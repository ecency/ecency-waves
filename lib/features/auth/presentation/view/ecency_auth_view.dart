import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/controller/ecency_auth_controller.dart';
import 'package:waves/features/auth/presentation/widgets/auth_button.dart';
import 'package:waves/features/auth/presentation/widgets/auth_textfield.dart';
import 'package:waves/features/user/view/user_controller.dart';

class EcencyAuthView extends StatefulWidget {
  const EcencyAuthView({super.key});

  @override
  State<EcencyAuthView> createState() => _EcencyAuthViewState();
}

class _EcencyAuthViewState extends State<EcencyAuthView> {
  static const String _callbackScheme = 'waves';
  static const String _callbackHost = 'ecency-login';
  static const String _androidEcencyPackage = 'app.esteem.mobile.android';
  static final Uri _iosEcencyStoreUri =
      Uri.parse('https://apps.apple.com/app/ecency/id1450268965');
  static final Uri _androidEcencyStoreUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$_androidEcencyPackage');

  final TextEditingController _usernameController = TextEditingController();
  final EcencyAuthController _controller = EcencyAuthController();
  final Set<String> _handledCallbacks = <String>{};

  StreamSubscription<Uri?>? _linkSubscription;
  String? _pendingRequestId;
  String? _pendingUsername;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _initUniLinks() async {
    await _handleInitialUri();

    _linkSubscription = uriLinkStream.listen(
      (Uri? uri) async {
        if (uri != null) {
          await _handleUri(uri);
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> _handleInitialUri() async {
    try {
      final Uri? initialUri = await getInitialUri();
      if (initialUri != null) {
        await _handleUri(initialUri);
      }
    } on PlatformException {
      // Ignore – uni_links throws when no initial URI is available.
    } on FormatException catch (error) {
      debugPrint('Invalid initial URI from Ecency login: $error');
    }
  }

  Future<void> _handleUri(Uri uri) async {
    if (uri.scheme.toLowerCase() != _callbackScheme ||
        uri.host.toLowerCase() != _callbackHost) {
      return;
    }

    final String callbackIdentifier =
        uri.queryParameters['request_id'] ?? uri.toString();
    if (_handledCallbacks.contains(callbackIdentifier)) {
      return;
    }
    _handledCallbacks.add(callbackIdentifier);

    if (_pendingRequestId != null &&
        uri.queryParameters['request_id'] != null &&
        uri.queryParameters['request_id'] != _pendingRequestId) {
      return;
    }

    final String status = uri.queryParameters['status']?.toLowerCase() ?? '';
    final String? callbackUsername = uri.queryParameters['username'];
    final String username =
        (callbackUsername ?? _pendingUsername ?? '').trim().toLowerCase();

    if (status == 'success') {
      final String? postingKey = uri.queryParameters['posting_key'];
      if (postingKey == null || postingKey.isEmpty || username.isEmpty) {
        _showSnackBar(LocaleText.ecencyLoginFailed);
      } else {
        await _controller.completeLogin(
          username,
          postingKey: postingKey,
          showToast: (message) => _showSnackBar(message),
          showLoader: () {
            if (mounted) {
              context.showLoader();
            }
          },
          hideLoader: () {
            if (mounted) {
              context.hideLoader();
            }
          },
          onSuccess: () {
            if (!mounted) return;
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }
    } else {
      final String message = uri.queryParameters['message'] ??
          uri.queryParameters['error'] ??
          LocaleText.ecencyLoginFailed;
      _showSnackBar(message);
    }

    _pendingRequestId = null;
    _pendingUsername = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleText.loginWithEcency.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: kScreenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                hintText: LocaleText.username.tr(),
                textEditingController: _usernameController,
              ),
              const Gap(15),
              AuthButton(
                authType: AuthType.ecency,
                onTap: _onLoginTap,
                label: LocaleText.continueInEcency.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLoginTap() async {
    final String normalized = _normalizeUsername(_usernameController.text);

    if (normalized.isEmpty) {
      _showSnackBar(LocaleText.pleaseEnterTheUsername.tr());
      return;
    }

    if (!mounted) return;
    if (context.read<UserController>().isAccountDeleted(normalized)) {
      _showSnackBar(LocaleText.theAccountDoesntExist.tr());
      return;
    }

    FocusScope.of(context).unfocus();
    final String requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final Uri callbackUri = Uri(
      scheme: _callbackScheme,
      host: _callbackHost,
    );

    final Uri ecencyUri = Uri(
      scheme: 'ecency',
      host: 'login',
      queryParameters: <String, String>{
        'username': normalized,
        'callback': callbackUri.toString(),
        'request_id': requestId,
      },
    );

    final bool launched = await _launchEcencyUri(ecencyUri);
    if (launched) {
      _pendingRequestId = requestId;
      _pendingUsername = normalized;
    }
  }

  Future<bool> _launchEcencyUri(Uri uri) async {
    try {
      if (Platform.isAndroid) {
        final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: uri.toString(),
          package: _androidEcencyPackage,
        );
        final bool canLaunchIntent = await intent.canResolveActivity() ?? false;
        if (canLaunchIntent) {
          await intent.launch();
          return true;
        }
        _showSnackBar(LocaleText.ecencyAppNotFound);
        await launchUrl(
          _androidEcencyStoreUri,
          mode: LaunchMode.externalApplication,
        );
        return false;
      }

      if (Platform.isIOS) {
        final bool canLaunchEcency = await canLaunchUrl(uri);
        if (canLaunchEcency) {
          final bool launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {
            return true;
          }
        }

        _showSnackBar(LocaleText.ecencyAppNotFound);
        await launchUrl(
          _iosEcencyStoreUri,
          mode: LaunchMode.externalApplication,
        );
        return false;
      }

      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (error, stackTrace) {
      debugPrint('Unable to launch Ecency login: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showSnackBar(LocaleText.ecencyLoginFailed);
      return false;
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    context.showSnackBar(message);
  }

  String _normalizeUsername(String value) {
    return value.replaceAll('@', '').trim().toLowerCase();
  }
}

