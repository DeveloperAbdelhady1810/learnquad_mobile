import 'dart:convert';

/// Matches GET /api/teachers (list) and GET /api/teachers/{id} (detail, which
/// includes a `courses` array not present on the list response).
class TeacherSummary {
  const TeacherSummary({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
    this.subjects = const [],
    this.educationStages = const [],
  });

  final int id;
  final String name;
  final String? avatar;
  final String? bio;
  final List<String> subjects;
  final List<String> educationStages;

  /// The API's `subjects`/`education_stages` columns come from a raw
  /// `DB::table()` query (no Eloquent array cast), so they arrive as a
  /// JSON-encoded *string* (e.g. `"[\"mathematics\",\"physics\"]"`), not an
  /// actual JSON array — handle both shapes defensively.
  static List<String> _parseJsonArray(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {
        // Not valid JSON — fall through to empty.
      }
    }
    return const [];
  }

  factory TeacherSummary.fromJson(Map<String, dynamic> json) {
    return TeacherSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      subjects: _parseJsonArray(json['subjects']),
      educationStages: _parseJsonArray(json['education_stages']),
    );
  }
}

class TeacherCourseSummary {
  const TeacherCourseSummary({
    required this.id,
    required this.title,
    required this.price,
    this.grade,
    this.subject,
  });

  final int id;
  final String title;
  final double price;
  final String? grade;
  final String? subject;

  factory TeacherCourseSummary.fromJson(Map<String, dynamic> json) {
    return TeacherCourseSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      grade: json['grade'] as String?,
      subject: json['subject'] as String?,
    );
  }
}

class TeacherDetail extends TeacherSummary {
  const TeacherDetail({
    required super.id,
    required super.name,
    super.avatar,
    super.bio,
    super.subjects,
    super.educationStages,
    this.email,
    this.courses = const [],
  });

  final String? email;
  final List<TeacherCourseSummary> courses;

  factory TeacherDetail.fromJson(Map<String, dynamic> json) {
    return TeacherDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      email: json['email'] as String?,
      subjects: TeacherSummary._parseJsonArray(json['subjects']),
      educationStages: TeacherSummary._parseJsonArray(json['education_stages']),
      courses: (json['courses'] as List? ?? [])
          .map((c) => TeacherCourseSummary.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaginatedTeachers {
  const PaginatedTeachers({
    required this.data,
    required this.currentPage,
    required this.lastPage,
  });

  final List<TeacherSummary> data;
  final int currentPage;
  final int lastPage;

  factory PaginatedTeachers.fromJson(Map<String, dynamic> json) {
    return PaginatedTeachers(
      data: (json['data'] as List)
          .map((t) => TeacherSummary.fromJson(t as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
    );
  }
}
