import 'package:flutter/material.dart';
import 'package:secretgarden_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../homepage.dart';
import '../menucustomerpage.dart';
import '../bookingmeja.dart';
import '../history.dart';
import '../login_page.dart'; // pastikan file ini ada dan export LoginPage
import 'editprofile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar dan Nama
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      "https://ucarecdn.com/20400afe-1bd5-406b-9f5f-d8ffc8586840/profile.jpeg",
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Risky Chandra ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Riskychandra@gmail.com",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Menu Aksi Profil
            _profileMenuItem(Icons.edit, "Edit Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfilePage()),
              );
            }),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            _profileMenuItem(Icons.settings, "Settings", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings clicked")),
              );
            }),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 40),

            // Tombol Logout di bawah
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Konfirmasi Logout"),
                      content: const Text("Apakah Anda yakin ingin keluar?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Batal"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Ya"),
                        ),
                      ],
                    ),
                  );

                  if (confirmLogout == true) {
                    // Bersihkan shared preferences jika tersedia
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                    } catch (e) {
                      debugPrint('SharedPreferences error: $e');
                    }

                    // Arahkan ke LoginPage dan hapus semua route sebelumnya
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Profile aktif
        selectedItemColor: const Color(0xFF145A00),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MenuCustomerPage(
                  bookingDetails: {
                    // Tambahkan data yang sesuai di sini
                    'tableName': 'nama meja',
                    'date': 'tanggal',
                    'time': 'waktu',
                    'qty': 'jumlah meja',
                  },
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BookingPage(
                  bookingDetails: {
                    'tableName': 'nama meja',
                    'date': 'tanggal',
                    'time': 'waktu',
                    'qty': 'jumlah meja',
                  }, // Kirimkan bookingDetails yang sesuai
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HistoryPage()),
            );
          } else if (index == 4) {
            // Profile (current)
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.table_bar), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Widget untuk item menu profil
  Widget _profileMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF145A00)),
      title: Text(title),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
