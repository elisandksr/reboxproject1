import 'dart:convert';
import 'package:flutter/material.dart';
import 'donasi_saya_screen.dart';
import 'profil_saya_screen.dart';
import 'lihat_detail_screen.dart';
import 'tambah_donasi_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? username;

  const HomeScreen({super.key, this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;

  List<Map<String, dynamic>> items = [
    {
             'id': 1,
      'image': 'assets/baju1.jpeg',
      'name': 'Baju Bekas Layak Pakai',
      'desc': 'Masih bagus, bersih, dan jarang dipakai. Cocok untuk donasi ke panti asuhan atau wilayah bencana. Bahan katun lembut dan tebal.',
      'contact': '0812-3456-7890',
      'category': 'Pakaian',
      'condition': 'Sangat Baik',
      'isClaimed': false,
      'isMyDonation': false,
    },
    {
      'id': 2,
      'image': 'assets/sepatu1.jpg',
      'name': 'Sepatu Olahraga Merk Adinda',
      'desc': 'Kondisi 90%, ukuran 40. Cocok untuk lari atau kegiatan outdoor. Bagian sol masih tebal dan tidak ada yang robek.',
      'contact': '26476326497268',
      'category': 'Sepatu',
      'condition': 'Baik',
      'isClaimed': false,
      'isMyDonation': false,
    },
    {
      'id': 3,
      'image': 'assets/tas.jpg',
      'name': 'Tas Sekolah Multifungsi',
      'desc': 'Masih kuat, resleting berfungsi semua, dan bagus. Jarang dipakai karena sudah lulus sekolah. Ada banyak sekat penyimpanan.',
      'contact': '0813-8888-7777',
      'category': 'Aksesoris',
      'condition': 'Sangat Baik',
      'isClaimed': false,
      'isMyDonation': false,
    },
    {
      'id': 4,
      'image': 'assets/jaket2.webp',
      'name': 'Jaket Musim Dingin Tebal',
      'desc': 'Hangat dan nyaman, ukuran M. Cocok untuk daerah pegunungan atau cuaca dingin. Warna navy gelap, bersih dari noda.',
      'contact': '0856-1234-5678',
      'category': 'Pakaian',
      'condition': 'Baik',
      'isClaimed': false,
      'isMyDonation': false,
    },
    {
      'id': 5,
      'image': 'assets/buku.jpg',
      'name': 'Buku Pelajaran SMA Lengkap',
      'desc': 'Lengkap 1 paket kelas 10, 11, dan 12. Masih bagus, hanya sedikit coretan pensil. Sangat membantu untuk belajar.',
      'contact': '0877-9876-5432',
      'category': 'Buku',
      'condition': 'Cukup Baik',
      'isClaimed': false,
      'isMyDonation': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    print('HomeScreen initState - items: ${items.length}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    print('Tab tapped: $index');
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return items;
    }
    return items.where((item) {
      return item['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['desc']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['category']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _claimItem(Map<String, dynamic> item) {
    setState(() {
      int idx = items.indexWhere((i) => i['id'] == item['id']);
      if (idx != -1) {
        items[idx]['isClaimed'] = true;
      }
    });
  }

  void _showItemDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailItemScreen(
          item: item,
          onClaimItem: _claimItem,
        ),
      ),
    );
  }

  int _generateNewId() {
    if (items.isEmpty) return 1;
    int maxId = items.map((item) => item['id'] as int).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  void _addDonation(Map<String, dynamic> newDonation) {
    print('_addDonation called');
    print('newDonation: $newDonation');

    int newId = _generateNewId();
    print(' Generated ID: $newId');

    final donationItem = {
      'id': newId,
      'image': newDonation['image'] ?? 'assets/logo_rebox.png',
      'name': newDonation['name'],
      'desc': newDonation['desc'],
      'contact': newDonation['contact'],
      'category': newDonation['category'],
      'condition': newDonation['condition'],
      'isClaimed': false,
      'isMyDonation': true, 
      'isBase64': newDonation['isBase64'] ?? false,
    };

    print(' Final donationItem: $donationItem');

    setState(() {
      items.add(donationItem);
      print(' Total items setelah add: ${items.length}');
      print(' Items sekarang: ');
      for (var item in items) {
        print('  - ${item['name']} (isMyDonation: ${item['isMyDonation']})');
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${newDonation['name']} berhasil ditambahkan!'),
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

  Widget _buildItemCard(Map<String, dynamic> item) {
    final isClaimed = item['isClaimed'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: item['isBase64'] == true && item['image'] != null
                      ? Image.memory(
                          base64Decode(item['image']),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/logo_rebox.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          item['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey[600]),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    item['category']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isClaimed)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['desc'] ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 59, 59, 59),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isClaimed ? Colors.grey[400] : Colors.orange[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isClaimed ? null : () => _showItemDetail(item),
                      child: Text(
                        isClaimed ? 'Diklaim' : 'Lihat Detail',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build - selectedIndex: $_selectedIndex, items: ${items.length}');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[600]!,
                Colors.orange[400]!,
              ],
            ),
          ),
        ),
        title: const Text(
          'REBOX',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          DonasiSayaScreen(
            items: items,
            onItemsChanged: (newItems) {
              print('onItemsChanged called - newItems: ${newItems.length}');
              setState(() {
                items = newItems;
              });
            },
          ),
          ProfilSayaScreen(username: widget.username),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orange[600],
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 26),
              activeIcon: Icon(Icons.home, size: 26),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_outlined, size: 26),
              activeIcon: Icon(Icons.card_giftcard, size: 26),
              label: 'Donasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 26),
              activeIcon: Icon(Icons.person, size: 26),
              label: 'Profil',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: Colors.orange[600],
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                print('FAB pressed di tab Donasi Saya');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TambahDonasiScreen(
                      onDonasiAdded: _addDonation,
                    ),
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange[600]!,
                  Colors.orange[400]!,
                  Colors.orange[300]!,
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${widget.username ?? "User"}! 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Temukan barang bekas yang layak pakai',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari barang bekas...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.orange[600]),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: _filteredItems.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text(
                          'Barang tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredItems[index];
                      return _buildItemCard(item);
                    },
                    childCount: _filteredItems.length,
                  ),
                ),
        ),
      ],
    );
  }
}