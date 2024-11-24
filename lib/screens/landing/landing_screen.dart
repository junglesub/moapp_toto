import 'package:flutter/material.dart';
import 'package:moapp_toto/constants.dart';
import 'package:moapp_toto/widgets/custom_button.dart';
import 'package:moapp_toto/widgets/custom_full_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: Stack(
        children: [
          // Background Ellipse
          Positioned(
            bottom: -350,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(-22.82 * 3.141592653589793 / 180),
              child: Container(
                width: 662,
                height: 750,
                decoration: BoxDecoration(
                  color: Color(0xFF363536),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(662 / 2, 750 / 2),
                  ),
                ),
              ),
            ),
          ),
          // Foreground
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomFullWidthButton(
                    label: "구글로 계속",
                    height: 59,
                    padding: 48,
                    onPressed: () {
                      Navigator.pushNamed(context, '/signIn');
                    }),
                SizedBox(height: 32),
                Text(
                  "개발의 정석",
                  style: TextStyle(color: Color(0xBFFFFFFF)),
                ),
                SizedBox(height: 22)
              ],
            ),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TODAY,\nTOGETHER',
                  style: TextStyle(fontSize: 48),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 400)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
