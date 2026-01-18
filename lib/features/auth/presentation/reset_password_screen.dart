import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone; // Received from previous screen

  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthRepository _authRepo = AuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // 1. LOGIC: Reset Password
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await _authRepo.resetPassword(
      widget.phone,
      _otpController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed! Please login."), backgroundColor: Colors.green),
      );
      // Navigate to Login and clear stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
    }
  }

  // 2. LOGIC: Resend OTP
  Future<void> _handleResendOtp() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sending OTP...")));

    final response = await _authRepo.sendForgotPasswordOtp(widget.phone);

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Resent successfully!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Colors.red),
        );
      }
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
                Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Enter the OTP sent to your phone and choose a new password.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40.h),

                // OTP FIELD
                Text(
                  "Enter OTP",
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: _inputDecoration(
                    hint: "6-digit code",
                    prefixIcon: Icons.sms_outlined,
                  ).copyWith(counterText: ""),
                  validator: (val) => (val == null || val.length != 6) ? "Enter valid 6-digit OTP" : null,
                ),

                SizedBox(height: 24.h),

                // PASSWORD FIELD
                Text(
                  "Enter New Password",
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: _inputDecoration(
                    hint: "At least 8 characters",
                    prefixIcon: Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => (val == null || val.length < 6) ? "Password too short" : null,
                ),

                SizedBox(height: 30.h),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 5,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Update Password",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),

                SizedBox(height: 180.h), // Spacer

                // FOOTER
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the OTP? ",
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: _handleResendOtp,
                        child: Text(
                          "Resend code",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp),
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

  InputDecoration _inputDecoration({required String hint, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
      prefixIcon: Icon(prefixIcon, color: Colors.grey[500], size: 22.sp),
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
    );
  }
}