import 'package:flutter/material.dart';

void main() => runApp(const RealityDuelApp());

enum Role { talent, company }
enum ProofStatus { none, pending, verified, rejected }

class AppState extends ChangeNotifier {
  Role? role;
  String name = '';
  String email = '';
  String country = '';
  String headline = '';
  String company = '';
  String industry = '';
  List<String> skills = [];
  bool openToWork = true;
  bool openToOpportunities = true;
  int proofCount = 0;
  ProofStatus proofStatus = ProofStatus.none;

  bool get signedIn => role != null;

  void createAccount({
    required Role newRole,
    required String newName,
    required String newEmail,
    required String newCountry,
    String newHeadline = '',
    String newCompany = '',
    String newIndustry = '',
    List<String> newSkills = const [],
  }) {
    role = newRole;
    name = newName;
    email = newEmail;
    country = newCountry;
    headline = newHeadline;
    company = newCompany;
    industry = newIndustry;
    skills = List.of(newSkills);
    notifyListeners();
  }

  void submitProof() {
    proofCount++;
    proofStatus = ProofStatus.pending;
    notifyListeners();
  }

  void signOut() {
    role = null;
    notifyListeners();
  }
}

final app = AppState();

class RealityDuelApp extends StatelessWidget {
  const RealityDuelApp({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: app,
    builder: (_, __) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reality Duel',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF7557FF),
        scaffoldBackgroundColor: const Color(0xFF080911),
      ),
      home: app.signedIn ? const MainShell() : const Welcome(),
    ),
  );
}

class Welcome extends StatelessWidget {
  const Welcome({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.public, size: 60),
        const SizedBox(height: 20),
        const Text('REALITY DUEL', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('The World Is Your Arena.', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        const Text('أظهر موهبتك • أثبتها • دع العالم يكتشفك', style: TextStyle(fontSize: 17)),
        const SizedBox(height: 22),
        const Bullet('⚔️ تحديات أساسية مجانية'),
        const Bullet('🎥 إثبات بالفيديو والصور'),
        const Bullet('👤 Talent Profile'),
        const Bullet('🔎 Discover Talent'),
        const Bullet('💼 Opportunities & Hiring'),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleChoice())),
          child: const Text('إنشاء حساب'),
        )),
        SizedBox(width: double.infinity, child: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignIn())),
          child: const Text('لدي حساب بالفعل'),
        )),
      ]),
    )),
  );
}

class Bullet extends StatelessWidget {
  final String text;
  const Bullet(this.text, {super.key});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text));
}

class RoleChoice extends StatelessWidget {
  const RoleChoice({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('نوع الحساب')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('اختر طريقة استخدامك للمنصة', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      ChoiceCard(Icons.person, 'موهبة / مستخدم', 'أظهر مهاراتك وشارك في التحديات وابحث عن الفرص.', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUp(role: Role.talent)));
      }),
      ChoiceCard(Icons.business, 'شركة', 'اكتشف المواهب وانشر الوظائف والفرص ووظّف من داخل المنصة.', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUp(role: Role.company)));
      }),
    ]),
  );
}

class ChoiceCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const ChoiceCard(this.icon, this.title, this.subtitle, this.onTap, {super.key});
  @override Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.all(18),
    leading: CircleAvatar(radius: 27, child: Icon(icon)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: onTap,
  ));
}

class SignUp extends StatefulWidget {
  final Role role;
  const SignUp({super.key, required this.role});
  @override State<SignUp> createState() => _SignUpState();
}
class _SignUpState extends State<SignUp> {
  final name = TextEditingController();
  final email = TextEditingController();
  final country = TextEditingController();
  final headline = TextEditingController();
  final skills = TextEditingController();
  final company = TextEditingController();
  final industry = TextEditingController();
  final password = TextEditingController();

  @override void dispose() {
    for (final c in [name,email,country,headline,skills,company,industry,password]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.role == Role.talent ? 'حساب الموهبة' : 'حساب الشركة')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(widget.role == Role.talent ? 'أنشئ ملف موهبتك' : 'أنشئ ملف شركتك', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      Input(name, widget.role == Role.talent ? 'الاسم' : 'اسم المسؤول', Icons.person),
      Input(email, 'البريد الإلكتروني', Icons.email),
      Input(password, 'كلمة المرور', Icons.lock, obscure: true),
      Input(country, 'الدولة', Icons.public),
      if (widget.role == Role.talent) ...[
        Input(headline, 'العنوان المهني / الموهبة', Icons.auto_awesome),
        Input(skills, 'المهارات — افصل بينها بفواصل', Icons.psychology),
      ] else ...[
        Input(company, 'اسم الشركة', Icons.business),
        Input(industry, 'المجال', Icons.category),
      ],
      const SizedBox(height: 10),
      const Card(child: ListTile(
        leading: Icon(Icons.lock_outline),
        title: Text('قاعدة Reality Duel'),
        subtitle: Text('لا يدفع المستخدم للمشاركة الأساسية في التحديات ولا يمكن شراء الفوز.'),
      )),
      const SizedBox(height: 16),
      FilledButton(onPressed: () {
        if (name.text.trim().isEmpty || email.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الاسم والبريد الإلكتروني.')));
          return;
        }
        app.createAccount(
          newRole: widget.role,
          newName: name.text.trim(),
          newEmail: email.text.trim(),
          newCountry: country.text.trim(),
          newHeadline: headline.text.trim(),
          newCompany: company.text.trim(),
          newIndustry: industry.text.trim(),
          newSkills: skills.text.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty).toList(),
        );
        Navigator.of(context).popUntil((r) => r.isFirst);
      }, child: const Text('إنشاء الحساب')),
    ]),
  );
}

class SignIn extends StatelessWidget {
  const SignIn({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تسجيل الدخول')),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      const TextField(decoration: InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email))),
      const SizedBox(height: 12),
      const TextField(obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock))),
      const SizedBox(height: 18),
      FilledButton(onPressed: () {
        app.createAccount(newRole: Role.talent, newName: 'Demo Talent', newEmail: 'demo@example.com', newCountry: 'Yemen', newHeadline: 'Creative Talent', newSkills: ['Creativity']);
        Navigator.of(context).popUntil((r) => r.isFirst);
      }, child: const Text('دخول تجريبي')),
    ])),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int i = 0;
  @override Widget build(BuildContext context) {
    final company = app.role == Role.company;
    final pages = company
      ? const [CompanyHome(), Discover(), Opportunities(), CompanyProfile()]
      : const [TalentHome(), Duels(), Discover(), Opportunities(), TalentProfile()];
    return Scaffold(
      body: SafeArea(child: pages[i]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (x) => setState(() => i = x),
        destinations: company ? const [
          NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'الشركة'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'المواهب'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'الفرص'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'الملف'),
        ] : const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.flash_on_outlined), selectedIcon: Icon(Icons.flash_on), label: 'التحديات'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'المواهب'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'الفرص'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'ملفي'),
        ],
      ),
    );
  }
}

class TalentHome extends StatelessWidget {
  const TalentHome({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('REALITY DUEL', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text('مرحبًا ${app.name}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const Text('موهبتك يمكن أن تكون بداية فرصتك التالية.'),
    const SizedBox(height: 18),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ملف الموهبة', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(app.skills.isEmpty ? 'أضف مهاراتك حتى تتمكن الشركات من اكتشافك.' : 'تمت إضافة ${app.skills.length} مهارة.'),
      const SizedBox(height: 12),
      LinearProgressIndicator(value: app.skills.isEmpty ? .25 : .75),
    ]))),
    const Section('تحديات مقترحة'),
    const Tile(Icons.auto_awesome, '60-Second Creative Challenge', 'مجاني • عالمي'),
    const Tile(Icons.sports_soccer, 'Street Football Skill', 'مجاني • شخص ضد شخص'),
    const Section('فرص مقترحة'),
    const Tile(Icons.work, 'Junior Graphic Designer', 'وظيفة • Global Creative Co.'),
  ]);
}

class TalentProfile extends StatefulWidget {
  const TalentProfile({super.key});
  @override State<TalentProfile> createState() => _TalentProfileState();
}
class _TalentProfileState extends State<TalentProfile> {
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    Row(children: [
      const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(app.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(app.headline.isEmpty ? 'أضف عنوانك المهني' : app.headline),
        Text(app.country, style: TextStyle(color: Colors.white.withOpacity(.6))),
      ])),
    ]),
    const SizedBox(height: 18),
    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
      Stat('Talent Score','0'), Stat('Wins','0'), Stat('Proofs','0'), Stat('Views','0')
    ]),
    const SizedBox(height: 18),
    Card(child: Column(children: [
      SwitchListTile(value: app.openToWork, onChanged: (v) => setState(() => app.openToWork = v), title: const Text('Open to Work')),
      SwitchListTile(value: app.openToOpportunities, onChanged: (v) => setState(() => app.openToOpportunities = v), title: const Text('Open to Opportunities')),
    ])),
    const Section('المهارات'),
    Wrap(spacing: 8, children: app.skills.isEmpty ? const [Chip(label: Text('لا توجد مهارات بعد'))] : app.skills.map((x) => Chip(label: Text(x))).toList()),
    const Section('الإثباتات'),
    Card(child: ListTile(
      leading: const Icon(Icons.verified),
      title: Text(app.proofCount == 0 ? 'لا توجد إثباتات بعد' : '${app.proofCount} إثباتات'),
      subtitle: Text(_proofLabel(app.proofStatus)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProofPage())),
    )),
    OutlinedButton.icon(onPressed: app.signOut, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
  ]);

  String _proofLabel(ProofStatus s) {
    switch (s) {
      case ProofStatus.pending: return 'قيد المراجعة';
      case ProofStatus.verified: return 'موثّق';
      case ProofStatus.rejected: return 'مرفوض';
      case ProofStatus.none: return 'أرسل فيديو أو صورًا لإثبات إنجازك';
    }
  }
}

class ProofPage extends StatefulWidget {
  const ProofPage({super.key});
  @override State<ProofPage> createState() => _ProofPageState();
}
class _ProofPageState extends State<ProofPage> {
  bool video = false, photos = false;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إرسال الإثبات')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('أثبت ما أنجزته', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 7),
      const Text('في النسخة الإنتاجية سيتم رفع الملفات إلى تخزين آمن ثم تمر على التحقق.'),
      const SizedBox(height: 20),
      OutlinedButton.icon(onPressed: () => setState(() => video = true), icon: const Icon(Icons.videocam), label: Text(video ? 'تم اختيار فيديو ✓' : 'إضافة فيديو')),
      OutlinedButton.icon(onPressed: () => setState(() => photos = true), icon: const Icon(Icons.photo_library), label: Text(photos ? 'تم اختيار الصور ✓' : 'إضافة صور')),
      const SizedBox(height: 16),
      const Card(child: ListTile(leading: Icon(Icons.security), title: Text('حماية النتيجة'), subtitle: Text('لا يستطيع المستخدم اعتماد إثباته بنفسه. التحقق والنتيجة تحت سيطرة النظام والمراجعة.'))),
      const SizedBox(height: 18),
      FilledButton(onPressed: video || photos ? () {
        app.submitProof();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإثبات — قيد المراجعة.')));
      } : null, child: const Text('إرسال للمراجعة')),
    ]),
  );
}

class CompanyHome extends StatelessWidget {
  const CompanyHome({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('EMPLOYER HUB', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(app.company.isEmpty ? app.name : app.company, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    Text(app.industry),
    const SizedBox(height: 20),
    const Action(Icons.people, 'اكتشاف المواهب', 'ابحث عن المواهب حسب المهارة والنتائج الموثقة.'),
    const Action(Icons.post_add, 'نشر فرصة', 'وظيفة أو منحة أو رعاية أو مشروع.'),
    const Action(Icons.video_call, 'المقابلات', 'إدارة المرشحين داخل Reality Duel.'),
    const Action(Icons.analytics, 'تحليلات المواهب', 'مقارنة المرشحين بناءً على الأداء.'),
    const SizedBox(height: 10),
    const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('المواهب لا تدفع للمشاركة الأساسية. إيرادات المنصة تأتي من خدمات الشركات والأدوات التجارية ورسوم النجاح المؤهلة.'))),
  ]);
}

class CompanyProfile extends StatelessWidget {
  const CompanyProfile({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const CircleAvatar(radius: 44, child: Icon(Icons.business, size: 44)),
    const SizedBox(height: 12),
    Text(app.company.isEmpty ? app.name : app.company, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
    Text(app.industry, textAlign: TextAlign.center),
    const SizedBox(height: 18),
    const Card(child: ListTile(leading: Icon(Icons.verified_user), title: Text('توثيق الشركة'), subtitle: Text('في النسخة الإنتاجية سيتم التحقق من هوية الشركة قبل تفعيل أدوات التوظيف الحساسة.'))),
    OutlinedButton.icon(onPressed: app.signOut, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
  ]);
}

class Duels extends StatelessWidget {
  const Duels({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Header('التحديات', 'كل التحديات الأساسية مجانية.'),
    const Tile(Icons.auto_awesome, '60-Second Creative Challenge', 'Global Open'),
    const Tile(Icons.sports_soccer, 'Street Football Skill', 'Person vs Person'),
    const Tile(Icons.business, 'Innovation Duel', 'Company vs Company'),
    const Tile(Icons.flag, 'National Talent Challenge', 'Country vs Country'),
    const Tile(Icons.campaign, 'Company vs Everyone', 'Brand Challenge'),
  ]);
}

class Discover extends StatelessWidget {
  const Discover({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Header('Discover Talent', 'اكتشف ما يستطيع الشخص فعله فعليًا.'),
    TextField(decoration: InputDecoration(hintText: 'المهارة، الدولة، الموهبة...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white.withOpacity(.06))),
    const SizedBox(height: 14),
    const Talent('Sara Noor', 'Programming • AI', 'Jordan', 96, 31),
    const Talent('Lina Ahmed', 'Graphic Design • Video', 'Yemen', 94, 18),
    const Talent('Omar Ali', 'Football • Fitness', 'Egypt', 92, 22),
  ]);
}

class Opportunities extends StatelessWidget {
  const Opportunities({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Header('Opportunities', 'وظائف ومنح ورعايات ومشاريع.'),
    const Tile(Icons.work, 'Junior Graphic Designer', 'Job • Global Creative Co.'),
    const Tile(Icons.school, 'Global Talent Scholarship', 'Scholarship • Future Foundation'),
    const Tile(Icons.star, 'Sports Creator Sponsorship', 'Sponsorship • Active Brand'),
    const Tile(Icons.handshake, 'AI Builder Collaboration', 'Project • Tech Lab'),
  ]);
}

class Input extends StatelessWidget {
  final TextEditingController c; final String label; final IconData icon; final bool obscure;
  const Input(this.c, this.label, this.icon, {super.key, this.obscure = false});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: c, obscureText: obscure, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon))));
}

class Header extends StatelessWidget {
  final String title, sub;
  const Header(this.title, this.sub, {super.key});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
    const SizedBox(height: 5), Text(sub, style: TextStyle(color: Colors.white.withOpacity(.65))),
  ]));
}

class Section extends StatelessWidget {
  final String text;
  const Section(this.text, {super.key});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 10), child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
}

class Tile extends StatelessWidget {
  final IconData icon; final String title, sub;
  const Tile(this.icon, this.title, this.sub, {super.key});
  @override Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(sub), trailing: const Icon(Icons.chevron_right),
  ));
}

class Action extends StatelessWidget {
  final IconData icon; final String title, sub;
  const Action(this.icon, this.title, this.sub, {super.key});
  @override Widget build(BuildContext context) => Card(child: ListTile(contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(sub), trailing: const Icon(Icons.chevron_right)));
}

class Talent extends StatelessWidget {
  final String name, skill, country; final int score, wins;
  const Talent(this.name, this.skill, this.country, this.score, this.wins, {super.key});
  @override Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.all(14), leading: const CircleAvatar(child: Icon(Icons.person)),
    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('$skill\n$country • $wins verified wins'), isThreeLine: true,
    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('$score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Text('score')]),
  ));
}

class Stat extends StatelessWidget {
  final String label, value;
  const Stat(this.label, this.value, {super.key});
  @override Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 11))]);
}