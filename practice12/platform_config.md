# Android — android/app/src/main/AndroidManifest.xml

Inside `<manifest>`, above `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />

<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="mailto" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="tel" />
    </intent>
</queries>
```

`android/app/build.gradle(.kts)`: `minSdk = 23` (flutter_secure_storage).

# iOS — ios/Runner/Info.plist

```xml
<key>NSCameraUsageDescription</key>
<string>The camera is used to take your profile photo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Your photo library is used to choose your profile photo.</string>
```

# iOS — ios/Podfile (permission_handler), inside post_install, in the target loop

```ruby
target.build_configurations.each do |config|
  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
    '$(inherited)',
    'PERMISSION_CAMERA=1',
    'PERMISSION_PHOTOS=1',
  ]
end
```
