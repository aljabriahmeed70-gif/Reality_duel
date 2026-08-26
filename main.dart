import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sdbfruxgoefdwyzhkjay.supabase.co',
  );

  const supabaseKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_t3mt53Npr-LxfprutshcVQ_cQulCux2',
  );

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const RealityDuelApp());
}

final supabase = Supabase.instance.client;

class RealityDuelApp extends StatelessWidget {
  const RealityDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reality Duel',
      debugShowCheckedModeBanner: false,
            theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6C4DFF),
        scaffoldBackgroundColor: const Color(0xFF0B0B12),
      ),
      home: const LoginPage(),
    );
    );
  }
}

// ============================================================
// APP SHELL
// ============================================================

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    DuelsPage(),
    DiscoverPage(),
    OpportunitiesPage(),
    TalentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: pages[currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_martial_arts_outlined),
            selectedIcon: Icon(Icons.sports_martial_arts),
            label: 'Duels',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Talent',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Opportunities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'REALITY DUEL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'The World Is Your Arena.',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أظهر موهبتك. أثبتها. دع العالم يكتشفك.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.public, size: 42),
                const SizedBox(height: 14),
                const Text(
                  'Your talent can open doors.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join free challenges, submit proof, build your Talent Profile and get discovered by companies.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateDuelPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create a Duel — Free'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const SectionTitle('Trending Duels'),
        const DuelCard(
          title: 'Best Street Football Skill',
          type: 'Global • Free',
          icon: Icons.sports_soccer,
        ),
        const DuelCard(
          title: '60-Second Creative Challenge',
          type: 'Talent • Free',
          icon: Icons.auto_awesome,
        ),
        const DuelCard(
          title: 'Company vs Company: Innovation',
          type: 'Companies • Free to join',
          icon: Icons.business,
        ),
        const SizedBox(height: 20),
        const SectionTitle('Featured Talent'),
        const TalentMini(
          name: 'Lina Ahmed',
          skill: 'Graphic Design',
          score: 94,
        ),
        const TalentMini(
          name: 'Omar Ali',
          skill: 'Football',
          score: 92,
        ),
      ],
    );
  }
}

// ============================================================
// DUELS
// ============================================================

class DuelsPage extends StatelessWidget {
  const DuelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageHeader(
          title: 'Duels',
          subtitle: 'All core challenges are free.',
        ),
        const DuelCard(
          title: 'Best Street Football Skill',
          type: 'Person vs Person',
          icon: Icons.sports_soccer,
        ),
        const DuelCard(
          title: 'Global Art Challenge',
          type: 'Open to everyone',
          icon: Icons.palette,
        ),
        const DuelCard(
          title: 'Company Innovation Duel',
          type: 'Company vs Company',
          icon: Icons.business,
        ),
        const DuelCard(
          title: 'Country Talent Challenge',
          type: 'Country vs Country',
          icon: Icons.flag,
        ),
      ],
    );
  }
}

// ============================================================
// DISCOVER
// ============================================================

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageHeader(
          title: 'Discover Talent',
          subtitle: 'Find proven skills, not just followers.',
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search talent, skill or country',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
          ),
        ),
        const SizedBox(height: 20),
        const TalentCard(
          name: 'Lina Ahmed',
          skill: 'Graphic Design • Video',
          country: 'Yemen',
          score: 94,
          wins: 18,
        ),
        const TalentCard(
          name: 'Omar Ali',
          skill: 'Football • Fitness',
          country: 'Egypt',
          score: 92,
          wins: 22,
        ),
        const TalentCard(
          name: 'Sara Noor',
          skill: 'Programming • AI',
          country: 'Jordan',
          score: 96,
          wins: 31,
        ),
      ],
    );
  }
}

// ============================================================
// OPPORTUNITIES
// ============================================================

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageHeader(
          title: 'Opportunities',
          subtitle: 'Jobs, scholarships, sponsorships and collaborations.',
        ),
        const OpportunityCard(
          title: 'Junior Graphic Designer',
          company: 'Global Creative Co.',
          type: 'Job',
          icon: Icons.work,
        ),
        const OpportunityCard(
          title: 'Global Talent Scholarship',
          company: 'Future Foundation',
          type: 'Scholarship',
          icon: Icons.school,
        ),
        const OpportunityCard(
          title: 'Sports Creator Sponsorship',
          company: 'Active Brand',
          type: 'Sponsorship',
          icon: Icons.star,
        ),
        const OpportunityCard(
          title: 'AI Builder Collaboration',
          company: 'Tech Lab',
          type: 'Collaboration',
          icon: Icons.handshake,
        ),
      ],
    );
  }
}

// ============================================================
// TALENT PROFILE
// ============================================================

class TalentProfilePage extends StatelessWidget {
  const TalentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 46,
          child: Icon(
            Icons.person,
            size: 46,
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Your Talent Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Center(
          child: Text('Build proof. Get discovered.'),
        ),
        const SizedBox(height: 22),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stat(
              label: 'Talent Score',
              value: '0',
            ),
            Stat(
              label: 'Wins',
              value: '0',
            ),
            Stat(
              label: 'Proofs',
              value: '0',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionTitle('Your Skills'),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text('Sports'),
            ),
            Chip(
              label: Text('Creativity'),
            ),
            Chip(
              label: Text('Add skill'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionTitle('Proof & Achievements'),
        const Card(
          child: ListTile(
            leading: Icon(Icons.verified),
            title: Text(
              'Verified achievements will appear here.',
            ),
            subtitle: Text(
              'Complete free duels and submit video/photo proof.',
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CREATE DUEL
// ============================================================

class CreateDuelPage extends StatefulWidget {
  const CreateDuelPage({super.key});

  @override
  State<CreateDuelPage> createState() => _CreateDuelPageState();
}

class _CreateDuelPageState extends State<CreateDuelPage> {
  String duelType = 'Person vs Person';

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Duel'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Create a challenge for free.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Challenge title',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'What must participants do?',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: duelType,
            decoration: const InputDecoration(
              labelText: 'Duel type',
            ),
            items: const [
              'Person vs Person',
              'Team vs Team',
              'Company vs Company',
              'Country vs Country',
              'Company vs Everyone',
              'Global Open',
            ].map(
              (item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                duelType = value;
              });
            },
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.rule),
              title: Text('Winning rules'),
              subtitle: Text(
                'Rules are locked when the duel starts. Score can combine execution, quality, creativity and public judging.',
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.video_camera_back),
              title: Text('Proof required'),
              subtitle: Text(
                'Participants can submit video and photos.',
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a challenge title.'),
                  ),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Duel created — free for everyone to join.',
                  ),
                ),
              );

              Navigator.pop(context);
            },
            child: const Text('Publish Duel'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DUEL CARD
// ============================================================

class DuelCard extends StatelessWidget {
  final String title;
  final String type;
  final IconData icon;

  const DuelCard({
    super.key,
    required this.title,
    required this.type,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(type),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DuelDetailPage(
                title: title,
                type: type,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// DUEL DETAIL
// ============================================================

class DuelDetailPage extends StatelessWidget {
  final String title;
  final String type;

  const DuelDetailPage({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duel'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(type),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Rules are public and locked when the challenge starts. Complete the real-world task and submit proof.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.verified),
              title: Text('Proof'),
              subtitle: Text(
                'Video and photos can be submitted for verification.',
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.emoji_events),
              title: Text('Scoring'),
              subtitle: Text(
                'Execution, quality, creativity and judging can be weighted per challenge.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProofPage(),
                ),
              );
            },
            icon: const Icon(Icons.sports_score),
            label: const Text('Join Duel — Free'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROOF
// ============================================================

class ProofPage extends StatelessWidget {
  const ProofPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Proof'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Show what you did.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload video or photos as evidence of your real-world challenge.',
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.videocam),
            label: const Text('Add Video'),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.photo_library),
            label: const Text('Add Photos'),
          ),
          const SizedBox(height: 20),
          const Card(
            child: ListTile(
              leading: Icon(Icons.security),
              title: Text('Verification'),
              subtitle: Text(
                'Future backend will run automated checks and human review for suspicious submissions.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Proof submitted for review.'),
                ),
              );
            },
            child: const Text('Submit Proof'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TALENT MINI
// ============================================================

class TalentMini extends StatelessWidget {
  final String name;
  final String skill;
  final int score;

  const TalentMini({
    super.key,
    required this.name,
    required this.skill,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(name),
        subtitle: Text(skill),
        trailing: Text(
          '$score',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TALENT CARD
// ============================================================

class TalentCard extends StatelessWidget {
  final String name;
  final String skill;
  final String country;
  final int score;
  final int wins;

  const TalentCard({
    super.key,
    required this.name,
    required this.skill,
    required this.country,
    required this.score,
    required this.wins,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text('$score/100'),
              ],
            ),
            const SizedBox(height: 10),
            Text(skill),
            Text(country),
            Text(
              '$wins verified wins',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('View Talent Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// OPPORTUNITY CARD
// ============================================================

class OpportunityCard extends StatelessWidget {
  final String title;
  final String company;
  final String type;
  final IconData icon;

  const OpportunityCard({
    super.key,
    required this.title,
    required this.company,
    required this.type,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('$company • $type'),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}

// ============================================================
// STAT
// ============================================================

class Stat extends StatelessWidget {
  final String label;
  final String value;

  const Stat({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PAGE HEADER
// ============================================================

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool loading = false;
  bool createAccount = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submitLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter email and password.',
          ),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters.',
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      if (createAccount) {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (response.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created successfully.',
              ),
            ),
          );

          setState(() {
            createAccount = false;
          });
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AppShell(),
          ),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An unexpected error occurred: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.public,
                    size: 70,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'REALITY DUEL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The World Is Your Arena.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    createAccount
                        ? 'Create your account'
                        : 'Welcome back',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !loading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    enabled: !loading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'At least 6 characters',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: loading
                          ? null
                          : submitLogin,
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              createAccount
                                  ? 'Create Account'
                                  : 'Login',
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            setState(() {
                              createAccount =
                                  !createAccount;
                            });
                          },
                    child: Text(
                      createAccount
                          ? 'Already have an account? Login'
                          : 'Create a new account',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your account is securely managed by Supabase.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
