import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _controller = PageController();
  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();
  String nama = '', email = '', noHp = '', pin = '', alamat = '';

  // Untuk payload (_id)
  String? selectedProvinsiId;
  String? selectedKabupatenId;
  String? selectedKecamatanId;

  // Untuk fetch path (id)
  String? selectedProvinsiApiId;
  String? selectedKabupatenApiId;

  List provinsiList = [], kabupatenList = [], kecamatanList = [];

  bool isAgreed = false;
  bool isLoading = false;

  String provinsiSearch = '', kabupatenSearch = '', kecamatanSearch = '';

  @override
  void initState() {
    super.initState();
    fetchProvinsi();
  }

  Future<void> fetchProvinsi() async {
    final response = await http.get(Uri.parse('https://payuni-app.findig.id/api/v1/propinsi/list'));
    if (response.statusCode == 200) {
      setState(() => provinsiList = jsonDecode(response.body)['data']);
    }
  }

  Future<void> fetchKabupaten(String idPropinsi) async {
    final response = await http.get(Uri.parse('https://payuni-app.findig.id/api/v1/propinsi/$idPropinsi/kabupaten'));
    if (response.statusCode == 200) {
      setState(() {
        kabupatenList = jsonDecode(response.body)['data'];
        selectedKabupatenId = null;
        selectedKabupatenApiId = null;
        selectedKecamatanId = null;
        kecamatanList = [];
        kabupatenSearch = '';
        kecamatanSearch = '';
      });
    }
  }

  Future<void> fetchKecamatan(String idKabupaten) async {
    final response = await http.get(Uri.parse('https://payuni-app.findig.id/api/v1/kabupaten/$idKabupaten/kecamatan'));
    if (response.statusCode == 200) {
      setState(() {
        kecamatanList = jsonDecode(response.body)['data'];
        selectedKecamatanId = null;
        kecamatanSearch = '';
      });
    }
  }

  List filterList(List list, String keyword) {
    if (keyword.isEmpty) return list;
    return list.where((item) => item['nama'].toString().toLowerCase().contains(keyword.toLowerCase())).toList();
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.deepPurple),
      ),
    );
  }

  void nextPage() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void prevPage() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void register() async {
    if (!isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Anda harus menyetujui syarat dan ketentuan')));
      return;
    }

    if (selectedProvinsiId == null || selectedKabupatenId == null || selectedKecamatanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pilih provinsi, kabupaten, dan kecamatan terlebih dahulu')));
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "name": nama,
      "email": email,
      "phone": noHp,
      "pin": int.tryParse(pin) ?? 0,
      "id_propinsi": selectedProvinsiId,
      "id_kabupaten": selectedKabupatenId,
      "id_kecamatan": selectedKecamatanId,
      "alamat": alamat
    };
    print("Payload yang dikirim ke API:");
    print(jsonEncode(body));

    final response = await http.post(
      Uri.parse("https://payuni-app.findig.id/api/v1/user/register"),
      headers: {
        "Content-Type": "application/json",
        "merchantCode": "5e7b291771268f3dc3dd73c6"
      },
      body: jsonEncode(body),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrasi berhasil')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrasi gagal')));
    }
  }

  Widget stepIndicator(int index, String label) {
    bool isActive = _currentStep == index;
    bool isCompleted = _currentStep > index;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isCompleted || isActive ? Colors.deepPurple : Colors.grey,
          child: isCompleted
              ? Icon(Icons.check, color: Colors.white, size: 14)
              : Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? Colors.deepPurple : Colors.grey, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrasi'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  stepIndicator(0, "Data Diri"),
                  stepIndicator(1, "Domisili"),
                  stepIndicator(2, "Konfirmasi"),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // Step 1
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: inputDecoration("Nama", Icons.person),
                          onSaved: (val) => nama = val ?? '',
                          validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: inputDecoration("Email", Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => email = val ?? '',
                          validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: inputDecoration("Nomor HP", Icons.phone),
                          keyboardType: TextInputType.phone,
                          onSaved: (val) => noHp = val ?? '',
                          validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: inputDecoration("PIN", Icons.lock),
                          obscureText: true,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          onSaved: (val) => pin = val ?? '',
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Wajib diisi';
                            if (val.length != 4) return 'PIN harus 4 digit';
                            return null;
                          },
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text("Batal"))),
                            SizedBox(width: 12),
                            Expanded(child: ElevatedButton(onPressed: nextPage, child: Text("Lanjut"))),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Step 2
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          decoration: inputDecoration("Cari Provinsi", Icons.search),
                          onChanged: (val) => setState(() => provinsiSearch = val),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: inputDecoration("Pilih Provinsi", Icons.location_on),
                          items: filterList(provinsiList, provinsiSearch).map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem(
                              value: item['_id'], // pakai _id untuk payload
                              child: Text(item['nama']),
                            );
                          }).toList(),
                          value: selectedProvinsiId,
                          onChanged: (val) {
                            setState(() {
                              selectedProvinsiId = val;
                              // cari 'id' untuk path API
                              selectedProvinsiApiId = provinsiList.firstWhere((e) => e['_id'] == val)['id'];
                              fetchKabupaten(selectedProvinsiApiId!);
                            });
                          },
                          validator: (val) => val == null ? 'Pilih provinsi' : null,
                        ),
                        SizedBox(height: 12),
                        TextField(
                          decoration: inputDecoration("Cari Kabupaten", Icons.search),
                          onChanged: (val) => setState(() => kabupatenSearch = val),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: inputDecoration("Pilih Kabupaten", Icons.location_city),
                          items: filterList(kabupatenList, kabupatenSearch).map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem(
                              value: item['_id'],
                              child: Text(item['nama']),
                            );
                          }).toList(),
                          value: selectedKabupatenId,
                          onChanged: (val) {
                            setState(() {
                              selectedKabupatenId = val;
                              selectedKabupatenApiId = kabupatenList.firstWhere((e) => e['_id'] == val)['id'];
                              fetchKecamatan(selectedKabupatenApiId!);
                            });
                          },
                          validator: (val) => val == null ? 'Pilih kabupaten' : null,
                        ),
                        SizedBox(height: 12),
                        TextField(
                          decoration: inputDecoration("Cari Kecamatan", Icons.search),
                          onChanged: (val) => setState(() => kecamatanSearch = val),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: inputDecoration("Pilih Kecamatan", Icons.map),
                          items: filterList(kecamatanList, kecamatanSearch).map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem(
                              value: item['_id'],
                              child: Text(item['nama']),
                            );
                          }).toList(),
                          value: selectedKecamatanId,
                          onChanged: (val) => setState(() => selectedKecamatanId = val),
                          validator: (val) => val == null ? 'Pilih kecamatan' : null,
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Expanded(child: OutlinedButton(onPressed: prevPage, child: Text("Kembali"))),
                            SizedBox(width: 12),
                            Expanded(child: ElevatedButton(onPressed: nextPage, child: Text("Lanjut"))),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Step 3 - Konfirmasi
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Text("Konfirmasi Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Text("Nama: $nama"),
                        Text("Email: $email"),
                        Text("No HP: $noHp"),
                        Text("PIN: $pin"),
                        Text("Provinsi: ${provinsiList.firstWhere((e) => e['_id'] == selectedProvinsiId, orElse: () => {'nama': '-'})['nama']}"),
                        Text("Kabupaten: ${kabupatenList.firstWhere((e) => e['_id'] == selectedKabupatenId, orElse: () => {'nama': '-'})['nama']}"),
                        Text("Kecamatan: ${kecamatanList.firstWhere((e) => e['_id'] == selectedKecamatanId, orElse: () => {'nama': '-'})['nama']}"),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(value: isAgreed, onChanged: (val) => setState(() => isAgreed = val ?? false)),
                            Expanded(child: Text("Saya setuju dengan syarat dan ketentuan")),
                          ],
                        ),
                        SizedBox(height: 12),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Row(
                          children: [
                            Expanded(child: OutlinedButton(onPressed: prevPage, child: Text("Kembali"))),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: register,
                                child: Text("Daftar"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
