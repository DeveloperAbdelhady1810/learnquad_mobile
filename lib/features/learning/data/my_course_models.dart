/// Matches GET /api/my-courses list items — deliberately separate from
/// `Course` (in the courses feature) since the fields differ (no
/// description/sections here, but has enrolled_at/progress instead).
class MyCourse {
  const MyCourse({
    required this.id,
    required this.title,
    this.grade,
    this.subject,
    this.teacherName,
    required this.progress,
  });

  final int id;
  final String title;
  final String? grade;
  final String? subject;
  final String? teacherName;
  final int progress;

  factory MyCourse.fromJson(Map<String, dynamic> json) {
    return MyCourse(
      id: json['id'] as int,
      title: json['title'] as String,
      grade: json['grade'] as String?,
      subject: json['subject'] as String?,
      teacherName: json['teacher_name'] as String?,
      progress: int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
    );
  }
}
