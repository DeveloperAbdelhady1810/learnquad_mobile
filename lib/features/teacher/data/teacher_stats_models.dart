/// Matches GET /api/teacher/stats.
class TeacherStats {
  const TeacherStats({
    required this.students,
    required this.revenue,
    required this.courses,
  });

  final int students;
  final double revenue;
  final int courses;

  factory TeacherStats.fromJson(Map<String, dynamic> json) {
    return TeacherStats(
      students: json['students'] as int,
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0,
      courses: json['courses'] as int,
    );
  }
}

/// Matches GET /api/teacher/courses items (`courses.*` + a computed
/// `enrollment_count`) — read-only display, per the v1 scope: teachers get
/// analytics only, never course/video authoring from mobile.
class TeacherCourseRow {
  const TeacherCourseRow({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    required this.enrollmentCount,
  });

  final int id;
  final String title;
  final double price;
  final String status;
  final int enrollmentCount;

  factory TeacherCourseRow.fromJson(Map<String, dynamic> json) {
    return TeacherCourseRow(
      id: json['id'] as int,
      title: json['title'] as String,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      status: json['status'] as String,
      enrollmentCount:
          int.tryParse(json['enrollment_count']?.toString() ?? '0') ?? 0,
    );
  }
}
