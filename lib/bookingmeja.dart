import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:secretgarden_app/homepage.dart';
import 'package:secretgarden_app/menucustomerpage.dart';
import 'package:secretgarden_app/app_db.dart';
import 'package:provider/provider.dart';
import 'package:secretgarden_app/providers/history_provider.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const BookingPage({super.key, required this.bookingDetails});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String selectedCategory = "Indoor";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int tables = 1;
  String note = '';

  // Dummy data booking
  final Map<String, List<Map<String, String>>> bookingData = {
    "Indoor": [
      {
        "image":
            "https://ucarecdn.com/2e42c152-e688-4bea-8350-f10843b4a66b/MejaIndoor2Orang.jpg",
        "name": "Meja 1 (Indoor)",
        "capacity": "2 orang"
      },
      {
        "image":
            "https://ucarecdn.com/c05d48e9-607d-4c69-b959-01050f819bcb/MejaIndoor4Orang.jpg",
        "name": "Meja 2 (Indoor)",
        "capacity": "4 orang"
      },
    ],
    "Outdoor": [
      {
        "image":
            "https://ucarecdn.com/6220fd18-dfea-4d40-84af-13dd485b590e/MejaOutdoor2Orang.jpg",
        "name": "Meja 1 (Outdoor)",
        "capacity": "2 orang"
      },
      {
        "image":
            "https://ucarecdn.com/ff9a3d7a-42e2-4a31-880d-7fe1cbd9017d/MejaOutdoor4Orang.jpg",
        "name": "Meja 2 (Outdoor)",
        "capacity": "4 orang"
      },
      {
        "image":
            "https://ucarecdn.com/7a409914-c9da-454c-bc8e-60aac1d47a04/GajeboOutdoor4Orang.jpg",
        "name": "Gazebo (Outdoor)",
        "capacity": "4 orang"
      },
    ],
    "VIP": [
      {
        "image":
            "https://ucarecdn.com/0a220c03-744a-4474-8fe3-e91c93d03bbf/MejaVIP.jpg",
        "name": "VIP Room",
        "capacity": "10 orang"
      },
    ],
  };

  void _openMenuPage(Map<String, String> selectedTable) {
    print("Data yang dikirim ke MenuCustomerPage: $selectedTable");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MenuCustomerPage(
          bookingDetails: selectedTable, // Mengirimkan data meja yang dipilih
        ),
      ),
    );
  }

  void _showBookingSheet(Map<String, String> item) {
    final parentCtx = context; // Simpan context halaman

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Detail Booking',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['image'] ?? '',
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
                                item['name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['capacity'] ?? '',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Jumlah meja
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jumlah meja',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (tables > 1) setModalState(() => tables--);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$tables',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => setModalState(() => tables++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tanggal & Jam
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? now,
                                firstDate: now,
                                lastDate: now.add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setModalState(() => selectedDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              selectedDate == null
                                  ? 'Pilih tanggal'
                                  : _formatDate(selectedDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setModalState(() => selectedTime = picked);
                              }
                            },
                            icon: const Icon(Icons.schedule),
                            label: Text(
                              selectedTime == null
                                  ? 'Pilih jam'
                                  : _formatTime(selectedTime!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Catatan
                    const Text(
                      'Catatan (opsional)',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      onChanged: (v) => setModalState(() => note = v),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Contoh: dekat jendela / high chair / dll',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info & tombol Konfirmasi
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (selectedDate != null && selectedTime != null)
                                ? 'Waktu: ${_formatDate(selectedDate!)} ${_formatTime(selectedTime!)}'
                                : 'Pilih tanggal & jam',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF145A00),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedDate == null || selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Pilih tanggal & jam dulu ya')));
                              return;
                            }

                            String _formatTime24(TimeOfDay time) {
                              final hour = time.hour.toString().padLeft(2, '0');
                              final minute =
                                  time.minute.toString().padLeft(2, '0');
                              return '$hour:$minute';
                            }

                            final schedule = DateTime(
                              selectedDate!.year,
                              selectedDate!.month,
                              selectedDate!.day,
                              selectedTime!.hour,
                              selectedTime!.minute,
                            );

                            final User? user =
                                FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final payload = {
                                'userId': user.uid,
                                'tableName': item['name'],
                                'image': item['image'],
                                'capacity': item['capacity'],
                                'area': selectedCategory,
                                'qty': tables,
                                'date': selectedDate?.toIso8601String() ?? '',
                                'time': selectedTime != null
                                    ? _formatTime24(selectedTime!)
                                    : '',
                                'note':
                                    note.trim().isEmpty ? null : note.trim(),
                                'status': 'pending',
                                'scheduleIso': schedule.toIso8601String(),
                                'createdAt': ServerValue.timestamp,
                                'updatedAt': null,
                              };

                              try {
                                // Save history booking to the provider
                                final newBooking = {
                                  'image': item['image']!,
                                  'title': item['name']!,
                                  'subtitle':
                                      'Booking Tempat • ${_formatDate(selectedDate!)}',
                                  'price': 'Rp. ${item['capacity']}',
                                };

                                // Adding the new booking history to the provider
                                Provider.of<HistoryProvider>(context,
                                        listen: false)
                                    .addHistory(newBooking);

                                // Save the booking to the Firebase database
                                await bookingsRef().push().set(payload);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MenuCustomerPage(
                                      bookingDetails: {
                                        'meja': item['name'],
                                        'jumlah_orang': tables,
                                        'date':
                                            selectedDate?.toIso8601String() ??
                                                '',
                                        'time': _formatTime24(selectedTime!),
                                        'note': note.trim().isEmpty
                                            ? null
                                            : note.trim(),
                                      },
                                    ),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Booking berhasil dilakukan')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Gagal simpan booking: $e')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF145A00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            elevation: 3,
                          ),
                          child: const Text('Konfirmasi'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // helpers
  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatTime24(TimeOfDay t) => _formatTime(t);

  @override
  Widget build(BuildContext context) {
    final bookingItems = bookingData[selectedCategory]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF145A00)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
        ),
        centerTitle: true,
        title: const Text('Booking',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: const [
                Icon(Icons.star, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Booking Secret Garden",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _categoryButton("Indoor", Icons.chair),
                const SizedBox(width: 12),
                _categoryButton("Outdoor", Icons.park),
                const SizedBox(width: 12),
                _categoryButton("VIP", Icons.meeting_room),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: bookingItems.length,
              itemBuilder: (_, index) {
                final item = bookingItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['image']!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name']!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['capacity']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _showBookingSheet(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF145A00),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  elevation: 4,
                                  shadowColor: Colors.black26,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                ),
                                child: const Text("Book Now",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryButton(String label, IconData icon) {
    final isSelected = selectedCategory == label;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          selectedCategory = label;
        });
      },
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFF145A00),
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF145A00),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF145A00) : Colors.white,
        elevation: 6,
        shadowColor: Colors.black26,
        side: const BorderSide(color: Color(0xFF145A00)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
