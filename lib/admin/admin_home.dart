import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:secretgarden_app/app_db.dart';
import 'package:secretgarden_app/admin/admin_menu_page.dart';   // ✅ AdminMenuTab asli
import 'package:secretgarden_app/admin/orders_admin_page.dart'; // ✅ halaman pesanan

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  static const brand = Color(0xFF145A00);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // default buka tab Pesanan
  int _idx = 2;

  final _pages = const [
    AdminBookingTab(),
    AdminMenuPage(),                         // ✅ dari admin_menu_page.dart
    AdminOrdersPage(showAppBar: false),     // ✅ tab Pesanan
    AdminSettingsTab(),
  ];

  final _titles = const [
    'Booking',
    'Menu/Produk',
    'Pesanan',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final isOrdersTab = _idx == 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AdminHomePage.brand),
        title: Text(
          'Admin • ${_titles[_idx]}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // tombol cepat ke halaman Pesanan — tampil hanya jika tab aktif BUKAN Pesanan
        actions: [
          if (!isOrdersTab)
            IconButton(
              icon: const Icon(Icons.receipt_long, color: AdminHomePage.brand),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminOrdersPage()),
                );
              },
            ),
        ],
      ),
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        selectedItemColor: AdminHomePage.brand,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// =============================
// TAB 1: BOOKING (Realtime DB)
// =============================
class AdminBookingTab extends StatelessWidget {
  const AdminBookingTab({super.key});

  static const brand = Color(0xFF145A00);
  DatabaseReference get _root => dbRef('bookings');

  Stream<DatabaseEvent> _stream() => _root.orderByChild('createdAt').onValue;

  Future<void> _updateStatus(BuildContext context, String id, String newStatus) async {
    await _root.child(id).update({'status': newStatus});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status diubah ke $newStatus')),
    );
  }

  Future<void> _delete(BuildContext context, String id) async {
    await _root.child(id).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking dihapus')),
    );
  }

  Color _statusColor(String? s) {
    switch ((s ?? 'pending').toLowerCase()) {
      case 'approved':
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blueGrey;
      default:
        return Colors.amber;
    }
  }

  String _statusText(String? s) {
    switch ((s ?? 'pending').toLowerCase()) {
      case 'approved':
      case 'confirmed':
        return 'Approved';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  String _fmtDateIso(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return '-';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd-$mm-${d.year}';
  }

  String _fmtCreatedAt(dynamic ts) {
    final millis = (ts is int) ? ts : int.tryParse(ts?.toString() ?? '');
    if (millis == null) return '-';
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd-$mm-${d.year} $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _stream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.snapshot.value == null) {
          return const Center(child: Text('Belum ada booking'));
        }

        final raw = snap.data!.snapshot.value as Map<dynamic, dynamic>;
        final items = <Map<String, dynamic>>[];

        raw.forEach((key, value) {
          if (value is Map) {
            items.add({
              'id': key.toString(),
              ...value.map((k, v) => MapEntry(k.toString(), v)),
            });
          }
        });

        items.sort((a, b) {
          final ai = (a['createdAt'] is int)
              ? a['createdAt'] as int
              : int.tryParse(a['createdAt']?.toString() ?? '') ?? 0;
          final bi = (b['createdAt'] is int)
              ? b['createdAt'] as int
              : int.tryParse(b['createdAt']?.toString() ?? '') ?? 0;
          return bi.compareTo(ai);
        });

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final b = items[i];
            final id = b['id'] as String;

            final tableName = (b['tableName'] ?? '-') as String;
            final area = (b['area'] ?? '-') as String;
            final capacity = (b['capacity'] ?? '-') as String;
            final qty = (b['qty'] ?? 1).toString();
            final dateIso = b['date']?.toString();
            final time = (b['time'] ?? '-') as String;
            final note = (b['note'] ?? '') as String;
            final status = (b['status'] ?? 'pending') as String;
            final createdAt = b['createdAt'];
            final image = (b['image'] ?? '') as String;

            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (image.isNotEmpty)
                      ? Image.network(image, width: 56, height: 56, fit: BoxFit.cover)
                      : Container(
                          width: 56,
                          height: 56,
                          color: Colors.white,
                          child: const Icon(Icons.table_bar, color: brand),
                        ),
                ),
                title: Text(tableName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$area • $capacity • $qty meja'),
                    Text('${_fmtDateIso(dateIso)} • $time'),
                    if (note.isNotEmpty) Text('Catatan: $note'),
                    const SizedBox(height: 6),
                    Chip(
                      label: Text(_statusText(status), style: const TextStyle(color: Colors.white)),
                      backgroundColor: _statusColor(status),
                    ),
                    const SizedBox(height: 4),
                    Text('Dibuat: ${_fmtCreatedAt(createdAt)}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
                trailing: _BookingActions(
                  status: status,
                  onApprove: () => _updateStatus(context, id, 'approved'),
                  onCancel: () => _updateStatus(context, id, 'cancelled'),
                  onComplete: () => _updateStatus(context, id, 'completed'),
                  onDelete: () => _delete(context, id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BookingActions extends StatelessWidget {
  const _BookingActions({
    required this.status,
    required this.onApprove,
    required this.onCancel,
    required this.onComplete,
    required this.onDelete,
  });

  final String status;
  final Future<void> Function() onApprove;
  final Future<void> Function() onCancel;
  final Future<void> Function() onComplete;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lower != 'approved' && lower != 'confirmed')
          TextButton(
            onPressed: onApprove,
            style: TextButton.styleFrom(foregroundColor: AdminHomePage.brand),
            child: const Text('Approve'),
          ),
        if (lower != 'cancelled')
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        if (lower != 'completed' && lower != 'cancelled')
          TextButton(
            onPressed: onComplete,
            style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
            child: const Text('Complete'),
          ),
        TextButton(
          onPressed: onDelete,
          style: TextButton.styleFrom(foregroundColor: Colors.black54),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}

// ============ TAB 2: MENU/PRODUK ============
// ❌ HAPUS kelas placeholder AdminMenuTab lama dari file ini!
// Gunakan AdminMenuTab dari admin/admin_menu_page.dart yang sudah kamu import.

// ============ TAB 4: SETTINGS ============
class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Tentang aplikasi'),
          subtitle: Text('Panel admin Secret Garden'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Keluar', style: TextStyle(color: Colors.red)),
          onTap: () => _signOut(context),
        ),
      ],
    );
  }
}
