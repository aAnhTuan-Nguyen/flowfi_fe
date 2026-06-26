final class AiImageFile {
  const AiImageFile({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final List<int> bytes;
  final String mimeType;

  int get sizeBytes => bytes.length;
}
