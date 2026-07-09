import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../account/provider/account_provider.dart';
import '../../incentives/incentives_screen.dart';
import '../../notifications/notifications_screen.dart';
import '../../preferences/driver_preferences_screen.dart';
import '../../referrals/referral_screen.dart';
import '../../subscription/my_subscription_screen.dart';
import '../../scheduled/scheduled_rides_screen.dart';
import '../../wallet/wallet_screen.dart';
import '../../work_zones/work_zones_screen.dart';
import '../../account/language/language_screen.dart';
import '../support/support_screen.dart';
import '../vehicle/vehicle_info_screen.dart';
import 'driver_menu_item.dart';

class DriverDrawer extends StatelessWidget {
  final void Function(int tabIndex) onSelectTab;
  final VoidCallback onLogout;

  const DriverDrawer({
    super.key,
    required this.onSelectTab,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final prov = context.watch<AccountProvider>();
    final driver = prov.account;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      child: Stack(
        children: [
          Container(color: Colors.white),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.white.withValues(alpha: 0.05)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        onSelectTab(3);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              child: ProfileAvatar(
                                imageUrl: driver?.profileImage,
                                localPreviewPath: prov.localProfilePreview,
                                onNetworkImageLoaded: prov.clearLocalProfilePreview,
                                name: driver?.name ?? t.driverLabel,
                                radius: 30,
                                backgroundColor: Colors.grey.shade100,
                                initialColor: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver?.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    driver?.phone ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _section([
                      DriverMenuItem(
                        icon: Icons.notifications_outlined,
                        title: t.notificationsTitle,
                        onTap: () => _push(
                          context,
                          const DriverNotificationsScreen(),
                        ),
                      ),
                      DriverMenuItem(
                        icon: Icons.event_note_rounded,
                        title: t.scheduledRidesTitle,
                        onTap: () => _push(
                          context,
                          const DriverScheduledRidesScreen(),
                        ),
                      ),
                      DriverMenuItem(
                        icon: Icons.history,
                        title: t.trips,
                        onTap: () {
                          onSelectTab(1);
                          Navigator.pop(context);
                        },
                      ),
                      DriverMenuItem(
                        icon: Icons.monetization_on,
                        title: t.earnings,
                        onTap: () {
                          onSelectTab(2);
                          Navigator.pop(context);
                        },
                      ),
                      DriverMenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: t.walletTitle,
                        onTap: () => _push(context, const DriverWalletScreen()),
                      ),
                    ]),
                    _section([
                      DriverMenuItem(
                        icon: Icons.map_outlined,
                        title: t.workZonesTitle,
                        onTap: () => _push(context, const WorkZonesScreen()),
                      ),
                      DriverMenuItem(
                        icon: Icons.tune_rounded,
                        title: t.preferences,
                        onTap: () => _push(
                          context,
                          const DriverPreferencesScreen(),
                        ),
                      ),
                      DriverMenuItem(
                        icon: Icons.card_giftcard_outlined,
                        title: t.driverIncentivesTitle,
                        onTap: () => _push(
                          context,
                          const DriverIncentivesScreen(),
                        ),
                      ),
                      DriverMenuItem(
                        icon: Icons.people_outline,
                        title: t.referrals,
                        onTap: () => _push(
                          context,
                          const DriverReferralScreen(),
                        ),
                      ),
                    ]),
                    _section([
                      DriverMenuItem(
                        icon: Icons.directions_car_outlined,
                        title: t.vehicleInfo,
                        onTap: () => _push(
                          context,
                          const VehicleInfoScreen(),
                        ),
                      ),
                      DriverMenuItem(
                        icon: Icons.subscriptions_outlined,
                        title: t.subscriptions,
                        onTap: () => _push(
                          context,
                          const MySubscriptionScreen(),
                        ),
                      ),
                      DriverMenuItem(
                        icon: Icons.person_outline,
                        title: t.account,
                        onTap: () {
                          onSelectTab(3);
                          Navigator.pop(context);
                        },
                      ),
                      DriverMenuItem(
                        icon: Icons.language_outlined,
                        title: t.language,
                        onTap: () => _push(context, const LanguageScreen()),
                      ),
                      DriverMenuItem(
                        icon: Icons.support_agent_outlined,
                        title: t.support,
                        onTap: () => _push(context, const SupportScreen()),
                      ),
                    ]),
                    DriverMenuItem(
                      icon: Icons.logout,
                      title: t.logout,
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        onLogout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(List<Widget> items) =>
      Column(children: [...items, const Divider(height: 24)]);

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
