import 'package:flutter/material.dart';
import '../../../core/services/notification_inbox_service.dart';
import '../../../core/widgets/empty_illustration.dart';
import '../../../l10n/app_localizations.dart';
import '../onboarding/documents/documents_screen.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() =>
      _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await NotificationInboxService.instance.loadFromApi();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openNotification(AppNotificationItem n) async {
    await NotificationInboxService.instance.markRead(n.id);
    if (mounted) setState(() {});
    if (!mounted) return;

    switch (n.type) {
      case 'DOCUMENT_RESUBMIT':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DocumentsScreen(resubmitOnly: true),
          ),
        );
        break;
      case 'NEW_RIDE':
      case 'RIDE_CANCELLED':
        // Both refer to a ride offer/trip that's already resolved by the
        // time it's read from history — the Trips tab (not a standalone
        // route) is where the driver can look it up, so just get them back
        // to the home screen rather than pushing a broken bare tab widget.
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = NotificationInboxService.instance.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notificationsTitle),
        centerTitle: true,
        actions: [
          if (items.any((n) => !n.read))
            TextButton(
              onPressed: () async {
                await NotificationInboxService.instance.markAllRead();
                if (mounted) setState(() {});
              },
              child: Text(t.markAllRead),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? EmptyIllustration(
              imageAsset: 'assets/images/Push notifications-bro.png',
              message: t.notificationsEmpty,
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final n = items[i];
                  return ListTile(
                    tileColor: n.read
                        ? Colors.grey.shade100
                        : Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.read ? FontWeight.w500 : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(n.body),
                    onTap: () => _openNotification(n),
                  );
                },
              ),
            ),
    );
  }
}
