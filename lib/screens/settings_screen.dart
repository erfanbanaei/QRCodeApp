import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_gradients.dart';
import '../theme/theme_controller.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'تنظیمات',
            subtitle: 'ظاهر و اطلاعات برنامه',
            icon: Icons.settings_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              children: [
          SectionCard(
            title: 'ظاهر برنامه',
            icon: Icons.dark_mode_rounded,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('حالت نمایش', style: Theme.of(context).textTheme.bodySmall),
                ),
                const SizedBox(height: 10),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, label: Text('روشن'), icon: Icon(Icons.light_mode_outlined, size: 18)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('تاریک'), icon: Icon(Icons.dark_mode_outlined, size: 18)),
                    ButtonSegment(value: ThemeMode.system, label: Text('سیستم'), icon: Icon(Icons.settings_suggest_outlined, size: 18)),
                  ],
                  selected: {themeController.themeMode},
                  onSelectionChanged: (v) => themeController.setThemeMode(v.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'درباره برنامه',
            icon: Icons.info_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppGradients.brand,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppGradients.glow(AppGradients.violet, opacity: 0.35, blur: 14, y: 5),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('کیوآرکد من', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('ساخت و اسکن کد QR با شخصی‌سازی کامل', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تمامی داده‌ها فقط به‌صورت محلی روی دستگاه شما ذخیره می‌شوند و به سروری ارسال نمی‌گردند.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
