class Submission {
  final String token;

  Submission({required this.token});

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      token: json['token'],
    );
  }
}
