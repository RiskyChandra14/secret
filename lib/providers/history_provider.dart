import 'package:flutter/material.dart';

class HistoryProvider with ChangeNotifier {
  // List untuk menyimpan riwayat pesanan
  List<Map<String, String>> _historyData = [];

  // Getter untuk historyData
  List<Map<String, String>> get history => _historyData;

  // Fungsi untuk menambahkan riwayat pesanan
  void addHistory(Map<String, String> order) {
    _historyData.add(order);
    notifyListeners(); // Memberi tahu widget yang mendengarkan bahwa ada perubahan
  }

  // Fungsi untuk menghapus semua riwayat
  void clearHistory() {
    _historyData.clear();
    notifyListeners();
  }
}
