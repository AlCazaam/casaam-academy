import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io; // Conditional Import

class CloudinaryService {
  final String cloudName = "dglg5masi";
  final String uploadPreset = "ttxxuuiis";

  // Upload image (Mobile)
  Future<String?> uploadImage(XFile imageFile) async {
    String url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(imageFile.path),
      "upload_preset": uploadPreset,
    });

    try {
      var response = await Dio().post(url, data: formData);
      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
    }
    return null;
  }

  // Upload image (Web)
  Future<String?> uploadImageBytes(Uint8List imageBytes) async {
    String url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(imageBytes, filename: "upload.jpg"),
      "upload_preset": uploadPreset,
    });

    try {
      var response = await Dio().post(url, data: formData);
      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
    }
    return null;
  }

  Future<String> uploadFile(dynamic file) async {
    String url = "https://api.cloudinary.com/v1_1/$cloudName/upload";

    FormData formData;
    if (file is io.File) {
      // Native platform
      formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
        "upload_preset": uploadPreset,
      });
    } else if (file is Uint8List) {
      // Web platform (Uint8List)
      formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(file, filename: "upload.pdf"),
        "upload_preset": uploadPreset,
      });
    } else {
      throw ArgumentError("Unsupported file type.  Must be File or Uint8List.");
    }

    try {
      var response = await Dio().post(url, data: formData);
      if (response.statusCode == 200) {
        return response.data["secure_url"];
      } else {
        print(
            "Cloudinary Upload Failed: ${response.statusCode} - ${response.statusMessage} - ${response.data}");
        throw Exception(
            "Cloudinary Upload Failed: ${response.statusCode} - ${response.statusMessage}");
      }
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      rethrow;
    }
  }
}