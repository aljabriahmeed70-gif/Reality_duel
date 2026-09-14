import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

const String supabaseUrl =
    'https://sdbfruxgoefdwyzhkjay.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_t3mt53Npr-LxfprutshcVQ_cQulCux2';

const String videoBucket = 'videos';

final SupabaseClient supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const RealityDuelApp());
}

class RealityDuelApp extends StatefulWidget {
  const RealityDuelApp({super.key});

  @override
  State<RealityDuelApp> createState() => _RealityDuelAppState();
}

class _RealityDuelAppState extends State<RealityDuelApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reality Duel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF7557FF),
        scaffoldBackgroundColor: const Color(0xFF080911),
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  StreamSubscription<AuthState>? authSubscription;

  Session? session;

  @override
  void initState() {
    super.initState();

    session = supabase.auth.currentSession;

    authSubscription =
        supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      setState(() {
        session = data.session;
      });
    });
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const GuestHome();
    }

    return const MainShell();
  }
}

/* ============================================================
   GUEST HOME
   ============================================================ */

class GuestHome extends StatefulWidget {
  const GuestHome({super.key});

  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const VideoFeedPage(),
      const DiscoverPage(),
      const OpportunitiesPage(),
      const LoginPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Login',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   MAIN SHELL
   ============================================================ */

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const VideoFeedPage(),
      const DiscoverPage(),
      const OpportunitiesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const UploadVideoPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Jobs',
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

/* ============================================================
   VIDEO MODEL
   ============================================================ */

class VideoItem {
  final String id;
  final String url;
  final String caption;
  final int views;
  final int likes;
  final int comments;
  final String? userId;

  VideoItem({
    required this.id,
    required this.url,
    required this.caption,
    required this.views,
    required this.likes,
    required this.comments,
    this.userId,
  });

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    String url = '';

    final directUrl = map['video_url']?.toString();

    if (directUrl != null && directUrl.isNotEmpty) {
      url = directUrl;
    } else {
      final path = map['storage_path']?.toString();

      if (path != null && path.isNotEmpty) {
        url = supabase.storage
            .from(videoBucket)
            .getPublicUrl(path);
      }
    }

    return VideoItem(
      id: map['id'].toString(),
      url: url,
      caption: map['caption']?.toString() ?? '',
      views: _toInt(map['views_count']),
      likes: _toInt(map['likes_count']),
      comments: _toInt(map['comments_count']),
      userId: map['user_id']?.toString(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;

  return int.tryParse(
        value?.toString() ?? '0',
      ) ??
      0;
}

/* ============================================================
   VIDEO FEED
   ============================================================ */

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final PageController controller = PageController();

  List<VideoItem> videos = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final response = await supabase
          .from('videos')
          .select(
            'id,user_id,storage_path,video_url,caption,'
            'views_count,likes_count,comments_count,created_at',
          )
          .order(
            'created_at',
            ascending: false,
          );

      final list = (response as List)
          .map(
            (item) => VideoItem.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((video) => video.url.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        videos = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
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

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reality Duel'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'تعذر تحميل الفيديوهات',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: loadVideos,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reality Duel'),
        ),
        body: RefreshIndicator(
          onRefresh: loadVideos,
          child: ListView(
            children: const [
              SizedBox(height: 250),
              Center(
                child: Text(
                  'لا توجد فيديوهات حتى الآن',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadVideos,
        child: PageView.builder(
          controller: controller,
          scrollDirection: Axis.vertical,
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return VideoCard(
              video: videos[index],
            );
          },
        ),
      ),
    );
  }
}

/* ============================================================
   VIDEO CARD
   ============================================================ */

class VideoCard extends StatefulWidget {
  final VideoItem video;

  const VideoCard({
    super.key,
    required this.video,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController videoController;

  bool initialized = false;
  bool playing = false;
  bool liked = false;
  bool loadingLike = false;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.url),
    );

    try {
      await videoController.initialize();

      await videoController.setLooping(true);

      if (!mounted) return;

      setState(() {
        initialized = true;
        playing = true;
      });

      await videoController.play();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        initialized = false;
      });
    }
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  Future<void> toggleLike() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
      return;
    }

    if (loadingLike) return;

    setState(() {
      loadingLike = true;
    });

    try {
      if (liked) {
        await supabase
            .from('likes')
            .delete()
            .eq('video_id', widget.video.id)
            .eq('user_id', user.id);

        setState(() {
          liked = false;
        });
      } else {
        await supabase.from('likes').insert({
          'video_id': widget.video.id,
          'user_id': user.id,
        });

        setState(() {
          liked = true;
        });
      }
    } catch (e) {
      showMessage(
        context,
        'تعذر تنفيذ الإعجاب: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingLike = false;
        });
      }
    }
  }

  void togglePlay() {
    if (!initialized) return;

    if (videoController.value.isPlaying) {
      videoController.pause();

      setState(() {
        playing = false;
      });
    } else {
      videoController.play();

      setState(() {
        playing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.black,
          ),

          if (initialized)
            Center(
              child: AspectRatio(
                aspectRatio: videoController.value.aspectRatio,
                child: VideoPlayer(videoController),
              ),
            ),

          if (!initialized)
            const Center(
              child: CircularProgressIndicator(),
            ),

          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                _ActionButton(
                  icon: liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: '${widget.video.likes}',
                  color: liked ? Colors.red : Colors.white,
                  onTap: toggleLike,
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  icon: Icons.comment,
                  label: '${widget.video.comments}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CommentsPage(
                          videoId: widget.video.id,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  icon: Icons.visibility,
                  label: '${widget.video.views}',
                  onTap: () {},
                ),
              ],
            ),
          ),

          Positioned(
            left: 18,
            right: 80,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reality Duel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.video.caption.isNotEmpty)
                  Text(
                    widget.video.caption,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),

          if (!playing && initialized)
            const Center(
              child: Icon(
                Icons.play_arrow,
                size: 80,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }
}

/* ============================================================
   ACTION BUTTON
   ============================================================ */

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 34,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   LOGIN
   ============================================================ */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscure = true;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(
        context,
        'أدخل البريد الإلكتروني وكلمة المرور',
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
      showMessage(
        context,
        e.message,
      );
    } catch (e) {
      showMessage(
        context,
        'حدث خطأ أثناء تسجيل الدخول: $e',
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 35),
              const Icon(
                Icons.sports_mma,
                size: 80,
              ),
              const SizedBox(height: 15),
              const Text(
                'REALITY DUEL',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                    icon: Icon(
                      obscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'دخول',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: loading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const SignUpPage(),
                          ),
                        );
                      },
                child: const Text(
                  'إنشاء حساب جديد',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   SIGN UP
   ============================================================ */

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool loading = false;
  bool obscure = true;

  Future<void> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      showMessage(
        context,
        'أكمل جميع البيانات',
      );
      return;
    }

    if (password.length < 6) {
      showMessage(
        context,
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'display_name': name,
        },
      );

      final user = response.user;

      if (user == null) {
        throw Exception(
          'لم يتم إنشاء المستخدم',
        );
      }

      try {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'full_name': name,
          'display_name': name,
        });
      } catch (_) {
        // إذا كان trigger ينشئ profile تلقائياً
        // لا نوقف إنشاء الحساب.
      }

      if (!mounted) return;

      if (response.session == null) {
        showMessage(
          context,
          'تم إنشاء الحساب. تحقق من بريدك الإلكتروني إذا كان تأكيد البريد مفعلاً.',
        );

        Navigator.of(context).pop();
      } else {
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      }
    } on AuthException catch (e) {
      showMessage(
        context,
        e.message,
      );
    } catch (e) {
      showMessage(
        context,
        'حدث خطأ أثناء إنشاء الحساب: $e',
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'أنشئ حساب Reality Duel',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person),
                 
