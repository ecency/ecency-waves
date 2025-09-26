import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waves/core/utilities/enum.dart';

class Act {
  static Future<bool> launchThisUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }

    final bool isHttpScheme = uri.scheme == 'http' || uri.scheme == 'https';
    final List<LaunchMode> preferredModes = [
      if (isHttpScheme) LaunchMode.inAppBrowserView,
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
    ];

    for (final mode in preferredModes) {
      try {
        final bool launched = await launchUrl(uri, mode: mode);
        if (launched) {
          return true;
        }
      } catch (e, stackTrace) {
        dev.log('Failed to launch $url with mode $mode',
            error: e, stackTrace: stackTrace);
      }
    }

    dev.log("URL can't be launched.");
    return false;
  }

  static String generateQrString(SocketInputType inputType, String jsonString) {
    var utf8Data = utf8.encode(jsonString);
    String qr = base64.encode(utf8Data);
    qr = "has://${enumToString(inputType)}/$qr";
    return qr;
  }

  static Future<String?> getStringFromclipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  static List<String> compileTags(
    String comment, {
    List<String>? baseTags,
    String? parentPermlink,
  }) {
    final RegExp pattern = RegExp(r'#(\w+)');

    final List<String> ordered = [];
    final Set<String> seen = {};

    void addTag(String? tag) {
      if (tag == null) {
        return;
      }
      final String trimmed = tag.trim();
      if (trimmed.isEmpty) {
        return;
      }
      final String normalized = trimmed.toLowerCase();
      if (seen.add(normalized)) {
        ordered.add(normalized);
      }
    }

    addTag(parentPermlink);

    final Iterable<String> defaults = baseTags ?? const [
      "hive-125125",
      "waves",
      "ecency",
      "mobile",
      "thread",
    ];
    for (final tag in defaults) {
      addTag(tag);
    }

    for (final match in pattern.allMatches(comment)) {
      addTag(match.group(1));
    }

    return ordered;
  }

  static String generatePermlink(String username) {
    final t = DateTime.now();
    final timeFormat = '${t.year}'
        '${t.month.toString()}'
        '${t.day.toString()}'
        't${t.hour.toString()}'
        '${t.minute.toString()}'
        '${t.second.toString()}'
        '${t.millisecond.toString()}z';
    return 're-${username.replaceAll('.', '')}-$timeFormat';
  }

  static int generateRandomNumber(int numberOfDigits) {
    if (numberOfDigits < 1) {
      throw ArgumentError('Number of digits must be at least 1');
    }
    Random random = Random();
    int min = pow(10, numberOfDigits - 1).toInt();
    int max = pow(10, numberOfDigits).toInt() - 1;
    return min + random.nextInt(max - min + 1);
  }

  static String commentWithImages(String comment, List<String> imageLinks) {
    String result = "";
    if (comment.trim().isNotEmpty) {
      result += comment;
      result += '\n\n';
    }
    for (int i = 0; i < imageLinks.length; i++) {
      String image = imageLinks[i];
      result += "![image-${i + 1}]($image)";
    }
    return result;
  }
}
