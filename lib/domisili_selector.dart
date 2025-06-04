import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Domisili {
  final String id;
  final String nama;

  Domisili({required this.id, required this.nama});

  factory Domisili.fromJson(Map<String, dynamic> json) {
    return Domisili(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

class PilihDomisiliScreen extends StatefulWidget {
  final String title;
  final Future<List<Domisili>> Function() fetchData;
  final Function(Domisili) onSelected;

  const PilihDomisiliScreen({
    super.key,
    required this.title,
    required this.fetchData,
    required this.onSelected,
  });

  @override
  State<PilihDomisiliScreen> createState() => _PilihDomisiliScreenState();
}

class _PilihDomisiliScreenState extends State<PilihDomisiliScreen> {
  List<Domisili> _list = [];
  List<Domisili> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.fetchData().then((value) {
      setState(() {
        _list = value;
        _filtered = value;
        _loading = false;
      });
    });
  }

  void _filter(String keyword) {
    setState(() {
      _filtered = _list
          .where((item) =>
          item.nama.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
        leading: BackButton(),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              onChanged: _filter,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                hintText: "Cari ${widget.title}",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                return ListTile(
                  title: Text(item.nama),
                  onTap: () => widget.onSelected(item),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
