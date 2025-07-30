import 'package:image_picker/image_picker.dart';
import 'logger_service.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();
  final _logger = LoggerService.instance;

  Future<XFile?> pickFromCamera() async {
    _logger.methodEntry('pickFromCamera');

    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);

      if (file != null) {
        _logger.fileOperation('picked from camera', file.path);
        _logger.methodExit('pickFromCamera', 'File selected: ${file.path}');
      } else {
        _logger.info('Camera pick cancelled by user');
        _logger.methodExit('pickFromCamera', 'No file selected');
      }

      return file;
    } catch (e) {
      _logger.error('Failed to pick image from camera', e);
      _logger.methodExit('pickFromCamera', 'Error occurred');
      return null;
    }
  }

  Future<XFile?> pickFromGallery() async {
    _logger.methodEntry('pickFromGallery');

    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        _logger.fileOperation('picked from gallery', file.path);
        _logger.methodExit('pickFromGallery', 'File selected: ${file.path}');
      } else {
        _logger.info('Gallery pick cancelled by user');
        _logger.methodExit('pickFromGallery', 'No file selected');
      }

      return file;
    } catch (e) {
      _logger.error('Failed to pick image from gallery', e);
      _logger.methodExit('pickFromGallery', 'Error occurred');
      return null;
    }
  }
}
