import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
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

    try {
      if (Platform.isIOS) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e, stackTrace) {
      dev.log('Failed to launch $url', error: e, stackTrace: stackTrace);
      return false;
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

  static List<String> compileTags(String comment) {
    // Regex pattern for hashtags
    RegExp pattern = RegExp(r'#(\w+)');

    // Find all hashtags and discard the # character
    List<String> hashtags = [];
    Iterable<RegExpMatch> matches = pattern.allMatches(comment);

    for (var match in matches) {
      hashtags
          .add(match.group(1)!); // group(1) contains the hashtag without the #
    }
    
    return [
      "hive-125125",
      "waves",
      "ecency",
      "mobile",
      "thread",
      ...hashtags
    ];
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
