import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

/// LTR OTP entry with iOS/Android SMS autofill (sms_autofill + oneTimeCode).
class OtpCodeInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool enabled;

  const OtpCodeInput({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.enabled = true,
  });

  @override
  State<OtpCodeInput> createState() => OtpCodeInputState();
}

class OtpCodeInputState extends State<OtpCodeInput> with CodeAutoFill {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  StreamSubscription<String>? _smsSub;
  late final DateTime _listenAfter;
  bool _programmatic = false;

  String get otpValue => _ctrl.text;

  void clear() {
    _ctrl.clear();
    widget.onChanged('');
    _focus.requestFocus();
  }

  /// Call after resend so stale inbox codes are ignored until SMS arrives.
  Future<void> restartListening() async {
    _listenAfter = DateTime.now().add(const Duration(seconds: 2));
    await _startSmsListen();
  }

  void setCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 6) return;
    _programmatic = true;
    _ctrl.text = digits;
    _ctrl.selection = TextSelection.collapsed(offset: digits.length);
    _programmatic = false;
    _emitChange(digits);
  }

  void _emitChange(String digits) {
    widget.onChanged(digits);
    if (digits.length == 6 && DateTime.now().isAfter(_listenAfter)) {
      widget.onCompleted?.call(digits);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _listenAfter = DateTime.now().add(const Duration(seconds: 2));
    _ctrl.addListener(_onTextChanged);
    unawaited(_startSmsListen());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enabled) _focus.requestFocus();
    });
  }

  Future<void> _startSmsListen() async {
    try {
      await SmsAutoFill().unregisterListener();
      _smsSub?.cancel();
      listenForCode();
      _smsSub = SmsAutoFill().code.listen((code) {
        if (!mounted || code.length != 6) return;
        if (DateTime.now().isBefore(_listenAfter)) return;
        setCode(code);
      });
    } catch (_) {
      /* SMS retriever optional — keyboard autofill still works */
    }
  }

  void _onTextChanged() {
    if (_programmatic) return;
    final digits = _ctrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits != _ctrl.text) {
      _programmatic = true;
      _ctrl.text = digits;
      _ctrl.selection = TextSelection.collapsed(offset: digits.length);
      _programmatic = false;
      return;
    }
    _emitChange(digits);
  }

  @override
  void codeUpdated() {
    final received = code;
    if (received != null &&
        received.length == 6 &&
        DateTime.now().isAfter(_listenAfter)) {
      setCode(received);
    }
  }

  @override
  void dispose() {
    _smsSub?.cancel();
    cancel();
    _ctrl.removeListener(_onTextChanged);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final digits = _ctrl.text.padRight(6).split('');

    return AutofillGroup(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final filled = i < _ctrl.text.length;
                final active = _focus.hasFocus && i == _ctrl.text.length;
                return Container(
                  width: 48,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.hasError
                        ? Colors.red.shade100
                        : filled
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active
                          ? Colors.green
                          : widget.hasError
                          ? Colors.red.shade300
                          : Colors.grey.shade200,
                      width: active ? 2 : 1.5,
                    ),
                  ),
                  child: Text(
                    filled ? digits[i] : '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                );
              }),
            ),
            // Full-size transparent field — better tap/focus on Samsung Android.
            Positioned.fill(
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: 6,
                style: const TextStyle(color: Colors.transparent, fontSize: 1),
                cursorColor: Colors.transparent,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
