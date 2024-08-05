import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Timer(
        const Duration(
          seconds: 3,
        ), () {
      Get.offNamedUntil(
        '/nav_bar',
        (route) => false,
      );
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(),
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/kalena_mart.png',
            ),
          ),
          const Spacer(),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
