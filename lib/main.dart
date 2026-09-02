import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://sdbfruxgoefdwyzhkjay.supabase.co',
);

const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_t3mt53Npr-LxfprutshcVQ_cQulCux2',
);

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const RealityDuelApp());
}

/* ============================================================
   TRANSLATIONS
   ============================================================ */

class T {
  static const Map<String, Map<String, String>> data = {
    'English': {
      'feed': 'Feed',
      'duels': 'Duels',
      'talent': 'Talent',
      'opportunities': 'Opportunities',
      'profile': 'Profile',
      'login': 'Login',
      'logout': 'Logout',
      'create_account': 'Create Account',
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'display_name': 'Display Name',
      'bio': 'Bio',
      'country': 'Country',
      'skills': 'Skills',
      'save': 'Save',
      'cancel': 'Cancel',
      'search': 'Search',
      'like': 'Like',
      'comment': 'Comment',
      'share': 'Share',
      'follow': 'Follow',
      'following': 'Following',
      'upload_video': 'Upload Video',
      'choose_video': 'Choose Video',
      'caption': 'Caption',
      'publish': 'Publish',
      'create_duel': 'Create Duel',
      'join': 'Join',
      'submit_proof': 'Submit Proof',
      'add_photo': 'Add Photo',
      'opportunity': 'Opportunity',
      'apply': 'Apply',
      'applied': 'Applied',
      'create_opportunity': 'Create Opportunity',
      'no_videos': 'No videos available yet',
      'no_talent': 'No talent found',
      'no_duels': 'No duels available',
      'no_opportunities': 'No opportunities available',
      'login_required': 'Login required',
      'login_required_text': 'Please login to use this feature.',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'success': 'Success',
      'comments': 'Comments',
      'write_comment': 'Write a comment...',
      'title': 'Title',
      'description': 'Description',
      'type': 'Type',
      'status': 'Status',
      'location': 'Location',
      'deadline': 'Deadline',
      'create': 'Create',
      'edit_profile': 'Edit Profile',
      'followers': 'Followers',
      'following_count': 'Following',
      'wins': 'Wins',
      'proofs': 'Proofs',
      'talent_score': 'Talent Score',
      'guest_user': 'Guest User',
      'language': 'Language',
      'account_created': 'Account created successfully',
      'login_success': 'Login successful',
      'logout_success': 'Logged out',
      'video_uploaded': 'Video uploaded successfully',
      'duel_created': 'Duel created successfully',
      'opportunity_created': 'Opportunity created successfully',
      'application_sent': 'Application sent successfully',
      'proof_submitted': 'Proof submitted successfully',
      'edit': 'Edit',
      'company': 'Company',
      'institution': 'Institution',
      'talent_account': 'Talent',
    },
    'العربية': {
      'feed': 'الرئيسية',
      'duels': 'المواجهات',
      'talent': 'المواهب',
      'opportunities': 'الفرص',
      'profile': 'حسابي',
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'create_account': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'username': 'اسم المستخدم',
      'display_name': 'الاسم الظاهر',
      'bio': 'نبذة',
      'country': 'الدولة',
      'skills': 'المهارات',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'search': 'بحث',
      'like': 'إعجاب',
      'comment': 'تعليق',
      'share': 'مشاركة',
      'follow': 'متابعة',
      'following': 'تتابعه',
      'upload_video': 'رفع فيديو',
      'choose_video': 'اختيار فيديو',
      'caption': 'الوصف',
      'publish': 'نشر',
      'create_duel': 'إنشاء مواجهة',
      'join': 'انضمام',
      'submit_proof': 'إرسال الإثبات',
      'add_photo': 'إضافة صورة',
      'opportunity': 'فرصة',
      'apply': 'تقديم',
      'applied': 'تم التقديم',
      'create_opportunity': 'إنشاء فرصة',
      'no_videos': 'لا توجد فيديوهات بعد',
      'no_talent': 'لم يتم العثور على مواهب',
      'no_duels': 'لا توجد مواجهات',
      'no_opportunities': 'لا توجد فرص',
      'login_required': 'تسجيل الدخول مطلوب',
      'login_required_text': 'يرجى تسجيل الدخول لاستخدام هذه الميزة.',
      'loading': 'جارٍ التحميل...',
      'error': 'حدث خطأ',
      'success': 'تم بنجاح',
      'comments': 'التعليقات',
      'write_comment': 'اكتب تعليقاً...',
      'title': 'العنوان',
      'description': 'الوصف',
      'type': 'النوع',
      'status': 'الحالة',
      'location': 'الموقع',
      'deadline': 'الموعد النهائي',
      'create': 'إنشاء',
      'edit_profile': 'تعديل الملف',
      'followers': 'المتابعون',
      'following_count': 'يتابع',
      'wins': 'الانتصارات',
      'proofs': 'الإثباتات',
      'talent_score': 'نقاط الموهبة',
      'guest_user': 'زائر',
      'language': 'اللغة',
      'account_created': 'تم إنشاء الحساب بنجاح',
      'login_success': 'تم تسجيل الدخول بنجاح',
      'logout_success': 'تم تسجيل الخروج',
      'video_uploaded': 'تم رفع الفيديو بنجاح',
      'duel_created': 'تم إنشاء المواجهة بنجاح',
      'opportunity_created': 'تم إنشاء الفرصة بنجاح',
      'application_sent': 'تم إرسال الطلب بنجاح',
      'proof_submitted': 'تم إرسال الإثبات بنجاح',
      'edit': 'تعديل',
      'company': 'شركة',
      'institution': 'مؤسسة',
      'talent_account': 'موهبة',
    },
    'Español': {
      'feed': 'Inicio',
      'duels': 'Duelos',
      'talent': 'Talento',
      'opportunities': 'Oportunidades',
      'profile': 'Perfil',
      'login': 'Iniciar sesión',
      'logout': 'Cerrar sesión',
      'create_account': 'Crear cuenta',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'username': 'Usuario',
      'display_name': 'Nombre',
      'bio': 'Biografía',
      'country': 'País',
      'skills': 'Habilidades',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'search': 'Buscar',
      'like': 'Me gusta',
      'comment': 'Comentar',
      'share': 'Compartir',
      'follow': 'Seguir',
      'following': 'Siguiendo',
      'upload_video': 'Subir video',
      'choose_video': 'Elegir video',
      'caption': 'Descripción',
      'publish': 'Publicar',
      'create_duel': 'Crear duelo',
      'join': 'Unirse',
      'submit_proof': 'Enviar prueba',
      'add_photo': 'Añadir foto',
      'opportunity': 'Oportunidad',
      'apply': 'Aplicar',
      'applied': 'Aplicado',
      'create_opportunity': 'Crear oportunidad',
      'no_videos': 'No hay videos disponibles',
      'no_talent': 'No se encontró talento',
      'no_duels': 'No hay duelos disponibles',
      'no_opportunities': 'No hay oportunidades',
      'login_required': 'Inicio de sesión requerido',
      'login_required_text': 'Inicia sesión para usar esta función.',
      'loading': 'Cargando...',
      'error': 'Algo salió mal',
      'success': 'Éxito',
      'comments': 'Comentarios',
      'write_comment': 'Escribe un comentario...',
      'title': 'Título',
      'description': 'Descripción',
      'type': 'Tipo',
      'status': 'Estado',
      'location': 'Ubicación',
      'deadline': 'Fecha límite',
      'create': 'Crear',
      'edit_profile': 'Editar perfil',
      'followers': 'Seguidores',
      'following_count': 'Siguiendo',
      'wins': 'Victorias',
      'proofs': 'Pruebas',
      'talent_score': 'Puntuación',
      'guest_user': 'Usuario invitado',
      'language': 'Idioma',
      'account_created': 'Cuenta creada',
      'login_success': 'Inicio de sesión correcto',
      'logout_success': 'Sesión cerrada',
      'video_uploaded': 'Video subido correctamente',
      'duel_created': 'Duelo creado',
      'opportunity_created': 'Oportunidad creada',
      'application_sent': 'Solicitud enviada',
      'proof_submitted': 'Prueba enviada',
      'edit': 'Editar',
      'company': 'Empresa',
      'institution': 'Institución',
      'talent_account': 'Talento',
    },
    'Français': {
      'feed': 'Accueil',
      'duels': 'Duels',
      'talent': 'Talents',
      'opportunities': 'Opportunités',
      'profile': 'Profil',
      'login': 'Connexion',
      'logout': 'Déconnexion',
      'create_account': 'Créer un compte',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'username': 'Nom utilisateur',
      'display_name': 'Nom affiché',
      'bio': 'Biographie',
      'country': 'Pays',
      'skills': 'Compétences',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'search': 'Rechercher',
      'like': 'J’aime',
      'comment': 'Commenter',
      'share': 'Partager',
      'follow': 'Suivre',
      'following': 'Abonné',
      'upload_video': 'Télécharger une vidéo',
      'choose_video': 'Choisir une vidéo',
      'caption': 'Description',
      'publish': 'Publier',
      'create_duel': 'Créer un duel',
      'join': 'Participer',
      'submit_proof': 'Envoyer la preuve',
      'add_photo': 'Ajouter une photo',
      'opportunity': 'Opportunité',
      'apply': 'Postuler',
      'applied': 'Postulé',
      'create_opportunity': 'Créer une opportunité',
      'no_videos': 'Aucune vidéo disponible',
      'no_talent': 'Aucun talent trouvé',
      'no_duels': 'Aucun duel disponible',
      'no_opportunities': 'Aucune opportunité disponible',
      'login_required': 'Connexion requise',
      'login_required_text': 'Connectez-vous pour utiliser cette fonction.',
      'loading': 'Chargement...',
      'error': 'Une erreur est survenue',
      'success': 'Succès',
      'comments': 'Commentaires',
      'write_comment': 'Écrire un commentaire...',
      'title': 'Titre',
      'description': 'Description',
      'type': 'Type',
      'status': 'Statut',
      'location': 'Lieu',
      'deadline': 'Date limite',
      'create': 'Créer',
      'edit_profile': 'Modifier le profil',
      'followers': 'Abonnés',
      'following_count': 'Abonnements',
      'wins': 'Victoires',
      'proofs': 'Preuves',
      'talent_score': 'Score talent',
      'guest_user': 'Utilisateur invité',
      'language': 'Langue',
      'account_created': 'Compte créé',
      'login_success': 'Connexion réussie',
      'logout_success': 'Déconnexion réussie',
      'video_uploaded': 'Vidéo téléchargée',
      'duel_created': 'Duel créé',
      'opportunity_created': 'Opportunité créée',
      'application_sent': 'Candidature envoyée',
      'proof_submitted': 'Preuve envoyée',
      'edit': 'Modifier',
      'company': 'Entreprise',
      'institution': 'Institution',
      'talent_account': 'Talent',
    },
    'Türkçe': {
      'feed': 'Akış',
      'duels': 'Düellolar',
      'talent': 'Yetenek',
      'opportunities': 'Fırsatlar',
      'profile': 'Profil',
      'login': 'Giriş',
      'logout': 'Çıkış',
      'create_account': 'Hesap oluştur',
      'email': 'E-posta',
      'password': 'Şifre',
      'username': 'Kullanıcı adı',
      'display_name': 'Görünen ad',
      'bio': 'Biyografi',
      'country': 'Ülke',
      'skills': 'Yetenekler',
      'save': 'Kaydet',
      'cancel': 'İptal',
      'search': 'Ara',
      'like': 'Beğen',
      'comment': 'Yorum',
      'share': 'Paylaş',
      'follow': 'Takip et',
      'following': 'Takiptesin',
      'upload_video': 'Video yükle',
      'choose_video': 'Video seç',
      'caption': 'Açıklama',
      'publish': 'Yayınla',
      'create_duel': 'Düello oluştur',
      'join': 'Katıl',
      'submit_proof': 'Kanıt gönder',
      'add_photo': 'Fotoğraf ekle',
      'opportunity': 'Fırsat',
      'apply': 'Başvur',
      'applied': 'Başvuruldu',
      'create_opportunity': 'Fırsat oluştur',
      'no_videos': 'Henüz video yok',
      'no_talent': 'Yetenek bulunamadı',
      'no_duels': 'Düello bulunamadı',
      'no_opportunities': 'Fırsat bulunamadı',
      'login_required': 'Giriş gerekli',
      'login_required_text': 'Bu özelliği kullanmak için giriş yapın.',
      'loading': 'Yükleniyor...',
      'error': 'Bir hata oluştu',
      'success': 'Başarılı',
      'comments': 'Yorumlar',
      'write_comment': 'Yorum yaz...',
      'title': 'Başlık',
      'description': 'Açıklama',
      'type': 'Tür',
      'status': 'Durum',
      'location': 'Konum',
      'deadline': 'Son tarih',
      'create': 'Oluştur',
      'edit_profile': 'Profili düzenle',
      'followers': 'Takipçiler',
      'following_count': 'Takip',
      'wins': 'Galibiyet',
      'proofs': 'Kanıtlar',
      'talent_score': 'Yetenek puanı',
      'guest_user': 'Misafir kullanıcı',
      'language': 'Dil',
      'account_created': 'Hesap oluşturuldu',
      'login_success': 'Giriş başarılı',
      'logout_success': 'Çıkış yapıldı',
      'video_uploaded': 'Video başarıyla yüklendi',
      'duel_created': 'Düello oluşturuldu',
      'opportunity_created': 'Fırsat oluşturuldu',
      'application_sent': 'Başvuru gönderildi',
      'proof_submitted': 'Kanıt gönderildi',
      'edit': 'Düzenle',
      'company': 'Şirket',
      'institution': 'Kurum',
      'talent_account': 'Yetenek',
    },
    '中文': {
      'feed': '首页',
      'duels': '对决',
      'talent': '人才',
      'opportunities': '机会',
      'profile': '个人资料',
      'login': '登录',
      'logout': '退出',
      'create_account': '创建账户',
      'email': '邮箱',
      'password': '密码',
      'username': '用户名',
      'display_name': '显示名称',
      'bio': '简介',
      'country': '国家',
      'skills': '技能',
      'save': '保存',
      'cancel': '取消',
      'search': '搜索',
      'like': '点赞',
      'comment': '评论',
      'share': '分享',
      'follow': '关注',
      'following': '已关注',
      'upload_video': '上传视频',
      'choose_video': '选择视频',
      'caption': '描述',
      'publish': '发布',
      'create_duel': '创建对决',
      'join': '加入',
      'submit_proof': '提交证明',
      'add_photo': '添加照片',
      'opportunity': '机会',
      'apply': '申请',
      'applied': '已申请',
      'create_opportunity': '创建机会',
      'no_videos': '暂无视频',
      'no_talent': '未找到人才',
      'no_duels': '暂无对决',
      'no_opportunities': '暂无机会',
      'login_required': '需要登录',
      'login_required_text': '请登录后使用此功能。',
      'loading': '加载中...',
      'error': '发生错误',
      'success': '成功',
      'comments': '评论',
      'write_comment': '写评论...',
      'title': '标题',
      'description': '描述',
      'type': '类型',
      'status': '状态',
      'location': '地点',
      'deadline': '截止日期',
      'create': '创建',
      'edit_profile': '编辑资料',
      'followers': '粉丝',
      'following_count': '关注',
      'wins': '胜利',
      'proofs': '证明',
      'talent_score': '人才评分',
      'guest_user': '访客',
      'language': '语言',
      'account_created': '账户创建成功',
      'login_success': '登录成功',
      'logout_success': '已退出',
      'video_uploaded': '视频上传成功',
      'duel_created': '对决创建成功',
      'opportunity_created': '机会创建成功',
      'application_sent': '申请已发送',
      'proof_submitted': '证明已提交',
      'edit': '编辑',
      'company': '公司',
      'institution': '机构',
      'talent_account': '人才',
    },
  };

  static String s(String lang, String key) {
    return data[lang]?[key] ?? data['English']![key] ?? key;
  }

  static Locale locale(String lang) {
    switch (lang) {
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
}

/* ============================================================
   APP
   ============================================================ */

class RealityDuelApp extends StatefulWidget {
  const RealityDuelApp({super.key});

  @override
  State<RealityDuelApp> createState() => _RealityDuelAppState();
}

class _RealityDuelAppState extends State<RealityDuelApp> {
  String language = 'English';
  bool loadingLanguage = true;

  @override
  void initState() {
    super.initState();
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language');

    if (saved != null && T.data.containsKey(saved)) {
      language = saved;
    }

    if (mounted) {
      setState(() {
        loadingLanguage = false;
      });
    }
  }

  Future<void> changeLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);

    if (mounted) {
      setState(() {
        language = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingLanguage) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final isArabic = language == 'العربية';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reality Duel',
      locale: T.locale(language),
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('es'),
        Locale('fr'),
        Locale('tr'),
        Locale('zh'),
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Directionality(
        textDirection:
            isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AppShell(
          language: language,
          onLanguageChanged: changeLanguage,
        ),
      ),
    );
  }
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
    final lang = widget.language;

    final pages = [
      VideoFeedPage(language: lang),
      DuelsPage(language: lang),
      DiscoverPage(language: lang),
      OpportunitiesPage(language: lang),
      TalentProfilePage(language: lang),
    ];

    final labels = [
      T.s(lang, 'feed'),
      T.s(lang, 'duels'),
      T.s(lang, 'talent'),
      T.s(lang, 'opportunities'),
      T.s(lang, 'profile'),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'languageButton',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: T.data.keys.map((language) {
                    return ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(language),
                      trailing: widget.language == language
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onLanguageChanged(language);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.language),
      ),
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
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool signup = false;
  bool loading = false;

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.length < 6) {
      showMessage('Email and password are required.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      AuthResponse response;

      if (signup) {
        response = await supabase.auth.signUp(
          email: email,
          password: password,
        );
      } else {
        response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }

      if (response.user != null) {
        await ensureProfile(response.user!);

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> ensureProfile(User user) async {
    final existing = await supabase
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      final base = user.email?.split('@').first ?? 'talent';

      await supabase.from('profiles').insert({
        'id': user.id,
        'username': '${base}_${user.id.substring(0, 6)}',
        'display_name': base,
        'account_type': 'talent',
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reality Duel'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.flash_on,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              Text(
                signup
                    ? T.s(lang, 'create_account')
                    : T.s(lang, 'login'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: T.s(lang, 'email'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: T.s(lang, 'password'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(
                          signup
                              ? T.s(lang, 'create_account')
                              : T.s(lang, 'login'),
                        ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    signup = !signup;
                  });
                },
                child: Text(
                  signup
                      ? T.s(lang, 'login')
                      : T.s(lang, 'create_account'),
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
   LOGIN HELPER
   ============================================================ */

Future<bool> requireLogin(
  BuildContext context,
  String language,
) async {
  if (supabase.auth.currentUser != null) {
    return true;
  }

  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LoginPage(language: language),
    ),
  );

  return result == true &&
      supabase.auth.currentUser != null;
}

/* ============================================================
   FEED MODEL
   ============================================================ */

class FeedVideo {
  final String id;
  final String url;
  final String caption;
  final String creatorName;
  final String? creatorId;
  int views;
  int likes;
  int comments;
  bool liked;

  FeedVideo({
    required this.id,
    required this.url,
    required this.caption,
    required this.creatorName,
    required this.creatorId,
    required this.views,
    required this.likes,
    required this.comments,
    this.liked = false,
  });

  factory FeedVideo.fromMap(Map<String, dynamic> map) {
    return FeedVideo(
      id: '${map['id']}',
      url: '${map['video_url']}',
      caption: map['caption'] ?? '',
      creatorName:
          map['creator_name'] ??
          map['username'] ??
          'Reality Talent',
      creatorId: map['user_id']?.toString(),
      views: (map['views_count'] ?? 0) as int,
      likes: (map['likes_count'] ?? 0) as int,
      comments: (map['comments_count'] ?? 0) as int,
    );
  }
}

/* ============================================================
   VIDEO FEED
   ============================================================ */

class VideoFeedPage extends StatefulWidget {
  final String language;

  const VideoFeedPage({
    super.key,
    required this.language,
  });

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final PageController pageController = PageController();

  List<FeedVideo> videos = [];
  bool loading = true;
  String? errorMessage;
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      final response = await supabase
          .from('videos')
          .select()
          .order('created_at', ascending: false);

      final loaded = (response as List)
          .map(
            (row) => FeedVideo.fromMap(
              Map<String, dynamic>.from(row),
            ),
          )
          .where(
            (video) =>
                video.url.isNotEmpty &&
                video.url != 'null',
          )
          .toList();

      if (mounted) {
        setState(() {
          videos = loaded;
          loading = false;
        });
      }

      await loadLikes();
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> loadLikes() async {
    final user = supabase.auth.currentUser;
    if (user == null || videos.isEmpty) return;

    try {
      final rows = await supabase
          .from('video_likes')
          .select('video_id')
          .eq('user_id', user.id);

      final likedIds =
          rows.map((e) => '${e['video_id']}').toSet();

      if (!mounted) return;

      setState(() {
        for (final video in videos) {
          video.liked = likedIds.contains(video.id);
        }
      });
    } catch (_) {}
  }

  Future<void> registerView(FeedVideo video) async {
    try {
      await supabase.rpc(
        'rd_register_view',
        params: {
          'p_video_id': video.id,
        },
      );
    } catch (_) {}
  }

  Future<void> toggleLike(FeedVideo video) async {
    final ok = await requireLogin(
      context,
      widget.language,
    );

    if (!ok) return;

    try {
      final result = await supabase.rpc(
        'rd_toggle_video_like',
        params: {
          'p_video_id': video.id,
        },
      );

      final map = Map<String, dynamic>.from(result);

      if (mounted) {
        setState(() {
          video.liked = map['liked'] == true;
          video.likes =
              (map['count'] ?? video.likes) as int;
        });
      }
    } catch (e) {
      showMessage(e.toString());
    }
  }

  Future<void> showComments(FeedVideo video) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CommentsSheet(
        language: widget.language,
        video: video,
      ),
    );

    await loadVideos();
  }

  Future<void> followCreator(FeedVideo video) async {
    if (video.creatorId == null) return;

    final ok = await requireLogin(
      context,
      widget.language,
    );

    if (!ok) return;

    try {
      await supabase.rpc(
        'rd_toggle_follow',
        params: {
          'p_following_id': video.creatorId,
        },
      );

      showMessage(T.s(widget.language, 'success'));
    } catch (e) {
      showMessage(e.toString());
    }
  }

  Future<void> shareVideo(FeedVideo video) async {
    await Clipboard.setData(
      ClipboardData(text: video.url),
    );

    showMessage(
      T.s(widget.language, 'share'),
    );
  }

  Future<void> uploadVideo() async {
    final ok = await requireLogin(
      context,
      widget.language,
    );

    if (!ok) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadVideoPage(
          language: widget.language,
        ),
      ),
    );

    if (result == true) {
      await loadVideos();
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (videos.isEmpty)
            Center(
              child: Text(
                T.s(lang, 'no_videos'),
                style: const TextStyle(fontSize: 18),
              ),
            )
          else
            PageView.builder(
              controller: pageController,
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              onPageChanged: (index) {
                setState(() {
                  activeIndex = index;
                });

                registerView(videos[index]);
              },
              itemBuilder: (context, index) {
                final video = videos[index];

                return VideoFeedItem(
                  key: ValueKey(video.id),
                  video: video,
                  active: index == activeIndex,
                  language: lang,
                  onLike: () => toggleLike(video),
                  onComments: () => showComments(video),
                  onShare: () => shareVideo(video),
                  onFollow: () => followCreator(video),
                );
              },
            ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'REALITY DUEL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: uploadVideo,
                      icon: const Icon(Icons.add_box_outlined),
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

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

/* ============================================================
   VIDEO ITEM
   ============================================================ */

class VideoFeedItem extends StatefulWidget {
  final FeedVideo video;
  final bool active;
  final String language;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback onShare;
  final VoidCallback onFollow;

  const VideoFeedItem({
    super.key,
    required this.video,
    required this.active,
    required this.language,
    required this.onLike,
    required this.onComments,
    required this.onShare,
    required this.onFollow,
  });

  @override
  State<VideoFeedItem> createState() =>
      _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  VideoPlayerController? controller;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    final c = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.url),
    );

    controller = c;

    try {
      await c.initialize();
      await c.setLooping(true);

      if (mounted) {
        setState(() {
          initialized = true;
        });

        if (widget.active) {
          await c.play();
        }
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(
    covariant VideoFeedItem oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (controller == null) return;

    if (widget.active) {
      controller!.play();
    } else {
      controller!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (initialized && c != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(),
          ),

        Positioned(
          left: 16,
          right: 90,
          bottom: 90,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '@${widget.video.creatorName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.video.caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.video.caption,
                    style: const TextStyle(fontSize: 16),
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
              IconButton(
                onPressed: widget.onLike,
                icon: Icon(
                  widget.video.liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 34,
                ),
              ),
              Text('${widget.video.likes}'),
              const SizedBox(height: 16),
              IconButton(
                onPressed: widget.onComments,
                icon: const Icon(
                  Icons.comment,
                  size: 32,
                ),
              ),
              Text('${widget.video.comments}'),
              const SizedBox(height: 16),
              IconButton(
                onPressed: widget.onShare,
                icon: const Icon(
                  Icons.share,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              IconButton(
                onPressed: widget.onFollow,
                icon: const Icon(
                  Icons.person_add,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

/* ============================================================
   COMMENTS
   ============================================================ */

class CommentsSheet extends StatefulWidget {
  final String language;
  final FeedVideo video;

  const CommentsSheet({
    super.key,
    required this.language,
    required this.video,
  });

  @override
  State<CommentsSheet> createState() =>
      _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final controller = TextEditingController();

  List<Map<String, dynamic>> comments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final response = await supabase
          .from('video_comments')
          .select()
          .eq('video_id', widget.video.id)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          comments = (response as List)
              .map(
                (e) => Map<String, dynamic>.from(e),
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

  Future<void> addComment() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      Navigator.pop(context);
      await requireLogin(
        context,
        widget.language,
      );
      return;
    }

    final text = controller.text.trim();

    if (text.isEmpty) return;

    try {
      final profile = await supabase
          .from('profiles')
          .select('username,display_name')
          .eq('id', user.id)
          .maybeSingle();

      final username =
          profile?['username'] ??
          profile?['display_name'] ??
          user.email?.split('@').first ??
          'User';

      await supabase.from('video_comments').insert({
        'video_id': widget.video.id,
        'user_id': user.id,
        'username': username,
        'comment': text,
      });

      await supabase
          .from('videos')
          .update({
            'comments_count':
                widget.video.comments + 1,
          })
          .eq('id', widget.video.id);

      controller.clear();
      await loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height *
              .70,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  T.s(lang, 'comments'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : comments.isEmpty
                        ? const Center(
                            child:
                                Text('No comments yet'),
                          )
                        : ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (_, index) {
                              final c =
                                  comments[index];

                              return ListTile(
                                leading:
                                    const CircleAvatar(
                                  child:
                                      Icon(Icons.person),
                                ),
                                title: Text(
                                  '${c['username'] ?? 'User'}',
                                ),
                                subtitle: Text(
                                  '${c['comment'] ?? ''}',
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
                        decoration: InputDecoration(
                          hintText:
                              T.s(lang, 'write_comment'),
                          border:
                              const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: addComment,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
  final captionController = TextEditingController();

  PlatformFile? selectedFile;
  bool uploading = false;

  Future<void> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      selectedFile = result.files.first;
    });
  }

  Future<void> upload() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await requireLogin(
        context,
        widget.language,
      );
      return;
    }

    final file = selectedFile;

    if (file == null || file.bytes == null) {
      showMessage(
        T.s(widget.language, 'choose_video'),
      );
      return;
    }

    setState(() {
      uploading = true;
    });

    try {
      final safeName = file.name
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

      final path =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await supabase.storage
          .from('videos')
          .uploadBinary(
            path,
            file.bytes!,
            fileOptions: const FileOptions(
              contentType: 'video/mp4',
              upsert: false,
            ),
          );

      final url = supabase.storage
          .from('videos')
          .getPublicUrl(path);

      final profile = await supabase
          .from('profiles')
          .select('display_name,username')
          .eq('id', user.id)
          .maybeSingle();

      final creatorName =
          profile?['display_name'] ??
          profile?['username'] ??
          user.email?.split('@').first ??
          'Reality Talent';

      await supabase.from('videos').insert({
        'user_id': user.id,
        'storage_path': path,
        'video_url': url,
        'caption': captionController.text.trim(),
        'creator_name': creatorName,
        'media_type': 'video',
        'views_count': 0,
        'likes_count': 0,
        'comments_count': 0,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          uploading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'upload_video')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            OutlinedButton.icon(
              onPressed: uploading ? null : pickVideo,
              icon: const Icon(Icons.video_library),
              label: Text(
                selectedFile?.name ??
                    T.s(lang, 'choose_video'),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: captionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: T.s(lang, 'caption'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: uploading ? null : upload,
                child: uploading
                    ? const CircularProgressIndicator()
                    : Text(T.s(lang, 'publish')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
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
  State<DuelsPage> createState() => _DuelsPageState();
}

class _DuelsPageState extends State<DuelsPage> {
  List<Map<String, dynamic>> duels = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDuels();
  }

  Future<void> loadDuels() async {
    try {
      final response = await supabase
          .from('duels')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          duels = (response as List)
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
      }
    }
  }

  Future<void> createDuel() async {
    final ok = await requireLogin(
      context,
      widget.language,
    );

    if (!ok) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDuelPage(
          language: widget.language,
        ),
      ),
    );

    if (result == true) {
      await loadDuels();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'duels')),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : duels.isEmpty
              ? Center(
                  child: Text(
                    T.s(lang, 'no_duels'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadDuels,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: duels.length,
                    itemBuilder: (_, index) {
                      final duel = duels[index];

                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 14),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child:
                                Icon(Icons.sports_mma),
                          ),
                          title: Text(
                            '${duel['title'] ?? ''}',
                          ),
                          subtitle: Text(
                            '${duel['description'] ?? ''}',
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DuelDetailPage(
                                  language: lang,
                                  duelId:
                                      '${duel['id']}',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createDuel,
        icon: const Icon(Icons.add),
        label: Text(T.s(lang, 'create_duel')),
      ),
    );
  }
}

/* ============================================================
   CREATE DUEL
   ============================================================ */

class CreateDuelPage extends StatefulWidget {
  final String language;

  const CreateDuelPage({
    super.key,
    required this.language,
  });

  @override
  State<CreateDuelPage> createState() =>
      _CreateDuelPageState();
}

class _CreateDuelPageState
    extends State<CreateDuelPage> {
  final titleController = TextEditingController();
  final descriptionController =
      TextEditingController();
  final typeController = TextEditingController();

  bool loading = false;

  Future<void> create() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (titleController.text.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      await supabase.from('duels').insert({
        'creator_id': user.id,
        'title': titleController.text.trim(),
        'description':
            descriptionController.text.trim(),
        'duel_type': typeController.text.trim(),
        'status': 'open',
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'create_duel')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'title'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: T.s(lang, 'description'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: typeController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'type'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: loading ? null : create,
            child: loading
                ? const CircularProgressIndicator()
                : Text(T.s(lang, 'create')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    typeController.dispose();
    super.dispose();
  }
}

/* ============================================================
   DUEL DETAIL
   ============================================================ */

class DuelDetailPage extends StatefulWidget {
  final String language;
  final String duelId;

  const DuelDetailPage({
    super.key,
    required this.language,
    required this.duelId,
  });

  @override
  State<DuelDetailPage> createState() =>
      _DuelDetailPageState();
}

class _DuelDetailPageState
    extends State<DuelDetailPage> {
  Map<String, dynamic>? duel;
  bool loading = true;
  bool joining = false;

  @override
  void initState() {
    super.initState();
    loadDuel();
  }

  Future<void> loadDuel() async {
    try {
      final response = await supabase
          .from('duels')
          .select()
          .eq('id', widget.duelId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          duel = response;
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

  Future<void> join() async {
    final ok = await requireLogin(
      context,
      widget.language,
    );

    if (!ok) return;

    final user = supabase.auth.currentUser!;

    setState(() {
      joining = true;
    });

    try {
      await supabase
          .from('duel_participants')
          .upsert({
        'duel_id': widget.duelId,
        'user_id': user.id,
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProofPage(
              language: widget.language,
              duelId: widget.duelId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          joining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'duels')),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : duel == null
              ? Center(
                  child: Text(
                    T.s(lang, 'error'),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      '${duel!['title'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${duel!['description'] ?? ''}',
                      style:
                          const TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 16),
                    Chip(
                      label: Text(
                        '${duel!['duel_type'] ?? ''}',
                      ),
                    ),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: joining ? null : join,
                      icon: const Icon(Icons.play_arrow),
                      label: joining
                          ? const CircularProgressIndicator()
                          : Text(T.s(lang, 'join')),
                    ),
                  ],
                ),
    );
  }
}

/* ============================================================
   PROOF
   ============================================================ */

class ProofPage extends StatefulWidget {
  final String language;
  final String duelId;

  const ProofPage({
    super.key,
    required this.language,
    required this.duelId,
  });

  @override
  State<ProofPage> createState() => _ProofPageState();
}

class _ProofPageState extends State<ProofPage> {
  PlatformFile? selectedFile;
  String? proofType;
  bool uploading = false;

  Future<void> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      selectedFile = result.files.first;
      proofType = 'video';
    });
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      selectedFile = result.files.first;
      proofType = 'image';
    });
  }

  Future<void> submit() async {
    final user = supabase.auth.currentUser;

    if (user == null ||
        selectedFile == null ||
        selectedFile!.bytes == null) {
      return;
    }

    setState(() {
      uploading = true;
    });

    try {
      final file = selectedFile!;

      final safeName = file.name
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

      final path =
          '${user.id}/proofs/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await supabase.storage
          .from('videos')
          .uploadBinary(
            path,
            file.bytes!,
            fileOptions: FileOptions(
              contentType: proofType == 'image'
                  ? 'image/jpeg'
                  : 'video/mp4',
              upsert: false,
            ),
          );

      final url = supabase.storage
          .from('videos')
          .getPublicUrl(path);

      String? videoId;

      if (proofType == 'video') {
        final profile = await supabase
            .from('profiles')
            .select('display_name,username')
            .eq('id', user.id)
            .maybeSingle();

        final creator =
            profile?['display_name'] ??
            profile?['username'] ??
            'Reality Talent';

        final inserted = await supabase
            .from('videos')
            .insert({
              'user_id': user.id,
              'storage_path': path,
              'video_url': url,
              'caption': 'Duel Proof',
              'creator_name': creator,
              'media_type': 'video',
              'views_count': 0,
              'likes_count': 0,
              'comments_count': 0,
            })
            .select('id')
            .single();

        videoId = '${inserted['id']}';
      }

      await supabase
          .from('duel_participants')
          .upsert({
        'duel_id': widget.duelId,
        'user_id': user.id,
        'proof_url': url,
        'proof_type': proofType,
        'proof_video_id': videoId,
      });

      try {
        final profile = await supabase
            .from('profiles')
            .select('proofs_count')
            .eq('id', user.id)
            .single();

        final count =
            (profile['proofs_count'] ?? 0) as int;

        await supabase
            .from('profiles')
            .update({
          'proofs_count': count + 1,
        }).eq('id', user.id);
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              T.s(
                widget.language,
                'proof_submitted',
              ),
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'submit_proof')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    uploading ? null : pickVideo,
                icon:
                    const Icon(Icons.video_library),
                label: Text(
                  T.s(lang, 'choose_video'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    uploading ? null : pickImage,
                icon: const Icon(Icons.image),
                label:
                    Text(T.s(lang, 'add_photo')),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedFile != null)
              Text(
                selectedFile!.name,
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    uploading ? null : submit,
                child: uploading
                    ? const CircularProgressIndicator()
                    : Text(
                        T.s(lang, 'submit_proof'),
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
   DISCOVER
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
  final searchController = TextEditingController();

  List<Map<String, dynamic>> talents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTalents();
  }

  Future<void> loadTalents() async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .order('talent_score', ascending: false);

      if (mounted) {
        setState(() {
          talents = (response as List)
              .map(
                (e) => Map<String, dynamic>.from(e),
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

  List<Map<String, dynamic>> filtered() {
    final query =
        searchController.text.trim().toLowerCase();

    if (query.isEmpty) return talents;

    return talents.where((talent) {
      final text = [
        talent['username'],
        talent['display_name'],
        talent['country'],
        talent['bio'],
      ].join(' ').toLowerCase();

      return text.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    final list = filtered();

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'talent')),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.search),
                      hintText:
                          T.s(lang, 'search'),
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text(
                            T.s(lang, 'no_talent'),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: list.length,
                          itemBuilder: (_, index) {
                            final talent = list[index];

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: ListTile(
                                leading:
                                    const CircleAvatar(
                                  child:
                                      Icon(Icons.person),
                                ),
                                title: Text(
                                  '${talent['display_name'] ?? talent['username'] ?? 'Talent'}',
                                ),
                                subtitle: Text(
                                  [
                                    if (talent['country'] !=
                                        null)
                                      '${talent['country']}',
                                    if (talent['bio'] !=
                                        null)
                                      '${talent['bio']}',
                                  ].join(' • '),
                                  maxLines: 2,
                                ),
                                trailing: Text(
                                  '${talent['talent_score'] ?? 0}',
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PublicTalentPage(
                                        language: lang,
                                        userId:
                                            '${talent['id']}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

/* ============================================================
   PUBLIC TALENT
   ============================================================ */

class PublicTalentPage extends StatefulWidget {
  final String language;
  final String userId;

  const PublicTalentPage({
    super.key,
    required this.language,
    required this.userId,
  });

  @override
  State<PublicTalentPage> createState() =>
      _PublicTalentPageState();
}

class _PublicTalentPageState
    extends State<PublicTalentPage> {
  Map<String, dynamic>? profile;
  bool loading = true;
  bool following = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', widget.userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          profile = response;
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

  Future<void> follow() async {
    final ok = await requireLogin(
      context,
      widget.language,
    );

    if (!ok) return;

    try {
      final result = await supabase.rpc(
        'rd_toggle_follow',
        params: {
          'p_following_id': widget.userId,
        },
      );

      setState(() {
        following =
            (result['following'] ?? false) == true;
      });

      await loadProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'talent')),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : profile == null
              ? Center(
                  child:
                      Text(T.s(lang, 'no_talent')),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.person,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        '${profile!['display_name'] ?? profile!['username'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '@${profile!['username'] ?? ''}',
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (profile!['bio'] != null)
                      Text(
                        '${profile!['bio']}',
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        StatItem(
                          title:
                              T.s(lang, 'followers'),
                          value:
                              '${profile!['followers_count'] ?? 0}',
                        ),
                        StatItem(
                          title:
                              T.s(lang, 'following_count'),
                          value:
                              '${profile!['following_count'] ?? 0}',
                        ),
                        StatItem(
                          title:
                              T.s(lang, 'wins'),
                          value:
                              '${profile!['wins_count'] ?? 0}',
                        ),
                        StatItem(
                          title:
                              T.s(lang, 'proofs'),
                          value:
                              '${profile!['proofs_count'] ?? 0}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: follow,
                      icon: const Icon(
                        Icons.person_add,
                      ),
                      label: Text(
                        following
                            ? T.s(lang, 'following')
                            : T.s(lang, 'follow'),
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
  List<Map<String, dynamic>> opportunities = [];
  Set<String> appliedIds = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOpportunities();
  }

  Future<void> loadOpportunities() async {
    try {
      final response = await supabase
          .from('opportunities')
          .select()
          .order('created_at', ascending: false);

      final user = supabase.auth.currentUser;

      if (user != null) {
        final apps = await supabase
            .from('opportunity_applications')
            .select('opportunity_id')
            .eq('user_id', user.id);

        appliedIds = apps
            .map(
              (e) => '${e['opportunity_id']}',
            )
            .toSet();
      }

      if (mounted) {
        setState(() {
          opportunities = (response as List)
              .map(
                (e) => Map<String, dynamic>.from(e),
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

  Future<void> apply(String id) async {
    final ok = await requireLogin(
      context,
      widget.language,
    );

    if (!ok) return;

    final user = supabase.auth.currentUser!;

    try {
      await supabase
          .from('opportunity_applications')
          .upsert({
        'opportunity_id': id,
        'user_id': user.id,
        'status': 'pending',
      });

      setState(() {
        appliedIds.add(id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            T.s(
              widget.language,
              'application_sent',
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> createOpportunity() async {
    final ok = await requireLogin(
      context,
      widget.language,
    );

    if (!ok) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOpportunityPage(
          language: widget.language,
        ),
      ),
    );

    if (result == true) {
      await loadOpportunities();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'opportunities')),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : opportunities.isEmpty
              ? Center(
                  child: Text(
                    T.s(
                      lang,
                      'no_opportunities',
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadOpportunities,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        opportunities.length,
                    itemBuilder: (_, index) {
                      final opportunity =
                          opportunities[index];

                      final id =
                          '${opportunity['id']}';

                      final isApplied =
                          appliedIds.contains(id);

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${opportunity['title'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${opportunity['company_name'] ?? ''}',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${opportunity['description'] ?? ''}',
                                maxLines: 4,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              if (opportunity[
                                      'location'] !=
                                  null)
                                Text(
                                  '📍 ${opportunity['location']}',
                                ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed:
                                      isApplied
                                          ? null
                                          : () =>
                                              apply(id),
                                  child: Text(
                                    isApplied
                                        ? T.s(
                                            lang,
                                            'applied',
                                          )
                                        : T.s(
                                            lang,
                                            'apply',
                                          ),
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
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: createOpportunity,
        icon: const Icon(Icons.add),
        label: Text(
          T.s(lang, 'create_opportunity'),
        ),
      ),
    );
  }
}

/* ============================================================
   CREATE OPPORTUNITY
   ============================================================ */

class CreateOpportunityPage extends StatefulWidget {
  final String language;

  const CreateOpportunityPage({
    super.key,
    required this.language,
  });

  @override
  State<CreateOpportunityPage> createState() =>
      _CreateOpportunityPageState();
}

class _CreateOpportunityPageState
    extends State<CreateOpportunityPage> {
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final typeController = TextEditingController();
  final descriptionController =
      TextEditingController();
  final locationController =
      TextEditingController();

  bool loading = false;

  Future<void> create() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (titleController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await supabase.from('opportunities').insert({
        'created_by': user.id,
        'title': titleController.text.trim(),
        'company_name':
            companyController.text.trim(),
        'opportunity_type':
            typeController.text.trim(),
        'description':
            descriptionController.text.trim(),
        'location':
            locationController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(T.s(lang, 'create_opportunity')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'title'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: companyController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'company'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: typeController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'type'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: locationController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'location'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText:
                  T.s(lang, 'description'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: loading ? null : create,
            child: loading
                ? const CircularProgressIndicator()
                : Text(T.s(lang, 'create')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    typeController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }
}

/* ============================================================
   TALENT PROFILE
   ============================================================ */

class TalentProfilePage extends StatefulWidget {
  final String language;

  const TalentProfilePage({
    super.key,
    required this.language,
  });

  @override
  State<TalentProfilePage> createState() =>
      _TalentProfilePageState();
}

class _TalentProfilePageState
    extends State<TalentProfilePage> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((_) {
      if (mounted) {
        loadProfile();
      }
    });

    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          profile = null;
          loading = false;
        });
      }
      return;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          profile = response;
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

  Future<void> login() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          language: widget.language,
        ),
      ),
    );

    await loadProfile();
  }

  Future<void> editProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null || profile == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          language: widget.language,
          profile: profile!,
        ),
      ),
    );

    if (result == true) {
      await loadProfile();
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (mounted) {
      setState(() {
        profile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            T.s(
              widget.language,
              'logout_success',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(T.s(lang, 'profile')),
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
                const SizedBox(height: 16),
                Text(
                  T.s(lang, 'guest_user'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: login,
                  child: Text(
                    T.s(lang, 'login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final p = profile ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(T.s(lang, 'profile')),
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
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 55,
              child: Icon(
                Icons.person,
                size: 55,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${p['display_name'] ?? p['username'] ?? 'Talent'}',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '@${p['username'] ?? ''}',
              ),
            ),
            const SizedBox(height: 12),
            if (p['bio'] != null)
              Text(
                '${p['bio']}',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                StatItem(
                  title:
                      T.s(lang, 'followers'),
                  value:
                      '${p['followers_count'] ?? 0}',
                ),
                StatItem(
                  title: T.s(
                    lang,
                    'following_count',
                  ),
                  value:
                      '${p['following_count'] ?? 0}',
                ),
                StatItem(
                  title: T.s(lang, 'wins'),
                  value:
                      '${p['wins_count'] ?? 0}',
                ),
                StatItem(
                  title: T.s(lang, 'proofs'),
                  value:
                      '${p['proofs_count'] ?? 0}',
                ),
              ],
            ),
            const SizedBox(height: 25),
            Card(
              child: ListTile(
                leading: const Icon(Icons.star),
                title: Text(
                  T.s(lang, 'talent_score'),
                ),
                trailing: Text(
                  '${p['talent_score'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.location_on),
                title:
                    Text(T.s(lang, 'country')),
                subtitle: Text(
                  '${p['country'] ?? '-'}',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.psychology),
                title:
                    Text(T.s(lang, 'skills')),
                subtitle: Text(
                  ((p['skills'] as List?) ?? [])
                      .join(', '),
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
   EDIT PROFILE
   ============================================================ */

class EditProfilePage extends StatefulWidget {
  final String language;
  final Map<String, dynamic> profile;

  const EditProfilePage({
    super.key,
    required this.language,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController displayController;
  late TextEditingController bioController;
  late TextEditingController countryController;
  late TextEditingController skillsController;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(
      text: '${widget.profile['username'] ?? ''}',
    );

    displayController = TextEditingController(
      text:
          '${widget.profile['display_name'] ?? ''}',
    );

    bioController = TextEditingController(
      text: '${widget.profile['bio'] ?? ''}',
    );

    countryController = TextEditingController(
      text: '${widget.profile['country'] ?? ''}',
    );

    final skills =
        (widget.profile['skills'] as List?) ?? [];

    skillsController = TextEditingController(
      text: skills.join(', '),
    );
  }

  Future<void> save() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      saving = true;
    });

    try {
      final skills = skillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await supabase.from('profiles').update({
        'username':
            usernameController.text.trim(),
        'display_name':
            displayController.text.trim(),
        'bio': bioController.text.trim(),
        'country':
            countryController.text.trim(),
        'skills': skills,
        'updated_at':
            DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(T.s(lang, 'edit_profile')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'username'),
              border:
                  const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: displayController,
            decoration: InputDecoration(
              labelText:
                  T.s(lang, 'display_name'),
              border:
                  const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: bioController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: T.s(lang, 'bio'),
              border:
                  const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: countryController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'country'),
              border:
                  const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: skillsController,
            decoration: InputDecoration(
              labelText: T.s(lang, 'skills'),
              hintText: 'Flutter, Design, Music',
              border:
                  const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: saving ? null : save,
            child: saving
                ? const CircularProgressIndicator()
                : Text(T.s(lang, 'save')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    displayController.dispose();
    bioController.dispose();
    countryController.dispose();
    skillsController.dispose();
    super.dispose();
  }
}

/* ============================================================
   STAT
   ============================================================ */

class StatItem extends StatelessWidget {
  final String title;
  final String value;

  const StatItem({
    super.key,
    required this.title,
    required this.value,
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
