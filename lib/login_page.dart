import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

// ✅ Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:secretgarden_app/app_db.dart';

// ✅ Halaman tujuan
import 'package:secretgarden_app/homepage.dart';
import 'package:secretgarden_app/register.dart';
import 'package:secretgarden_app/forgot_password.dart';
import 'package:secretgarden_app/admin/admin_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const greenColor = Color(0xFF145A00);
  static const backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.black87),
          floatingLabelStyle: const TextStyle(color: greenColor),
          focusColor: greenColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: greenColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: greenColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home:
          const LoginPage(), // bisa juga Splash/Welcome yang push ke LoginPage
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 🔁 Ganti 'username' -> email sesuai Firebase
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();
  bool _loading = false;

  void _showTopNotification(String message, {bool success = false}) {
    Flushbar(
      message: message,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(10),
      backgroundColor: success ? MyApp.greenColor : Colors.red.shade700,
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  Future<void> _login() async {
    final email = _emailC.text.trim();
    final pass = _passC.text;

    if (email.isEmpty || pass.isEmpty) {
      _showTopNotification('Isi email dan password');
      return;
    }

    setState(() => _loading = true);
    try {
      // 1) Sign in
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // 2) Cek role admin di Realtime DB: admins/<uid> == true
      final uid = cred.user!.uid;
      final snap = await await dbRef('admins/$uid').get();
      final v = snap.value;
      final isAdmin = v is bool && v;

      if (!mounted) return;

      _showTopNotification('Login berhasil', success: true);

      // 3) Redirect sesuai role
      await Future.delayed(const Duration(milliseconds: 600));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => isAdmin ? const AdminHomePage() : HomePage(),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showTopNotification(e.message ?? 'Login gagal');
    } catch (e) {
      _showTopNotification('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.backgroundColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Opacity(
                opacity: 0.55,
                child: Image.network(
                  'https://ucarecdn.com/d02a0863-1e2f-4ce4-8264-47459cba7f61/daunn.png',
                  width: 320,
                  height: 320,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (Navigator.canPop(context))
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Logo
                  Image.network(
                    'https://ucarecdn.com/f1083d3c-ac61-4c16-824f-8cd6344456c5/Logo_secretgarden.png',
                    width: 180,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔁 EMAIL (bukan Username)
                  TextField(
                    controller: _emailC,
                    cursorColor: MyApp.greenColor,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _login(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black87),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyApp.greenColor, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyApp.greenColor, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      floatingLabelStyle: TextStyle(color: MyApp.greenColor),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  TextField(
                    controller: _passC,
                    obscureText: true,
                    cursorColor: MyApp.greenColor,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black87),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyApp.greenColor, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyApp.greenColor, width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      floatingLabelStyle: TextStyle(color: MyApp.greenColor),
                    ),
                  ),

                
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // TOMBOL LOGIN
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyApp.greenColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Masuk'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Belum punya akun? Daftar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterPage()),
                          );
                        },
                        child: const Text(
                          "Daftar",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
