/// Matches GET /api/dashboard. `streak` is currently always 0 on the backend
/// (hardcoded `// TODO` — see the mobile plan's open items) — displayed as-is,
/// not hidden, so it's obvious once the backend implements it for real.
class DashboardStats {
  const DashboardStats({
    required this.enrolled,
    required this.completed,
    required this.streak,
  });

  final int enrolled;
  final int completed;
  final int streak;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      enrolled: json['enrolled'] as int,
      completed: json['completed'] as int,
      streak: json['streak'] as int,
    );
  }
}
