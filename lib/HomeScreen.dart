import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'ProfileDetailScreen.dart';
import 'RewardScreen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nama = "";
  String phone = "";
  String email = "";
  int saldo = 0;
  int poin = 0;
  int komisi = 0;

  int _selectedIndex = 0;

  List<dynamic> menuPrabayar = [];
  List<dynamic> menuPascabayar = [];
  bool isLoadingMenu = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchMenus();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://payuni-app.findig.id/api/v1/user/info');
    final headers = {'Content-Type': 'application/json', 'Authorization': token};

    try {
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 200) {
        final userData = data['data'];
        setState(() {
          nama = userData['nama'] ?? "";
          phone = userData['phone'] ?? "";
          email = userData['email'] ?? "";
          saldo = userData['saldo'] ?? 0;
          poin = userData['poin'] ?? 0;
          komisi = userData['komisi'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Gagal ambil data profil: $e');
    }
  }

  void _showAllMenusDialog(List<dynamic> menus, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: menus.map((item) {
                return _MenuItemNetwork(
                  iconUrl: item['icon'],
                  label: item['name'],
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            )
          ],
        );
      },
    );
  }


  Future<void> _fetchMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://payuni-app.findig.id/api/v1/menu/1');
    final headers = {'Content-Type': 'application/json', 'Authorization': token};

    try {
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 200) {
        final menus = data['data'] as List;
        final prabayar = menus.where((m) => m['type'] == 1).toList();
        final pascabayar = menus.where((m) => m['type'] == 2).toList();

        setState(() {
          menuPrabayar = prabayar;
          menuPascabayar = pascabayar;
          isLoadingMenu = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal ambil menu: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  Widget _buildMenuSection(String title, List<dynamic> menuData) {
    // Batasi maksimal 6 item, lalu tambahkan 'Lainnya' jika lebih
    List<dynamic> displayMenus = menuData.length > 6 ? menuData.sublist(0, 6) : menuData;
    bool hasMore = menuData.length > 6;

    if (hasMore) {
      displayMenus.add({
        'name': 'Lainnya',
        'icon': 'https://dokumen.payuni.co.id/icon/payuni/lainnya.png',
        'isMore': true,
        'allMenus': menuData,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.8, // agar tinggi mencukupi
          children: displayMenus.map((item) {
            if (item['isMore'] == true) {
              return _MenuItemNetwork(
                iconUrl: item['icon'],
                label: item['name'],
                onTap: () {
                  _showAllMenusDialog(item['allMenus'], title);
                },
              );
            } else {
              return _MenuItemNetwork(
                iconUrl: item['icon'],
                label: item['name'],
              );
            }
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  Widget _buildShimmerGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(8, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 10,
                color: Colors.grey,
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selamat Datang,', style: TextStyle(fontSize: 16)),
                  Text(nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Image.asset(
                'assets/logo.png',
                height: 40,
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFF9D4DFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp $saldo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RewardScreen()),
                        );
                      },
                      child: Text('Payuni Points ($poin)'),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          _ActionIcon(icon: Icons.add_circle_outline, label: 'Top Up'),
                          _ActionIcon(icon: Icons.send, label: 'Transfer'),
                          _ActionIcon(icon: Icons.qr_code, label: 'QRIS'),
                          _ActionIcon(icon: Icons.history, label: 'History'),
                        ],
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),


          // Menu Prabayar
          isLoadingMenu
              ? _buildShimmerGrid()
              : _buildMenuSection('Menu Prabayar', menuPrabayar),

          // Menu Pascabayar
          isLoadingMenu
              ? _buildShimmerGrid()
              : _buildMenuSection('Menu Pascabayar', menuPascabayar),

          const SizedBox(height: 24),
          const Text('Belanja Makin Hemat!!!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('Dapetin diskon dan harga spesial nya di Payuni sekarang sebelum kehabisan!!!'),
          const SizedBox(height: 16),

          // Promo
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cashback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('15%'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top-Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Spesial Promo'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayat() => const Center(child: Text('Riwayat Transaksi'));
  Widget _buildProfil() => SingleChildScrollView(
    child: Column(
      children: [
        // Header background
        Container(
          height: 180,
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
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text(
            'Akun Saya',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        // Card Profil
        Transform.translate(
          offset: const Offset(0, -40),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(Icons.person, color: Colors.deepOrange, size: 36),
                ),
                const SizedBox(height: 10),
                Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(phone, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Premium User', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoItem('Saldo', 'Rp ${saldo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', Colors.blue),
                    _infoItem('Komisi', 'Rp $komisi', Colors.purple),
                    _infoItem('Poin', '$poin pts', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Menu Aksi
        const SizedBox(height: 16),
        _profileMenuTile(Icons.person, 'Profil Detail', Colors.deepPurple, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileDetailScreen(nama: nama, email: email, phone: phone),
            ),
          );
        }),
        _profileMenuTile(Icons.wallet_giftcard, 'Komisi', Colors.purple, () {}),
        _profileMenuTile(Icons.group_add, 'Undang Teman', Colors.teal, () {}),
        _profileMenuTile(Icons.people_alt, 'Downline', Colors.orange, () {}),
        _profileMenuTile(Icons.bar_chart, 'Laporan', Colors.blue, () {}),
        _profileMenuTile(Icons.print, 'Atur Printer', Colors.red, () {}),
        _profileMenuTile(Icons.pin, 'Ganti PIN', Colors.deepOrange, () {}),
        _profileMenuTile(Icons.store, 'Ubah Toko', Colors.green, () {}),
        _profileMenuTile(Icons.card_giftcard, 'Rewards', Colors.indigo, () {}),


        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    ),
  );


  Widget _profileMenuTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _infoItem(String title, String value, Color color) {
    return Column(
      children: [
        Icon(Icons.account_balance_wallet, color: color),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            _buildRiwayat(),
            _buildProfil(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Scan belum tersedia')),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.qr_code_scanner, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          iconSize: 20,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _MenuItemNetwork extends StatelessWidget {
  final String iconUrl;
  final String label;
  final VoidCallback? onTap;

  const _MenuItemNetwork({
    required this.iconUrl,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
              iconUrl,
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}


class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }
}
