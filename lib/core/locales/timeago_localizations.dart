import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

final Set<String> _registeredTimeagoLocales = <String>{};

String formatRelativeTime(
  BuildContext context,
  DateTime dateTime, {
  bool allowFromNow = false,
  DateTime? clock,
  bool short = false,
}) {
  final locale = context.locale;
  final localeKey = _resolveLocaleKey(locale, short: short);
  _ensureLocaleRegistered(localeKey);

  return timeago.format(
    dateTime,
    allowFromNow: allowFromNow,
    clock: clock,
    locale: localeKey,
  );
}

String _resolveLocaleKey(Locale locale, {required bool short}) {
  final languageCode = locale.languageCode.toLowerCase();
  switch (languageCode) {
    case 'de':
      return short ? 'de_short' : 'de';
    case 'es':
      return short ? 'es_short' : 'es';
    case 'fr':
      return short ? 'fr_short' : 'fr';
    case 'hi':
      return short ? 'hi_short' : 'hi';
    case 'pt':
      return short ? 'pt_br_short' : 'pt_br';
    case 'ru':
      return short ? 'ru_short' : 'ru';
    case 'zh':
      return 'zh_cn';
    case 'en':
    default:
      return short ? 'en_short' : 'en';
  }
}

void _ensureLocaleRegistered(String localeKey) {
  if (_registeredTimeagoLocales.contains(localeKey)) {
    return;
  }

  final factory = _localeFactories[localeKey];
  if (factory != null) {
    timeago.setLocaleMessages(localeKey, factory());
  }

  _registeredTimeagoLocales.add(localeKey);
}

final Map<String, timeago.LookupMessages Function()> _localeFactories = {
  'de': () => timeago.DeMessages(),
  'de_short': () => timeago.DeShortMessages(),
  'es': () => timeago.EsMessages(),
  'es_short': () => timeago.EsShortMessages(),
  'fr': () => timeago.FrMessages(),
  'fr_short': () => timeago.FrShortMessages(),
  'hi': () => timeago.HiMessages(),
  'hi_short': () => timeago.HiShortMessages(),
  'pt_br': () => timeago.PtBrMessages(),
  'pt_br_short': () => timeago.PtBrShortMessages(),
  'ru': () => timeago.RuMessages(),
  'ru_short': () => timeago.RuShortMessages(),
  'zh_cn': () => timeago.ZhCnMessages(),
  'en': () => timeago.EnMessages(),
  'en_short': () => timeago.EnShortMessages(),
};
