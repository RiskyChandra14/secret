import 'package:firebase_database/firebase_database.dart';
import 'package:secretgarden_app/app_db.dart'; // <-- penting: pakai helper dbRef()

class BookingService {
  // Akar Realtime DB lewat helper (mengikuti konfigurasi tunggal di app_db.dart)
  static DatabaseReference get _root => dbRef();

  /// Simpan 1 booking ke `bookings/{autoId}`
  /// return: order/booking id yang di-generate
  static Future<String> saveBooking(Map<String, dynamic> data) async {
    final ref = _root.child('bookings').push();
    await ref.set({
      ...data,
      'createdAt': ServerValue.timestamp,
    });
    return ref.key!; // bisa dipakai kalau perlu
  }

  // ======================= TAMBAHAN YANG BENAR =======================

  /// Stream semua booking (untuk ADMIN), diurutkan createdAt (terbaru dulu di UI).
  static Stream<DatabaseEvent> streamAll() =>
      _root.child('bookings').orderByChild('createdAt').onValue;

  /// Stream booking milik user tertentu (untuk halaman riwayat User).
  static Stream<DatabaseEvent> streamByUser(String uid) =>
      _root.child('bookings').orderByChild('userId').equalTo(uid).onValue;

  /// Ambil satu booking sekali baca.
  static Future<DataSnapshot> getOnce(String bookingId) =>
      _root.child('bookings/$bookingId').get();

  /// Ubah status booking (admin).
  /// Contoh nilai: pending | approved | cancelled | completed
  static Future<void> updateStatus(String bookingId, String status) =>
      _root.child('bookings/$bookingId').update({'status': status});

  /// Hapus booking (admin).
  static Future<void> delete(String bookingId) =>
      _root.child('bookings/$bookingId').remove();

  /// (Opsional) Tulis index untuk riwayat per-user: /user_bookings/{uid}/{bookingId} = true
  static Future<void> indexForUser(String uid, String bookingId) =>
      _root.child('user_bookings/$uid/$bookingId').set(true);
}
