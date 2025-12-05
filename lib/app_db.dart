import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Pastikan URL ini persis sama di seluruh app (jangan campur dengan domain lain).
const String kDatabaseUrl =
    'https://secretgarden-app-default-rtdb.asia-southeast1.firebasedatabase.app'; // Ganti dengan URL Firebase Realtime Database Anda

/// Holder untuk membuat instance tunggal (singleton) sekali saja.
class _DBHolder {
  static FirebaseDatabase? _db;

  static FirebaseDatabase get instance {
    if (_db != null) return _db!;

    // Ambil URL dari FirebaseOptions
    final url = Firebase.app().options.databaseURL;

    // Gunakan instanceFor dengan URL yang konsisten
    _db = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: url);
    return _db!;
  }
}

/// Tetap sediakan symbol seperti punyamu agar file lain tidak perlu diubah.
FirebaseDatabase get appDb => _DBHolder.instance;

DatabaseReference dbRef([String? path]) =>
    path == null ? appDb.ref() : appDb.ref(path);

DatabaseReference ordersRef() => dbRef('orders');
DatabaseReference bookingsRef() => dbRef('bookings');
DatabaseReference adminsRef() => dbRef('admins');
DatabaseReference usersRef() => dbRef('users'); // opsional tambahan
