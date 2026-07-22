String _escapeWifi(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll(':', '\\:')
      .replaceAll('"', '\\"');
}

class QrContentBuilder {
  QrContentBuilder._();

  static String text(String content) => content;

  static String url(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith(RegExp(r'https?://'))) return trimmed;
    return 'https://$trimmed';
  }

  static String wifi({
    required String ssid,
    required String password,
    required String encryption,
    required bool hidden,
  }) {
    final type = password.isEmpty ? 'nopass' : encryption;
    return 'WIFI:T:$type;S:${_escapeWifi(ssid)};'
        '${password.isEmpty ? '' : 'P:${_escapeWifi(password)};'}'
        'H:${hidden ? 'true' : 'false'};;';
  }

  static String contact({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String org,
  }) {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('N:$lastName;$firstName;;;')
      ..writeln('FN:$firstName $lastName'.trim());
    if (org.isNotEmpty) buffer.writeln('ORG:$org');
    if (phone.isNotEmpty) buffer.writeln('TEL;TYPE=CELL:$phone');
    if (email.isNotEmpty) buffer.writeln('EMAIL:$email');
    buffer.writeln('END:VCARD');
    return buffer.toString().trim();
  }

  static String email({
    required String address,
    required String subject,
    required String body,
  }) {
    final query = <String>[];
    if (subject.isNotEmpty) query.add('subject=${Uri.encodeComponent(subject)}');
    if (body.isNotEmpty) query.add('body=${Uri.encodeComponent(body)}');
    final queryString = query.isEmpty ? '' : '?${query.join('&')}';
    return 'mailto:$address$queryString';
  }

  static String phone(String number) => 'tel:$number';

  static String sms({required String number, required String message}) {
    if (message.isEmpty) return 'smsto:$number';
    return 'smsto:$number:$message';
  }
}
