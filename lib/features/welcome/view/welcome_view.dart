import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/features/user/view/user_controller.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  bool showAnimation = true;
  bool isConsentChecked = false;
  String appVersion =
      "1.0.0"; // Flutter has no direct equivalent for getting version, use package_info for this

  @override
  void initState() {
    super.initState();
  }

  void _handleButtonPress() {
    context.read<UserController>().setTermsAcceptedFlag(true);

    // Navigate to Main Screen (Use your route navigation logic here)
    context.pushReplacementNamed(Routes.initialView);
  }

  void _onCheckPress(bool? value) {
    setState(() {
      isConsentChecked = value ?? false;
    });
  }

  void _onTermsPress() {
    // Navigate to a webview or open URL in browser
    Act.launchThisUrl("https://ecency.com/terms-of-service");
  }

  Widget _renderInfo(IconData iconName, String heading, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns items at the top
        children: [
          Icon(iconName, size: 30, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            // Ensures the column takes the available space and allows wrapping
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                    height: 5), // Add some spacing between heading and body
                Text(
                  body,
                  style: const TextStyle(fontSize: 15),
                  softWrap: true, // Allows wrapping onto multiple lines
                  overflow: TextOverflow
                      .visible, // Ensure text remains visible if it exceeds space
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderConsent() {
    return Row(
      children: [
        Checkbox.adaptive(
          value: isConsentChecked,
          onChanged: _onCheckPress,
        ),
        Expanded(
          child: GestureDetector(
            onTap: _onTermsPress,
            child: Text.rich(
              TextSpan(
                text: "I accept the ",
                style: const TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: "Terms and Conditions",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Waves', // Replace with localized text
                        style: TextStyle(fontSize: 34),
                        textAlign: TextAlign.start,
                      ),
                      const Text(
                        'In Ocean of Thoughts', // Replace with localized text
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Short content sharing', // Replace with localized text
                        style: TextStyle(
                            fontSize: 34,
                            color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          _renderInfo(Icons.lock, 'Own Your Content',
                              'Post short blogs on a decentralized platform.'),
                          _renderInfo(
                              Icons.sentiment_satisfied_alt,
                              'Engage with Diverse Communities',
                              'Connect with a global community of content creators.'),
                          _renderInfo(Icons.speed, 'Post in Seconds',
                              'Share quickly using our simple, fast interface.'),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _renderConsent(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isConsentChecked ? _handleButtonPress : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text(
                          'Get Started', // Replace with localized text
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
