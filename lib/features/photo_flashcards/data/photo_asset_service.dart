import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:langbat/src/services/app_path_service.dart';

class StoredPhotoAsset {
  final String imagePath;
  final String thumbnailPath;

  const StoredPhotoAsset({
    required this.imagePath,
    required this.thumbnailPath,
  });
}

class PhotoAssetService {
  const PhotoAssetService({
    this.paths = const AppPathService(),
    ImagePicker? picker,
  }) : _picker = picker;

  final AppPathService paths;
  final ImagePicker? _picker;

  ImagePicker get picker => _picker ?? ImagePicker();

  Future<List<XFile>> pickMultiplePhotos() {
    return picker.pickMultiImage(
      maxWidth: 2400,
      imageQuality: 95,
    );
  }

  Future<StoredPhotoAsset> storePhoto({
    required String termId,
    required XFile source,
  }) async {
    final bytes = await source.readAsBytes();
    final displayBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 1800,
      minHeight: 1200,
      quality: 82,
      format: CompressFormat.jpeg,
    );
    final thumbBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 480,
      minHeight: 320,
      quality: 72,
      format: CompressFormat.jpeg,
    );

    final root = await paths.termImagesRoot();
    final dir = Directory(p.join(root.path, termId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final imageFile = File(p.join(dir.path, 'front.jpg'));
    final thumbFile = File(p.join(dir.path, 'thumb.jpg'));
    await imageFile.writeAsBytes(displayBytes, flush: true);
    await thumbFile.writeAsBytes(thumbBytes, flush: true);

    return StoredPhotoAsset(
      imagePath: await paths.normalizeToRelativePath(imageFile.path),
      thumbnailPath: await paths.normalizeToRelativePath(thumbFile.path),
    );
  }
}
