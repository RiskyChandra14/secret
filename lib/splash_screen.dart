import 'package:flutter/material.dart';
import 'welcome.dart';

void main() {
  runApp(const Splash_screen());
}

class Splash_screen extends StatelessWidget {
  const Splash_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // ✅ Background putih
      ),
      home: const Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double decorationSize = size.width * 0.4;
    final double logoSize = size.width * 0.40;

    return Stack(
      children: [
        SizedBox.expand(child: Container(color: Colors.white)),

        // Dekorasi atas kiri
        Positioned(
          top: 0,
          left: 0,
          width: decorationSize,
          height: decorationSize,
          child: Opacity(
            opacity: 0.6,
            child: Image.network(
              'https://ucarecdn.com/26a9b8df-c122-48cb-8e77-226f394ab4ee/imagehias.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Dekorasi bawah kanan
        Positioned(
          bottom: 0,
          right: 0,
          width: size.width * 0.45,
          child: Opacity(
            opacity: 0.6,
            child: Image.network(
              'https://ucarecdn.com/650104f2-08b7-485c-a06c-21aa5d5430a3/daun.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Dekorasi daun layu kiri bawah
        Positioned(
          bottom: 0,
          left: 0,
          width: decorationSize * 0.9,
          height: decorationSize * 0.9,
          child: Opacity(
            opacity: 0.6,
            child: Image.network(
              'https://ucarecdn.com/0ee128f9-109c-456e-8a12-c33f2abe5214/daunLayu.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Konten tengah (Logo & Text)
        Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 2),
            curve: Curves.easeIn,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval( // ✅ Membuat logo bulat
                  child: Image.network(
                    "https://ucarecdn.com/f1083d3c-ac61-4c16-824f-8cd6344456c5/Logo_secretgarden.png",
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aplikasi Restoran &\nBooking Tempat',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
