import 'package:flutter/material.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward / Poin'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          'Ini halaman Reward Anda!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
