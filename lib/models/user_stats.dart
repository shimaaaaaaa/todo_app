class UserStats {
  final int totalPoints;

  UserStats({
    this.totalPoints = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalPoints: json['totalPoints'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
    };
  }

  UserStats copyWith({
    int? totalPoints,
  }) {
    return UserStats(
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
