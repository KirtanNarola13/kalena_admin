import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class FirebaseHelper {
  FirebaseHelper._();
  static FirebaseHelper firebaseHelper = FirebaseHelper._();
  Future<Uint8List?> pickImage(ImageSource imageSource) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: imageSource);
    if (_file != null) {
      Uint8List img = await _file.readAsBytes();
      return img;
    }
    print('No image selected');
  }
}
