import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/helper/get_helper.dart';
import '../helper/app_logger.dart';
import '../../features/auth/views/login_page.dart';
import '../cache/cache_data.dart';
import '../cache/cache_helper.dart';
import '../cache/cache_keys.dart';
import 'api_response.dart';
import 'end_points.dart';

class ApiHelper {
  // Singleton
  static final ApiHelper _instance = ApiHelper._init();
  factory ApiHelper() {
    // initialize the dio instance and the interceptors
    _instance.initDio();
    return _instance;
  }

  ApiHelper._init();

  // Dio instance with its options configured
  late final dio.Dio _dio = dio.Dio(
    dio.BaseOptions(
      baseUrl: EndPoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      // Add retry configuration
      extra: {
        'retry': true,
        'retryCount': 3,
        'retryDelay': 1000, // milliseconds
      },
    ),
  );

  // Flag to prevent multiple refresh attempts
  bool _isRefreshing = false;
  // Queue to store pending requests during refresh
  final List<Future Function()> _pendingRequests = [];
  // Maximum number of refresh attempts
  int _refreshAttempts = 0;
  static const int maxRefreshAttempts = 2;
  // Flag to track if we're in initial app launch
  bool _isInitialLaunch = true;
  // Flag to track if refresh token is expired
  bool _isRefreshTokenExpired = false;

  // Check internet connectivity
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        Get.snackbar(
          'No Internet',
          'Please check your internet connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
      return true;
    } on SocketException catch (_) {
      Get.snackbar(
        'Connection Error',
        'Please check your internet connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  // Retry mechanism for failed requests
  Future<dio.Response> _retryRequest(dio.RequestOptions requestOptions) async {
    int retryCount = requestOptions.extra['retryCount'] ?? 3;
    int retryDelay = requestOptions.extra['retryDelay'] ?? 1000;

    while (retryCount > 0) {
      try {
        await Future.delayed(Duration(milliseconds: retryDelay));
        final response = await _dio.fetch(requestOptions);
        return response;
      } catch (e) {
        retryCount--;
        if (retryCount == 0) {
          if (e is dio.DioException) {
            if (e.type == dio.DioExceptionType.connectionTimeout ||
                e.type == dio.DioExceptionType.sendTimeout ||
                e.type == dio.DioExceptionType.receiveTimeout ||
                e.type == dio.DioExceptionType.connectionError) {
              Get.snackbar(
                'Connection Error',
                'Unable to connect to the server after multiple attempts. Please check your internet connection.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 5),
              );
            }
          }
          rethrow;
        }
        // Exponential backoff
        retryDelay *= 2;
      }
    }
    throw Exception('Max retries reached');
  }

  void initDio() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check internet connection before making request
          if (!await _checkInternetConnection()) {
            return handler.reject(
              dio.DioException(
                requestOptions: options,
                error: 'No internet connection',
                type: dio.DioExceptionType.connectionError,
              ),
            );
          }

          // Just Print the details of the call for observation purposes
          AppLogger.yellow("Request --- endpoint : ${options.path.toString()}");

          // Add authorization header if needed
          if (options.headers.containsKey('Authorization')) {
            String? token;
            if (options.headers['Authorization']
                    ?.toString()
                    .contains('refresh') ==
                true) {
              token = await CacheHelper.getData(key: CacheKeys.refreshToken);
            } else {
              token = CacheData.accessToken;
            }
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          // then continue the call
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Print the response in case of success
          AppLogger.green("--- Response : ${response.data.toString()}");
          // Continue the process
          return handler.next(response);
        },
        onError: (dio.DioException error, handler) async {
          // Print the error Body in case of failure
          AppLogger.red("--- Error : ${error.response?.data.toString()}");

          // Handle connection errors
          if (error.type == dio.DioExceptionType.connectionTimeout ||
              error.type == dio.DioExceptionType.sendTimeout ||
              error.type == dio.DioExceptionType.receiveTimeout ||
              error.type == dio.DioExceptionType.connectionError) {
            // Show specific error message for API connectivity
            if (!_isInitialLaunch) {
              Get.snackbar(
                'API Error',
                'Unable to connect to the server. The API might be down or unreachable.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 5),
              );
            }

            // Check if retry is enabled and we haven't exceeded retry count
            if (error.requestOptions.extra['retry'] == true) {
              try {
                final response = await _retryRequest(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          // Check if the error is due to an expired token
          if (error.response?.data['message']
                      ?.toString()
                      .contains('expired') ==
                  true ||
              error.response?.data['message']?.toString().contains('missing') ==
                  true ||
              error.response?.statusCode == 401) {
            // If this is a refresh token request that failed, mark refresh token as expired
            if (error.requestOptions.path == EndPoints.refreshToken) {
              _isRefreshTokenExpired = true;
              await _logoutAndClearData();
              return handler.next(error);
            }

            if (_isRefreshing) {
              return _queueRequest(error, handler);
            }

            // Start refresh process
            _isRefreshing = true;

            try {
              // For initial launch, skip refresh attempt if it's the first request
              if (_isInitialLaunch &&
                  error.requestOptions.path == EndPoints.getUserData) {
                _isInitialLaunch = false;
                await _logoutAndClearData();
                return handler.next(error);
              }

              // Don't attempt refresh if refresh token is expired
              if (_isRefreshTokenExpired) {
                await _logoutAndClearData();
                return handler.next(error);
              }

              // Attempt to refresh token
              ApiResponse apiResponse = await _instance.postRequest(
                endPoint: EndPoints.refreshToken,
                sendRefreshToken: true,
                isProtected: true,
              );

              if (apiResponse.status) {
                // Update tokens
                CacheData.accessToken = apiResponse.data['access_token'];
                await CacheHelper.saveData(
                  key: CacheKeys.accessToken,
                  value: CacheData.accessToken,
                );

                // Process all queued requests
                for (var request in _pendingRequests) {
                  await request();
                }
                _pendingRequests.clear();

                // Retry original request
                final options = error.requestOptions;
                options.headers['Authorization'] =
                    'Bearer ${CacheData.accessToken}';

                // Handle FormData properly
                if (options.data is dio.FormData) {
                  final oldFormData = options.data as dio.FormData;
                  final Map<String, dynamic> formMap = {};
                  for (var entry in oldFormData.fields) {
                    formMap[entry.key] = entry.value;
                  }
                  for (var file in oldFormData.files) {
                    formMap[file.key] = file.value;
                  }
                  options.data = dio.FormData.fromMap(formMap);
                }

                final response = await _dio.fetch(options);
                _isRefreshing = false;
                return handler.resolve(response);
              } else {
                await _handleRefreshFailure();
                return handler.next(error);
              }
            } catch (e) {
              await _handleRefreshFailure();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _handleRefreshFailure() async {
    _refreshAttempts++;

    if (_refreshAttempts < maxRefreshAttempts && !_isRefreshTokenExpired) {
      // Try to refresh token again
      try {
        ApiResponse apiResponse = await _instance.postRequest(
          endPoint: EndPoints.refreshToken,
          sendRefreshToken: true,
          isProtected: true,
        );

        if (apiResponse.status) {
          // Update tokens
          CacheData.accessToken = apiResponse.data['access_token'];
          await CacheHelper.saveData(
            key: CacheKeys.accessToken,
            value: CacheData.accessToken,
          );

          // Reset refresh attempts counter
          _refreshAttempts = 0;
          _isRefreshing = false;
          _isRefreshTokenExpired = false;

          // Process all queued requests
          for (var request in _pendingRequests) {
            await request();
          }
          _pendingRequests.clear();

          return;
        }
      } catch (e) {
        // Continue to logout if refresh fails
      }
    }

    // If we've exhausted all refresh attempts or refresh failed
    await _logoutAndClearData();
  }

  Future<void> _logoutAndClearData() async {
    // Clear tokens and user data
    await CacheHelper.removeData(key: CacheKeys.accessToken);
    await CacheHelper.removeData(key: CacheKeys.refreshToken);
    await CacheHelper.removeData(key: CacheKeys.userModel);
    await CacheHelper.removeData(key: CacheKeys.loggedIn);

    // Clear pending requests
    _pendingRequests.clear();
    _isRefreshing = false;
    _refreshAttempts = 0;
    _isRefreshTokenExpired = false;

    // Show error message and navigate to login
    if (!_isInitialLaunch) {
      Get.snackbar(
        'Session Expired',
        'Your session has expired. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
    _isInitialLaunch = false;

    // Use Future.microtask to ensure navigation happens after current frame
    Future.microtask(() {
      GetHelper.pushReplaceAll(() => LoginPage());
    });
  }

  Future<void> _queueRequest(
      dio.DioException error, dio.ErrorInterceptorHandler handler) async {
    _pendingRequests.add(() async {
      try {
        final options = error.requestOptions;
        options.headers['Authorization'] = 'Bearer ${CacheData.accessToken}';
        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(error);
      }
    });
  }

  // Post Request
  Future<ApiResponse> postRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = true,
    bool isProtected = false,
    bool sendRefreshToken = false,
  }) async {
    String? token;
    if (isProtected) {
      if (sendRefreshToken) {
        token = await CacheHelper.getData(key: CacheKeys.refreshToken);
      } else {
        token = CacheData.accessToken;
      }
    }

    return ApiResponse.fromResponse(
      await _dio.post(
        endPoint,
        data: isFormData ? dio.FormData.fromMap(data ?? {}) : data,
        options: dio.Options(
          headers: {
            if (isProtected && token != null) 'Authorization': 'Bearer $token',
          },
        ),
      ),
    );
  }

  Future<dio.Response> getRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = true,
    bool isProtected = false,
    bool sendRefreshToken = false,
  }) async {
    AppLogger.bgYellow("getRequest called");
    String? token;
    if (isProtected) {
      if (sendRefreshToken) {
        token = await CacheHelper.getData(key: CacheKeys.refreshToken);
      } else {
        token = CacheData.accessToken;
      }
    }

    return await _dio.get(
      endPoint,
      data: isFormData ? dio.FormData.fromMap(data ?? {}) : data,
      options: dio.Options(
        headers: {
          if (isProtected && token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<dio.Response> putRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = true,
    bool isProtected = false,
    bool sendRefreshToken = false,
  }) async {
    String? token;
    if (isProtected) {
      if (sendRefreshToken) {
        token = await CacheHelper.getData(key: CacheKeys.refreshToken);
      } else {
        token = CacheData.accessToken;
      }
    }

    return await _dio.put(
      endPoint,
      data: isFormData ? dio.FormData.fromMap(data ?? {}) : data,
      options: dio.Options(
        headers: {
          if (isProtected && token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<dio.Response> deleteRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = true,
    bool isProtected = false,
    bool sendRefreshToken = false,
  }) async {
    String? token;
    if (isProtected) {
      if (sendRefreshToken) {
        token = await CacheHelper.getData(key: CacheKeys.refreshToken);
      } else {
        token = CacheData.accessToken;
      }
    }

    return await _dio.delete(
      endPoint,
      data: isFormData ? dio.FormData.fromMap(data ?? {}) : data,
      options: dio.Options(
        headers: {
          if (isProtected && token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
