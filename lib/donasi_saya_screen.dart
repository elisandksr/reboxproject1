import 'package:flutter/material.dart';
import 'tambah_donasi_screen.dart';
import 'dart:convert';
import 'dart:io';

class DonasiSayaScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(List<Map<String, dynamic>>) onItemsChanged;

  const DonasiSayaScreen({
    super.key,
    required this.items,
    required this.onItemsChanged,
  });

  @override
  State<DonasiSayaScreen> createState() => _DonasiSayaScreenState();
}

class _DonasiSayaScreenState extends State<DonasiSayaScreen> {
  List<Map<String, dynamic>> _myDonations = [];

  @override
  void initState() {
    super.initState();
    _updateMyDonations();
  }

  void _updateMyDonations() {
    setState(() {
      _myDonations = widget.items
          .where((item) => item['isMyDonation'] == true)
          .toList();
    });
  }

  void _addDonation(Map<String, dynamic> newItem) {
    int newId = widget.items.isEmpty
        ? 1
        : widget.items
                .map((item) => item['id'] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final donationItem = {
      'id': newId,
      'image': newItem['image'] ?? 'assets/logo_rebox.png',
      'name': newItem['name'],
      'desc': newItem['desc'],
      'contact': newItem['contact'],
      'category': newItem['category'],
      'condition': newItem['condition'],
      'isClaimed': false,
      'isMyDonation': true,
      'isBase64': newItem['isBase64'] ?? false,
    };

    setState(() {
      widget.items.add(donationItem);
      _myDonations.add(donationItem);
    });

    widget.onItemsChanged(widget.items);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${newItem['name']} berhasil ditambahkan!'),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteDonation(int index) {
    final item = _myDonations[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Hapus Donasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Hapus ${item['name']} dari donasi Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                widget.items.removeWhere((i) => i['id'] == item['id']);
                _myDonations.removeAt(index);
              });
              widget.onItemsChanged(widget.items);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Donasi berhasil dihapus'),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(20),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _myDonations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_outlined,
                      size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    'Belum ada donasi Anda',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mulai donasikan barang bekas Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _myDonations.length,
              itemBuilder: (context, index) {
                final item = _myDonations[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildImage(item),
                    ),
                    title: Text(
                      item['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          item['category'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['isClaimed'] == true
                              ? 'Status: Diklaim'
                              : 'Status: Menunggu',
                          style: TextStyle(
                            fontSize: 11,
                            color: item['isClaimed'] == true
                                ? Colors.green[600]
                                : Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                      onPressed: () => _deleteDonation(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahDonasiScreen(
                onDonasiAdded: _addDonation,
              ),
            ),
          );
        },
        backgroundColor: Colors.orange[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ✅ BAGIAN YANG DITAMBAHKAN UNTUK FIX GAMBAR MERAH / BASE64
  Widget _buildImage(Map<String, dynamic> item) {
    try {
      final imageData = item['image'];

      if (imageData == null || imageData.toString().isEmpty) {
        return Image.asset(
          'assets/logo_rebox.png',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        );
      }

      if (item['isBase64'] == true) {
        // Decode base64 (untuk web & mobile)
        return Image.memory(
          base64Decode(imageData),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/logo_rebox.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      } else {
        final file = File(imageData);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          );
        } else {
          return Image.asset(
            'assets/logo_rebox.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          );
        }
      }
    } catch (e) {
      return Image.asset(
        'assets/logo_rebox.png',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    }
  }
}