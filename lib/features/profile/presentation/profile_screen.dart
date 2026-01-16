import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT ADDED
import 'package:google_fonts/google_fonts.dart'; // Keep if used globally, else remove

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../../onboarding/presentation/about_us_screen.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();

  // State Variables
  bool _isSendingFeedback = false;
  String _userName = "Loading...";

  // Controllers
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final response = await _repository.getUserName();
    if (mounted) {
      setState(() {
        if (response.success && response.data != null) {
          _userName = response.data!;
        } else {
          _userName = "User";
        }
      });
    }
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)), // Adaptive
              title: Text("Edit Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
              content: TextField(
                controller: nameController,
                style: TextStyle(fontSize: 16.sp),
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                    final text = nameController.text.trim();
                    if (text.isEmpty) return;

                    setStateDialog(() => isUpdating = true);

                    final response = await _repository.updateUserName(text);

                    if (context.mounted) {
                      Navigator.pop(context);

                      if (response.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Name updated!"), backgroundColor: Colors.green),
                        );
                        _fetchUserName();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response.message), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: isUpdating
                      ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    await StorageService().deleteToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AboutUsScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp, // Adaptive Font
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.r), // Adaptive Padding
        child: Column(
          children: [
            // --- 1. PROFILE HEADER ---
            Center(
              child: Column(
                children: [
                  SizedBox(height: 10.h), // Adaptive Height

                  // --- CLICKABLE NAME ROW ONLY ---
                  GestureDetector(
                    onTap: _showEditNameDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 26.sp, // Adaptive Font
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.edit, size: 20.sp, color: AppColors.primary), // Adaptive Icon
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h), // Increased spacing after header

            // --- 2. FEEDBACK CARD ---
            _buildSectionCard(
              title: "Feedback & Suggestions",
              icon: Icons.chat_bubble,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(12.r), // Adaptive Radius
                    ),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      style: TextStyle(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: "Tell us how we can improve...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.r), // Adaptive Padding
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 40.h, // Adaptive Height
                      child: ElevatedButton(
                        onPressed: _isSendingFeedback
                            ? null
                            : () async {
                          final text = _feedbackController.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please write a suggestion first")),
                            );
                            return;
                          }
                          setState(() => _isSendingFeedback = true);
                          final response = await _repository.submitSuggestion(text);
                          if (mounted) {
                            setState(() => _isSendingFeedback = false);
                            if (response.success) {
                              _feedbackController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Thank you! Feedback sent."), backgroundColor: Colors.green),
                              );
                              FocusManager.instance.primaryFocus?.unfocus();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response.message), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: _isSendingFeedback
                            ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 2))
                            : Text(
                          "Send Feedback",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // --- 3. SECURITY CARD ---
            _buildSectionCard(
              title: "Security",
              icon: Icons.lock,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Current Password"),
                  _buildPasswordField(_currentPassController, "••••••••"),
                  SizedBox(height: 16.h),
                  _buildLabel("New Password"),
                  _buildPasswordField(_newPassController, "Enter new password"),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Call Update Password API
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        "Update Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // --- 4. LOGOUT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: Icon(Icons.logout, color: const Color(0xFFE53935), size: 22.sp),
                label: Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE53935),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade100),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),

            SizedBox(height: 20.h),
            Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20.r), // Adaptive Padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r), // Adaptive Radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}