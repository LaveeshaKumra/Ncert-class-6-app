import 'dart:async';
import 'dart:convert';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solutions/chapterpage.dart';

class Books extends StatefulWidget {
  var subject;
  Books(s) {
    this.subject = s;
  }
  @override
  _BooksState createState() => _BooksState(this.subject);
}

class _BooksState extends State<Books> {
  var subject, book;

  _BooksState(s) {
    subject = s;
    _nativeAdController.reloadAd(forceRefresh: true);
  }
  @override
  void initState() {
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-6216078565461407~8870479935");
    myInterstitial = buildInterstitialAd()..load();
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    _nativeAdController.reloadAd(forceRefresh: true);
  }

  InterstitialAd myInterstitial;

  InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      //adUnitId: InterstitialAd.testAdUnitId,
      adUnitId: "ca-app-pub-6216078565461407/6911720376",
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.failedToLoad) {
          myInterstitial..load();
        } else if (event == MobileAdEvent.closed) {
          myInterstitial = buildInterstitialAd()..load();
        }
        print(event);
      },
    );
  }

  void showInterstitialAd() {
    myInterstitial.show();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    _nativeAdController.dispose();
  }

  void _onStateChanged(AdLoadState state) {
    switch (state) {
      case AdLoadState.loading:
        setState(() {
          _height = 0;
        });
        break;

      case AdLoadState.loadCompleted:
        setState(() {
          _height = 120;
        });
        break;

      default:
        break;
    }
  }

  static const _adUnitID = "ca-app-pub-6216078565461407/9380579382";
  final _nativeAdController = NativeAdmobController();
  double _height = 0;
  StreamSubscription _subscription;

//  Navigator.push(
//  context,
//  MaterialPageRoute(
//  builder: (context) => Chapters("ch"))).then((_) {
//  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        child: Card(
                          elevation: 10.0,
                          child: subject == "Hindi"
                              ? Image.asset("assets/images/vasant.jpg")
                              : Image.asset("assets/images/honey.jpg"),
                        ),
                        onTap: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          int click = pref.getInt("clicks");
                          pref.setInt("clicks", click + 1);
                          if ((click + 1) % 4 == 0) {
                            showInterstitialAd();
                          }
                          subject == "Hindi"
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Chapters("वसंत, भाग-1")),
                                )
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Chapters("Honeysuckle")),
                                );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      subject == "Hindi"
                          ? Text("वसंत, भाग-1")
                          : Text("Honeysuckle")
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        child: Card(
                          elevation: 10.0,
                          child: subject == "Hindi"
                              ? Image.asset("assets/images/raam.jpg")
                              : Image.asset("assets/images/sun.jpg"),
                        ),
                        onTap: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          int click = pref.getInt("clicks");
                          pref.setInt("clicks", click + 1);
                          if ((click + 1) % 4 == 0) {
                            showInterstitialAd();
                          }
                          subject == "Hindi"
                              ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Chapters("बाल रामकथा")),
                          )
                              : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Chapters("A pact with the Sun")),
                          );

                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      subject == "Hindi"
                          ? Text("बाल रामकथा")
                          : Text("A pact with the Sun")
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 160,),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: _height,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: NativeAdmob(
                      adUnitID: _adUnitID,
                      controller: _nativeAdController,
                      loading: Container(),
                    ),
                  ),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
