import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_repository.dart';
import '../models/signup_request.dart';
import 'login_screen.dart'; // To navigate to Login

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  // State
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
      password: _passwordController.text,
      address: _addressController.text.trim(),
    );

    // Call API
    final response = await _authRepo.register(request);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created! Please Login.")),
      );
      // Redirect to Login Page after success
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
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // 1. HEADLINE WITH COLORED TEXT
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                    children: [
                      const TextSpan(text: "Fresh Groceries\n"),
                      TextSpan(
                        text: "In Minutes",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. SUBTITLE
                Text(
                  "Create an account to start your fresh delivery journey.",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                // 3. PHONE INPUT
                _buildLabel("Phone Number"),
                _buildTextField(
                  controller: _phoneController,
                  hint: "+91 98765 43210",
                  icon: Icons.phone_in_talk_outlined,
                  inputType: TextInputType.phone,
                ),

                // 4. NAME INPUT
                _buildLabel("Name"),
                _buildTextField(
                  controller: _nameController,
                  hint: "Full Name",
                  icon: Icons.person_outline,
                  inputType: TextInputType.name,
                ),

                // 5. ADDRESS INPUT
                _buildLabel("Address"),
                _buildTextField(
                  controller: _addressController,
                  hint: "Delivery Address",
                  icon: Icons.location_on_outlined, // Pin icon
                  inputType: TextInputType.streetAddress,
                ),

                // 6. PASSWORD INPUT
                _buildLabel("Password"),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(fontSize: 16),
                  decoration: _inputDecoration(
                    hint: "Create a password",
                    prefixIcon: null, // No prefix in your design for password? Or maybe lock?
                    // Design shows no prefix, but I'll add lock for consistency if needed.
                    // Let's stick to design: No prefix icon shown in image for password, only suffix.
                    // Actually, let's keep it consistent with other fields or empty.
                    // If we strictly follow the image, there is no prefix icon for password.
                  ).copyWith(
                    // Override to add toggle
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val!.length < 6 ? 'Password too short' : null,
                ),

                const SizedBox(height: 20),

                // 7. CHECKBOX & TERMS
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          setState(() => _agreedToTerms = val ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 13),
                          children: [
                            const TextSpan(text: "I agree to the "),
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 8. SIGN UP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 9. FOOTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Label above text fields
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  // Helper: Common Text Field Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: TextStyle(fontSize: 16),
      decoration: _inputDecoration(
        hint: hint,
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 22), // Right side icon in your design?
        // Note: Your design shows icons on the RIGHT for Phone/Person/Location.
        // Let's adjust styles to match the image exactly (Icons at the End).
      ).copyWith(
        prefixIcon: null, // Remove default prefix
        suffixIcon: Icon(icon, color: Colors.grey[500], size: 22), // Add to end
      ),
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
    );
  }

  // Helper: Decoration Style
  InputDecoration _inputDecoration({
    required String hint,
    Icon? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F9FE), // Light bluish-grey background from design
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border by default in design
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}