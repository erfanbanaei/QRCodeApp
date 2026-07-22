import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:uuid/uuid.dart';

import '../models/history_item.dart';
import '../models/qr_style_options.dart';
import '../models/qr_type.dart';
import '../services/history_service.dart';
import '../theme/app_gradients.dart';
import '../utils/qr_content_builder.dart';
import '../utils/qr_export.dart';
import '../widgets/color_picker_button.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_card.dart';
import '../widgets/type_pill.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  QrType _type = QrType.text;
  QrStyleOptions _style = const QrStyleOptions();
  bool _busy = false;

  final _qrKey = GlobalKey();
  final _historyService = HistoryService();

  final _textController = TextEditingController();
  final _urlController = TextEditingController();

  final _wifiSsidController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  String _wifiEncryption = 'WPA';
  bool _wifiHidden = false;

  final _contactFirstNameController = TextEditingController();
  final _contactLastNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactOrgController = TextEditingController();

  final _emailAddressController = TextEditingController();
  final _emailSubjectController = TextEditingController();
  final _emailBodyController = TextEditingController();

  final _phoneController = TextEditingController();

  final _smsNumberController = TextEditingController();
  final _smsMessageController = TextEditingController();

  late final List<TextEditingController> _allControllers = [
    _textController,
    _urlController,
    _wifiSsidController,
    _wifiPasswordController,
    _contactFirstNameController,
    _contactLastNameController,
    _contactPhoneController,
    _contactEmailController,
    _contactOrgController,
    _emailAddressController,
    _emailSubjectController,
    _emailBodyController,
    _phoneController,
    _smsNumberController,
    _smsMessageController,
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _allControllers) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  String get _currentData {
    switch (_type) {
      case QrType.text:
        return QrContentBuilder.text(_textController.text.trim());
      case QrType.url:
        return _urlController.text.trim().isEmpty
            ? ''
            : QrContentBuilder.url(_urlController.text);
      case QrType.wifi:
        if (_wifiSsidController.text.trim().isEmpty) return '';
        return QrContentBuilder.wifi(
          ssid: _wifiSsidController.text.trim(),
          password: _wifiPasswordController.text,
          encryption: _wifiEncryption,
          hidden: _wifiHidden,
        );
      case QrType.contact:
        if (_contactFirstNameController.text.trim().isEmpty &&
            _contactLastNameController.text.trim().isEmpty) {
          return '';
        }
        return QrContentBuilder.contact(
          firstName: _contactFirstNameController.text.trim(),
          lastName: _contactLastNameController.text.trim(),
          phone: _contactPhoneController.text.trim(),
          email: _contactEmailController.text.trim(),
          org: _contactOrgController.text.trim(),
        );
      case QrType.email:
        if (_emailAddressController.text.trim().isEmpty) return '';
        return QrContentBuilder.email(
          address: _emailAddressController.text.trim(),
          subject: _emailSubjectController.text.trim(),
          body: _emailBodyController.text.trim(),
        );
      case QrType.phone:
        if (_phoneController.text.trim().isEmpty) return '';
        return QrContentBuilder.phone(_phoneController.text.trim());
      case QrType.sms:
        if (_smsNumberController.text.trim().isEmpty) return '';
        return QrContentBuilder.sms(
          number: _smsNumberController.text.trim(),
          message: _smsMessageController.text.trim(),
        );
    }
  }

  String get _historyTitle {
    switch (_type) {
      case QrType.text:
        final t = _textController.text.trim();
        return t.length > 40 ? '${t.substring(0, 40)}…' : t;
      case QrType.url:
        return _urlController.text.trim();
      case QrType.wifi:
        return 'وای‌فای: ${_wifiSsidController.text.trim()}';
      case QrType.contact:
        return 'مخاطب: ${_contactFirstNameController.text.trim()} ${_contactLastNameController.text.trim()}'.trim();
      case QrType.email:
        return 'ایمیل: ${_emailAddressController.text.trim()}';
      case QrType.phone:
        return 'تلفن: ${_phoneController.text.trim()}';
      case QrType.sms:
        return 'پیامک: ${_smsNumberController.text.trim()}';
    }
  }

  PrettyQrDecoration get _decoration {
    return PrettyQrDecoration(
      shape: _style.shape,
      background: _style.backgroundColor,
      quietZone: const PrettyQrQuietZone.modules(3),
      image: _style.logoBytes == null
          ? null
          : PrettyQrDecorationImage(
              image: MemoryImage(_style.logoBytes!),
              position: PrettyQrDecorationImagePosition.embedded,
              padding: const EdgeInsets.all(6),
              scale: 0.22,
            ),
    );
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _style = _style.copyWith(logoBytes: bytes, eccLevel: QrEccLevel.high);
    });
  }

  Future<void> _addToHistory() async {
    // این متد هرگز نباید باعث شکست ذخیره/اشتراک‌گذاری شود، پس خطایش را جدا می‌بلعیم.
    try {
      final data = _currentData;
      if (data.isEmpty) return;
      await _historyService.add(
        HistoryItem(
          id: const Uuid().v4(),
          data: data,
          title: _historyTitle.isEmpty ? data : _historyTitle,
          source: HistorySource.generated,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // نادیده گرفتن خطای تاریخچه؛ خروجی اصلی (ذخیره/اشتراک‌گذاری) مهم‌تر است.
    }
  }

  Future<void> _saveToGallery() async {
    if (_currentData.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await QrExport.captureBoundary(_qrKey);
      if (bytes == null) throw Exception('امکان ساخت تصویر از کد نبود');
      await QrExport.saveToGallery(bytes);
      unawaited(_addToHistory());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('کد QR در گالری ذخیره شد')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ذخیره‌سازی ناموفق بود: ${_readableError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareQr() async {
    if (_currentData.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await QrExport.captureBoundary(_qrKey);
      if (bytes == null) throw Exception('امکان ساخت تصویر از کد نبود');
      await QrExport.share(bytes);
      unawaited(_addToHistory());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('اشتراک‌گذاری ناموفق بود: ${_readableError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _readableError(Object e) {
    if (e is GalException) {
      switch (e.type) {
        case GalExceptionType.accessDenied:
          return 'دسترسی به گالری داده نشد. از تنظیمات گوشی مجوز را فعال کنید.';
        case GalExceptionType.notEnoughSpace:
          return 'فضای کافی برای ذخیره وجود ندارد.';
        case GalExceptionType.notSupportedFormat:
          return 'فرمت تصویر پشتیبانی نمی‌شود.';
        case GalExceptionType.unexpected:
          return 'خطای غیرمنتظره‌ای رخ داد.';
      }
    }
    return e.toString();
  }

  String get _customizationSummary {
    final parts = <String>[];
    parts.add(_style.shapeStyle.label);
    if (_style.useGradient) parts.add('گرادیان');
    if (_style.logoBytes != null) parts.add('لوگو');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'ساخت کد QR',
            subtitle: 'محتوا را انتخاب کن و دلخواه بساز',
            icon: Icons.qr_code_2_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
              children: [
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: QrType.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final type = QrType.values[index];
                      return TypePill(
                        icon: type.icon,
                        label: type.label,
                        selected: type == _type,
                        onTap: () => setState(() => _type = type),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SectionCard(title: 'اطلاعات', icon: Icons.edit_note_rounded, child: _buildFields()),
                const SizedBox(height: 20),
                _buildPreview(data),
                const SizedBox(height: 20),
                SectionCard(
                  title: 'شخصی‌سازی ظاهر',
                  icon: Icons.palette_rounded,
                  collapsible: true,
                  initiallyExpanded: false,
                  summary: _customizationSummary,
                  child: _buildCustomization(),
                ),
                const SizedBox(height: 24),
                _buildActions(data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFields() {
    switch (_type) {
      case QrType.text:
        return TextField(
          controller: _textController,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'متن مورد نظر خود را وارد کنید'),
        );
      case QrType.url:
        return TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(labelText: 'آدرس لینک', hintText: 'example.com'),
        );
      case QrType.wifi:
        return Column(
          children: [
            TextField(
              controller: _wifiSsidController,
              decoration: const InputDecoration(labelText: 'نام شبکه (SSID)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wifiPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'رمز عبور'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _wifiEncryption,
              decoration: const InputDecoration(labelText: 'نوع رمزنگاری'),
              items: const [
                DropdownMenuItem(value: 'WPA', child: Text('WPA/WPA2')),
                DropdownMenuItem(value: 'WEP', child: Text('WEP')),
              ],
              onChanged: (v) => setState(() => _wifiEncryption = v ?? 'WPA'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('شبکه پنهان است'),
              value: _wifiHidden,
              onChanged: (v) => setState(() => _wifiHidden = v),
            ),
          ],
        );
      case QrType.contact:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _contactFirstNameController,
                    decoration: const InputDecoration(labelText: 'نام'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _contactLastNameController,
                    decoration: const InputDecoration(labelText: 'نام خانوادگی'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactPhoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'شماره تلفن'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactEmailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'ایمیل'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactOrgController,
              decoration: const InputDecoration(labelText: 'سازمان (اختیاری)'),
            ),
          ],
        );
      case QrType.email:
        return Column(
          children: [
            TextField(
              controller: _emailAddressController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'آدرس ایمیل گیرنده'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailSubjectController,
              decoration: const InputDecoration(labelText: 'موضوع'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailBodyController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'متن پیام'),
            ),
          ],
        );
      case QrType.phone:
        return TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(labelText: 'شماره تلفن'),
        );
      case QrType.sms:
        return Column(
          children: [
            TextField(
              controller: _smsNumberController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'شماره گیرنده'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _smsMessageController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'متن پیامک'),
            ),
          ],
        );
    }
  }

  Widget _buildPreview(String data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF241E38), const Color(0xFF1A1626)]
              : [Colors.white, const Color(0xFFF0EDFA)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppGradients.violet.withValues(alpha: isDark ? 0.22 : 0.14),
        ),
        boxShadow: AppGradients.glow(AppGradients.violet, opacity: isDark ? 0.14 : 0.10, blur: 30, y: 14),
      ),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: data.isEmpty
              ? _emptyPreview()
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      color: _style.backgroundColor,
                      padding: const EdgeInsets.all(6),
                      child: PrettyQrView.data(
                        data: data,
                        errorCorrectLevel: _style.eccLevel.value,
                        decoration: _decoration,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _emptyPreview() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppGradients.glow(AppGradients.violet, opacity: 0.4, blur: 20, y: 8),
                ),
                child: const Icon(Icons.qr_code_2_rounded, size: 42, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'پیش‌نمایش کد QR',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'برای دیدن پیش‌نمایش، اطلاعات را وارد کنید',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomization() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ColorPickerButton(
                label: 'رنگ کد',
                color: _style.foregroundColor,
                onChanged: (c) => setState(() => _style = _style.copyWith(foregroundColor: c)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ColorPickerButton(
                label: 'رنگ زمینه',
                color: _style.backgroundColor,
                onChanged: (c) => setState(() => _style = _style.copyWith(backgroundColor: c)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _gradientToggle(),
        if (_style.useGradient) ...[
          const SizedBox(height: 12),
          ColorPickerButton(
            label: 'رنگ دوم گرادیان',
            color: _style.gradientColor,
            onChanged: (c) => setState(() => _style = _style.copyWith(gradientColor: c)),
          ),
        ],
        const SizedBox(height: 20),
        _subHeader('سبک ماژول‌ها'),
        const SizedBox(height: 10),
        Row(
          children: QrShapeStyle.values.map((s) {
            final selected = _style.shapeStyle == s;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: s == QrShapeStyle.values.last ? 0 : 8),
                child: _optionChip(
                  label: s.label,
                  selected: selected,
                  onTap: () => setState(() => _style = _style.copyWith(shapeStyle: s)),
                ),
              ),
            );
          }).toList(),
        ),
        if (_style.shapeStyle == QrShapeStyle.rounded) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text('میزان گردی', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text('${(_style.roundFactor * 100).round()}٪',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      )),
            ],
          ),
          Slider(
            value: _style.roundFactor,
            onChanged: (v) => setState(() => _style = _style.copyWith(roundFactor: v)),
          ),
        ],
        const SizedBox(height: 20),
        _subHeader('سطح تصحیح خطا'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: QrEccLevel.values.map((level) {
            return _optionChip(
              label: level.label,
              selected: _style.eccLevel == level,
              onTap: () => setState(() => _style = _style.copyWith(eccLevel: level)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _subHeader('لوگوی مرکز کد'),
        const SizedBox(height: 10),
        Row(
          children: [
            if (_style.logoBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_style.logoBytes!, width: 46, height: 46, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                label: Text(_style.logoBytes == null ? 'افزودن لوگو' : 'تغییر لوگو'),
              ),
            ),
            if (_style.logoBytes != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => _style = _style.copyWith(clearLogo: true)),
                icon: const Icon(Icons.delete_outline_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _subHeader(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _gradientToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppGradients.candy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.gradient_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('گرادیان رنگی', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: _style.useGradient,
            onChanged: (v) => setState(() => _style = _style.copyWith(useGradient: v)),
          ),
        ],
      ),
    );
  }

  Widget _optionChip({required String label, required bool selected, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.brand : null,
          color: selected
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected ? AppGradients.glow(AppGradients.violet, opacity: 0.3, blur: 12, y: 4) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IRANYekan',
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13.5,
            color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(String data) {
    final disabled = data.isEmpty || _busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradientButton(
          icon: Icons.ios_share_rounded,
          label: 'اشتراک‌گذاری کد',
          onPressed: disabled ? null : _shareQr,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: disabled ? null : _saveToGallery,
          icon: const Icon(Icons.download_rounded, size: 20),
          label: const Text('ذخیره در گالری'),
        ),
        if (!disabled) ...[
          const SizedBox(height: 12),
          Text(
            'با ذخیره یا اشتراک‌گذاری، این کد به تاریخچه هم اضافه می‌شود',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
