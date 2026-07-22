import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/webview/bridge_webview_screen.dart';
import '../../purchase/data/webview_ticket_repository.dart';
import '../application/course_providers.dart';
import '../data/course_models.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Course')),
      body: courseAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Failed to load course: $err')),
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
            title: 'Checkout',
            interceptUrlContains: '/payment/callback',
            interceptSuccess: (uri) => uri.queryParameters['success'] == 'true',
          ),
        ),
      );

      if (!mounted) return;
      if (success == true) {
        ref.invalidate(courseDetailProvider(widget.course.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase successful! You are now enrolled.'),
          ),
        );
      } else if (success == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment was not completed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not start checkout: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final totalLectures =
        course.sections?.fold<int>(0, (sum, s) => sum + s.lectures.length) ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(course.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        if (course.teacherName != null)
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                course.teacherName!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${course.price.toStringAsFixed(0)} EGP',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              '$totalLectures lectures',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        const Divider(height: 32),
        if (course.description != null) ...[
          Text(
            'About this course',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(course.description!),
          const Divider(height: 32),
        ],
        Text('Content', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...?course.sections?.map((section) => _SectionTile(section: section)),
        const SizedBox(height: 24),
        ElevatedButton(
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
              : Text('Buy — ${course.price.toStringAsFixed(0)} EGP'),
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
    return ExpansionTile(
      title: Text(
        section.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: section.lectures.map((lecture) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 16),
          leading: Icon(
            lecture.type == 'video'
                ? Icons.play_circle_outline
                : Icons.description_outlined,
            color: AppColors.primary,
          ),
          title: Text(lecture.title),
          trailing: lecture.isFree
              ? const Text(
                  'Free',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                )
              : const Icon(Icons.lock_outline, size: 16, color: Colors.black38),
        );
      }).toList(),
    );
  }
}
