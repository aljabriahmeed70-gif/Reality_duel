from pathlib import Path
code = r'''import 'package:flutter/material.dart'; import 'package:file_picker/file_picker.dart'; import 'package:supabase_flutter/supabase_flutter.dart'; import 'package:video_player/video_player.dart';
const String supabaseUrl = 'YOUR_SUPABASE_URL'; const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
final supabase = Supabase.instance.client;
Future main() async { WidgetsFlutterBinding.ensureInitialized();
await Supabase.initialize( url: supabaseUrl, anonKey: supabaseAnonKey, );
runApp(const RealityDuelApp()); }
class RealityDuelApp extends StatefulWidget { const RealityDuelApp({super.key});
@override State createState() => _RealityDuelAppState(); }
class _RealityDuelAppState extends State { String language = 'en';
bool get isArabic => language == 'ar';
void changeLanguage(String value) { setState(() => language = value); }
@override Widget build(BuildContext context) { return MaterialApp( debugShowCheckedModeBanner: false, title: 'Reality Duel', theme: ThemeData( brightness: Brightness.dark, scaffoldBackgroundColor: Colors.black, colorScheme: ColorScheme.fromSeed( seedColor: Colors.deepPurple, brightness: Brightness.dark, ), useMaterial3: true, ), home: AppShell( language: language, onLanguageChanged: changeLanguage, ), ); } }
String tr(String language, String en, String ar, String es, String fr, String trk, String zh) { switch (language) { case 'ar': return ar; case 'es': return es; case 'fr': return fr; case 'tr': return trk; case 'zh': return zh; default: return en; } }
String errorText(Object e) { if (e is PostgrestException) { return e.message; } return e.toString(); }
bool isLoggedIn() => supabase.auth.currentUser != null;
class AppShell extends StatefulWidget { final String language; final ValueChanged onLanguageChanged;
const AppShell({ super.key, required this.language, required this.onLanguageChanged, });
@override State createState() => _AppShellState(); }
class _AppShellState extends State { int index = 0;
void selectPage(int value) { setState(() => index = value); }
void showLanguagePicker() { showModalBottomSheet( context: context, backgroundColor: const Color(0xff171717), builder: (context) { final languages = <String, String>{ 'en': 'English', 'ar': 'العربية', 'es': 'Español', 'fr': 'Français', 'tr': 'Türkçe', 'zh': '中文', };
return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: languages.entries.map((entry) {
          return ListTile(
            leading: const Icon(Icons.language),
            title: Text(entry.value),
            trailing: widget.language == entry.key
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              widget.onLanguageChanged(entry.key);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  },
);
}
@override Widget build(BuildContext context) { final isArabic = widget.language == 'ar';
final pages = [
  FeedPage(language: widget.language),
  DuelsPage(language: widget.language),
  DiscoverTalentPage(language: widget.language),
  OpportunitiesPage(language: widget.language),
  TalentProfilePage(language: widget.language),
];

final labels = [
  tr(widget.language, 'Feed', 'الرئيسية', 'Inicio', 'Accueil', 'Akış', '首页'),
  tr(widget.language, 'Duels', 'التحديات', 'Duelos', 'Défis', 'Düellolar', '挑战'),
  tr(widget.language, 'Talent', 'المواهب', 'Talento', 'Talents', 'Yetenek', '人才'),
  tr(widget.language, 'Opportunities', 'الفرص', 'Oportunidades', 'Opportunités', 'Fırsatlar', '机会'),
  tr(widget.language, 'Profile', 'حسابي', 'Perfil', 'Profil', 'Profil', '个人资料'),
];

return Directionality(
  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
  child: Scaffold(
    body: IndexedStack(
      index: index,
      children: pages,
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'language',
      onPressed: showLanguagePicker,
      child: const Icon(Icons.language),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: selectPage,
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
          icon: const Icon(Icons.search),
          selectedIcon: const Icon(Icons.manage_search),
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
  ),
);
} }
class FeedVideo { final String id; final String userId; final String videoUrl; final String caption; final int likes; final int comments; final int views; final String? username;
const FeedVideo({ required this.id, required this.userId, required this.videoUrl, required this.caption, required this.likes, required this.comments, required this.views, this.username, });
factory FeedVideo.fromMap(Map<String, dynamic> map) { return FeedVideo( id: (map['id'] ?? '').toString(), userId: (map['user_id'] ?? '').toString(), videoUrl: (map['video_url'] ?? '').toString(), caption: (map['caption'] ?? '').toString(), likes: (map['likes_count'] as num?)?.toInt() ?? 0, comments: (map['comments_count'] as num?)?.toInt() ?? 0, views: (map['views_count'] as num?)?.toInt() ?? 0, username: map['username']?.toString(), ); } }
class FeedPage extends StatefulWidget { final String language;
const FeedPage({super.key, required this.language});
@override State createState() => _FeedPageState(); }
class _FeedPageState extends State { final List videos = []; bool loading = true; String? error; int currentIndex = 0;
@override void initState() { super.initState(); loadVideos(); }
Future loadVideos() async { setState(() { loading = true; error = null; });
try {
  final rows = await supabase
      .from('videos')
      .select(
        'id,user_id,storage_path,video_url,caption,status,likes_count,comments_count,views_count,created_at',
      )
      .eq('status', 'published')
      .order('created_at', ascending: false);

  final loaded = <FeedVideo>[];

  for (final row in rows) {
    final map = Map<String, dynamic>.from(row);
    String url = (map['video_url'] ?? '').toString();

    if (url.isEmpty && (map['storage_path'] ?? '').toString().isNotEmpty) {
      url = supabase.storage
          .from('videos')
          .getPublicUrl(map['storage_path'].toString());
    }

    if (url.isNotEmpty) {
      map['video_url'] = url;
      loaded.add(FeedVideo.fromMap(map));
    }
  }

  if (loaded.isNotEmpty) {
    setState(() {
      videos
        ..clear()
        ..addAll(loaded);
      loading = false;
    });
    return;
  }

  await loadStorageVideos();
} catch (_) {
  await loadStorageVideos();
}
}
Future loadStorageVideos() async { try { final files = await supabase.storage.from('videos').list(); final loaded = [];
for (final file in files) {
    final name = file.name;
    final lower = name.toLowerCase();

    final isVideo = lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi');

    if (!isVideo) continue;

    final url = supabase.storage.from('videos').getPublicUrl(name);

    loaded.add(
      FeedVideo(
        id: '',
        userId: '',
        videoUrl: url,
        caption: '',
        likes: 0,
        comments: 0,
        views: 0,
      ),
    );
  }

  setState(() {
    videos
      ..clear()
      ..addAll(loaded);
    loading = false;
    error = loaded.isEmpty
        ? tr(
            widget.language,
            'No videos available yet.',
            'لا توجد فيديوهات متاحة حالياً.',
            'No hay videos disponibles.',
            'Aucune vidéo disponible.',
            'Henüz video yok.',
            '暂无视频。',
          )
        : null;
  });
} catch (e) {
  setState(() {
    loading = false;
    error = errorText(e);
  });
}
}
Future openUpload() async { if (!isLoggedIn()) { await showLoginRequired(context, widget.language); return; }
await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => UploadVideoPage(language: widget.language),
  ),
);

if (mounted) {
  await loadVideos();
}
}
@override Widget build(BuildContext context) { return Scaffold( backgroundColor: Colors.black, appBar: AppBar( backgroundColor: Colors.black, title: const Text( 'Reality Duel', style: TextStyle(fontWeight: FontWeight.bold), ), actions: [ IconButton( tooltip: tr( widget.language, 'Upload video', 'رفع فيديو', 'Subir video', 'Téléverser une vidéo', 'Video yükle', '上传视频', ), onPressed: openUpload, icon: const Icon(Icons.video_call), ), IconButton( tooltip: tr( widget.language, 'Live', 'بث مباشر', 'En directo', 'Direct', 'Canlı', '直播', ), onPressed: () => showLiveInfo(context, widget.language), icon: const Icon(Icons.live_tv), ), ], ), body: loading ? const Center(child: CircularProgressIndicator()) : error != null && videos.isEmpty ? RefreshIndicator( onRefresh: loadVideos, child: ListView( children: [ SizedBox( height: MediaQuery.of(context).size.height * .7, child: Center( child: Padding( padding: const EdgeInsets.all(24), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.video_library_outlined, size: 70), const SizedBox(height: 16), Text( error!, textAlign: TextAlign.center, ), const SizedBox(height: 20), FilledButton.icon( onPressed: loadVideos, icon: const Icon(Icons.refresh), label: Text( tr( widget.language, 'Refresh', 'تحديث', 'Actualizar', 'Actualiser', 'Yenile', '刷新', ), ), ), ], ), ), ), ), ], ), ) : PageView.builder( scrollDirection: Axis.vertical, itemCount: videos.length, onPageChanged: (value) { setState(() => currentIndex = value); }, itemBuilder: (context, index) { return VideoFeedItem( video: videos[index], language: widget.language, active: currentIndex == index, ); }, ), ); } }
class VideoFeedItem extends StatefulWidget { final FeedVideo video; final String language; final bool active;
const VideoFeedItem({ super.key, required this.video, required this.language, required this.active, });
@override State createState() => _VideoFeedItemState(); }
class _VideoFeedItemState extends State { VideoPlayerController? controller; bool initialized = false; bool failed = false; bool liked = false; bool following = false; bool busy = false;
@override void initState() { super.initState(); initializeVideo(); loadInteractionState(); }
@override void didUpdateWidget(covariant VideoFeedItem oldWidget) { super.didUpdateWidget(oldWidget);
if (oldWidget.video.videoUrl != widget.video.videoUrl) {
  disposeController();
  initializeVideo();
  loadInteractionState();
}

if (oldWidget.active != widget.active && initialized) {
  if (widget.active) {
    controller?.play();
  } else {
    controller?.pause();
  }
}
}
Future initializeVideo() async { if (widget.video.videoUrl.isEmpty) return;
try {
  final c = VideoPlayerController.networkUrl(
    Uri.parse(widget.video.videoUrl),
  );

  controller = c;
  await c.initialize();
  await c.setLooping(true);

  if (mounted) {
    setState(() => initialized = true);
    if (widget.active) {
      await c.play();
      recordView();
    }
  }
} catch (_) {
  if (mounted) setState(() => failed = true);
}
}
Future loadInteractionState() async { if (!isLoggedIn() || widget.video.id.isEmpty) return;
try {
  final likeResult = await supabase.rpc(
    'has_video_like',
    params: {'p_video_id': widget.video.id},
  );

  final followResult = widget.video.userId.isEmpty
      ? false
      : await supabase.rpc(
          'is_following',
          params: {'p_target_user_id': widget.video.userId},
        );

  if (mounted) {
    setState(() {
      liked = likeResult == true;
      following = followResult == true;
    });
  }
} catch (_) {}
}
Future recordView() async { if (widget.video.id.isEmpty) return;
try {
  await supabase.rpc(
    'record_video_view',
    params: {'p_video_id': widget.video.id},
  );
} catch (_) {}
}
Future toggleLike() async { if (!isLoggedIn()) { await showLoginRequired(context, widget.language); return; }
if (widget.video.id.isEmpty || busy) return;

setState(() => busy = true);

try {
  final result = await supabase.rpc(
    'toggle_video_like',
    params: {'p_video_id': widget.video.id},
  );

  if (mounted) {
    setState(() {
      liked = result == true;
      busy = false;
    });
  }
} catch (e) {
  if (mounted) {
    setState(() => busy = false);
    showSnack(context, errorText(e));
  }
}
}
Future toggleFollow() async { if (!isLoggedIn()) { await showLoginRequired(context, widget.language); return; }
if (widget.video.userId.isEmpty || busy) return;

setState(() => busy = true);

try {
  final result = await supabase.rpc(
    'toggle_follow',
    params: {'p_target_user_id': widget.video.userId},
  );

  if (mounted) {
    setState(() {
      following = result == true;
      busy = false;
    });
  }
} catch (e) {
  if (mounted) {
    setState(() => busy = false);
    showSnack(context, errorText(e));
  }
}
}
Future comments() async { if (!isLoggedIn()) { await showLoginRequired(context, widget.language); return; }
if (widget.video.id.isEmpty) {
  showSnack(
    context,
    tr(
      widget.language,
      'This storage video has no database record yet.',
      'هذا الفيديو موجود في التخزين ولكنه لا يملك سجلاً في قاعدة البيانات بعد.',
      'Este video no tiene registro en la base de datos.',
      'Cette vidéo n’a pas encore d’enregistrement en base.',
      'Bu videonun henüz veritabanı kaydı yok.',
      '该视频尚无数据库记录。',
    ),
  );
  return;
}

final controller = TextEditingController();

await showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: const Color(0xff151515),
  builder: (context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tr(
              widget.language,
              'Add a comment',
              'أضف تعليقاً',
              'Añadir comentario',
              'Ajouter un commentaire',
              'Yorum ekle',
              '添加评论',
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: tr(
                widget.language,
                'Write your comment...',
                'اكتب تعليقك...',
                'Escribe tu comentario...',
                'Écrivez votre commentaire...',
                'Yorumunuzu yazın...',
                '写下你的评论……',
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              try {
                await supabase.rpc(
                  'add_video_comment',
                  params: {
                    'p_video_id': widget.video.id,
                    'p_text': text,
                  },
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  showSnack(
                    context,
                    tr(
                      widget.language,
                      'Comment added.',
                      'تمت إضافة التعليق.',
                      'Comentario añadido.',
                      'Commentaire ajouté.',
                      'Yorum eklendi.',
                      '评论已添加。',
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showSnack(context, errorText(e));
                }
              }
            },
            icon: const Icon(Icons.send),
            label: Text(
              tr(
                widget.language,
                'Send',
                'إرسال',
                'Enviar',
                'Envoyer',
                'Gönder',
                '发送',
              ),
            ),
          ),
        ],
      ),
    );
  },
);
}
void shareVideo() { showSnack( context, tr( widget.language, 'Video sharing link: ${widget.video.videoUrl}', 'رابط مشاركة الفيديو: ${widget.video.videoUrl}', 'Enlace del video: ${widget.video.videoUrl}', 'Lien de la vidéo : ${widget.video.videoUrl}', 'Video bağlantısı: ${widget.video.videoUrl}', '视频链接：${widget.video.videoUrl}', ), ); }
@override void dispose() { disposeController(); super.dispose(); }
void disposeController() { final c = controller; controller = null; if (c != null) { c.dispose(); } initialized = false; }
@override Widget build(BuildContext context) { return Stack( fit: StackFit.expand, children: [ Container(color: Colors.black), if (initialized && controller != null) FittedBox( fit: BoxFit.cover, child: SizedBox( width: controller!.value.size.width, height: controller!.value.size.height, child: VideoPlayer(controller!), ), ) else if (failed) const Center( child: Icon( Icons.error_outline, size: 80, ), ) else const Center(child: CircularProgressIndicator()), if (initialized) Center( child: GestureDetector( onTap: () { final c = controller; if (c == null) return;
if (c.value.isPlaying) {
              c.pause();
            } else {
              c.play();
            }

            setState(() {});
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller?.value.isPlaying == true
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 42,
            ),
          ),
        ),
      ),
    Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: Row(
        children: [
          const CircleAvatar(
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.video.username?.isNotEmpty == true
                  ? '@${widget.video.username}'
                  : '@realityduel',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          FilledButton(
            onPressed: toggleFollow,
            child: Text(
              following
                  ? tr(
                      widget.language,
                      'Following',
                      'متابَع',
                      'Siguiendo',
                      'Abonné',
                      'Takiptesin',
                      '已关注',
                    )
                  : tr(
                      widget.language,
                      'Follow',
                      'متابعة',
                      'Seguir',
                      'Suivre',
                      'Takip Et',
                      '关注',
                    ),
            ),
          ),
        ],
      ),
    ),
    Positioned(
      right: 10,
      bottom: 95,
      child: Column(
        children: [
          FeedActionButton(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            label: '${widget.video.likes}',
            onTap: toggleLike,
          ),
          FeedActionButton(
            icon: Icons.comment,
            label: '${widget.video.comments}',
            onTap: comments,
          ),
          FeedActionButton(
            icon: Icons.share,
            label: tr(
              widget.language,
              'Share',
              'مشاركة',
              'Compartir',
              'Partager',
              'Paylaş',
              '分享',
            ),
            onTap: shareVideo,
          ),
          FeedActionButton(
            icon: Icons.visibility,
            label: '${widget.video.views}',
            onTap: () {},
          ),
        ],
      ),
    ),
    Positioned(
      left: 16,
      right: 80,
      bottom: 25,
      child: Text(
        widget.video.caption,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: Colors.black,
            ),
          ],
        ),
      ),
    ),
  ],
);
} }
class FeedActionButton extends StatelessWidget { final IconData icon; final String label; final VoidCallback onTap;
const FeedActionButton({ super.key, required this.icon, required this.label, required this.onTap, });
@override Widget build(BuildContext context) { return Padding( padding: const EdgeInsets.only(bottom: 14), child: InkWell( onTap: onTap, borderRadius: BorderRadius.circular(30), child: Column( children: [ CircleAvatar( radius: 25, backgroundColor: Colors.black.withOpacity(.45), child: Icon(icon, size: 26), ), const SizedBox(height: 4), Text( label, style: const TextStyle(fontWeight: FontWeight.bold), ), ], ), ), ); } }
class UploadVideoPage extends StatefulWidget { final String language;
const UploadVideoPage({super.key, required this.language});
@override State createState() => _UploadVideoPageState(); }
class _UploadVideoPageState extends State { final captionController = TextEditingController(); bool uploading = false; String? selectedName;
@override void dispose() { captionController.dispose(); super.dispose(); }
Future pickAndUpload() async { if (!isLoggedIn()) { await showLoginRequired(context, widget.language); return; }
final result = await FilePicker.platform.pickFiles(
  type: FileType.video,
  withData: true,
);

if (result == null || result.files.isEmpty) return;

final file = result.files.single;

if (file.bytes == null) {
  showSnack(
    context,
    tr(
      widget.language,
      'Could not read the selected video.',
      'تعذر قراءة الفيديو المحدد.',
      'No se pudo leer el video.',
      'Impossible de lire la vidéo.',
      'Video okunamadı.',
      '无法读取所选视频。',
    ),
  );
  return;
}

setState(() {
  uploading = true;
  selectedName = file.name;
});

try {
  final extension =
      file.extension?.toLowerCase().replaceAll('.', '') ?? 'mp4';

  final storagePath =
      '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

  String contentType = 'video/mp4';
  if (extension == 'mov') contentType = 'video/quicktime';
  if (extension == 'webm') contentType = 'video/webm';

  await supabase.storage.from('videos').uploadBinary(
        storagePath,
        file.bytes!,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: false,
        ),
      );

  final publicUrl =
      supabase.storage.from('videos').getPublicUrl(storagePath);

  await supabase.rpc(
    'create_video_record',
    params: {
      'p_storage_path': storagePath,
      'p_video_url': publicUrl,
      'p_caption': captionController.text.trim(),
    },
  );

  if (mounted) {
    showSnack(
      context,
      tr(
        widget.language,
        'Video uploaded successfully.',
        'تم رفع الفيديو بنجاح.',
        'Video subido correctamente.',
        'Vidéo téléversée avec succès.',
        'Video
