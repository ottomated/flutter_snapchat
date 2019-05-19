import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:snapchat/snapchat.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SnapchatPlugin snapchat;
  SnapchatUser user;

  String stickerPath;

  @override
  void initState() {
    super.initState();
    snapchat = SnapchatPlugin();
    initSnapchat();
  }

  Future<void> initSnapchat() async {
    // Load asset to local file
    var d = await getTemporaryDirectory();
    stickerPath = p.join(d.path, "example_sticker.png");
    ByteData data = await rootBundle.load("assets/example_sticker.png");
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(stickerPath).writeAsBytes(bytes);

    // Init snapchat plugin
    await snapchat.init();
    SnapchatUser res = await snapchat.login();
    setState(() {
      user = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: user == null
            ? Center(child: Text("User not loaded"))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      child: Image.network(user.bitmoji),
                    ),
                  ),
                  Center(
                    child: Text('User: ${user.displayName}\n${user.id}'),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(onPressed: () async {
          await snapchat.send(
            SnapMediaType.Live,
            sticker: SnapchatSticker(
              stickerPath,
              x: 0.5,
              y: 0.5,
              rotation: 30,
            ),
            attachment: "https://google.com",
          );
        }),
      ),
    );
  }
}
