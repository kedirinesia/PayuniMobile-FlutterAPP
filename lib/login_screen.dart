import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'OTPverification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('saved_phone');
    final savedPin = prefs.getString('saved_pin');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      setState(() {
        _phoneController.text = savedPhone ?? '';
        _pinController.text = savedPin ?? '';
        _rememberMe = rememberMe;
      });
    }
  }

  Future<void> _saveCredentials(String phone, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_phone', phone);
      await prefs.setString('saved_pin', pin);
    } else {
      await prefs.remove('saved_phone');
      await prefs.remove('saved_pin');
    }
    await prefs.setBool('remember_me', _rememberMe);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    setState(() => _isLoading = true);

    final url = Uri.parse('https://payuni-app.findig.id/api/v1/user/login');
    final headers = {
      'Content-Type': 'application/json',
      'merchantcode': '5e7b291771268f3dc3dd73c6',
    };
    final body = jsonEncode({'phone': phone, 'pin': pin});

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 200) {
        await _saveCredentials(phone, pin);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);


        final loginValidateId = data['data']['validate_id'] as String? ?? '';
        final phoneNumber = data['data']['phone'] as String? ?? phone;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phone: phoneNumber,
              loginValidateId: loginValidateId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  const SizedBox(height: 24),
                  const Text(
                    'Masuk ke Akun Anda',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor HP',
                      hintText: '08xxxxxxxxxx',
                      prefixIcon: const Icon(Icons.phone_android),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Nomor HP wajib diisi';
                      if (!RegExp(r'^08[0-9]{8,12}$').hasMatch(value)) return 'Nomor HP tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _pinController,
                    obscureText: _isObscure,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      hintText: '4 digit angka',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() => _isObscure = !_isObscure);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'PIN wajib diisi';
                      if (value.length < 4) return 'PIN minimal 4 angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() => _rememberMe = value!);
                        },
                      ),
                      const Text('Remember Me'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('MASUK', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
