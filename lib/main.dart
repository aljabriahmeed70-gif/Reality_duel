import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

const String supabaseUrl =
    'https://sdbfruxgoefdwyzhkjay.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_t3mt53Npr-LxfprutshcVQ_cQulCux2';

const String videoBucket = 'videos';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
  );

  runApp(const RealityDuelApp());
}

// ============================================================
// APP
// ============================================================

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF171717),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthGate(),
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
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session == null) {
          return const GuestHome();
        }

        return const AuthenticatedHome();
      },
    );
  }
}

// ============================================================
// PROFILE MODEL
// ============================================================

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
  final String? avatarUrl;

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
    this.avatarUrl,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      displayName: map['display_name']?.toString() ?? 'User',
      bio: map['bio']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      isTalent: map['is_talent'] == true,
      isCompany: map['is_company'] == true,
      followersCount: (map['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (map['following_count'] as num?)?.toInt() ?? 0,
      videosCount: (map['videos_count'] as num?)?.toInt() ?? 0,
      avatarUrl: map['avatar_url']?.toString(),
    );
  }
}

// ============================================================
// GUEST HOME
// ============================================================

class GuestHome extends StatelessWidget {
  const GuestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const VideoFeedPage(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SignInPage(),
            ),
          );
        },
        icon: const Icon(Icons.login),
        label: const Text('تسجيل الدخول'),
      ),
    );
  }
}

// ============================================================
// AUTHENTICATED HOME
// ============================================================

class AuthenticatedHome extends StatefulWidget {
  const AuthenticatedHome({super.key});

  @override
  State<AuthenticatedHome> createState() =>
      _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends State<AuthenticatedHome> {
  int currentIndex = 0;
  ProfileData? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        loading = false;
      });
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
      } else {
        await ensureOwnProfile(user);

        final retry = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (retry != null) {
          profile = ProfileData.fromMap(retry);
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> ensureOwnProfile(User user) async {
    final metadata = user.userMetadata ?? {};

    final bool company =
        metadata['is_company'] == true;

    final bool talent =
        metadata['is_talent'] == true || !company;

    final username =
        metadata['username']?.toString() ??
            'user_${user.id.substring(0, 8)}';

    final displayName =
        metadata['display_name']?.toString() ??
            user.email?.split('@').first ??
            'User';

    await supabase.from('profiles').upsert({
      'id': user.id,
      'username': username,
      'display_name': displayName,
      'is_talent': talent,
      'is_company': company,
    });
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

    final bool company = profile?.isCompany == true;

    final pages = company
        ? const [
            VideoFeedPage(),
            DiscoverTalentPage(),
            OpportunitiesPage(),
            ProfilePage(),
          ]
        : const [
            VideoFeedPage(),
            DuelsPage(),
            DiscoverTalentPage(),
            OpportunitiesPage(),
            ProfilePage(),
          ];

    final labels = company
        ? const [
            'Feed',
            'Talent',
            'الفرص',
            'حسابي',
          ]
        : const [
            'Feed',
            'Duels',
            'Talent',
            'الفرص',
            'حسابي',
          ];

    final icons = company
        ? const [
            Icons.play_circle_outline,
            Icons.people_outline,
            Icons.work_outline,
            Icons.person_outline,
          ]
        : const [
            Icons.play_circle_outline,
            Icons.sports_mma_outlined,
            Icons.people_outline,
            Icons.work_outline,
            Icons.person_outline,
          ];

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
        destinations: List.generate(
          labels.length,
          (index) => NavigationDestination(
            icon: Icon(icons[index]),
            label: labels[index],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// VIDEO MODEL
// ============================================================

class FeedVideo {
  final String? id;
  final String path;
  final String url;
  final String title;
  final String description;
  final String? ownerId;
  final int views;
  final int likes;
  final int comments;

    const FeedVideo({
    this.id,
    required this.path,
    required this.url,
    required this.title,
    this.description = '',
    this.ownerId,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
  });
}
  

// ============================================================
// VIDEO FEED
// ============================================================

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() =>
      _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  List<FeedVideo> videos = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final dbData = await supabase
          .from('videos')
          .select(
            'id,user_id,storage_path,title,description,'
            'views_count,likes_count,comments_count',
          )
          .order(
            'created_at',
            ascending: false,
          );

      final List<FeedVideo> result = [];

      for (final row in dbData) {
        final path = row['storage_path']?.toString();

        if (path == null || path.isEmpty) {
          continue;
        }

        final url = supabase.storage
            .from(videoBucket)
            .getPublicUrl(path);

        result.add(
          FeedVideo(
            id: row['id']?.toString(),
            path: path,
            url: url,
            title: row['title']?.toString() ?? '',
            description:
                row['description']?.toString() ?? '',
            ownerId: row['user_id']?.toString(),
            views:
                (row['views_count'] as num?)?.toInt() ?? 0,
            likes:
                (row['likes_count'] as num?)?.toInt() ?? 0,
            comments:
                (row['comments_count'] as num?)?.toInt() ?? 0,
          ),
        );
      }

      // ------------------------------------------------------
      // Fallback:
      // إذا كان هناك فيديو في Storage لم يسجل في جدول videos
      // يظهر في Feed حتى لا يختفي الفيديو القديم.
      // ------------------------------------------------------

      final storageFiles = await supabase.storage
          .from(videoBucket)
          .list();

      final existingPaths =
          result.map((e) => e.path).toSet();

      for (final file in storageFiles) {
        final name = file.name;

        if (!_isVideo(name)) {
          continue;
        }

        if (existingPaths.contains(name)) {
          continue;
        }

        final url = supabase.storage
            .from(videoBucket)
            .getPublicUrl(name);

        result.add(
          FeedVideo(
            id: null,
            path: name,
            url: url,
            title: name,
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
      if (mounted) {
        setState(() {
          loading = false;
          error = e.toString();
        });
      }
    }
  }

  bool _isVideo(String name) {
    final lower = name.toLowerCase();

    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi');
  }

  Future<void> uploadVideo() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    try {
      final picked =
          await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );

      if (picked == null ||
          picked.files.isEmpty) {
        return;
      }

      final file = picked.files.first;
      final Uint8List? bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        showMessage(
          context,
          'تعذر قراءة ملف الفيديو.',
        );
        return;
      }

      showLoadingDialog(
        context,
        'جاري رفع الفيديو...',
      );

      final originalName = file.name.isEmpty
          ? 'video.mp4'
          : file.name;

      final extension =
          _extension(originalName);

      final safeName =
          _safeFileName(
        originalName
            .replaceAll(
              RegExp(r'\.[^.]+$'),
              '',
            ),
      );

      final storagePath =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}_$safeName.$extension';

      final contentType =
          _videoContentType(extension);

      await supabase.storage
          .from(videoBucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      try {
        await supabase.from('videos').insert({
          'user_id': user.id,
          'storage_path': storagePath,
          'title': safeName,
          'description': '',
        });
      } catch (e) {
        await supabase.storage
            .from(videoBucket)
            .remove([storagePath]);

        rethrow;
      }

      if (mounted) {
        Navigator.pop(context);
      }

      showMessage(
        context,
        'تم رفع الفيديو بنجاح ✅',
      );

      await loadVideos();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      }

      showMessage(
        context,
        'حدث خطأ أثناء رفع الفيديو.',
      );
    }
  }

  String _extension(String name) {
    final index = name.lastIndexOf('.');

    if (index == -1) {
      return 'mp4';
    }

    return name
        .substring(index + 1)
        .toLowerCase();
  }

  String _safeFileName(String name) {
    final cleaned = name.replaceAll(
      RegExp(r'[^a-zA-Z0-9_\-]'),
      '_',
    );

    if (cleaned.isEmpty) {
      return 'video';
    }

    return cleaned;
  }

  String _videoContentType(String extension) {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'REALITY DUEL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadVideos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton:
          supabase.auth.currentUser != null
              ? FloatingActionButton(
                  onPressed: uploadVideo,
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 55,
              ),
              const SizedBox(height: 15),
              const Text(
                'تعذر تحميل الفيديوهات',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),
              FilledButton(
                onPressed: loadVideos,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.video_library_outlined,
              size: 70,
            ),
            const SizedBox(height: 15),
            const Text(
              'لا توجد فيديوهات حتى الآن',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (supabase.auth.currentUser != null)
              FilledButton.icon(
                onPressed: uploadVideo,
                icon: const Icon(Icons.upload),
                label: const Text('رفع أول فيديو'),
              ),
          ],
        ),
      );
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (index) {
        final video = videos[index];

        if (video.id != null) {
          incrementView(video.id!);
        }
      },
      itemBuilder: (context, index) {
        final video = videos[index];

        return VideoFeedItem(
          video: video,
        );
      },
    );
  }
}

// ============================================================
// VIDEO ITEM
// ============================================================

class VideoFeedItem extends StatefulWidget {
  final FeedVideo video;

  const VideoFeedItem({
    super.key,
    required this.video,
  });

  @override
  State<VideoFeedItem> createState() =>
      _VideoFeedItemState();
}

class _VideoFeedItemState
    extends State<VideoFeedItem> {
  VideoPlayerController? controller;

  bool initialized = false;
  bool playing = true;
  bool muted = true;
  bool liked = false;

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
    loadLikeState();
  }

  Future<void> initializeVideo() async {
    try {
      final c =
          VideoPlayerController.networkUrl(
        Uri.parse(widget.video.url),
      );

      controller = c;

      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);

      await c.play();

      if (mounted) {
        setState(() {
          initialized = true;
        });
      }
    } catch (_) {}
  }

  Future<void> loadLikeState() async {
    final user = supabase.auth.currentUser;
    final videoId = widget.video.id;

    if (user == null || videoId == null) {
      return;
    }

    try {
      final result = await supabase
          .from('likes')
          .select('id')
          .eq('video_id', videoId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          liked = result != null;
        });
      }
    } catch (_) {}
  }

  Future<void> toggleLike() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    if (widget.video.id == null) {
      showMessage(
        context,
        'هذا الفيديو القديم يحتاج إلى تسجيله في قاعدة البيانات أولًا.',
      );
      return;
    }

    try {
      if (liked) {
        await supabase
            .from('likes')
            .delete()
            .eq('video_id', widget.video.id!)
            .eq('user_id', user.id);

        if (mounted) {
          setState(() {
            liked = false;
            if (likes > 0) likes--;
          });
        }
      } else {
        await supabase.from('likes').insert({
          'video_id': widget.video.id!,
          'user_id': user.id,
        });

        if (mounted) {
          setState(() {
            liked = true;
            likes++;
          });
        }
      }
    } catch (e) {
      showMessage(
        context,
        'تعذر تنفيذ الإعجاب.',
      );
    }
  }

  Future<void> showComments() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    final videoId = widget.video.id;

    if (videoId == null) {
      showMessage(
        context,
        'هذا الفيديو غير مسجل في قاعدة البيانات.',
      );
      return;
    }

    final commentController =
        TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context)
                          .viewInsets
                          .bottom,
                ),
                child: SizedBox(
                  height:
                      MediaQuery.of(context)
                              .size
                              .height *
                          .70,
                  child: Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.all(16),
                        child: Text(
                          'التعليقات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<
                            List<Map<String,
                                dynamic>>>(
                          future: loadComments(
                            videoId,
                          ),
                          builder:
                              (context, snapshot) {
                            if (snapshot
                                    .connectionState ==
                                ConnectionState
                                    .waiting) {
                              return const Center(
                                child:
                                    CircularProgressIndicator(),
                              );
                            }

                            final data =
                                snapshot.data ?? [];

                            if (data.isEmpty) {
                              return const Center(
                                child: Text(
                                  'لا توجد تعليقات بعد.',
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount:
                                  data.length,
                              itemBuilder:
                                  (context, index) {
                                final item =
                                    data[index];

                                final profile =
                                    item['profiles']
                                        as Map<String,
                                            dynamic>?;

                                final name =
                                    profile?[
                                            'display_name'] ??
                                        'User';

                                return ListTile(
                                  leading:
                                      const CircleAvatar(
                                    child: Icon(
                                      Icons.person,
                                    ),
                                  ),
                                  title: Text(
                                    name.toString(),
                                  ),
                                  subtitle: Text(
                                    item['comment']
                                            ?.toString() ??
                                        '',
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller:
                                    commentController,
                                decoration:
                                    const InputDecoration(
                                  hintText:
                                      'اكتب تعليقك...',
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            IconButton.filled(
                              onPressed: () async {
                                final text =
                                    commentController
                                        .text
                                        .trim();

                                if (text.isEmpty) {
                                  return;
                                }

                                try {
                                  await supabase
                                      .from(
                                          'comments')
                                      .insert({
                                    'video_id':
                                        videoId,
                                    'user_id':
                                        user.id,
                                    'comment': text,
                                  });

                                  commentController
                                      .clear();

                                  if (mounted) {
                                    setState(() {
                                      comments++;
                                    });
                                  }

                                  setSheetState(() {});
                                } catch (_) {
                                  showMessage(
                                    context,
                                    'تعذر إضافة التعليق.',
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.send,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  Future<List<Map<String, dynamic>>>
      loadComments(String videoId) async {
    final result = await supabase
        .from('comments')
        .select(
          'id,comment,created_at,user_id,'
          'profiles(display_name,username)',
        )
        .eq('video_id', videoId)
        .order(
          'created_at',
          ascending: false,
        );

    return List<Map<String, dynamic>>.from(
      result,
    );
  }

  Future<void> toggleFollow() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    final ownerId = widget.video.ownerId;

    if (ownerId == null ||
        ownerId == user.id) {
      showMessage(
        context,
        'لا يمكن متابعة هذا الحساب.',
      );
      return;
    }

    try {
      final existing = await supabase
          .from('followers')
          .select('id')
          .eq('follower_id', user.id)
          .eq('following_id', ownerId)
          .maybeSingle();

      if (existing != null) {
        await supabase
            .from('followers')
            .delete()
            .eq('follower_id', user.id)
            .eq('following_id', ownerId);

        showMessage(
          context,
          'تم إلغاء المتابعة.',
        );
      } else {
        await supabase.from('followers').insert({
          'follower_id': user.id,
          'following_id': ownerId,
        });

        showMessage(
          context,
          'تمت المتابعة ✅',
        );
      }
    } catch (_) {
      showMessage(
        context,
        'تعذر تنفيذ المتابعة.',
      );
    }
  }

  Future<void> shareVideo() async {
    await Clipboard.setData(
      ClipboardData(
        text: widget.video.url,
      ),
    );

    showMessage(
      context,
      'تم نسخ رابط الفيديو. يمكنك مشاركته الآن.',
    );
  }

  void togglePlay() {
    final c = controller;

    if (c == null) return;

    if (c.value.isPlaying) {
      c.pause();

      setState(() {
        playing = false;
      });
    } else {
      c.play();

      setState(() {
        playing = true;
      });
    }
  }

  void toggleMute() {
    final c = controller;

    if (c == null) return;

    muted = !muted;

    c.setVolume(muted ? 0 : 1);

    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
            child: initialized &&
                    controller != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller!
                          .value
                          .size
                          .width,
                      height: controller!
                          .value
                          .size
                          .height,
                      child:
                          VideoPlayer(controller!),
                    ),
                  )
                : const Center(
                    child:
                        CircularProgressIndicator(),
                  ),
          ),

          // Gradient
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withValues(alpha: .15),
                      Colors.transparent,
                      Colors.black
                          .withValues(alpha: .75),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Brand
          const Positioned(
            top: 20,
            left: 16,
            child: Text(
              'REALITY DUEL',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Mute
          Positioned(
            top: 15,
            right: 10,
            child: IconButton(
              onPressed: toggleMute,
              icon: Icon(
                muted
                    ? Icons.volume_off
                    : Icons.volume_up,
              ),
            ),
          ),

          // Play indicator
          if (!playing)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 80,
                color: Colors.white70,
              ),
            ),

          // Information
          Positioned(
            left: 16,
            right: 90,
            bottom: 25,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title.isEmpty
                      ? 'Reality Duel'
                      : widget.video.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                if (widget
                    .video
                    .description
                    .isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    widget.video.description,
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Positioned(
            right: 10,
            bottom: 35,
            child: Column(
              children: [
                ActionButton(
                  icon: liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: '$likes',
                  color: liked
                      ? Colors.red
                      : Colors.white,
                  onTap: toggleLike,
                ),
                const SizedBox(height: 18),
                ActionButton(
                  icon: Icons.comment_outlined,
                  label: '$comments',
                  onTap: showComments,
                ),
                const SizedBox(height: 18),
                ActionButton(
                  icon: Icons.person_add_alt_1,
                  label: 'متابعة',
                  onTap: toggleFollow,
                ),
                const SizedBox(height: 18),
                ActionButton(
                  icon: Icons.share_outlined,
                  label: 'مشاركة',
                  onTap: shareVideo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor:
                Colors.black.withValues(alpha: .45),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() =>
      _SignInPageState();
}

class _SignInPageState
    extends State<SignInPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  Future<void> signIn() async {
    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    if (email.isEmpty ||
        password.isEmpty) {
      showMessage(
        context,
        'أدخل البريد وكلمة المرور.',
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

      if (mounted) {
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      }
    } on AuthException catch (e) {
      showMessage(
        context,
        e.message,
      );
    } catch (_) {
      showMessage(
        context,
        'حدث خطأ أثناء تسجيل الدخول.',
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 30),
          const Icon(
            Icons.sports_mma,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'REALITY DUEL',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 35),
          InputField(
            controller: emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email_outlined,
            keyboardType:
                TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          InputField(
            controller: passwordController,
            label: 'كلمة المرور',
            icon: Icons.lock_outline,
            obscure: true,
          ),
          const SizedBox(height: 25),
          FilledButton(
            onPressed: loading ? null : signIn,
            child: loading
                ? const CircularProgressIndicator()
                : const Text('دخول'),
          ),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoleChoicePage(),
                ),
              );
            },
            child: const Text(
              'إنشاء حساب جديد',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ROLE CHOICE
// ============================================================

class RoleChoicePage extends StatelessWidget {
  const RoleChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار نوع الحساب'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'كيف تريد استخدام Reality Duel؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 35),
            RoleCard(
              icon: Icons.person_search,
              title: 'موهبة / Talent',
              description:
                  'اعرض موهبتك وشارك في التحديات واكتشف الفرص.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SignUpPage(
                      isCompany: false,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            RoleCard(
              icon: Icons.business_outlined,
              title: 'شركة / Company',
              description:
                  'اكتشف المواهب وانشر الوظائف والفرص والتحديات.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SignUpPage(
                      isCompany: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SIGN UP
// ============================================================

class SignUpPage extends StatefulWidget {
  final bool isCompany;

  const SignUpPage({
    super.key,
    required this.isCompany,
  });

  @override
  State<SignUpPage> createState() =>
      _SignUpPageState();
}

class _SignUpPageState
    extends State<SignUpPage> {
  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final countryController =
      TextEditingController();

  final headlineController =
      TextEditingController();

  final industryController =
      TextEditingController();

  bool loading = false;

  String generateUsername() {
    final source =
        nameController.text.trim().toLowerCase();

    final clean = source.replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );

    final base = clean.isEmpty
        ? 'user'
        : clean;

    return '${base.substring(0, base.length > 18 ? 18 : base.length)}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> createAccount() async {
    final name =
        nameController.text.trim();

    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.length < 6) {
      showMessage(
        context,
        'أدخل البيانات بشكل صحيح. كلمة المرور يجب أن تكون 6 أحرف على الأقل.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final username =
        generateUsername();

    try {
      final response =
          await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'display_name': name,
          'is_talent': !widget.isCompany,
          'is_company': widget.isCompany,
        },
      );

      final user = response.user;

      if (user == null) {
        throw Exception(
          'لم يتم إنشاء المستخدم.',
        );
      }

      // إذا كان تأكيد البريد مغلقًا
      // تكون هناك جلسة مباشرة.
      if (response.session != null) {
        await saveProfile(
          user,
          username,
          name,
        );

        if (mounted) {
          Navigator.of(context).popUntil(
            (route) => route.isFirst,
          );
        }
      } else {
        // عند تفعيل تأكيد البريد،
        // Trigger في Supabase ينشئ profile
        // تلقائيًا من metadata.
        if (mounted) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text(
                'تم إنشاء الحساب',
              ),
              content: Text(
                'تم إنشاء حسابك. تحقق من بريدك الإلكتروني لتفعيل الحساب ثم قم بتسجيل الدخول.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('حسنًا'),
                ),
              ],
            ),
          );

          Navigator.of(context).popUntil(
            (route) => route.isFirst,
          );
        }
      }
    } on AuthException catch (e) {
      if (e.message
          .toLowerCase()
          .contains('already registered')) {
        showMessage(
          context,
          'هذا البريد الإلكتروني مسجل مسبقًا.',
        );
      } else {
        showMessage(
          context,
          e.message,
        );
      }
    } catch (e) {
      showMessage(
        context,
        'حدث خطأ أثناء إنشاء الحساب.',
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> saveProfile(
    User user,
    String username,
    String name,
  ) async {
    await supabase.from('profiles').upsert({
      'id': user.id,
      'username': username,
      'display_name': name,
      'bio': widget.isCompany
          ? industryController.text.trim()
          : headlineController.text.trim(),
      'country':
          countryController.text.trim(),
      'is_talent': !widget.isCompany,
      'is_company': widget.isCompany,
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    countryController.dispose();
    headlineController.dispose();
    industryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.isCompany;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          company
              ? 'إنشاء حساب شركة'
              : 'إنشاء حساب موهبة',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          InputField(
            controller: nameController,
            label: company
                ? 'اسم الشركة'
                : 'الاسم',
            icon: company
                ? Icons.business
                : Icons.person,
          ),
          const SizedBox(height: 14),
          InputField(
            controller: emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email_outlined,
            keyboardType:
                TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          InputField(
            controller: passwordController,
            label: 'كلمة المرور',
            icon: Icons.lock_outline,
            obscure: true,
          ),
          const SizedBox(height: 14),
          InputField(
            controller: countryController,
            label: 'الدولة',
            icon: Icons.public,
          ),
          const SizedBox(height: 14),
          InputField(
            controller: company
                ? industryController
                : headlineController,
            label: company
                ? 'مجال الشركة'
                : 'المجال / المهارة',
            icon: Icons.star_outline,
          ),
          const SizedBox(height: 25),
          FilledButton(
            onPressed:
                loading ? null : createAccount,
            child: loading
                ? const CircularProgressIndicator()
                : const Text(
                    'إنشاء الحساب',
                  ),
          ),
        ],
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
  State<DuelsPage> createState() =>
      _DuelsPageState();
}

class _DuelsPageState
    extends State<DuelsPage> {
  bool loading = true;
  List<Map<String, dynamic>> duels = [];

  @override
  void initState() {
    super.initState();
    loadDuels();
  }

  Future<void> loadDuels() async {
    try {
      final data = await supabase
          .from('duels')
          .select()
          .order(
            'created_at',
            ascending: false,
          );

      if (mounted) {
        setState(() {
          duels =
              List<Map<String, dynamic>>.from(
            data,
          );
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> createDuel() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    final titleController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    final categoryController =
        TextEditingController(
      text: 'General',
    );

    final countryController =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'إنشاء Duel جديد',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(
                    labelText: 'عنوان التحدي',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:
                      descriptionController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText: 'الوصف',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:
                      categoryController,
                  decoration:
                      const InputDecoration(
                    labelText: 'الفئة',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:
                      countryController,
                  decoration:
                      const InputDecoration(
                    labelText: 'الدولة',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text
                    .trim()
                    .isEmpty) {
                  return;
                }

                try {
                  await supabase
                      .from('duels')
                      .insert({
                    'creator_id': user.id,
                    'title':
                        titleController.text.trim(),
                    'description':
                        descriptionController.text
                            .trim(),
                    'category':
                        categoryController.text
                            .trim(),
                    'country':
                        countryController.text
                            .trim(),
                    'status': 'open',
                  });

                  if (mounted) {
                    Navigator.pop(
                        dialogContext);
                  }

                  await loadDuels();

                  showMessage(
                    context,
                    'تم إنشاء التحدي بنجاح ✅',
                  );
                } catch (_) {
                  showMessage(
                    context,
                    'تعذر إنشاء التحدي.',
                  );
                }
              },
              child: const Text('نشر التحدي'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    countryController.dispose();
  }

  Future<void> joinDuel(
    Map<String, dynamic> duel,
  ) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    final videos = await supabase
        .from('videos')
        .select(
          'id,title,storage_path',
        )
        .eq('user_id', user.id)
        .order(
          'created_at',
          ascending: false,
        );

    if (videos.isEmpty) {
      showMessage(
        context,
        'ارفع فيديو أولًا حتى تتمكن من المشاركة في التحدي.',
      );
      return;
    }

    final selected =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'اختر فيديو المشاركة',
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: videos.length,
              itemBuilder:
                  (context, index) {
                final video =
                    videos[index];

                return ListTile(
                  leading: const Icon(
                    Icons.video_library,
                  ),
                  title: Text(
                    video['title']
                            ?.toString() ??
                        'Video',
                  ),
                  onTap: () {
                    Navigator.pop(
                      dialogContext,
                      Map<String, dynamic>.from(
                        video,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    try {
      await supabase
          .from('duel_entries')
          .insert({
        'duel_id': duel['id'],
        'user_id': user.id,
        'video_id': selected['id'],
      });

      showMessage(
        context,
        'تم تسجيل مشاركتك في التحدي ✅',
      );
    } catch (e) {
      final message =
          e.toString().toLowerCase();

      if (message.contains('duplicate') ||
          message.contains('unique')) {
        showMessage(
          context,
          'أنت مشارك بالفعل في هذا التحدي.',
        );
      } else {
        showMessage(
          context,
          'تعذر المشاركة في التحدي.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duels'),
        actions: [
          IconButton(
            onPressed: loadDuels,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton:
          supabase.auth.currentUser != null
              ? FloatingActionButton.extended(
                  onPressed: createDuel,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'إنشاء Duel',
                  ),
                )
              : null,
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : duels.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد تحديات حاليًا.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadDuels,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount: duels.length,
                    itemBuilder:
                        (context, index) {
                      final duel =
                          duels[index];

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 15,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                duel['title']
                                        ?.toString() ??
                                    'Duel',
                                style:
                                    const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                duel['description']
                                        ?.toString() ??
                                    '',
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'الفئة: ${duel['category'] ?? 'General'}',
                              ),
                              if ((duel['country']
                                          ?.toString() ??
                                      '')
                                  .isNotEmpty)
                                Text(
                                  'الدولة: ${duel['country']}',
                                ),
                              const SizedBox(
                                height: 12,
                              ),
                              FilledButton(
                                onPressed: () =>
                                    joinDuel(
                                  duel,
                                ),
                                child:
                                    const Text(
                                  'شارك في التحدي',
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

class DiscoverTalentPage
    extends StatefulWidget {
  const DiscoverTalentPage({super.key});

  @override
  State<DiscoverTalentPage> createState() =>
      _DiscoverTalentPageState();
}

class _DiscoverTalentPageState
    extends State<DiscoverTalentPage> {
  final searchController =
      TextEditingController();

  List<ProfileData> talents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTalents();
  }

  Future<void> loadTalents([
    String query = '',
  ]) async {
    setState(() {
      loading = true;
    });

    try {
      final q = query.trim();

      dynamic data;

      if (q.isEmpty) {
        data = await supabase
            .from('profiles')
            .select()
            .eq('is_talent', true)
            .order(
              'followers_count',
              ascending: false,
            );
      } else {
        data = await supabase
            .from('profiles')
            .select()
            .eq('is_talent', true)
            .or(
              'display_name.ilike.%$q%,'
              'username.ilike.%$q%,'
              'country.ilike.%$q%,'
              'bio.ilike.%$q%',
            )
            .order(
              'followers_count',
              ascending: false,
            );
      }

      final result =
          List<Map<String, dynamic>>.from(
        data,
      );

      if (mounted) {
        setState(() {
          talents = result
              .map(
                ProfileData.fromMap,
              )
              .toList();
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
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
        title: const Text(
          'Discover Talent',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(14),
            child: TextField(
              controller:
                  searchController,
              onSubmitted: loadTalents,
              decoration:
                  InputDecoration(
                hintText:
                    'ابحث عن موهبة...',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    IconButton(
                  onPressed: () =>
                      loadTalents(
                    searchController.text,
                  ),
                  icon: const Icon(
                    Icons.arrow_forward,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : talents.isEmpty
                    ? const Center(
                        child: Text(
                          'لم نجد مواهب مطابقة.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            loadTalents(
                          searchController.text,
                        ),
                        child:
                            ListView.builder(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                          ),
                          itemCount:
                              talents.length,
                          itemBuilder:
                              (context, index) {
                            final talent =
                                talents[index];

                            return Card(
                              child: ListTile(
                                leading:
                                    CircleAvatar(
                                  radius: 27,
                                  backgroundImage:
                                      talent.avatarUrl !=
                                                  null &&
                                              talent.avatarUrl!
                                                  .isNotEmpty
                                          ? NetworkImage(
                                              talent.avatarUrl!,
                                            )
                                          : null,
                                  child: talent.avatarUrl ==
                                              null ||
                                          talent.avatarUrl!
                                              .isEmpty
                                      ? const Icon(
                                          Icons.person,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  talent
                                      .displayName,
                                ),
                                subtitle:
                                    Text(
                                  '@${talent.username}\n'
                                  '${talent.country}\n'
                                  '${talent.followersCount} متابع • '
                                  '${talent.videosCount} فيديو',
                                ),
                                isThreeLine: true,
                                trailing:
                                    const Icon(
                                  Icons
                                      .arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PublicTalentPage(
                                        profile:
                                            talent,
                                      ),
                                    ),
                                  );
                                },
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
// PUBLIC TALENT PAGE
// ============================================================

class PublicTalentPage
    extends StatefulWidget {
  final ProfileData profile;

  const PublicTalentPage({
    super.key,
    required this.profile,
  });

  @override
  State<PublicTalentPage> createState() =>
      _PublicTalentPageState();
}

class _PublicTalentPageState
    extends State<PublicTalentPage> {
  List<FeedVideo> videos = [];
  bool loading = true;
  bool following = false;

  @override
  void initState() {
    super.initState();
    loadVideos();
    checkFollowing();
  }

  Future<void> loadVideos() async {
    try {
      final data = await supabase
          .from('videos')
          .select(
            'id,user_id,storage_path,title,'
            'description,views_count,likes_count,'
            'comments_count',
          )
          .eq(
            'user_id',
            widget.profile.id,
          )
          .order(
            'created_at',
            ascending: false,
          );

      final list = <FeedVideo>[];

      for (final row in data) {
        final path =
            row['storage_path']?.toString();

        if (path == null) continue;

        list.add(
          FeedVideo(
            id: row['id']?.toString(),
            path: path,
            url: supabase.storage
                .from(videoBucket)
                .getPublicUrl(path),
            title:
                row['title']?.toString() ?? '',
            description:
                row['description']?.toString() ??
                    '',
            ownerId:
                row['user_id']?.toString(),
            views:
                (row['views_count'] as num?)
                        ?.toInt() ??
                    0,
            likes:
                (row['likes_count'] as num?)
                        ?.toInt() ??
                    0,
            comments:
                (row['comments_count'] as num?)
                        ?.toInt() ??
                    0,
          ),
        );
      }

      if (mounted) {
        setState(() {
          videos = list;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> checkFollowing() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final result = await supabase
          .from('followers')
          .select('id')
          .eq(
            'follower_id',
            user.id,
          )
          .eq(
            'following_id',
            widget.profile.id,
          )
          .maybeSingle();

      if (mounted) {
        setState(() {
          following = result != null;
        });
      }
    } catch (_) {}
  }

  Future<void> follow() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    if (user.id == widget.profile.id) {
      return;
    }

    try {
      if (following) {
        await supabase
            .from('followers')
            .delete()
            .eq(
              'follower_id',
              user.id,
            )
            .eq(
              'following_id',
              widget.profile.id,
            );
      } else {
        await supabase
            .from('followers')
            .insert({
          'follower_id': user.id,
          'following_id':
              widget.profile.id,
        });
      }

      setState(() {
        following = !following;
      });
    } catch (_) {
      showMessage(
        context,
        'تعذر تنفيذ المتابعة.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.displayName),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 45,
            backgroundImage:
                p.avatarUrl != null &&
                        p.avatarUrl!.isNotEmpty
                    ? NetworkImage(
                        p.avatarUrl!,
                      )
                    : null,
            child: p.avatarUrl == null ||
                    p.avatarUrl!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 45,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            p.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '@${p.username}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (p.bio.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Text(
                p.bio,
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              StatItem(
                value:
                    '${p.followersCount}',
                label: 'متابعون',
              ),
              StatItem(
                value:
                    '${p.followingCount}',
                label: 'يتابع',
              ),
              StatItem(
                value:
                    '${p.videosCount}',
                label: 'فيديو',
              ),
            ],
          ),
          const SizedBox(height: 15),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: FilledButton(
              onPressed: follow,
              child: Text(
                following
                    ? 'إلغاء المتابعة'
                    : 'متابعة',
              ),
            ),
          ),
          const Divider(height: 35),
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (videos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'لا توجد فيديوهات بعد.',
                ),
              ),
            )
          else
            ...videos.map(
              (video) => SizedBox(
                height: 300,
                child: VideoFeedItem(
                  video: video,
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

class OpportunitiesPage
    extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() =>
      _OpportunitiesPageState();
}

class _OpportunitiesPageState
    extends State<OpportunitiesPage> {
  bool loading = true;
  List<Map<String, dynamic>>
      opportunities = [];

  bool get isCompany {
    final user = supabase.auth.currentUser;

    if (user == null) return false;

    return false;
  }

  @override
  void initState() {
    super.initState();
    loadOpportunities();
  }

  Future<void> loadOpportunities() async {
    try {
      final data = await supabase
          .from('opportunities')
          .select()
          .eq('status', 'open')
          .order(
            'created_at',
            ascending: false,
          );

      if (mounted) {
        setState(() {
          opportunities =
              List<Map<String, dynamic>>.from(
            data,
          );
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<bool> currentUserIsCompany() async {
    final user = supabase.auth.currentUser;

    if (user == null) return false;

    final profile = await supabase
        .from('profiles')
        .select('is_company')
        .eq('id', user.id)
        .maybeSingle();

    return profile?['is_company'] == true;
  }

  Future<void> createOpportunity() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    if (!await currentUserIsCompany()) {
      showMessage(
        context,
        'هذه الوظيفة متاحة لحسابات الشركات فقط.',
      );
      return;
    }

    final titleController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    final typeController =
        TextEditingController(
      text: 'job',
    );

    final countryController =
        TextEditingController();

    final locationController =
        TextEditingController();

    final skillsController =
        TextEditingController();

    bool remote = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'نشر فرصة',
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller:
                          titleController,
                      decoration:
                          const InputDecoration(
                        labelText: 'العنوان',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller:
                          descriptionController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText: 'الوصف',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller:
                          typeController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'نوع الفرصة: job / grant / project',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller:
                          countryController,
                      decoration:
                          const InputDecoration(
                        labelText: 'الدولة',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller:
                          locationController,
                      decoration:
                          const InputDecoration(
                        labelText: 'الموقع',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller:
                          skillsController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'المهارات مفصولة بفاصلة',
                      ),
                    ),
                    CheckboxListTile(
                      value: remote,
                      onChanged: (value) {
                        setDialogState(() {
                          remote =
                              value ?? false;
                        });
                      },
                      title: const Text(
                        'عن بعد',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (titleController
                        .text
                        .trim()
                        .isEmpty) {
                      return;
                    }

                    try {
                      final skills =
                          skillsController
                              .text
                              .split(',')
                              .map(
                                (e) => e.trim(),
                              )
                              .where(
                                (e) =>
                                    e.isNotEmpty,
                              )
                              .toList();

                      await supabase
                          .from(
                              'opportunities')
                          .insert({
                        'company_id':
                            user.id,
                        'title':
                            titleController
                                .text
                                .trim(),
                        'description':
                            descriptionController
                                .text
                                .trim(),
                        'opportunity_type':
                            typeController
                                .text
                                .trim(),
                        'country':
                            countryController
                                .text
                                .trim(),
                        'location':
                            locationController
                                .text
                                .trim(),
                        'skills': skills,
                        'is_remote': remote,
                        'status': 'open',
                      });

                      if (mounted) {
                        Navigator.pop(
                          dialogContext,
                        );
                      }

                      await loadOpportunities();

                      showMessage(
                        context,
                        'تم نشر الفرصة ✅',
                      );
                    } catch (_) {
                      showMessage(
                        context,
                        'تعذر نشر الفرصة.',
                      );
                    }
                  },
                  child:
                      const Text('نشر'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    typeController.dispose();
    countryController.dispose();
    locationController.dispose();
    skillsController.dispose();
  }

  Future<void> apply(
    Map<String, dynamic> opportunity,
  ) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showLoginRequired(context);
      return;
    }

    final messageController =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'التقديم على الفرصة',
          ),
          content: TextField(
            controller: messageController,
            maxLines: 5,
            decoration:
                const InputDecoration(
              hintText:
                  'اكتب رسالة لصاحب الفرصة...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
              ),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await supabase
                      .from('applications')
                      .insert({
                    'opportunity_id':
                        opportunity['id'],
                    'applicant_id':
                        user.id,
                    'message':
                        messageController
                            .text
                            .trim(),
                    'status': 'pending',
                  });

                  if (mounted) {
                    Navigator.pop(
                      dialogContext,
                    );
                  }

                  showMessage(
                    context,
                    'تم إرسال طلبك بنجاح ✅',
                  );
                } catch (e) {
                  final text =
                      e.toString().toLowerCase();

                  if (text.contains(
                          'duplicate') ||
                      text.contains(
                          'unique')) {
                    showMessage(
                      context,
                      'لقد تقدمت لهذه الفرصة مسبقًا.',
                    );
                  } else {
                    showMessage(
                      context,
                      'تعذر إرسال الطلب.',
                    );
                  }
                }
              },
              child:
                  const Text('إرسال الطلب'),
            ),
          ],
        );
      },
    );

    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفرص'),
        actions: [
          IconButton(
            onPressed: loadOpportunities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton:
          supabase.auth.currentUser != null
              ? FutureBuilder<bool>(
                  future:
                      currentUserIsCompany(),
                  builder:
                      (context, snapshot) {
                    if (snapshot.data != true) {
                      return const SizedBox
                          .shrink();
                    }

                    return FloatingActionButton.extended(
                      onPressed:
                          createOpportunity,
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'نشر فرصة',
                      ),
                    );
                  },
                )
              : null,
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : opportunities.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد فرص متاحة حاليًا.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh:
                      loadOpportunities,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount:
                        opportunities.length,
                    itemBuilder:
                        (context, index) {
                      final item =
                          opportunities[index];

                      final skills =
                          (item['skills']
                                  as List?)
                              ?.map(
                                (e) =>
                                    e.toString(),
                              )
                              .toList() ??
                          [];

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 15,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                item['title']
                                        ?.toString() ??
                                    'فرصة',
                                style:
                                    const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                item['description']
                                        ?.toString() ??
                                    '',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'النوع: ${item['opportunity_type'] ?? 'job'}',
                              ),
                              if ((item['country']
                                          ?.toString() ??
                                      '')
                                  .isNotEmpty)
                                Text(
                                  'الدولة: ${item['country']}',
                                ),
                              if (item['is_remote'] ==
                                  true)
                                const Text(
                                  '🌍 عن بعد',
                                ),
                              if (skills.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 8,
                                  ),
                                  child: Wrap(
                                    spacing: 6,
                                    children:
                                        skills
                                            .map(
                                              (skill) =>
                                                  Chip(
                                                label:
                                                    Text(skill),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              FilledButton(
                                onPressed: () =>
                                    apply(item),
                                child:
                                    const Text(
                                  'التقديم',
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
// PROFILE
// ============================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  ProfileData? profile;
  bool loading = true;

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

      if (mounted) {
        setState(() {
          if (data != null) {
            profile =
                ProfileData.fromMap(data);
          }

          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> editProfile() async {
    final p = profile;

    if (p == null) return;

    final nameController =
        TextEditingController(
      text: p.displayName,
    );

    final bioController =
        TextEditingController(
      text: p.bio,
    );

    final countryController =
        TextEditingController(
      text: p.country,
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'تعديل الملف الشخصي',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'الاسم',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:
                      countryController,
                  decoration:
                      const InputDecoration(
                    labelText: 'الدولة',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bioController,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(
                    labelText: 'نبذة',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
              ),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await supabase
                      .from('profiles')
                      .update({
                    'display_name':
                        nameController.text
                            .trim(),
                    'country':
                        countryController.text
                            .trim(),
                    'bio':
                        bioController.text.trim(),
                    'updated_at':
                        DateTime.now()
                            .toIso8601String(),
                  })
                      .eq('id', p.id);

                  if (mounted) {
                    Navigator.pop(
                      dialogContext,
                    );
                  }

                  await loadProfile();

                  showMessage(
                    context,
                    'تم تحديث الملف الشخصي ✅',
                  );
                } catch (_) {
                  showMessage(
                    context,
                    'تعذر تحديث الملف.',
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    bioController.dispose();
    countryController.dispose();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (mounted) {
      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
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

    final p = profile;

    if (p == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('حسابي'),
        ),
        body: const Center(
          child: Text(
            'لم يتم العثور على الملف الشخصي.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            onPressed: editProfile,
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage:
                p.avatarUrl != null &&
                        p.avatarUrl!.isNotEmpty
                    ? NetworkImage(
                        p.avatarUrl!,
                      )
                    : null,
            child: p.avatarUrl == null ||
                    p.avatarUrl!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 50,
                  )
                : null,
          ),
          const SizedBox(height: 15),
          Text(
            p.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '@${p.username}',
            textAlign: TextAlign.center,
          ),
          if (p.country.isNotEmpty)
            Text(
              p.country,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 15),
          if (p.bio.isNotEmpty)
            Text(
              p.bio,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              StatItem(
                value:
                    '${p.followersCount}',
                label: 'متابعون',
              ),
              StatItem(
                value:
                    '${p.followingCount}',
                label: 'يتابع',
              ),
              StatItem(
                value:
                    '${p.videosCount}',
                label: 'فيديو',
              ),
            ],
          ),
          const SizedBox(height: 35),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.person_outline,
              ),
              title: const Text(
                'نوع الحساب',
              ),
              subtitle: Text(
                p.isCompany
                    ? 'Company'
                    : 'Talent',
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
            label: const Text(
              'تسجيل الخروج',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL WIDGETS
// ============================================================

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 45,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(description),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String label;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label),
        ],
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

Future<void> incrementView(
  String videoId,
) async {
  try {
    await supabase.rpc(
      'increment_video_view',
      params: {
        'p_video_id': videoId,
      },
    );
  } catch (_) {}
}

Future<void> showLoginRequired(
  BuildContext context,
) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'تسجيل الدخول مطلوب',
        ),
        content: const Text(
          'يمكنك مشاهدة الفيديوهات بدون حساب، لكن تحتاج إلى تسجيل الدخول للتفاعل والمشاركة.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              dialogContext,
            ),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SignInPage(),
                ),
              );
            },
            child: const Text(
              'تسجيل الدخول',
            ),
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
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

void showLoadingDialog(
  BuildContext context,
  String message,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 18),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
      );
    },
  );
}
