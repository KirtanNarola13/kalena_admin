import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:kalena_admin/utils/helper/firebase_helper/firestore_helper.dart';

class MyOrderScreen extends StatefulWidget {
  MyOrderScreen({Key? key}) : super(key: key);

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreHelper.firestoreHelper.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.hasData) {
            Map<String, List<DocumentSnapshot<Map<String, dynamic>>>>
                groupedOrders = groupOrdersByCustomer(snapshot.data!.docs);

            return Column(
              children: [
                SafeArea(
                  child: Container(
                    color: Colors.grey.shade300,
                    height: height * 0.05,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Total Order :-",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          groupedOrders.length.toString(),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: groupedOrders.entries.map((entry) {
                      String customerName = entry.key;
                      List<DocumentSnapshot<Map<String, dynamic>>> orders =
                          entry.value;
                      return Card(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: ExpansionTile(
                          title: Text(customerName),
                          children: orders.map((order) {
                            return buildOrderTile(order);
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
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
    return ListTile(
      title: Text('Order ID: ${order.id}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var product in products)
            Container(
              margin: EdgeInsets.all(10),
              height: 150,
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.grey,
                width: 2,
              )),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      child: Image.network(product['image']),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name']),
                        Text(product['description']),
                        Text('${product['price']}'),
                        Text('Quantity: ${product['quantity']}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      dense: true,
      trailing: IconButton(
        icon: Text('Complete'),
        onPressed: () {
          _completeOrder(order.id);
        },
      ),
    );
  }

  Future<void> _completeOrder(String orderId) async {
    try {
      // Get a reference to the order document using the provided order ID
      DocumentReference orderReference =
          FirebaseFirestore.instance.collection("orders").doc(orderId);

      // Delete the order document
      await orderReference.delete();

      log("Order with ID: $orderId deleted successfully");
    } catch (e) {
      log("Error deleting order: $e");
    }
  }
}
