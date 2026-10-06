import 'dart:async';

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

  runApp(const ProveApp());
}

class ProveApp extends StatelessWidget {
  const ProveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PROVE',
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

/* ============================================================
   APP ROOT
   ============================================================ */

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
    return FeedPage(
      loggedIn: session != null,
    );
  }
}

/* ============================================================
   FEED
   ============================================================ */

class FeedPage extends StatefulWidget {
  final bool loggedIn;

  const FeedPage({
    super.key,
    required this.loggedIn,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final PageController pageController = PageController();

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

      final result = (response as List)
          .map(
            (item) => VideoItem.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((video) => video.url.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        videos = result;
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
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off,
                  size: 65,
                ),
                const SizedBox(height: 20),
                const Text(
                  'تعذر تحميل الفيديوهات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
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
        backgroundColor: Colors.black,
        body: RefreshIndicator(
          onRefresh: loadVideos,
          child: ListView(
            children: const [
              SizedBox(height: 300),
              Center(
                child: Text(
                  'لا توجد فيديوهات حتى الآن',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return ProveVideoCard(
            video: videos[index],
          );
        },
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

  const VideoItem({
    required this.id,
    required this.url,
    required this.caption,
    required this.views,
    required this.likes,
    required this.comments,
    this.userId,
  });

  factory VideoItem.fromMap(
    Map<String, dynamic> map,
  ) {
    String url = '';

    final directUrl =
        map['video_url']?.toString();

    if (directUrl != null &&
        directUrl.isNotEmpty) {
      url = directUrl;
    } else {
      final path =
          map['storage_path']?.toString();

      if (path != null && path.isNotEmpty) {
        url = supabase.storage
            .from(videoBucket)
            .getPublicUrl(path);
      }
    }

    return VideoItem(
      id: map['id'].toString(),
      url: url,
      caption:
          map['caption']?.toString() ?? '',
      views:
          _toInt(map['views_count']),
      likes:
          _toInt(map['likes_count']),
      comments:
          _toInt(map['comments_count']),
      userId:
          map['user_id']?.toString(),
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
   VIDEO CARD
   ============================================================ */

class ProveVideoCard extends StatefulWidget {
  final VideoItem video;

  const ProveVideoCard({
    super.key,
    required this.video,
  });

  @override
  State<ProveVideoCard> createState() =>
      _ProveVideoCardState();
}

class _ProveVideoCardState
    extends State<ProveVideoCard> {
  late VideoPlayerController controller;

  bool initialized = false;
  bool liked = false;
  bool loadingLike = false;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    controller =
        VideoPlayerController.networkUrl(
      Uri.parse(widget.video.url),
    );

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      if (!mounted) return;

      setState(() {
        initialized = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        initialized = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> toggleLike() async {
    final user =
        supabase.auth.currentUser;

    if (user == null) {
      showLoginMessage();
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
            .eq(
              'video_id',
              widget.video.id,
            )
            .eq(
              'user_id',
              user.id,
            );

        if (!mounted) return;

        setState(() {
          liked = false;
        });
      } else {
        await supabase
            .from('likes')
            .insert({
          'video_id': widget.video.id,
          'user_id': user.id,
        });

        if (!mounted) return;

        setState(() {
          liked = true;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('تعذر تنفيذ الإعجاب: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingLike = false;
        });
      }
    }
  }

  void showLoginMessage() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'سجّل الدخول أولًا لاستخدام هذه الميزة',
        ),
      ),
    );
  }

  void togglePlay() {
    if (!initialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [

          /* VIDEO */

          Container(
            color: Colors.black,
          ),

          if (initialized)
            Center(
              child: AspectRatio(
                aspectRatio:
                    controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),

          if (!initialized)
            const Center(
              child:
                  CircularProgressIndicator(),
            ),

          /* PROVE LOGO */

          const Positioned(
            top: 55,
            left: 20,
            child: Text(
              'PROVE',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),

          /* ACTIONS */

          Positioned(
            right: 14,
            bottom: 120,
            child: Column(
              children: [

                GestureDetector(
                  onTap: toggleLike,
                  child: Column(
                    children: [
                      Icon(
                        liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 38,
                        color: liked
                            ? Colors.red
                            : Colors.white,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.video.likes}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: showLoginMessage,
                  child: const Column(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 36,
                      ),
                      SizedBox(height: 5),
                      Text('تعليق'),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Column(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 34,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.video.views}',
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: showLoginMessage,
                  child: const Icon(
                    Icons.person_add_alt_1,
                    size: 34,
                  ),
                ),
              ],
            ),
          ),

          /* CAPTION */

          Positioned(
            left: 18,
            right: 85,
            bottom: 35,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                if (widget
                    .video
                    .userId !=
                    null)
                  Text(
                    '@${widget.video.userId!.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                const SizedBox(height: 8),

                if (widget
                    .video
                    .caption
                    .isNotEmpty)
                  Text(
                    widget.video.caption,
                    maxLines: 4,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                const SizedBox(height: 8),

                const Text(
                  'The World Is Your Arena',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /* PAUSE ICON */

          if (initialized &&
              !controller.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_arrow,
                size: 85,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }
}
