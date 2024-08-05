
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseHelper {
  FirebaseHelper._();
  static FirebaseHelper firebaseHelper = FirebaseHelper._();
  Future<Uint8List?> pickImage(ImageSource imageSource) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: imageSource);
    if (file != null) {
      Uint8List img = await file.readAsBytes();
      return img;
    }
    if (kDebugMode) {
      print('No image selected');
    }
    return null;
  }
}
