import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secretgarden_app/bookingmeja.dart';
import 'package:secretgarden_app/menucustomerpage.dart';
import 'package:secretgarden_app/history.dart';
import 'package:secretgarden_app/profile/profile.dart'; // ✅ Import ProfilePage

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        "name": "western food",
        "image":
            "https://ucarecdn.com/e1655f23-30f0-4283-b8e9-adb7cf942942/westernfood.jpeg"
      },
      {
        "name": "japanese food",
        "image":
            "https://ucarecdn.com/27230ec4-e68c-4ec0-b2a0-c4dabf4ed03b/japanesefood.jpeg"
      },
      {
        "name": "nusantara food",
        "image":
            "https://ucarecdn.com/e69df354-be83-47a0-90d5-493fefc775b3/Nusantara.jpeg"
      },
      {
        "name": "light meal",
        "image":
            "https://ucarecdn.com/e89d0003-d6a7-4de0-bf02-6073d0fa15a8/Lightmeal.jpeg"
      },
    ];

    final favoritePlaces = [
      "https://ucarecdn.com/bd3e0405-4cd7-4706-a3dd-7b9fb7ac8e21/secretgarden.png",
      "https://ucarecdn.com/fc61afe3-5024-42f3-adaf-36c98c249735/secretgarden.jpg",
      "https://ucarecdn.com/d949b7e1-d193-4f62-ae8d-d91e525e17f6/secretgarden_jpg.jpg",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Secret Garden',
          style: GoogleFonts.audiowide(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: 1.2,
          ),
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.black),
          SizedBox(width: 12),
          CircleAvatar(
            backgroundImage: NetworkImage(
              "https://ucarecdn.com/20400afe-1bd5-406b-9f5f-d8ffc8586840/profile.jpeg",
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: true,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Search bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Banner promo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://ucarecdn.com/c87bf0f7-31f4-43b6-8b32-4f6a1d0ca41f/OfferandCTASection.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Popular categories
                      _sectionTitle("Popular categories"),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: categories.length,
                          itemBuilder: (_, index) {
                            final item = categories[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(item["image"]!),
                                    radius: 32,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item["name"]!,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Favorite Places
                      _sectionTitle("View Favorite Places"),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: favoritePlaces.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, index) {
                            return _placeCard(favoritePlaces[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),

      // ✅ Bottom Navigation Bar pakai pushReplacement agar tidak numpuk
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            // Halaman Home (current)
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
                  }, // Kirimkan bookingDetails ke MenuCustomerPage
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            );
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

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          const Icon(Icons.star, color: Colors.green),
          const SizedBox(width: 6),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        const Text("See All", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _placeCard(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(imageUrl, width: 160, fit: BoxFit.cover),
    );
  }
}
