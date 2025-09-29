import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension LocaleWatchExtension on BuildContext {
  Locale watchLocale() => locale;
}

typedef LocaleAwareWidgetBuilder<T> = Widget Function(
    BuildContext context, T value, Widget? child);

class LocaleAwareConsumer<T> extends StatelessWidget {
  const LocaleAwareConsumer({super.key, required this.builder, this.child});

  final LocaleAwareWidgetBuilder<T> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, value, child) {
        context.locale;
        return builder(context, value, child);
      },
      child: child,
    );
  }
}

typedef LocaleAwareSelectorBuilder<S> = Widget Function(
    BuildContext context, S value, Widget? child);

class LocaleAwareSelector<T, S> extends StatelessWidget {
  const LocaleAwareSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.child,
    this.shouldRebuild,
  });

  final S Function(BuildContext, T) selector;
  final LocaleAwareSelectorBuilder<S> builder;
  final Widget? child;
  final ShouldRebuild<S>? shouldRebuild;

  @override
  Widget build(BuildContext context) {
    return Selector<T, S>(
      selector: selector,
      shouldRebuild: shouldRebuild,
      builder: (context, value, child) {
        context.locale;
        return builder(context, value, child);
      },
      child: child,
    );
  }
}
