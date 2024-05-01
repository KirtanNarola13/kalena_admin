import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalena_admin/screens/allProducts/components/edit_product.dart';
import 'package:kalena_admin/screens/nav_bar/views/nav_bar.dart';
import 'package:kalena_admin/screens/splash_screen/view/splash.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/nav_bar', page: () => NavBar()),
        // GetPage(name: '/edit_product', page: () => EditProduct()),
      ],
    ),
  );
}
