class VCardFormatter {
  VCardFormatter._();

  static String format({required String name, String? phone, String? email}) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:$name');
    if (phone != null && phone.isNotEmpty) {
      buffer.writeln('TEL:$phone');
    }
    if (email != null && email.isNotEmpty) {
      buffer.writeln('EMAIL:$email');
    }
    buffer.writeln('END:VCARD');
    return buffer.toString();
  }
}
