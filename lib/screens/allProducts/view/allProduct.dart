import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalena_admin/utils/helper/firebase_helper/firestore_helper.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: StreamBuilder(
        stream: FirestoreHelper.firestoreHelper.fatcheProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>? products =
                snapshot.data?.docs;
            return ListView.builder(
                itemCount: products?.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: h / 3.5,
                    width: w / 0.9,
                    margin: const EdgeInsets.only(top: 30, left: 20, right: 10),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300.withOpacity(0.3),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(25),
                        ),
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        )),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25),
                              ),
                              image: DecorationImage(
                                  image:
                                      NetworkImage(products![index]['image'])),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 20, left: 10, right: 10, bottom: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          products[index]['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          "₹ ${products[index]['price']}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: h / 80,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "₹ ${products[index]['mrp']}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: h / 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Purchase Rate",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                        SizedBox(
                                          width: w / 120,
                                        ),
                                        Text(
                                          "${products![index]['rate']}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: h / 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Stoke",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                        SizedBox(
                                          width: w / 120,
                                        ),
                                        Text(
                                          "${products![index]['stoke']}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: h / 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Description",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                        SizedBox(
                                          width: w / 120,
                                        ),
                                        Text(
                                          products![index]['description'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: h / 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          'edit_product',
                                          arguments: products[index],
                                        );
                                        setState(() {});
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: h / 30,
                                        width: w / 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            alignment: Alignment.center,
                                            title: Center(
                                                child: const Text(
                                                    "Are you sure ?")),
                                            actionsAlignment:
                                                MainAxisAlignment.center,
                                            actionsPadding:
                                                const EdgeInsets.all(10),
                                            actions: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('cancel'),
                                              ),
                                              OutlinedButton(
                                                onPressed: () {
                                                  FirestoreHelper
                                                      .firestoreHelper
                                                      .deleteProduct(
                                                          products[index].id);
                                                  setState(() {
                                                    Get.back();
                                                  });
                                                },
                                                child: const Text('conform'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: h / 30,
                                        width: w / 8,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.delete_outline_outlined,
                                          color: Colors.red.shade200,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
