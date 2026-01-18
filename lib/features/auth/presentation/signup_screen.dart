import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_repository.dart';
import '../models/signup_request.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // NEW CONTROLLER
  final _passwordController = TextEditingController();

  String? _selectedAddress;

  final List<String> _addressOptions = [
    "Bishna",
    "Jammu",
    "Samba",
    "Kathua",
    "Udhampur",
    "R.S. Pura",
    "Gandhi Nagar",
    "Trikuta Nagar"
  ];

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  final _formKey = GlobalKey<FormState>();

  final AuthRepository _authRepo = AuthRepository();

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms & Privacy Policy")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = SignUpRequest(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(), // PASS EMAIL
      password: _passwordController.text,
      address: _selectedAddress!,
    );

    final response = await _authRepo.register(request);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created! Please Login.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
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
        centerTitle: true,
        title: Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),

                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                    children: [
                      const TextSpan(text: "Fresh Groceries\n"),
                      TextSpan(
                        text: "In Minutes",
                        style: TextStyle(color: AppColors.primary, fontSize: 28.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                Text(
                  "Create an account to start your fresh delivery journey.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 30.h),

                // 1. PHONE INPUT
                _buildLabel("Phone Number"),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: _inputDecoration(
                    hint: "9876543210",
                  ).copyWith(
                    counterText: "",
                    suffixIcon: Icon(Icons.phone_in_talk_outlined, color: Colors.grey[500], size: 22.sp),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    if (val.length != 10) return "Must be 10 digits";
                    if (!RegExp(r'^[0-9]+$').hasMatch(val)) return 'Digits only';
                    return null;
                  },
                ),

                // 2. NAME INPUT
                _buildLabel("Name"),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: _inputDecoration(hint: "Full Name").copyWith(
                    suffixIcon: Icon(Icons.person_outline, color: Colors.grey[500], size: 22.sp),
                  ),
                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                ),

                // 3. EMAIL INPUT (NEW)
                _buildLabel("Email"),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: _inputDecoration(hint: "example@mail.com").copyWith(
                    suffixIcon: Icon(Icons.email_outlined, color: Colors.grey[500], size: 22.sp),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    // REGEX FOR EMAIL VALIDATION
                    final bool emailValid =
                    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val);
                    if (!emailValid) return "Enter a valid email";
                    return null;
                  },
                ),

                // 4. ADDRESS INPUT
                _buildLabel("Address"),
                DropdownButtonFormField<String>(
                  value: _selectedAddress,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  decoration: _inputDecoration(hint: "Select your location").copyWith(
                    suffixIcon: null,
                    prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[500], size: 22.sp),
                  ),
                  items: _addressOptions.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAddress = newValue;
                    });
                  },
                  validator: (value) => value == null ? "Please select an address" : null,
                ),

                // 5. PASSWORD INPUT
                _buildLabel("Password"),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignUp(),
                  style: TextStyle(fontSize: 16.sp),
                  decoration: _inputDecoration(
                    hint: "Create a password",
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 22.sp,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val!.length < 6 ? 'Password too short' : null,
                ),

                SizedBox(height: 20.h),

                // CHECKBOX
                Row(
                  children: [
                    SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                        onChanged: (val) {
                          setState(() => _agreedToTerms = val ?? false);
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                              fontSize: 13.sp
                          ),
                          children: [
                            const TextSpan(text: "I agree to the "),
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.h),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // FOOTER
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0.h),
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
      filled: true,
      fillColor: const Color(0xFFF8F9FE),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}