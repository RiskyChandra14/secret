import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Untuk menampilkan QR code
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk menggunakan Firestore

class MidtransPaymentPage extends StatefulWidget {
  final String amount; // Menerima parameter jumlah yang akan dibayar

  const MidtransPaymentPage({Key? key, required this.amount}) : super(key: key);

  @override
  _MidtransPaymentPageState createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  String qrUrl = ''; // Untuk menampung URL QRIS
  bool isLoading = false; // Indikator loading selama proses transaksi
  String selectedPaymentMethod = 'qris'; // Metode pembayaran yang dipilih, default QRIS
  final String serverKey = 'Mid-server-ImtdiRoA9e79c8dbTY_8Sfkl'; // Ganti dengan Server Key Midtrans Anda (sandbox)

  @override
  void initState() {
    super.initState();
  }

  // Fungsi untuk membuat transaksi dan mendapatkan URL pembayaran dari Midtrans
  Future<void> createMidtransTransaction(String amount) async {
    final String url = 'https://api.sandbox.midtrans.com/v2/charge'; // URL Sandbox Midtrans untuk pengujian

    final Map<String, dynamic> requestData = {
      "payment_type": selectedPaymentMethod, // Metode pembayaran yang dipilih
      "transaction_details": {
        "order_id": "order-${DateTime.now().millisecondsSinceEpoch}",
        "gross_amount": int.parse(amount),
      },
      "item_details": [
        {
          "id": "item1",
          "price": int.parse(amount),
          "quantity": 1,
          "name": "Pembelian"
        },
      ],
    };

    final String jsonRequest = jsonEncode(requestData);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Basic ' + base64Encode(utf8.encode('$serverKey:')), // Header untuk authorization
            },
            body: jsonRequest,
          )
          .timeout(Duration(seconds: 60)); // Timeout 60 detik

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          qrUrl = responseData['redirect_url']; // Mendapatkan URL pembayaran (QRIS atau lainnya)
          isLoading = false;
        });
        print('QRIS Link: $qrUrl');
        saveTransactionDetails(responseData['order_id'], 'pending'); // Menyimpan status transaksi di Firestore
      } else {
        final responseData = jsonDecode(response.body);
        print('Error response: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat transaksi: ${responseData['error_messages']}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Menghentikan loading jika ada error
      });
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghubungi Midtrans: $e')),
      );
    }
  }

  // Fungsi untuk menyimpan status transaksi ke Firestore
  Future<void> saveTransactionDetails(String orderId, String status) async {
    FirebaseFirestore.instance.collection('payments').add({
      'order_id': orderId,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      print("Transaction saved successfully!");
    }).catchError((error) {
      print("Failed to save transaction: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran Midtrans"),
        backgroundColor: const Color(0xFF145A00),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Pilih metode pembayaran:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Pilihan metode pembayaran
            DropdownButton<String>(
              value: selectedPaymentMethod,
              items: [
                DropdownMenuItem(
                  child: Text("QRIS"),
                  value: 'qris',
                ),
                DropdownMenuItem(
                  child: Text("Kartu Kredit"),
                  value: 'credit_card',
                ),
                DropdownMenuItem(
                  child: Text("Debit Card"),
                  value: 'debit_card',
                ),
                DropdownMenuItem(
                  child: Text("GoPay"),
                  value: 'gopay',
                ),
                DropdownMenuItem(
                  child: Text("DANA"),
                  value: 'dana',
                ),
                DropdownMenuItem(
                  child: Text("OVO"),
                  value: 'ovo',
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Tombol untuk memulai transaksi
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                createMidtransTransaction(widget.amount);
              },
              child: const Text('Mulai Pembayaran'),
            ),

            const SizedBox(height: 16),

            // Menampilkan QR code jika URL tersedia
            isLoading
                ? const CircularProgressIndicator()
                : qrUrl.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),
                        child: QrImageView(
                          data: qrUrl,  // URL yang didapat dari API Midtrans
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      )
                    : const Text("Gagal mendapatkan URL pembayaran."),
          ],
        ),
      ),
    );
  }
}
