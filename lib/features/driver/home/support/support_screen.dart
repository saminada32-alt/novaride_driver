import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/support_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../chat/ride_chat_screen.dart';
import 'complaints_service.dart';
import 'faq_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _descCtrl = TextEditingController();

  String _type = 'passenger';
  bool _loading = false;
  bool _sent = false;

  List<(String, String, String)> _types(AppLocalizations local) => [
    ('passenger', '👤', local.complaintTypePassenger),
    ('technical', '⚙️', local.complaintTypeTechnical),
    ('billing', '💰', local.complaintTypeBilling),
    ('safety', '🚨', local.complaintTypeSafety),
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (_descCtrl.text.trim().isEmpty) return;

    try {
      setState(() => _loading = true);
      await DriverComplaintsService.instance.submit(
        type: _type,
        description: _descCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.complaintError)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openWhatsapp() async {
    final uri = Uri.parse('https://wa.me/${SupportConstants.whatsappDigits}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.complaintError)),
      );
    }
  }

  Future<void> _callUs() async {
    final uri = Uri.parse('tel:${SupportConstants.phoneE164}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.complaintError)),
      );
    }
  }

  void _openSupportChat() {
    final local = AppLocalizations.of(context)!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverRideChatScreen(
          mode: DriverChatMode.support,
          title: local.chatWithUs,
        ),
      ),
    );
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse(
      'mailto:${SupportConstants.email}?subject=NovaRide%20Driver%20Support',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.complaintError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    if (_sent) {
      return Scaffold(
        appBar: AppBar(title: Text(local.support), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  local.complaintSuccessTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  local.complaintSuccessBody,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    local.complaintOk,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: Text(local.support),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.asset(
                'assets/images/support_header.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              local.support,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              local.supportDesc,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            _supportTile(
              icon: Icons.chat_bubble_outline,
              title: local.chatWithUs,
              subtitle: local.chatWithUsDesc,
              onTap: _openSupportChat,
            ),
            const SizedBox(height: 16),
            _supportTile(
              icon: Icons.phone_outlined,
              title: local.callUs,
              subtitle: local.callUsDesc,
              onTap: _callUs,
            ),
            const SizedBox(height: 16),
            _supportTile(
              icon: Icons.email_outlined,
              title: local.emailUs,
              subtitle: local.emailUsDesc,
              onTap: _sendEmail,
            ),
            const SizedBox(height: 16),
            _supportTile(
              icon: Icons.chat,
              title: local.whatsappUs,
              subtitle: local.whatsappUsDesc,
              onTap: _openWhatsapp,
            ),
            const SizedBox(height: 16),
            _supportTile(
              icon: Icons.help_outline,
              title: local.faq,
              subtitle: local.faqDesc,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DriverFaqScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              local.reportIssue,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              local.complaintTypeTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ..._types(local).map(
              (type) => GestureDetector(
                onTap: () => setState(() => _type = type.$1),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _type == type.$1 ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(type.$2, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          type.$3,
                          style: TextStyle(
                            color: _type == type.$1
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_type == type.$1)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              local.complaintDescTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: TextField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: local.complaintDescHint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        local.complaintSubmit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              local.supportFooter,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green.shade700, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
