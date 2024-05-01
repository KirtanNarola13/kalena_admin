import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListingScreen extends StatefulWidget {
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
  final TextEditingController _MRPController = TextEditingController();
  final TextEditingController _productRate = TextEditingController();

  XFile? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 520, maxWidth: 520);
    setState(() {
      _imageFile = image;
    });
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      // Check if Firebase has been initialized
      if (firebase_storage.FirebaseStorage.instance.app == null) {
        await Firebase.initializeApp();
      }

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().millisecondsSinceEpoch}.png');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _addProduct() async {
    setState(() {
      _isUploading = true;
    });

    String imageUrl = await _uploadImageToFirebase(File(_imageFile!.path));

    // Get other product details
    String productName = _productNameController.text;
    double productPrice = double.parse(_productPriceController.text);
    double MRP = double.parse(_MRPController.text);
    double stoke = double.parse(_stokeController.text);
    String productDescription = _productDescriptionController.text;
    String productSku = _productSkuController.text;
    String productRate = _productRate.text;

    // Store product details in Firestore
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'image': imageUrl,
        'name': productName,
        'mrp': MRP,
        'price': productPrice,
        'rate': productRate,
        'stoke': stoke,
        'description': productDescription,
        'sku': productSku,
      });

      // Once the product is added, reset the form
      _productNameController.clear();
      _productPriceController.clear();
      _productDescriptionController.clear();
      _productSkuController.clear();
      _productRate.clear();
      _MRPController.clear();
      _stokeController.clear();
      setState(() {
        _imageFile = null;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
        ),
      );
    } catch (e) {
      print('Error adding product to Firestore: $e');
      setState(() {
        _isUploading = false;
      });
    }
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
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _productRate,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Purchase Rate',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _MRPController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'MRP',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _productPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Product Price',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _stokeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _productDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Product Description',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _productSkuController,
                decoration: const InputDecoration(
                  labelText: 'Product SKU',
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
