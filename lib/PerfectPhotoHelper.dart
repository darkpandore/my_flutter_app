import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class PerfectPhotoHelper {
  final ImagePicker _picker = ImagePicker();

  // Fonction pour ouvrir l'appareil photo
  Future<File?> takePhoto(BuildContext context) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return null;

    // Amélioration et recadrage après capture
    return await _processPhoto(File(photo.path));
  }

  // Fonction pour sélectionner une image existante
  Future<File?> pickExistingPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo == null) return null;

    return await _processPhoto(File(photo.path));
  }

  // Fonction de traitement de l'image (recadrage et ajustement)
  Future<File?> _processPhoto(File imageFile) async {
    // Recadrage au format carré
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer la photo',
          lockAspectRatio: true,
        ),
      ],
    );

    if (croppedFile == null) return null;

    // Amélioration de l'image (luminosité, contraste)
    return _enhancePhoto(File(croppedFile.path));
  }

  // Fonction d'amélioration (contraste, luminosité)
  Future<File> _enhancePhoto(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage != null) {
      // Appliquer une amélioration automatique
      img.Image enhancedImage = img.adjustColor(
        originalImage,
        brightness: 0.15, // Légère augmentation de la luminosité
        contrast: 1.2,   // Augmentation du contraste
      );

      // Recadrage automatique centré
      int size = originalImage.width > originalImage.height ? originalImage.height : originalImage.width;
      enhancedImage = img.copyCrop(
        enhancedImage,
        x: (enhancedImage.width - size) ~/ 2,
        y: (enhancedImage.height - size) ~/ 2,
        width: size,
        height: size,
      );

      final directory = imageFile.parent;
      final processedFilePath = '${directory.path}/enhanced_photo.jpg';
      File(processedFilePath).writeAsBytesSync(img.encodeJpg(enhancedImage, quality: 90));
      return File(processedFilePath);
    } else {
      return imageFile; // Si l'image ne peut être optimisée, retourne l'originale.
    }
  }
}
