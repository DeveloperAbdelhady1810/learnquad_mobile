import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../core/webview/bridge_webview_screen.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../learning/application/learning_providers.dart';
import '../../purchase/data/webview_ticket_repository.dart';
import '../application/course_providers.dart';
import '../data/course_models.dart';

const _swatches = [
  Color(0xFF7C1405),
  Color(0xFF8B2E1F),
  Color(0xFF605D5D),
  Color(0xFF444141),
];

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.failedToLoadCourse(err.toString()))),
        data: (course) => _CourseDetailBody(course: course),
      ),
    );
  }
}

class _CourseDetailBody extends ConsumerStatefulWidget {
  const _CourseDetailBody({required this.course});
  final Course course;

  @override
  ConsumerState<_CourseDetailBody> createState() => _CourseDetailBodyState();
}

class _CourseDetailBodyState extends ConsumerState<_CourseDetailBody> {
  bool _isBuying = false;

  Future<void> _handleBuy() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isBuying = true);
    try {
      final bridgeUrl = await ref
          .read(webviewTicketRepositoryProvider)
          .requestPayCourseTicket(courseId: widget.course.id);

      if (!mounted) return;
      final success = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => BridgeWebViewScreen(
            initialUrl: bridgeUrl,
            title: l10n.checkoutTitle,
            interceptUrlContains: '/payment/callback',
            interceptSuccess: (uri) => uri.queryParameters['success'] == 'true',
          ),
        ),
      );

      if (!mounted) return;
      if (success == true) {
        ref.invalidate(courseDetailProvider(widget.course.id));
        ref.invalidate(myCoursesProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.purchaseSuccess)));
      } else if (success == false) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paymentNotCompleted)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.checkoutFailed(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final l10n = AppLocalizations.of(context)!;
    final totalLectures =
        course.sections?.fold<int>(0, (sum, s) => sum + s.lectures.length) ?? 0;
    final myCoursesAsync = ref.watch(myCoursesProvider);
    final isEnrolled = myCoursesAsync.maybeWhen(
      data: (courses) => courses.any((c) => c.id == course.id),
      orElse: () => false,
    );
    final heroColor = _swatches[course.id % _swatches.length];
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 180,
                color: heroColor,
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: BackButton(color: bg),
                    ),
                    if (course.subject != null)
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          color: bg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            course.subject!,
                            style: TextStyle(fontSize: 11, color: heroColor),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                    ),
                    if (course.teacherName != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: AppColors.neutral300,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            course.teacherName!,
                            style: TextStyle(
                              fontSize: 13,
                              color: fg?.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (course.grade != null)
                          AppTag(course.grade!, variant: AppTagVariant.neutral),
                        AppTag(
                          l10n.lecturesCount(
                            localizedDigits(context, totalLectures),
                          ),
                          variant: AppTagVariant.neutral,
                        ),
                      ],
                    ),
                    if (course.description != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        course.description!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.85,
                          color: fg?.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Divider(
                        height: 2,
                        thickness: 2,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Text(
                      l10n.courseContent,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.unitsAndLectures(
                        localizedDigits(context, course.sections?.length ?? 0),
                        localizedDigits(context, totalLectures),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: fg?.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...?course.sections?.map(
                      (section) => _SectionTile(section: section),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor, width: 2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: isEnrolled
                ? ElevatedButton(
                    onPressed: () => context.push('/my-courses/${course.id}'),
                    child: Text(l10n.continueLearning),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.priceLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: fg?.withValues(alpha: 0.55),
                              ),
                            ),
                            Text(
                              '${localizedDigits(context, course.price.toStringAsFixed(0))} '
                              '${l10n.currencySuffix}',
                              style: AppTextStyles.brand(context, size: 20),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isBuying ? null : _handleBuy,
                          child: _isBuying
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(l10n.buyNow),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section});
  final CourseSection section;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: section.lectures.map((lecture) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              lecture.type == 'video'
                  ? Icons.play_circle_outline
                  : Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(lecture.title, style: const TextStyle(fontSize: 13.5)),
            trailing: lecture.isFree
                ? AppTag(
                    AppLocalizations.of(context)!.freeTag,
                    variant: AppTagVariant.accent,
                  )
                : const Icon(Icons.lock_outline, size: 16),
          );
        }).toList(),
      ),
    );
  }
}
