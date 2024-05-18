import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_ads_bugg/feed_screen.dart';

class HomeFeedScreen extends StatefulWidget {

  HomeFeedScreen({super.key,});

  @override
  State<HomeFeedScreen> createState() => HomeFeedScreenState();
}

class HomeFeedScreenState extends State<HomeFeedScreen> {
  late TabController _tabController;

  static const _insets = 16.0;

  BannerAd? _adaptiveStickyBanner;
  bool _isLoaded = false;
  AdSize? _adSize;

  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() async {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';

    await _adaptiveStickyBanner?.dispose();
    setState(() {
      _adaptiveStickyBanner = null;
      _isLoaded = false;
    });

    // Get an inline adaptive size for the current orientation.
    AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            _adWidth.truncate());

    _adaptiveStickyBanner = BannerAd(
      adUnitId: adUnitId,
      size: size!,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) async {
          print('Sticky adaptive banner loaded: ${ad.responseInfo}');

          BannerAd bannerAd = (ad as BannerAd);
          final AdSize? size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            print('Error: getPlatformAdSize() returned null for $bannerAd');
            return;
          }
          setState(() {
            _adaptiveStickyBanner = bannerAd;
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Inline adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    await _adaptiveStickyBanner!.load();
  }

  @override
  void initState() {
    _loadAd();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:  Column(
        children: [
          Flexible(
            child: FeedScreen(),
          ),
          if (_isLoaded)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _adaptiveStickyBanner!.size.width.toDouble(),
                height: _adaptiveStickyBanner!.size.height.toDouble(),
                child: AdWidget(ad: _adaptiveStickyBanner!),
              ),
            )
        ],
      )
    );
  }
}
