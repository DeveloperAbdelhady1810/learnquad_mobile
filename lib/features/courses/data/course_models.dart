/// Matches GET /api/courses (list item — a subset of columns) and
/// GET /api/courses/{id} (full row via `courses.*`, hence the extra nullable
/// fields only present on the detail response).
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.grade,
    required this.subject,
    this.views,
    this.teacherName,
    this.teacherAvatar,
    this.teacherBio,
    this.sections,
  });

  final int id;
  final String title;
  final String? description;
  final double price;
  final String? grade;
  final String? subject;
  final int? views;
  final String? teacherName;
  final String? teacherAvatar;
  final String? teacherBio;
  final List<CourseSection>? sections;

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: _parsePrice(json['price']),
      grade: json['grade'] as String?,
      subject: json['subject'] as String?,
      views: json['views'] as int?,
      teacherName: json['teacher_name'] as String?,
      teacherAvatar: json['teacher_avatar'] as String?,
      teacherBio: json['teacher_bio'] as String?,
      sections: json['sections'] != null
          ? (json['sections'] as List)
                .map((s) => CourseSection.fromJson(s as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}

class CourseSection {
  const CourseSection({
    required this.id,
    required this.title,
    required this.lectures,
  });

  final int id;
  final String title;
  final List<CourseLecture> lectures;

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'] as int,
      title: json['title'] as String,
      lectures: (json['lectures'] as List? ?? [])
          .map((l) => CourseLecture.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CourseLecture {
  const CourseLecture({
    required this.id,
    required this.title,
    required this.type,
    required this.isFree,
    this.videoDuration,
    this.completed,
    this.lastPosition,
    this.progressPercentage,
  });

  final int id;
  final String title;
  final String type;
  final bool isFree;
  final int? videoDuration;
  final bool? completed;
  final int? lastPosition;
  final int? progressPercentage;

  factory CourseLecture.fromJson(Map<String, dynamic> json) {
    return CourseLecture(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
      isFree: json['is_free'] == true || json['is_free'] == 1,
      videoDuration: json['video_duration'] as int?,
      completed: json['completed'] == null
          ? null
          : (json['completed'] == true || json['completed'] == 1),
      lastPosition: json['last_position'] as int?,
      progressPercentage: json['progress_percentage'] as int?,
    );
  }
}

class PaginatedCourses {
  const PaginatedCourses({
    required this.data,
    required this.currentPage,
    required this.lastPage,
  });

  final List<Course> data;
  final int currentPage;
  final int lastPage;

  factory PaginatedCourses.fromJson(Map<String, dynamic> json) {
    return PaginatedCourses(
      data: (json['data'] as List)
          .map((c) => Course.fromJson(c as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
    );
  }
}
