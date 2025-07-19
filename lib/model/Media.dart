enum MediaType { audio, video, image }

class MediaFile {
  final String path;
  final String name;
  final int size;
  final DateTime dateModified;
  final MediaType type;

  MediaFile({
    required this.path,
    required this.name,
    required this.size,
    required this.dateModified,
    required this.type,
  });
}
