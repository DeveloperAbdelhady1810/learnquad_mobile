import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/course_models.dart';
import '../data/course_repository.dart';

class CourseListState {
  const CourseListState({
    this.courses = const [],
    this.page = 1,
    this.lastPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.search = '',
    this.errorMessage,
  });

  final List<Course> courses;
  final int page;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final String search;
  final String? errorMessage;

  bool get hasMore => page < lastPage;

  CourseListState copyWith({
    List<Course>? courses,
    int? page,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    String? search,
    String? errorMessage,
  }) {
    return CourseListState(
      courses: courses ?? this.courses,
      page: page ?? this.page,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
      errorMessage: errorMessage,
    );
  }
}

class CourseListController extends Notifier<CourseListState> {
  @override
  CourseListState build() {
    Future.microtask(refresh);
    return const CourseListState(isLoading: true);
  }

  CourseRepository get _repo => ref.read(courseRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repo.list(page: 1, search: state.search);
      state = state.copyWith(
        courses: result.data,
        page: result.currentPage,
        lastPage: result.lastPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load courses.',
      );
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(search: query);
    await refresh();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _repo.list(
        page: state.page + 1,
        search: state.search,
      );
      state = state.copyWith(
        courses: [...state.courses, ...result.data],
        page: result.currentPage,
        lastPage: result.lastPage,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final courseListProvider =
    NotifierProvider<CourseListController, CourseListState>(
      CourseListController.new,
    );

final courseDetailProvider = FutureProvider.family<Course, int>((ref, id) {
  return ref.watch(courseRepositoryProvider).detail(id);
});
