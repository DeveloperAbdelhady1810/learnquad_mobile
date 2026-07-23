import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../application/notification_providers.dart';
import '../data/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final fg = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationListProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: const Text('تعليم الكل كمقروء', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationListProvider.future),
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('تعذّر تحميل الإشعارات: $err')),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('لا توجد إشعارات بعد.')),
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
                        ? AppColors.accent.withValues(alpha: 0.06)
                        : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: n.isUnread
                                  ? AppColors.accent
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                                DateFormat('MMM d').format(n.createdAt),
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
