import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sdbfruxgoefdwyzhkjay.supabase.co',
  );

  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  if (supabasePublishableKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabasePublishableKey,
    );
  }

  runApp(const RealityDuelApp());
}

class RealityDuelApp extends StatefulWidget {
  const RealityDuelApp({super.key});

  @override
  State<RealityDuelApp> createState() => _RealityDuelAppState();
}

class _RealityDuelAppState extends State<RealityDuelApp> {
  Locale _locale = const Locale('en');

  void changeLanguage(String language) {
    setState(() {
      _locale = Locale(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reality Duel',
      locale: _locale,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF080A12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: AppShell(
        locale: _locale,
        onLanguageChanged: changeLanguage,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final Locale locale;
  final ValueChanged<String> onLanguageChanged;

  const AppShell({
    super.key,
    required this.locale,
    required this.onLanguageChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FeedPage(),
    DuelsPage(),
    TalentPage(),
    OpportunitiesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.locale.languageCode == 'ar';

    return Directionality(
      textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'language_button',
          onPressed: _showLanguagePicker,
          child: const Icon(Icons.language),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.play_circle_outline),
              selectedIcon: const Icon(Icons.play_circle),
              label: _text('Feed', 'الرئيسية'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.sports_mma_outlined),
              selectedIcon: const Icon(Icons.sports_mma),
              label: _text('Duels', 'التحديات'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: _text('Talent', 'المواهب'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.work_outline),
              selectedIcon: const Icon(Icons.work),
              label: _text('Opportunities', 'الفرص'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: _text('Profile', 'حسابي'),
            ),
          ],
        ),
      ),
    );
  }

  String _text(String english, String arabic) {
    return widget.locale.languageCode == 'ar' ? arabic : english;
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.language),
                title: Text(
                  'Choose Language / اختر اللغة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _languageTile('English', 'en'),
              _languageTile('العربية', 'ar'),
              _languageTile('Español', 'es'),
              _languageTile('Français', 'fr'),
              _languageTile('Türkçe', 'tr'),
              _languageTile('中文', 'zh'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile(String title, String code) {
    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(title),
      trailing: widget.locale.languageCode == code
          ? const Icon(Icons.check_circle)
          : null,
      onTap: () {
        Navigator.pop(context);
        widget.onLanguageChanged(code);
      },
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.play_circle,
      title: 'Reality Duel',
      subtitle: 'The World Is Your Arena',
    );
  }
}

class DuelsPage extends StatelessWidget {
  const DuelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.sports_mma,
      title: 'Duels',
      subtitle: 'Challenge the world',
    );
  }
}

class TalentPage extends StatelessWidget {
  const TalentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.people,
      title: 'Discover Talent',
      subtitle: 'Find the next great talent',
    );
  }
}

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.work,
      title: 'Opportunities',
      subtitle: 'Jobs, grants and sponsorships',
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = _supabaseClient;

    final user = client?.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 45,
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user?.email ?? 'Guest User',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: user == null
                    ? () => _showLoginMessage(context)
                    : () async {
                        await client!.auth.signOut();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Signed out successfully'),
                            ),
                          );
                        }
                      },
                icon: Icon(
                  user == null ? Icons.login : Icons.logout,
                ),
                label: Text(
                  user == null ? 'Login' : 'Logout',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login required'),
          content: const Text(
            'You can watch public content without an account. '
            'Login is required for interactions and publishing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF080A12),
              Color(0xFF12152A),
              Color(0xFF1A1030),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF7C4DFF),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 55,
                      color: const Color(0xFFB388FF),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
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

SupabaseClient? get _supabaseClient {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
