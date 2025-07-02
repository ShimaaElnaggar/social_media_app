import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/utils/image_utility.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  void navigate() {
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/sign-up');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Image.asset(
                  ImageUtility.logo,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Say hello to your new social space!',
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      // color: ColorUtility.primary,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
                totalRepeatCount: 1,
              ),
              Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
