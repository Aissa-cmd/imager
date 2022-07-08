import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:images_app/admob/google_admob.dart';
import 'package:images_app/data/image_data.dart';
import 'package:photo_view/photo_view.dart';

class ShowImageScreen extends StatefulWidget {
  const ShowImageScreen({Key? key, required this.image}) : super(key: key);

  final ImageData image;

  @override
  State<ShowImageScreen> createState() => _ShowImageScreenState();
}

const TextStyle bottomMenuOptionsTextStyle = TextStyle(color: Colors.white);

class _ShowImageScreenState extends State<ShowImageScreen> {
  var googleAdmobController = GoogleAdmob();
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

  // bool _isControlVisible = true;
  var _topControlOffset = const Offset(0, 0);
  var _bottomControlOffset = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    googleAdmobController.createBottomBannerAd(() {
      setState(() {
        _isBottomBannerAdLoaded = true;
      });
    }, (bannerAd) {
      _bottomBannerAd = bannerAd;
    });
  }

  @override
  void dispose() {
    _bottomBannerAd.dispose();
    super.dispose();
  }

  downloadImage() async {
    try {
      var imageId = await ImageDownloader.downloadImage(
        widget.image.src_original,
        destination: AndroidDestinationType.directoryDCIM
          ..subDirectory("app_name/${widget.image.src.split('/').last}"),
      );
      if (imageId == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Image was saved successfully to your device.",
          ),
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff303030),
        bottomNavigationBar: _isBottomBannerAdLoaded
            ? Container(
                width: _bottomBannerAd.size.width.toDouble(),
                height: _bottomBannerAd.size.height.toDouble(),
                child: AdWidget(
                  ad: _bottomBannerAd,
                  key: UniqueKey(),
                ),
              )
            : null,
        body: Container(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: PhotoView(
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 1.1,
                  imageProvider: NetworkImage(widget.image.src),
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: widget.image.tag,
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AnimatedSlide(
                  offset: _topControlOffset,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha(0),
                          Colors.black12,
                          Colors.black45,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Image by: ",
                          style: bottomMenuOptionsTextStyle,
                        ),
                        Text(
                          widget.image.photographer,
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: AnimatedSlide(
                  offset: _bottomControlOffset,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    // color: Colors.blue,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha(0),
                          Colors.black12,
                          Colors.black45,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                            ),
                            onPressed: () {
                              downloadImage();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: const [
                                  Icon(Icons.download, color: Colors.white),
                                  Text(
                                    "Download",
                                    style: bottomMenuOptionsTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
