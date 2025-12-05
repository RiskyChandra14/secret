import 'package:flutter/foundation.dart';
import 'package:secretgarden_app/models/booking.dart';

class AppStore {
  AppStore._();
  static final I = AppStore._();

  /// daftar booking disimpan di sini
  final ValueNotifier<List<Booking>> bookings = ValueNotifier<List<Booking>>([]);

  void addBooking(Booking b) {
    bookings.value = [...bookings.value, b];
  }

  void updateStatus(int index, BookingStatus status) {
    final list = [...bookings.value];
    list[index] = list[index].copyWith(status: status);
    bookings.value = list;
  }

  void removeAt(int index) {
    final list = [...bookings.value]..removeAt(index);
    bookings.value = list;
  }
}
