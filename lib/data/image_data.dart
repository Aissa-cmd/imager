import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class ImageData {
  int id;
  String photographer;
  String src;
  String src_original;
  String alt;
  String tag;

  ImageData({
    required this.id,
    required this.photographer,
    required this.src,
    required this.alt,
    required this.tag,
    required this.src_original,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'],
      photographer: json['photographer'],
      src: json['src']['large'],
      alt: json['alt'],
      src_original: json['src']['original'],
      tag: uuid.v4(),
    );
  }

  static List<ImageData> fromListJson(List<dynamic> json) {
    return json.map((e) => ImageData.fromJson(e)).toList();
  }

  @override
  String toString() {
    return "ImageData[id: $id, photographer: $photographer, src: $src, alt: $alt]";
  }
}
