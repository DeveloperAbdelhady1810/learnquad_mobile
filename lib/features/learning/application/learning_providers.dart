import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/learning_repository.dart';
import '../data/my_course_models.dart';

final myCoursesProvider = FutureProvider<List<MyCourse>>((ref) {
  return ref.watch(learningRepositoryProvider).myCourses();
});

final courseLecturesProvider = FutureProvider.family((ref, int courseId) {
  return ref.watch(learningRepositoryProvider).lecturesFor(courseId);
});
