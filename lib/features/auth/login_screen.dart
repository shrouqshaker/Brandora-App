import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:winterproject/features/auth/role_selection_screen.dart';
import 'package:winterproject/home/main_screen.dart';
import 'package:winterproject/home/data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Color primaryColor = const Color(0xFF3F51B5);
  final Color backgroundColor = const Color(0xFFF6F8FB);
  final Color textColor = const Color(0xFF1E232C);
  final Color greyTextColor = const Color(0xFF8391A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.campaign,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Brandora',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Text(
                    isLogin ? 'Welcome Back' : 'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isLogin
                        ? 'Login to your Brandora account'
                        : 'Sign up for a new Brandora account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: greyTextColor),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildTextField(
                    hintText: 'name@example.com',
                    prefixIcon: Icons.email_outlined,
                    controller: emailController,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildTextField(
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    controller: passwordController,
                    isPassword: true,
                  ),

                  if (isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        if (isLogin) {
                          // LOGIN
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          if (!context.mounted) return;
                          final userData = Provider.of<UserData>(context, listen: false);
                          await userData.fetchProfile();

                          if (!context.mounted) return;
                          Navigator.pop(context); // Close loading dialog

                          if (userData.error != null) {
                            // Show error but still try to navigate based on best guess
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Server error: ${userData.error}. Please try again."),
                                backgroundColor: Colors.red[700],
                                duration: const Duration(seconds: 4),
                              ),
                            );
                            // Sign out so user can try again cleanly
                            await FirebaseAuth.instance.signOut();
                            return;
                          }

                          if (userData.hasSelectedRole) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainScreen()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                            );
                          }
                        } else {
                          // REGISTER
                          String email = emailController.text.trim();
                          String password = passwordController.text.trim();

                          if (email.contains(' ') || password.contains(' ')) {
                             Navigator.pop(context);
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No spaces allowed")));
                             return;
                          }

                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          if (!context.mounted) return;
                          final userData = Provider.of<UserData>(context, listen: false);
                          await userData.fetchProfile(); // Creates profile in DB

                          if (!context.mounted) return;
                          Navigator.pop(context); // Close loading dialog

                          if (userData.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Account created but profile sync failed: ${userData.error}"),
                                backgroundColor: Colors.orange[700],
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                          
                          // Always navigate to role selection after registration
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        if (!context.mounted) return;
                        Navigator.pop(context); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? "Authentication Failed")),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        Navigator.pop(context); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Unexpected error: $e")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLogin ? 'Sign In' : 'Sign Up',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: TextStyle(color: greyTextColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLogin = !isLogin;
                            emailController.clear();
                            passwordController.clear();
                          });
                        },
                        child: Text(
                          isLogin ? 'Sign up' : 'Sign in',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return isPassword ? "Password is required" : "Email is required";
          }
          if (!isPassword) {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return "Enter a valid email";
            }
          }
          if (isPassword && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}