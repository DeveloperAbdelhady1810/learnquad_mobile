import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/color_utils.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/notification_providers.dart';
import '../data/notification_repository.dart';

/// Matches the real notification `type` values created by
/// `App\Models\Notification::createFor()` (see PaymobController,
/// StudentCourseController, LectureController on the Laravel side) —
/// anything else falls back to a generic bell.
IconData _iconFor(String type) {
  switch (type) {
    case 'course_enrolled':
      return Icons.school_outlined;
    case 'payment_received':
      return Icons.payments_outlined;
    case 'new_lecture':
      return Icons.play_circle_outline;
    default:
      return Icons.notifications_outlined;
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationListProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: Text(l10n.markAllRead, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationListProvider.future),
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) =>
              Center(child: Text(l10n.failedToLoadNotifications(err.toString()))),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(l10n.noNotificationsYet)),
                ],
              );
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return InkWell(
                  onTap: () async {
                    if (n.isUnread) {
                      await ref
                          .read(notificationRepositoryProvider)
                          .markRead(n.id);
                      ref.invalidate(notificationListProvider);
                      ref.invalidate(unreadCountProvider);
                    }
                  },
                  child: Container(
                    color: n.isUnread
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
                        : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: n.isUnread
                              ? shadeColor(
                                  Theme.of(context).colorScheme.primary,
                                  0.55,
                                )
                              : Theme.of(context).colorScheme.surface,
                          child: Icon(
                            _iconFor(n.type),
                            size: 17,
                            color: n.isUnread
                                ? tintColor(
                                    Theme.of(context).colorScheme.primary,
                                    0.90,
                                  )
                                : fg?.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: n.isUnread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                n.body,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: fg?.withValues(alpha: 0.65),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                DateFormat('MMM d', locale).format(n.createdAt),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: fg?.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
