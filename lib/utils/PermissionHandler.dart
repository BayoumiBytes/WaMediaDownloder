import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissionhandler {
  static Future<bool> checkPermissions() async {
    bool granted = false;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt > 30) {
      // Android 11+ requires MANAGE_EXTERNAL_STORAGE permission
      final manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isGranted) {
        granted = true;
      } else {
        // Request manage external storage permission
        final result = await Permission.manageExternalStorage.request();
        granted = result.isGranted;
      }
    } else {
      // Android 10 and below - use regular storage permission
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) {
        granted = true;
      } else {
        final result = await Permission.storage.request();
        granted = result.isGranted;
      }
    }
    return granted;
  }
}
