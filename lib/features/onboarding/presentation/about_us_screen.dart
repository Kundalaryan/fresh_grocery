import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT ADDED
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/signup_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use SafeArea to avoid notches and status bars
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),

              // 1. TOP LOGO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/logo-back.png",
                    width: 80.w, // Adjusted size to fit the header
                    height: 80.w,
                  ),
                  SizedBox(width: 10.w),
                  // Text(
                  //   "GetIt", // Kept your project name
                  //   style: TextStyle(
                  //     fontSize: 24.sp,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  // ),
                ],
              ),

              const Spacer(flex: 2), // Pushes content to visual center
              // 2. MAIN HEADLINE
              Text(
                "Essentials\ndelivered simply.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42.sp, // Large bold text
                  height: 1.1, // Tighter line height
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -1.0,
                ),
              ),

              SizedBox(height: 40.h),

              // 3. ABOUT US LABEL
              Text(
                "ABOUT US",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary, // #135bec
                  letterSpacing: 1.5, // Spaced out letters
                ),
              ),

              SizedBox(height: 16.h),

              // 4. SUB-HEADLINE
              Text(
                "Minimalism in motion.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 16.h),

              // 5. DESCRIPTION TEXT
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                child: Text(
                  "We strip away the noise to bring you fresh groceries and daily goods with absolute efficiency. Quality products, smooth experience, zero clutter.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.5,
                    color: const Color(0xFF666666), // Soft grey
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // 6. FEATURES LIST (Bullet points)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureItem("Fast"),
                  _buildDot(),
                  _buildFeatureItem("Fresh"),
                  _buildDot(),
                  _buildFeatureItem("Simple"),
                ],
              ),

              const Spacer(flex: 3), // Pushes buttons to bottom area
              // 7. SIGN UP BUTTON (Outlined)
              SizedBox(
                width: double.infinity,
                height: 56.h, // Tall, modern button
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // 8. LOGIN BUTTON (Text only)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // 9. FOOTER TEXT
              Text(
                "Terms of Service and Privacy Policy apply.",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the features "Fast", "Fresh", etc.
  Widget _buildFeatureItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  // Helper widget for the small grey dot
  Widget _buildDot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0.w),
      child: Container(
        width: 4.w,
        height: 4.w, // Keep square aspect ratio
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
