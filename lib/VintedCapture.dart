import 'package:flutter/material.dart';
import 'dart:io'; // Pour manipuler les fichiers

import 'PerfectPhotoHelper.dart'; // Import de la classe PerfectPhotoHelper

class VintedCapture extends StatefulWidget {
  const VintedCapture({super.key});

  @override
  _VintedCaptureState createState() => _VintedCaptureState();
}

class _VintedCaptureState extends State<VintedCapture> {
  File? _selectedPhoto; // Stocke la photo capturée
  final PerfectPhotoHelper _photoHelper = PerfectPhotoHelper(); // Instance de PerfectPhotoHelper

  Future<void> _takePhoto() async {
    try {
      // Utilisation de la classe PerfectPhotoHelper pour capturer et améliorer la photo
      File? photo = await _photoHelper.takePhoto(context);

      if (photo != null && mounted) {
        setState(() {
          _selectedPhoto = photo; // Sauvegarde la photo dans un fichier après amélioration
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo capturée et optimisée avec succès !")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la prise de la photo : $e")),
        );
      }
    }
  }

  Future<void> _pickExistingPhoto() async {
    try {
      File? photo = await _photoHelper.pickExistingPhoto(); // Sélection d'une photo depuis la galerie

      if (photo != null && mounted) {
        setState(() {
          _selectedPhoto = photo;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo sélectionnée et optimisée avec succès !")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la sélection de la photo : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Optimisée pour Vinted"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhoto, // Prendre une photo via la caméra
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Prendre une photo"),
                ),
                ElevatedButton.icon(
                  onPressed: _pickExistingPhoto, // Choisir une photo depuis la galerie
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Choisir une photo"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Prévisualisation de l'image capturée
            if (_selectedPhoto != null)
              Column(
                children: [
                  const Text(
                    "Prévisualisation de l'image",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedPhoto!,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover, // Cadrage optimal pour Vinted
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedPhoto = null; // Réinitialise la photo
                      });
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Supprimer la photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              )
            else
              const Text(
                "Aucune photo capturée pour l'instant.",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
