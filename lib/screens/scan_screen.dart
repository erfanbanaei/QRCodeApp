import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../models/history_item.dart';
import '../services/history_service.dart';
import '../theme/app_gradients.dart';

class ScanScreen extends StatefulWidget {
  final bool active;

  const ScanScreen({super.key, this.active = true});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final _historyService = HistoryService();
  bool _processing = false;

  @override
  void didUpdateWidget(covariant ScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _controller.start();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Uri? _asUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) return uri;
    return null;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final value = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (value == null || value.isEmpty) return;

    _processing = true;
    await _controller.stop();
    await _historyService.add(
      HistoryItem(
        id: const Uuid().v4(),
        data: value,
        title: value.length > 60 ? '${value.substring(0, 60)}…' : value,
        source: HistorySource.scanned,
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) await _showResultSheet(value);
    await _controller.start();
    _processing = false;
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    try {
      final capture = await _controller.analyzeImage(file.path);
      final value = capture?.barcodes.isNotEmpty == true ? capture!.barcodes.first.rawValue : null;
      if (value == null || value.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('کد QR در تصویر پیدا نشد')),
          );
        }
        return;
      }
      await _historyService.add(
        HistoryItem(
          id: const Uuid().v4(),
          data: value,
          title: value.length > 60 ? '${value.substring(0, 60)}…' : value,
          source: HistorySource.scanned,
          createdAt: DateTime.now(),
        ),
      );
      if (mounted) await _showResultSheet(value);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خواندن تصویر ناموفق بود')),
        );
      }
    }
  }

  Future<void> _showResultSheet(String value) async {
    final url = _asUrl(value);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('نتیجه اسکن', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectableText(
                  value,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              if (url != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FilledButton.icon(
                    onPressed: () => launchUrl(url, mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new_rounded, size: 20),
                    label: const Text('باز کردن لینک'),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('کپی شد')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      label: const Text('کپی'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => SharePlus.instance.share(ShareParams(text: value)),
                      icon: const Icon(Icons.ios_share_rounded, size: 20),
                      label: const Text('اشتراک‌گذاری'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _errorBuilder(BuildContext context, MobileScannerException error) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_rounded, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              const Text(
                'به دوربین دسترسی نیست',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: openAppSettings,
                child: const Text('باز کردن تنظیمات برنامه'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: _errorBuilder,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                stops: const [0, 0.25],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'کد را داخل کادر قرار دهید',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'IRANYekan',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppGradients.violet.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ScanControlButton(
                    icon: Icons.photo_library_outlined,
                    label: 'گالری',
                    onTap: _pickFromGallery,
                  ),
                  const SizedBox(width: 24),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, state, child) {
                      final torchOn = state.torchState == TorchState.on;
                      return _ScanControlButton(
                        icon: torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        label: 'فلاش',
                        onTap: _controller.toggleTorch,
                        active: torchOn,
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  _ScanControlButton(
                    icon: Icons.cameraswitch_rounded,
                    label: 'چرخش دوربین',
                    onTap: _controller.switchCamera,
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

class _ScanControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _ScanControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
