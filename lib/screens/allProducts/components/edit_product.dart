import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product['name'];
    _priceController.text = widget.product['price'].toString();
    _mrpController.text = widget.product['mrp'].toString();
    _rateController.text = widget.product['rate'].toString();
    _stockController.text = widget.product['stoke'].toString();
    _descriptionController.text = widget.product['description'];
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
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await FirestoreHelper.firestoreHelper.updateProduct(
                      widget.product.id,
                      {
                        'name': _nameController.text,
                        'price': double.parse(_priceController.text),
                        'mrp': double.parse(_mrpController.text),
                        'rate': double.parse(_rateController.text),
                        'stoke': int.parse(_stockController.text),
                        'description': _descriptionController.text,
                      },
                    );
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
