import 'dart:io';
import 'package:file/local.dart';
import 'package:file/src/interface/file.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart'
    as c;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file/file.dart';

class IOFileSystem implements c.FileSystem {
  final Future<Directory> _fileDir;

  IOFileSystem(String key) : _fileDir = createDirectory(key);

  static Future<Directory> createDirectory(String key) async {
    // use documents directory instead of temp
    var baseDir = await getApplicationDocumentsDirectory();
    var path = p.join(baseDir.path, key);

    var fs = const LocalFileSystem();
    var directory = fs.directory((path));
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    assert(name != null);
    return (await _fileDir).childFile(name);
  }
}
