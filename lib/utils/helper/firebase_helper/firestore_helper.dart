import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirestoreHelper._();
  static FirestoreHelper firestoreHelper = FirestoreHelper._();

  Stream<QuerySnapshot<Map<String, dynamic>>> fatcheProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  deleteProduct(String id) {
    FirebaseFirestore.instance.collection('products').doc(id).delete();
  }
}
