import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:file_utils/file_utils.dart';
import 'dart:math';

void main() => runApp(Downloader());

class Downloader extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
  MaterialApp(
    title: "File Downloader",
    debugShowCheckedModeBanner: false,
    home: FileDownloader(),
    theme: ThemeData(
      primarySwatch: Colors.blue
    ),
  );
}

class FileDownloader extends StatefulWidget {
  @override
  _FileDownloaderState createState() => _FileDownloaderState();
}

class _FileDownloaderState extends State<FileDownloader> {

  // final imgUrl = "https://firebasestorage.googleapis.com/v0/b/flutter-884a9.appspot.com/o/28.jpg?alt=media&token=39c47553-8ba3-48bf-ad3d-5b7618120b9a";
  final imgUrl = "https://unsplash.com/photos/iEJVyyevw-U/download?force=true";
  bool downloading = false;
  var progress = "";
  var path = "No Data";
  var platformVersion = "Unknown";
  Permission permission1 = Permission.WriteExternalStorage;
  var _onPressed;
  static final Random random = Random();

  @override
    void initState() {
      super.initState();
      downloadFile();
    }

  Future<void> downloadFile() async {
  Dio dio = Dio();
  bool checkPermission1 = await SimplePermissions.checkPermission(permission1);
  // print(checkPermission1);
  if (checkPermission1 == false) { 
    await SimplePermissions.requestPermission(permission1);
    checkPermission1 = await SimplePermissions.checkPermission(permission1);
  }
  if (checkPermission1 == true) {
    
    var dir = await getExternalStorageDirectory();
    var dirloc = "${dir.path}/FileDownloader/";
    var randid = random.nextInt(10000);

    try {
      FileUtils.mkdir([dirloc]);
      await dio.download(imgUrl, dirloc + randid.toString() + ".jpg",
        onProgress: (receivedBytes, totalBytes) {
          setState(() {
            downloading = true;
            progress = ((receivedBytes/totalBytes) * 100).toStringAsFixed(0) + "%";
          });
        } );
    } catch(e) {
      print(e);
    }

    setState(() {
      downloading = false;
      progress = "Download Completed.";
      path = dirloc + randid.toString() + ".jpg";
    });
  } else {
    setState(() {
      progress = "Permission Denied!";
      _onPressed = () {
        downloadFile();
      };
    });
  }
  }

  @override
  Widget build(BuildContext context) =>
  Scaffold(
    appBar: AppBar(
      title: Text('File Downloader'),
    ),
    body: Center(
      child: downloading
      ? Container(
        height: 120.0,
        width: 200.0,
        child: Card(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 10.0,),
              Text('Downloading File: $progress',style: TextStyle(color: Colors.white),),
            ],
          ),
        ),
      )
      : 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(path),
          MaterialButton(
            child: Text('Request Permission Again.'),
            onPressed: _onPressed,
            disabledColor: Colors.blueGrey,
            color: Colors.pink,
            textColor: Colors.white,
            height: 40.0,
            minWidth: 100.0,
          ),
          ], 
      )
    )
  );
}