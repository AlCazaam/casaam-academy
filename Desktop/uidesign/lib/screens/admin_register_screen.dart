import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uidesign/models/admin.dart';
import '../Providers/admin_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminRegister extends StatefulWidget {
  const AdminRegister({super.key});

  @override
  State<AdminRegister> createState() => _AdminRegisterState();
}

class _AdminRegisterState extends State<AdminRegister> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AdminProvider _adminProvider = AdminProvider();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  Map<String, bool> _fieldTouched = {
    'fullname': false,
    'username': false,
    'email': false,
    'password': false,
  };

  @override
  void initState() {
    super.initState();
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.ring;
    Animate.restartOnHotReload = true;  // Good practice for development
  }

  void _registerAdmin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      EasyLoading.show(status: 'Registering...');

      String id = const Uuid().v4();
      DateTime now = DateTime.now();

      Admin admin = Admin(
        id: id,
        fullname: fullnameController.text,
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        description: "",
        imageUrl: "",
        dayAvailable: [],
        isShowInfo: true,
        createdAt: now,
        updatedAt: now,
      );

      try {
        await _adminProvider.registerAdmin(admin);
        EasyLoading.showSuccess('Admin registered successfully!');
        fullnameController.clear();
        usernameController.clear();
        emailController.clear();
        passwordController.clear();

        setState(() {
          _fieldTouched = {
            'fullname': false,
            'username': false,
            'email': false,
            'password': false,
          };
        });
      } catch (e) {
        EasyLoading.showError('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Registration", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Register as Admin",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms), // Fade-in on the title

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: fullnameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: _fieldTouched['fullname']!
                            ? (fullnameController.text.isNotEmpty
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.close, color: Colors.red))
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _fieldTouched['fullname'] = true;
                          _formKey.currentState!.validate();
                        });
                      },
                    ).animate().fadeIn(delay: 100.ms, duration: 500.ms), // Staggered fade-in

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.account_circle),
                        suffixIcon: _fieldTouched['username']!
                            ? (usernameController.text.isNotEmpty
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.close, color: Colors.red))
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _fieldTouched['username'] = true;
                          _formKey.currentState!.validate();
                        });
                      },
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms), // Staggered fade-in

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon: _fieldTouched['email']!
                            ? ((emailController.text.isNotEmpty && emailController.text.endsWith('@gmail.com'))
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.close, color: Colors.red))
                            : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!value.endsWith('@gmail.com')) {
                          return 'Please enter a valid gmail email (@gmail.com)';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _fieldTouched['email'] = true;
                          _formKey.currentState!.validate();
                        });
                      },
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms), // Staggered fade-in

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _fieldTouched['password'] = true;
                          _formKey.currentState!.validate();
                        });
                      },
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms), // Staggered fade-in

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _registerAdmin();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Register", style: TextStyle(color: Colors.white)),
                    ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeInOut), // Slide in button
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