import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kalena_admin/utils/helper/firebase_helper/firestore_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Future<File> generatePdf(
      Map<String, dynamic> order, String orderId, double totalPrice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Order Slip', style: pw.TextStyle(fontSize: 24)),
            pw.Divider(),
            pw.Text('Order ID: ${orderId}'),
            pw.Text('Customer Name: ${order['name']}'),
            pw.Text('Contact: ${order['number']}'),
            pw.Text('Address: ${order['address']}'),
            pw.SizedBox(height: 10),
            pw.Text('Products:', style: pw.TextStyle(fontSize: 18)),
            pw.ListView.builder(
              itemCount: order['products'].length,
              itemBuilder: (context, index) {
                final product = order['products'][index];
                return pw.Text(
                  '${product['name']} (x${product['quantity']}) - ${product['price']} /-',
                );
              },
            ),
            pw.Divider(),
            pw.Text(
              'Total Price: ${totalPrice} /-',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    final outputDir = await getTemporaryDirectory();
    final file = File('${outputDir.path}/order_${orderId}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.grey.shade50,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by Customer Name or Order ID',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreHelper.firestoreHelper.fetchOrders(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else if (snapshot.hasData) {
                  Map<String, List<DocumentSnapshot<Map<String, dynamic>>>>
                      groupedOrders =
                      groupOrdersByCustomer(snapshot.data!.docs);

                  // Filter orders by search query
                  if (_searchQuery.isNotEmpty) {
                    groupedOrders.removeWhere((customerName, orders) {
                      return !customerName
                              .toLowerCase()
                              .contains(_searchQuery) &&
                          !orders
                              .any((order) => order.id.contains(_searchQuery));
                    });
                  }

                  if (groupedOrders.isEmpty) {
                    return const Center(
                      child: Text('No orders found for the search query.'),
                    );
                  }

                  return ListView(
                    children: groupedOrders.entries.map((entry) {
                      String customerName = entry.key;
                      List<DocumentSnapshot<Map<String, dynamic>>> orders =
                          entry.value;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            customerName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('Orders: ${orders.length}'),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person),
                          ),
                          children: orders.map((order) {
                            return buildOrderTile(order);
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Group orders by customer name
  Map<String, List<DocumentSnapshot<Map<String, dynamic>>>>
      groupOrdersByCustomer(
          List<DocumentSnapshot<Map<String, dynamic>>> orders) {
    Map<String, List<DocumentSnapshot<Map<String, dynamic>>>> groupedOrders =
        {};

    for (var order in orders) {
      String customerName = order.get('name');
      if (!groupedOrders.containsKey(customerName)) {
        groupedOrders[customerName] = [];
      }
      groupedOrders[customerName]!.add(order);
    }

    return groupedOrders;
  }

  Widget buildOrderTile(DocumentSnapshot<Map<String, dynamic>> order) {
    List<dynamic> products = order['products'];
    double totalPrice = 0;

    // Calculate total price
    for (var product in products) {
      totalPrice += product['price'] * product['quantity'];
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Text('Order ID: ${order.id}',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const Divider(),

          // Products List
          const Text('Products:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          for (var product in products)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'],
                          style: const TextStyle(fontSize: 14)),
                      Text('Quantity: ${product['quantity']}',
                          style: TextStyle(color: Colors.grey.shade600)),
                      Text('₹${product['price']}',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          const Divider(),

          // Contact and Address
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact: ${order['number']}',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Address: ${order['address']}',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),

          Text('Total Price: ₹$totalPrice',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Divider(),
          // Total Price and Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _shareBill(order.id, order.data() ?? {}, totalPrice);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Share Bill',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _completeOrder(order.id, order.data() ?? {}, totalPrice);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Mark Complete',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeOrder(
    String orderId,
    Map<String, dynamic> order,
    double totalPrice,
  ) async {
    try {
      // // Launch WhatsApp
      // if (await canLaunch(url)) {
      //   await launch(url);
      // } else {
      //   log("Could not launch WhatsApp");
      // }
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderId)
          .delete();
      log("Order with ID: $orderId deleted successfully");
    } catch (e) {
      log("Error completing order: $e");
    }
  }

  Future<void> _shareBill(
    String orderId,
    Map<String, dynamic> order,
    double totalPrice,
  ) async {
    try {
      // Generate PDF
      final pdfFile = await generatePdf(order, orderId, totalPrice);

      // Send WhatsApp message
      final whatsappNumber = order['number'];
      final message = Uri.encodeComponent(
        "Hello ${order['name']},\n\nYour order with ID ${order['id']} has been completed. Please find your order slip attached below.\n\nThank you for shopping with us!",
      );
      // final url = "https://wa.me/$whatsappNumber?text=$message";
// Send SMS with PDF
      Share.shareXFiles([XFile(pdfFile.path)],
              text: "Order Slip for Order ID: ${order['id']}")
          .whenComplete(() async {
        // Optionally delete order from Firestore
      });
      log("Order with ID: $orderId deleted successfully");
    } catch (e) {
      log("Error completing order: $e");
    }
  }
}
