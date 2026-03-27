import '../../../../core/constants/firebase_constants.dart';

class UserModel {
  String? id;
  String? imagePath;
  String? username;
  String? email;

  UserModel({
    this.id,
    this.imagePath,
    this.username,
    this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      imagePath: map[FirebaseConstants.profileImage],
      username: map[FirebaseConstants.username],
      email: map[FirebaseConstants.email],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.username: username,
      FirebaseConstants.email: email,
      FirebaseConstants.profileImage: imagePath,
    };
  }

  // Legacy support for JSON caching if still used
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      imagePath: json['image_path'],
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['image_path'] = imagePath;
    data['username'] = username;
    data['email'] = email;
    return data;
  }

  UserModel copyWith({
    String? id,
    String? imagePath,
    String? username,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}
