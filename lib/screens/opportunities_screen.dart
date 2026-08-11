import 'package:flutter/material.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunities'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Opportunities',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Discover opportunities that match your talents.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 25),

          _opportunityCard(
            title: 'Talent Challenge',
            description:
                'Join a challenge and show your skills to companies.',
            icon: Icons.emoji_events,
          ),

          _opportunityCard(
            title: 'Job Opportunity',
            description:
                'Find opportunities from companies looking for talented people.',
            icon: Icons.work,
          ),

          _opportunityCard(
            title: 'Competition',
            description:
                'Compete with other talents and build your profile.',
            icon: Icons.groups,
          ),

          _opportunityCard(
            title: 'Training Program',
            description:
                'Improve your skills through useful training programs.',
            icon: Icons.school,
          ),
        ],
      ),
    );
  }

  Widget _opportunityCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
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
