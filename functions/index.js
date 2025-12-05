const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");

// Inisialisasi Firebase Admin
admin.initializeApp();

// Shared secret key yang diberikan oleh Midtrans
const sharedSecretKey = 'Mid-server-ImtdiRoA9e79c8dbTY_8Sfkl';

// Fungsi untuk menghasilkan signature
const generateSignature = (data, key) => {
  return crypto.createHmac('sha512', key)
               .update(data)
               .digest('hex');
};

// Fungsi untuk menangani webhook pembayaran dari Midtrans
exports.handleMidtransWebhook = functions.https.onRequest((req, res) => {
  // Mengambil signature dari header
  const signatureKey = req.headers['x-midtrans-signature']; // Sesuaikan dengan header yang dikirimkan oleh Midtrans
  const requestBody = JSON.stringify(req.body); // Pastikan body sudah di-stringify dengan benar

  // Log requestBody dan signature untuk debugging
  console.log('Request Body:', requestBody);
  console.log('Signature Key:', signatureKey);

  // Menghasilkan signature untuk memverifikasi data
  const generatedSignature = generateSignature(requestBody, sharedSecretKey);
  console.log("Generated Signature:", generatedSignature);
  console.log("Signature from Header:", signatureKey);

  // Periksa apakah signature yang dihasilkan cocok dengan signature yang dikirim oleh Midtrans
  if (generatedSignature === signatureKey) {
    // Verifikasi berhasil, lanjutkan untuk memproses data pembayaran
    const paymentStatus = req.body.transaction_status;  // Status pembayaran
    const orderId = req.body.order_id;  // ID pesanan untuk referensi

    // Mengakses Firestore dan memperbarui status pembayaran
    const paymentRef = admin.firestore().collection("payments").doc(orderId);
    paymentRef.update({
      status: paymentStatus,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    })
    .then(() => {
      // Kirimkan respons sukses ke Midtrans
      res.status(200).send("Success");
    })
    .catch((error) => {
      // Tangani error jika terjadi kesalahan dalam pembaruan Firestore
      console.error("Error updating Firestore:", error);
      res.status(500).send("Error: " + error.message);
    });
  } else {
    // Signature tidak cocok, kirimkan error
    console.error('Invalid signature');
    res.status(400).send("Invalid signature");
  }
});
