import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/socket_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import 'chat_message.dart';
import 'chat_service.dart';

enum DriverChatMode { ride, support }

class DriverRideChatScreen extends StatefulWidget {
  final DriverChatMode mode;
  final int? rideId;
  final String title;

  const DriverRideChatScreen({
    super.key,
    required this.mode,
    this.rideId,
    required this.title,
  });

  @override
  State<DriverRideChatScreen> createState() => _DriverRideChatScreenState();
}

class _DriverRideChatScreenState extends State<DriverRideChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == DriverChatMode.ride && widget.rideId != null) {
      DriverSocketService.instance.onChatMessage = _onIncoming;
    } else {
      DriverSocketService.instance.onSupportChatMessage = _onIncoming;
    }
    _load();
  }

  @override
  void dispose() {
    if (widget.mode == DriverChatMode.ride) {
      DriverSocketService.instance.onChatMessage = null;
    } else {
      DriverSocketService.instance.onSupportChatMessage = null;
    }
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onIncoming(Map<String, dynamic> data) {
    if (widget.mode == DriverChatMode.ride) {
      final rid = data['rideId'];
      if (rid != null && rid != widget.rideId) return;
    }
    final msg = ChatMessage.fromJson(data);
    if (_messages.any((m) => m.id == msg.id)) return;
    setState(() => _messages = [..._messages, msg]);
    _scrollToEnd();
  }

  int? get _myDriverId => context.read<AuthProvider>().driver?.id;

  bool _isMine(ChatMessage m) {
    final myId = _myDriverId ?? 0;
    if (widget.mode == DriverChatMode.support) {
      return m.senderRole == 'DRIVER' && m.senderId == myId;
    }
    return m.senderId == myId;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = widget.mode == DriverChatMode.ride
          ? await DriverChatService.instance.getRideMessages(widget.rideId!)
          : await DriverChatService.instance.getSupportMessages();
      if (!mounted) return;
      setState(() {
        _messages = list;
        _loading = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final msg = widget.mode == DriverChatMode.ride
          ? await DriverChatService.instance.sendRideMessage(
              widget.rideId!,
              text,
            )
          : await DriverChatService.instance.sendSupportMessage(text);
      _ctrl.clear();
      if (!mounted) return;
      if (!_messages.any((m) => m.id == msg.id)) {
        setState(() => _messages = [..._messages, msg]);
      }
      _scrollToEnd();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          t.chatEmpty,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final m = _messages[i];
                          final mine = _isMine(m);
                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.78,
                              ),
                              decoration: BoxDecoration(
                                color: mine
                                    ? Colors.black
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(mine ? 16 : 4),
                                  bottomRight: Radius.circular(mine ? 4 : 16),
                                ),
                              ),
                              child: Text(
                                m.body,
                                style: TextStyle(
                                  color: mine ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: t.chatTypeMessage,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
