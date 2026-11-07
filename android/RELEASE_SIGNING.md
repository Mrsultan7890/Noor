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

To reduce the APK download size, build one APK per processor architecture with
`flutter build apk --release --split-per-abi`. Flutter creates separate
`armeabi-v7a`, `arm64-v8a`, and `x86_64` APKs; upload the matching APK for the
target device, or provide the complete set if the store supports multiple APKs.
The unsplit APK contains all supported native architectures and is larger.
An app bundle can also let a compatible store deliver only device-specific
components. For a new APKPure listing, upload the signed release APK itself,
not the GitHub Actions ZIP or the debug APK; choose the `arm64-v8a` APK for
modern 64-bit Android phones. This first listing build is version `1.0.0` with
version code `1`. Keep this new listing's upload keystore backed up securely
and use the same key for every future update.

The GitHub release workflow expects these repository secrets:

- `ANDROID_KEYSTORE_BASE64`: base64-encoded original upload keystore
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

On Linux, encode the existing keystore with `base64 -w 0 /path/to/upload-key.jks`
and save its output directly as the `ANDROID_KEYSTORE_BASE64` repository secret.
Do not paste the encoded key or passwords into chat or commit them.

For CI builds, the Flutter CI workflow builds and uploads a **debug-only
arm64 APK** for testing. It is not signed with the release key and must not be
submitted to APKPure. CI artifact size is not the release APK size; release
builds are produced separately using the release signing key.

Do not generate a new keystore as a substitute for the original: it has a
different signature and will still be rejected as an update. If the original
keystore is lost, contact APKPure support about recovery before uploading.
