import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';

class ValidateOtpScreen extends StatefulWidget {
  final String contactMethod; // 'email' atau 'phone'
  final String contactInfo; // Alamat email atau nomor telepon
  final String validateId;

  const ValidateOtpScreen({
    Key? key,
    required this.contactMethod,
    required this.contactInfo,
    required this.validateId,
  }) : super(key: key);

  @override
  State<ValidateOtpScreen> createState() => _ValidateOtpScreenState();
}

class _ValidateOtpScreenState extends State<ValidateOtpScreen> {
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  bool _isLoading = false;

  Future<void> verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP harus 4 digit')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('https://payuni-app.findig.id/api/v1/user/login/validate');
    final headers = {
      'Content-Type': 'application/json',
      'merchantcode': '5e7b291771268f3dc3dd73c6',
    };
    final body = jsonEncode({
      'phone': widget.contactInfo,
      'otp': otp,
      'validate_id': widget.validateId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 200) {
        final token = data['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifikasi berhasil')),
        );

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'OTP gagal diverifikasi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustrasi
              Image.asset(
                'assets/otp_illustration.png', // Pastikan file ilustrasi ini ada di folder assets Anda
                height: 200,
              ),
              const SizedBox(height: 32),
              // Judul dan Deskripsi
              const Text(
                'Masukkan OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kami akan mengirimkan anda 4 digit kode OTP untuk melanjutkan proses masuk, silakan pilih salah satu metode untuk menerima kode OTP dari kami',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              // Input OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _otpControllers[index],
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.purple, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Tombol Verifikasi
              ElevatedButton(
                onPressed: _isLoading ? null : verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verifikasi', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
