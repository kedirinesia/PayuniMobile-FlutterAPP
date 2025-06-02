import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payuniapp/validateOTP.dart';


class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String loginValidateId;

  const OtpVerificationScreen({
    Key? key,
    required this.phone,
    required this.loginValidateId,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool _isLoading = false;

  Future<void> sendOtpAndNavigate(String type) async {
    setState(() => _isLoading = true);

    final url = Uri.parse('https://payuni-app.findig.id/api/v1/user/login/send-otp');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'validate_id': widget.loginValidateId,
      'type': type,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 && data['status'] == 200) {
        final sendOtpValidateId = data['validate_id'] ?? data['data']?['validate_id'];
        if (sendOtpValidateId == null || sendOtpValidateId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Validate ID dari server kosong')),
          );
          setState(() => _isLoading = false);
          return;
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ValidateOtpScreen(
              phone: widget.phone,
              validateIdFromSendOtp: sendOtpValidateId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal kirim OTP')),
        );
      }

    } catch (e) {
      print('Terjadi kesalahan: $e');
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
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Kirim OTP ke ${widget.phone}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.sms),
                label: const Text('Kirim via SMS'),
                onPressed: _isLoading ? null : () => sendOtpAndNavigate('sms'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('Kirim via WhatsApp'),
                onPressed: _isLoading ? null : () => sendOtpAndNavigate('whatsapp'),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
