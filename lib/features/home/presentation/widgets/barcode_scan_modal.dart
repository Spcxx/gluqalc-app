import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanDialog extends StatefulWidget {
  const BarcodeScanDialog({super.key});

  @override
  State<BarcodeScanDialog> createState() => _BarcodeScanDialogState();
}

class _BarcodeScanDialogState extends State<BarcodeScanDialog> {
  bool _handled = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  Future<void> dispose() async {
    await _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSupported =
        kIsWeb || defaultTargetPlatform == TargetPlatform.android;

    if (!isSupported) {
      return AlertDialog(
        title: Text(l10n.unsupportedPlatform),
        content: Text(l10n.unsupportedPlatformDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okButton),
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_handled) return;
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final rawValue = barcode.rawValue;
                  if (rawValue != null && rawValue.isNotEmpty) {
                    _handled = true;
                    Navigator.of(context).pop(rawValue);
                    break;
                  }
                }
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
