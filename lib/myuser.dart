class MyUser {
  final String login;
  final String email;

  MyUser({required this.login, required this.email});

  MyUser.fromJson(Map<String, Object?> json)
      : this(login: json['login'] as String, email: json['email'] as String);

  Map<String, Object?> toJson() {
    return {
      'login': login,
      'email': email,
    };
  }
}
