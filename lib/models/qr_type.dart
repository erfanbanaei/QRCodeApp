import 'package:flutter/material.dart';

enum QrType { text, url, wifi, contact, email, phone, sms }

extension QrTypeLabel on QrType {
  String get label {
    switch (this) {
      case QrType.text:
        return 'متن';
      case QrType.url:
        return 'لینک';
      case QrType.wifi:
        return 'وای‌فای';
      case QrType.contact:
        return 'مخاطب';
      case QrType.email:
        return 'ایمیل';
      case QrType.phone:
        return 'تلفن';
      case QrType.sms:
        return 'پیامک';
    }
  }

  IconData get icon {
    switch (this) {
      case QrType.text:
        return Icons.notes_rounded;
      case QrType.url:
        return Icons.link_rounded;
      case QrType.wifi:
        return Icons.wifi_rounded;
      case QrType.contact:
        return Icons.contact_page_rounded;
      case QrType.email:
        return Icons.email_rounded;
      case QrType.phone:
        return Icons.call_rounded;
      case QrType.sms:
        return Icons.sms_rounded;
    }
  }
}
