import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              'أظهر مهاراتك، شارك في التحديات، واكتشف الفرص.',
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

            const SizedBox(height: 15),

            _buildButton(
              context,
              'Challenges',
              'التحديات',
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
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        onPressed: () {},
        child: Text(
          '$title\n$subtitle',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
