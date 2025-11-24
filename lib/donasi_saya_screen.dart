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
  late List<Map<String, dynamic>> _myDonations;

  @override
  void initState() {
    super.initState();
    _refreshMyDonations();
    print('🔥 DonasiSayaScreen INIT - total items: ${widget.items.length}');
  }

  @override
  void didUpdateWidget(covariant DonasiSayaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('🔥 DonasiSayaScreen didUpdateWidget');
    print('🔥 OLD items: ${oldWidget.items.length}');
    print('🔥 NEW items: ${widget.items.length}');
    
    _refreshMyDonations();
  }

  void _refreshMyDonations() {
    setState(() {
      _myDonations = widget.items
          .where((item) => item['isMyDonation'] == true)
          .toList();
      
      print('🔥 After filter - _myDonations: ${_myDonations.length}');
      for (var item in _myDonations) {
        print('  - ${item['name']} (ID: ${item['id']})');
      }
    });
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

  Widget _buildImage(Map<String, dynamic> item) {
    try {
      final imageData = item['image'];

      if (imageData == null || imageData.toString().isEmpty) {
        return Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
        );
      }

      if (item['isBase64'] == true) {
        return Image.memory(
          base64Decode(imageData),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[600]),
          ),
        );
      } else {
        // File path image
        final file = File(imageData);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, color: Colors.grey[600]),
            ),
          );
        } else {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
          );
        }
      }
    } catch (e) {
      print('Error loading image: $e');
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey[300],
        child: Icon(Icons.broken_image, color: Colors.grey[600]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD DonasiSayaScreen - _myDonations: ${_myDonations.length}');
    
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
                      item['name'] ?? 'Tanpa nama',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Kategori: ${item['category'] ?? '-'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kondisi: ${item['condition'] ?? '-'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item['isClaimed'] == true
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['isClaimed'] == true
                                ? '✓ Diklaim'
                                : '⏳ Menunggu Diklaim',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: item['isClaimed'] == true
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
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
                onDonasiAdded: (newDonation) {
                  print('🔥 DonasiSayaScreen received newDonation: $newDonation');
                  
                  int newId = widget.items.isEmpty
                      ? 1
                      : widget.items
                              .map((item) => item['id'] as int)
                              .reduce((a, b) => a > b ? a : b) +
                          1;

                  final donationItem = {
                    'id': newId,
                    'image': newDonation['image'],
                    'name': newDonation['name'],
                    'desc': newDonation['desc'],
                    'contact': newDonation['contact'],
                    'category': newDonation['category'],
                    'condition': newDonation['condition'],
                    'isClaimed': false,
                    'isMyDonation': true, // 🔥 PENTING!
                    'isBase64': newDonation['isBase64'] ?? false,
                  };

                  setState(() {
                    widget.items.add(donationItem);
                  });
                  widget.onItemsChanged(widget.items);
                  _refreshMyDonations();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                '${newDonation['name']} berhasil ditambahkan!'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(20),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.orange[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}