import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:secretgarden_app/profile/profile.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController namaController =
      TextEditingController(text: "Risky Chandra");
  final TextEditingController emailController =
      TextEditingController(text: "Riskychandra@gmail.com");
  final TextEditingController teleponController =
      TextEditingController(text: "+62 812 3456 7890");
  final TextEditingController alamatController =
      TextEditingController(text: "Jl. Mawar No. 123, Jakarta");
  final TextEditingController tanggalLahirController =
      TextEditingController(text: "01 Januari 1990");

  String jenisKelamin = "Pria"; // Default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Preview
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      "https://ucarecdn.com/20400afe-1bd5-406b-9f5f-d8ffc8586840/profile.jpeg",
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF145A00),
                      ),
                      padding: const EdgeInsets.all(6),
                      child:
                          const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nama
            const Text(
              "Nama Lengkap",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Masukkan nama Anda",
              ),
            ),
            const SizedBox(height: 16),

            // Email
            const Text(
              "Email",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Masukkan email Anda",
              ),
            ),
            const SizedBox(height: 16),

            // Nomor Telepon
            const Text(
              "Nomor Telepon",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: teleponController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Masukkan nomor telepon",
              ),
            ),
            const SizedBox(height: 16),

            // Alamat
            const Text(
              "Alamat",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: alamatController,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Masukkan alamat Anda",
              ),
            ),
            const SizedBox(height: 16),

            // Tanggal Lahir
            const Text(
              "Tanggal Lahir",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: tanggalLahirController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Pilih tanggal lahir",
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    const bulan = [
                      "Januari",
                      "Februari",
                      "Maret",
                      "April",
                      "Mei",
                      "Juni",
                      "Juli",
                      "Agustus",
                      "September",
                      "Oktober",
                      "November",
                      "Desember"
                    ];
                    tanggalLahirController.text =
                        "${pickedDate.day} ${bulan[pickedDate.month - 1]} ${pickedDate.year}";
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Jenis Kelamin
            const Text(
              "Jenis Kelamin",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Pria"),
                    value: "Pria",
                    groupValue: jenisKelamin,
                    onChanged: (value) {
                      setState(() {
                        jenisKelamin = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Wanita"),
                    value: "Wanita",
                    groupValue: jenisKelamin,
                    onChanged: (value) {
                      setState(() {
                        jenisKelamin = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Tampilkan Flushbar di atas
                  Flushbar(
                    message: "Berhasil disimpan",
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    flushbarPosition: FlushbarPosition.TOP,
                    margin: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    animationDuration: const Duration(milliseconds: 300),
                  ).show(context);

                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF145A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
