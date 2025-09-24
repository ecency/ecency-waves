import 'package:equatable/equatable.dart';

class TranslationLanguage extends Equatable {
  const TranslationLanguage({
    required this.code,
    required this.name,
    required this.targets,
  });

  final String code;
  final String name;
  final List<String> targets;

  factory TranslationLanguage.fromJson(Map<String, dynamic> json) {
    return TranslationLanguage(
      code: json['code'] as String,
      name: json['name'] as String,
      targets: (json['targets'] as List<dynamic>).cast<String>(),
    );
  }

  bool supportsTarget(String targetCode) => targets.contains(targetCode);

  @override
  List<Object?> get props => [code, name, targets];
}
