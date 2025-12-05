
enum BookingStatus { pending, approved, cancelled }

class Booking {
  final String area;         // Indoor / Outdoor / VIP
  final String tableName;    // Meja 1 (Indoor)
  final String capacity;     // 2 orang
  final String image;
  final int tables;          // jumlah meja
  final DateTime date;       // tanggal+jam dipilih
  final String note;         // opsional
  final BookingStatus status;

  Booking({
    required this.area,
    required this.tableName,
    required this.capacity,
    required this.image,
    required this.tables,
    required this.date,
    this.note = '',
    this.status = BookingStatus.pending,
  });

  String get dateStr =>
      '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  Booking copyWith({
    String? area,
    String? tableName,
    String? capacity,
    String? image,
    int? tables,
    DateTime? date,
    String? note,
    BookingStatus? status,
  }) {
    return Booking(
      area: area ?? this.area,
      tableName: tableName ?? this.tableName,
      capacity: capacity ?? this.capacity,
      image: image ?? this.image,
      tables: tables ?? this.tables,
      date: date ?? this.date,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }
}
