import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import '../../courses/presentation/course_list_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../learning/presentation/my_courses_screen.dart';
import '../../notifications/application/notification_providers.dart';
import '../../teacher/presentation/teacher_dashboard_screen.dart';
import '../../teachers/presentation/teacher_list_screen.dart';

/// Branches by role: teachers get the read-only analytics dashboard (v1
/// scope — no course/video authoring from mobile), students get the full
/// browse/purchase/learn/quiz experience.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) =>
          Scaffold(body: Center(child: Text('تعذّر تحميل الملف الشخصي: $err'))),
      data: (user) => user.role == 'teacher'
          ? const TeacherDashboardScreen()
          : const _StudentHome(),
    );
  }
}

class _StudentHome extends ConsumerStatefulWidget {
  const _StudentHome();

  @override
  ConsumerState<_StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends ConsumerState<_StudentHome> {
  int _index = 0;

  static const _titles = ['الكورسات', 'المدرسين', 'كورساتي', 'لوحتي'];

  @override
  Widget build(BuildContext context) {
    final unreadAsync = ref.watch(unreadCountProvider);
    final unreadCount = unreadAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('LearnQuad', style: AppTextStyles.brand(size: 15)),
            const SizedBox(width: 10),
            Text(
              _titles[_index],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'الإشعارات',
                onPressed: () async {
                  await context.push('/notifications');
                  ref.invalidate(unreadCountProvider);
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'تسجيل الخروج',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          CourseListScreen(),
          TeacherListScreen(),
          MyCoursesScreen(),
          DashboardScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.menu_book_outlined, 'الكورسات'),
    (Icons.people_alt_outlined, 'المدرسين'),
    (Icons.video_collection_outlined, 'كورساتي'),
    (Icons.bar_chart_rounded, 'لوحتي'),
  ];

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 2)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: List.generate(_items.length, (i) {
          final (icon, label) = _items[i];
          final selected = i == index;
          final color = selected ? AppColors.accent : fg.withValues(alpha: 0.5);
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(height: 4),
                  Text(label, style: TextStyle(fontSize: 10, color: color)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
