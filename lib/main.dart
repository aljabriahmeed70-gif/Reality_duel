import 'package:flutter/material.dart';

void main() {
  runApp(const RealityDuelApp());
}

class RealityDuelApp extends StatelessWidget {
  const RealityDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reality Duel',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reality Duel'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text(
              'اكتشف موهبتك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'منصة لاكتشاف المواهب الحقيقية وعرضها والتواصل معها من خلال التحديات والفرص.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            _buildButton(
              context,
              'Talent Profile',
              'ملف الموهبة',
            ),
            const SizedBox(height: 15),
            _buildButton(
              context,
              'Discover Talent',
              'اكتشف المواهب',
            ),
            const SizedBox(height: 15),
            _buildButton(
              context,
              'Opportunities',
              'الفرص',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      child: Text(
        '$title\n$subtitle',
        textAlign: TextAlign.center,
      ),
    );
  }
}
