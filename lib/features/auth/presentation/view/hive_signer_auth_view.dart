import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/features/auth/presentation/controller/hive_signer_controller.dart';

class HiveSignerAuthView extends StatefulWidget {
  const HiveSignerAuthView({super.key});

  @override
  State<HiveSignerAuthView> createState() => _HiveSignerAuthViewState();
}

class _HiveSignerAuthViewState extends State<HiveSignerAuthView> {
  static const String _callbackScheme = 'waves';
  static const String _callbackHost = 'hivesigner-auth';

  static final Uri _authorizeUri = Uri.https(
    'hivesigner.com',
    '/oauth2/authorize',
    <String, String>{
      'client_id': 'ecency.app',
      'redirect_uri': '$_callbackScheme://$_callbackHost',
      'response_type': 'token',
      'scope': 'vote,comment,transfer',
    },
  );

  final HiveSignerController controller = HiveSignerController();
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri?>? _linkSubscription;
  bool _hasAttemptedLaunch = false;
  bool _isLaunching = false;
  bool _launchFailed = false;
  bool _hasHandledCallback = false;

  @override
  void initState() {
    super.initState();
    _initAppLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openHiveSigner();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    closeInAppWebView();
    super.dispose();
  }

  Future<void> _initAppLinks() async {
    await _handleInitialUri();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleUri(uri);
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> _handleInitialUri() async {
    try {
      final Uri? initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleUri(initial);
      }
    } catch (_) {
      // No-op: we only care about valid callback URIs.
    }
  }

  Future<void> _handleUri(Uri uri) async {
    if (uri.scheme.toLowerCase() != _callbackScheme ||
        uri.host.toLowerCase() != _callbackHost ||
        _hasHandledCallback) {
      return;
    }

    _hasHandledCallback = true;
    await closeInAppWebView();

    controller.onLogin(
      uri.toString(),
      onSuccess: (accountName) {
        if (!mounted) return;
        context.showSnackBar(LocaleText.successfullLoginMessage(accountName));

        final NavigatorState navigator = Navigator.of(context);
        final GoRouter router = GoRouter.of(context);

        if (navigator.canPop()) {
          navigator.pop();
          if (navigator.canPop()) {
            navigator.pop();
          }
        } else {
          router.goNamed(Routes.initialView);
        }
      },
      onFailure: (errorMessage) {
        if (!mounted) return;
        context.showSnackBar(errorMessage);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _openHiveSigner() async {
    setState(() {
      _hasHandledCallback = false;
      _isLaunching = true;
      _hasAttemptedLaunch = true;
      _launchFailed = false;
    });

    await closeInAppWebView();

    final bool launched = await Act.launchThisUrl(_authorizeUri.toString());

    if (!mounted) {
      return;
    }

    if (!launched && mounted) {
      context.showSnackBar(LocaleText.somethingWentWrong);
    }

    setState(() {
      _isLaunching = false;
      _launchFailed = !launched;
    });
  }

  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleText.loginWithSigner),
      ),
      body: SafeArea(
        child: Padding(
          padding: kScreenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLaunching) ...[
                const Center(child: CircularProgressIndicator()),
                const Gap(24),
              ],
              Text(
                LocaleText.loginWithSigner,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              ElevatedButton(
                onPressed: _isLaunching ? null : _openHiveSigner,
                child: Text(LocaleText.loginWithSigner),
              ),
              if (_hasAttemptedLaunch && _launchFailed && !_isLaunching) ...[
                const Gap(16),
                Text(
                  LocaleText.somethingWentWrong,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
