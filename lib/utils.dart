import 'dart:convert';

import 'package:images_app/data/image_data.dart';
import 'package:http/http.dart' as http;

class FetchImagesResponse {
  String nextPage;
  List<ImageData> images;

  FetchImagesResponse({
    required this.nextPage,
    required this.images,
  });
}

Future<FetchImagesResponse> fetchImages(String url) async {
  final response = await http.get(Uri.parse(url), headers: {
    "Authorization": "563492ad6f91700001000001ca5c1efa4e274b17992486864aded3ea",
  });
  if (response.statusCode == 200) {
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);
    return FetchImagesResponse(
      nextPage: decodedResponse['next_page'] ?? "",
      images: ImageData.fromListJson(decodedResponse['photos']),
    );
  } else {
    throw Exception("Faild to load data");
  }
}
