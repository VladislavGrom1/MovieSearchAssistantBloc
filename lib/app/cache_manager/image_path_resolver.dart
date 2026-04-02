class ImagePathResolver {
  static late String basePath;

  static void init(String path) {
    basePath = path;
  }

  static String resolve(String relativePath) {
    return "$basePath/films/$relativePath";
  }
}