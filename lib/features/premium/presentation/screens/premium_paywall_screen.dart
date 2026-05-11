import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final pkg in packages) ...[
                            FilledButton.tonal(
                              onPressed: _busy ? null : () => _purchase(pkg),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                                alignment: Alignment.centerLeft,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _packageTitle(pkg, l10n),
                                    style: theme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pkg.storeProduct.priceString,
                                    style: theme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
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
