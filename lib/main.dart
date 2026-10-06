import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://sdbfruxgoefdwyzhkjay.supabase.co';
const String supabasePublishableKey = 'sb_publishable_t3mt53Npr-LxfprutshcVQ_cQulCux2';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
  );

  runApp(const RealityDuelApp());
}

final supabase = Supabase.instance.client;

enum Role { talent, company }

class ProfileData {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String country;
  final bool isTalent;
  final bool isCompany;
  final int followersCount;
  final int followingCount;
  final int videosCount;

  const ProfileData({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.country,
    required this.isTalent,
    required this.isCompany,
    required this.followersCount,
    required this.followingCount,
    required this.videosCount,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      displayName: map['display_name']?.toString() ?? 'New User',
      bio: map['bio']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      isTalent: map['is_talent'] == true,
      isCompany: map['is_company'] == true,
      followersCount: (map['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (map['following_count'] as num?)?.toInt() ?? 0,
      videosCount: (map['videos_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class RealityDuelApp extends StatelessWidget {
  const RealityDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reality Duel',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF7557FF),
        scaffoldBackgroundColor: const Color(0xFF080911),
      ),
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = supabase.auth.currentSession;

          if (session == null) {
            return const GuestHome();
          }

          return const AuthenticatedHome();
        },
      ),
    );
  }
}

class GuestHome extends StatelessWidget {
  const GuestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 25),
            const Icon(Icons.public, size: 70),
            const SizedBox(height: 18),
            const Text(
              'REALITY DUEL',
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 4,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'The World Is Your Arena.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'العالم هو ساحتك.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 25),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Icon(Icons.play_circle_outline, size: 45),
                    SizedBox(height: 10),
                    Text(
                      'شاهد المحتوى بدون تسجيل دخول',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'يمكنك مشاهدة المواهب والتحديات العامة، '
                      'أما التفاعل والمشاركة فتحتاج إلى حساب.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublicFeedPage(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('مشاهدة Reality Duel'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoleChoicePage(),
                  ),
                );
              },
              child: const Text('إنشاء حساب'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignInPage(),
                  ),
                );
              },
              child: const Text('لدي حساب بالفعل'),
            ),
          ],
        ),
      ),
    );
  }
}

class PublicFeedPage extends StatelessWidget {
  const PublicFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reality Duel'),
        actions: [
          IconButton(
            tooltip: 'تسجيل الدخول',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignInPage(),
                ),
              );
            },
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_outlined, size: 70),
              SizedBox(height: 15),
              Text(
                'الفيديوهات العامة',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'سنربط هذه الصفحة الآن بتخزين الفيديوهات '
                'الذي أنشأناه في Supabase.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleChoicePage extends StatelessWidget {
  const RoleChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نوع الحساب'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'اختر نوع حسابك',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'يمكنك تغيير بيانات ملفك لاحقًا.',
          ),
          const SizedBox(height: 25),
          AccountChoiceCard(
            icon: Icons.person,
            title: 'موهبة / مستخدم',
            description:
                'شارك في التحديات، اعرض مهاراتك واكتشف الفرص.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignUpPage(
                    role: Role.talent,
                  ),
                ),
              );
            },
          ),
          AccountChoiceCard(
            icon: Icons.business,
            title: 'شركة',
            description:
                'اكتشف المواهب وانشر الوظائف والفرص.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignUpPage(
                    role: Role.company,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AccountChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const AccountChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  final Role role;

  const SignUpPage({
    super.key,
    required this.role,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final countryController = TextEditingController();
  final headlineController = TextEditingController();
  final companyController = TextEditingController();
  final industryController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    countryController.dispose();
    headlineController.dispose();
    companyController.dispose();
    industryController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('أدخل الاسم والبريد الإلكتروني وكلمة المرور.');
      return;
    }

    if (password.length < 6) {
      showMessage('كلمة المرور يجب أن تكون 6 أحرف على الأقل.');
      return;
    }

    setState(() => loading = true);

    try {
      final username = createUsername(name);

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'display_name': name,
        },
      );

      final user = response.user;

      if (user == null) {
        throw Exception('لم يتم إنشاء المستخدم.');
      }

      if (response.session != null) {
        await saveProfile(user.id);
      }

      if (!mounted) return;

      if (response.session == null) {
        showMessage(
          'تم إنشاء الحساب. تحقق من بريدك الإلكتروني ثم سجل الدخول.',
        );
        Navigator.pop(context);
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      showMessage('حدث خطأ أثناء إنشاء الحساب.');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> saveProfile(String userId) async {
    final isTalent = widget.role == Role.talent;
    final isCompany = widget.role == Role.company;

    final displayName = isCompany &&
            companyController.text.trim().isNotEmpty
        ? companyController.text.trim()
        : nameController.text.trim();

    final bio = isTalent
        ? headlineController.text.trim()
        : industryController.text.trim();

    await supabase.from('profiles').upsert({
      'id': userId,
      'display_name': displayName,
      'country': countryController.text.trim(),
      'bio': bio,
      'is_talent': isTalent,
      'is_company': isCompany,
    });
  }

  String createUsername(String name) {
    final cleaned = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (cleaned.isEmpty) {
      return 'user_${DateTime.now().millisecondsSinceEpoch}';
    }

    return '${cleaned}_${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final talent = widget.role == Role.talent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          talent ? 'حساب الموهبة' : 'حساب الشركة',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            talent ? 'أنشئ ملف موهبتك' : 'أنشئ ملف شركتك',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          InputField(
            controller: nameController,
            label: talent ? 'الاسم' : 'اسم المسؤول',
            icon: Icons.person,
          ),
          InputField(
            controller: emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          InputField(
            controller: passwordController,
            label: 'كلمة المرور',
            icon: Icons.lock,
            obscureText: obscurePassword,
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
          ),
          InputField(
            controller: countryController,
            label: 'الدولة',
            icon: Icons.public,
          ),
          if (talent)
            InputField(
              controller: headlineController,
              label: 'العنوان المهني / الموهبة',
              icon: Icons.auto_awesome,
            )
          else ...[
            InputField(
              controller: companyController,
              label: 'اسم الشركة',
              icon: Icons.business,
            ),
            InputField(
              controller: industryController,
              label: 'مجال الشركة',
              icon: Icons.category,
            ),
          ],
          const SizedBox(height: 15),
          const Card(
            child: ListTile(
              leading: Icon(Icons.verified_user_outlined),
              title: Text('Reality Duel'),
              subtitle: Text(
                'التحديات الأساسية مجانية ولا يمكن شراء الفوز.',
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: loading ? null : createAccount,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('إنشاء الحساب'),
            ),
          ),
        ],
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('أدخل البريد الإلكتروني وكلمة المرور.');
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      showMessage('حدث خطأ أثناء تسجيل الدخول.');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'مرحبًا بعودتك',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 25),
          InputField(
            controller: emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          InputField(
            controller: passwordController,
            label: 'كلمة المرور',
            icon: Icons.lock,
            obscureText: obscurePassword,
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: loading ? null : signIn,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('تسجيل الدخول'),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthenticatedHome extends StatefulWidget {
  const AuthenticatedHome({super.key});

  @override
  State<AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends State<AuthenticatedHome> {
  ProfileData? profile;
  bool loading = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        profile = ProfileData.fromMap(data);
      }
    } catch (_) {
      // الملف الشخصي قد لا يكون جاهزًا بعد لحظة التسجيل.
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final company = profile?.isCompany == true;

    final pages = company
        ? [
            CompanyHomePage(profile: profile),
            const DiscoverTalentPage(),
            const OpportunitiesPage(),
            ProfilePage(profile: profile),
          ]
        : [
            TalentHomePage(profile: profile),
            const DuelsPage(),
            const DiscoverTalentPage(),
            const OpportunitiesPage(),
            ProfilePage(profile: profile),
          ];

    return Scaffold(
      body: SafeArea(
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: company
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business),
                  label: 'الشركة',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'المواهب',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline),
                  selectedIcon: Icon(Icons.work),
                  label: 'الفرص',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'الملف',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Icon(Icons.flash_on_outlined),
                  selectedIcon: Icon(Icons.flash_on),
                  label: 'التحديات',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'المواهب',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline),
                  selectedIcon: Icon(Icons.work),
                  label: 'الفرص',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'ملفي',
                ),
              ],
      ),
    );
  }
}

class TalentHomePage extends StatelessWidget {
  final ProfileData? profile;

  const TalentHomePage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : 'موهبة';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'REALITY DUEL',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'مرحبًا $name',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Text(
          'موهبتك يمكن أن تكون بداية فرصتك التالية.',
        ),
        const SizedBox(height: 20),
        const Card(
          child: ListTile(
            leading: Icon(Icons.play_circle),
            title: Text('الفيديوهات'),
            subtitle: Text(
              'استكشف مواهب العالم وشاهد المحتوى العام.',
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Card(
          child: ListTile(
            leading: Icon(Icons.flash_on),
            title: Text('التحديات'),
            subtitle: Text(
              'شارك في تحديات Reality Duel المجانية.',
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Card(
          child: ListTile(
            leading: Icon(Icons.work),
            title: Text('الفرص'),
            subtitle: Text(
              'اكتشف الوظائف والمنح والرعايات والمشاريع.',
            ),
          ),
        ),
      ],
    );
  }
}

class CompanyHomePage extends StatelessWidget {
  final ProfileData? profile;

  const CompanyHomePage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : 'الشركة';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'EMPLOYER HUB',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        const FeatureCard(
          icon: Icons.people,
          title: 'اكتشاف المواهب',
          description: 'ابحث عن المواهب حسب المهارات والأداء.',
        ),
        const FeatureCard(
          icon: Icons.post_add,
          title: 'نشر فرصة',
          description: 'وظيفة أو منحة أو رعاية أو مشروع.',
        ),
        const FeatureCard(
          icon: Icons.video_call,
          title: 'المقابلات',
          description: 'إدارة المرشحين داخل المنصة.',
        ),
        const FeatureCard(
          icon: Icons.analytics,
          title: 'تحليلات المواهب',
          description: 'مقارنة المرشحين بناءً على الأداء.',
        ),
      ],
    );
  }
}

class DiscoverTalentPage extends StatelessWidget {
  const DiscoverTalentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Discover Talent',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'اكتشف المواهب من خلال الأداء الحقيقي.',
        ),
        const SizedBox(height: 18),
        TextField(
          decoration: InputDecoration(
            hintText: 'المهارة، الدولة، الموهبة...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white.withOpacity(.06),
          ),
        ),
        const SizedBox(height: 15),
        const TalentCard(
          name: 'Discover Talent',
          description: 'سيتم تحميل المواهب الحقيقية من Supabase.',
        ),
      ],
    );
  }
}

class DuelsPage extends StatelessWidget {
  const DuelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'التحديات',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text('كل التحديات الأساسية مجانية.'),
        SizedBox(height: 20),
        FeatureCard(
          icon: Icons.auto_awesome,
          title: '60-Second Creative Challenge',
          description: 'تحدي عالمي مفتوح.',
        ),
        FeatureCard(
          icon: Icons.sports_soccer,
          title: 'Street Football Skill',
          description: 'Person vs Person.',
        ),
        FeatureCard(
          icon: Icons.business,
          title: 'Innovation Duel',
          description: 'Company vs Company.',
        ),
        FeatureCard(
          icon: Icons.flag,
          title: 'National Talent Challenge',
          description: 'Country vs Country.',
        ),
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
      children: const [
        Text(
          'Opportunities',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text('وظائف ومنح ورعايات ومشاريع.'),
        SizedBox(height: 20),
        FeatureCard(
          icon: Icons.work,
          title: 'الوظائف',
          description: 'سيتم تحميل الوظائف من Supabase.',
        ),
        FeatureCard(
          icon: Icons.school,
          title: 'المنح',
          description: 'فرص تعليمية ومنح.',
        ),
        FeatureCard(
          icon: Icons.star,
          title: 'الرعايات',
          description: 'فرص رعاية للمواهب.',
        ),
        FeatureCard(
          icon: Icons.handshake,
          title: 'المشاريع',
          description: 'مشاريع وتعاونات.',
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  final ProfileData? profile;

  const ProfilePage({
    super.key,
    required this.profile,
  });

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 45,
          child: Icon(
            Icons.person,
            size: 45,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          profile?.displayName ?? 'New User',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user?.email ?? '',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text('الدولة'),
                subtitle: Text(
                  profile?.country.isNotEmpty == true
                      ? profile!.country
                      : 'لم تتم الإضافة',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('المتابعون'),
                subtitle: Text(
                  '${profile?.followersCount ?? 0}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('الفيديوهات'),
                subtitle: Text(
                  '${profile?.videosCount ?? 0}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: logout,
          icon: const Icon(Icons.logout),
          label: const Text('تسجيل الخروج'),
        ),
      ],
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class TalentCard extends StatelessWidget {
  final String name;
  final String description;

  const TalentCard({
    super.key,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(name),
        subtitle: Text(description),
      ),
    );
  }
}
