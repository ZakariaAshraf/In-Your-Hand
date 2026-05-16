import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/premium/premium_ad_refresh_notifier.dart';
import 'package:in_your_hand/core/premium/premium_service.dart';
import 'package:in_your_hand/core/premium/revenuecat_service.dart';
import 'package:in_your_hand/core/session/session_cubit.dart';
import 'package:in_your_hand/features/authenticate/presentation/pages/sign_in.dart';
import 'package:in_your_hand/l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Premium paywall backed by RevenueCat offerings and purchases.
class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  late Future<Offerings?> _offeringsFuture;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _offeringsFuture = RevenueCatService.instance.fetchOfferings();
  }

  void _reloadOfferings() {
    setState(() {
      _offeringsFuture = RevenueCatService.instance.fetchOfferings();
    });
  }

  String _packageTitle(Package package, AppLocalizations l10n) {
    switch (package.packageType) {
      case PackageType.monthly:
        return l10n.premiumPackageMonthly;
      case PackageType.annual:
        return l10n.premiumPackageAnnual;
      case PackageType.weekly:
        return l10n.premiumPackageWeekly;
      case PackageType.lifetime:
        return l10n.premiumPackageLifetime;
      default:
        return package.storeProduct.title;
    }
  }

  String _billingCycleSubtitle(Package package, AppLocalizations l10n) {
    switch (package.packageType) {
      case PackageType.monthly:
        return l10n.premiumBillingMonthly;
      case PackageType.annual:
        return l10n.premiumBillingAnnual;
      case PackageType.weekly:
        return l10n.premiumBillingWeekly;
      case PackageType.lifetime:
        return l10n.premiumBillingLifetime;
      default:
        return l10n.premiumBillingDefault;
    }
  }

  List<Package> _sortedPackages(List<Package> packages) {
    int rank(Package p) {
      switch (p.packageType) {
        case PackageType.annual:
          return 0;
        case PackageType.monthly:
          return 1;
        case PackageType.weekly:
          return 2;
        case PackageType.lifetime:
          return 3;
        default:
          return 4;
      }
    }

    final copy = List<Package>.from(packages);
    copy.sort((a, b) => rank(a).compareTo(rank(b)));
    return copy;
  }

  Widget _buildPackageCard({
    required Package pkg,
    required AppLocalizations l10n,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    final isAnnual = pkg.packageType == PackageType.annual;
    final borderColor =
        isAnnual ? colorScheme.primary : colorScheme.outlineVariant;
    final borderWidth = isAnnual ? 2.5 : 1.0;
    final onPrimary = colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: _busy ? 0.48 : 1.0,
        child: Material(
          color: isAnnual
              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _busy ? null : () => _purchase(pkg),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: isAnnual
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.22),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _packageTitle(pkg, l10n),
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (isAnnual) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.premiumAnnualSaveBadge,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            pkg.storeProduct.priceString,
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _billingCycleSubtitle(pkg, l10n),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isAnnual ? Icons.star_rounded : Icons.arrow_forward_ios_rounded,
                      size: isAnnual ? 28 : 18,
                      color: isAnnual
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _purchase(Package package) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context, rootNavigator: true);
    final sessionCubit = context.read<SessionCubit>();
    final premiumService = context.read<PremiumService>();
    final guest = sessionCubit.contextOrNull?.isGuest ?? false;

    setState(() => _busy = true);
    try {
      final active = await RevenueCatService.instance.purchasePackage(package);
      if (!mounted) return;

      if (!active) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.premiumPurchaseError)),
        );
        return;
      }

      await premiumService.isPremium();
      PremiumAdRefreshNotifier.instance.notifyPremiumMayHaveChanged();

      if (!mounted) return;
      if (nav.canPop()) {
        nav.pop();
      }

      messenger.showSnackBar(
        SnackBar(content: Text(l10n.premiumPurchaseSuccess)),
      );

      if (guest) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.premiumSignInForSyncHint),
            action: SnackBarAction(
              label: l10n.login,
              onPressed: () {
                nav.push(
                  MaterialPageRoute<void>(builder: (_) => const SignIn()),
                );
              },
            ),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (RevenueCatService.isUserCancelledPurchase(e)) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.premiumPurchaseCancelled)),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.premiumPurchaseError} (${RevenueCatService.purchaseErrorMessage(e)})',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.premiumPurchaseError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context, rootNavigator: true);
    final sessionCubit = context.read<SessionCubit>();
    final premiumService = context.read<PremiumService>();
    final guest = sessionCubit.contextOrNull?.isGuest ?? false;

    setState(() => _busy = true);
    try {
      final info = await RevenueCatService.instance.restorePurchases();
      if (!mounted) return;

      if (info == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.premiumOfferingsUnavailable)),
        );
        return;
      }

      final active =
          info.entitlements.all[RevenueCatService.entitlementPremiumId]?.isActive ==
              true;

      if (active) {
        await premiumService.isPremium();
        PremiumAdRefreshNotifier.instance.notifyPremiumMayHaveChanged();
        if (!mounted) return;
        if (nav.canPop()) {
          nav.pop();
        }
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.premiumRestoreSuccess)),
        );
        if (guest) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.premiumSignInForSyncHint),
              action: SnackBarAction(
                label: l10n.login,
                onPressed: () {
                  nav.push(
                    MaterialPageRoute<void>(builder: (_) => const SignIn()),
                  );
                },
              ),
            ),
          );
        }
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.premiumRestoreNoEntitlement)),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.premiumPurchaseError} (${RevenueCatService.purchaseErrorMessage(e)})',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.premiumOfferingsUnavailable)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget benefit(String text, IconData icon) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: theme.bodyLarge?.copyWith(height: 1.35),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.premiumPaywallTitle),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    l10n.premiumPaywallHeadline,
                    textAlign: TextAlign.center,
                    style: theme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.premiumPaywallDescription,
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          benefit(
                            l10n.premiumBenefitCloudSync,
                            Icons.cloud_done_outlined,
                          ),
                          benefit(
                            l10n.premiumBenefitNoAds,
                            Icons.notifications_off_outlined,
                          ),
                          benefit(
                            l10n.premiumBenefitAiVoice,
                            Icons.mic_none_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<Offerings?>(
                    future: _offeringsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final offerings = snapshot.data;
                      final packages = offerings?.current?.availablePackages ?? [];

                      if (packages.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.premiumOfferingsUnavailable,
                              textAlign: TextAlign.center,
                              style: theme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _busy ? null : _reloadOfferings,
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.tryAgain),
                            ),
                          ],
                        );
                      }

                      final ordered = _sortedPackages(packages);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final pkg in ordered)
                            _buildPackageCard(
                              pkg: pkg,
                              l10n: l10n,
                              textTheme: theme,
                              colorScheme: colorScheme,
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy ? null : _restore,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      l10n.premiumRestorePlaceholder,
                      style: theme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SignIn(),
                              ),
                            );
                          },
                    child: Text(
                      l10n.premiumAlreadySubscribedLogin,
                      style: theme.titleMedium!.copyWith(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_busy)
            const ModalBarrier(dismissible: false, color: Color(0x66000000)),
          if (_busy)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
