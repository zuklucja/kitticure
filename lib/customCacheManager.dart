import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:kitticure/ioFileSystem.dart';

class CustomCacheManager extends CacheManager with ImageCacheManager {
  static const String key = "customCache";

  static CustomCacheManager _instance = CustomCacheManager._();

  factory CustomCacheManager() {
    return _instance ??= CustomCacheManager._();
  }

  CustomCacheManager._()
      : super(Config(key, fileSystem: IOFileSystem(key)),);
}