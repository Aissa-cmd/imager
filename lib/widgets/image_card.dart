import 'package:flutter/material.dart';
import 'package:images_app/data/image_data.dart';
import 'package:images_app/screens/show_image_screen.dart';

class ImageCard extends StatefulWidget {
  ImageCard({
    Key? key,
    required this.image,
    required this.showAdCallback,
  }) : super(key: key);

  final ImageData image;
  final Function showAdCallback;

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ([true, false]..shuffle()).first == true
            ? widget.showAdCallback()
            : null;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowImageScreen(image: widget.image)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffd9d9d9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          // fit: StackFit.expand,
          children: [
            Positioned(
              top: 0.0,
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Hero(
                  tag: widget.image.tag,
                  child: Image.network(
                    widget.image.src,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
