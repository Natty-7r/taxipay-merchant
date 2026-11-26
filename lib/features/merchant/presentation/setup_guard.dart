import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/merchant_models.dart';

/// One open setup step: what it is, why, and where to do it.
class SetupStep {
  const SetupStep({required this.icon, required this.title, required this.hint, required this.route, this.color});

  final IconData icon;
  final String title;
  final String hint;
  final String route;
  final Color? color;
}

/// The owner's open setup steps, in order: business → approval → payout account.
List<SetupStep> setupSteps(BuildContext context, AppContext c) {
  final l10n = context.l10n;
  return [
    if (!c.businessSetUp)
      SetupStep(icon: AppIcons.storefront, title: l10n.setupBusiness, hint: l10n.setupBusinessHint, route: '/setup/business')
    else if (c.status == MerchantStatus.rejected)
      SetupStep(icon: AppIcons.cancel, title: l10n.statusRejected, hint: c.statusReason ?? l10n.applicationRejectedHint,
          route: '/status', color: AppTheme.error)
    else if (!c.approved)
      SetupStep(icon: AppIcons.hourglassTopRounded, title: l10n.awaitingApproval, hint: l10n.awaitingApprovalHint,
          route: '/status', color: AppTheme.warning),
    if (!c.payoutAccount)
      SetupStep(icon: AppIcons.accountBalanceWalletOutlined, title: l10n.addPayout, hint: l10n.addPayoutHint,
          route: '/setup/payout'),
  ];
}

/// Home-screen reminders for whatever is left to set up. Empty once everything is done.
class SetupReminders extends ConsumerWidget {
  const SetupReminders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    if (session == null || session.isDriver) return const SizedBox.shrink();
    final steps = setupSteps(context, session.context);
    if (steps.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l10n.finishSetup, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 2),
        Text(l10n.finishSetupHint, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 10),
        for (final s in steps) ...[
          _StepCard(step: s),
          const SizedBox(height: 10),
        ],
      ]),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});

  final SetupStep step;

  @override
  Widget build(BuildContext context) {
    final color = step.color ?? AppTheme.blue;
    return SoftCard(
      onTap: () => context.push(step.route),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(step.icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(step.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(step.hint, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12.5)),
          ]),
        ),
        const Icon(AppIcons.chevronRight),
      ]),
    );
  }
}

/// Before an owner adds taxis or routes ([needsApproval]) or drivers, or starts operating ([forOperating]):
/// if a setup step is missing, explains it in a sheet with a button to fix it, and returns false.
/// Drivers can't fix setup, so for them the API's own message is shown instead.
Future<bool> ensureSetup(BuildContext context, WidgetRef ref, {bool needsApproval = true, bool forOperating = false}) async {
  final session = ref.read(sessionProvider).value;
  if (session == null || session.isDriver) return true;
  final c = session.context;
  final missing = setupSteps(context, c).where((s) {
    if (s.route == '/setup/business') return true;
    if (s.route == '/status') return needsApproval || forOperating;
    return forOperating; // payout
  }).firstOrNull;
  if (missing == null) return true;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Icon(missing.icon, size: 40, color: missing.color ?? AppTheme.blue),
          const SizedBox(height: 12),
          Text(missing.title, textAlign: TextAlign.center, style: Theme.of(sheet).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(missing.hint, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.pop(sheet);
              context.push(missing.route);
            },
            child: Text(missing.title),
          ),
          TextButton(onPressed: () => Navigator.pop(sheet), child: Text(sheet.l10n.later)),
        ]),
      ),
    ),
  );
  return false;
}
