// lib/admin/admin_menu_page.dart
import 'package:flutter/material.dart';
import 'package:secretgarden_app/models/product.dart';
import 'package:secretgarden_app/services/product_service.dart';

const kBrand = Color(0xFF145A00);

/// Pakai withAppBar:true kalau dipush sebagai layar penuh.
/// Default false: body-only (tidak bikin AppBar) → tidak dobel saat di dalam shell.
class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key, this.withAppBar = false});
  final bool withAppBar;

  Future<void> _importSamples(BuildContext context) async {
    try {
      final n = await ProductService.importSamples();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            n == 0
                ? 'Data sudah ada — tidak diimport ulang.'
                : 'Berhasil import $n produk contoh',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal import: $e')),
      );
    }
  }

  Future<void> _cleanupDuplicates(BuildContext context) async {
    try {
      final n = await ProductService.removeDuplicateNames();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            n == 0
                ? 'Tidak ada duplikat nama.'
                : 'Berhasil hapus $n item duplikat',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal bersihkan duplikat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = const AdminMenuBody();

    if (!withAppBar) return body; // ← tidak bikin Scaffold/AppBar

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin • Menu/Produk',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: kBrand),
        actions: [
          IconButton(
            tooltip: 'Import contoh menu',
            icon: const Icon(Icons.file_download_done, color: kBrand),
            onPressed: () => _importSamples(context),
          ),
          IconButton(
            tooltip: 'Bersihkan duplikat nama',
            icon: const Icon(Icons.cleaning_services, color: kBrand),
            onPressed: () => _cleanupDuplicates(context),
          ),
        ],
      ),
      body: body,
    );
  }
}

/// Body tanpa Scaffold/AppBar — aman dipasang di dalam shell.
class AdminMenuBody extends StatefulWidget {
  const AdminMenuBody({super.key});
  @override
  State<AdminMenuBody> createState() => _AdminMenuBodyState();
}

class _AdminMenuBodyState extends State<AdminMenuBody> {
  String _q = '';

  Future<void> _importSamplesHere() async {
    try {
      final n = await ProductService.importSamples();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            n == 0
                ? 'Data sudah ada — tidak diimport ulang.'
                : 'Berhasil import $n produk contoh',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal import: $e')),
      );
    }
  }

  String _rp(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      c++;
      if (c % 3 == 0 && i != 0) buf.write('.');
    }
    return 'Rp.${buf.toString().split('').reversed.join()}';
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          height: 1.1,
          fontWeight: FontWeight.w600,
          letterSpacing: .1,
        ),
      ),
    );
  }

  Future<void> _openAdd() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _ProductForm(onSubmit: (form) async {
        await ProductService.add(
          name: form.name,
          price: form.price,
          image: form.image,
          category: form.category,
          tag: form.tag?.isEmpty == true ? null : form.tag,
          active: form.active,
        );
      }),
    );
  }

  Future<void> _openEdit(Product p) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _ProductForm(
        initial: p,
        onSubmit: (form) async => ProductService.update(p.id, {
          'name': form.name,
          'price': form.price,
          'image': form.image,
          'category': form.category,
          'tag': form.tag?.isEmpty == true ? null : form.tag,
          'active': form.active,
        }),
      ),
    );
  }

  Future<void> _confirmDelete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: true, // aman untuk nested navigator
      barrierDismissible: true, // biar bisa tap di luar untuk batal
      builder: (dctx) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text(p.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false), // ← pakai dctx!
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true), // ← pakai dctx!
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (ok == true) {
      await ProductService.remove(p.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Produk dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari menu…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFEAE5EE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            // List
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: ProductService.streamAll(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Terjadi kesalahan memuat data.'),
                            const SizedBox(height: 8),
                            Text(
                              '${snap.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // ← UBAHAN DI SINI: var items + deduplikasi saat search
                  var items = (snap.data ?? [])
                      .where((p) =>
                          _q.isEmpty || p.name.toLowerCase().contains(_q))
                      .toList();

                  // Saat sedang search, tampilkan hanya 1 produk per nama (ambil yang terbaru)
                  if (_q.isNotEmpty) {
                    final seenNames = <String>{};
                    items = items
                        .where(
                            (p) => seenNames.add(p.name.trim().toLowerCase()))
                        .toList();
                  }
                  // → SELESAI UBAHAN

                  // Empty state
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Belum ada produk'),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _importSamplesHere,
                            icon: const Icon(Icons.file_download_done,
                                color: kBrand),
                            label: const Text('Import contoh menu'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = items[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          isThreeLine: true,
                          minVerticalPadding: 12,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: p.image.isNotEmpty
                                ? Image.network(
                                    p.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.white,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: kBrand,
                                    ),
                                  ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_rp(p.price)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 0,
                                children: [
                                  _chip(p.category, kBrand),
                                  if (p.tag != null && p.tag!.isNotEmpty)
                                    _chip(p.tag!, Colors.black54),
                                ],
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 68,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.scale(
                                    scale: 0.80,
                                    child: Switch(
                                      value: p.active,
                                      activeColor: kBrand,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (v) => ProductService.update(
                                          p.id, {'active': v}),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  IconButton(
                                    tooltip: 'Hapus',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(
                                        width: 40, height: 40),
                                    splashRadius: 22,
                                    iconSize: 40,
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(p),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () => _openEdit(p),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        // FAB tambah
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: kBrand,
            onPressed: _openAdd,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// ---------- Form Tambah/Ubah ----------
class _ProductForm extends StatefulWidget {
  const _ProductForm({this.initial, required this.onSubmit});
  final Product? initial;
  final Future<void> Function(_FormData) onSubmit;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _image = TextEditingController();
  String _category = 'Food';
  final _tag = TextEditingController();
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _name.text = p.name;
      _price.text = p.price.toString();
      _image.text = p.image;
      _category = p.category;
      _tag.text = p.tag ?? '';
      _active = p.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.initial == null
                            ? 'Tambah Produk'
                            : 'Ubah Produk',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Harga (angka)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (int.tryParse(
                              (v ?? '').replaceAll(RegExp(r'[^0-9]'), '')) ==
                          null)
                      ? 'Angka tidak valid'
                      : null,
                ),
                TextFormField(
                  controller: _image,
                  decoration: const InputDecoration(labelText: 'URL Gambar'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: const [
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                    DropdownMenuItem(value: 'Drink', child: Text('Drink')),
                    DropdownMenuItem(
                        value: 'Light Meal', child: Text('Light Meal')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? 'Food'),
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                TextFormField(
                  controller: _tag,
                  decoration: const InputDecoration(
                    labelText: 'Tag/Subkategori (opsional)',
                    hintText: 'Mis. Sundanese Food, Squash, Tea…',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aktif'),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(widget.initial == null ? 'Simpan' : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final price = int.parse(_price.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final data = _FormData(
      name: _name.text.trim(),
      price: price,
      image: _image.text.trim(),
      category: _category,
      tag: _tag.text.trim().isEmpty ? null : _tag.text.trim(),
      active: _active,
    );
    await widget.onSubmit(data);
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _FormData {
  final String name;
  final int price;
  final String image;
  final String category;
  final String? tag;
  final bool active;
  _FormData({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.tag,
    required this.active,
  });
}
