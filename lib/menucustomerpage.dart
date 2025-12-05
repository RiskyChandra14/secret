import 'package:flutter/material.dart';
import 'package:secretgarden_app/bookingmeja.dart';
import 'package:secretgarden_app/checkout.dart';
import 'package:secretgarden_app/history.dart';
import 'package:secretgarden_app/profile/profile.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';
import 'package:secretgarden_app/providers/history_provider.dart';

class MenuCustomerPage extends StatefulWidget {
  final Map<String, dynamic> bookingDetails; // Tambahkan properti ini

  const MenuCustomerPage(
      {super.key,
      required this.bookingDetails}); // Pastikan constructor menerima parameter ini

  @override
  State<MenuCustomerPage> createState() => _MenuCustomerPageState();
}

class _MenuCustomerPageState extends State<MenuCustomerPage> {
  void _showOrderSheet(Map<String, String> item) {
    final unitPrice = _parsePriceToInt(item['price'] ?? '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int qty = 1;
        String note = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final total = unitPrice * qty;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                          child: Text('Detail Pesanan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(item['image'] ?? '',
                            width: 70, height: 70, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(item['price'] ?? '',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (qty > 1) setModalState(() => qty--);
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$qty',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => setModalState(() => qty++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Catatan (opsional)',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: (v) => setModalState(() => note = v),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Mis: kurang pedas / es sedikit / no onion...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total: ${_formatRupiah(total)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF145A00),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _addToCart(item, qty, note.isEmpty ? null : note);

                          // Setelah menambah pesanan ke keranjang, simpan ke HistoryProvider
                          Map<String, String> newOrder = {
                            'image': item['image'] ?? '',
                            'title': item['name'] ?? '',
                            'subtitle': 'Pesanan • ${DateTime.now().toLocal()}',
                            'price': item['price'] ?? '',
                          };

                          // Menambahkan pesanan ke HistoryProvider
                          Provider.of<HistoryProvider>(context, listen: false)
                              .addHistory(newOrder);

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${item['name']} x$qty ditambahkan ke pesanan')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF145A00),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Tambah',
                          style:
                              TextStyle(color: Colors.white), // ⬅️ teks putih
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _parsePriceToInt(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  String _formatRupiah(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      c++;
      if (c % 3 == 0 && i != 0) buf.write('.');
    }
    return 'Rp.${buf.toString().split('').reversed.join()}';
  }

  // ===== Cart state =====
  final List<CartItem> _cart = [];

  int get _cartCount => _cart.fold<int>(0, (sum, e) => sum + e.qty);

  void _addToCart(Map<String, String> item, int qty, String? note) {
    final name = item['name'] ?? '';
    final image = item['image'] ?? '';
    final price = _parsePriceToInt(item['price'] ?? '0');

    // Gabungkan item yang sama (name + note)
    final i = _cart
        .indexWhere((e) => e.name == name && (e.note ?? '') == (note ?? ''));
    if (i >= 0) {
      _cart[i].qty += qty;
    } else {
      _cart.add(CartItem(
          name: name, image: image, unitPrice: price, qty: qty, note: note));
    }

    setState(() {}); // refresh badge/count
  }

  int get _cartTotal => _cart.fold<int>(0, (sum, e) => sum + e.lineTotal);

  String selectedTableName = '';
  String selectedTableImage = '';
  String selectedTableCapacity = '';

  void _openCheckout() async {
    print(
        "Selected Table Data di MenuCustomerPage: $selectedTableName, $selectedTableImage, $selectedTableCapacity");

    if (tables.isNotEmpty) {
      selectedTableName = tables[0]['meja'] ?? 'Meja belum dipilih';
      selectedTableImage =
          tables[0]['meja_image'] ?? ''; // Default jika tidak ada
      selectedTableCapacity =
          tables[0]['jumlah_orang'] ?? '0'; // Default jika tidak ada
    }

    final ok = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cart: _cart, // Cart items
          formatRupiah: _formatRupiah,
          onCartChanged: () => setState(() {}),
          bookingDetails: {
            'meja': selectedTableName, // Nama meja
            'meja_image': selectedTableImage, // Gambar meja
            'jumlah_orang': selectedTableCapacity, // Kapasitas meja
          },
        ),
      ),
    );
    if (ok == true) {
      _cart.clear();
      setState(() {});
    }
  }

// Tombol cart + badge di AppBar
  Widget _cartAction() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined,
              color: Color(0xFF145A00)),
          onPressed: _openCheckout,
        ),
        if (_cartCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_cartCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  String selectedCategory = "Food";

  // ✅ Tag subkategori untuk Food
  final List<String> foodTags = const [
    "Sundanese Food",
    "Japanese Food",
    "Nusantara Food",
    "Western Food",
  ];
  String selectedFoodTag = "Sundanese Food"; // default terpilih

  // ✅ Tag subkategori untuk Drink
  final List<String> drinkTags = const [
    "Squash",
    "Mojito",
    "Smoothies",
    "Juice",
    "Yakult",
    "Tea",
    "Non Coffeee",
    "Blend",
    "Milkshake",
    "Hot Drink",
    "Basic Coffeee",
    "Signature Coffeee",
    "Coffeee Fushion",
  ];
  String selectedDrinkTag = "Squash"; // default terpilih

  // ✅ Data khusus untuk subkategori Sundanese Food (ditambah Paket Nasi Liwet)
  final List<Map<String, String>> sundaneseMenu = [
    {
      "image":
          "https://ucarecdn.com/e84d411b-b0de-4338-b201-895749538d7b/supiga.jpg",
      "name": "Sup Iga",
      "price": "Rp.35.000"
    },
    {
      "image":
          "https://ucarecdn.com/d71a1ed7-2a97-42f0-b30c-b00fb0d4b988/supayam.jpg",
      "name": "Sup Ayam",
      "price": "Rp.25.000"
    },
    {
      "image":
          "https://ucarecdn.com/6fcfe6f1-1c46-4237-9caa-695ec282b9f2/SupSapi.jpg",
      "name": "Sup Sapi",
      "price": "Rp.30.000"
    },
    {
      "image":
          "https://ucarecdn.com/a01e917b-970f-453b-a8e3-fd9b26da678a/SupIkanNilaAsamPedas.jpg",
      "name": "Sup Ikan Nila Asam Pedas",
      "price": "Rp.40.000"
    },
    {
      "image":
          "https://ucarecdn.com/73aeebb4-eaa8-446c-9754-89203fab1b0a/SupIkanGurameAsamPedas.jpg",
      "name": "Sup Ikan Gurame Asam Pedas",
      "price": "Rp.45.000"
    },
    {
      "image":
          "https://ucarecdn.com/663cc80d-7919-4718-9c72-b12394b3975c/AyamGoreng.jpg",
      "name": "Ayam Goreng",
      "price": "Rp.25.000"
    },
    {
      "image":
          "https://ucarecdn.com/4a056dc0-3038-467c-b878-25d38e321076/AyamBakar.jpg",
      "name": "Ayam Bakar",
      "price": "Rp.28.000"
    },
    {
      "image":
          "https://ucarecdn.com/ce2328c0-b1c2-4645-bbb6-222dfb00ba69/AyamKremes.jpg",
      "name": "Ayam Kremes",
      "price": "Rp.27.000"
    },
    {
      "image":
          "https://ucarecdn.com/d97b8147-cac2-4e2b-90b6-a77af7b0cc6a/AyamGeprek.jpg",
      "name": "Ayam Geprek",
      "price": "Rp.23.000"
    },
    {
      "image":
          "https://ucarecdn.com/1b91b140-a8a0-4108-9c4f-d18dc181989b/NasiTimbel.jpg",
      "name": "Nasi Timbel",
      "price": "Rp.30.000"
    },
    {
      "image":
          "https://ucarecdn.com/13fbc270-66a7-4222-8822-b4f6bcca1c5a/AyamCrispy.jpg",
      "name": "Ayam Crispy",
      "price": "Rp.25.000"
    },
    {
      "image":
          "https://ucarecdn.com/8f9f2870-01b2-4602-80aa-1e8c901b9831/NasiBakar.jpg",
      "name": "Nasi Bakar",
      "price": "Rp.28.000"
    },
    {
      "image":
          "https://ucarecdn.com/b39641d6-b16d-4361-b038-de86b5cf1cd7/IkanNila.jpg",
      "name": "Ikan Nila",
      "price": "Rp.40.000"
    },
    {
      "image":
          "https://ucarecdn.com/bc455fea-389c-49b5-93d4-1c9595249475/IkanGurame.jpg",
      "name": "Ikan Gurame",
      "price": "Rp.45.000"
    },

    // ✅ Paket Nasi Liwet (ditambahkan di Sundanese Food)
    {
      "image":
          "https://ucarecdn.com/489a1db7-15ee-420d-b991-6a0a92265f0d/PaketNasiLiwetAyam.jpg",
      "name": "Paket Nasi Liwet Personal",
      "price": "Rp.55.000"
    },
    {
      "image":
          "https://ucarecdn.com/489a1db7-15ee-420d-b991-6a0a92265f0d/PaketNasiLiwetAyam.jpg",
      "name": "Paket Nasi Liwet 2 Orang",
      "price": "Rp.60.000"
    },
    {
      "image":
          "https://ucarecdn.com/489a1db7-15ee-420d-b991-6a0a92265f0d/PaketNasiLiwetAyam.jpg",
      "name": "Paket Nasi Liwet 4 Orang",
      "price": "Rp.65.000"
    },
    {
      "image":
          "https://ucarecdn.com/b8a9f05a-c4b5-43c3-87e3-ab0aa8918a05/BakmieOriginal.jpg",
      "name": "Bakmie Original",
      "price": "Rp.75.000"
    },
    {
      "image":
          "https://ucarecdn.com/f9461c6a-7e82-4f26-9cc5-b6dee76207f0/BakmieMercon.jpg",
      "name": "Bakmie Mercon",
      "price": "Rp.75.000"
    },
    {
      "image":
          "https://ucarecdn.com/6d69d6b5-1bb7-4028-84fe-6a9b452cbcc6/BakmieSpecial.jpg",
      "name": "Bakmie Special",
      "price": "Rp.75.000"
    },
  ];

  // ✅ Data khusus untuk subkategori Japanese Food
  final List<Map<String, String>> japaneseMenu = [
    {
      "image":
          "https://ucarecdn.com/b09fc525-099c-4ee4-8bb7-cdcb93bf270a/RamenSpicy.jpg",
      "name": "Ramen Spicy",
      "price": "Rp.30.000"
    },
    {
      "image":
          "https://ucarecdn.com/ad00b71c-e3ec-4430-a186-e71db9e10ebe/RamenMiso.jpg",
      "name": "Ramen Miso",
      "price": "Rp.32.000"
    },
    {
      "image":
          "https://ucarecdn.com/c443b13d-8ebf-48e3-acb9-746d8ae69123/RamenTomyum.jpg",
      "name": "Ramen Tomyum",
      "price": "Rp.35.000"
    },
    {
      "image":
          "https://ucarecdn.com/beac078a-eaf2-4f27-a663-d78bbb18d240/RamenKare.jpg",
      "name": "Ramen Kare",
      "price": "Rp.33.000"
    },
    {
      "image":
          "https://ucarecdn.com/997afe5e-b515-4dcc-9bbe-a4e29e3016d3/RamenSoyu.jpg",
      "name": "Ramen Soyu",
      "price": "Rp.31.000"
    },
    {
      "image":
          "https://ucarecdn.com/e37af574-4f7d-472a-a668-c4fb8f3e1427/RamenCheese.jpg",
      "name": "Ramen Cheese",
      "price": "Rp.34.000"
    },
    {
      "image":
          "https://ucarecdn.com/29246d8e-bf76-41e5-92d3-e7210e08266e/RamenSpicyTantan.jpg",
      "name": "Ramen Spicy Tantan",
      "price": "Rp.36.000"
    },
    {
      "image":
          "https://ucarecdn.com/42075946-b37a-42fb-aac7-5e4c6359cd7a/RamenToriPaitan.jpg",
      "name": "Ramen Tori Paitan",
      "price": "Rp.37.000"
    },
    {
      "image":
          "https://ucarecdn.com/941f6138-774d-4e6a-8e0b-7e721efd1c14/SpecialRamen.jpg",
      "name": "Special Ramen",
      "price": "Rp.40.000"
    },
    {
      "image":
          "https://ucarecdn.com/153f7baa-642d-43a7-a1ec-afc123ff893b/BentoBox.jpg",
      "name": "Bento Box",
      "price": "Rp.45.000"
    },
    {
      "image":
          "https://ucarecdn.com/5eff6925-a2d8-4a83-b3f9-193eeb2355b8/DonburiRiceBowl.jpg",
      "name": "Donburi Rice Bowl",
      "price": "Rp.38.000"
    },
  ];

  // ✅ Data khusus untuk subkategori Nusantara Food
  final List<Map<String, String>> nusantaraMenu = [
    {
      "image":
          "https://ucarecdn.com/111867db-49e8-4702-937d-d0a1e8d81267/NasiGorengOriginal.jpg",
      "name": "Nasi Goreng Original",
      "price": "Rp.25.000"
    },
    {
      "image":
          "https://ucarecdn.com/9291d09c-c5aa-4432-aa8b-0f1012861c29/NasiGorengSeafood.jpg",
      "name": "Nasi Goreng Seafood",
      "price": "Rp.28.000"
    },
    {
      "image":
          "https://ucarecdn.com/fcb02e4b-7f2b-4899-898f-d147ebd7a79e/NasiGorengSpecial.jpg",
      "name": "Nasi Goreng Special",
      "price": "Rp.30.000"
    },
    {
      "image":
          "https://ucarecdn.com/ccdd830d-7455-413e-9ed6-5aba1e69ce1d/SotoLamongan.jpg",
      "name": "Soto Lamongan",
      "price": "Rp.25.000"
    },
    {
      "image":
          "https://ucarecdn.com/df0686df-4b00-49e4-98f0-095c5f505a05/SotoBetawi.jpg",
      "name": "Soto Betawi",
      "price": "Rp.27.000"
    },
    {
      "image":
          "https://ucarecdn.com/7543fafa-2868-4f07-a617-c6392d1cd5ed/Rawon.jpg",
      "name": "Rawon",
      "price": "Rp.32.000"
    },
    {
      "image":
          "https://ucarecdn.com/8da647d1-1eab-411d-97be-19d42c05334a/SateMaranggi.jpg",
      "name": "Sate Maranggi",
      "price": "Rp.35.000"
    },
  ];

  // ✅ Data khusus untuk subkategori Western Food
  final List<Map<String, String>> westernMenu = [
    {
      "image":
          "https://ucarecdn.com/436cb1c1-d95c-4001-a0ae-bebb1e11b025/PastaBolognes.jpg",
      "name": "Pasta Bolognes",
      "price": "Rp.35.000"
    },
    {
      "image":
          "https://ucarecdn.com/6219f849-4c50-47ce-8881-72f6508e1f15/PastaCarbonara.jpg",
      "name": "Pasta Carbonara",
      "price": "Rp.36.000"
    },
    {
      "image":
          "https://ucarecdn.com/de772841-6836-405c-964e-7e4fbe686305/PastaCheeseFondue.jpg",
      "name": "Pasta Cheese Fondue",
      "price": "Rp.38.000"
    },
    {
      "image":
          "https://ucarecdn.com/25649723-d55f-4ec3-ac5c-9526e7a2e14c/UdangAgliOlioSpicy.jpg",
      "name": "Udang Agli Olio Spicy",
      "price": "Rp.42.000"
    },
    {
      "image":
          "https://ucarecdn.com/a1f0621e-e153-4416-919e-020ff1fc7b32/CumiTeriyaki.webp",
      "name": "Cumi Teriyaki",
      "price": "Rp.40.000"
    },
    {
      "image":
          "https://ucarecdn.com/69f467bd-fd09-4835-9a1f-60a379d77ada/CumiBolognese.jpg",
      "name": "Cumi Bolognese",
      "price": "Rp.40.000"
    },
    {
      "image":
          "https://ucarecdn.com/1896e780-a2cc-4bcb-b147-46cf2093bbdc/CumiLadaHitam.jpg",
      "name": "Cumi Lada Hitam",
      "price": "Rp.40.000"
    },
    {
      "image":
          "https://ucarecdn.com/04255814-2aa8-4064-9ef5-9c4e4b471e06/CumiAsamManis.jpg",
      "name": "Cumi Asam Manis",
      "price": "Rp.40.000"
    },
    {
      "image":
          "https://ucarecdn.com/322eebff-a296-47f1-ae49-080cb9458617/UdangTeriyaki.jpg",
      "name": "Udang Teriyaki",
      "price": "Rp.42.000"
    },
    {
      "image":
          "https://ucarecdn.com/0cdf3139-fb05-4216-9476-0bb12c06ec71/UdangBolognese.jpg",
      "name": "Udang Bolognese",
      "price": "Rp.42.000"
    },
    {
      "image":
          "https://ucarecdn.com/70944e0e-43df-4a24-bffa-c34fcbae591b/UdangLadaHitam.jpg",
      "name": "Udang Lada Hitam",
      "price": "Rp.42.000"
    },
    {
      "image":
          "https://ucarecdn.com/8f2292dc-7837-47c0-ae51-39e2174b0c8e/UdangAsamManis.jpg",
      "name": "Udang Asam Manis",
      "price": "Rp.42.000"
    },
  ];

  // ✅ Updated data for Squash drinks
  final List<Map<String, String>> squashDrinks = [
    {
      "image":
          "https://ucarecdn.com/e07d2f3a-277d-4aa0-a804-d5d7b4b12630/DRAGONFRUITLEMONADE.jpg", // Add the correct image URL
      "name": "Dragon Fruit Lemonade",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/5a6be3f4-e1c2-486a-8b79-fada1468f5bc/ORANGESQUASH.jpg", // Add the correct image URL
      "name": "Orange Squash",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/d814361c-24ae-4a24-80cb-185d0389bfd9/MANGOSQUASH.jpg", // Add the correct image URL
      "name": "Mango Squash",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/4bb9ba99-8f3e-4c39-9379-9c78c14ef706/STRAWBERRYSQUASH.jpg", // Add the correct image URL
      "name": "Strawberry Squash",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/ed9f003c-e6a0-4500-9ce5-bff094089c71/GRAPESQUASH.jpg", // Add the correct image URL
      "name": "Grape Squash",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/690ae8ab-b6f9-4219-bfd2-62b4adb2d423/MELONSQUASH.jpg", // Add the correct image URL
      "name": "Melon Squash",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/54bb9cdb-59a8-4e24-a6ce-6dad102d9c81/LEMONSQUASH.jpg", // Add the correct image URL
      "name": "Lemon Squash",
      "price": "Rp.11.000"
    },
  ];

  final List<Map<String, String>> mojitoDrinks = [
    {
      "image":
          "https://ucarecdn.com/9794e6cb-57a8-4632-8e11-cc41b096f9b1/ORANGEMOJITO.jpg", // Add the correct image URL
      "name": "Orange Mojito",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/f5712663-79c0-4345-86ac-cd316fd2d2f0/MELONMOJITO.jpg", // Add the correct image URL
      "name": "Melon Mojito",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/7c97574e-aad4-4e17-95cf-6d56c719c3b1/STRAWBERRYMOJITO.jpg", // Add the correct image URL
      "name": "Strawberry Mojito",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/47a269c3-1d30-4500-a6a3-52c808bf241b/BLUESEAMOJITO.jpg", // Add the correct image URL
      "name": "Blue Sea Mojito",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/7bb9ec35-7928-45d1-90b5-4b78957ad508/GRAPEMOJITO.jpg", // Add the correct image URL
      "name": "Grape Mojito",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/2a632c3a-ea89-4198-9b99-4278d14952b1/VIRGINMOJITO.jpg", // Add the correct image URL
      "name": "Virgin Mojito",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/f2842524-75a3-4360-b287-657b6c925922/LYCHEEMOJITO.jpg", // Add the correct image URL
      "name": "Lychee Mojito",
      "price": "Rp.11.000"
    },
  ];

  final List<Map<String, String>> smoothiesDrinks = [
    {
      "image":
          "https://ucarecdn.com/72315a10-043d-442f-b390-a0d43a88b479/STRAWBERRYSMOOTHIES.jpg", // Add the correct image URL
      "name": "Strawberry Smoothies",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/8e182163-9b02-40fc-9c17-9736c0723723/GRAPESMOOTHIES.jpg", // Add the correct image URL
      "name": "Grape Smoothies",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/d111c948-1ba7-4153-b5ef-4957d4e63a9c/DRAGONSMOOTHIES.jpg", // Add the correct image URL
      "name": "Dragon Smoothies",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/584263bc-b1ce-459f-ad8e-75691d2c25cd/MELONSMOOTHIES.jpg", // Add the correct image URL
      "name": "Melon Smoothies",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/13c79c6b-fe0e-437c-948e-4b50b688128c/MANGOSMOOTHIES.jpg", // Add the correct image URL
      "name": "Mango Smoothies",
      "price": "Rp.13.000"
    },
  ];

  final List<Map<String, String>> juiceDrinks = [
    {
      "image":
          "https://ucarecdn.com/545b7951-2e75-4e2f-9294-101285d5eb23/MANGOJUICE.jpg", // Add the correct image URL
      "name": "Mango Juice",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/9c713de3-0f62-46df-8d2a-a7dc5e34e3a9/LEMONJUICE.jpg", // Add the correct image URL
      "name": "Lemon Juice",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/f3487b9b-96d7-4825-a6fa-5e71a6253e97/GRAPEJUICE.jpg", // Add the correct image URL
      "name": "Grape Juice",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/4ec86ec5-66c4-4d31-b550-82342edf2f0c/MELONJUICE.jpg", // Add the correct image URL
      "name": "Melon Juice",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/32516056-6d40-4925-a808-e1a6670ccccd/DRAGONFRUITJUICE.jpg", // Add the correct image URL
      "name": "Dragon Fruit Juice",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/03864d2d-d057-441b-a031-2d8b3840d2a7/STRAWBERRYJUICE.jpg", // Add the correct image URL
      "name": "Stawberry Juice",
      "price": "Rp.12.000"
    },
  ];

  final List<Map<String, String>> yakultDrinks = [
    {
      "image":
          "https://ucarecdn.com/89ac4a17-d845-4bb7-9509-7a96680bf4fb/ORANGEYAKULT.jpg", // Add the correct image URL
      "name": "Orange Yakult",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/f70ff95b-5355-4f42-ab83-75a29311d681/TAROYAKULT.jpg", // Add the correct image URL
      "name": "Taro Yakult",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/545bd6fe-a1ae-4e16-b0a2-1140fdbc0098/LYCHEEYAKULT.jpg", // Add the correct image URL
      "name": "Lychee Yakult",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/41d23829-1d82-4c60-a73c-af56c2f29161/MANGOYAKULT.jpg", // Add the correct image URL
      "name": "Mango Yakult",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/37ad7467-b035-4a7e-900f-b95effeea7b1/GRAPEYAKULT.jpg", // Add the correct image URL
      "name": "Grape Yakult",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/503a19b0-48d1-4ee4-a2bf-33abebbaa8f1/STRAWBERRYYAKULT.jpg", // Add the correct image URL
      "name": "Strawberry Yakult",
      "price": "Rp.12.000"
    },
  ];

  final List<Map<String, String>> teaDrinks = [
    {
      "image":
          "https://ucarecdn.com/f0b318b8-c7e1-4db9-81d8-eb1bdc2e18cd/MINTTEA.jpg", // Add the correct image URL
      "name": "Mint Tea",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/10a38f78-7191-45cd-99b0-8f6297e6e438/TEA.jpg", // Add the correct image URL
      "name": "Tea",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/b221845c-d159-4692-9727-3189e1739bec/TEHTARIK.jpg", // Add the correct image URL
      "name": "Teh Tarik",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/c1d20f5b-b0db-461f-b6d9-15a23d07e996/GREENTEA.jpg", // Add the correct image URL
      "name": "Green Tea",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/5e667981-babf-4eb5-82fc-b4d894fd40b4/LEMONTEA.jpg", // Add the correct image URL
      "name": "lemon Tea",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/0b0958be-20ea-4f6e-97bb-2df91275499e/SWEETTEA.jpg", // Add the correct image URL
      "name": "Sweet Tea",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/8a43009a-4ad4-4da8-bf06-74fc0dafea39/MELONTEA.jpg", // Add the correct image URL
      "name": "Melon Tea",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/45786a91-d98f-4b03-af28-694af469fa5b/PANDANTEA.jpg", // Add the correct image URL
      "name": "Pandan Tea",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/a52a5e60-9e17-4484-b28d-b5cfe027af02/THAITEA.jpg", // Add the correct image URL
      "name": "Thai Tea",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/4ae4d89d-bbcd-4d14-8be9-cefbbb637882/LYCHEETEA.jpg", // Add the correct image URL
      "name": "Lychee Tea",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/b652394b-8256-43cc-9a80-448140225800/PAKETTEHTUBRUK.jpg", // Add the correct image URL
      "name": "Paket Teh Tubruk",
      "price": "Rp.11.000"
    },
  ];

  final List<Map<String, String>> nonCoffeeeDrinks = [
    {
      "image":
          "https://ucarecdn.com/43d320f7-f5cb-44ee-a0f5-af124486f0d0/ICEJERUK.jpg", // Add the correct image URL
      "name": "Ice Jeruk",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/49a1220d-9fa7-4983-912d-571bb545ec7c/TAROLATTE.jpg", // Add the correct image URL
      "name": "Taro Latte",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/c76e2600-3e41-4f08-9c19-ae1c3772b1f3/MATCHALATTE.jpg", // Add the correct image URL
      "name": "Matcha Latte",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/b3902e1c-4bbb-4d2d-98a2-eeef51675ced/CHOCOALMOND.jpg", // Add the correct image URL
      "name": "Choco Almond",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/c1a5d888-b8c1-4290-a9b5-25f12056a1fa/REDVELVET.jpg", // Add the correct image URL
      "name": "Red Velvet",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/0817e533-6e7a-47cb-b9da-48035c704b33/AVOCADOLATTE.jpg", // Add the correct image URL
      "name": "Avocado Latte",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/5e6c2807-f5e8-49f2-856f-07e47afec7f4/CHOCOVANILLA.jpg", // Add the correct image URL
      "name": "Choco Vanilla",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/fc7e6c4b-5b03-482e-a567-0c84b033790f/TIRAMISULATTE.jpg", // Add the correct image URL
      "name": "Tiramisu Latte",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/3517c2be-67ed-44b8-b646-d9138abe2c2c/CHOCOCARAMEL.jpg", // Add the correct image URL
      "name": "Choco Caramel",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/bf48daf9-5bb1-4f6b-913a-2e68ad660860/CHOCOHAZELNUT.jpg", // Add the correct image URL
      "name": "Choco Hazelnut",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/ebd58b72-8095-4766-8a87-c7a27220e4cd/CHOCOLATE.jpg", // Add the correct image URL
      "name": "Chocolate",
      "price": "Rp.11.000"
    },
  ];

  final List<Map<String, String>> blendDrinks = [
    {
      "image":
          "https://ucarecdn.com/47e16953-eafe-4ffb-8444-9e4b324931fa/TAROBLEND.jpg", // Add the correct image URL
      "name": "Taro Blend",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/4a93c774-86ad-4dd0-ab42-96d72a27ba25/REDVELVETBLEND.jpg", // Add the correct image URL
      "name": "Red Velvet Blend",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/7389b298-7525-4954-aedf-5b5358a85944/TIRAMISUBLEND.jpg", // Add the correct image URL
      "name": "Tiramisu Blend",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/bfd59599-9456-4dd5-82cd-4a66c4e09b91/CHOCOAVOCADO.jpg", // Add the correct image URL
      "name": "Choco Avocado",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/aec8b823-53cd-4d77-9182-f772d0a9a1a9/VANILLAOREO.jpg", // Add the correct image URL
      "name": "Vanilla Oreo",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/54291114-8361-41ff-9820-c3fc3d1d4d09/CHOCOHAZELNUTBLAND.jpg", // Add the correct image URL
      "name": "Choco Hazelnut Bland",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/2226059f-0535-46b5-951b-e06dfa130560/CHOCOBLEND.jpg", // Add the correct image URL
      "name": "Choco Blend",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/70710f08-e655-495d-b25c-a74a578cd331/MACHABLEND.jpg", // Add the correct image URL
      "name": "Macha Blend",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/d85b6fbe-49b3-4904-9737-bbc5ae922c9e/COOKIESCREAM.jpg", // Add the correct image URL
      "name": "Cookies Cream",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/03cb4dab-9c1a-4b92-9326-061d341fd196/CHOCOOREO.jpg", // Add the correct image URL
      "name": "Choco Oreo",
      "price": "Rp.11.000"
    },
  ];

  final List<Map<String, String>> milkshakeDrinks = [
    {
      "image":
          "https://ucarecdn.com/0a0084f1-c1d9-473c-bafc-a7f937a0cb9e/STRAWBERRYMILKSHAKE.jpg", // Add the correct image URL
      "name": "Strawberry Milkshake",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/3c138652-c2d5-4747-881d-35a30bb654b5/VANILLAMILKSHAKE.jpg", // Add the correct image URL
      "name": "Vanilla Milkshake",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/59b6a764-9f37-480b-bd25-9dedfd171f55/CHOCOMILKSHAKE.jpg", // Add the correct image URL
      "name": "Choco Milkshake",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/0ab88398-600d-46cf-bdf6-f7802b116cd7/DRAGONFRUITMILKSHAKE.jpg", // Add the correct image URL
      "name": "Dragon Fruit Milkshake",
      "price": "Rp.14.000"
    },
  ];

  final List<Map<String, String>> hotDrinks = [
    {
      "image":
          "https://ucarecdn.com/92f98c8e-7c23-4723-9212-5c0ed3bd0a41/BANDREK.jpg", // Add the correct image URL
      "name": "Bandrek",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/fd2d50a5-505f-4994-818a-77984ecd0e7c/SUSUJAHE.jpg", // Add the correct image URL
      "name": "Susu Jahe",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/187af321-a5dd-4502-be5a-c323da946056/BAJIGUR.jpg", // Add the correct image URL
      "name": "Bajigur",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/9fe1b178-f192-4d48-bb2d-9a5ae03ca266/BANDREKSUSU.jpg", // Add the correct image URL
      "name": "Bandrek Susu",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/d3d798d8-b09f-4b38-94ed-0f38f6b673b0/JERUKPANAS.jpg", // Add the correct image URL
      "name": "Jeruk Panas",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/4e746f2e-02c0-4a86-956c-b869fb188eb1/WEDANGJAHE.jpg", // Add the correct image URL
      "name": "Wedang Jahe",
      "price": "Rp.12.000"
    },
  ];

  final List<Map<String, String>> basicCoffeeeDrinks = [
    {
      "image":
          "https://ucarecdn.com/4ea1d4e1-fa09-489d-bce3-e923a3f41340/CARAMELLATTE.jpg", // Add the correct image URL
      "name": "Caramel Latte",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/4c22680b-d7d5-4514-8a99-9168ffad96c2/ALMONDCOFFEELATTE.jpg", // Add the correct image URL
      "name": "Almond Coffee Latte",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/86f39a46-c44d-4c0d-a488-58b72a28d583/CAPPUCINO.jpg", // Add the correct image URL
      "name": "Cappucino",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/f2db060a-0f41-49a8-bfc8-1fde9639101f/ESPRESSO.jpg", // Add the correct image URL
      "name": "Espresso",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/60e3523f-97eb-4cb7-be40-0a48f367a6fe/HAZELNUTCOFFELATTE.jpg", // Add the correct image URL
      "name": "Hazelnut Coffee Latte",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/957dcb48-ffa2-44a9-8033-1a90f857827f/AMERICANO.jpg", // Add the correct image URL
      "name": "Americano",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/90ff3a1e-5080-435b-9b3e-6c1c05417e78/LONGBLACKCOFFEE.jpg", // Add the correct image URL
      "name": "Long Black Coffee",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/cb6bb32e-6dbd-4b2e-98a6-ffaf8af24510/MOCHACINO.jpg", // Add the correct image URL
      "name": "Mochacino",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/e3e82e72-4cad-479d-ae28-89aa47ce5433/CAFELATTE.jpg", // Add the correct image URL
      "name": "Cafe Latte",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/5c74896d-3f7a-468d-83bb-41237dbab51b/VANILLACOFFELATTE.jpg", // Add the correct image URL
      "name": "Vanilla Coffee Latte",
      "price": "Rp.11.000"
    },
    {
      "image":
          "https://ucarecdn.com/6ff13269-0328-4dca-917d-48aaeba88a65/MACCHIATO.jpg", // Add the correct image URL
      "name": "Macchiato",
      "price": "Rp.11.000"
    },
  ];

  final List<Map<String, String>> signatureCoffeeeDrinks = [
    {
      "image":
          "https://ucarecdn.com/b455d367-b713-4f9d-9607-2cb5db8fbbe7/ESKOPISUSU.jpg", // Add the correct image URL
      "name": "Es Kopi Susu",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/6bb06844-983c-4850-bff2-8ee8f63f5c09/ESKOPIPANDAN.jpg", // Add the correct image URL
      "name": "Es Kopi Pandan",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/633b6e56-6836-467d-8059-17c99ef7abf3/AFFOGATO.jpg", // Add the correct image URL
      "name": "Affogato",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/cd26270a-50be-4075-b8b2-abeeb50058e9/ESKOPIGULAAREN.jpg", // Add the correct image URL
      "name": "Es Kopi Gula Aren",
      "price": "Rp.14.000"
    }
  ];

  final List<Map<String, String>> coffeeeFushionDrinks = [
    {
      "image":
          "https://ucarecdn.com/6b8edf31-10ee-4362-825f-a493397acb57/TIRAMISUCOFFE.jpg", // Add the correct image URL
      "name": "Tiramisu Coffee",
      "price": "Rp.15.000"
    },
    {
      "image":
          "https://ucarecdn.com/a6e3f877-4979-456c-8f3b-51bab4a90c66/REDVELVETCOFFE.jpg", // Add the correct image URL
      "name": "Red Velvet Coffee",
      "price": "Rp.12.000"
    },
    {
      "image":
          "https://ucarecdn.com/66a754a9-a682-41c0-8bbd-809eddf851aa/AVOCADOCOFFE.jpg", // Add the correct image URL
      "name": "Avocado Coffee",
      "price": "Rp.13.000"
    },
    {
      "image":
          "https://ucarecdn.com/f68481a4-b2d8-4208-98af-3b9e79c3055d/TAROCOFFEE.jpg", // Add the correct image URL
      "name": "Taro Coffee",
      "price": "Rp.14.000"
    },
    {
      "image":
          "https://ucarecdn.com/bd76a5cf-23b2-43c4-9fff-54bbd690c6cc/MATCHACOFFEE.jpg", // Add the correct image URL
      "name": "Matcha Coffee",
      "price": "Rp.13.000"
    },
  ];

  // Data dummy untuk setiap kategori (default)
  final Map<String, List<Map<String, String>>> menuData = {
    "Light Meal": [
      {
        "image":
            "https://ucarecdn.com/3bcbfa56-7502-405b-a0d5-6110338ef17e/ROTIBAKARSTRAWBERRYSUSU.webp",
        "name": "Roti Bakar Strawberry Susu",
        "price": "Rp.10.000"
      },
      {
        "image":
            "https://ucarecdn.com/db29e6b7-3aab-49fe-b42c-d85cd6d2c60f/ROTIBAKARSUSUKEJU.jpg",
        "name": "Roti Bakar Susu Keju",
        "price": "Rp.15.000"
      },
      {
        "image":
            "https://ucarecdn.com/3e3b7434-f5bc-4a4d-9a66-a7693eaf30ae/PISANGBAKARSUSUKEJU.jpg",
        "name": "Pisang Bakar Susu Keju",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/71ec9ecd-151d-4df5-8ceb-e556b9b23bef/PISANGGORENGORIGINAL.jpg",
        "name": "Pisang Goreng Original",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/9f0385ea-4815-4bd1-96f9-327472f8e105/SOSISBAKAR.jpg",
        "name": "Sosis Bakar",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/cdfb0ca1-c92d-4082-8480-1242f20c9313/ROTIBAKARCOKLATKEJU.jpg",
        "name": "Roti Bakar Coklat Keju",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/19a2295b-44dc-4924-9b59-70c836d30ba3/POTATOWEDGES.jpg",
        "name": "Potato Wedges",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/33789aaa-607e-46dd-937d-57216d0553bf/TAHUWALIK.jpg",
        "name": "Tahu Walik",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/a30cf3e0-b808-4292-8b4a-b36df029682c/SPICYWINGSFRIES.jpgg",
        "name": "Spicy Wings & Fries",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/0da84a07-6ca8-4656-9c23-ab55552b99fe/SAUSAGEFRIES.jpg",
        "name": "Sausage & Fries",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/cdb2350d-5e0d-4672-ade7-56b484321769/TEMPEMENDOAN.jpg",
        "name": "Tempe Mendoan",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/466cb069-4663-4306-9b67-df5fc4c30dbe/JAGUNGSAUSKEJU.jpg",
        "name": "Jagung Saus Keju",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/0646a88d-593b-463a-a634-34006e42e9a7/FISHROLLBAKAR.jpeg",
        "name": "Fishrol Bakar",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/eb558737-3fae-4218-a76a-96ffe1bc40e8/BANANACINNAMONROLL.jpg",
        "name": "Banana Cinamon Roll",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/6e1b2f8a-3581-4aab-a66d-73da40353d21/CIRENGRUJAK.jpg",
        "name": "Cireng Rujak",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/9f773749-154a-4624-a44a-74fd579cfafe/BALABALA.jpg",
        "name": "Bala Bala",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/d3376cf6-0d08-424e-86dc-dd0399279d23/CRISPYBANANA.jpg",
        "name": "Crispy Banana",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/65720f4d-e0b2-45b5-8b51-98d235be6bb8/COLENAK.jpg",
        "name": "Colenak",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/76f6bd58-9c6f-41a7-bdfb-be6ae1a716d0/FRENCHFRIESMOZARELLA.jpg",
        "name": "French Fries Mozarella",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/745161d4-c382-44b2-80eb-afcc9ad9cc69/FIREWINGS.jpg",
        "name": "FIre Wings",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/93cffe2f-dec3-4377-ab38-e698b8152860/FRENCHFRIES.jpg",
        "name": "French Fries",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/bb0148c6-29a1-4784-880f-0a969f969264/GIYOZAMENTAI.jpg",
        "name": "Giyoza Mentai",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/66fae4d9-6ecd-4dee-b6a0-52d59c6f85b1/MIXPLATER.jpg",
        "name": "Mix Plater",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/c451c6fb-acff-442e-a54a-d84c68ed78db/PISANGBAKARCOKLATKEJU.jpg",
        "name": "Pisang Bakar Coklat Keju",
        "price": "Rp.8.000"
      },
      {
        "image":
            "https://ucarecdn.com/74904ba9-c180-4fdd-a0f8-af5678dd3fa2/GIYOZA.jpg",
        "name": "Giyoza",
        "price": "Rp.8.000"
      },
    ],
  };

  List<Map<String, String>> tables = [
    {
      'meja': 'Meja 1 (Indoor)',
      'meja_image':
          'https://ucarecdn.com/2e42c152-e688-4bea-8350-f10843b4a66b/MejaIndoor2Orang.jpg',
      'jumlah_orang': '2',
    },
    {
      'meja': 'Meja 2 (Indoor)',
      'meja_image':
          'https://ucarecdn.com/c05d48e9-607d-4c69-b959-01050f819bcb/MejaIndoor4Orang.jpg',
      'jumlah_orang': '4',
    },
    {
      'meja': 'Meja 1 (Outdoor)',
      'meja_image':
          'https://ucarecdn.com/6220fd18-dfea-4d40-84af-13dd485b590e/MejaOutdoor2Orang.jpg',
      'jumlah_orang': '2',
    },
    {
      'meja': 'Meja 2 (Outdoor)',
      'meja_image':
          'https://ucarecdn.com/ff9a3d7a-42e2-4a31-880d-7fe1cbd9017d/MejaOutdoor4Orang.jpg',
      'jumlah_orang': '4',
    },
    {
      'meja': 'Gazebo (Outdoor)',
      'meja_image':
          'https://ucarecdn.com/7a409914-c9da-454c-bc8e-60aac1d47a04/GajeboOutdoor4Orang.jpg',
      'jumlah_orang': '4',
    },
    {
      'meja': 'VIP Room (Indoor)',
      'meja_image':
          'https://ucarecdn.com/0a220c03-744a-4474-8fe3-e91c93d03bbf/MejaVIP.jpg',
      'jumlah_orang': '10',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ Pilih sumber data list berdasarkan kategori & tag
    List<Map<String, String>> menuItems;
    if (selectedCategory == "Food" && selectedFoodTag == "Sundanese Food") {
      menuItems = sundaneseMenu;
    } else if (selectedCategory == "Food" &&
        selectedFoodTag == "Japanese Food") {
      menuItems = japaneseMenu;
    } else if (selectedCategory == "Food" &&
        selectedFoodTag == "Nusantara Food") {
      menuItems = nusantaraMenu;
    } else if (selectedCategory == "Food" &&
        selectedFoodTag == "Western Food") {
      menuItems = westernMenu; // ✅ tampilkan daftar Western Food
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Squash") {
      menuItems = squashDrinks;
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Mojito") {
      menuItems = mojitoDrinks;
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Smoothies") {
      menuItems = smoothiesDrinks;
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Juice") {
      menuItems = juiceDrinks;
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Yakult") {
      menuItems = yakultDrinks;
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Tea") {
      menuItems = teaDrinks;
    } else if (selectedCategory == "Drink" &&
        selectedDrinkTag == "Non Coffeee") {
      menuItems = nonCoffeeeDrinks;
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Blend") {
      menuItems = blendDrinks;
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Milkshake") {
      menuItems = milkshakeDrinks;
    } else if (selectedCategory == "Drink" && selectedDrinkTag == "Hot Drink") {
      menuItems = hotDrinks;
    } else if (selectedCategory == "Drink" &&
        selectedDrinkTag == "Basic Coffeee") {
      menuItems = basicCoffeeeDrinks;
    } else if (selectedCategory == "Drink" &&
        selectedDrinkTag == "Signature Coffeee") {
      menuItems = signatureCoffeeeDrinks;
    } else if (selectedCategory == "Drink" &&
        selectedDrinkTag == "Coffeee Fushion") {
      menuItems = coffeeeFushionDrinks;
    } else {
      menuItems = menuData[selectedCategory]!;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF145A00)),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomePage()));
          },
        ),
        centerTitle: true,
        title: const Text(
          'Menu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          _cartAction(), // ⬅️ ikon keranjang + badge
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: const [
                Icon(Icons.star, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Menu Secret Garden",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _categoryButton("Food", Icons.restaurant),
                const SizedBox(width: 12),
                _categoryButton("Drink", Icons.local_cafe),
                const SizedBox(width: 12),
                _categoryButton("Light Meal", Icons.icecream),
              ],
            ),
          ),

          // ✅ Tag makanan muncul hanya saat kategori Food
          const SizedBox(height: 12),
          if (selectedCategory == "Drink")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: drinkTags.map((tag) {
                    final isSelected = selectedDrinkTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDrinkTag = tag;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? const Color(0xFF145A00)
                              : Colors.white,
                          elevation: 4,
                          shadowColor: Colors.black26,
                          side: const BorderSide(color: Color(0xFF145A00)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF145A00),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          if (selectedCategory == "Food")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: foodTags.map((tag) {
                    final isSelected = selectedFoodTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFoodTag = tag;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? const Color(0xFF145A00)
                              : Colors.white,
                          elevation: 4,
                          shadowColor: Colors.black26,
                          side: const BorderSide(color: Color(0xFF145A00)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF145A00),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Menu List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: menuItems.length,
              itemBuilder: (_, index) {
                final item = menuItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['image']!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['price']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _showOrderSheet(item);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF145A00),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  elevation: 4,
                                  shadowColor: Colors.black26,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                ),
                                child: const Text("Pesan",
                                    style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ✅ BottomNavigationBar dengan route lengkap
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
            // Halaman Menu (current)
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BookingPage(
                  bookingDetails: widget
                      .bookingDetails, // Pastikan Anda mengirimkan bookingDetails
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

  Widget _categoryButton(String label, IconData icon) {
    final isSelected = selectedCategory == label;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          selectedCategory = label;
        });
      },
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFF145A00),
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF145A00),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF145A00) : Colors.white,
        elevation: 6,
        shadowColor: Colors.black26,
        side: const BorderSide(color: Color(0xFF145A00)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
