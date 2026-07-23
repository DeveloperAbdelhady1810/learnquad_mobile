import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final locale = ref.watch(localeControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.failedToLoadProfile(err.toString()))),
        data: (user) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.neutral300,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : '؟',
                    style: AppTextStyles.brand(context, size: 24, color: fg),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      AppTag(
                        user.role == 'teacher' ? l10n.roleTeacher : l10n.roleStudent,
                        variant: AppTagVariant.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              l10n.accountSection,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 10),
            _InfoRow(label: l10n.nameLabel, value: user.name),
            _InfoRow(label: l10n.emailLabel, value: user.email),
            if (user.phone != null && user.phone!.isNotEmpty)
              _InfoRow(label: l10n.phoneLabel, value: user.phone!),
            const SizedBox(height: 28),
            Text(
              l10n.languageLabel,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 10),
            _LanguageSegment(
              value: locale.languageCode,
              onChanged: (code) => ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(Locale(code)),
            ),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: () => _confirmLogout(context, ref),
              child: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.5, color: fg?.withValues(alpha: 0.6)),
          ),
          Text(value, style: const TextStyle(fontSize: 13.5)),
        ],
      ),
    );
  }
}

/// Same visual language as the registration screen's stage segmented
/// control — switching flips locale (and therefore text direction) for the
/// whole app immediately.
class _LanguageSegment extends StatelessWidget {
  const _LanguageSegment({required this.value, required this.onChanged});
  final String value;
  final void Function(String code) onChanged;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    final l10n = AppLocalizations.of(context)!;
    final options = [
      ('ar', l10n.languageArabic),
      ('en', l10n.languageEnglish),
    ];

    return Container(
      decoration: BoxDecoration(border: Border.all(color: divider)),
      child: Row(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final (code, label) = entry.value;
          final selected = value == code;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(code),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? Theme.of(context).colorScheme.primary : null,
                  border: index == 0
                      ? Border(right: BorderSide(color: divider))
                      : null,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? Colors.white : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
