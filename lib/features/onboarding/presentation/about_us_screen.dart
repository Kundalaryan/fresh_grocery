import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // 1. TOP LOGO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag, // Simple black bag icon
                    color: Colors.black,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "FastGoods", // Kept your project name
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2), // Pushes content to visual center

              // 2. MAIN HEADLINE
              Text(
                "Essentials\ndelivered simply.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42, // Large bold text
                  height: 1.1, // Tighter line height
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -1.0,
                ),
              ),

              const SizedBox(height: 40),

              // 3. ABOUT US LABEL
              Text(
                "ABOUT US",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary, // #135bec
                  letterSpacing: 1.5, // Spaced out letters
                ),
              ),

              const SizedBox(height: 16),

              // 4. SUB-HEADLINE
              Text(
                "Minimalism in motion.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // 5. DESCRIPTION TEXT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "We strip away the noise to bring you fresh groceries and daily goods with absolute efficiency. Quality products, smooth experience, zero clutter.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: const Color(0xFF666666), // Soft grey
                  ),
                ),
              ),

              const SizedBox(height: 32),

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
                height: 56, // Tall, modern button
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 8. LOGIN BUTTON (Text only)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 9. FOOTER TEXT
              Text(
                "Terms of Service and Privacy Policy apply.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 10),
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
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  // Helper widget for the small grey dot
  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}