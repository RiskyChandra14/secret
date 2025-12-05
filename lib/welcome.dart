import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:secretgarden_app/login_page.dart';
import 'package:secretgarden_app/register.dart';

void main() {
  runApp(const SecretGardenWelcomeApp());
}

class SecretGardenWelcomeApp extends StatelessWidget {
  const SecretGardenWelcomeApp({super.key});

  static const Color backgroundColor = Colors.white; // ✅ Background putih
  static const Color greenColor = Color(0xFF145A00);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: SecretGardenWelcomeApp.backgroundColor, // ✅ Putih
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.network(
              'https://ucarecdn.com/0befb688-bea5-43f3-894b-098a918dbfb2/imagehias.png',
              width: 120,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 120),

                  Image.network(
                    'https://ucarecdn.com/f1083d3c-ac61-4c16-824f-8cd6344456c5/Logo_secretgarden.png', // ✅ Logo baru
                    width: size.width * 0.6,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Sebelum menikmati layanan di Secret Garden\nSilakan daftar terlebih dahulu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Tombol Buat Akun
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SecretGardenWelcomeApp.greenColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Buat Akun',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Masuk
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SecretGardenWelcomeApp.greenColor,
                        side: const BorderSide(
                            color: SecretGardenWelcomeApp.greenColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                "Dengan masuk atau mendaftar, Anda menyetujui ",
                          ),
                          TextSpan(
                            text: "Syarat dan Ketentuan",
                            style: const TextStyle(color: Color(0xFF2DAA59)),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO
                              },
                          ),
                          const TextSpan(text: " dan "),
                          TextSpan(
                            text: "Kebijakan Privasi.",
                            style: const TextStyle(color: Color(0xFF2DAA59)),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO
                              },
                          ),
                        ],
                      ),
                    ),
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
