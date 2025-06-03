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
              contactMethod: type == 'email' ? 'email' : 'phone',
              contactInfo: widget.phone,
              validateId: data['validate_id'] ?? data['data']['validate_id'],
            ),
          ),
        );


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal kirim OTP')),
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
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Verifikasi OTP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kirim OTP ke ${widget.phone}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.email),
                          label: const Text('Kirim via Email'),
                          onPressed: _isLoading ? null : () => sendOtpAndNavigate('email'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Kirim via WhatsApp'),
                          onPressed: _isLoading ? null : () => sendOtpAndNavigate('whatsapp'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ],
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
