import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../models/history_item.dart';
import '../services/history_service.dart';
import '../theme/app_gradients.dart';
import '../utils/qr_export.dart';
import '../utils/qr_image_renderer.dart';
import '../widgets/gradient_header.dart';

const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

String _toPersianDigits(String input) {
  return input.split('').map((c) {
    final index = int.tryParse(c);
    return index == null ? c : _persianDigits[index];
  }).join();
}

String _formatDate(DateTime dt) {
  final j = Jalali.fromDateTime(dt);
  final date = '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  return _toPersianDigits('$date - $time');
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final _service = HistoryService();
  List<HistoryItem> _items = [];
  bool _loading = true;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// از بیرون (وقتی تب تاریخچه انتخاب می‌شود) صدا زده می‌شود تا لیست تازه شود.
  Future<void> reload() => _load();

  Future<void> _load() async {
    final items = await _service.load();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _shareAsQr(HistoryItem item) async {
    if (_sharing) return;
    _sharing = true;
    try {
      final bytes = await QrImageRenderer.renderToPng(item.data);
      await QrExport.share(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('اشتراک‌گذاری ناموفق بود: $e')),
        );
      }
    } finally {
      _sharing = false;
    }
  }

  Future<void> _remove(HistoryItem item) async {
    await _service.remove(item.id);
    _load();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن تاریخچه'),
        content: const Text('آیا از پاک کردن کامل تاریخچه مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('پاک کردن')),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clear();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'تاریخچه',
            subtitle: 'کدهای ساخته و اسکن‌شده',
            icon: Icons.history_rounded,
            trailing: _items.isEmpty
                ? null
                : IconButton(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                    tooltip: 'پاک کردن همه',
                  ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Icon(Icons.history_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(height: 16),
                            Text('تاریخچه خالی است', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text('کدهایی که می‌سازی یا اسکن می‌کنی اینجا نمایش داده می‌شوند', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isGen = item.source == HistorySource.generated;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: isGen ? AppGradients.brand : AppGradients.candy,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: AppGradients.glow(
                                        isGen ? AppGradients.violet : AppGradients.magenta,
                                        opacity: 0.3, blur: 12, y: 4,
                                      ),
                                    ),
                                    child: Icon(
                                      isGen ? Icons.qr_code_2_rounded : Icons.qr_code_scanner_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (isGen ? AppGradients.violet : AppGradients.magenta).withValues(alpha: 0.14),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isGen ? 'ساخته‌شده' : 'اسکن‌شده',
                                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: isGen ? AppGradients.violet : AppGradients.magenta,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _formatDate(item.createdAt),
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded),
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'copy':
                                          Clipboard.setData(ClipboardData(text: item.data));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('کپی شد')),
                                          );
                                          break;
                                        case 'share':
                                          _shareAsQr(item);
                                          break;
                                        case 'delete':
                                          _remove(item);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'copy', child: Text('کپی متن')),
                                      PopupMenuItem(value: 'share', child: Text('اشتراک‌گذاری')),
                                      PopupMenuItem(value: 'delete', child: Text('حذف')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
