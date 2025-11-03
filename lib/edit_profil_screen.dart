import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilDialog {
  static void show(
    BuildContext context, {
    required String displayName,
    required String email,
    required String phone,
    required Function(String, String, String, dynamic) onSave, // ✅ terima File atau Uint8List
  }) {
    final nameController = TextEditingController(text: displayName);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phone);
    final ImagePicker picker = ImagePicker();

    Uint8List? webImageBytes;
    File? imageFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final picked = await picker.pickImage(source: ImageSource.gallery);
            if (picked != null) {
              if (kIsWeb) {
                final bytes = await picked.readAsBytes();
                setState(() {
                  webImageBytes = bytes;
                });
              } else {
                setState(() {
                  imageFile = File(picked.path);
                });
              }
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Edit Profil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: webImageBytes != null
                              ? MemoryImage(webImageBytes!)
                              : imageFile != null
                                  ? FileImage(imageFile!)
                                  : const AssetImage('assets/default_profile.png')
                                      as ImageProvider,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // ✅ Kirim sesuai platform
                  final imageToSend = kIsWeb ? webImageBytes : imageFile;
                  onSave(
                    nameController.text,
                    emailController.text,
                    phoneController.text,
                    imageToSend,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Simpan',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}