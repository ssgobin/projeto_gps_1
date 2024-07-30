class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
    };
  }
}
