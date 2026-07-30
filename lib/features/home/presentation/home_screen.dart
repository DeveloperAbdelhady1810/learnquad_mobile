import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../courses/presentation/course_list_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../learning/presentation/my_courses_screen.dart';
import '../../notifications/application/notification_providers.dart';
import '../../profile/presentation/profile_screen.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text(l10n.failedToLoadProfile(err.toString()))),
      ),
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

  @override
  Widget build(BuildContext context) {
    final unreadAsync = ref.watch(unreadCountProvider);
    final unreadCount = unreadAsync.value ?? 0;
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.navDashboard,
      l10n.navCourses,
      l10n.navTeachers,
      l10n.navMyCourses,
      l10n.navProfile,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appName, style: AppTextStyles.brand(context, size: 15)),
            const SizedBox(width: 10),
            Text(
              titles[_index],
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
                tooltip: l10n.notifications,
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
                      color: Theme.of(context).colorScheme.primary,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          CourseListScreen(),
          TeacherListScreen(),
          MyCoursesScreen(),
          ProfileScreen(),
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

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.menu_book_outlined, l10n.navCourses),
      (Icons.people_alt_outlined, l10n.navTeachers),
      (Icons.video_collection_outlined, l10n.navMyCourses),
      (Icons.bar_chart_rounded, l10n.navDashboard),
      (Icons.person_outline, l10n.navProfile),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: List.generate(items.length, (i) {
              final (icon, label) = items[i];
              final selected = i == index;
              final color = selected ? accent : fg.withValues(alpha: 0.5);
              return Expanded(
                child: InkWell(
                  borderRadius: AppRadius.mdBr,
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: AppRadius.mdBr,
                        ),
                        child: Icon(icon, size: 20, color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
