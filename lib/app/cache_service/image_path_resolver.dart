class ImagePathResolver {
  static late String basePath;

  static void init(String path) {
    basePath = path;
  }

  static String resolve(String relativePath, {String category = 'films'}) {
    return "$basePath/$category/$relativePath";
  }

  static String resolveFilm(String relativePath) =>
      resolve(relativePath, category: 'films');

  static String resolveCollection(String relativePath) =>
      resolve(relativePath, category: 'collections');
}