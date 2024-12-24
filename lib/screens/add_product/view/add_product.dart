import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productSkuController = TextEditingController();
  final TextEditingController _stokeController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _productRate = TextEditingController();
  final TextEditingController categorycon = TextEditingController();

  XFile? _imageFile;
  bool _isUploading = false;
  String? _category;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 520, maxWidth: 520);
    setState(
      () {
        _imageFile = image;
      },
    );
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().millisecondsSinceEpoch}.png');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return '';
    }
  }

  Future<void> _addProduct() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image.')),
      );
      return;
    }

    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    String imageUrl = await _uploadImageToFirebase(File(_imageFile!.path));
    if (imageUrl.isEmpty) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed. Please try again.')),
      );
      return;
    }

    double productPrice;
    double mrp;
    int stock;
    try {
      productPrice = double.parse(_productPriceController.text);
      mrp = double.parse(_mrpController.text);
      stock = int.parse(_stokeController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid input. Please check your fields.')),
      );
      setState(() => _isUploading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'image': imageUrl,
        'name': _productNameController.text,
        'mrp': mrp,
        'price': productPrice,
        'rate': _productRate.text,
        'stoke': stock,
        'category': _category ?? 'Uncategorized',
        'description': _productDescriptionController.text,
        'sku': _productSkuController.text,
      });

      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
    } catch (e) {
      if (kDebugMode) print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error adding product. Please try again.')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _clearFields() {
    _productNameController.clear();
    _productPriceController.clear();
    _productDescriptionController.clear();
    _productSkuController.clear();
    _productRate.clear();
    _mrpController.clear();
    _stokeController.clear();
    categorycon.clear();
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _imageFile == null
                  ? const Text('No image selected.')
                  : Image.file(File(_imageFile!.path)),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextField(
                controller: _productRate,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Purchase Rate',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextField(
                controller: _mrpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'MRP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _productPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Product Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _stokeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('category')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    value: _category,
                    onChanged: (value) => setState(() => _category = value),
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['name'],
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'Select category' : null,
                  );
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _productDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Product Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _productSkuController,
                decoration: const InputDecoration(
                  labelText: 'Product SKU',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              _isUploading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _addProduct,
                      child: const Text('Add Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
