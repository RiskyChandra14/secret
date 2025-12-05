import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:secretgarden_app/app_db.dart';
import 'package:secretgarden_app/services/order_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  DatabaseReference get _ref => dbRef('orders');

  @override
  void initState() {
    super.initState();
    _debugLastOrder();
  }

  Future<void> _debugLastOrder() async {
    try {
      final snap = await dbRef('orders').limitToLast(1).get();
      // ignore: avoid_print
      print('[AdminOrders] test read: ${snap.value}');
    } catch (e) {
      // ignore: avoid_print
      print('[AdminOrders] test read error: $e');
    }
  }

  Stream<DatabaseEvent> _stream() => _ref.orderByChild('createdAt').onValue;

  String _rupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    var c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      c++;
      if (c % 3 == 0 && i != 0) buf.write('.');
    }
    return 'Rp.${buf.toString().split('').reversed.join()}';
  }

  String _fmtTs(dynamic ts) {
    final millis = (ts is int) ? ts : int.tryParse('${ts ?? ''}');
    if (millis == null) return '-';
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.day.toString().padLeft(2, "0")}-'
           '${d.month.toString().padLeft(2, "0")}-${d.year} '
           '${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}';
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted':  return Colors.green;
      case 'rejected':  return Colors.red;
      case 'ready':     return Colors.blue;
      case 'completed': return Colors.grey;
      default:          return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Admin • Pesanan',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              elevation: 1,
            )
          : null,
      body: StreamBuilder<DatabaseEvent>(
        stream: _stream(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('Belum ada pesanan'));
          }

          final raw = (data as Map).cast<dynamic, dynamic>();
          final items = <Map<String, dynamic>>[];

          raw.forEach((k, v) {
            if (v is Map) {
              items.add({'id': '$k', ...v.map((kk, vv) => MapEntry('$kk', vv))});
            }
          });

          items.sort((a, b) {
            final ai = int.tryParse('${a['createdAt'] ?? 0}') ?? 0;
            final bi = int.tryParse('${b['createdAt'] ?? 0}') ?? 0;
            return bi.compareTo(ai);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final o = items[i];
              final id        = o['id'];
              final status    = (o['status'] ?? 'new') as String;
              final total     = (o['total'] is int) ? o['total'] as int
                               : int.tryParse('${o['total']}') ?? 0;
              final userId    = '${o['userId'] ?? '-'}';
              final createdAt = o['createdAt'];

              var count = 0;
              final it = o['items'];
              if (it is List) {
                for (final e in it) {
                  final q = (e is Map) ? int.tryParse('${e['qty'] ?? 0}') ?? 0 : 0;
                  count += q;
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('Order #$id',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: $userId • Item: $count'),
                      Text('Waktu: ${_fmtTs(createdAt)}'),
                      const SizedBox(height: 6),
                      Chip(
                        label: Text(status,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: _statusColor(status),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_rupiah(total),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF145A00))),
                      PopupMenuButton<String>(
                        onSelected: (s) => OrderService.updateStatus(id, s),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'accepted',  child: Text('Accept')),
                          PopupMenuItem(value: 'rejected',  child: Text('Reject')),
                          PopupMenuItem(value: 'ready',     child: Text('Mark Ready')),
                          PopupMenuItem(value: 'completed', child: Text('Complete')),
                          PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
