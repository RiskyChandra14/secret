import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secretgarden_app/providers/history_provider.dart';
import 'package:secretgarden_app/menucustomerpage.dart';
import 'package:secretgarden_app/bookingmeja.dart';
import 'package:secretgarden_app/homepage.dart';
import 'package:secretgarden_app/profile/profile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF145A00)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          // Jika riwayat kosong, tampilkan pesan "Belum ada riwayat pesanan."
          if (historyProvider.history.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat pesanan.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            );
          }

          // Jika riwayat ada, tampilkan list history
          return ListView.builder(
            itemCount: historyProvider.history.length,
            itemBuilder: (_, index) {
              final item = historyProvider.history[index];

              // Pastikan data pada item valid
              if (item == null ||
                  item['image'] == null ||
                  item['title'] == null ||
                  item['price'] == null) {
                return const SizedBox(); // Jangan tampilkan jika data tidak lengkap
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['image']!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    item['subtitle']!,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Text(
                    item['price']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  onTap: () {
                    if (item['title'] == 'Ramen' ||
                        item['title'] == 'Milk Tea') {
                      // Pesanan Makanan atau Minuman
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MenuCustomerPage(
                            bookingDetails: {
                              'tableName': 'nama meja',
                              'date': 'tanggal',
                              'time': 'waktu',
                              'qty': 'jumlah meja',
                            },
                          ),
                        ),
                      );
                    } else if (item['title'] == 'Booking Gazebo 1') {
                      // Booking Tempat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingPage(
                            bookingDetails: {
                              'tableName': 'nama meja',
                              'date': 'tanggal',
                              'time': 'waktu',
                              'qty': 'jumlah meja',
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // History tab aktif
        selectedItemColor: Colors.green,
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
                  },
                ),
              ),
            );
          } else if (index == 3) {
            // Halaman History (current)
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
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
}
