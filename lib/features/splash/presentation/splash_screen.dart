import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- CHANGED: Removed Container/Shadow, just showing Big Logo ---
                Image.asset(
                  "assets/icons/logo-back.png",
                  width: 160.w, // Increased size (was 100)
                  height: 160.w,
                  fit: BoxFit.contain,
                ),
                // -----------------------------------------------------------

                SizedBox(height: 30.h), // Adjusted spacing

                // Text(
                //   "GetIt",
                //   style: TextStyle(
                //     fontSize: 32.sp,
                //     fontWeight: FontWeight.w700,
                //     color: AppColors.textBlack,
                //     letterSpacing: -0.5,
                //   ),
                // ),
                SizedBox(height: 8.h),

                Text(
                  "Groceries in minutes",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 150.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "v1.0.0",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}