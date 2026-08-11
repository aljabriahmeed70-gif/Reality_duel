import 'package:flutter/material.dart';

void main() => runApp(const RealityDuelApp());

class RealityDuelApp extends StatelessWidget {
  const RealityDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reality Duel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C4DFF),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B12),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  final pages = const [
    HomePage(),
    DuelsPage(),
    DiscoverPage(),
    OpportunitiesPage(),
    TalentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.swords_outlined), selectedIcon: Icon(Icons.swords), label: 'Duels'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Talent'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Opportunities'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('REALITY DUEL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('The World Is Your Arena.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('أظهر موهبتك. أثبتها. دع العالم يكتشفك.',
            style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 16)),
        const SizedBox(height: 24),
        _heroCard(context),
        const SizedBox(height: 28),
        const SectionTitle('Trending Duels'),
        const DuelCard(title: 'Best Street Football Skill', type: 'Global • Free', icon: Icons.sports_soccer),
        const DuelCard(title: '60-Second Creative Challenge', type: 'Talent • Free', icon: Icons.auto_awesome),
        const DuelCard(title: 'Company vs Company: Innovation', type: 'Companies • Free to join', icon: Icons.business),
        const SizedBox(height: 20),
        const SectionTitle('Featured Talent'),
        const TalentMini(name: 'Lina Ahmed', skill: 'Graphic Design', score: 94),
        const TalentMini(name: 'Omar Ali', skill: 'Football', score: 92),
      ],
    );
  }

  Widget _heroCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.public, size: 42),
          const SizedBox(height: 14),
          const Text('Your talent can open doors.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Join free challenges, submit proof, build your Talent Profile and get discovered by companies.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateDuelPage())),
            icon: const Icon(Icons.add),
            label: const Text('Create a Duel — Free'),
          )
        ]),
      ),
    );
  }
}

class DuelsPage extends StatelessWidget {
  const DuelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageHeader(title: 'Duels', subtitle: 'All core challenges are free.'),
        const DuelCard(title: 'Best Street Football Skill', type: 'Person vs Person', icon: Icons.sports_soccer),
        const DuelCard(title: 'Global Art Challenge', type: 'Open to everyone', icon: Icons.palette),
        const DuelCard(title: 'Company Innovation Duel', type: 'Company vs Company', icon: Icons.business),
        const DuelCard(title: 'Country Talent Challenge', type: 'Country vs Country', icon: Icons.flag),
      ],
    );
  }
}

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageHeader(title: 'Discover Talent', subtitle: 'Find proven skills, not just followers.'),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search talent, skill or country',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white.withOpacity(.06),
          ),
        ),
        const SizedBox(height: 20),
        const TalentCard(name: 'Lina Ahmed', skill: 'Graphic Design • Video', country: 'Yemen', score: 94, wins: 18),
        const TalentCard(name: 'Omar Ali', skill: 'Football • Fitness', country: 'Egypt', score: 92, wins: 22),
        const TalentCard(name: 'Sara Noor', skill: 'Programming • AI', country: 'Jordan', score: 96, wins: 31),
      ],
    );
  }
}

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageHeader(title: 'Opportunities', subtitle: 'Jobs, scholarships, sponsorships and collaborations.'),
        OpportunityCard(title: 'Junior Graphic Designer', company: 'Global Creative Co.', type: 'Job', icon: Icons.work),
        OpportunityCard(title: 'Global Talent Scholarship', company: 'Future Foundation', type: 'Scholarship', icon: Icons.school),
        OpportunityCard(title: 'Sports Creator Sponsorship', company: 'Active Brand', type: 'Sponsorship', icon: Icons.star),
        OpportunityCard(title: 'AI Builder Collaboration', company: 'Tech Lab', type: 'Collaboration', icon: Icons.handshake),
      ],
    );
  }
}

class TalentProfilePage extends StatelessWidget {
  const TalentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(radius: 46, child: Icon(Icons.person, size: 46)),
        const SizedBox(height: 12),
        const Center(child: Text('Your Talent Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        const Center(child: Text('Build proof. Get discovered.')),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Stat(label: 'Talent Score', value: '0'),
            Stat(label: 'Wins', value: '0'),
            Stat(label: 'Proofs', value: '0'),
          ],
        ),
        const SizedBox(height: 24),
        const SectionTitle('Your Skills'),
        const Wrap(spacing: 8, runSpacing: 8, children: [
          Chip(label: Text('Add skill')),
          Chip(label: Text('Sports')),
          Chip(label: Text('Creativity')),
        ]),
        const SizedBox(height: 20),
        const SectionTitle('Proof & Achievements'),
        Card(child: ListTile(leading: Icon(Icons.verified), title: Text('Verified achievements will appear here.'), subtitle: Text('Complete free duels and submit video/photo proof.'))),
      ],
    );
  }
}

class CreateDuelPage extends StatefulWidget {
  const CreateDuelPage({super.key});

  @override
  State<CreateDuelPage> createState() => _CreateDuelPageState();
}

class _CreateDuelPageState extends State<CreateDuelPage> {
  String type = 'Person vs Person';
  final title = TextEditingController();
  final description = TextEditingController();

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Duel')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Create a challenge for free.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Challenge title')),
          const SizedBox(height: 12),
          TextField(controller: description, maxLines: 4, decoration: const InputDecoration(labelText: 'What must participants do?')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: type,
            decoration: const InputDecoration(labelText: 'Duel type'),
            items: const ['Person vs Person', 'Team vs Team', 'Company vs Company', 'Country vs Country', 'Company vs Everyone', 'Global Open']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => type = v!),
          ),
          const SizedBox(height: 12),
          const Card(child: ListTile(
            leading: Icon(Icons.rule),
            title: Text('Winning rules'),
            subtitle: Text('Rules are locked when the duel starts. Score can combine execution, quality, creativity and public judging.'),
          )),
          const Card(child: ListTile(
            leading: Icon(Icons.video_camera_back),
            title: Text('Proof required'),
            subtitle: Text('Participants can submit video and photos. Verification is part of the result.'),
          )),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duel created — free for everyone to join.')));
              Navigator.pop(context);
            },
            child: const Text('Publish Duel'),
          ),
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title, subtitle;
  const PageHeader({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.65))),
    ]),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  );
}

class DuelCard extends StatelessWidget {
  final String title, type;
  final IconData icon;
  const DuelCard({super.key, required this.title, required this.type, required this.icon});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(type),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DuelDetailPage(title: title, type: type))),
    ),
  );
}

class DuelDetailPage extends StatelessWidget {
  final String title, type;
  const DuelDetailPage({super.key, required this.title, required this.type});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Duel')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(type),
      const SizedBox(height: 20),
      const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Rules are public and locked when the challenge starts. Complete the real-world task and submit proof.'))),
      const SizedBox(height: 12),
      const Card(child: ListTile(leading: Icon(Icons.verified), title: Text('Proof'), subtitle: Text('Video + photos can be submitted for verification.'))),
      const Card(child: ListTile(leading: Icon(Icons.emoji_events), title: Text('Scoring'), subtitle: Text('Execution, quality, creativity and judging can be weighted per challenge.'))),
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProofPage())), icon: const Icon(Icons.sports_score), label: const Text('Join Duel — Free')),
    ]),
  );
}

class ProofPage extends StatelessWidget {
  const ProofPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Submit Proof')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Show what you did.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Upload video or photos as evidence of your real-world challenge.'),
      const SizedBox(height: 24),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.videocam), label: const Text('Add Video')),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.photo_library), label: const Text('Add Photos')),
      const SizedBox(height: 20),
      const Card(child: ListTile(leading: Icon(Icons.security), title: Text('Verification'), subtitle: Text('Future backend will run automated checks and human review for disputed or suspicious submissions.'))),
      const SizedBox(height: 20),
      FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proof submitted for review.'))), child: const Text('Submit Proof')),
    ]),
  );
}

class TalentMini extends StatelessWidget {
  final String name, skill;
  final int score;
  const TalentMini({super.key, required this.name, required this.skill, required this.score});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(name), subtitle: Text(skill), trailing: Text('$score', style: const TextStyle(fontWeight: FontWeight.bold))));
}

class TalentCard extends StatelessWidget {
  final String name, skill, country;
  final int score, wins;
  const TalentCard({super.key, required this.name, required this.skill, required this.country, required this.score, required this.wins});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 12), Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))), Text('$score/100')]),
      const SizedBox(height: 10),
      Text(skill),
      Text(country),
      Text('$wins verified wins', style: TextStyle(color: Colors.white.withOpacity(.65))),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: () {}, child: const Text('View Talent Profile')),
    ])),
  );
}

class OpportunityCard extends StatelessWidget {
  final String title, company, type;
  final IconData icon;
  const OpportunityCard({super.key, required this.title, required this.company, required this.type, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('$company • $type'), trailing: const Icon(Icons.arrow_forward_ios, size: 16)));
}

class Stat extends StatelessWidget {
  final String label, value;
  const Stat({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 12))]);
}