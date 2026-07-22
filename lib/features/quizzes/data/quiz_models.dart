/// Matches GET /api/courses/{course}/quizzes list items.
class QuizSummary {
  const QuizSummary({
    required this.id,
    required this.title,
    this.description,
    required this.passScore,
    this.durationMinutes,
    required this.questionCount,
    required this.submitted,
  });

  final int id;
  final String title;
  final String? description;
  final int passScore;
  final int? durationMinutes;
  final int questionCount;
  final bool submitted;

  factory QuizSummary.fromJson(Map<String, dynamic> json) {
    return QuizSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      passScore: json['pass_score'] as int,
      durationMinutes: json['duration_minutes'] as int?,
      questionCount: json['question_count'] as int,
      submitted: json['submitted'] == true,
    );
  }
}

/// Matches GET /api/quizzes/{quiz} — note `options` is a map of
/// {"A": "...", "B": "...", ...} per QuizQuestion.options, and
/// `correct_answer` is deliberately never sent by the API before submission.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.questionText,
    this.image,
    required this.options,
    required this.points,
  });

  final int id;
  final String questionText;
  final String? image;
  final Map<String, String> options;
  final int points;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as Map<String, dynamic>;
    return QuizQuestion(
      id: json['id'] as int,
      questionText: json['question_text'] as String,
      image: json['image'] as String?,
      options: rawOptions.map((k, v) => MapEntry(k, v.toString())),
      points: json['points'] as int,
    );
  }
}

class QuizDetail {
  const QuizDetail({
    required this.id,
    required this.title,
    this.description,
    required this.passScore,
    this.durationMinutes,
    required this.questions,
  });

  final int id;
  final String title;
  final String? description;
  final int passScore;
  final int? durationMinutes;
  final List<QuizQuestion> questions;

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    return QuizDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      passScore: json['pass_score'] as int,
      durationMinutes: json['duration_minutes'] as int?,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Matches GET /api/quizzes/{quiz}/result.
class QuizResult {
  const QuizResult({
    required this.quizId,
    required this.title,
    required this.score,
    required this.totalScore,
    required this.percentage,
    required this.passed,
    required this.passScore,
    required this.answers,
  });

  final int quizId;
  final String title;
  final int score;
  final int totalScore;
  final double percentage;
  final bool passed;
  final int passScore;
  final List<QuizAnswerResult> answers;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      quizId: json['quiz_id'] as int,
      title: json['title'] as String,
      score: json['score'] as int,
      totalScore: json['total_score'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      passed: json['passed'] == true,
      passScore: json['pass_score'] as int,
      answers: (json['answers'] as List)
          .map((a) => QuizAnswerResult.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizAnswerResult {
  const QuizAnswerResult({
    required this.questionId,
    required this.questionText,
    this.yourAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.pointsEarned,
  });

  final int questionId;
  final String questionText;
  final String? yourAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int pointsEarned;

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) {
    return QuizAnswerResult(
      questionId: json['question_id'] as int,
      questionText: json['question_text'] as String,
      yourAnswer: json['your_answer'] as String?,
      correctAnswer: json['correct_answer'] as String,
      isCorrect: json['is_correct'] == true,
      pointsEarned: json['points_earned'] as int,
    );
  }
}
