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

final supabase = Supabase.instance.client;

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
  bool isArabic = true;

  void toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
    });
  }

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
        cardColor: const Color(0xFF11131D),
      ),
      home: AppShell(
        isArabic: isArabic,
        onLanguageChanged: toggleLanguage,
      ),
    );
  }
}

/* ============================================================
   HELPERS
============================================================ */

String text(bool ar, String arabic, String english) {
  return ar ? arabic : english;
}

void showMessage(
  BuildContext context,
  String message,
) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message)),
    );
}

Future<Map<String, dynamic>?> getMyProfile() async {
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  final result = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  return result;
}

/* ============================================================
   APP SHELL
============================================================ */

class AppShell extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageChanged;

  const AppShell({
    super.key,
    required this.isArabic,
    required this.onLanguageChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final loggedIn = supabase.auth.currentUser != null;

    final pages = [
      FeedPage(isArabic: widget.isArabic),
      DiscoverPage(isArabic: widget.isArabic),
      OpportunitiesPage(isArabic: widget.isArabic),
      ProfilePage(isArabic: widget.isArabic),
    ];

    return Directionality(
      textDirection:
          widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: pages,
        ),
        floatingActionButton: loggedIn
            ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadVideoPage(
                        isArabic: widget.isArabic,
                      ),
                    ),
                  );

                  if (mounted) {
                    setState(() {});
                  }
                },
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) {
            setState(() {
              index = value;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.play_circle_outline),
              selectedIcon: const Icon(Icons.play_circle),
              label: text(widget.isArabic, 'الفيديو', 'Feed'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: text(widget.isArabic, 'المواهب', 'Talent'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.work_outline),
              selectedIcon: const Icon(Icons.work),
              label: text(widget.isArabic, 'الفرص', 'Jobs'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: text(widget.isArabic, 'حسابي', 'Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   FEED
============================================================ */

class FeedPage extends StatefulWidget {
  final bool isArabic;

  const FeedPage({
    super.key,
    required this.isArabic,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Map<String, dynamic>> videos = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await supabase
          .from('videos')
          .select('''
            id,
            user_id,
            title,
            description,
            storage_path,
            video_url,
            thumbnail_url,
            duration_seconds,
            views_count,
            likes_count,
            comments_count,
            shares_count,
            is_public,
            created_at
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false);

      final rows = List<Map<String, dynamic>>.from(result);

      for (final video in rows) {
        final profile = await supabase
            .from('profiles')
            .select('username,display_name,avatar_url')
            .eq('id', video['user_id'])
            .maybeSingle();

        video['profile'] = profile;
      }

      if (!mounted) return;

      setState(() {
        videos = rows;
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
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                text(
                  widget.isArabic,
                  'تعذر تحميل الفيديوهات',
                  'Could not load videos',
                ),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loadVideos,
                child: Text(
                  text(widget.isArabic, 'إعادة المحاولة', 'Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadVideos,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .75,
              child: Center(
                child: Text(
                  text(
                    widget.isArabic,
                    'لا توجد فيديوهات حتى الآن',
                    'No videos yet',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadVideos,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return VideoCard(
            video: videos[index],
            isArabic: widget.isArabic,
          );
        },
      ),
    );
  }
}

/* ============================================================
   VIDEO CARD
============================================================ */

class VideoCard extends StatefulWidget {
  final Map<String, dynamic> video;
  final bool isArabic;

  const VideoCard({
    super.key,
    required this.video,
    required this.isArabic,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? controller;

  bool liked = false;
  bool following = false;
  bool loadingAction = false;

  @override
  void initState() {
    super.initState();
    initializeVideo();
    checkLike();
    checkFollow();
  }

  Future<void> initializeVideo() async {
    String? url = widget.video['video_url']?.toString();

    if (url == null || url.isEmpty) {
      final path = widget.video['storage_path']?.toString();

      if (path != null && path.isNotEmpty) {
        url = supabase.storage.from('videos').getPublicUrl(path);
      }
    }

    if (url == null || url.isEmpty) return;

    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
    );

    controller = c;

    try {
      await c.initialize();
      await c.setLooping(true);

      if (mounted) {
        setState(() {});
        await c.play();
      }
    } catch (_) {}
  }

  Future<void> checkLike() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final row = await supabase
          .from('likes')
          .select('id')
          .eq('video_id', widget.video['id'])
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          liked = row != null;
        });
      }
    } catch (_) {}
  }

  Future<void> checkFollow() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    if (user.id == widget.video['user_id']) return;

    try {
      final row = await supabase
          .from('followers')
          .select('id')
          .eq('follower_id', user.id)
          .eq('following_id', widget.video['user_id'])
          .maybeSingle();

      if (mounted) {
        setState(() {
          following = row != null;
        });
      }
    } catch (_) {}
  }

  Future<void> toggleLike() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthPage(
            isArabic: widget.isArabic,
          ),
        ),
      );

      if (mounted) {
        checkLike();
      }

      return;
    }

    if (loadingAction) return;

    setState(() {
      loadingAction = true;
    });

    try {
      if (liked) {
        await supabase
            .from('likes')
            .delete()
            .eq('video_id', widget.video['id'])
            .eq('user_id', user.id);
      } else {
        await supabase.from('likes').insert({
          'video_id': widget.video['id'],
          'user_id': user.id,
        });
      }

      if (mounted) {
        setState(() {
          liked = !liked;
        });
      }
    } catch (e) {
      if (mounted) {
        showMessage(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingAction = false;
        });
      }
    }
  }

  Future<void> toggleFollow() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthPage(
            isArabic: widget.isArabic,
          ),
        ),
      );

      if (mounted) {
        checkFollow();
      }

      return;
    }

    if (user.id == widget.video['user_id']) return;

    try {
      if (following) {
        await supabase
            .from('followers')
            .delete()
            .eq('follower_id', user.id)
            .eq('following_id', widget.video['user_id']);
      } else {
        await supabase.from('followers').insert({
          'follower_id': user.id,
          'following_id': widget.video['user_id'],
        });
      }

      if (mounted) {
        setState(() {
          following = !following;
        });
      }
    } catch (e) {
      if (mounted) {
        showMessage(context, e.toString());
      }
    }
  }

  Future<void> openComments() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121B),
      builder: (_) => CommentsSheet(
        videoId: widget.video['id'],
        isArabic: widget.isArabic,
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        widget.video['profile'] as Map<String, dynamic>?;

    final username =
        profile?['display_name'] ??
        profile?['username'] ??
        'Reality Duel';

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: controller != null &&
                  controller!.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    final c = controller!;

                    if (c.value.isPlaying) {
                      c.pause();
                    } else {
                      c.play();
                    }

                    setState(() {});
                  },
                  child: Center(
                    child: AspectRatio(
                      aspectRatio:
                          controller!.value.aspectRatio,
                      child: VideoPlayer(controller!),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),

        Positioned(
          left: 16,
          right: 90,
          bottom: 35,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '@$username',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              if ((widget.video['title'] ?? '')
                  .toString()
                  .isNotEmpty)
                Text(
                  widget.video['title'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if ((widget.video['description'] ?? '')
                  .toString()
                  .isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(top: 5),
                  child: Text(
                    widget.video['description'].toString(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),

        Positioned(
          right: 12,
          bottom: 35,
          child: Column(
            children: [
              CircleAvatar(
                radius: 25,
                child: IconButton(
                  onPressed: toggleLike,
                  icon: Icon(
                    liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        liked ? Colors.red : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.video['likes_count'] ?? 0}',
              ),
              const SizedBox(height: 18),
              CircleAvatar(
                radius: 25,
                child: IconButton(
                  onPressed: openComments,
                  icon: const Icon(Icons.comment),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.video['comments_count'] ?? 0}',
              ),
              const SizedBox(height: 18),
              CircleAvatar(
                radius: 25,
                child: IconButton(
                  onPressed: toggleFollow,
                  icon: Icon(
                    following
                        ? Icons.person_remove
                        : Icons.person_add,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ============================================================
   COMMENTS
============================================================ */

class CommentsSheet extends StatefulWidget {
  final String videoId;
  final bool isArabic;

  const CommentsSheet({
    super.key,
    required this.videoId,
    required this.isArabic,
  });

  @override
  State<CommentsSheet> createState() =>
      _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final controller = TextEditingController();

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
          .from('comments')
          .select('''
            id,
            user_id,
            body,
            created_at
          ''')
          .eq('video_id', widget.videoId)
          .order('created_at', ascending: true);

      final rows =
          List<Map<String, dynamic>>.from(result);

      for (final comment in rows) {
        final profile = await supabase
            .from('profiles')
            .select('username,display_name')
            .eq('id', comment['user_id'])
            .maybeSingle();

        comment['profile'] = profile;
      }

      if (mounted) {
        setState(() {
          comments = rows;
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

  Future<void> sendComment() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage(
        context,
        text(
          widget.isArabic,
          'سجل الدخول أولاً',
          'Please sign in first',
        ),
      );
      return;
    }

    final body = controller.text.trim();

    if (body.isEmpty || sending) return;

    setState(() {
      sending = true;
    });

    try {
      await supabase.from('comments').insert({
        'video_id': widget.videoId,
        'user_id': user.id,
        'body': body,
      });

      controller.clear();
      await loadComments();
    } catch (e) {
      if (mounted) {
        showMessage(context, e.toString());
      }
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
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                text(
                  widget.isArabic,
                  'التعليقات',
                  'Comments',
                ),
                style: const TextStyle(
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
                      ? Center(
                          child: Text(
                            text(
                              widget.isArabic,
                              'لا توجد تعليقات',
                              'No comments yet',
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (_, index) {
                            final item = comments[index];
                            final profile =
                                item['profile']
                                    as Map<String, dynamic>?;

                            return ListTile(
                              title: Text(
                                profile?['display_name'] ??
                                    profile?['username'] ??
                                    'User',
                              ),
                              subtitle:
                                  Text(item['body'] ?? ''),
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
                      decoration: InputDecoration(
                        hintText: text(
                          widget.isArabic,
                          'اكتب تعليقًا...',
                          'Write a comment...',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: sendComment,
                    icon: sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
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

/* ============================================================
   DISCOVER TALENT
============================================================ */

class DiscoverPage extends StatefulWidget {
  final bool isArabic;

  const DiscoverPage({
    super.key,
    required this.isArabic,
  });

  @override
  State<DiscoverPage> createState() =>
      _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<Map<String, dynamic>> profiles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    try {
      final result = await supabase
          .from('profiles')
          .select('''
            id,
            username,
            display_name,
            bio,
            avatar_url,
            country,
            city,
            is_talent,
            is_company,
            followers_count,
            videos_count
          ''')
          .eq('is_talent', true)
          .order('followers_count', ascending: false);

      if (mounted) {
        setState(() {
          profiles =
              List<Map<String, dynamic>>.from(result);
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
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: loadProfiles,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            text(
              widget.isArabic,
              'اكتشف المواهب',
              'Discover Talent',
            ),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...profiles.map(
            (profile) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      profile['avatar_url'] != null &&
                              profile['avatar_url']
                                  .toString()
                                  .isNotEmpty
                          ? NetworkImage(
                              profile['avatar_url'],
                            )
                          : null,
                  child:
                      profile['avatar_url'] == null
                          ? const Icon(Icons.person)
                          : null,
                ),
                title: Text(
                  profile['display_name'] ??
                      profile['username'] ??
                      'Talent',
                ),
                subtitle: Text(
                  '${profile['followers_count'] ?? 0} '
                  '${text(widget.isArabic, 'متابع', 'followers')}',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicProfilePage(
                        profile: profile,
                        isArabic: widget.isArabic,
                      ),
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

/* ============================================================
   OPPORTUNITIES
============================================================ */

class OpportunitiesPage extends StatefulWidget {
  final bool isArabic;

  const OpportunitiesPage({
    super.key,
    required this.isArabic,
  });

  @override
  State<OpportunitiesPage> createState() =>
      _OpportunitiesPageState();
}

class _OpportunitiesPageState
    extends State<OpportunitiesPage> {
  List<Map<String, dynamic>> opportunities = [];
  bool loading = true;

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
          .eq('status', 'open')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          opportunities =
              List<Map<String, dynamic>>.from(result);
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

  Future<void> apply(
    Map<String, dynamic> opportunity,
  ) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthPage(
            isArabic: widget.isArabic,
          ),
        ),
      );
      return;
    }

    try {
      await supabase.from('applications').insert({
        'opportunity_id': opportunity['id'],
        'applicant_id': user.id,
        'message': '',
        'status': 'pending',
      });

      if (mounted) {
        showMessage(
          context,
          text(
            widget.isArabic,
            'تم إرسال طلبك',
            'Application submitted',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showMessage(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: loadOpportunities,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            text(
              widget.isArabic,
              'الفرص',
              'Opportunities',
            ),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (opportunities.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Center(
                child: Text(
                  text(
                    widget.isArabic,
                    'لا توجد فرص مفتوحة حاليًا',
                    'No open opportunities',
                  ),
                ),
              ),
            ),
          ...opportunities.map(
            (opportunity) => Card(
              margin:
                  const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      opportunity['description'] ?? '',
                    ),
                    const SizedBox(height: 8),
                    if ((opportunity['location'] ?? '')
                        .toString()
                        .isNotEmpty)
                      Text(
                        '📍 ${opportunity['location']}',
                      ),
                    if ((opportunity['opportunity_type'] ??
                            '')
                        .toString()
                        .isNotEmpty)
                      Text(
                        '• ${opportunity['opportunity_type']}',
                      ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            apply(opportunity),
                        child: Text(
                          text(
                            widget.isArabic,
                            'تقديم',
                            'Apply',
                          ),
                        ),
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
   PROFILE
============================================================ */

class ProfilePage extends StatefulWidget {
  final bool isArabic;

  const ProfilePage({
    super.key,
    required this.isArabic,
  });

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool loading = true;

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
      final result = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          profile = result;
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
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_outline,
                size: 70,
              ),
              const SizedBox(height: 16),
              Text(
                text(
                  widget.isArabic,
                  'سجل الدخول للوصول إلى حسابك',
                  'Sign in to access your profile',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuthPage(
                        isArabic: widget.isArabic,
                      ),
                    ),
                  );

                  if (mounted) {
                    setState(() {});
                    loadProfile();
                  }
                },
                child: Text(
                  text(
                    widget.isArabic,
                    'تسجيل الدخول',
                    'Sign In',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final p = profile ?? {};

    return RefreshIndicator(
      onRefresh: loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage:
                  p['avatar_url'] != null &&
                          p['avatar_url']
                              .toString()
                              .isNotEmpty
                      ? NetworkImage(p['avatar_url'])
                      : null,
              child: p['avatar_url'] == null
                  ? const Icon(
                      Icons.person,
                      size: 48,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              p['display_name'] ??
                  p['username'] ??
                  'Reality Duel User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (p['username'] != null)
            Center(
              child: Text('@${p['username']}'),
            ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              StatBox(
                value: '${p['followers_count'] ?? 0}',
                label: text(
                  widget.isArabic,
                  'المتابعون',
                  'Followers',
                ),
              ),
              StatBox(
                value: '${p['following_count'] ?? 0}',
                label: text(
                  widget.isArabic,
                  'يتابع',
                  'Following',
                ),
              ),
              StatBox(
                value: '${p['videos_count'] ?? 0}',
                label: text(
                  widget.isArabic,
                  'الفيديوهات',
                  'Videos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          if ((p['bio'] ?? '').toString().isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(p['bio']),
              ),
            ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              await supabase.auth.signOut();

              if (mounted) {
                setState(() {
                  profile = null;
                });
              }
            },
            icon: const Icon(Icons.logout),
            label: Text(
              text(
                widget.isArabic,
                'تسجيل الخروج',
                'Sign Out',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String value;
  final String label;

  const StatBox({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

/* ============================================================
   PUBLIC PROFILE
============================================================ */

class PublicProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final bool isArabic;

  const PublicProfilePage({
    super.key,
    required this.profile,
    required this.isArabic,
  });

  @override
  State<PublicProfilePage> createState() =>
      _PublicProfilePageState();
}

class _PublicProfilePageState
    extends State<PublicProfilePage> {
  bool following = false;

  @override
  void initState() {
    super.initState();
    checkFollowing();
  }

  Future<void> checkFollowing() async {
    final user = supabase.auth.currentUser;

    if (user == null ||
        user.id == widget.profile['id']) {
      return;
    }

    try {
      final row = await supabase
          .from('followers')
          .select('id')
          .eq('follower_id', user.id)
          .eq('following_id', widget.profile['id'])
          .maybeSingle();

      if (mounted) {
        setState(() {
          following = row != null;
        });
      }
    } catch (_) {}
  }

  Future<void> toggleFollow() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthPage(
            isArabic: widget.isArabic,
          ),
        ),
      );

      checkFollowing();
      return;
    }

    try {
      if (following) {
        await supabase
            .from('followers')
            .delete()
            .eq('follower_id', user.id)
            .eq('following_id', widget.profile['id']);
      } else {
        await supabase.from('followers').insert({
          'follower_id': user.id,
          'following_id': widget.profile['id'],
        });
      }

      if (mounted) {
        setState(() {
          following = !following;
        });
      }
    } catch (e) {
      if (mounted) {
        showMessage(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          p['display_name'] ??
              p['username'] ??
              'Profile',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 55,
              backgroundImage:
                  p['avatar_url'] != null &&
                          p['avatar_url']
                              .toString()
                              .isNotEmpty
                      ? NetworkImage(p['avatar_url'])
                      : null,
              child: p['avatar_url'] == null
                  ? const Icon(
                      Icons.person,
                      size: 55,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              p['display_name'] ??
                  p['username'] ??
                  'Talent',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: toggleFollow,
            icon: Icon(
              following
                  ? Icons.person_remove
                  : Icons.person_add,
            ),
            label: Text(
              following
                  ? text(
                      widget.isArabic,
                      'إلغاء المتابعة',
                      'Unfollow',
                    )
                  : text(
                      widget.isArabic,
                      'متابعة',
                      'Follow',
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              StatBox(
                value: '${p['followers_count'] ?? 0}',
                label: text(
                  widget.isArabic,
                  'المتابعون',
                  'Followers',
                ),
              ),
              StatBox(
                value: '${p['videos_count'] ?? 0}',
                label: text(
                  widget.isArabic,
                  'الفيديوهات',
                  'Videos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          if ((p['bio'] ?? '').toString().isNotEmpty)
            Text(p['bio']),
        ],
      ),
    );
  }
}

/* ============================================================
   AUTH
============================================================ */

class AuthPage extends StatefulWidget {
  final bool isArabic;

  const AuthPage({
    super.key,
    required this.isArabic,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool signup = false;
  bool loading = false;

  final email = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();
  final displayName = TextEditingController();

  String role = 'talent';

  Future<void> submit() async {
    final e = email.text.trim();
    final p = password.text.trim();

    if (e.isEmpty || p.isEmpty) {
      showMessage(
        context,
        text(
          widget.isArabic,
          'أدخل البريد وكلمة المرور',
          'Enter email and password',
        ),
      );
      return;
    }

    if (signup && username.text.trim().isEmpty) {
      showMessage(
        context,
        text(
          widget.isArabic,
          'أدخل اسم المستخدم',
          'Enter username',
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      if (signup) {
        final response =
            await supabase.auth.signUp(
          email: e,
          password: p,
          data: {
            'role': role,
            'username': username.text.trim(),
            'display_name':
                displayName.text.trim(),
          },
        );

        if (response.user == null) {
          throw Exception(
            text(
              widget.isArabic,
              'تعذر إنشاء الحساب',
              'Could not create account',
            ),
          );
        }

        if (mounted) {
          showMessage(
            context,
            text(
              widget.isArabic,
              'تم إنشاء الحساب بنجاح',
              'Account created successfully',
            ),
          );
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: e,
          password: p,
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      String message = e.message;

      if (message.toLowerCase().contains(
            'already registered',
          )) {
        message = text(
          widget.isArabic,
          'هذا البريد مسجل مسبقًا. استخدم تسجيل الدخول.',
          'This email is already registered. Please sign in.',
        );
      }

      showMessage(context, message);
    } catch (e) {
      if (mounted) {
        showMessage(context, e.toString());
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
    email.dispose();
    password.dispose();
    username.dispose();
    displayName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          signup
              ? text(
                  widget.isArabic,
                  'إنشاء حساب',
                  'Create Account',
                )
              : text(
                  widget.isArabic,
                  'تسجيل الدخول',
                  'Sign In',
                ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Icon(
              Icons.public,
              size: 70,
            ),
            const SizedBox(height: 15),
            const Text(
              'REALITY DUEL',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 35),
            if (signup) ...[
              TextField(
                controller: username,
                decoration: InputDecoration(
                  labelText: text(
                    widget.isArabic,
                    'اسم المستخدم',
                    'Username',
                  ),
                  prefixIcon:
                      const Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: displayName,
                decoration: InputDecoration(
                  labelText: text(
                    widget.isArabic,
                    'الاسم الظاهر',
                    'Display name',
                  ),
                  prefixIcon:
                      const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(
                  labelText: text(
                    widget.isArabic,
                    'نوع الحساب',
                    'Account type',
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'talent',
                    child: Text(
                      text(
                        widget.isArabic,
                        'موهبة',
                        'Talent',
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'company',
                    child: Text(
                      text(
                        widget.isArabic,
                        'شركة',
                        'Company',
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      role = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: email,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: text(
                  widget.isArabic,
                  'البريد الإلكتروني',
                  'Email',
                ),
                prefixIcon:
                    const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: text(
                  widget.isArabic,
                  'كلمة المرور',
                  'Password',
                ),
                prefixIcon:
                    const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                        signup
                            ? text(
                                widget.isArabic,
                                'إنشاء الحساب',
                                'Create Account',
                              )
                            : text(
                                widget.isArabic,
                                'تسجيل الدخول',
                                'Sign In',
                              ),
                      ),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: loading
                  ? null
                  : () {
                      setState(() {
                        signup = !signup;
                      });
                    },
              child: Text(
                signup
                    ? text(
                        widget.isArabic,
                        'لديك حساب؟ تسجيل الدخول',
                        'Already have an account? Sign in',
                      )
                    : text(
                        widget.isArabic,
                        'ليس لديك حساب؟ إنشاء حساب',
                        'No account? Create one',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   UPLOAD VIDEO
============================================================ */

class UploadVideoPage extends StatefulWidget {
  final bool isArabic;

  const UploadVideoPage({
    super.key,
    required this.isArabic,
  });

  @override
  State<UploadVideoPage> createState() =>
      _UploadVideoPageState();
}

class _UploadVideoPageState
    extends State<UploadVideoPage> {
  Uint8List? bytes;
  String? fileName;

  final title = TextEditingController();
  final description = TextEditingController();

  bool uploading = false;
  bool isPublic = true;

  Future<void> pickVideo() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null ||
        result.files.single.bytes == null) {
      return;
    }

    setState(() {
      bytes = result.files.single.bytes;
      fileName = result.files.single.name;
    });
  }

  Future<void> upload() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage(
        context,
        text(
          widget.isArabic,
          'يجب تسجيل الدخول أولاً',
          'Please sign in first',
        ),
      );
      return;
    }

    if (bytes == null || fileName == null) {
      showMessage(
        context,
        text(
          widget.isArabic,
          'اختر فيديو أولاً',
          'Choose a video first',
        ),
      );
      return;
    }

    if (uploading) return;

    setState(() {
      uploading = true;
    });

    try {
      final extension =
          fileName!.split('.').last.toLowerCase();

      final filePath =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await supabase.storage
          .from('videos')
          .uploadBinary(
            filePath,
            bytes!,
            fileOptions: FileOptions(
              contentType:
                  extension == 'mov'
                      ? 'video/quicktime'
                      : 'video/mp4',
              upsert: false,
            ),
          );

      final publicUrl = supabase.storage
          .from('videos')
          .getPublicUrl(filePath);

      await supabase.from('videos').insert({
        'user_id': user.id,
        'title': title.text.trim(),
        'description':
            description.text.trim(),
        'storage_path': filePath,
        'video_url': publicUrl,
        'is_public': isPublic,
      });

      if (!mounted) return;

      showMessage(
        context,
        text(
          widget.isArabic,
          'تم رفع الفيديو بنجاح',
          'Video uploaded successfully',
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showMessage(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          uploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          text(
            widget.isArabic,
            'رفع فيديو',
            'Upload Video',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickVideo,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(18),
                  color: const Color(0xFF151722),
                ),
                child: bytes == null
                    ? Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.video_library,
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            text(
                              widget.isArabic,
                              'اضغط لاختيار فيديو',
                              'Tap to choose a video',
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            fileName ?? '',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: title,
              decoration: InputDecoration(
                labelText: text(
                  widget.isArabic,
                  'عنوان الفيديو',
                  'Video title',
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: description,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: text(
                  widget.isArabic,
                  'الوصف',
                  'Description',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: isPublic,
              onChanged: (value) {
                setState(() {
                  isPublic = value;
                });
              },
              title: Text(
                text(
                  widget.isArabic,
                  'فيديو عام',
                  'Public video',
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed:
                    uploading ? null : upload,
                child: uploading
                    ? const CircularProgressIndicator()
                    : Text(
                        text(
                          widget.isArabic,
                          'رفع الفيديو',
                          'Upload Video',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
