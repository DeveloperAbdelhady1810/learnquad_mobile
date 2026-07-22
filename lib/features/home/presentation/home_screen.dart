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
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (err, _) =>
          Scaffold(body: Center(child: Text('Failed to load profile: $err'))),
      data: (user) => user.role == 'teacher'
          ? const TeacherDashboardScreen()
          : const _StudentHome(),
    );
  }
}

class _StudentHome extends ConsumerWidget {
  const _StudentHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadCountProvider);
    final unreadCount = unreadAsync.value ?? 0;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LearnQuad'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Courses', icon: Icon(Icons.menu_book_outlined)),
              Tab(text: 'Teachers', icon: Icon(Icons.people_outline)),
              Tab(text: 'My Courses', icon: Icon(Icons.school_outlined)),
              Tab(text: 'Dashboard', icon: Icon(Icons.dashboard_outlined)),
            ],
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Notifications',
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
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            CourseListScreen(),
            TeacherListScreen(),
            MyCoursesScreen(),
            DashboardScreen(),
          ],
        ),
      ),
    );
  }
}
