import 'package:flutter/material.dart';


class SearchCityScreen extends StatefulWidget {
  final String province;
  const SearchCityScreen({required this.province});

  @override
  _SearchCityScreenState createState() => _SearchCityScreenState();
}

class _SearchCityScreenState extends State<SearchCityScreen> {
  final Map<String, List<String>> provinceToCities = {
    "Jawa Barat": ["Bandung", "Bogor", "Bekasi", "Depok"],
    "Dki Jakarta": ["Jakarta Pusat", "Jakarta Timur", "Jakarta Barat"],
    // Tambahkan sesuai kebutuhan
  };

  String query = "";

  @override
  Widget build(BuildContext context) {
    final cities = provinceToCities[widget.province] ?? [];
    final filtered = cities.where((city) => city.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Kota atau Kabupaten"), backgroundColor: Colors.deepPurple),
      body: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => query = val),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Cari Kota/Kabupaten",
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
