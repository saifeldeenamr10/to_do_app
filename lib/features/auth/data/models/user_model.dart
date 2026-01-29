class LoginResponseModel {
  String? accessToken;
  String? refreshToken;
  bool? status;
  UserModel? user;

  LoginResponseModel({
    this.accessToken,
    this.refreshToken,
    this.status,
    this.user,
  });

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    status = json['status'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['access_token'] = accessToken;
    json['refresh_token'] = refreshToken;
    json['status'] = status;
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return json;
  }
}

class UserModel {
  int? id;
  String? imagePath;
  String? username;
  String? refreshToken;

  UserModel({
    this.id,
    this.imagePath,
    this.username,
    this.refreshToken,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imagePath = json['image_path'];
    username = json['username'];
    refreshToken = json['refresh_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image_path'] = imagePath;
    data['username'] = username;
    data['refresh_token'] = refreshToken;
    return data;
  }

  UserModel copyWith({
    int? id,
    String? imagePath,
    String? username,
    String? refreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      username: username ?? this.username,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
