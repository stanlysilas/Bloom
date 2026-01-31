import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bloom_pin_service.dart';

enum PinMode { set, verify }

class PasswordEntryScreen extends StatefulWidget {
  final PinMode mode;
  final String? message;

  const PasswordEntryScreen({
    super.key,
    required this.mode,
    this.message,
  });

  @override
  State<PasswordEntryScreen> createState() => _PasswordEntryScreenState();
}

class _PasswordEntryScreenState extends State<PasswordEntryScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  final _pinService = BloomPinService();
  bool _isProcessing = false;
  bool? ok;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes.first.requestFocus(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  Future<void> _onCompleted() async {
    if (_pin.length != 4 || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (widget.mode == PinMode.set) {
        await _pinService.setPin(_pin);
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        ok = await _pinService.verifyPin(_pin);
        if (!mounted) return;

        if (ok == true) {
          Navigator.pop(context, true);
        } else {
          _reset();
          _showError('Incorrect PIN');
        }
      }
    } catch (e) {
      _showError('Something went wrong: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _reset() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        margin: const EdgeInsets.all(6),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: Colors.grey)),
        title: Text(
            widget.mode == PinMode.set
                ? 'Set Privacy PIN'
                : 'Enter Privacy PIN',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ok == false
                  ? 'Entered PIN is wrong'
                  : widget.mode == PinMode.set
                      ? 'Set Privacy PIN'
                      : 'Authentication Required',
              style: TextStyle(
                  fontFamily: 'ClashGrotesk',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color:
                      ok == false ? Theme.of(context).colorScheme.error : null),
            ),
            Text(
              widget.message != '' || widget.message != null
                  ? widget.message!
                  : widget.mode == PinMode.set
                      ? 'Set your Privacy PIN to authenticate with all objects'
                      : 'Verify your Privacy PIN to access',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:
                      ok == false ? Theme.of(context).colorScheme.error : null),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      enabled: !_isProcessing,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      obscureText: true,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      cursorErrorColor: ok == false
                          ? Theme.of(context).colorScheme.error
                          : null,
                      onChanged: (v) {
                        if (v.isNotEmpty) {
                          if (i < 3) {
                            _focusNodes[i + 1].requestFocus();
                          } else {
                            _focusNodes[i].unfocus();
                            _onCompleted();
                          }
                        } else if (i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            if (_isProcessing) const CircularProgressIndicator(year2023: false),
          ],
        ),
      ),
    );
  }
}
