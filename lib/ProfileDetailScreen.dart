import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({
    Key? key,
    required String nama,
    required String email,
    required String phone,
  }) : super(key: key);

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('https://payuni-app.findig.id/api/v1/user/info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 200) {
        setState(() {
          userInfo = data['data'];
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Text(title,
                  style: const TextStyle(color: Colors.black54))),
          Expanded(
              flex: 5,
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userInfo == null
          ? const Center(child: Text('Gagal memuat data profil'))
          : Column(
        children: [
          // Header
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFF9D4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Detail Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person,
                        size: 50, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Konten Profil
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline,
                            color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text('Informasi Pengguna',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildRow('Nama', userInfo!['nama'] ?? ''),
                    buildRow('Email', userInfo!['email'] ?? ''),
                    buildRow('No HP', userInfo!['phone'] ?? ''),
                    buildRow(
                        'Provinsi', userInfo!['id_propinsi'] ?? ''),
                    buildRow(
                        'Kabupaten', userInfo!['id_kabupaten'] ?? ''),
                    buildRow(
                        'Kecamatan', userInfo!['id_kecamatan'] ?? ''),
                    buildRow('Alamat', userInfo!['alamat'] ?? ''),
                    buildRow('Nama Toko',
                        userInfo!['toko']?['nama'] ?? '-'),
                    buildRow('Alamat Toko',
                        userInfo!['toko']?['alamat'] ?? '-'),
                    buildRow('NIK', userInfo!['kyc']?['nik'] ?? '-'),
                    buildRow('Keterangan KYC',
                        userInfo!['kyc']?['keterangan'] ?? '-'),
                    buildRow('Status KYC',
                        userInfo!['kyc']?['status'].toString() ?? '-'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
