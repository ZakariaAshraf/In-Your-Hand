import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:in_your_hand/core/utils/screen_util.dart';
import '../../../../core/generated/extentions.dart';
import '../../../../core/locale/widgets/language_toggle_button.dart';
import '../../../../core/themes/widgets/theme_toggle_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/business_logo_display.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/printer/thermal_printer_service.dart';
import '../../../../core/services/printer/repos/printer_repository_prefs.dart';
import '../../../authenticate/presentation/manager/auth_cubit.dart';
import '../../../authenticate/presentation/pages/sign_in.dart';
import '../../../premium/presentation/screens/premium_paywall_screen.dart';
import '../../../help_support/help_support_screen.dart';
import '../../../business_profile/domain/entities/business_profile.dart';
import '../Cubit/user_cubit.dart';
import '../components/settings_button.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class SettingScreen extends StatefulWidget {
  final BusinessProfile profile;
  final bool isGuest;

  const SettingScreen({
    super.key,
    required this.profile,
    required this.isGuest,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final ThermalPrinterService _printerService = ThermalPrinterService();
  final PrinterRepositoryPrefs _printerPrefs = const PrinterRepositoryPrefs();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignIn()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n!.settings, style: theme.titleLarge),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                /// photo and information section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xffe8d4d4),
                            radius: 60,
                            child: ClipOval(
                              child: buildBusinessLogoDisplay(
                                logoLocalPath: widget.profile.logoLocalPath,
                                size: 120,
                                fallback: Center(
                                  child: Text(
                                    (widget.profile.businessName.isNotEmpty
                                            ? widget.profile.businessName
                                            : '—')
                                        .trim()
                                        .characters
                                        .take(1)
                                        .toString(),
                                    style: theme.titleLarge!.copyWith(color: Colors.green),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   bottom: 0,
                          //   right: 0,
                          //   child: InkWell(
                          //     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeCharacterScreen(),)),
                          //
                          //     child: Container(
                          //       // height: 40,
                          //       // width: 64.w(context),
                          //       padding: EdgeInsets.all(7),
                          //       decoration: BoxDecoration(
                          //         border: BoxBorder.all(color: Colors.white),
                          //         shape: BoxShape.circle,
                          //         color: Colors.blueAccent,
                          //       ),
                          //       child: Row(
                          //         children: [
                          //           Icon(
                          //             Icons.edit,
                          //             color: Colors.white,
                          //             size: 18,
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.profile.businessName.trim().isNotEmpty
                            ? widget.profile.businessName.trim()
                            : l10n.settingsBusinessFallbackTitle,
                        textAlign: TextAlign.center,
                        style: theme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.profile.businessName.trim().isEmpty &&
                          widget.isGuest) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.guestModeHint,
                          textAlign: TextAlign.center,
                          style: theme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                      if ((widget.profile.phone ?? '')
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          widget.profile.phone!.trim(),
                          textAlign: TextAlign.center,
                          style: theme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.map_pin,
                            color: Colors.red,
                            size: 20,
                          ),
                          Text(
                            l10n.egypt,
                            style: theme.bodyMedium!.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        title: l10n.editProfile,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        isInvert: false,
                        color: Colors.white,
                        width: 180.w(context),
                        textStyle: theme.titleMedium!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        circularRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.preferences,
                  style: theme.titleMedium!.copyWith(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ThemeToggleButton().animate().fade().slideX(duration: 200.ms),
                      LanguageToggleButton().animate().fade().slideX(duration: 300.ms),
                    ],
                  ),
                ),
                Text(
                  l10n.supportAndAccount,
                  style: theme.titleMedium!.copyWith(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SettingsButton(
                        title: l10n.recommendFeature,
                        function: () async {
                          await launchUrls("https://forms.gle/G3V7PwjhPdm6MBtU6");
                        },
                        iconData: Icons.lightbulb_outlined,
                        iconColor: Colors.yellow,
                      ).animate().fade().slideX(duration: 400.ms),
                      SettingsButton(
                        title: l10n.helpAndSupport,
                        function: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                          },
                        iconData: Icons.question_mark_rounded,
                        iconColor: Colors.indigo,
                      ).animate().fade().slideX(duration: 500.ms),
                      SettingsButton(
                        title: l10n.changePassword,
                        function: widget.isGuest
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChangePasswordScreen(),
                            ),
                          );
                        },
                        iconData: Icons.lock_open_outlined,
                      ).animate().fade().slideX(duration: 600.ms),
                      SettingsButton(
                        title: l10n.printerSettings,
                        function: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final devices =
                                await _printerService.getPairedDevices();
                            if (!context.mounted) return;
                            if (devices.isEmpty) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10n.printerNoPairedDevices),
                                ),
                              );
                              return;
                            }

                            await showModalBottomSheet<void>(
                              context: context,
                              showDragHandle: true,
                              builder: (sheetContext) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.printerSelectPairedDevice,
                                              style: theme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              l10n.printerSettingsSubtitle,
                                              style: theme.bodySmall?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: devices.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(height: 1),
                                          itemBuilder: (_, index) {
                                            final d = devices[index];
                                            final name = d.name.trim();
                                            final addr = d.macAddress.trim();
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.print_outlined,
                                              ),
                                              title: Text(name),
                                              subtitle: addr.isEmpty
                                                  ? null
                                                  : Text(addr),
                                              onTap: () async {
                                                Navigator.of(sheetContext)
                                                    .pop();
                                                try {
                                                  await _printerService
                                                      .connect(addr);
                                                  await _printerPrefs
                                                      .saveSelectedMacAddress(
                                                          addr);
                                                  if (!context.mounted) return;
                                                  messenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        l10n.printerConnected(
                                                          name,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  if (!context.mounted) return;
                                                  final msg = e
                                                          .toString()
                                                          .contains(
                                                              'Bluetooth permissions are required')
                                                      ? l10n
                                                          .bluetoothPermissionsRequired
                                                      : l10n
                                                          .printerConnectFailed(
                                                        e.toString(),
                                                      );
                                                  messenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text(msg),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .error,
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              },
                            );
                          } catch (e) {
                            final msg = e
                                    .toString()
                                    .contains('Bluetooth permissions are required')
                                ? l10n.bluetoothPermissionsRequired
                                : l10n.printerConnectFailed('$e');
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                        iconData: Icons.print_outlined,
                        iconColor: Colors.deepPurple,
                      ).animate().fade().slideX(duration: 650.ms),
                      SettingsButton(
                        title: widget.isGuest
                            ? l10n.settingsPremiumBackupSubtitle
                            : l10n.logout,
                        function: () async {
                          try {
                            if (widget.isGuest) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PremiumPaywallScreen(),
                                ),
                              );
                            } else {
                              context.read<AuthCubit>().signOut();
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const SignIn()),
                                  (route) => false,
                                );
                              }
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print(e.toString());
                            }
                          }
                        },
                        iconData: Icons.logout,
                        iconColor: Colors.red,
                      ).animate().fade().slideX(duration: 700.ms),
                      SettingsButton(
                        title: l10n.deleteLocalData,
                        function: () async {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              final dialogL10n = AppLocalizations.of(
                                dialogContext,
                              )!;
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
                                child: AlertDialog(
                                  title: Text(dialogL10n.deleteOrder,style: theme.titleLarge!.copyWith(color: Colors.red),),
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    child: Text(dialogL10n.deleteLocalDataConfirm),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: Text(
                                        dialogL10n.cancel,
                                        style: theme.titleMedium,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await context.read<UserCubit>().deleteLocalData();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          Colors.red,
                                        ),
                                      ),
                                      child: Text(
                                        dialogL10n.delete,
                                        style: theme.titleMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        iconData: Icons.delete_forever,
                        iconColor: Colors.redAccent,
                      ).animate().fade().slideX(duration: 800.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
