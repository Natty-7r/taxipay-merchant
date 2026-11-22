import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import 'ui.dart';

import '../../l10n/app_localizations.dart';
import '../network/api_exception.dart';
import '../utils/formatters.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Shows a failed action as a floating error card.
void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: AppErrorCard(error: error),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 6),
    ));
}

/// [ErrorCard] for any error: picks the title and icon from the kind of failure.
class AppErrorCard extends StatelessWidget {
  const AppErrorCard({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final api = error is ApiException ? error as ApiException : null;
    final status = api?.status ?? 0;
    final (title, icon) = switch (api) {
      _ when api?.code == 'NETWORK' => (l10n.errorNetworkTitle, AppIcons.wifiOff),
      _ when api?.code == 'TIMEOUT' => (l10n.errorTimeoutTitle, AppIcons.hourglassTop),
      _ when status == 403 => (l10n.errorDeniedTitle, AppIcons.shieldAlert),
      _ when status == 404 => (l10n.errorNotFoundTitle, AppIcons.errorOutline),
      _ when status >= 500 => (l10n.errorServerTitle, AppIcons.serverCrash),
      _ => (l10n.errorGenericTitle, AppIcons.errorOutline),
    };
    return ErrorCard(
      title: title,
      message: api?.userMessage ?? '$error',
      reference: api?.traceId == null ? null : l10n.errorReference(api!.traceId!),
      icon: icon,
      onRetry: onRetry,
      retryLabel: l10n.retry,
    );
  }
}

void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

/// Runs an action, showing errors; returns true on success.
Future<bool> runAction(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } catch (e) {
    if (context.mounted) showError(context, e);
    return false;
  }
}

/// Loading / error / data for an [AsyncValue], with pull-to-refresh.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.onRefresh, required this.builder});

  final AsyncValue<T> value;
  final Future<void> Function() onRefresh;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData(:final value) => RefreshIndicator(onRefresh: onRefresh, child: builder(value)),
      AsyncError(:final error) => ErrorView(error: error, onRetry: onRefresh),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// A full-screen error state: the error card, still pull-to-refreshable.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRetry,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), children: [
          AppErrorCard(error: error, onRetry: onRetry),
        ]),
      );
}

/// A scrollable empty state (so pull-to-refresh still works).
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.message, this.icon = AppIcons.inboxOutlined});

  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ListView(children: [
        const SizedBox(height: 120),
        Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 12),
        Text(message ?? context.l10n.empty, textAlign: TextAlign.center),
      ]);
}

/// Coloured chip for API statuses (PENDING, APPROVED, SUCCESSFUL…).
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      'APPROVED' || 'SUCCESSFUL' || 'ACTIVE' || 'COMPLETED' => AppTheme.success,
      'PENDING' || 'PROPOSED' || 'NOT_STARTED' || 'INITIATED' || 'IN_PROGRESS' => const Color(0xFFB45309),
      'REJECTED' || 'FAILED' || 'SUSPENDED' || 'CANCELLED' || 'EXPIRED' => scheme.error,
      _ => scheme.outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(humanize(status), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppTheme.lightYellow, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: AppTheme.navy),
            ),
          const SizedBox(height: 6),
          Text(value, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: text.bodySmall),
        ]),
      ),
    );
  }
}

String? requiredValidator(BuildContext context, String? v) =>
    v == null || v.trim().isEmpty ? context.l10n.required : null;
