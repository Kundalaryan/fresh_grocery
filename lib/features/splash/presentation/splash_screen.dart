import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Start the robust initialization logic
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Wait for 2 seconds AND check storage
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      StorageService().getToken(),
    ]);

    final token = results[1] as String?;

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // CASE A: User HAS token -> Go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // CASE B: No token -> Go to About Us / Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AboutUsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent to match the clean design
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        // USE THE NEW COLOR
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.flash_on_rounded,
                      size: 50,
                      color: AppColors.primary, // USE THE NEW COLOR
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Font is automatically Jakarta Sans because of main.dart
                const Text(
                  "FastGoods",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700, // Bold in Jakarta Sans
                    color: AppColors.textBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Groceries in minutes",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary, // USE THE NEW COLOR
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      // USE THE NEW COLOR
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "v1.0.2",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
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
