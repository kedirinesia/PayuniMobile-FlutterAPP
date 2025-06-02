import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/aman.png",
      "title": "Aman",
      "desc": "Transaksi kamu dijamin aman dengan enkripsi tingkat tinggi."
    },
    {
      "image": "assets/harga.png",
      "title": "Harga Bersaing",
      "desc": "Harga pulsa dan tagihan lebih murah dari tempat lain."
    },
    {
      "image": "assets/terpercaya.png",
      "title": "Terpercaya",
      "desc": "Dipercaya oleh ribuan pengguna di seluruh Indonesia."
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _goToHome();
    }
  }

  void _goToHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemCount: onboardingData.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(onboardingData[index]["image"]!, height: 250),
                    const SizedBox(height: 40),
                    Text(
                      onboardingData[index]["title"]!,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      onboardingData[index]["desc"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20),
                width: _currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white, // Warna teks tombol
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == onboardingData.length - 1 ? "SELESAI" : "LANJUTKAN",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _goToHome,
                  child: const Text("LEWATI"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
