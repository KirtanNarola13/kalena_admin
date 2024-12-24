import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kalena_admin/utils/helper/firebase_helper/firestore_helper.dart';

class EditProduct extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> product;

  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  List<String> _categories = []; // To hold category data
  String? _updatedImageUrl;

  @override
  void initState() {
    super.initState();
    super.initState();
    _nameController.text = widget.product['name'];
    _priceController.text = widget.product['price'].toString();
    _mrpController.text = widget.product['mrp'].toString();
    _rateController.text = widget.product['rate'].toString();
    _stockController.text = widget.product['stoke'].toString();
    log("${widget.product['image']}");
    _descriptionController.text = widget.product['description'];
    _selectedCategory = widget.product['category'];

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('category').get();
    setState(
      () {
        _categories =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImageContainer(
                imageUrl: widget.product['image'], // Product image URL
                onTap: () async {
                  // Logic to pick a new image
                  String? newImageUrl =
                      await _pickNewImage(); // Implement this function
                  if (newImageUrl != null) {
                    setState(() async {
                      await FirebaseFirestore.instance
                          .collection(
                              'products') // Replace with your collection name
                          .doc(widget.product.id) // Use the document ID
                          .update(
                              {'image': newImageUrl}); // Update the image URL

                      // Optionally, show a success message
                      Get.snackbar('Success', 'Image updated successfully');
                    });
                  }
                },
              ),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.text_fields,
              ),
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _mrpController,
                label: 'MRP',
                icon: Icons.money_off,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _rateController,
                label: 'Rate',
                icon: Icons.trending_up,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _stockController,
                label: 'Stock',
                icon: Icons.storage,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) => setState(() => _selectedCategory = value),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null ? 'Select category' : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    _showLoader(context); // Show loader
                    try {
                      await FirestoreHelper.firestoreHelper.updateProduct(
                        widget.product.id,
                        {
                          'name': _nameController.text,
                          'price': double.parse(_priceController.text),
                          'mrp': double.parse(_mrpController.text),
                          'rate': double.parse(_rateController.text),
                          'stoke': int.parse(_stockController.text),
                          'description': _descriptionController.text,
                          'category': _selectedCategory ?? 'Uncategorized',
                        },
                      );
                      Get.snackbar('Success', 'Product updated successfully');
                      Get.back();
                    } catch (e) {
                      Get.snackbar('Error', 'Failed to update product: $e');
                    } finally {
                      _hideLoader(context); // Hide loader
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Function to show loader
  void _showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

// Function to hide loader
  void _hideLoader(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<String?> _pickNewImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _showLoader(context); // Show loader
      try {
        // Upload to Firebase or any storage and get the new URL
        String imageUrl = await uploadImageToFirebase(image.path);
        setState(() {
          _updatedImageUrl = imageUrl;
        });
        return imageUrl;
      } catch (e) {
        Get.snackbar('Error', 'Failed to upload image: $e');
      } finally {
        _hideLoader(context); // Hide loader
      }
    }
    return null;
  }

  Widget _buildProductImageContainer({
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
            image: (_updatedImageUrl ?? imageUrl).isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(_updatedImageUrl ?? imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (_updatedImageUrl ?? imageUrl).isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.image, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to select image',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Future<String> uploadImageToFirebase(String imagePath) async {
    try {
      // Create a unique filename using a timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Reference to Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('product_images/$fileName');

      // Upload the image file
      File file = File(imagePath);
      final uploadTask = await storageRef.putFile(file);

      // Get the download URL
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw 'Image upload failed!';
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
