import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT ADDED

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/about_us_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      StorageService().getToken(),
    ]);

    final token = results[1] as String?;

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AboutUsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100.w, // Adaptive
                  height: 100.w, // Keep aspect ratio square
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r), // Adaptive Radius
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 20.r,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.flash_on_rounded,
                      size: 50.sp, // Adaptive Icon
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                Text(
                  "FastGoods",
                  style: TextStyle(
                    fontSize: 32.sp, // Adaptive Font
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  "Groceries in minutes",
                  style: TextStyle(
                    fontSize: 16.sp, // Adaptive Font
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40.h, // Adaptive Position
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 150.w, // Adaptive Width
                  height: 4.h, // Adaptive Height
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "v1.0.2",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.sp, // Adaptive Font
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}