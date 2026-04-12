import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;

class QrGenerator {
  QrGenerator._();

  static const double _qrSize = 512;
  static const int _textAreaHeight = 60;
  static const int _qrSizeInt = 512;
  static const int _totalHeight = _qrSizeInt + _textAreaHeight;

  static Future<Uint8List?> generateWebsiteQR(String url) async {
    return _generateQR(url, url);
  }

  static Future<Uint8List?> generateWifiQR(String ssid, String password) async {
    final wifiString = 'WIFI:T:WPA;S:$ssid;P:$password;;';
    return _generateQR(wifiString, 'WiFi: $ssid');
  }

  static Future<Uint8List?> generateContactQR({
    required String name,
    String? phone,
    String? email,
  }) async {
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
    return _generateQR(buffer.toString(), name);
  }

  static Future<Uint8List?> _generateQR(String data, String caption) async {
    try {
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: false,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );

      final qrBytes = await qrPainter.toImageData(_qrSize);
      if (qrBytes == null) return null;

      final qrImg = img.decodeImage(qrBytes.buffer.asUint8List());
      if (qrImg == null) return null;

      final composite = img.Image(width: _qrSize.toInt(), height: _totalHeight);

      img.fill(composite, color: img.ColorRgb8(255, 255, 255));

      img.compositeImage(composite, qrImg);

      final textLines = _wrapText(caption, 38);
      final startY = _qrSize.toInt() + 10;
      int y = startY;

      for (final line in textLines) {
        img.drawString(
          composite,
          line,
          font: img.arial14,
          x: 0,
          y: y,
          color: img.ColorRgb8(26, 26, 46),
        );
        y += 18;
      }

      return Uint8List.fromList(img.encodePng(composite));
    } catch (e) {
      return null;
    }
  }

  static List<String> _wrapText(String text, int maxCharsPerLine) {
    if (text.length <= maxCharsPerLine) return [text];

    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      if (testLine.length <= maxCharsPerLine) {
        currentLine = testLine;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines.take(2).toList();
  }
}
