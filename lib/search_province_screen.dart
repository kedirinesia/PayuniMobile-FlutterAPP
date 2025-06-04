import 'package:flutter/material.dart';

class SearchProvinceScreen extends StatefulWidget {
  @override
  _SearchProvinceScreenState createState() => _SearchProvinceScreenState();
}

class _SearchProvinceScreenState extends State<SearchProvinceScreen> {
  final List<String> allProvinces = [
    "Aceh", "Sumatera Utara", "Sumatera Barat", "Riau", "Jambi",
    "Sumatera Selatan", "Bengkulu", "Lampung", "Kepulauan Riau",
    "Kepulauan Bangka Belitung", "Dki Jakarta", "Jawa Barat",
    "Jawa Tengah", "Di Yogyakarta", // tambahkan lainnya sesuai kebutuhan
  ];

  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = allProvinces
        .where((prov) => prov.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Provinsi"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => query = val),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Cari Provinsi",
              contentPadding: EdgeInsets.all(16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filtered[index]),
                  onTap: () => Navigator.pop(context, filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
