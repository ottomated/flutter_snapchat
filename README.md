# Flutter SnapKit

 This plugin allows you to add [Snapchat's SnapKit](https://kit.snapchat.com/) to any Flutter project!

### Features

- [x] [Login Kit](https://kit.snapchat.com/login-kit)

- [x] [Creative Kit](https://kit.snapchat.com/creative-kit)

- [x] AndroidX Support

- [ ] iOS Support (Coming very soon)

- [ ] [Camera Kit](https://kit.snapchat.com/camera-kit)

- [ ] [Bitmoji Kit](https://kit.snapchat.com/bitmoji-kit)

- [ ] [Story Kit](https://kit.snapchat.com/story-kit)

- [ ] [Ad Kit](https://kit.snapchat.com/ad-kit)



## Installation

- First, add `snapkit` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```yaml
dependencies:
  snapkit:
  ...
```

- Register an app on the [Snapchat developer portal](https://kit.snapchat.com/portal), and get your client ID.
- Also, create a redirect url that looks something like `yourapp://snapchat/oauth2`.

### Android

Edit your **project-level** `build.gradle` by adding the snap-kit repository to this block:

```groovy
allprojects {
    repositories {
        google()
        jcenter()
        maven {
            url "https://storage.googleapis.com/snap-kit-build/maven"
        }
    }
}
```

Edit the `build.gradle` in `android` by adding this to the *dependencies* block:

```groovy
dependencies {
    ...
    implementation([
        'com.snapchat.kit.sdk:creative:1.6.5',
        'com.snapchat.kit.sdk:login:1.6.5',
        'com.snapchat.kit.sdk:core:1.6.5'
    ])
}
```

Edit the `AndroidManifest.xml` in `android/src/main`:

- Inside your application tag, add these three `meta-data` fields (make sure to set your own `ClientID` & `RedirectURL`):

```xml
<application ... >
    ...

    <meta-data
        android:name="com.snapchat.kit.sdk.clientId"
        android:value="YOUR_CLIENT_ID" />

    <meta-data
        android:name="com.snapchat.kit.sdk.redirectUrl"
        android:value="yourapp://snapchat/oauth2" />

    <meta-data
        android:name="com.snapchat.kit.sdk.scopes"
        android:resource="@array/snap_connect_scopes" />

    ...
</application>
```

- Also add this activity tag to the same file. You'll need to deconstruct your redirect url into the parts `scheme`://`host` `/path`:

```xml
<application ... >
    ...

    <activity
        android:name="com.snapchat.kit.sdk.SnapKitActivity"
        android:launchMode="singleTask">

        <intent-filter>
            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                android:scheme="yourapp"
                android:host="snapchat"
                android:path="/oauth2" />
        </intent-filter>

    </activity>

    ...
</application>
```

- If you want to use the Creative Kit, add this tag to the same `AndroidManifest.xml`:

```xml
<application ... >
    ...

    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.fileprovider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/file_paths" />
    </provider>

    ...
</application>
```

Now, create a new file called `file_paths.xml` inside `android/app/src/main/res/xml` with these contents:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <root-path name="root" path="." />
</paths>
```

Finally, create a new file called `arrays.xml` inside `android/app/src/main/res/values` with the contents:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string-array name="snap_connect_scopes">
        <item>https://auth.snapchat.com/oauth2/api/user.bitmoji.avatar</item>
        <item>https://auth.snapchat.com/oauth2/api/user.display_name</item>
        <item>https://auth.snapchat.com/oauth2/api/user.external_id</item>
    </string-array>
</resources>
```

### iOS

Coming very soon.

## Usage

```dart
// Initialize the plugin before using it
var snapchat = SnapKitPlugin();
await snapchat.init();

// Make sure that the user has Snapchat installed
assert await snapchat.isSnapchatInstalled();

// Use the Login Kit to authenticate the user
SnapchatUser user = await snapchat.login();

// Get the cached user
user = snapchat.loggedInUser;
// If there is a cached user, snapchat.login() will automatically return it

// Share an image to Snapchat
await snapchat.send(
  SnapMediaType.Photo,
  path: '/path/to/image.png', // or jpg
);

// Share a video with a caption on it
await snapchat.send(
  SnapMediaType.Video,
  path: '/path/to/video.mp4',
  caption: 'This text can be edited by the user in the app and will appear on top of the video',
);

// Let the user take a photo/video but put a sticker on it
await snapchat.send(
  SnapMediaType.Live,
  sticker: SnapchatSticker(
    '/path/to/image.png',
    x: 0.5, // Percentage of width/height
    y: 0.5,
    width: 50,
    height: 50,
    rotation: 30 // degrees clockwise
    // x, y, width, height, and rotation are all optional
  ),
);


// Log out
await snapchat.logout();
```