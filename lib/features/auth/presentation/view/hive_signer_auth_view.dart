import 'package:flutter/material.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/features/auth/presentation/controller/hive_signer_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HiveSignerAuthView extends StatefulWidget {
  const HiveSignerAuthView({super.key});

  @override
  State<HiveSignerAuthView> createState() => _HiveSignerAuthViewState();
}

class _HiveSignerAuthViewState extends State<HiveSignerAuthView> {
  late final WebViewController webviewcontroller;
  final ValueNotifier<int> loadingProgress = ValueNotifier(0);
  final HiveSignerController controller = HiveSignerController();
  @override
  void initState() {
    webviewcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            loadingProgress.value = progress;
          },
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://example.com/')) {
              controller.onLogin(request.url, onSuccess: (accountname) {
                context.showSnackBar(
                    LocaleText.successfullLoginMessage(accountname));
                Navigator.pop(context);
                Navigator.pop(context);
              }, onFailure: (errorMessage) {
                context.showSnackBar(errorMessage);
                Navigator.pop(context);
              });
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://hivesigner.com/oauth2/authorize?client_id=ecency.app&redirect_uri=https://example.com/callback/&scope=vote,comment'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _pageLoader(),
        body: SafeArea(child: WebViewWidget(controller: webviewcontroller)));
  }

  SafeArea _pageLoader() {
    return SafeArea(
      child: ValueListenableBuilder<int>(
        valueListenable: loadingProgress,
        builder: (context, progress, child) {
          return Visibility(
            visible: progress != 100,
            child: LinearProgressIndicator(
              value: (progress / 100).toDouble(),
            ),
          );
        },
      ),
    );
  }
}
