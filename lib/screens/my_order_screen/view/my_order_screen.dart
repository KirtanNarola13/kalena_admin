import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kalena_admin/utils/helper/firebase_helper/firestore_helper.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreHelper.firestoreHelper.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> orders =
                snapshot.data!.docs;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                List<dynamic> products = order['products'];
                log(order.toString());
                return Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Iterate over products and display their information
                            for (var product in products)
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(10),
                                height: height * 0.32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                      15,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                "${product['image']},"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                product['name'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                product['description'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "${orders[index]['address']}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                            Expanded(
                                              child:
                                                  Text("${product['price']}"),
                                            ),
                                            Divider(),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text("Quantity : "),
                                                  Text(
                                                      "${product['quantity']}"),
                                                ],
                                              ),
                                            ),
                                            Divider(),
                                            TextButton(
                                              onPressed: () {
                                                _completeOrder(
                                                    order.id,
                                                    product[
                                                        'id']); // Assuming product['id'] is the productId
                                              },
                                              child: Text("Complete Order"),
                                            ),
                                          ],
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
                  ],
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<void> _completeOrder(String orderId, String productId) async {
    try {
      // Get a reference to the order document using the provided order ID
      DocumentReference orderReference =
          FirebaseFirestore.instance.collection("orders").doc(orderId);

      // Fetch the order document
      DocumentSnapshot orderSnapshot = await orderReference.get();

      if (orderSnapshot.exists) {
        // Get the list of products from the order
        List<dynamic> products = orderSnapshot.get('products');

        // Find the index of the product in the 'products' array
        int index =
            products.indexWhere((product) => product['id'] == productId);

        if (index != -1) {
          // Remove the product from the 'products' array
          products.removeAt(index);

          // Update the 'products' field in the order document
          await orderReference.update({'products': products});

          log("Product with ID: $productId removed from order with ID: $orderId");
        } else {
          log("Product with ID: $productId not found in order with ID: $orderId");
        }
      } else {
        log("Order with ID: $orderId does not exist.");
      }
    } catch (e) {
      log("Error removing product from order: $e");
    }
  }
}
