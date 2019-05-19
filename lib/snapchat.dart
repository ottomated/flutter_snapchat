import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows interaction with Snapchat
class SnapchatPlugin {
  /// Key used to store loggedInUser in shared preferences.
  static const _prefKey = '__snapchat_plugin_user';

  SnapchatPlugin();

  Future init() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(_prefKey)) {
      try {
        _cachedUser = SnapchatUser._fromMap(
          json.decode(
            prefs.getString(_prefKey),
          ),
        );
      } catch (e) {}
    }
    initialized = true;
  }

  bool initialized = false;

  SnapchatUser _cachedUser;

  /// Cached current user.
  SnapchatUser get loggedInUser {
    assert(initialized);
    return _cachedUser;
  }

  /// Channel used to communicate to native code.
  static const MethodChannel _channel = const MethodChannel('snapchat');

  /// Log a user in by opening the Snapchat app's OAuth screen.
  Future<SnapchatUser> login() async {
    assert(initialized);
    if (loggedInUser != null) return loggedInUser;
    try {
      dynamic result = await _channel.invokeMethod('login');
      // Save result to storage
      var prefs = await SharedPreferences.getInstance();
      prefs.setString(_prefKey, json.encode(result));
      // Cache result in memory
      _cachedUser = SnapchatUser._fromMap(result);
      return loggedInUser;
    } on PlatformException catch (e) {
      throw 'Unable to log in: ${e.message}';
    }
  }

  /// Log out the current user, revoking their OAuth token.
  Future logout() async {
    assert(initialized);
    await _channel.invokeMethod('logout');
  }

  /// Shares a media file of [mediaType] from a file located at [path]
  /// to Snapchat, or opens a live feed if [mediaType] is
  /// `SnapMediaType.Live`.
  ///
  /// Attaches an optional [sticker], [caption], and [attachment].
  /// [attachment] is a url which users can swipe up to open.
  Future send(
    SnapMediaType mediaType, {
    String path,
    SnapchatSticker sticker,
    String caption,
    String attachment,
  }) async {
    assert(initialized);
    if (mediaType != SnapMediaType.Live) assert(path != null);
    await _channel.invokeMethod(
      'send',
      <String, dynamic>{
        'mediaType': mediaType.toString(),
        'sticker': sticker == null ? null : sticker.toJson(),
        'caption': caption,
        'attachment': attachment,
      },
    );
  }

  /// Returns a boolean that indicates whether Snapchat is installed
  Future<bool> isSnapchatInstalled() async {
    return await _channel.invokeMethod("installed");
  }
}

/// A Snapchat "sticker", which is an image that the end-user can place over
/// their photo.
class SnapchatSticker {
  /// Width of the sticker in pixels
  double width;

  /// Height of the sticker in pixels
  double height;

  /// X Position of the sticker from 0.0 to 1.0
  double x;

  /// Y Position of the sticker from 0.0 to 1.0
  double y;

  /// Rotation of the sticker, in degrees clockwise
  double rotation;

  /// Path to the file containing the sticker image
  String file;

  SnapchatSticker(
    this.file, {
    this.width,
    this.height,
    this.x,
    this.y,
    this.rotation,
  }) : assert(file != null);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'rotation': rotation,
      'path': file,
    };
  }
}

/// A user obtained from Snapchat OAuth
class SnapchatUser {
  /// Unique identifier.
  final String id;

  /// Snapchat display name.
  final String displayName;

  /// The url to the user's bitmoji profile picture, if the bitmoji scope was
  /// accepted.
  final String bitmoji;

  bool get hasBitmoji => bitmoji != null;

  SnapchatUser(this.id, this.displayName, this.bitmoji);

  SnapchatUser._fromMap(dynamic map)
      : this.id = map['id'],
        this.displayName = map['displayName'],
        this.bitmoji = map['bitmoji'];

  @override
  String toString() {
    String result = "SnapchatUser[$displayName, id=$id";
    if (hasBitmoji)
      result += ", bitmoji=$bitmoji";
    return "$result]";
  }
}

/// The type of media to be shared to the app
enum SnapMediaType {
  /// A static photo
  Photo,

  /// A video
  Video,

  /// Allows the user to take a photo/video in the Snapchat app
  Live,
}
