

class LeaderboardEntry {
  final String user;
  final int points;
  final int workoutsCompleted;

  LeaderboardEntry({
    required this.user,
    required this.points,
    required this.workoutsCompleted,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      user: json['user'],
      points: json['points'],
      workoutsCompleted: json['workouts_completed'],
    );
  }
}
