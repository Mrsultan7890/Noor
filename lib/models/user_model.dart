class User {
  final String id;
  final String email;
  final String username;
  final String country;
  final String level;
  final int points;
  final int streakDays;
  final double quranProgress;
  final int prayersLogged;
  final int lessonsCompleted;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.country,
    required this.level,
    required this.points,
    required this.streakDays,
    required this.quranProgress,
    required this.prayersLogged,
    required this.lessonsCompleted,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      country: json['country'],
      level: json['level'],
      points: json['points'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      quranProgress: (json['quran_progress'] ?? 0.0).toDouble(),
      prayersLogged: json['prayers_logged'] ?? 0,
      lessonsCompleted: json['lessons_completed'] ?? 0,
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'country': country,
      'level': level,
      'points': points,
      'streak_days': streakDays,
      'quran_progress': quranProgress,
      'prayers_logged': prayersLogged,
      'lessons_completed': lessonsCompleted,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String country;
  final int points;
  final String? avatar;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.country,
    required this.points,
    this.avatar,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'],
      userId: json['user_id'],
      username: json['username'],
      country: json['country'],
      points: json['points'],
      avatar: json['avatar'],
    );
  }
}
