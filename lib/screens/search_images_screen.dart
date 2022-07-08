import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:images_app/admob/google_admob.dart';
import 'package:images_app/data/image_data.dart';
import 'package:images_app/utils.dart';
import 'package:images_app/widgets/image_card.dart';

class SearchImagesScreen extends StatefulWidget {
  const SearchImagesScreen({Key? key}) : super(key: key);

  @override
  State<SearchImagesScreen> createState() => _SearchImagesScreenState();
}

class _SearchImagesScreenState extends State<SearchImagesScreen> {
  var googleAdmobController = GoogleAdmob();
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;

  bool _isInitial = true;
  bool _isLoading = false;
  final gridController = ScrollController();
  bool noMoreImages = false;
  List<ImageData> images = [];
  String nextPage = "https://api.pexels.com/v1/search";
  String _searchString = "";

  @override
  void initState() {
    super.initState();
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

  getImages({String? url, String? query}) async {
    try {
      if (nextPage.isEmpty) {
        setState(() {
          noMoreImages = true;
        });
        return;
      }
      final response =
          await fetchImages(url ?? "$nextPage?query=$_searchString");
      setState(() {
        _isLoading = false;
        nextPage = response.nextPage;
        images.addAll(response.images);
        noMoreImages = response.nextPage.isEmpty ? true : false;
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
    if (_searchString.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await fetchImages(
            "https://api.pexels.com/v1/search?query=$_searchString");
        setState(() {
          _isLoading = false;
          nextPage = response.nextPage;
          images = response.images;
        });
      } catch (Exception) {
        print("Error!!!!!!!!!!!!!!!!!!!!!!");
      }
    }
  }

  handleSearchInputSubmit(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _isInitial = false;
        images.clear();
        _searchString = value;
        _isLoading = true;
      });
      getImages();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: null,
        titleSpacing: 0.0,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TextField(
            onSubmitted: handleSearchInputSubmit,
            textInputAction: TextInputAction.search,
            autofocus: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(10),
              hintText: "Search images",
            ),
          ),
        ),
      ),
      body: Container(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: refreshImages,
                child: StaggeredGridView.countBuilder(
                  controller: gridController,
                  padding: const EdgeInsets.all(10),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemCount: images.length + 1,
                  // itemCount: images.length,
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
                      if (_isInitial) {
                        return const Center();
                      }
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
