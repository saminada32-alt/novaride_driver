import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Pick → square/circle crop (WhatsApp-style) → JPEG compress.
Future<File?> pickCropProfilePhoto(ImageSource source) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    imageQuality: 95,
  );
  if (picked == null) return null;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressQuality: 88,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop',
        toolbarColor: const Color(0xff1DBF73),
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
        cropStyle: CropStyle.circle,
        hideBottomControls: false,
      ),
      IOSUiSettings(
        title: 'Crop',
        cropStyle: CropStyle.circle,
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    ],
  );
  if (cropped == null) return null;

  final dir = await getTemporaryDirectory();
  final outPath =
      '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final compressed = await FlutterImageCompress.compressAndGetFile(
    cropped.path,
    outPath,
    quality: 88,
    format: CompressFormat.jpeg,
    keepExif: false,
  );

  return File(compressed?.path ?? cropped.path);
}

Future<void> showProfilePhotoSourceSheet(
  BuildContext context, {
  required Future<void> Function(File file) onPicked,
  required String cameraLabel,
  required String galleryLabel,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xff1DBF73)),
            title: Text(cameraLabel),
            onTap: () async {
              Navigator.pop(ctx);
              final file = await pickCropProfilePhoto(ImageSource.camera);
              if (file != null) await onPicked(file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xff1DBF73)),
            title: Text(galleryLabel),
            onTap: () async {
              Navigator.pop(ctx);
              final file = await pickCropProfilePhoto(ImageSource.gallery);
              if (file != null) await onPicked(file);
            },
          ),
        ],
      ),
    ),
  );
}
