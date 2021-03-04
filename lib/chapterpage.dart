import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'ViewPDf.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'dart:async';
import 'package:toast/toast.dart';


class Chapters extends StatefulWidget {
  var subject;
  Chapters(s){this.subject=s;}
  @override
  _ChaptersState createState() => _ChaptersState(this.subject);
}

class _ChaptersState extends State<Chapters> {
  var subject;
  var checkdownload;
  var list;
  _ChaptersState(s){
    subject=s;
    _nativeAdController.reloadAd(forceRefresh: true);
    FlutterDownloader.initialize();
  }
  @override
  void initState() {
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-6216078565461407~8870479935");
    myInterstitial = buildInterstitialAd()..load();
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    _nativeAdController.reloadAd(forceRefresh: true);
  }
  _checkconnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("No internet Connection"),
              content: Text("Connect to internet to download files"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
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

    Future<bool> _check(name) async{
      final directory = await getApplicationDocumentsDirectory();
      final f='${directory.path}/$name';
      var x= await File(f).exists();
      if(x==true){
       return true;
      }
      else return false;
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: _height==0?10:9,
              child: FutureBuilder(
                  builder: (context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      var showData;
                      var x = json.decode(snapshot.data.toString());
                      if( subject=="बाल रामकथा"){
                        showData=x[0]["Hindi"][0]["बाल रामकथा"];
                      }
                      else if( subject=="वसंत, भाग-1"){
                        showData=x[0]["Hindi"][0]["वसंत, भाग-1"];
                      }
                      else if( subject=="Honeysuckle"){
                        showData=x[0]["English"][0]["Honeysuckle"];
                      }
                      else if( subject=="A pact with the Sun"){
                        showData=x[0]["English"][0]["A pact with the Sun"];
                      }
                      else{
                        showData=x[0][subject];
                      }
                      print(showData.length);
                      print(list);
                      return ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              title: Text(showData[index]["title"]),
                              subtitle: Text(showData[index]["name"]),
                              trailing: GestureDetector(
                                  child: FutureBuilder(
                                    builder: (context, s){
                                      if(s.data==true){
                                        return Container(width: 5,);
                                      }
                                      else{
                                        return GestureDetector(
                                            child: Icon(Icons.file_download),
                                          onTap: () async{
                                            _checkconnectivity();
                                            final directory = await getApplicationDocumentsDirectory();
                                            print(directory.path);
                                            await FlutterDownloader.enqueue(
                                              url: showData[index]["url"],
                                              savedDir: directory.path,
                                              showNotification: true, // show download progress in status bar (for Android)
                                              openFileFromNotification: false,
                                            ).then((_)async{
                                              //var b=await _check(showData[index]["filename"]);
                                              //if(b==true){
                                                 Toast.show("'${showData[index]["name"]}' Downloading...", context,
                                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                                                 Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => PdfViwer(showData[index]["name"],showData[index]["url"],showData[index]["filename"]))).then((_) {
                                                });

                                              //}
                                            });
                                          },
                                        );
                                      }
                                    }
                                      ,future:_check(showData[index]["filename"]),
                                  ),


                              ),
                              onTap: () async{

                                SharedPreferences pref=await SharedPreferences.getInstance();
                                int click=pref.getInt("clicks");
                                pref.setInt("clicks",click+1 );
                                if((click+1)%4==0){
                                  showInterstitialAd();
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfViwer(showData[index]["name"],showData[index]["url"],showData[index]["filename"]))).then((_) {
                                });
                              },
                            ),
                          );
                        },
                        itemCount: showData.length,
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(
                            ),
                            width: 30,
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text("Loading.."),
                          )
                        ],
                      );
                    }
                  },
                  future:
                DefaultAssetBundle.of(context).loadString("assets/chapters.json"),
              ),
            ),
            Expanded(child: Container(
              child:NativeAdmob(
                adUnitID: _adUnitID,
                controller: _nativeAdController,
                loading: Container(),
                type: NativeAdmobType.banner,
              ),
            ),flex:_height==0?0:1,),
          ],
        ),
      ),
    );
  }
}
