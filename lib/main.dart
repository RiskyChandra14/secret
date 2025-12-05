import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:secretgarden_app/providers/history_provider.dart';
import 'package:provider/provider.dart'; // ✅ Import provider package
import 'app_db.dart';
import 'package:secretgarden_app/bookingmeja.dart';
import 'package:secretgarden_app/history.dart';
import 'package:secretgarden_app/homepage.dart';
import 'package:secretgarden_app/login_page.dart';
import 'package:secretgarden_app/menucustomerpage.dart';
import 'package:secretgarden_app/profile/editprofile.dart';
import 'package:secretgarden_app/profile/profile.dart';
import 'package:secretgarden_app/register.dart';
import 'splash_screen.dart';
import 'welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib sebelum init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Menambahkan MultiProvider di sekitar aplikasi
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        // Tambahkan provider lainnya jika ada
      ],
      child: const SecretGardenCafeApp(),
    ),
  );
}

class SecretGardenCafeApp extends StatelessWidget {
  const SecretGardenCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafe Secret Garden',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF145A00)),
        useMaterial3: true,
      ),
      home: Splash_screen(), // Menggunakan halaman Splash pertama
    );
  }
}
