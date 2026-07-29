import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bloom/services/permissions/bloom_pin_service.dart';

enum PinMode { set, verify }

class PinEntryScreen extends StatefulWidget {
  final PinMode mode;
  final String? message;

  const PinEntryScreen({
    super.key,
    required this.mode,
    this.message,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final controllers = List.generate(4, (_) => TextEditingController());
  final focusNodes = List.generate(4, (_) => FocusNode());
  final pinService = BloomPinService();
  final bloomSnackBars = BloomSnackBars();
  bool isProcessing = false;
  bool? ok;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => focusNodes.first.requestFocus(),
    );
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _pin => controllers.map((c) => c.text).join();

  Future<void> _onCompleted() async {
    if (_pin.length != 4 || isProcessing) return;

    setState(() => isProcessing = true);

    try {
      if (widget.mode == PinMode.set) {
        await pinService.setPin(_pin);
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        ok = await pinService.verifyPin(_pin);
        if (!mounted) return;

        if (ok == true) {
          Navigator.pop(context, true);
        } else {
          _reset();
          bloomSnackBars.showGenericErrorSnackBar(context, 'Incorrect PIN');
        }
      }
    } catch (e) {
      bloomSnackBars.showGenericErrorSnackBar(
          context, 'Something went wrong: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  void _reset() {
    for (final c in controllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.pop(context),
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
              widget.message!.isNotEmpty
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
                      controller: controllers[i],
                      focusNode: focusNodes[i],
                      enabled: !isProcessing,
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
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (i < 3) {
                            focusNodes[i + 1].requestFocus();
                          } else {
                            focusNodes[i].unfocus();
                            _onCompleted();
                          }
                        } else if (i > 0) {
                          focusNodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            if (isProcessing) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
