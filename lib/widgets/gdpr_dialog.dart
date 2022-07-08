import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:images_app/data/data_shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const _actionButtonTextStyle = TextStyle(
  color: Colors.red,
);

class GdprDialog extends StatelessWidget {
  const GdprDialog({Key? key, required this.callback}) : super(key: key);

  final Function callback;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Privacy Policy"),
      content: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: "By using this app you are agree to our ",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            TextSpan(
                text: "privacy policy",
                style: const TextStyle(
                  color: Colors.red,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    const url =
                        "https://pages.flycricket.io/tortuga-play-wallpap-0/privacy.html";
                    if (!await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    )) {
                      // couldn't launch url
                    }
                  }),
          ],
        ),
      ),
      // Text("By using this app you are agree to our privacy policy"),
      actions: [
        TextButton(
          onPressed: () async {
            await DataSharedPreferences.setIsFirstTime(false);
            await DataSharedPreferences.setShowPersonalizedAds(false);
            callback();
            Navigator.pop(context);
          },
          child: const Text(
            "Disagree",
            style: _actionButtonTextStyle,
          ),
        ),
        TextButton(
          onPressed: () async {
            await DataSharedPreferences.setIsFirstTime(false);
            await DataSharedPreferences.setShowPersonalizedAds(true);
            callback();
            Navigator.pop(context);
          },
          child: const Text(
            "Agree",
            style: _actionButtonTextStyle,
          ),
        ),
      ],
    );
  }
}
