import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/courses/presentation/course_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/learning/presentation/course_lectures_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/teachers/presentation/teacher_detail_screen.dart';

/// Bridges Riverpod state changes into a [Listenable] go_router can watch,
/// so a login/logout immediately triggers a redirect re-evaluation.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthChangeNotifier(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final path = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return path == '/splash' ? null : '/splash';
      }

      final isLoggedIn = status == AuthStatus.authenticated;

      // Splash is only ever a transient loading state, never a real
      // destination — once status is resolved, always leave it.
      if (path == '/splash') return isLoggedIn ? '/home' : '/login';

      final onAuthGate = path == '/login' || path == '/register';
      if (!isLoggedIn && !onAuthGate) return '/login';
      if (isLoggedIn && onAuthGate) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/courses/:id',
        builder: (context, state) => CourseDetailScreen(
          courseId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/teachers/:id',
        builder: (context, state) => TeacherDetailScreen(
          teacherId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/my-courses/:id',
        builder: (context, state) => CourseLecturesScreen(
          courseId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
