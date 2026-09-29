import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const Lab7App());
}

class Lab7App extends StatelessWidget {
  const Lab7App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 7 - Form & Xác thực',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 93, 227, 52),
        ),
        useMaterial3: true,
      ),
      home: const RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isCheckingEmail = false;
  bool _emailAvailable = false;

  Timer? _emailCheckTimer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _emailCheckTimer?.cancel();

    super.dispose();
  }

  int _passwordStrength(String password) {
    if (password.isEmpty) {
      return 0;
    }

    int score = 0;

    if (password.length >= 8) {
      score++;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    return score;
  }

  String _passwordStrengthText(String password) {
    switch (_passwordStrength(password)) {
      case 1:
        return 'Rất yếu';
      case 2:
        return 'Yếu';
      case 3:
        return 'Trung bình';
      case 4:
        return 'Mạnh';
      case 5:
        return 'Rất mạnh';
      default:
        return '';
    }
  }

  Color _passwordStrengthColor(String password) {
    switch (_passwordStrength(password)) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _checkEmailAsync(String email) {
    _emailCheckTimer?.cancel();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      setState(() {
        _isCheckingEmail = false;
        _emailAvailable = false;
      });
      return;
    }

    setState(() {
      _isCheckingEmail = true;
      _emailAvailable = false;
    });

    _emailCheckTimer = Timer(
      const Duration(milliseconds: 800),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _isCheckingEmail = false;

          // Demo:
          // email chứa "used" sẽ được coi là đã tồn tại.
          _emailAvailable =
              !email.toLowerCase().contains('used');
        });
      },
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isCheckingEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đang kiểm tra email, vui lòng chờ...',
          ),
        ),
      );
      return;
    }

    if (!_emailAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email chưa được xác nhận khả dụng.',
          ),
        ),
      );
      return;
    }

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng ký thành công'),
          content: Text(
            'Xin chào ${_nameController.text}!\n\n'
            'Email: ${_emailController.text}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 7 - Đăng ký'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Điền thông tin bên dưới để đăng ký tài khoản.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // HỌ TÊN
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      hintText: 'Nhập họ và tên',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) {
                      _emailFocus.requestFocus();
                    },
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }

                      if (value.trim().length < 2) {
                        return 'Họ tên phải có ít nhất 2 ký tự';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@gmail.com',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      suffixIcon: _isCheckingEmail
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _emailController.text.isNotEmpty
                              ? Icon(
                                  _emailAvailable
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _emailAvailable
                                      ? Colors.green
                                      : Colors.red,
                                )
                              : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _checkEmailAsync(value);
                      setState(() {});
                    },
                    onFieldSubmitted: (_) {
                      _passwordFocus.requestFocus();
                    },
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }

                      final emailRegex = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      );

                      if (!emailRegex.hasMatch(
                        value.trim(),
                      )) {
                        return 'Email không hợp lệ';
                      }

                      if (!_isCheckingEmail &&
                          !_emailAvailable) {
                        return 'Email chưa được xác nhận khả dụng';
                      }

                      return null;
                    },
                  ),

                  if (_emailController.text.isNotEmpty &&
                      !_isCheckingEmail &&
                      _emailAvailable)
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 6,
                        left: 4,
                      ),
                      child: Text(
                        'Email có thể sử dụng',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  const SizedBox(height: 18),

                  // MẬT KHẨU
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    onFieldSubmitted: (_) {
                      _confirmPasswordFocus.requestFocus();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }

                      if (value.length < 8) {
                        return 'Mật khẩu phải có ít nhất 8 ký tự';
                      }

                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Mật khẩu phải có ít nhất 1 chữ hoa';
                      }

                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Mật khẩu phải có ít nhất 1 chữ thường';
                      }

                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Mật khẩu phải có ít nhất 1 chữ số';
                      }

                      return null;
                    },
                  ),

                  // ĐỘ MẠNH MẬT KHẨU
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value:
                                _passwordStrength(
                                      _passwordController.text,
                                    ) /
                                    5,
                            minHeight: 7,
                            borderRadius:
                                BorderRadius.circular(10),
                            color: _passwordStrengthColor(
                              _passwordController.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _passwordStrengthText(
                            _passwordController.text,
                          ),
                          style: TextStyle(
                            color: _passwordStrengthColor(
                              _passwordController.text,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Mật khẩu cần có ít nhất 8 ký tự, '
                      'chữ hoa, chữ thường và chữ số.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // XÁC NHẬN MẬT KHẨU
                  TextFormField(
                    controller:
                        _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                      hintText: 'Nhập lại mật khẩu',
                      prefixIcon: const Icon(
                        Icons.lock_reset,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) {
                      _submitForm();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }

                      if (value !=
                          _passwordController.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // ĐĂNG KÝ
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text(
                        'Đăng ký',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}