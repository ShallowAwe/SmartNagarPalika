import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);
      return file;
    } catch (e) {
      print('[CameraService] Error: $e');
      return null;
    }
  }

  Future<XFile?> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      return file;
    } catch (e) {
      print('[CameraService] Gallery Error: $e');
      return null;
    }
  }
}
