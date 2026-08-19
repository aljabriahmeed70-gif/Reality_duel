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
        scaffoldBackgroundColor: const Color(0xFF080808),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A2BE2),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final pages = const [
    HomeContent(),
    DiscoverPage(),
    ChallengesPage(),
    OpportunitiesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101010),
        indicatorColor: const Color(0xFF2A2A2A),
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'اكتشف',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'التحديات',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'الفرص',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF080808),
            floating: true,
            title: const Text(
              'REALITY DUEL',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'العالم هو ساحتك.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أظهر موهبتك، ادخل التحدي، وابحث عن فرصتك.',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _featuredChallenge(context),
                  const SizedBox(height: 28),
                  const Text(
                    'مواهب تستحق المشاهدة',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return TalentCard(index: index);
              },
              childCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredChallenge(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A00FF),
            Color(0xFFB000FF),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔥 التحدي الحالي',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'أظهر موهبتك للعالم',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'شارك بفيديو قصير ودع العالم يكتشف ما تستطيع فعله.',
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChallengeDetailsPage(),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('شارك الآن'),
          ),
        ],
      ),
    );
  }
}

class TalentCard extends StatelessWidget {
  final int index;

  const TalentCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final talents = [
      'موهبة رقم 1',
      'موهبة رقم 2',
      'موهبة رقم 3',
      'موهبة رقم 4',
      'موهبة رقم 5',
    ];

    final skills = [
      'الغناء والأداء',
      'الرسم والتصميم',
      'الرياضة واللياقة',
      'البرمجة والتقنية',
      'صناعة المحتوى',
    ];

    return Card(
      color: const Color(0xFF141414),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TalentDetailsPage(
                talentName: talents[index],
                skill: skills[index],
                number: index + 1,
              ),
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 28,
            child: Text('${index + 1}'),
          ),
          title: Text(
            talents[index],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(skills[index]),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
    );
  }
}

class TalentDetailsPage extends StatefulWidget {
  final String talentName;
  final String skill;
  final int number;

  const TalentDetailsPage({
    super.key,
    required this.talentName,
    required this.skill,
    required this.number,
  });

  @override
  State<TalentDetailsPage> createState() => _TalentDetailsPageState();
}

class _TalentDetailsPageState extends State<TalentDetailsPage> {
  bool following = false;
  int likes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف الموهبة'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 55,
            child: Text(
              '${widget.number}',
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.talentName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.skill,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 80,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    likes++;
                  });
                },
                icon: const Icon(Icons.favorite_border),
                label: Text('إعجاب $likes'),
              ),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    following = !following;
                  });
                },
                icon: Icon(
                  following ? Icons.check : Icons.person_add,
                ),
                label: Text(
                  following ? 'تتابعه' : 'متابعة',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'عن الموهبة',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هذه صفحة موهبة تجريبية في Reality Duel. '
            'يمكن لاحقًا إضافة الفيديوهات الحقيقية، الإنجازات، '
            'التحديات، المتابعين والفرص المهنية.',
            style: TextStyle(
              color: Colors.grey.shade400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اكتشف المواهب'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'ابحث عن موهبة أو مهارة...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFF151515),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'مواهب مقترحة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 1; i <= 5; i++)
            Card(
              color: const Color(0xFF141414),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('$i'),
                ),
                title: Text('موهبة رقم $i'),
                subtitle: const Text('موهبة تستحق الاكتشاف'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TalentDetailsPage(
                        talentName: 'موهبة رقم $i',
                        skill: 'مهارة متنوعة',
                        number: i,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحديات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ChallengeTile(
            title: 'أظهر موهبتك للعالم',
            subtitle: 'تحدٍ مفتوح لجميع المواهب',
            icon: Icons.flash_on,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChallengeDetailsPage(),
                ),
              );
            },
          ),
          ChallengeTile(
            title: 'تحدي الإبداع',
            subtitle: 'ابتكر شيئًا مميزًا',
            icon: Icons.auto_awesome,
            onTap: () {},
          ),
          ChallengeTile(
            title: 'تحدي المهارات',
            subtitle: 'أثبت ما تستطيع فعله',
            icon: Icons.emoji_events,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class ChallengeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ChallengeTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151515),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class ChallengeDetailsPage extends StatelessWidget {
  const ChallengeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل التحدي'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.emoji_events, size: 70),
            const SizedBox(height: 20),
            const Text(
              'أظهر موهبتك للعالم',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'شارك بفيديو يثبت موهبتك وادخل المنافسة.',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 17,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'سيتم تفعيل رفع الفيديو في المرحلة التالية.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.video_camera_back),
                label: const Text('إرسال المشاركة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفرص'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OpportunityTile(
            title: 'فرصة عمل للمواهب',
            company: 'شركة تبحث عن مبدعين',
            icon: Icons.business_center,
          ),
          OpportunityTile(
            title: 'منحة للمبدعين',
            company: 'فرصة دعم للمواهب',
            icon: Icons.school,
          ),
          OpportunityTile(
            title: 'رعاية موهبة',
            company: 'فرصة للتعاون مع الشركات',
            icon: Icons.handshake,
          ),
        ],
      ),
    );
  }
}

class OpportunityTile extends StatelessWidget {
  final String title;
  final String company;
  final IconData icon;

  const OpportunityTile({
    super.key,
    required this.title,
    required this.company,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151515),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(company),
        trailing: FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('سيتم فتح تفاصيل الفرصة قريبًا.'),
              ),
            );
          },
          child: const Text('عرض'),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملفي'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('الإعدادات ستتوفر في المرحلة التالية.'),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 55,
            child: Icon(
              Icons.person,
              size: 55,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ملف موهبتي',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أنشئ ملفك ليكتشفك الجمهور والشركات.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'إنشاء الحساب والملف الشخصي سيتم ربطه بقاعدة البيانات لاحقًا.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('إنشاء ملف الموهبة'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تسجيل الدخول سيتم تفعيله في المرحلة التالية.'),
                ),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.emoji_events),
            ),
            title: Text('تحدٍ جديد'),
            subtitle: Text('هناك تحديات جديدة بانتظارك.'),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.favorite),
            ),
            title: Text('تفاعل جديد'),
            subtitle: Text('موهبتك حصلت على إعجاب جديد.'),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.work),
            ),
            title: Text('فرصة جديدة'),
            subtitle: Text('هناك فرصة قد تناسب مهاراتك.'),
          ),
        ],
      ),
    );
  }
}
