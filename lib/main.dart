import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

late final SupabaseClient supabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  supabase = Supabase.instance.client;

  runApp(const RealityDuelApp());
}

class RealityDuelApp extends StatefulWidget {
  const RealityDuelApp({super.key});

  @override
  State<RealityDuelApp> createState() => _RealityDuelAppState();
}

class _RealityDuelAppState extends State<RealityDuelApp> {
  String language = 'English';

  void changeLanguage(String value) {
    setState(() {
      language = value;
    });
  }

  Locale get currentLocale {
    switch (language) {
      case 'العربية':
        return const Locale('ar');
      case 'Español':
        return const Locale('es');
      case 'Français':
        return const Locale('fr');
      case 'Türkçe':
        return const Locale('tr');
      case '中文':
        return const Locale('zh');
      default:
        return const Locale('en');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reality Duel',
      locale: currentLocale,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: AppShell(
        language: language,
        onLanguageChanged: changeLanguage,
      ),
    );
  }
}

/* ============================================================
   HELPERS
   ============================================================ */

bool get loggedIn => supabase.auth.currentUser != null;

bool isArabic(String language) => language == 'العربية';

String t(
  String language, {
  required String en,
  required String ar,
  String? es,
  String? fr,
  String? tr,
  String? zh,
}) {
  switch (language) {
    case 'العربية':
      return ar;
    case 'Español':
      return es ?? en;
    case 'Français':
      return fr ?? en;
    case 'Türkçe':
      return tr ?? en;
    case '中文':
      return zh ?? en;
    default:
      return en;
  }
}

void snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

Future<bool> requireLogin(
  BuildContext context,
  String language,
) async {
  if (supabase.auth.currentUser != null) {
    return true;
  }

  final arabic = isArabic(language);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          t(
            language,
            en: 'Sign in required',
            ar: 'تسجيل الدخول مطلوب',
          ),
        ),
        content: Text(
          t(
            language,
            en: 'You can watch videos without an account. Sign in to like, comment, follow, upload videos, create duels, and apply for opportunities.',
            ar: 'يمكنك مشاهدة الفيديوهات بدون حساب. يجب تسجيل الدخول للإعجاب والتعليق والمتابعة ورفع الفيديوهات وإنشاء المواجهات والتقديم على الفرص.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(arabic ? 'لاحقًا' : 'Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(arabic ? 'تسجيل الدخول' : 'Sign in'),
          ),
        ],
      );
    },
  );

  if (result == true && context.mounted) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(language: language),
      ),
    );
  }

  return supabase.auth.currentUser != null;
}

Future<void> showLanguagePicker(
  BuildContext context,
  String current,
  ValueChanged<String> onChanged,
) async {
  final languages = [
    'English',
    'العربية',
    'Español',
    'Français',
    'Türkçe',
    '中文',
  ];

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Language / اللغة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...languages.map(
              (language) => ListTile(
                leading: Icon(
                  language == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(language),
                onTap: () {
                  onChanged(language);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

/* ============================================================
   APP SHELL
   ============================================================ */

class AppShell extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;

  const AppShell({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final arabic = isArabic(widget.language);

    final pages = [
      FeedPage(
        language: widget.language,
        onLanguageChanged: widget.onLanguageChanged,
      ),
      DuelsPage(language: widget.language),
      DiscoverPage(language: widget.language),
      OpportunitiesPage(language: widget.language),
      ProfilePage(language: widget.language),
    ];

    final labels = [
      t(
        widget.language,
        en: 'Feed',
        ar: 'الرئيسية',
        es: 'Inicio',
        fr: 'Accueil',
        tr: 'Akış',
        zh: '首页',
      ),
      t(
        widget.language,
        en: 'Duels',
        ar: 'المواجهات',
        es: 'Duelos',
        fr: 'Duels',
        tr: 'Düellolar',
        zh: '对决',
      ),
      t(
        widget.language,
        en: 'Talent',
        ar: 'المواهب',
        es: 'Talento',
        fr: 'Talents',
        tr: 'Yetenek',
        zh: '人才',
      ),
      t(
        widget.language,
        en: 'Opportunities',
        ar: 'الفرص',
        es: 'Oportunidades',
        fr: 'Opportunités',
        tr: 'Fırsatlar',
        zh: '机会',
      ),
      t(
        widget.language,
        en: 'Profile',
        ar: 'حسابي',
        es: 'Perfil',
        fr: 'Profil',
        tr: 'Profil',
        zh: '我的',
      ),
    ];

    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.play_circle_outline),
              selectedIcon: const Icon(Icons.play_circle),
              label: labels[0],
            ),
            NavigationDestination(
              icon: const Icon(Icons.sports_mma_outlined),
              selectedIcon: const Icon(Icons.sports_mma),
              label: labels[1],
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: labels[2],
            ),
            NavigationDestination(
              icon: const Icon(Icons.work_outline),
              selectedIcon: const Icon(Icons.work),
              label: labels[3],
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: labels[4],
            ),
          ],
        ),
        floatingActionButton: currentIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  showLanguagePicker(
                    context,
                    widget.language,
                    widget.onLanguageChanged,
                  );
                },
                child: const Icon(Icons.language),
              )
            : null,
      ),
    );
  }
}

/* ============================================================
   FEED MODEL
   ============================================================ */

class FeedVideo {
  final String id;
  final String userId;
  final String videoUrl;
  final String storagePath;
  final String caption;
  final int likes;
  final int comments;
  final int views;

  const FeedVideo({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.storagePath,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.views,
  });

  factory FeedVideo.fromMap(Map<String, dynamic> map) {
    return FeedVideo(
      id: '${map['id'] ?? ''}',
      userId: '${map['user_id'] ?? ''}',
      videoUrl: '${map['video_url'] ?? ''}',
      storagePath: '${map['storage_path'] ?? ''}',
      caption: '${map['caption'] ?? ''}',
      likes: _number(map['likes_count']),
      comments: _number(map['comments_count']),
      views: _number(map['views_count']),
    );
  }

  static int _number(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  FeedVideo copyWith({
    int? likes,
    int? comments,
    int? views,
  }) {
    return FeedVideo(
      id: id,
      userId: userId,
      videoUrl: videoUrl,
      storagePath: storagePath,
      caption: caption,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
    );
  }
}

/* ============================================================
   FEED
   ============================================================ */

class FeedPage extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;

  const FeedPage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final PageController pageController = PageController();

  List<FeedVideo> videos = [];
  bool loading = true;
  String? error;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> loadVideos() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    bool loadedFromDatabase = false;

    try {
      final result = await supabase
          .from('videos')
          .select(
            'id,user_id,storage_path,video_url,caption,status,likes_count,comments_count,views_count,created_at',
          )
          .eq('status', 'published')
          .order('created_at', ascending: false);

      final databaseVideos = <FeedVideo>[];

      for (final item in result) {
        final map = Map<String, dynamic>.from(item);

        String url = '${map['video_url'] ?? ''}';
        final storagePath = '${map['storage_path'] ?? ''}';

        if (url.isEmpty && storagePath.isNotEmpty) {
          url = supabase.storage
              .from('videos')
              .getPublicUrl(storagePath);
          map['video_url'] = url;
        }

        if (url.isNotEmpty) {
          databaseVideos.add(
            FeedVideo.fromMap(map),
          );
        }
      }

      if (databaseVideos.isNotEmpty) {
        loadedFromDatabase = true;

        if (mounted) {
          setState(() {
            videos = databaseVideos;
            loading = false;
          });
        }
      }
    } catch (_) {
      // Storage fallback below.
    }

    if (loadedFromDatabase) return;

    try {
      final files = await supabase.storage
          .from('videos')
          .list();

      final storageVideos = <FeedVideo>[];

      for (final file in files) {
        final name = file.name.toLowerCase();

        final isVideo =
            name.endsWith('.mp4') ||
            name.endsWith('.mov') ||
            name.endsWith('.m4v') ||
            name.endsWith('.webm') ||
            name.endsWith('.avi');

        if (!isVideo) continue;

        final url = supabase.storage
            .from('videos')
            .getPublicUrl(file.name);

        storageVideos.add(
          FeedVideo(
            id: '',
            userId: '',
            videoUrl: url,
            storagePath: file.name,
            caption: '',
            likes: 0,
            comments: 0,
            views: 0,
          ),
        );
      }

      if (mounted) {
        setState(() {
          videos = storageVideos;
          loading = false;
          error = storageVideos.isEmpty
              ? t(
                  widget.language,
                  en: 'No videos available yet.',
                  ar: 'لا توجد فيديوهات متاحة حالياً.',
                )
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = '$e';
        });
      }
    }
  }

  Future<void> openUpload() async {
    if (!await requireLogin(context, widget.language)) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadVideoPage(
          language: widget.language,
        ),
      ),
    );

    await loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    final arabic = isArabic(widget.language);

    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (loading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (videos.isEmpty)
              _EmptyFeed(
                language: widget.language,
                onUpload: openUpload,
                onRefresh: loadVideos,
              )
            else
              RefreshIndicator(
                onRefresh: loadVideos,
                child: PageView.builder(
                  controller: pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: videos.length,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return VideoFeedItem(
                      key: ValueKey(
                        '${videos[index].videoUrl}-$index',
                      ),
                      video: videos[index],
                      language: widget.language,
                      active: index == currentPage,
                      onChanged: (updated) {
                        if (!mounted) return;
                        setState(() {
                          videos[index] = updated;
                        });
                      },
                    );
                  },
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  const Text(
                    'REALITY DUEL',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: openUpload,
                    icon: const Icon(
                      Icons.video_call_outlined,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showLanguagePicker(
                        context,
                        widget.language,
                        widget.onLanguageChanged,
                      );
                    },
                    icon: const Icon(Icons.language),
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

class _EmptyFeed extends StatelessWidget {
  final String language;
  final VoidCallback onUpload;
  final Future<void> Function() onRefresh;

  const _EmptyFeed({
    required this.language,
    required this.onUpload,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final arabic = isArabic(language);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .75,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.video_library_outlined,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      arabic
                          ? 'لا توجد فيديوهات منشورة بعد'
                          : 'No videos available yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onUpload,
                      icon: const Icon(Icons.upload),
                      label: Text(
                        arabic
                            ? 'رفع فيديو'
                            : 'Upload video',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   VIDEO ITEM
   ============================================================ */

class VideoFeedItem extends StatefulWidget {
  final FeedVideo video;
  final String language;
  final bool active;
  final ValueChanged<FeedVideo> onChanged;

  const VideoFeedItem({
    super.key,
    required this.video,
    required this.language,
    required this.active,
    required this.onChanged,
  });

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  VideoPlayerController? player;

  bool initialized = false;
  bool failed = false;
  bool liked = false;
  bool following = false;
  bool busy = false;

  bool get arabic => isArabic(widget.language);

  @override
  void initState() {
    super.initState();
    initializePlayer();
    loadInteractionState();
  }

  @override
  void didUpdateWidget(
    covariant VideoFeedItem oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video.videoUrl !=
        widget.video.videoUrl) {
      disposePlayer();
      initializePlayer();
      loadInteractionState();
    }

    if (oldWidget.active != widget.active) {
      setPlaying(widget.active);
    }
  }

  Future<void> initializePlayer() async {
    try {
      if (widget.video.videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }

      final controller =
          VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );

      player = controller;

      await controller.initialize();
      await controller.setLooping(true);

      if (!mounted) return;

      setState(() {
        initialized = true;
      });

      if (widget.active) {
        await controller.play();
        recordView();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          failed = true;
        });
      }
    }
  }

  Future<void> setPlaying(bool value) async {
    final p = player;

    if (p == null || !initialized) return;

    if (value) {
      await p.play();
    } else {
      await p.pause();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadInteractionState() async {
    final user = supabase.auth.currentUser;

    if (user == null || widget.video.id.isEmpty) {
      return;
    }

    try {
      final result = await supabase.rpc(
        'has_video_like',
        params: {
          'p_video_id': widget.video.id,
        },
      );

      if (mounted) {
        setState(() {
          liked = result == true;
        });
      }
    } catch (_) {}

    if (widget.video.userId.isEmpty) return;

    try {
      final result = await supabase.rpc(
        'is_following',
        params: {
          'p_target_user_id':
              widget.video.userId,
        },
      );

      if (mounted) {
        setState(() {
          following = result == true;
        });
      }
    } catch (_) {}
  }

  Future<void> recordView() async {
    if (widget.video.id.isEmpty) return;

    try {
      await supabase.rpc(
        'record_video_view',
        params: {
          'p_video_id': widget.video.id,
        },
      );
    } catch (_) {}
  }

  Future<void> toggleLike() async {
    if (!await requireLogin(
      context,
      widget.language,
    )) {
      return;
    }

    if (widget.video.id.isEmpty || busy) return;

    setState(() {
      busy = true;
    });

    try {
      final result = await supabase.rpc(
        'toggle_video_like',
        params: {
          'p_video_id': widget.video.id,
        },
      );

      final newLiked = result == true;

      int newLikes = widget.video.likes;

      if (newLiked && !liked) {
        newLikes++;
      } else if (!newLiked && liked) {
        newLikes--;
      }

      if (newLikes < 0) newLikes = 0;

      if (mounted) {
        setState(() {
          liked = newLiked;
          busy = false;
        });

        widget.onChanged(
          widget.video.copyWith(
            likes: newLikes,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          busy = false;
        });

        snack(context, '$e');
      }
    }
  }

  Future<void> toggleFollow() async {
    if (!await requireLogin(
      context,
      widget.language,
    )) {
      return;
    }

    if (widget.video.userId.isEmpty || busy) {
      return;
    }

    setState(() {
      busy = true;
    });

    try {
      final result = await supabase.rpc(
        'toggle_follow',
        params: {
          'p_target_user_id':
              widget.video.userId,
        },
      );

      if (mounted) {
        setState(() {
          following = result == true;
          busy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          busy = false;
        });

        snack(context, '$e');
      }
    }
  }

  Future<void> addComment() async {
    if (!await requireLogin(
      context,
      widget.language,
    )) {
      return;
    }

    if (widget.video.id.isEmpty) {
      snack(
        context,
        arabic
            ? 'هذا الفيديو موجود في التخزين فقط ولا يملك سجلاً في جدول videos.'
            : 'This video exists in Storage but has no videos table record.',
      );
      return;
    }

    final controller = TextEditingController();

    final comment = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            arabic
                ? 'إضافة تعليق'
                : 'Add comment',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: arabic
                  ? 'اكتب تعليقك...'
                  : 'Write your comment...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                arabic ? 'إلغاء' : 'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child: Text(
                arabic ? 'نشر' : 'Post',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (comment == null || comment.isEmpty) {
      return;
    }

    try {
      await supabase.rpc(
        'add_video_comment',
        params: {
          'p_video_id': widget.video.id,
          'p_text': comment,
        },
      );

      widget.onChanged(
        widget.video.copyWith(
          comments: widget.video.comments + 1,
        ),
      );

      if (mounted) {
        snack(
          context,
          arabic
              ? 'تم نشر التعليق'
              : 'Comment posted',
        );
      }
    } catch (e) {
      if (mounted) snack(context, '$e');
    }
  }

  Future<void> shareVideo() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            arabic
                ? 'رابط الفيديو'
                : 'Video link',
          ),
          content: SelectableText(
            widget.video.videoUrl,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                arabic ? 'إغلاق' : 'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  void disposePlayer() {
    final old = player;
    player = null;
    initialized = false;
    old?.dispose();
  }

  @override
  void dispose() {
    disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = player;

    return GestureDetector(
      onTap: () {
        if (p == null || !initialized) return;

        if (p.value.isPlaying) {
          p.pause();
        } else {
          p.play();
        }

        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),

          if (initialized && p != null)
            Center(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: p.value.size.width,
                  height: p.value.size.height,
                  child: VideoPlayer(p),
                ),
              ),
            )
          else if (failed)
            const Center(
              child: Icon(
                Icons.error_outline,
                size: 70,
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),

          const _VideoGradient(),

          Positioned(
            left: 16,
            right: 90,
            bottom: 24,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  '@RealityDuel',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.video.caption.isEmpty
                      ? (arabic
                          ? 'العالم هو ساحتك.'
                          : 'The World Is Your Arena.')
                      : widget.video.caption,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 8,
            bottom: 90,
            child: Column(
              children: [
                ActionButton(
                  icon: liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: '${widget.video.likes}',
                  onTap: toggleLike,
                ),
                ActionButton(
                  icon: Icons.comment_outlined,
                  label: '${widget.video.comments}',
                  onTap: addComment,
                ),
                ActionButton(
                  icon: Icons.share_outlined,
                  label: arabic
                      ? 'مشاركة'
                      : 'Share',
                  onTap: shareVideo,
                ),
                ActionButton(
                  icon: following
                      ? Icons.person
                      : Icons.person_add_alt_1,
                  label: following
                      ? (arabic
                          ? 'متابَع'
                          : 'Following')
                      : (arabic
                          ? 'متابعة'
                          : 'Follow'),
                  onTap: toggleFollow,
                ),
                ActionButton(
                  icon: Icons.visibility_outlined,
                  label: '${widget.video.views}',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoGradient extends StatelessWidget {
  const _VideoGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(.45),
              Colors.transparent,
              Colors.black.withOpacity(.75),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: CircleAvatar(
              radius: 25,
              backgroundColor:
                  Colors.black.withOpacity(.5),
              child: Icon(
                icon,
                size: 27,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   UPLOAD VIDEO
   ============================================================ */

class UploadVideoPage extends StatefulWidget {
  final String language;

  const UploadVideoPage({
    super.key,
    required this.language,
  });

  @override
  State<UploadVideoPage> createState() =>
      _UploadVideoPageState();
}

class _UploadVideoPageState
    extends State<UploadVideoPage> {
  final captionController =
      TextEditingController();

  PlatformFile? selectedFile;
  bool uploading = false;

  bool get arabic => isArabic(widget.language);

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> pickVideo() async {
    try {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      setState(() {
        selectedFile = result.files.first;
      });
    } catch (e) {
      if (mounted) snack(context, '$e');
    }
  }

  Future<void> uploadVideo() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await requireLogin(
        context,
        widget.language,
      );
      return;
    }

    if (selectedFile == null ||
        selectedFile!.bytes == null) {
      snack(
        context,
        arabic
            ? 'اختر فيديو أولاً'
            : 'Choose a video first',
      );
      return;
    }

    setState(() {
      uploading = true;
    });

    try {
      final extension =
          selectedFile!.extension
                  ?.toLowerCase() ??
              'mp4';

      final storagePath =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await supabase.storage
          .from('videos')
          .uploadBinary(
            storagePath,
            selectedFile!.bytes!,
            fileOptions: FileOptions(
              contentType:
                  _contentType(extension),
              upsert: false,
            ),
          );

      final publicUrl = supabase.storage
          .from('videos')
          .getPublicUrl(storagePath);

      await supabase.rpc(
        'create_video_record',
        params: {
          'p_storage_path': storagePath,
          'p_video_url': publicUrl,
          'p_caption':
              captionController.text.trim(),
        },
      );

      if (!mounted) return;

      snack(
        context,
        arabic
            ? 'تم رفع الفيديو ونشره بنجاح'
            : 'Video uploaded and published successfully',
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        snack(context, '$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          uploading = false;
        });
      }
    }
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'm4v':
        return 'video/x-m4v';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'video/mp4';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            arabic
                ? 'رفع فيديو'
                : 'Upload Video',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.video_camera_back_outlined,
              size: 90,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed:
                  uploading ? null : pickVideo,
              icon: const Icon(
                Icons.video_library_outlined,
              ),
              label: Text(
                selectedFile == null
                    ? (arabic
                        ? 'اختيار فيديو'
                        : 'Choose video')
                    : selectedFile!.name,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: captionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText:
                    arabic ? 'الوصف' : 'Caption',
                hintText: arabic
                    ? 'اكتب وصف الفيديو...'
                    : 'Write a caption...',
                border:
                    const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed:
                  uploading ? null : uploadVideo,
              icon: uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.cloud_upload,
                    ),
              label: Text(
                arabic
                    ? 'رفع ونشر'
                    : 'Upload & Publish',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   DUELS
   ============================================================ */

class DuelsPage extends StatefulWidget {
  final String language;

  const DuelsPage({
    super.key,
    required this.language,
  });

  @override
  State<DuelsPage> createState() =>
      _DuelsPageState();
}

class _DuelsPageState extends State<DuelsPage> {
  List<Map<String, dynamic>> duels = [];
  bool loading = true;

  bool get arabic => isArabic(widget.language);

  @override
  void initState() {
    super.initState();
    loadDuels();
  }

  Future<void> loadDuels() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await supabase
          .from('duels')
          .select(
            'id,creator_id,title,description,challenge_type,status,created_at',
          )
          .order(
            'created_at',
            ascending: false,
          );

      if (mounted) {
        setState(() {
          duels = (result as List)
              .map(
                (e) => Map<String, dynamic>.from(e),
              )
              .toList();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        snack(context, '$e');
      }
    }
  }

  Future<void> createDuel() async {
    if (!await requireLogin(
      context,
      widget.language,
    )) {
      return;
    }

    final title = TextEditingController();
    final description =
        TextEditingController();
    final challengeType =
        TextEditingController(text: 'video');

    final data =
        await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            arabic
                ? 'إنشاء مواجهة'
                : 'Create Duel',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    labelText:
                        arabic ? 'العنوان' : 'Title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText:
                        arabic ? 'الوصف' : 'Description',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: challengeType,
                  decoration: InputDecoration(
                    labelText: arabic
                        ? 'نوع التحدي'
                        : 'Challenge type',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: Text(
                arabic ? 'إلغاء' : 'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  [
                    title.text.trim(),
                    description.text.trim(),
                    challengeType.text.trim(),
                  ],
                );
              },
              child: Text(
                arabic ? 'إنشاء' : 'Create',
              ),
            ),
          ],
        );
      },
    );

    title.dispose();
    description.dispose();
    challengeType.dispose();

    if (data == null ||
        data.length != 3 ||
        data[0].isEmpty) {
      return;
    }

    try {
      await supabase.rpc(
        'create_duel',
        params: {
          'p_title': data[0],
          'p_description': data[1],
          'p_challenge_type':
              data[2].isEmpty
                  ? 'video'
                  : data[2],
        },
      );

      await loadDuels();
    } catch (e) {
      if (mounted) snack(context, '$e');
    }
  }

  Future<void> joinDuel(String duelId) async {
    if (!await requireLogin(
      context,
      widget.language,
    )) {
      return;
    }

    if (duelId.isEmpty) return;

    try {
      await supabase.rpc(
        'join_duel',
        params: {
          'p_duel_id': duelId,
        },
      );

      if (mounted) {
        snack(
          context,
          arabic
              ? 'تم الانضمام إلى المواجهة'
              : 'Joined the duel',
        );
      }
    } catch (e) {
      if (mounted) snack(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            arabic ? 'المواجهات' : 'Duels',
          ),
          actions: [
            IconButton(
              onPressed: loadDuels,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton:
            FloatingActionButton.extended(
          onPressed: createDuel,
          icon: const Icon(Icons.add),
          label: Text(
            arabic
                ? 'مواجهة جديدة'
                : 'New Duel',
          ),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : duels.isEmpty
                ? Center(
                    child: Text(
                      arabic
                          ? 'لا توجد مواجهات بعد'
                          : 'No duels yet',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadDuels,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.all(12),
                      itemCount: duels.length,
                      itemBuilder:
                          (context, index) {
                        final duel =
                            duels[index];

                        return Card(
                          child: ListTile(
                            leading:
                                const CircleAvatar(
                              child: Icon(
                                Icons.sports_mma,
                              ),
                            ),
                            title: Text(
                              '${duel['title'] ?? ''}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${duel['description'] ?? ''}\n'
                              '${duel['challenge_type'] ?? ''}',
                            ),
                            isThreeLine: true,
                            trailing:
                                FilledButton(
                              onPressed: () =>
                                  joinDuel(
                                '${duel['id'] ?? ''}',
                              ),
                              child: Text(
                                arabic
                                    ? 'انضم'
                                    : 'Join',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

/* ============================================================
   DISCOVER TALENT
   ============================================================ */

class DiscoverPage extends StatefulWidget {
  final String language;

  const DiscoverPage({
    super.key,
    required this.language,
  });

  @override
  State<DiscoverPage> createState() =>
      _DiscoverPageState();
}

class _DiscoverPageState
    extends State<DiscoverPage> {
  List<Map<String, dynamic>> profiles = [];
  bool loading = true;
  String search = '';

  bool get arabic => isArabic(widget.language);

  @override
  void initState() {
    super.initState();
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await supabase
          .from('profiles')
          .select(
            'user_id,display_name,username,bio,country,avatar_url,role,talent_score,follower_count,following_count,wins_count',
          )
          .order(
            'talent_score',
            ascending: false,
          );

      if (mounted) {
        setState(() {
          profiles = (result as List)
              .map(
                (e) => Map<String, dynamic>.from(e),
              )
              .toList();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        snack(context, '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = search.trim().toLowerCase();

    final filtered = profiles.where((profile) {
      if (query.isEmpty) return true;

      final text =
          '${profile['display_name'] ?? ''} '
          '${profile['username'] ?? ''} '
          '${profile['country'] ?? ''}'
              .toLowerCase();

      return text.contains(query);
    }).toList();

    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            arabic
                ? 'اكتشف المواهب'
                : 'Discover Talent',
          ),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: loadProfiles,
                child: ListView(
                  padding:
                      const EdgeInsets.all(14),
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                      },
                      decoration:
                          InputDecoration(
                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),
                        hintText: arabic
                            ? 'ابحث عن موهبة...'
                            : 'Search talent...',
                        border:
                            const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (filtered.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            arabic
                                ? 'لا توجد نتائج'
                                : 'No results',
                          ),
                        ),
                      ),
                    ...filtered.map(
                      (profile) => ProfileCard(
                        profile: profile,
                        language:
                            widget.language,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PublicProfilePage(
                                profile: profile,
                                language:
                                    widget.language,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String language;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar =
        '${profile['avatar_url'] ?? ''}';

    final name =
        '${profile['display_name'] ?? ''}'
                .trim()
                .isEmpty
            ? '@${profile['username'] ?? 'talent'}'
            : '${profile['display_name']}';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: avatar.isNotEmpty
              ? NetworkImage(avatar)
              : null,
          child: avatar.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '@${profile['username'] ?? ''}\n'
          '${profile['country'] ?? ''} • '
          '${t(
            language,
            en: 'Score',
            ar: 'النقاط',
          )}: '
          '${profile['talent_score'] ?? 0}',
        ),
        isThreeLine: true,
        trailing:
            const Icon(Icons.chevron_right),
      ),
    );
  }
}

/* ============================================================
   PUBLIC PROFILE
   ============================================================ */

class PublicProfilePage
    extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String language;

  const PublicProfilePage({
    super.key,
    required this.profile,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final arabic = isArabic(language);
    final avatar =
        '${profile['avatar_url'] ?? ''}';

    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            arabic
                ? 'ملف الموهبة'
                : 'Talent Profile',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: avatar.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 60,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                '${profile['display_name'] ?? profile['username'] ?? ''}',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                '@${profile['username'] ?? ''}',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${profile['bio'] ?? ''}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            StatsRow(
              items: [
                StatItem(
                  arabic
                      ? 'المتابعون'
                      : 'Followers',
                  '${profile['follower_count'] ?? 0}',
                ),
                StatItem(
                  arabic
                      ? 'المتابَعون'
                      : 'Following',
                  '${profile['following_count'] ?? 0}',
                ),
                StatItem(
                  arabic
                      ? 'الانتصارات'
                      : 'Wins',
                  '${profile['wins_count'] ?? 0}',
                ),
                StatItem(
                  arabic
                      ? 'النقاط'
                      : 'Score',
                  '${profile['talent_score'] ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   OPPORTUNITIES
   ============================================================ */

class OpportunitiesPage
    extends StatefulWidget {
  final String language;

  const OpportunitiesPage({
    super.key,
    required this.language,
  });

  @override
  State<OpportunitiesPage> createState() =>
      _OpportunitiesPageState();
}

class _OpportunitiesPageState
    extends State<OpportunitiesPage> {
  List<Map<String, dynamic>> opportunities =
      [];

  bool loading = true;

  bool get arabic => isArabic(widget.language);

  @override
  void initState() {
    super.initState();
    loadOpportunities();
  }

  Future<void> loadOpportunities() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await supabase
          .from('opportunities')
          .select(
            'id,creator_id,title,company_name,opportunity_type,description,location,deadline,status,created_at',
          )
          .order(
            'created_at',
            ascending: false,
          );

      if (mounted) {
        setState(() {
          opportunities = (result as List)
              .map(
                (e) => Map<String, dynamic>.from(e),
              )
              .toList();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        snack(context, '$e');
      }
    }
  }

  Future<void> createOpportunity() async {
    if (!await requireLogin(
      context,
      widget.language,
    )) {
      return;
    }

    final title = TextEditingController();
    final company =
        TextEditingController();
    final type =
        TextEditingController(text: 'job');
    final description =
        TextEditingController();
    final location =
        TextEditingController();
    final deadline =
        TextEditingController();

    final data =
        await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            arabic
                ? 'نشر فرصة'
                : 'Post Opportunity',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DialogField(
                  controller: title,
                  label:
                      arabic ? 'العنوان' : 'Title',
                ),
                DialogField(
                  controller: company,
                  label: arabic
                      ? 'الشركة / المؤسسة'
                      : 'Company / Institution',
                ),
                DialogField(
                  controller: type,
                  label: arabic
                      ? 'نوع الفرصة'
                      : 'Opportunity type',
                ),
                DialogField(
                  controller: description,
                  label:
                      arabic ? 'الوصف' : 'Description',
                  maxLines: 4,
                ),
                DialogField(
                  controller: location,
                  label:
                      arabic ? 'الموقع' : 'Location',
                ),
                DialogField(
                  controller: deadline,
                  label: arabic
                      ? 'الموعد النهائي YYYY-MM-DD'
                      : 'Deadline YYYY-MM-DD',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: Text(
                arabic ? 'إلغاء' : 'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  [
                    title.text.trim(),
                    company.text.trim(),
                    type.text.trim(),
                    description.text.trim(),
                    location.text.trim(),
                    deadline.text.trim(),
                  ],
                );
              },
              child: Text(
                arabic ? 'نشر' : 'Publish',
              ),
            ),
          ],
        );
      },
    );

    title.dispose();
    company.dispose();
    type.dispose();
    description.dispose();
    location.dispose();
    deadline.dispose();

    if (data == null ||
        data.length != 6 ||
        data[0].isEmpty) {
      return;
    }

    try {
      await supabase.rpc(
        'create_opportunity',
        params: {
          'p_title': data[0],
          'p_company_name': data[1],
          'p_opportunity_type': data[2],
          'p_description': data[3],
          'p_location': data[4],
          'p_deadline':
              data[5].isEmpty ? null : data[5],
        },
      );

      await loadOpportunities();
    } catch (e) {
      if (mounted) snack(context, '$e');
    }
  }

  Future<void> apply(String opportunityId) async {
    if (!await requireLogin(
      context,
      widget.language,
    )) {
      return;
    }

    final message =
        TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            arabic
                ? 'التقديم على الفرصة'
                : 'Apply',
          ),
          content: TextField(
            controller: message,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: arabic
                  ? 'اكتب رسالة لصاحب الفرصة...'
                  : 'Write a message...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: Text(
                arabic ? 'إلغاء' : 'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                message.text.trim(),
              ),
              child: Text(
                arabic ? 'إرسال' : 'Send',
              ),
            ),
          ],
        );
      },
    );

    message.dispose();

    if (text == null) return;

    try {
      await supabase.rpc(
        'apply_to_opportunity',
        params: {
          'p_opportunity_id':
              opportunityId,
          'p_message': text,
        },
      );

      if (mounted) {
        snack(
          context,
          arabic
              ? 'تم إرسال طلبك'
              : 'Application sent',
        );
      }
    } catch (e) {
      if (mounted) snack(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            arabic ? 'الفرص' : 'Opportunities',
          ),
          actions: [
            IconButton(
              onPressed: loadOpportunities,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton:
            FloatingActionButton.extended(
          onPressed: createOpportunity,
          icon: const Icon(Icons.add_business),
          label: Text(
            arabic
                ? 'نشر فرصة'
                : 'Post Opportunity',
          ),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : opportunities.isEmpty
                ? Center(
                    child: Text(
                      arabic
                          ? 'لا توجد فرص بعد'
                          : 'No opportunities yet',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh:
                        loadOpportunities,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.all(12),
                      itemCount:
                          opportunities.length,
                      itemBuilder:
                          (context, index) {
                        final item =
                            opportunities[index];

                        return Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              14,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  '${item['title'] ?? ''}',
                                  style:
                                      const TextStyle(
                                    fontSize: 19,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                    height: 6),
                                Text(
                                  '${item['company_name'] ?? ''} • '
                                  '${item['opportunity_type'] ?? ''}',
                                ),
                                const SizedBox(
                                    height: 10),
                                Text(
                                  '${item['description'] ?? ''}',
                                ),
                                const SizedBox(
                                    height: 8),
                                Text(
                                  '${arabic ? 'الموقع' : 'Location'}: '
                                  '${item['location'] ?? '-'}',
                                ),
                                Text(
                                  '${arabic ? 'الموعد النهائي' : 'Deadline'}: '
                                  '${item['deadline'] ?? '-'}',
                                ),
                                const SizedBox(
                                    height: 12),
                                Align(
                                  alignment:
                                      AlignmentDirectional
                                          .centerEnd,
                                  child:
                                      FilledButton.icon(
                                    onPressed: () =>
                                        apply(
                                      '${item['id'] ?? ''}',
                                    ),
                                    icon: const Icon(
                                      Icons.send,
                                    ),
                                    label: Text(
                                      arabic
                                          ? 'تقديم'
                                          : 'Apply',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

/* ============================================================
   DIALOG FIELD
   ============================================================ */

class DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const DialogField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/* ============================================================
   PROFILE
   ============================================================ */

class ProfilePage extends StatefulWidget {
  final String language;

  const ProfilePage({
    super.key,
    required this.language,
  });

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool loading = true;

  bool get arabic => isArabic(widget.language);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      loading = true;
    });

    final user =
        supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    try {
      final result = await supabase
          .from('profiles')
          .select(
            'user_id,display_name,username,bio,country,avatar_url,role,talent_score,follower_count,following_count,wins_count',
          )
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          profile = result == null
              ? null
              : Map<String, dynamic>.from(
                  result,
                );
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        snack(context, '$e');
      }
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (mounted) {
      setState(() {
        profile = null;
      });
    }
  }

  Future<void> openLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          language: widget.language,
        ),
      ),
    );

    if (mounted) {
      await loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        supabase.auth.currentUser;

    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            arabic
                ? 'حسابي'
                : 'My Profile',
          ),
          actions: [
            IconButton(
              onPressed: loadProfile,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : user == null
                ? GuestProfile(
                    language: widget.language,
                    onLogin: openLogin,
                  )
                : profile == null
                    ? MissingProfile(
                        language:
                            widget.language,
                        email:
                            user.email ?? '',
                      )
                    : OwnProfile(
                        profile: profile!,
                        language:
                            widget.language,
                        email:
                            user.email ?? '',
                        onLogout: logout,
                      ),
      ),
    );
  }
}

class GuestProfile extends StatelessWidget {
  final String language;
  final VoidCallback onLogin;

  const GuestProfile({
    super.key,
    required this.language,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final arabic = isArabic(language);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person_outline,
                size: 50,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              arabic
                  ? 'زائر'
                  : 'Guest User',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              arabic
                  ? 'يمكنك مشاهدة الفيديوهات بدون تسجيل الدخول.'
                  : 'You can watch videos without signing in.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login),
              label: Text(
                arabic
                    ? 'تسجيل الدخول'
                    : 'Sign in',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MissingProfile
    extends StatelessWidget {
  final String language;
  final String email;

  const MissingProfile({
    super.key,
    required this.language,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final arabic = isArabic(language);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_search_outlined,
              size: 70,
            ),
            const SizedBox(height: 15),
            Text(
              email,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              arabic
                  ? 'تم تسجيل الدخول، لكن لم يتم العثور على ملفك في جدول profiles.'
                  : 'You are signed in, but no profile was found in profiles.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class OwnProfile
    extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String language;
  final String email;
  final VoidCallback onLogout;

  const OwnProfile({
    super.key,
    required this.profile,
    required this.language,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final arabic = isArabic(language);
    final avatar =
        '${profile['avatar_url'] ?? ''}';

    final name =
        '${profile['display_name'] ?? ''}'
                .trim()
                .isEmpty
            ? '${profile['username'] ?? 'Talent'}'
            : '${profile['display_name']}';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundImage: avatar.isNotEmpty
                ? NetworkImage(avatar)
                : null,
            child: avatar.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 60,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            '@${profile['username'] ?? ''}',
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(email),
        ),
        const SizedBox(height: 20),
        Text(
          '${profile['bio'] ?? ''}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25),
        StatsRow(
          items: [
            StatItem(
              arabic
                  ? 'المتابعون'
                  : 'Followers',
              '${profile['follower_count'] ?? 0}',
            ),
            StatItem(
              arabic
                  ? 'المتابَعون'
                  : 'Following',
              '${profile['following_count'] ?? 0}',
            ),
            StatItem(
              arabic
                  ? 'الانتصارات'
                  : 'Wins',
              '${profile['wins_count'] ?? 0}',
            ),
            StatItem(
              arabic
                  ? 'النقاط'
                  : 'Score',
              '${profile['talent_score'] ?? 0}',
            ),
          ],
        ),
        const SizedBox(height: 25),
        FilledButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: Text(
            arabic
                ? 'تسجيل الخروج'
                : 'Sign out',
          ),
        ),
      ],
    );
  }
}

/* ============================================================
   STATS
   ============================================================ */

class StatItem {
  final String label;
  final String value;

  const StatItem(
    this.label,
    this.value,
  );
}

class StatsRow extends StatelessWidget {
  final List<StatItem> items;

  const StatsRow({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++)
          Expanded(
            child: Padding(
              padding:
                  EdgeInsetsDirectional.only(
                end:
                    i == items.length - 1
                        ? 0
                        : 5,
              ),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 3,
                  ),
                  child: Column(
                    children: [
                      Text(
                        items[i].value,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        items[i].label,
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/* ============================================================
   LOGIN
   ============================================================ */

class LoginPage extends StatefulWidget {
  final String language;

  const LoginPage({
    super.key,
    required this.language,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  bool get arabic => isArabic(widget.language);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      snack(
        context,
        arabic
            ? 'أدخل البريد وكلمة المرور'
            : 'Enter email and password',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email:
            emailController.text.trim(),
        password:
            passwordController.text,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        snack(context, '$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> signUp() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.length < 6) {
      snack(
        context,
        arabic
            ? 'أدخل بريدًا صحيحًا وكلمة مرور من 6 أحرف على الأقل'
            : 'Enter a valid email and a password of at least 6 characters',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result =
          await supabase.auth.signUp(
        email:
            emailController.text.trim(),
        password:
            passwordController.text,
      );

      if (!mounted) return;

      if (result.session != null) {
        Navigator.pop(context);
      } else {
        snack(
          context,
          arabic
              ? 'تم إنشاء الحساب. تحقق من بريدك إذا كان تأكيد البريد مفعلاً.'
              : 'Account created. Check your email if email confirmation is enabled.',
        );
      }
    } catch (e) {
      if (mounted) {
        snack(context, '$e');
      }
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
    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            arabic
                ? 'تسجيل الدخول'
                : 'Sign in',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.shield_outlined,
              size: 85,
            ),
            const SizedBox(height: 25),
            TextField(
              controller: emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: arabic
                    ? 'البريد الإلكتروني'
                    : 'Email',
                border:
                    const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: arabic
                    ? 'كلمة المرور'
                    : 'Password',
                border:
                    const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed:
                  loading ? null : signIn,
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      arabic
                          ? 'دخول'
                          : 'Sign in',
                    ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed:
                  loading ? null : signUp,
              child: Text(
                arabic
                    ? 'إنشاء حساب'
                    : 'Create account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
