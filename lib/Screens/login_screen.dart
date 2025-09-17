import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/Screens/employee_screens/employee_complaint_view_screen.dart';
import 'package:smart_nagarpalika/Screens/homeScreen.dart';
import 'package:smart_nagarpalika/Screens/singnup-screen.dart';
import 'package:smart_nagarpalika/Services/auth_services.dart';
import 'package:smart_nagarpalika/Services/logger_service.dart';
import 'package:smart_nagarpalika/provider/auth_provider.dart';
import 'package:smart_nagarpalika/provider/employee/employee_auth_details_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool isEmployeeMode;
  const LoginScreen({super.key, this.isEmployeeMode = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Add loading state

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Move login logic outside build method
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final username = _usernameController.text.trim();
        final password = _passwordController.text.trim();

        LoggerService.instance.info(
          'Attempting login with username: $username',
        );
        LoggerService.instance.debug(
          'Mode: ${widget.isEmployeeMode ? "Employee" : "Citizen"}',
        );

        final authService = AuthService();
        final loginResponse = await authService.login(username, password);

        if (loginResponse != null) {
          final role = loginResponse.role;
          LoggerService.instance.info('Login successful! Role: $role');

          // Enforce mode vs role matching
          final isEmployeeRole = role == "ROLE_EMPLOYEE";
          final isUserRole = role == "ROLE_USER";
          ref.read(authProvider.notifier).state = AuthState(
            username: username,
            password: password,
          );
          if (widget.isEmployeeMode && isEmployeeRole) {
            LoggerService.instance.debug(
              'Employee details: ${loginResponse.employeeDetails}',
            );
            // Store employee details globally for later use
            ref.read(employeeDetailsProvider.notifier).state =
                loginResponse.employeeDetails;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => EmployeeComplaintViewScreen()),
            );
          } else if (!widget.isEmployeeMode && isUserRole) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else {
            // Mismatch: show guidance via SnackBar
            final message = widget.isEmployeeMode
                ? 'Citizen account detected. Switch to Citizen mode to sign in.'
                : 'Employee account detected. Switch to Employee mode to sign in.';
            LoggerService.instance.warning(
              'Role/mode mismatch: mode=' +
                  (widget.isEmployeeMode ? 'Employee' : 'Citizen') +
                  ', role=' +
                  role,
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        } else {
          _showErrorDialog("Invalid credentials. Please try again.");
        }
      } catch (e) {
        LoggerService.instance.error('Login error: $e');
        _showErrorDialog(
          "Login failed. Please check your connection and try again.",
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Logo/Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isEmployeeMode
                              ? Icons.work
                              : Icons.account_circle,
                          size: 48,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        widget.isEmployeeMode
                            ? 'Employee Login'
                            : 'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isEmployeeMode
                            ? 'Sign in to employee portal'
                            : 'Sign in to your account',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: widget.isEmployeeMode
                              ? 'Employee ID'
                              : 'Username',
                          hintText: widget.isEmployeeMode
                              ? 'Enter your employee ID'
                              : 'Enter your username',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.blue[600],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue[600]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return widget.isEmployeeMode
                                ? 'Please enter your employee ID'
                                : 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icon(Icons.lock, color: Colors.blue[600]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blue[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue[600]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text('Logging in...'),
                                  ],
                                )
                              : Text(
                                  widget.isEmployeeMode
                                      ? 'Employee Login'
                                      : 'Login',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Forgot Password Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // TODO: Implement forgot password
                                  },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 16,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // TODO: Implement sign up / another
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SignupScreen(),
                                      ),
                                    );
                                  },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontSize: 16,
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
        ),
      ),
    );
  }
}
