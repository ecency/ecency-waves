import 'dart:convert';
import 'dart:math' as math;

class NotificationModel {
  NotificationModel({
    required this.id,
    required this.type,
    required this.source,
    required this.read,
    required this.timestamp,
    required this.payload,
  });

  final String id;
  final String type;
  final String source;
  final bool read;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = Map<String, dynamic>.from(json);
    final timestampString = json['timestamp']?.toString();
    DateTime? timestamp;

    if (timestampString != null && timestampString.isNotEmpty) {
      timestamp = DateTime.tryParse(timestampString);
    }

    if (timestamp == null) {
      final tsValue = json['ts'];
      if (tsValue is num) {
        timestamp = DateTime.fromMillisecondsSinceEpoch(
          tsValue.toInt() * 1000,
          isUtc: true,
        );
      }
    }

    timestamp ??= DateTime.now().toUtc();

    final readValue = json['read'];

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      read: readValue == 1 || readValue == true,
      timestamp: timestamp.toLocal(),
      payload: payload,
    );
  }

  factory NotificationModel.fromJsonString(String jsonString) {
    return NotificationModel.fromJson(json.decode(jsonString));
  }

  String get actor {
    final keys = ['follower', 'voter', 'from', 'author', 'delegator'];
    for (final key in keys) {
      final value = payload[key];
      if (value != null) {
        final sanitized = _sanitizeUsername(value);
        if (sanitized.isNotEmpty) {
          return sanitized;
        }
      }
    }
    return _sanitizeUsername(source);
  }

  String get actorHandle => actor.isEmpty ? '' : '@$actor';

  String? get title {
    return _parseString(payload['title']);
  }

  String? get body {
    return _parseString(payload['body']);
  }

  String? get memo {
    final value = payload['memo'];
    if (value is Map) {
      final memoValue = value['memo'] ?? value['message'] ?? value['text'];
      final parsed = _parseString(memoValue);
      if (parsed != null) {
        return parsed;
      }
    }
    return _parseString(value);
  }

  String? get amount {
    return _parseAmount(payload['amount']);
  }

  String? get parentTitle {
    return _parseString(payload['parent_title']);
  }

  String? get imageUrl {
    return _parseString(payload['img_url']);
  }

  String? get permlink {
    return _parseString(payload['permlink']);
  }

  String? get parentPermlink {
    return _parseString(payload['parent_permlink']);
  }

  String? get parentAuthor {
    return _parseString(payload['parent_author']);
  }

  String? get contentAuthor {
    final value = payload['author'];
    final author = _parseString(value);
    if (author != null && author.isNotEmpty) {
      return author;
    }
    return parentAuthor;
  }

  String? get url {
    final urlValue = payload['url'] ?? payload['link'];
    return _parseString(urlValue);
  }

  NotificationModel copyWith({
    bool? read,
  }) {
    return NotificationModel(
      id: id,
      type: type,
      source: source,
      read: read ?? this.read,
      timestamp: timestamp,
      payload: payload,
    );
  }

  String _sanitizeUsername(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('@')) {
        return trimmed.substring(1);
      }
      return trimmed;
    }
    return '';
  }

  String? _parseString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num) {
      return value.toString();
    }
    return null;
  }

  String? _parseAmount(dynamic value) {
    final parsed = _parseString(value);
    if (parsed != null) {
      return parsed;
    }

    if (value is Map) {
      final amountValue =
          value['amount'] ?? value['quantity'] ?? value['value'];
      final symbolValue = value['symbol'] ?? value['token'] ?? value['currency'];
      final prefix = _parseString(value['prefix']);
      final suffix = _parseString(value['suffix']);

      String? amountString = _parseString(amountValue);
      if (amountString == null && amountValue is num) {
        amountString = amountValue.toString();
      }

      if (amountValue is num && value['precision'] is num) {
        final precision = (value['precision'] as num).toInt();
        if (precision >= 0 && precision <= 8) {
          final scaled = amountValue / math.pow(10, precision);
          amountString = scaled.toStringAsFixed(precision);
        }
      }

      final symbolString = _parseString(symbolValue);

      String? result;
      if (amountString != null && symbolString != null) {
        result = '$amountString $symbolString';
      } else {
        result = amountString ?? symbolString;
      }

      if (result != null) {
        if (prefix != null) {
          result = '$prefix$result';
        }
        if (suffix != null) {
          result = '$result$suffix';
        }
      }

      return result;
    }

    return null;
  }
}
