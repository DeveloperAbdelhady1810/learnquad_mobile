/// Matches GET /api/dashboard. `streak` is currently always 0 on the backend
/// (hardcoded `// TODO` — see the mobile plan's open items) — displayed as-is,
/// not hidden, so it's obvious once the backend implements it for real.
class DashboardStats {
  const DashboardStats({
    required this.enrolled,
    required this.completed,
    required this.streak,
    this.continueWatching,
    this.upNext,
  });

  final int enrolled;
  final int completed;
  final int streak;
  final ContinueWatching? continueWatching;
  final UpNextLecture? upNext;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      enrolled: json['enrolled'] as int,
      completed: json['completed'] as int,
      streak: json['streak'] as int,
      continueWatching: json['continueWatching'] != null
          ? ContinueWatching.fromJson(
              json['continueWatching'] as Map<String, dynamic>,
            )
          : null,
      upNext: json['upNext'] != null
          ? UpNextLecture.fromJson(json['upNext'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// The most recently-touched incomplete lecture — null when the student
/// hasn't started anything yet. Matches the `continueWatching` object built
/// in routes/api.php's `/dashboard` endpoint.
class ContinueWatching {
  const ContinueWatching({
    required this.courseId,
    required this.lectureId,
    required this.courseTitle,
    required this.lectureTitle,
    required this.progressPercentage,
    required this.totalSections,
    this.subject,
    this.grade,
    this.teacherName,
    this.thumbnail,
    this.sectionPosition,
  });

  final int courseId;
  final int lectureId;
  final String courseTitle;
  final String lectureTitle;
  final String? subject;
  final String? grade;
  final String? teacherName;
  final String? thumbnail;
  final num progressPercentage;
  final int? sectionPosition;
  final int totalSections;

  factory ContinueWatching.fromJson(Map<String, dynamic> json) {
    return ContinueWatching(
      courseId: json['course_id'] as int,
      lectureId: json['lecture_id'] as int,
      courseTitle: json['course_title'] as String,
      lectureTitle: json['lecture_title'] as String,
      subject: json['subject'] as String?,
      grade: json['grade'] as String?,
      teacherName: json['teacher_name'] as String?,
      thumbnail: json['thumbnail'] as String?,
      progressPercentage: (json['progress_percentage'] as num?) ?? 0,
      sectionPosition: json['section_position'] as int?,
      totalSections: json['total_sections'] as int? ?? 0,
    );
  }
}

/// Whichever lecture comes right after the in-progress one in curriculum
/// order — null if there isn't one (e.g. it was the course's last lecture).
class UpNextLecture {
  const UpNextLecture({
    required this.courseId,
    required this.lectureId,
    required this.lectureTitle,
    this.videoDuration,
  });

  final int courseId;
  final int lectureId;
  final String lectureTitle;
  final int? videoDuration;

  factory UpNextLecture.fromJson(Map<String, dynamic> json) {
    return UpNextLecture(
      courseId: json['course_id'] as int,
      lectureId: json['lecture_id'] as int,
      lectureTitle: json['lecture_title'] as String,
      videoDuration: json['video_duration'] as int?,
    );
  }
}
