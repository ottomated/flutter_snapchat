# Snapchat

Interface with the [Snapchat developer kit](https://kit.snapchat.com/). Currently supports the Login Kit, for OAuth authentication with Snapchat, and the Creative Kit, for sharing content from your app to Snapchat.

iOS is currently a work in progress.

## Installation

- First, add `snapchat` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
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

Edit your **app-level** `build.gradle` by adding this to the *dependencies* block:

```groovy
implementation([
    'com.snapchat.kit.sdk:creative:1.1.4',
    'com.snapchat.kit.sdk:login:1.1.4',
    'com.snapchat.kit.sdk:core:1.1.4'
])
```

Edit your `AndroidManifest.xml`:

- Inside your application tag, add these three fields (inserting your client ID and redirect URL):

```xml
<meta-data
    android:name="com.snapchat.kit.sdk.clientId"
    android:value="YOUR_CLIENT_ID" />
<meta-data
    android:name="com.snapchat.kit.sdk.redirectUrl"
    android:value="yourapp://snapchat/oauth2" />
<meta-data
    android:name="com.snapchat.kit.sdk.scopes"
    android:resource="@array/snap_connect_scopes" />
```

- Also add this activity tag. You'll need to deconstruct your redirect url into the parts `scheme`://`host` `path`:

```xml
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
```

- If you want to use the Creative Kit, add this tag:

```xml
<provider
    android:name="android.support.v4.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

Now, create a new file called `file_paths.xml` inside `res/xml` with the contents:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <root-path name="root" path="." />
</paths>
```

Finally, create a new file called `arrays.xml` inside `res/values` with the contents:

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

Coming soon.

## Usage

```dart
// Initialize the plugin before using it
var snapchat = SnapchatPlugin();
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