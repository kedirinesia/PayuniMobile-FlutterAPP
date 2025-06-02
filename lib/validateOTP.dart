import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'HomeScreen.dart';



class ValidateOtpScreen extends StatefulWidget {
  final String phone;
  final String validateIdFromSendOtp;

  const ValidateOtpScreen({
    Key? key,
    required this.phone,
    required this.validateIdFromSendOtp,
  }) : super(key: key);

  @override
  State<ValidateOtpScreen> createState() => _ValidateOtpScreenState();
}

class _ValidateOtpScreenState extends State<ValidateOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> verifyOtp() async {
    final otp = _otpController.text.trim();
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
      'phone': widget.phone,
      'otp': otp,
      'validate_id': widget.validateIdFromSendOtp,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifikasi berhasil')),
        );

        // Navigasi ke HomeScreen dan hilangkan semua halaman sebelumnya
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
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Masukkan OTP ke ${widget.phone}'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : verifyOtp,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}
