import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_fresh/features/auth/presentation/reset_password_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthRepository _authRepo = AuthRepository();

  bool _isLoading = false;

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Call API
    final response = await _authRepo.sendForgotPasswordOtp(_phoneController.text.trim());

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success) {
      // SUCCESS: Show Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(phone: _phoneController.text.trim()),
        ),
      );

    } else {
      // ERROR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // 1. HEADLINE
                Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12.h),

                // 2. SUBTITLE
                Text(
                  "Enter your registered phone number to reset your password.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 40.h),

                // 3. PHONE INPUT
                Text(
                  "Phone Number",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: InputDecoration(
                    hintText: "+91 98765 43210",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
                    prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[500], size: 22.sp),
                    counterText: "", // Hide length counter
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(18.r),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Phone is required';
                    if (value.length != 10) return 'Phone must be 10 digits';
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Enter valid numbers only';
                    return null;
                  },
                ),

                SizedBox(height: 30.h),

                // 4. ACTION BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 5,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 250.h), // Spacer to push bottom text down

                // 5. FOOTER
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Remembered your password? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // Back to Login
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}