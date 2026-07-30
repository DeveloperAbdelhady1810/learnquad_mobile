import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/course_providers.dart';
import '../data/course_models.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(courseListProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchCoursesHint,
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(courseListProvider.notifier).search('');
                      },
                    )
                  : null,
            ),
            onSubmitted: (value) =>
                ref.read(courseListProvider.notifier).search(value),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(courseListProvider.notifier).refresh(),
            child: _buildBody(state),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(CourseListState state) {
    if (state.isLoading && state.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.courses.isEmpty) {
      return Center(child: Text(state.errorMessage!));
    }
    if (state.courses.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noCoursesYet));
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.courses.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= state.courses.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _CourseCard(course: state.courses[index]);
      },
    );
  }
}

const _swatches = [
  AppColors.accent500,
  AppColors.accent700,
  AppColors.neutral600,
  AppColors.neutral800,
];

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _swatches[course.id % _swatches.length];
    final initial = course.subject?.isNotEmpty == true
        ? course.subject![0]
        : course.title[0];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.mdBr,
        border: Border.all(color: AppElevation.ringSm(isDark)),
        boxShadow: AppElevation.sm(isDark),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.push('/courses/${course.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.smBr,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: AppTextStyles.brand(
                      context,
                      size: 20,
                      color: AppColors.onAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (course.teacherName != null)
                        Text(
                          course.teacherName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.75),
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (course.grade != null)
                        AppTag(course.grade!, variant: AppTagVariant.neutral),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${localizedDigits(context, course.price.toStringAsFixed(0))} '
                  '${AppLocalizations.of(context)!.currencySuffix}',
                  style: AppTextStyles.brand(context, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
