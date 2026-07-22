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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationListProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationListProvider.future),
        child: notificationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) =>
              Center(child: Text('Failed to load notifications: $err')),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No notifications yet.')),
                ],
              );
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  tileColor: n.isUnread
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : null,
                  leading: Icon(
                    n.isUnread ? Icons.circle : Icons.circle_outlined,
                    size: 10,
                    color: n.isUnread ? AppColors.primary : Colors.transparent,
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(n.body),
                  trailing: Text(
                    DateFormat('MMM d').format(n.createdAt),
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () async {
                    if (n.isUnread) {
                      await ref
                          .read(notificationRepositoryProvider)
                          .markRead(n.id);
                      ref.invalidate(notificationListProvider);
                      ref.invalidate(unreadCountProvider);
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
