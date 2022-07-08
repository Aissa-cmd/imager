import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:images_app/admob/google_admob.dart';
import 'package:images_app/data/data_shared_preferences.dart';
import 'package:images_app/data/image_data.dart';
import 'package:images_app/screens/about_screen.dart';
import 'package:images_app/screens/search_images_screen.dart';
import 'package:images_app/utils.dart';
import 'package:images_app/widgets/gdpr_dialog.dart';
import 'package:images_app/widgets/image_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const TextStyle dropDrownMenuTextStyle = TextStyle(color: Color(0xff303030));

var gridItemsHeights = [2, 3, 3.5];

class _HomeScreenState extends State<HomeScreen> {
  var googleAdmobController = GoogleAdmob();
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;

  bool _showGdprDialog = true;

  final gridController = ScrollController();
  bool loading = true;
  bool noMoreImages = false;
  List<ImageData> images = [];
  String nextPage = "https://api.pexels.com/v1/curated";

  @override
  void initState() {
    super.initState();
    getImages();
    gridController.addListener(() {
      if (gridController.position.maxScrollExtent == gridController.offset) {
        getImages();
      }
    });
    googleAdmobController.createBottomBannerAd(() {
      setState(() {
        _isBottomBannerAdLoaded = true;
      });
    }, (bannerAd) {
      _bottomBannerAd = bannerAd;
    });
    _createInterstitialAd();
    _showGdprDialog = DataSharedPreferences.getIsFirstTime() ?? true;
  }

  _createInterstitialAd() {
    googleAdmobController.createInterstitialAd((p0) {
      _interstitialAd = p0;
    }, () {
      _interstitialAd = null;
    });
  }

  @override
  void dispose() {
    gridController.dispose();
    _bottomBannerAd.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  getImages({String? url}) async {
    try {
      if (nextPage.isEmpty) {
        setState(() {
          noMoreImages = true;
        });
        return;
      }
      final response = await fetchImages(url ?? nextPage);
      setState(() {
        loading = false;
        nextPage = response.nextPage;
        images.addAll(response.images);
      });
    } catch (Exception) {
      print("Error!!!!!!!!!!!!!!!!!!!!!!");
    }
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
    }
    _interstitialAd?.show();
  }

  Future refreshImages() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await fetchImages("https://api.pexels.com/v1/curated");
      setState(() {
        loading = false;
        nextPage = response.nextPage;
        images = response.images;
      });
    } catch (Exception) {
      print("Error!!!!!!!!!!!!!!!!!!!!!!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showGdprDialog) {
      Future.delayed(
        Duration.zero,
        () => showDialog(
            context: context,
            builder: (context) {
              return GdprDialog(callback: () {
                setState(() {
                  _showGdprDialog = false;
                });
              });
            }),
      );
    }

    return Scaffold(
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
      appBar: AppBar(
        title: const Text("Tortuga play wallpaper"),
        actions: [
          IconButton(
            tooltip: "Search",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SearchImagesScreen()),
              );
            },
            icon: const Icon(Icons.search),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton(
              onSelected: (value) {
                if (value == 0) {
                  _showInterstitialAd();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()),
                  );
                }
              },
              // offset: const Offset(0.0, 60.0),
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 0,
                    child: Container(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.info,
                              color: Color(0xff303030),
                            ),
                          ),
                          Text(
                            "About",
                            style: dropDrownMenuTextStyle,
                          )
                        ],
                      ),
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: Container(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: refreshImages,
                child: StaggeredGridView.countBuilder(
                  controller: gridController,
                  padding: const EdgeInsets.all(10),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemCount: images.length + 1,
                  crossAxisCount: 4,
                  staggeredTileBuilder: (index) => StaggeredTile.count(
                      index >= images.length ? 4 : 2,
                      index >= images.length
                          ? 1
                          : index % 4 == 1
                              ? 2.90
                              : index % 7 == 5
                                  ? 3.75
                                  : 2),
                  itemBuilder: (BuildContext context, int index) {
                    if (index < images.length) {
                      return ImageCard(
                          image: images[index],
                          showAdCallback: _showInterstitialAd);
                    } else {
                      return Center(
                        child: noMoreImages
                            ? const Text(
                                "No more images",
                                style: TextStyle(color: Colors.grey),
                              )
                            : const CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
      ),
    );
  }
}
