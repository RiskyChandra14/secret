import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'package:secretgarden_app/models/keranjang.dart';
import 'package:secretgarden_app/app_db.dart'; // <-- pakai instance & helper dari sini

class OrderService {
  // Akar path "orders"
  static DatabaseReference get _ordersRef => dbRef('orders');

  /// Simpan order ke Realtime DB -> orders/{autoId}
  /// return orderId
  static Future<String> createOrder({
    required List<CartItem> items,
    required int total,
    String? orderNote,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Pengguna belum login.',
      );
    }

    final ref = _ordersRef.push();

    debugPrint('[OrderService] write -> ${ref.path}');
    debugPrint('[OrderService] uid   -> ${user.uid}');

    await ref.set({
      'orderId': ref.key,
      'userId': user.uid,
      'total': total,
      'status': 'new', // new | accepted | rejected | ready | completed | cancelled
      'orderNote': orderNote,
      'createdAt': ServerValue.timestamp,
      'items': items.map((e) => e.toJson()).toList(),
    });

    // index riwayat pesanan per user
    await dbRef('user_orders/${user.uid}/${ref.key}').set(true);
    
    return ref.key!;
  } 

  static Future<void> updateStatus(String orderId, String status) async {
    await dbRef('orders/$orderId').update({'status': status});
  }
}
