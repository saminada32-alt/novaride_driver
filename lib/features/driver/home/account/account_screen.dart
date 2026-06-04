import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../auth/providers/auth_provider.dart';
import 'provider/account_provider.dart';
import 'edit_account_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) context.read<AccountProvider>().loadAccount(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final prov = context.watch<AccountProvider>();

    if (prov.isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    final user = prov.account;
    if (user == null) return Center(child: Text(t.noData ?? 'No data'));

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: () async {
        final token = context.read<AuthProvider>().token;
        if (token != null) prov.loadAccount(token);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff1DBF73), Color(0xff17A964)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final token = context.read<AuthProvider>().token;
                    if (token != null) prov.pickProfileImage(token);
                  },
                  child: Stack(
                    children: [
                      ProfileAvatar(
                        imageUrl: user.profileImage,
                        name: user.name,
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(.3),
                        initialColor: Colors.white,
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black45,
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(5, (i) {
                      final r = user.rating;
                      if (i < r.floor())
                        return const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        );
                      if (i < r)
                        return const Icon(
                          Icons.star_half,
                          color: Colors.amber,
                          size: 20,
                        );
                      return const Icon(
                        Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      user.rating.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isVerified
                        ? (t.verifiedDriver ?? 'Verified')
                        : (t.pending ?? 'Pending'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              _stat(t.trips, user.totalTrips.toString(), Icons.directions_car),
              const SizedBox(width: 12),
              _stat(t.rating, user.rating.toStringAsFixed(2), Icons.star),
            ],
          ),

          const SizedBox(height: 16),

          // Analytics
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.driverPerformance ?? 'Performance',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14),
                _row(
                  t.acceptanceRate ?? 'Acceptance Rate',
                  '${user.acceptanceRate.toStringAsFixed(1)}%',
                ),
                _row(
                  t.cancellationRate ?? 'Cancellation Rate',
                  '${user.cancelRate.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _info(Icons.phone, user.phone),
          _info(Icons.email, user.email.isNotEmpty ? user.email : 'Not set'),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditAccountScreen()),
            ),
            icon: const Icon(Icons.edit),
            label: Text(t.editProfile),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => prov.logout(context),
            icon: const Icon(Icons.logout),
            label: Text(t.logout ?? 'Logout'),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _stat(String t, String v, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 8),
          Text(t),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );

  Widget _row(String t, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(t),
        Text(
          v,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    ),
  );

  Widget _info(IconData icon, String v) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 16),
        Expanded(child: Text(v)),
      ],
    ),
  );
}
