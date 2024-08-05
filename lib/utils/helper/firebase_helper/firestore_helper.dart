import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {

  FirestoreHelper._();

  static FirestoreHelper firestoreHelper = FirestoreHelper._();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> fatcheProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  deleteProduct(String id) {
    FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchOrders() {
    return firestore.collection('orders').snapshots();
  }
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await firestore.collection('products').doc(productId).update(data);
  }
  Future<void> updateproduct(String productId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).update(data);
  }
}
