import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/models/admin.dart';
import 'package:uidesign/providers/admin_provider.dart';
import 'package:uidesign/screens/intro_screen.dart'; // Corrected typo: inro -> intro
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form Key for Validation
  bool _isLoading = false;
  bool _obscurePassword = true; // For password visibility toggle
  bool _emailTouched = false; // Track if the email field has been touched
  bool _passwordTouched = false; // Track if password field has been touched

  @override
  void initState() {
    super.initState();
    Animate.restartOnHotReload = true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginAdmin() async {
    if (_formKey.currentState!.validate()) {
      // Only proceed if form is valid
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      Admin? admin = await adminProvider.loginAdmin(email, password);

      setState(() {
        _isLoading = false;
      });

      if (admin != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IntroScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong email or password")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;
    return Scaffold(
    
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          // Limit width on larger screens
          padding: const EdgeInsets.all(24.0),
          child: Card(
            color: theme.colorScheme.surface,
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Admin Login",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(),
                    const SizedBox(height: 24),
                    TextFormField(
                       style: TextStyle(color: theme.colorScheme.onSurface),
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon: _emailTouched
                            ? ((_emailController.text.isNotEmpty &&
                                    _emailController.text.endsWith('@gmail.com'))
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.close, color: Colors.red))
                            : null, // No icon initially
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.endsWith('@gmail.com')) {
                          return 'Please enter a valid gmail email (@gmail.com)';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _emailTouched = true;
                          _formKey.currentState!.validate();
                        });
                      },
                    )
                        .animate()
                        .fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),
                    TextFormField(
                       style: TextStyle(color: theme.colorScheme.onSurface),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                         labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                                 color: theme.colorScheme.tertiary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _passwordTouched = true;
                          _formKey.currentState!.validate();
                        });
                      },
                    )
                        .animate()
                        .fadeIn(delay: 200.ms),
                    const SizedBox(height: 32),
                    _isLoading
                        ?  CircularProgressIndicator(color: theme.colorScheme.primaryContainer,)
                        : ElevatedButton(
                            onPressed: _loginAdmin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child:  Text("Login",
                                style: TextStyle(color: theme.colorScheme.inversePrimary,)),
                          )
                            .animate()
                            .slideY(
                                begin: 1,
                                end: 0,
                                duration: 500.ms,
                                curve: Curves.easeInOut), // Sliding effect
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}