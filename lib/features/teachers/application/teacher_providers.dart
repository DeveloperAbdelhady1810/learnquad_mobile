import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/teacher_models.dart';
import '../data/teacher_repository.dart';

class TeacherListState {
  const TeacherListState({
    this.teachers = const [],
    this.page = 1,
    this.lastPage = 1,
    this.isLoading = false,
    this.search = '',
    this.errorMessage,
  });

  final List<TeacherSummary> teachers;
  final int page;
  final int lastPage;
  final bool isLoading;
  final String search;
  final String? errorMessage;

  bool get hasMore => page < lastPage;

  TeacherListState copyWith({
    List<TeacherSummary>? teachers,
    int? page,
    int? lastPage,
    bool? isLoading,
    String? search,
    String? errorMessage,
  }) {
    return TeacherListState(
      teachers: teachers ?? this.teachers,
      page: page ?? this.page,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      search: search ?? this.search,
      errorMessage: errorMessage,
    );
  }
}

class TeacherListController extends Notifier<TeacherListState> {
  @override
  TeacherListState build() {
    Future.microtask(refresh);
    return const TeacherListState(isLoading: true);
  }

  TeacherRepository get _repo => ref.read(teacherRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repo.list(page: 1, search: state.search);
      state = state.copyWith(
        teachers: result.data,
        page: result.currentPage,
        lastPage: result.lastPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load teachers.',
      );
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(search: query);
    await refresh();
  }
}

final teacherListProvider =
    NotifierProvider<TeacherListController, TeacherListState>(
      TeacherListController.new,
    );

final teacherDetailProvider = FutureProvider.family<TeacherDetail, int>((
  ref,
  id,
) {
  return ref.watch(teacherRepositoryProvider).detail(id);
});
