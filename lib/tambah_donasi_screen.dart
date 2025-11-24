import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TambahDonasiScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onDonasiAdded;

  const TambahDonasiScreen({
    super.key,
    required this.onDonasiAdded,
  });

  @override
  State<TambahDonasiScreen> createState() => _TambahDonasiScreenState();
}

class _TambahDonasiScreenState extends State<TambahDonasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = 'Pakaian';
  String _selectedCondition = 'Sangat Baik';
  String? _imagePath;
  Uint8List? _webImageBytes;

  final List<String> _categories = [
    'Pakaian',
    'Sepatu',
    'Aksesoris',
    'Buku',
    'Elektronik',
    'Perabotan',
    'Mainan',
    'Lainnya',
  ];

  final List<String> _conditions = [
    'Sangat Baik',
    'Baik',
    'Cukup Baik',
    'Perlu Perbaikan',
  ];

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.orange),
              ),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: Colors.orange),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _imagePath = null;
          });
        } else {
          setState(() {
            _imagePath = pickedFile.path;
            _webImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _webImageBytes = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imagePath == null && _webImageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan unggah foto barang terlebih dahulu')),
        );
        return;
      }

      Uint8List? imageData;

      if (kIsWeb && _webImageBytes != null) {
        imageData = _webImageBytes;
      } else if (_imagePath != null) {
        imageData = await File(_imagePath!).readAsBytes();
      }

      final newDonation = {
        'name': _nameController.text.trim(),
        'desc': _descController.text.trim(),
        'contact': _contactController.text.trim(),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'image': imageData != null ? base64Encode(imageData) : null,
        'isBase64': true,
        'isMyDonation': true, 
      };

      print('TambahDonasiScreen - newDonation: $newDonation');

      widget.onDonasiAdded(newDonation);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[600]!, Colors.orange[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Tambah Donasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              _buildNameField(),
              _buildDescField(),
              _buildCategoryDropdown(),
              _buildConditionDropdown(),
              _buildContactField(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Tambahkan Donasi',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Foto Barang *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
                image: _imagePath != null
                    ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                    : _webImageBytes != null
                        ? DecorationImage(image: MemoryImage(_webImageBytes!), fit: BoxFit.cover)
                        : null,
              ),
              child: _imagePath == null && _webImageBytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 50, color: Colors.grey[600]),
                        const SizedBox(height: 12),
                        Text('Ketuk untuk unggah foto',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('Ambil foto atau pilih dari galeri',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange[600],
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text('Ganti Foto',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 25),
        ],
      );

  Widget _buildNameField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nama Barang *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Contoh: Baju Bekas Layak Pakai',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Nama barang tidak boleh kosong' : null,
          ),
          const SizedBox(height: 20),
        ],
      );

  Widget _buildDescField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deskripsi *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Jelaskan kondisi barang, ukuran, warna, dll',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => value == null || value.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
          ),
          const SizedBox(height: 20),
        ],
      );

  Widget _buildCategoryDropdown() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value!),
          ),
          const SizedBox(height: 20),
        ],
      );

  Widget _buildConditionDropdown() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kondisi *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCondition,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _conditions.map((condition) {
              return DropdownMenuItem(value: condition, child: Text(condition));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCondition = value!),
          ),
          const SizedBox(height: 20),
        ],
      );

  Widget _buildContactField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nomor Kontak *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Contoh: 0812-3456-7890',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Nomor kontak tidak boleh kosong' : null,
          ),
        ],
      );
}