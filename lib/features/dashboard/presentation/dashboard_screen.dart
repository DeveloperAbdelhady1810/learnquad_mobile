import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../learning/application/learning_providers.dart';
import '../../learning/presentation/lecture_watch_screen.dart';
import '../data/dashboard_repository.dart';
import '../data/dashboard_stats.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // Mirrors CourseLecturesScreen._watchLecture — fetches the course's full
  // section/lecture list (needed by LectureWatchScreen for prev/next/up-next
  // chrome), then jumps straight into the player at the given lecture,
  // instead of routing through the lecture-list screen first.
  Future<void> _openLecture(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int courseId,
    int lectureId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final sections = await ref.read(courseLecturesProvider(courseId).future);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LectureWatchScreen(
            courseId: courseId,
            sections: sections,
            initialLectureId: lectureId,
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.failedToOpenLecture(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardStatsProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          userAsync.when(
            data: (user) => _GreetingHeader(name: user.name, l10n: l10n),
            loading: () => const SizedBox(height: 48),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 22),
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(l10n.failedToLoadStats(err.toString())),
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StreakCard(streak: stats.streak, l10n: l10n),
                const SizedBox(height: 14),
                _StatGrid(stats: stats, l10n: l10n),
                const SizedBox(height: 18),
                _OverallProgress(stats: stats, l10n: l10n),
                if (stats.continueWatching case final cw?) ...[
                  const SizedBox(height: 24),
                  _ContinueWatchingCard(
                    data: cw,
                    l10n: l10n,
                    onResume: () => _openLecture(
                      context,
                      ref,
                      l10n,
                      cw.courseId,
                      cw.lectureId,
                    ),
                  ),
                ],
                if (stats.upNext case final next?) ...[
                  const SizedBox(height: 16),
                  _UpNextRow(
                    data: next,
                    l10n: l10n,
                    onTap: () => _openLecture(
                      context,
                      ref,
                      l10n,
                      next.courseId,
                      next.lectureId,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.name, required this.l10n});
  final String name;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0] : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: accent,
          child: Text(
            initial,
            style: TextStyle(
              color: onAccent,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.dashboardGreeting(name),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak, required this.l10n});
  final int streak;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.lgBr,
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppElevation.card(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: AppRadius.mdBr,
            ),
            child: Icon(Icons.local_fire_department, color: accent, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedDigits(context, streak),
                style: AppTextStyles.brand(context, size: 20),
              ),
              Text(
                l10n.streakDays,
                style: TextStyle(fontSize: 12, color: fg?.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats, required this.l10n});
  final DashboardStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCell(
            icon: Icons.menu_book_outlined,
            value: localizedDigits(context, stats.enrolled),
            label: l10n.enrolledCourses,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCell(
            icon: Icons.check_circle_outline,
            value: localizedDigits(context, stats.completed),
            label: l10n.completedCourses,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.lgBr,
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppElevation.card(isDark),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.brand(context, size: 19)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverallProgress extends StatelessWidget {
  const _OverallProgress({required this.stats, required this.l10n});
  final DashboardStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ratio = stats.enrolled == 0
        ? 0.0
        : (stats.completed / stats.enrolled).clamp(0, 1).toDouble();
    final fg = Theme.of(context).textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.overallProgress, style: const TextStyle(fontSize: 12)),
            Text(
              l10n.percentCompleteLabel(
                localizedDigits(context, (ratio * 100).round()),
              ),
              style: TextStyle(fontSize: 12, color: fg?.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppRadius.smBr,
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.neutral300,
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder-first thumbnail: shows the real course thumbnail when the API
/// provides one, otherwise (or on load failure) a Nocturne-styled accent
/// gradient with a lightened play glyph — matching the mockup's own
/// placeholder treatment rather than a broken-image icon.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.height, this.width});
  final String? url;
  final double height;
  final double? width;

  Widget _placeholder(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.35),
            accent.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          accent.withValues(alpha: 0.5),
          BlendMode.lighten,
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill, size: 32, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder(context);

    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder: (_, _) => _placeholder(context),
      errorWidget: (_, _, _) => _placeholder(context),
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  const _ContinueWatchingCard({
    required this.data,
    required this.l10n,
    required this.onResume,
  });

  final ContinueWatching data;
  final AppLocalizations l10n;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    final ratio = (data.progressPercentage / 100).clamp(0, 1).toDouble();
    final kicker = [
      data.subject,
      data.grade,
    ].where((s) => s != null && s.isNotEmpty).join(' · ');
    final subtitle = [
      if (data.teacherName != null) data.teacherName!,
      if (data.sectionPosition != null)
        l10n.sectionOf(
          localizedDigits(context, data.sectionPosition!),
          localizedDigits(context, data.totalSections),
        ),
    ].join(' · ');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.lgBr,
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppElevation.card(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(url: data.thumbnail, height: 120),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.continueWatchingTitle,
                  style: AppTextStyles.kicker(context),
                ),
                if (kicker.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    kicker,
                    style: TextStyle(
                      fontSize: 11,
                      color: fg?.withValues(alpha: 0.55),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  data.lectureTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: fg?.withValues(alpha: 0.55),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: AppRadius.smBr,
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: AppColors.neutral300,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.percentCompleteLabel(
                        localizedDigits(
                          context,
                          data.progressPercentage.round(),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: fg?.withValues(alpha: 0.6),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onResume,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                      ),
                      child: Text(l10n.continueLearning),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({
    required this.data,
    required this.l10n,
    required this.onTap,
  });
  final UpNextLecture data;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  String _duration(BuildContext context) {
    final seconds = data.videoDuration ?? 0;
    final minutes = seconds ~/ 60;
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '${localizedDigits(context, minutes)}:${localizedDigits(context, secs)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;

    return InkWell(
      borderRadius: AppRadius.lgBr,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.lgBr,
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: AppElevation.card(isDark),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.mdBr,
              child: const _Thumbnail(url: null, height: 48, width: 64),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.upNext,
                    style: TextStyle(
                      fontSize: 10,
                      color: fg?.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    data.lectureTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  if (data.videoDuration != null)
                    Text(
                      _duration(context),
                      style: TextStyle(
                        fontSize: 11,
                        color: fg?.withValues(alpha: 0.55),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.play_circle_fill, color: accent, size: 32),
          ],
        ),
      ),
    );
  }
}
