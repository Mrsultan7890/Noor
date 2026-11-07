# Android release signing

Release APKs and app bundles must be signed with the same keystore used for the
existing APKPure listing. The application ID is `com.noorislamiclearning.app`;
the Kotlin namespace remains `com.noor.app`.

The release build no longer falls back to the Android debug key. Configure the
existing upload keystore either in the ignored `android/key.properties` file:

```properties
storeFile=/absolute/path/to/the-existing-upload-key.jks
storePassword=your-keystore-password
keyAlias=your-existing-key-alias
keyPassword=your-key-password
```

Or provide the equivalent `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD` environment variables when
building. Keep the properties file and keystore private; never commit or share
them.

Then build the release package with `flutter build apk --release` or
`flutter build appbundle --release`.

Do not generate a new keystore as a substitute for the original: it has a
different signature and will still be rejected as an update. If the original
keystore is lost, contact APKPure support about recovery before uploading.
