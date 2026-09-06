import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

const String supabaseUrl = 'https://sdbfruxgoefdwyzhkjay.supabase.co';
const String supabasePublishableKey =
    'sb_publishable_t3mt53Npr-LxfprutshcVQ_cQulCux2';

const String videoBucket = 'videos';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
  );

  runApp(const RealityDuelApp());
}

final supabase = Supabase.instance.client;

enum Role {
  talent,
  company,
}

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

/* ============================================================
   APP
============================================================ */

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

/* ============================================================
   GUEST HOME
============================================================ */

class GuestHome extends StatelessWidget {
  const GuestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'REALITY DUEL',
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
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
            ),

            const Expanded(
              child: VideoFeedPage(
                showGuestMessage: true,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoleChoicePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('إنشاء حساب للمشاركة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   AUTHENTICATED HOME
============================================================ */

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
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
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
    } catch (e) {
      debugPrint('Profile loading error: $e');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
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

    final isCompany = profile?.isCompany == true;

    final pages = isCompany
        ? [
            VideoFeedPage(),
            const DiscoverTalentPage(),
            const OpportunitiesPage(),
            ProfilePage(profile: profile),
          ]
        : [
            VideoFeedPage(),
            const DuelsPage(),
            const DiscoverTalentPage(),
            const OpportunitiesPage(),
            ProfilePage(profile: profile),
          ];

    final destinations = isCompany
        ? const [
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle),
              label: 'Feed',
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
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle),
              label: 'Feed',
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
          ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}

/* ============================================================
   REAL VIDEO FEED
============================================================ */

class FeedVideo {
  final String name;
  final String path;
  final String url;

  const FeedVideo({
    required this.name,
    required this.path,
    required this.url,
  });
}

class VideoFeedPage extends StatefulWidget {
  final bool showGuestMessage;

  const VideoFeedPage({
    super.key,
    this.showGuestMessage = false,
  });

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  List<FeedVideo> videos = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final files = await supabase.storage.from(videoBucket).list();

      final result = <FeedVideo>[];

      for (final file in files) {
        final name = file.name;

        final lower = name.toLowerCase();

        final isVideo = lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.m4v') ||
            lower.endsWith('.webm') ||
            lower.endsWith('.avi');

        if (!isVideo) {
          continue;
        }

        final publicUrl = supabase.storage
            .from(videoBucket)
            .getPublicUrl(name);

        result.add(
          FeedVideo(
            name: name,
            path: name,
            url: publicUrl,
          ),
        );
      }

      if (mounted) {
        setState(() {
          videos = result;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint('Video loading error: $e');

      if (mounted) {
        setState(() {
          loading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> requireLogin(String action) async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action متاح للمستخدمين المسجلين.'),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تسجيل الدخول مطلوب'),
          content: Text(
            'يمكنك مشاهدة الفيديوهات بدون حساب، '
            'لكن يجب تسجيل الدخول حتى تتمكن من $action.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignInPage(),
                  ),
                );
              },
              child: const Text('تسجيل الدخول'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 65,
                ),
                const SizedBox(height: 15),
                const Text(
                  'تعذر تحميل الفيديوهات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: loadVideos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.video_library_outlined,
                  size: 75,
                ),
                const SizedBox(height: 15),
                const Text(
                  'لا توجد فيديوهات بعد',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ارفع فيديو إلى Bucket videos في Supabase '
                  'وسوف يظهر هنا تلقائيًا.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: loadVideos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث الفيديوهات'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: loadVideos,
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];

            return VideoFeedItem(
              video: video,
              onLike: () => requireLogin('الإعجاب'),
              onComment: () => requireLogin('التعليق'),
              onFollow: () => requireLogin('المتابعة'),
              onShare: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تجهيز المشاركة.'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/* ============================================================
   VIDEO ITEM
============================================================ */

class VideoFeedItem extends StatefulWidget {
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
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  late VideoPlayerController controller;
  bool initialized = false;
  bool muted = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.url),
    );

    initializeVideo();
  }

  Future<void> initializeVideo() async {
    try {
      await controller.initialize();

      controller.setLooping(true);
      controller.setVolume(1);

      if (mounted) {
        setState(() {
          initialized = true;
        });

        controller.play();
      }
    } catch (e) {
      debugPrint('Video player error: $e');

      if (mounted) {
        setState(() {
          initialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (!initialized) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  void toggleMute() {
    if (!initialized) return;

    setState(() {
      muted = !muted;
      controller.setVolume(muted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: togglePlay,
          child: Container(
            color: Colors.black,
            child: initialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),

        Positioned(
          top: 45,
          left: 18,
          right: 18,
          child: Row(
            children: [
              const Text(
                'REALITY DUEL',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: toggleMute,
                icon: Icon(
                  muted ? Icons.volume_off : Icons.volume_up,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              FeedActionButton(
                icon: Icons.favorite_border,
                label: 'إعجاب',
                onPressed: widget.onLike,
              ),
              const SizedBox(height: 15),
              FeedActionButton(
                icon: Icons.comment_outlined,
                label: 'تعليق',
                onPressed: widget.onComment,
              ),
              const SizedBox(height: 15),
              FeedActionButton(
                icon: Icons.person_add_alt_1,
                label: 'متابعة',
                onPressed: widget.onFollow,
              ),
              const SizedBox(height: 15),
              FeedActionButton(
                icon: Icons.share_outlined,
                label: 'مشاركة',
                onPressed: widget.onShare,
              ),
            ],
          ),
        ),

        Positioned(
          left: 18,
          right: 75,
          bottom: 35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reality Duel',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.video.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        if (initialized && !controller.value.isPlaying)
          const Center(
            child: Icon(
              Icons.play_circle_fill,
              size: 85,
            ),
          ),
      ],
    );
  }
}

class FeedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const FeedActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 30,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/* ============================================================
   ROLE CHOICE
============================================================ */

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

/* ============================================================
   SIGN UP
============================================================ */

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
      showMessage(
        'أدخل الاسم والبريد الإلكتروني وكلمة المرور.',
      );
      return;
    }

    if (password.length < 6) {
      showMessage(
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

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
        throw const AuthException(
          'لم يتم إنشاء المستخدم.',
        );
      }

      /*
       * مهم:
       * حفظ profiles منفصل عن إنشاء حساب Auth.
       *
       * إذا فشل profiles بسبب RLS أو سياسة قاعدة البيانات،
       * لا نعتبر إنشاء الحساب نفسه فاشلًا.
       */
      if (response.session != null) {
        try {
          await saveProfile(user.id);
        } catch (profileError) {
          debugPrint(
            'Profile save error after successful signup: '
            '$profileError',
          );
        }
      }

      if (!mounted) return;

      if (response.session == null) {
        showMessage(
          'تم إنشاء الحساب بنجاح. تحقق من بريدك الإلكتروني ثم سجل الدخول.',
        );

        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      } else {
        /*
         * الحساب تم إنشاؤه وتسجيل الدخول تم.
         * نعود للصفحة الرئيسية.
         */
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      final message = e.message.toLowerCase();

      if (message.contains('already registered') ||
          message.contains('already been registered') ||
          message.contains('user already exists')) {
        showMessage(
          'هذا البريد الإلكتروني مسجل بالفعل. استخدم تسجيل الدخول.',
        );
      } else {
        showMessage(e.message);
      }
    } catch (e) {
      debugPrint('Signup error: $e');

      if (mounted) {
        showMessage(
          'تعذر إنشاء الحساب. تحقق من البيانات وحاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> saveProfile(String userId) async {
    final isTalent = widget.role == Role.talent;
    final isCompany = widget.role == Role.company;

    final displayName =
        isCompany && companyController.text.trim().isNotEmpty
            ? companyController.text.trim()
            : nameController.text.trim();

    final bio = isTalent
        ? headlineController.text.trim()
        : industryController.text.trim();

    await supabase.from('profiles').upsert({
      'id': userId,
      'username': createUsername(nameController.text.trim()),
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
        .replaceAll(
          RegExp(r'[^a-z0-9]+'),
          '_',
        )
        .replaceAll(
          RegExp(r'^_+|_+$'),
          '',
        );

    if (cleaned.isEmpty) {
      return 'user_${DateTime.now().millisecondsSinceEpoch}';
    }

    return '${cleaned}_${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
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
              leading: Icon(
                Icons.verified_user_outlined,
              ),
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
              onPressed: loading
                  ? null
                  : createAccount,
              child: loading
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'إنشاء الحساب',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   SIGN IN
============================================================ */

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
      showMessage(
        'أدخل البريد الإلكتروني وكلمة المرور.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      debugPrint('Sign in error: $e');

      showMessage(
        'حدث خطأ أثناء تسجيل الدخول.',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
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
                  : const Text(
                      'تسجيل الدخول',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   DUELS
============================================================ */

class DuelsPage extends StatelessWidget {
  const DuelsPage({super.key});

  void showDuelMessage(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SignInPage(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'سيتم ربط إنشاء التحدي بقاعدة بيانات Reality Duel.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 25),

          const Text(
            'التحديات',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'كل التحديات الأساسية مجانية.',
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: () => showDuelMessage(context),
            icon: const Icon(Icons.add),
            label: const Text(
              'إنشاء تحدي',
            ),
          ),

          const SizedBox(height: 20),

          const FeatureCard(
            icon: Icons.auto_awesome,
            title: '60-Second Creative Challenge',
            description: 'تحدي عالمي مفتوح.',
          ),

          const FeatureCard(
            icon: Icons.sports_soccer,
            title: 'Street Football Skill',
            description: 'Person vs Person.',
          ),

          const FeatureCard(
            icon: Icons.business,
            title: 'Innovation Duel',
            description: 'Company vs Company.',
          ),

          const FeatureCard(
            icon: Icons.flag,
            title: 'National Talent Challenge',
            description: 'Country vs Country.',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   DISCOVER TALENT
============================================================ */

class DiscoverTalentPage extends StatelessWidget {
  const DiscoverTalentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 25),

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

          const SizedBox(height: 20),

          FeatureCard(
            icon: Icons.people,
            title: 'المواهب',
            description:
                'سيتم تحميل المواهب الحقيقية من Supabase.',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   OPPORTUNITIES
============================================================ */

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 25),

          Text(
            'Opportunities',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'وظائف ومنح ورعايات ومشاريع.',
          ),

          SizedBox(height: 20),

          FeatureCard(
            icon: Icons.work,
            title: 'الوظائف',
            description:
                'سيتم تحميل الوظائف من Supabase.',
          ),

          FeatureCard(
            icon: Icons.school,
            title: 'المنح',
            description:
                'فرص تعليمية ومنح.',
          ),

          FeatureCard(
            icon: Icons.star,
            title: 'الرعايات',
            description:
                'فرص رعاية للمواهب.',
          ),

          FeatureCard(
            icon: Icons.handshake,
            title: 'المشاريع',
            description:
                'مشاريع وتعاونات.',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   PROFILE
============================================================ */

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

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 30),

          const CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 45,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            profile?.displayName.isNotEmpty == true
                ? profile!.displayName
                : 'New User',
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
                  leading: const Icon(
                    Icons.video_library,
                  ),
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
            label: const Text(
              'تسجيل الخروج',
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   COMPANY / TALENT SHARED CARDS
============================================================ */

class TalentHomePage extends StatelessWidget {
  final ProfileData? profile;

  const TalentHomePage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return const VideoFeedPage();
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
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 25),

          const Text(
            'EMPLOYER HUB',
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            profile?.displayName.isNotEmpty == true
                ? profile!.displayName
                : 'الشركة',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          const FeatureCard(
            icon: Icons.people,
            title: 'اكتشاف المواهب',
            description:
                'ابحث عن المواهب حسب المهارات والأداء.',
          ),

          const FeatureCard(
            icon: Icons.post_add,
            title: 'نشر فرصة',
            description:
                'وظيفة أو منحة أو رعاية أو مشروع.',
          ),

          const FeatureCard(
            icon: Icons.video_call,
            title: 'المقابلات',
            description:
                'إدارة المرشحين داخل المنصة.',
          ),

          const FeatureCard(
            icon: Icons.analytics,
            title: 'تحليلات المواهب',
            description:
                'مقارنة المرشحين بناءً على الأداء.',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   INPUT FIELD
============================================================ */

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
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
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

/* ============================================================
   FEATURE CARD
============================================================ */

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
          padding: const EdgeInsets.only(
            top: 5,
          ),
          child: Text(description),
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}
