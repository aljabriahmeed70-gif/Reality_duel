import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

const String supabaseUrl = 'https://sdbfruxgoefdwyzhkjay.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_t3mt53Npr-LxfprutshcVQ_cQulCux2';

const String videoBucket = 'videos';

final SupabaseClient supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
  );

  runApp(const RealityDuelApp());
}

class RealityDuelApp extends StatefulWidget {
  const RealityDuelApp({super.key});

  @override
  State<RealityDuelApp> createState() => _RealityDuelAppState();
}

class _RealityDuelAppState extends State<RealityDuelApp> {
  Locale _locale = const Locale('en');

  bool get isArabic => _locale.languageCode == 'ar';

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reality Duel',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AppShell(
          locale: _locale,
          onLanguageChanged: changeLanguage,
        ),
      ),
    );
  }
}

// ============================================================
// APP SHELL
// ============================================================

class AppShell extends StatefulWidget {
  final Locale locale;
  final ValueChanged<Locale> onLanguageChanged;

  const AppShell({
    super.key,
    required this.locale,
    required this.onLanguageChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  bool get isArabic => widget.locale.languageCode == 'ar';

  List<Widget> get pages => const [
        VideoFeedPage(),
        DuelsPage(),
        DiscoverPage(),
        OpportunitiesPage(),
        TalentProfilePage(),
      ];

  List<String> get labels {
    if (isArabic) {
      return [
        'الرئيسية',
        'المواجهات',
        'المواهب',
        'الفرص',
        'حسابي',
      ];
    }

    return [
      'Feed',
      'Duels',
      'Talent',
      'Opportunities',
      'Profile',
    ];
  }

  List<IconData> get icons => const [
        Icons.play_circle_fill,
        Icons.sports_kabaddi,
        Icons.search,
        Icons.work_outline,
        Icons.person_outline,
      ];

  void openLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171717),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Language / اللغة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _languageTile(
                  'English',
                  const Locale('en'),
                  Icons.language,
                ),
                _languageTile(
                  'العربية',
                  const Locale('ar'),
                  Icons.translate,
                ),
                _languageTile(
                  'Español',
                  const Locale('es'),
                  Icons.language,
                ),
                _languageTile(
                  'Français',
                  const Locale('fr'),
                  Icons.language,
                ),
                _languageTile(
                  'Türkçe',
                  const Locale('tr'),
                  Icons.language,
                ),
                _languageTile(
                  '中文',
                  const Locale('zh'),
                  Icons.language,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageTile(
    String title,
    Locale locale,
    IconData icon,
  ) {
    final selected = widget.locale.languageCode == locale.languageCode;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selected
          ? const Icon(
              Icons.check_circle,
              color: Colors.redAccent,
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        widget.onLanguageChanged(locale);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: List.generate(
          labels.length,
          (index) => NavigationDestination(
            icon: Icon(icons[index]),
            selectedIcon: Icon(icons[index]),
            label: labels[index],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'language_button',
        onPressed: openLanguageSelector,
        child: const Icon(Icons.language),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

bool get isLoggedIn => supabase.auth.currentUser != null;

void requireLogin(
  BuildContext context, {
  String message = 'Please login to continue.',
}) {
  if (isLoggedIn) return;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Login required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
            child: const Text('Login'),
          ),
        ],
      );
    },
  );
}

void showMessage(
  BuildContext context,
  String message,
) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

String formatCount(dynamic value) {
  final number = int.tryParse('$value') ?? 0;

  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }

  return '$number';
}

String safeString(dynamic value) {
  return value?.toString() ?? '';
}

// ============================================================
// VIDEO MODEL
// ============================================================

class VideoItem {
  final dynamic id;
  final String videoUrl;
  final String caption;
  final String userId;
  final String username;
  final String displayName;
  final String avatarUrl;
  final int likes;
  final int comments;
  final int views;

  VideoItem({
    this.id,
    required this.videoUrl,
    this.caption = '',
    this.userId = '',
    this.username = '',
    this.displayName = '',
    this.avatarUrl = '',
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
  });

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'];

    String profileUsername = '';
    String profileDisplayName = '';
    String profileAvatar = '';

    if (profile is Map<String, dynamic>) {
      profileUsername = safeString(profile['username']);
      profileDisplayName = safeString(profile['display_name']);
      profileAvatar = safeString(profile['avatar_url']);
    }

    return VideoItem(
      id: map['id'],
      videoUrl: safeString(
        map['video_url'] ?? map['url'],
      ),
      caption: safeString(map['caption']),
      userId: safeString(map['user_id']),
      username: safeString(
        map['username'] ?? profileUsername,
      ),
      displayName: safeString(
        map['display_name'] ?? profileDisplayName,
      ),
      avatarUrl: safeString(
        map['avatar_url'] ?? profileAvatar,
      ),
      likes: int.tryParse(
            '${map['likes_count'] ?? map['like_count'] ?? 0}',
          ) ??
          0,
      comments: int.tryParse(
            '${map['comments_count'] ?? map['comment_count'] ?? 0}',
          ) ??
          0,
      views: int.tryParse(
            '${map['views_count'] ?? map['view_count'] ?? 0}',
          ) ??
          0,
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
  List<VideoItem> videos = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      List<VideoItem> databaseVideos = [];

      try {
        final response = await supabase
            .from('videos')
            .select()
            .eq('status', 'published')
            .order(
              'created_at',
              ascending: false,
            );

        if (response is List) {
          databaseVideos = response
              .whereType<Map<String, dynamic>>()
              .map(VideoItem.fromMap)
              .where((video) => video.videoUrl.isNotEmpty)
              .toList();
        }
      } catch (_) {
        // Some schemas may not have status.
        try {
          final response = await supabase
              .from('videos')
              .select()
              .order(
                'created_at',
                ascending: false,
              );

          if (response is List) {
            databaseVideos = response
                .whereType<Map<String, dynamic>>()
                .map(VideoItem.fromMap)
                .where((video) => video.videoUrl.isNotEmpty)
                .toList();
          }
        } catch (_) {}
      }

      if (databaseVideos.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          videos = databaseVideos;
          loading = false;
        });

        return;
      }

      // --------------------------------------------------------
      // FALLBACK: READ DIRECTLY FROM PUBLIC STORAGE
      // --------------------------------------------------------

      final files = await supabase.storage
          .from(videoBucket)
          .list();

      final storageVideos = <VideoItem>[];

      for (final file in files) {
        final name = file.name;

        final lower = name.toLowerCase();

        final isVideo = lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.m4v') ||
            lower.endsWith('.webm') ||
            lower.endsWith('.avi');

        if (!isVideo) continue;

        final publicUrl = supabase.storage
            .from(videoBucket)
            .getPublicUrl(name);

        storageVideos.add(
          VideoItem(
            id: name,
            videoUrl: publicUrl,
            caption: name,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        videos = storageVideos;
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

  void openUploadMenu() {
    if (!isLoggedIn) {
      requireLogin(
        context,
        message: 'Login is required to upload or create content.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171717),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Upload video'),
                subtitle: const Text(
                  'Choose a video from your device',
                ),
                onTap: () {
                  Navigator.pop(context);
                  uploadVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record video'),
                subtitle: const Text(
                  'Camera recording requires camera package setup',
                ),
                onTap: () {
                  Navigator.pop(context);

                  showMessage(
                    context,
                    'Camera recording will be enabled after adding the camera module.',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.live_tv),
                title: const Text('Go Live'),
                subtitle: const Text(
                  'Live streaming requires a streaming provider',
                ),
                onTap: () {
                  Navigator.pop(context);

                  showMessage(
                    context,
                    'Live streaming requires a streaming provider and live backend.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadVideo() async {
    if (!isLoggedIn) {
      requireLogin(context);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;

      Uint8List? bytes = picked.bytes;

      if (bytes == null) {
        showMessage(
          context,
          'Could not read the selected video.',
        );
        return;
      }

      final user = supabase.auth.currentUser;

      if (user == null) {
        requireLogin(context);
        return;
      }

      final originalName = picked.name;

      final cleanName = originalName
          .replaceAll(
            RegExp(r'[^a-zA-Z0-9._-]'),
            '_',
          );

      final filePath =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$cleanName';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 18),
                Expanded(
                  child: Text('Uploading video...'),
                ),
              ],
            ),
          );
        },
      );

      await supabase.storage
          .from(videoBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: false,
            ),
          );

      final publicUrl = supabase.storage
          .from(videoBucket)
          .getPublicUrl(filePath);

      try {
        await supabase.rpc(
          'create_video_record',
          params: {
            'p_storage_path': filePath,
            'p_video_url': publicUrl,
            'p_caption': originalName,
          },
        );
      } catch (_) {
        // Fallback for schemas without the RPC.
        try {
          await supabase.from('videos').insert({
            'user_id': user.id,
            'storage_path': filePath,
            'video_url': publicUrl,
            'caption': originalName,
          });
        } catch (_) {
          try {
            await supabase.from('videos').insert({
              'user_id': user.id,
              'video_url': publicUrl,
              'caption': originalName,
            });
          } catch (_) {}
        }
      }

      if (mounted) {
        Navigator.of(context).pop();

        showMessage(
          context,
          'Video uploaded successfully.',
        );

        await loadVideos();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        showMessage(
          context,
          'Upload failed: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reality Duel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadVideos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (error != null)
            _ErrorView(
              message: error!,
              onRetry: loadVideos,
            )
          else if (videos.isEmpty)
            const _EmptyFeed()
          else
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return VideoFeedItem(
                  video: videos[index],
                );
              },
            ),

          Positioned(
            right: 16,
            bottom: 20,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: 'upload_video',
                onPressed: openUploadMenu,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VIDEO ITEM
// ============================================================

class VideoFeedItem extends StatefulWidget {
  final VideoItem video;

  const VideoFeedItem({
    super.key,
    required this.video,
  });

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  VideoPlayerController? controller;

  bool initialized = false;
  bool liked = false;
  bool following = false;
  bool loadingLike = false;

  int likes = 0;
  int comments = 0;
  int views = 0;

  @override
  void initState() {
    super.initState();

    likes = widget.video.likes;
    comments = widget.video.comments;
    views = widget.video.views;

    initializeVideo();
    loadInteractionState();
  }

  Future<void> initializeVideo() async {
    try {
      final videoController =
          VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );

      controller = videoController;

      await videoController.initialize();

      await videoController.setLooping(true);
      await videoController.play();

      if (!mounted) return;

      setState(() {
        initialized = true;
      });

      recordView();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        initialized = false;
      });
    }
  }

  Future<void> recordView() async {
    if (!isLoggedIn) return;

    if (widget.video.id == null) return;

    try {
      await supabase.rpc(
        'record_video_view',
        params: {
          'p_video_id': widget.video.id,
        },
      );
    } catch (_) {}
  }

  Future<void> loadInteractionState() async {
    if (!isLoggedIn) return;

    if (widget.video.id == null) return;

    try {
      final result = await supabase.rpc(
        'has_video_like',
        params: {
          'p_video_id': widget.video.id,
        },
      );

      liked = result == true;
    } catch (_) {}

    try {
      if (widget.video.userId.isNotEmpty) {
        final result = await supabase.rpc(
          'is_following',
          params: {
            'p_target_user_id': widget.video.userId,
          },
        );

        following = result == true;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> toggleLike() async {
    if (!isLoggedIn) {
      requireLogin(
        context,
        message: 'Login to like videos.',
      );
      return;
    }

    if (widget.video.id == null) return;
    if (loadingLike) return;

    setState(() {
      loadingLike = true;
    });

    try {
      final result = await supabase.rpc(
        'toggle_video_like',
        params: {
          'p_video_id': widget.video.id,
        },
      );

      bool newLiked = !liked;

      if (result is bool) {
        newLiked = result;
      }

      setState(() {
        liked = newLiked;

        if (liked) {
          likes++;
        } else if (likes > 0) {
          likes--;
        }
      });
    } catch (e) {
      showMessage(
        context,
        'Could not update like.',
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingLike = false;
        });
      }
    }
  }

  Future<void> toggleFollow() async {
    if (!isLoggedIn) {
      requireLogin(
        context,
        message: 'Login to follow creators.',
      );
      return;
    }

    if (widget.video.userId.isEmpty) return;

    try {
      final result = await supabase.rpc(
        'toggle_follow',
        params: {
          'p_target_user_id': widget.video.userId,
        },
      );

      setState(() {
        following = result is bool ? result : !following;
      });
    } catch (_) {
      showMessage(
        context,
        'Could not update follow status.',
      );
    }
  }

  void openComments() {
    if (!isLoggedIn) {
      requireLogin(
        context,
        message: 'Login to view and add comments.',
      );
      return;
    }

    if (widget.video.id == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151515),
      builder: (_) {
        return CommentsSheet(
          videoId: widget.video.id,
          onCommentAdded: () {
            setState(() {
              comments++;
            });
          },
        );
      },
    );
  }

  Future<void> shareVideo() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share video'),
          content: SelectableText(
            widget.video.videoUrl,
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoController = controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: initialized && videoController != null
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: videoController.value.size.width,
                    height: videoController.value.size.height,
                    child: VideoPlayer(videoController),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),

        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black54,
                Colors.transparent,
                Colors.black87,
              ],
            ),
          ),
        ),

        Positioned(
          left: 16,
          right: 90,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.video.displayName.isNotEmpty)
                Text(
                  widget.video.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (widget.video.username.isNotEmpty)
                Text(
                  '@${widget.video.username}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              if (widget.video.caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.video.caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),

        Positioned(
          right: 12,
          bottom: 42,
          child: Column(
            children: [
              _ActionButton(
                icon: liked
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: formatCount(likes),
                active: liked,
                onTap: toggleLike,
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.comment,
                label: formatCount(comments),
                onTap: openComments,
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: following
                    ? Icons.person
                    : Icons.person_add,
                label: following ? 'Following' : 'Follow',
                onTap: toggleFollow,
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: shareVideo,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COMMENTS
// ============================================================

class CommentsSheet extends StatefulWidget {
  final dynamic videoId;
  final VoidCallback onCommentAdded;

  const CommentsSheet({
    super.key,
    required this.videoId,
    required this.onCommentAdded,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> comments = [];

  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final result = await supabase
          .from('video_comments')
          .select()
          .eq(
            'video_id',
            widget.videoId,
          )
          .order(
            'created_at',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {
        comments = result
            .whereType<Map<String, dynamic>>()
            .toList();

        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> sendComment() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    if (!isLoggedIn) {
      requireLogin(context);
      return;
    }

    setState(() {
      sending = true;
    });

    try {
      await supabase.rpc(
        'add_video_comment',
        params: {
          'p_video_id': widget.videoId,
          'p_comment': text,
        },
      );

      controller.clear();

      widget.onCommentAdded();

      await loadComments();
    } catch (_) {
      showMessage(
        context,
        'Could not add comment.',
      );
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .72,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : comments.isEmpty
                      ? const Center(
                          child: Text(
                            'No comments yet.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final item = comments[index];

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(
                                safeString(
                                  item['username'] ??
                                      item['user_name'] ??
                                      'User',
                                ),
                              ),
                              subtitle: Text(
                                safeString(
                                  item['comment'] ??
                                      item['content'] ??
                                      item['text'],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: sending ? null : sendComment,
                    icon: sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
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

// ============================================================
// DUELS
// ============================================================

class DuelsPage extends StatefulWidget {
  const DuelsPage({super.key});

  @override
  State<DuelsPage> createState() => _DuelsPageState();
}

class _DuelsPageState extends State<DuelsPage> {
  bool loading = true;
  List<Map<String, dynamic>> duels = [];

  @override
  void initState() {
    super.initState();
    loadDuels();
  }

  Future<void> loadDuels() async {
    try {
      final result = await supabase
          .from('duels')
          .select()
          .order(
            'created_at',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {
        duels = result
            .whereType<Map<String, dynamic>>()
            .toList();

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  void createDuelDialog() {
    if (!isLoggedIn) {
      requireLogin(
        context,
        message: 'Login to create a Duel.',
      );
      return;
    }

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Duel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final description =
                    descriptionController.text.trim();

                if (title.isEmpty) return;

                try {
                  await supabase.rpc(
                    'create_duel',
                    params: {
                      'p_title': title,
                      'p_description': description,
                      'p_challenge_type': 'video',
                    },
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  await loadDuels();

                  if (mounted) {
                    showMessage(
                      context,
                      'Duel created successfully.',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showMessage(
                      context,
                      'Could not create Duel.',
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> joinDuel(dynamic duelId) async {
    if (!isLoggedIn) {
      requireLogin(
        context,
        message: 'Login to join a Duel.',
      );
      return;
    }

    try {
      await supabase.rpc(
        'join_duel',
        params: {
          'p_duel_id': duelId,
        },
      );

      showMessage(
        context,
        'You joined the Duel.',
      );
    } catch (_) {
      showMessage(
        context,
        'Could not join this Duel.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duels'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createDuelDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create Duel'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : duels.isEmpty
              ? const Center(
                  child: Text(
                    'No Duels available yet.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadDuels,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: duels.length,
                    itemBuilder: (context, index) {
                      final duel = duels[index];

                      final title = safeString(
                        duel['title'],
                      );

                      final description = safeString(
                        duel['description'],
                      );

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.isEmpty
                                    ? 'Reality Duel'
                                    : title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (description.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    description,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => joinDuel(
                                  duel['id'],
                                ),
                                child: const Text(
                                  'Join Duel',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ============================================================
// DISCOVER TALENT
// ============================================================

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController searchController =
      TextEditingController();

  bool loading = true;
  List<Map<String, dynamic>> profiles = [];

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
      var query = supabase
          .from('profiles')
          .select();

      final search = searchController.text.trim();

      if (search.isNotEmpty) {
        query = query.or(
          'username.ilike.%$search%,'
          'display_name.ilike.%$search%,'
          'country.ilike.%$search%',
        );
      }

      final result = await query.limit(50);

      if (!mounted) return;

      setState(() {
        profiles = result
            .whereType<Map<String, dynamic>>()
            .toList();

        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Talent'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onSubmitted: (_) => loadProfiles(),
              decoration: InputDecoration(
                hintText: 'Search talent...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: loadProfiles,
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : profiles.isEmpty
                    ? const Center(
                        child: Text(
                          'No talent found.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadProfiles,
                        child: ListView.builder(
                          itemCount: profiles.length,
                          itemBuilder: (context, index) {
                            final profile = profiles[index];

                            final name = safeString(
                              profile['display_name'],
                            );

                            final username = safeString(
                              profile['username'],
                            );

                            final country = safeString(
                              profile['country'],
                            );

                            final avatar = safeString(
                              profile['avatar_url'],
                            );

                            return ListTile(
                              leading: _Avatar(
                                url: avatar,
                                radius: 28,
                              ),
                              title: Text(
                                name.isEmpty
                                    ? username.isEmpty
                                        ? 'Talent'
                                        : '@$username'
                                    : name,
                              ),
                              subtitle: Text(
                                [
                                  if (username.isNotEmpty)
                                    '@$username',
                                  if (country.isNotEmpty)
                                    country,
                                ].join(' • '),
                              ),
                              trailing: Text(
                                '${formatCount(profile['talent_score'] ?? 0)} score',
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OPPORTUNITIES
// ============================================================

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() =>
      _OpportunitiesPageState();
}

class _OpportunitiesPageState
    extends State<OpportunitiesPage> {
  bool loading = true;
  List<Map<String, dynamic>> opportunities = [];

  @override
  void initState() {
    super.initState();
    loadOpportunities();
  }

  Future<void> loadOpportunities() async {
    try {
      final result = await supabase
          .from('opportunities')
          .select()
          .order(
            'created_at',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {
        opportunities = result
            .whereType<Map<String, dynamic>>()
            .toList();

        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  void createOpportunityDialog() {
    if (!isLoggedIn) {
      requireLogin(
        context,
        message: 'Login to create an opportunity.',
      );
      return;
    }

    final title = TextEditingController();
    final company = TextEditingController();
    final description = TextEditingController();
    final location = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Opportunity'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: company,
                  decoration: const InputDecoration(
                    labelText: 'Company / Institution',
                  ),
                ),
                TextField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 4,
                ),
                TextField(
                  controller: location,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (title.text.trim().isEmpty) return;

                try {
                  await supabase.rpc(
                    'create_opportunity',
                    params: {
                      'p_title': title.text.trim(),
                      'p_company_name':
                          company.text.trim(),
                      'p_description':
                          description.text.trim(),
                      'p_opportunity_type': 'job',
                      'p_location':
                          location.text.trim(),
                      'p_deadline': null,
                    },
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  await loadOpportunities();

                  if (mounted) {
                    showMessage(
                      context,
                      'Opportunity created.',
                    );
                  }
                } catch (_) {
                  showMessage(
                    context,
                    'Could not create opportunity.',
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> apply(dynamic opportunityId) async {
    if (!isLoggedIn) {
      requireLogin(
        context,
        message: 'Login to apply for opportunities.',
      );
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      await supabase
          .from('opportunity_applications')
          .insert({
        'opportunity_id': opportunityId,
        'user_id': user.id,
        'status': 'pending',
      });

      showMessage(
        context,
        'Application submitted.',
      );
    } catch (_) {
      try {
        await supabase.rpc(
          'apply_to_opportunity',
          params: {
            'p_opportunity_id': opportunityId,
          },
        );

        showMessage(
          context,
          'Application submitted.',
        );
      } catch (_) {
        showMessage(
          context,
          'Could not submit application.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunities'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createOpportunityDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : opportunities.isEmpty
              ? const Center(
                  child: Text(
                    'No opportunities available yet.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadOpportunities,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: opportunities.length,
                    itemBuilder: (context, index) {
                      final item = opportunities[index];

                      final title =
                          safeString(item['title']);

                      final company = safeString(
                        item['company_name'] ??
                            item['company'],
                      );

                      final description = safeString(
                        item['description'],
                      );

                      final location = safeString(
                        item['location'],
                      );

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.isEmpty
                                    ? 'Opportunity'
                                    : title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (company.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 5,
                                  ),
                                  child: Text(
                                    company,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              if (description.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: Text(
                                    description,
                                  ),
                                ),
                              if (location.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(location),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () =>
                                    apply(item['id']),
                                child: const Text(
                                  'Apply',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ============================================================
// TALENT PROFILE
// ============================================================

class TalentProfilePage extends StatefulWidget {
  const TalentProfilePage({super.key});

  @override
  State<TalentProfilePage> createState() =>
      _TalentProfilePageState();
}

class _TalentProfilePageState
    extends State<TalentProfilePage> {
  bool loading = true;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        loading = false;
        profile = null;
      });

      return;
    }

    try {
      final result = await supabase
          .from('profiles')
          .select()
          .eq(
            'user_id',
            user.id,
          )
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        profile = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  void login() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  void editProfile() {
    if (!isLoggedIn) {
      requireLogin(context);
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) return;

    final displayNameController =
        TextEditingController(
      text: safeString(
        profile?['display_name'],
      ),
    );

    final usernameController =
        TextEditingController(
      text: safeString(
        profile?['username'],
      ),
    );

    final bioController =
        TextEditingController(
      text: safeString(
        profile?['bio'],
      ),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                  ),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await supabase.from('profiles').upsert(
                    {
                      'user_id': user.id,
                      'email': user.email,
                      'display_name':
                          displayNameController.text.trim(),
                      'username':
                          usernameController.text.trim(),
                      'bio':
                          bioController.text.trim(),
                    },
                    onConflict: 'user_id',
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  await loadProfile();
                } catch (_) {
                  showMessage(
                    context,
                    'Could not update profile.',
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    setState(() {
      profile = null;
    });

    showMessage(
      context,
      'Logged out.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Talent Profile'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Guest User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Watch videos without an account. Login to build your talent profile.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: login,
                  icon: const Icon(Icons.login),
                  label: const Text('Login / Sign up'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final displayName = safeString(
      profile?['display_name'],
    );

    final username = safeString(
      profile?['username'],
    );

    final bio = safeString(
      profile?['bio'],
    );

    final avatar = safeString(
      profile?['avatar_url'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Talent Profile'),
        actions: [
          IconButton(
            onPressed: editProfile,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: _Avatar(
                url: avatar,
                radius: 55,
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                displayName.isEmpty
                    ? 'Talent'
                    : displayName,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (username.isNotEmpty)
              Center(
                child: Text(
                  '@$username',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                user.email ?? '',
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
            if (bio.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  top: 18,
                ),
                child: Text(
                  bio,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 25),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatRow(
                      title: 'Talent Score',
                      value: formatCount(
                        profile?['talent_score'] ?? 0,
                      ),
                    ),
                    _StatRow(
                      title: 'Followers',
                      value: formatCount(
                        profile?['follower_count'] ?? 0,
                      ),
                    ),
                    _StatRow(
                      title: 'Following',
                      value: formatCount(
                        profile?['following_count'] ?? 0,
                      ),
                    ),
                    _StatRow(
                      title: 'Duel Wins',
                      value: formatCount(
                        profile?['wins_count'] ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool signUpMode = false;
  bool loading = false;

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(
        context,
        'Enter email and password.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      if (signUpMode) {
        final response =
            await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final user = response.user;

        if (user != null) {
          try {
            await supabase.from('profiles').upsert(
              {
                'user_id': user.id,
                'email': email,
                'display_name':
                    nameController.text.trim().isEmpty
                        ? 'Talent'
                        : nameController.text.trim(),
                'username':
                    email.split('@').first,
              },
              onConflict: 'user_id',
            );
          } catch (_) {}
        }

        if (mounted) {
          showMessage(
            context,
            'Account created. Check your email if confirmation is required.',
          );
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        showMessage(
          context,
          e.message,
        );
      }
    } catch (e) {
      if (mounted) {
        showMessage(
          context,
          'Authentication failed.',
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
        title: Text(
          signUpMode ? 'Create Account' : 'Login',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 25),
            const Icon(
              Icons.public,
              size: 75,
            ),
            const SizedBox(height: 15),
            const Text(
              'Reality Duel',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'The World Is Your Arena',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            if (signUpMode)
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  border: OutlineInputBorder(),
                ),
              ),
            if (signUpMode)
              const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                        signUpMode
                            ? 'Create Account'
                            : 'Login',
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: loading
                  ? null
                  : () {
                      setState(() {
                        signUpMode = !signUpMode;
                      });
                    },
              child: Text(
                signUpMode
                    ? 'Already have an account? Login'
                    : 'Create a new account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// UI HELPERS
// ============================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: active ? Colors.redAccent : Colors.white,
              size: 27,
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

class _Avatar extends StatelessWidget {
  final String url;
  final double radius;

  const _Avatar({
    required this.url,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: Icon(
          Icons.person,
          size: radius,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(url),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String title;
  final String value;

  const _StatRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.video_library_outlined,
              size: 70,
            ),
            const SizedBox(height: 15),
            const Text(
              'No videos available yet.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload the first Reality Duel video.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load videos.',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 15),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
