import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_mobile_apps/screens/delivery_order/delivery_order_screen.dart';
import 'package:my_mobile_apps/service/api.dart';
import 'package:my_mobile_apps/service/auth/authService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false; // Track loading state

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    // print(jsonEncode({
    //   'username': _usernameController.text.trim(),
    //   'password': _passwordController.text.trim(),
    // }));
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });

      try {
        final url = Uri.parse("$myUrl/api/login");
        final response = await http.post(
          url,
          body: jsonEncode({
            'username': _usernameController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        setState(() {
          _isLoading = false;
        });
        print(response.body);
        // return;
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);

          String token = responseData['token'];
          print(token);
          await AuthService.saveToken(token);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const DeliveryOrderScreen()),
          );
        } else {
          // Error handling for failed login
          // Show snackbar or dialog with error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print(e.toString());
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Do your best today!'),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        hintText: 'Enter your username',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(double.infinity, 48),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator() // Show loading indicator
                    : const Text('Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
