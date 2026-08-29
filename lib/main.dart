import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
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

// ============================================================
// APP
// ============================================================

class RealityDuelApp extends StatefulWidget {
  const RealityDuelApp({super.key});

  @override
  State<RealityDuelApp> createState() => _RealityDuelAppState();
}

class _RealityDuelAppState extends State<RealityDuelApp> {
  String selectedLanguage = 'English';

  void changeLanguage(String language) {
    setState(() {
      selectedLanguage = language;
    });
  }

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
      home: AppShell(
      ),
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
    VideoFeedPage(),
    DuelsPage(),
    DiscoverPage(),
    OpportunitiesPage(),
    TalentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
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
            icon: Icon(Icons.play_arrow_outlined),
            selectedIcon: Icon(Icons.play_arrow),
            label: 'Feed',
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

      // 🌐 زر اللغات — يظهر بشكل واضح أعلى التطبيق
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (context) {
              return SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      '🌐 Language',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Choose your language',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    ListTile(
                      leading: const Text(
                        '🇬🇧',
                        style: TextStyle(fontSize: 28),
                      ),
                      title: const Text('English'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    ListTile(
                      leading: const Text(
                        '🇸🇦',
                        style: TextStyle(fontSize: 28),
                      ),
                      title: const Text('العربية'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    ListTile(
                      leading: const Text(
                        '🇪🇸',
                        style: TextStyle(fontSize: 28),
                      ),
                      title: const Text('Español'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    ListTile(
                      leading: const Text(
                        '🇫🇷',
                        style: TextStyle(fontSize: 28),
                      ),
                      title: const Text('Français'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    ListTile(
                      leading: const Text(
                        '🇹🇷',
                        style: TextStyle(fontSize: 28),
                      ),
                      title: const Text('Türkçe'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    ListTile(
                      leading: const Text(
                        '🇨🇳',
                        style: TextStyle(fontSize: 28),
                      ),
                      title: const Text('中文'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.language),
        label: const Text('Language'),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }
}

// ============================================================
// VIDEO FEED
// ============================================================

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final PageController pageController = PageController();

  final List<FeedVideo> videos = const [
    FeedVideo(
      username: 'Reality Talent',
      title: 'Show your talent. Prove it.',
      description:
          'The world is your arena. Join Reality Duel and let the world discover you.',
      icon: Icons.star,
    ),
    FeedVideo(
      username: 'Football Talent',
      title: 'Street Football Challenge',
      description:
          'Skills, creativity and execution. Who would win this Duel?',
      icon: Icons.sports_soccer,
    ),
    FeedVideo(
      username: 'Creative Talent',
      title: '60 Second Creative Challenge',
      description:
          'You have 60 seconds. Show the world what you can create.',
      icon: Icons.auto_awesome,
    ),
    FeedVideo(
      username: 'Future Talent',
      title: 'Your talent can open doors.',
      description:
          'Build proof, get discovered and find opportunities through Reality Duel.',
      icon: Icons.public,
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> requireLogin(
    BuildContext context, {
    required String action,
  }) async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action is available for your account.'),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login required'),
          content: Text(
            'You can watch videos without an account.\n\n'
            'To $action, please login or create a free account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
              child: const Text('Login / Create Account'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];

        return VideoFeedItem(
          video: video,
          onLike: () {
            requireLogin(
              context,
              action: 'like this video',
            );
          },
          onComment: () {
            requireLogin(
              context,
              action: 'comment on this video',
            );
          },
          onFollow: () {
            requireLogin(
              context,
              action: 'follow this talent',
            );
          },
          onShare: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share feature coming soon.'),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// FEED VIDEO MODEL
// ============================================================

class FeedVideo {
  final String username;
  final String title;
  final String description;
  final IconData icon;

  const FeedVideo({
    required this.username,
    required this.title,
    required this.description,
    required this.icon,
  });
}

// ============================================================
// VIDEO FEED ITEM
// ============================================================

class VideoFeedItem extends StatelessWidget {
  final FeedVideo video;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onFollow;
  final VoidCallback onShare;

  const VideoFeedItem({
    super.key,
    required this.video,
    required this.onLike,
    required this.onComment,
    required this.onFollow,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ------------------------------------------------------
        // VIDEO PLACEHOLDER
        // ------------------------------------------------------

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF151522),
                Color(0xFF26184A),
                Color(0xFF09090F),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  video.icon,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.play_circle_fill,
                  size: 72,
                ),
                const SizedBox(height: 12),
                const Text(
                  'VIDEO',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ------------------------------------------------------
        // TOP BAR
        // ------------------------------------------------------

        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Text(
                    'REALITY DUEL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ------------------------------------------------------
        // RIGHT ACTIONS
        // ------------------------------------------------------

        Positioned(
          right: 10,
          bottom: 100,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 27,
                child: Icon(
                  Icons.person,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),

              _FeedAction(
                icon: Icons.favorite_border,
                label: 'Like',
                onTap: onLike,
              ),

              const SizedBox(height: 18),

              _FeedAction(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onTap: onComment,
              ),

              const SizedBox(height: 18),

              _FeedAction(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: onShare,
              ),

              const SizedBox(height: 18),

              _FeedAction(
                icon: Icons.person_add_alt_1,
                label: 'Follow',
                onTap: onFollow,
              ),
            ],
          ),
        ),

        // ------------------------------------------------------
        // BOTTOM INFORMATION
        // ------------------------------------------------------

        Positioned(
          left: 16,
          right: 80,
          bottom: 105,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    child: Icon(
                      Icons.person,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '@${video.username}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                video.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                video.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    size: 19,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Reality Duel Challenge',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// FEED ACTION
// ============================================================

class _FeedAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeedAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.black.withOpacity(0.35),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
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
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            final user = supabase.auth.currentUser;

            if (user == null) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Create a Duel'),
                    content: const Text(
                      'You need an account to create a Duel.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Login / Create Account',
                        ),
                      ),
                    ],
                  );
                },
              );
              return;
            }

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
          subtitle:
              'Jobs, scholarships, sponsorships and collaborations.',
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

  Future<void> logout(BuildContext context) async {
    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AppShell(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

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
        const SizedBox(height: 6),
        Center(
          child: Text(
            user?.email ?? 'Guest User',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Build proof. Get discovered.',
          ),
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
        const SizedBox(height: 24),
        if (user == null)
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
            child: const Text('Login / Create Account'),
          )
        else
          OutlinedButton.icon(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
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

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

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
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'What must participants do?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: duelType,
            decoration: const InputDecoration(
              labelText: 'Duel type',
              border: OutlineInputBorder(),
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
                    content: Text(
                      'Please enter a challenge title.',
                    ),
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
              final user = supabase.auth.currentUser;

              if (user == null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Join Reality Duel'),
                      content: const Text(
                        'You need an account to join a Duel.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Login / Create Account',
                          ),
                        ),
                      ],
                    );
                  },
                );
                return;
              }

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
class ProofPage extends StatefulWidget {
  const ProofPage({super.key});

  @override
  State<ProofPage> createState() => _ProofPageState();
}

class _ProofPageState extends State<ProofPage> {
  String? selectedFileName;
  bool uploading = false;
  String? uploadedVideoUrl;

  Future<void> pickAndUploadVideo() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login before uploading a video.',
          ),
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;

    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not read the selected video.',
          ),
        ),
      );
      return;
    }

    setState(() {
      selectedFileName = file.name;
      uploading = true;
      uploadedVideoUrl = null;
    });

    try {
      final safeFileName = file.name.replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );

      final filePath =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';

      await supabase.storage.from('videos').uploadBinary(
            filePath,
            file.bytes!,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'video/mp4',
            ),
          );

      final publicUrl = supabase.storage
          .from('videos')
          .getPublicUrl(filePath);

      if (!mounted) return;

      setState(() {
        uploadedVideoUrl = publicUrl;
        uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Video uploaded successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Video upload failed: $error',
          ),
        ),
      );
    }
  }

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
            onPressed: uploading ? null : pickAndUploadVideo,
            icon: const Icon(Icons.videocam),
            label: Text(
              uploading
                  ? 'Uploading...'
                  : 'Add Video',
            ),
          ),

          if (selectedFileName != null) ...[
            const SizedBox(height: 12),
            Text(
              'Selected: $selectedFileName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          if (uploading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],

          if (uploadedVideoUrl != null) ...[
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle),
                title: Text('Video uploaded'),
                subtitle: Text(
                  'Your video is now stored in Supabase Storage.',
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

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
            onPressed: uploadedVideoUrl == null || uploading
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Proof submitted for review.',
                        ),
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
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    if (session != null) {
      return const AppShell();
    }

    return const LoginPage();
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
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email and password.',
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
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const AppShell(),
            ),
            (route) => false,
          );
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const AppShell(),
          ),
          (route) => false,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      String message = error.message;

      if (message.toLowerCase().contains('invalid login')) {
        message = 'Email or password is incorrect.';
      } else if (message
          .toLowerCase()
          .contains('already registered')) {
        message =
            'This email is already registered. Please login.';
      } else if (message.toLowerCase().contains('rate limit')) {
        message =
            'Too many attempts. Please wait a little and try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
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
                        onPressed: loading
                            ? null
                            : () {
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
                      onPressed: loading ? null : submitLogin,
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
                              createAccount = !createAccount;
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
                          Icon(Icons.security),
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
