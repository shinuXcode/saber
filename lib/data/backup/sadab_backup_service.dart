import 'dart:typed_data';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:saber/data/file_manager/file_manager.dart';

/// Local-first backup/restore for Sadab A.
class SadabBackupService {
  SadabBackupService._();

  static Future<Uint8List> createBackup() async {
    final archive = Archive();
    final root = Directory(FileManager.documentsDirectory);
    if (!root.existsSync()) await root.create(recursive: true);

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relative = p.relative(entity.path, from: root.path);
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile(relative, bytes.length, bytes));
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) throw StateError('Could not create backup archive');
    return Uint8List.fromList(encoded);
  }

  static Future<bool> saveBackup() async {
    final bytes = await createBackup();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save Sadab A backup',
      fileName: 'sadab-a-backup-${stamp}.zip',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      bytes: bytes,
    );
    return path != null;
  }

  static Future<bool> restoreBackup() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Restore Sadab A backup',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return false;

    final archive = ZipDecoder().decodeBytes(result.files.single.bytes!);
    final root = Directory(FileManager.documentsDirectory);
    await root.create(recursive: true);

    for (final archiveFile in archive.files) {
      if (!archiveFile.isFile) continue;
      final target = p.normalize(p.join(root.path, archiveFile.name));
      final relative = p.relative(target, from: root.path);
      if (relative == '..' || relative.startsWith('../') || p.isAbsolute(relative)) {
        throw FormatException('Unsafe backup path: ${archiveFile.name}');
      }
      final output = File(target);
      await output.parent.create(recursive: true);
      await output.writeAsBytes(archiveFile.content as List<int>);
    }
    return true;
  }
}
