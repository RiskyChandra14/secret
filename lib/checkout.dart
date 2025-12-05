import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:secretgarden_app/app_db.dart'; 
import 'package:secretgarden_app/services/payment_servuce/payment_service.dart';
import 'package:secretgarden_app/services/payment_servuce/payment_service.dart';

class CartItem {
  final String name;
  final String image;
  final int unitPrice;
  int qty;
  final String? note;

  CartItem({
    required this.name,
    required this.image,
    required this.unitPrice,
    required this.qty,
    this.note,
  });

  // Menghitung total per item (unitPrice * qty)
  int get lineTotal => unitPrice * qty;
}

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cart;
  final String Function(int) formatRupiah;
  final VoidCallback onCartChanged;
  final Map<String, dynamic> bookingDetails; // Tambahkan properti ini

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.formatRupiah,
    required this.onCartChanged,
    required this.bookingDetails, // Tambahkan parameter ini
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const brand = Color(0xFF145A00);

  bool _submitting = false;
  String? _orderNote;

  // Menghitung total belanjaan
  int get total => widget.cart.fold<int>(0, (s, e) => s + e.lineTotal);

  // Menambahkan daftar meja yang tersedia
  final List<Map<String, String>> availableTables = [
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
          'https://ucarecdn.com/1a3e2f3e-3f0e-4f7c-8b1d-1e3f5c6b7d8e/MejaOutdoor4Orang.jpg',
      'jumlah_orang': '4',
    },
    {
      'meja': 'Gazebo (Outdoor)',
      'meja_image':
          'https://ucarecdn.com/7a409914-c9da-454c-bc8e-60aac1d47a04/GajeboOutdoor4Orang.jpg',
      'jumlah_orang': '4',
    },
    {
      'meja': 'VIP Room',
      'meja_image':
          'https://ucarecdn.com/0a220c03-744a-4474-8fe3-e91c93d03bbf/MejaVIP.jpg',
      'jumlah_orang': '10',
    },
  ];

  String selectedTableName = '';
  String selectedTableImage = '';
  String selectedTableCapacity = '';

  @override
  void initState() {
    super.initState();
    print("Data yang diterima di CheckoutPage: ${widget.bookingDetails}");

    // Inisialisasi dengan data meja dari bookingDetails atau nilai default
    selectedTableName = widget.bookingDetails['meja'] ?? 'Meja belum dipilih';
    selectedTableImage = widget.bookingDetails['meja_image'] ?? '';
    selectedTableCapacity = widget.bookingDetails['jumlah_orang'] ?? '0';
  }

  // Fungsi untuk mengirim pesanan
  Future<void> _kirimPesanan(List<CartItem> cart) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan login terlebih dahulu')),
    );
    return;
  }

  setState(() {
    _submitting = true; // Menandakan proses pengiriman dimulai
  });

  // 1) Hitung total harga (INTEGER)
  final int total = cart.fold<int>(0, (sum, e) => sum + e.unitPrice * e.qty);

  // 2) Siapkan items sebagai MAP: {"0": {...}, "1": {...}}
  final Map<String, dynamic> items = {};
  for (int i = 0; i < cart.length; i++) {
    final c = cart[i];
    items['$i'] = {
      'name': c.name,
      'unitPrice': c.unitPrice,
      'qty': c.qty,
      'note': c.note == null || c.note!.isEmpty ? null : c.note,
      'image': c.image == null || c.image!.isEmpty ? null : c.image,
    };
  }

  // Payload yang akan dikirim ke Firebase
  final payload = {
    'userId': user.uid, // STRING
    'total': total, // INTEGER
    'status': 'pending', // Salah satu status
    'createdAt': ServerValue.timestamp, // Waktu dibuat
    'updatedAt': null,
    'items': items, // MAP dari item
  };

  try {
    // Menyimpan data ke Firebase
    await ordersRef().push().set(payload);
    
    if (!mounted) return;

    // Push ke halaman Payment setelah berhasil
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MidtransPaymentPage(  // Pastikan ini sudah benar
      amount: total.toString(),
    ),
  ),
);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan berhasil dikirim, lanjutkan pembayaran QRIS')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mengirim pesanan: $e')),
    );
  } finally {
    setState(() {
      _submitting = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: brand),
      ),
      backgroundColor: Colors.white,
      body: widget.cart.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                // Menampilkan detail meja yang sudah dipilih
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Menampilkan gambar meja
                      Image.network(
                        widget.bookingDetails['meja_image'] ??
                            '', // Pastikan key 'meja_image' ada
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(
                          width:
                              16), // Menambahkan jarak antara gambar dan teks
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Menampilkan nama meja
                            Text(
                              widget.bookingDetails['meja'] ??
                                  'Meja belum dipilih',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                                height:
                                    4), // Jarak antara nama meja dan kapasitas
                            // Menampilkan kapasitas meja
                            Text(
                              'Kapasitas: ${widget.bookingDetails['jumlah_orang'] ?? '0'} orang',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Daftar pesanan makanan
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.length,
                    itemBuilder: (_, i) {
                      final c = widget.cart[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  c.image ?? '',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Harga: ${widget.formatRupiah(c.unitPrice)}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (c.qty > 1) {
                                                c.qty--;
                                              } else {
                                                widget.cart.removeAt(i);
                                              }
                                            });
                                            widget.onCartChanged();
                                          },
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: brand,
                                          ),
                                        ),
                                        Text(
                                          '${c.qty}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() => c.qty++);
                                            widget.onCartChanged();
                                          },
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: brand,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          widget.formatRupiah(c.lineTotal),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: brand,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() => widget.cart.removeAt(i));
                                  widget.onCartChanged();
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Catatan pesanan
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  color: Colors.white,
                  child: TextField(
                    onChanged: (v) =>
                        _orderNote = v.trim().isEmpty ? null : v.trim(),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan untuk pesanan (opsional)',
                      hintText: 'Misal: level pedas, tanpa bawang, dll.',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                // Bar total + tombol submit
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total',
                                style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                      Text(
                        widget.formatRupiah(total), // Total amount
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: brand,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submitting
                            ? null
                            : () {
                                _kirimPesanan(widget
                                    .cart); // Kirim pesanan terlebih dahulu
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MidtransPaymentPage(
                                      amount: total
                                          .toString(), // Mengonversi total menjadi string
                                    ),
                                  ),
                                );
                              },
                        icon: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: const Text('Buat Pesanan dan Bayar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
