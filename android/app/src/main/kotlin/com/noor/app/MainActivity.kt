package com.noor.app

import android.content.ComponentName
import android.content.pm.PackageManager
import android.hardware.GeomagneticField
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val iconChannel = "com.noor.app/launcher_icon"
    private val geomagneticChannel = "com.noor.app/geomagnetic"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, iconChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "setThemeIcon") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, geomagneticChannel)
                .setMethodCallHandler { call, result ->
                    if (call.method != "getDeclination") {
                        result.notImplemented()
                        return@setMethodCallHandler
                    }

                    val latitude = call.argument<Double>("latitude")
                    val longitude = call.argument<Double>("longitude")
                    val altitude = call.argument<Double>("altitude")
                    if (latitude == null || longitude == null || altitude == null ||
                        latitude !in -90.0..90.0 || longitude !in -180.0..180.0
                    ) {
                        result.error(
                            "invalid_coordinates",
                            "Valid coordinates and altitude are required.",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val field = GeomagneticField(
                            latitude.toFloat(),
                            longitude.toFloat(),
                            altitude.toFloat(),
                            System.currentTimeMillis(),
                        )
                        result.success(field.declination.toDouble())
                    } catch (error: Exception) {
                        result.error("declination_failed", error.message, null)
                    }
                }

                val selectedTheme = call.argument<String>("theme")
                val aliasName = launcherAliases[selectedTheme]
                if (aliasName == null) {
                    result.error("invalid_theme", "Unknown launcher icon theme.", null)
                    return@setMethodCallHandler
                }

                try {
                    val packageManager = packageManager
                    launcherAliases.values.forEach { name ->
                        packageManager.setComponentEnabledSetting(
                            ComponentName(this, "$packageName.$name"),
                            if (name == aliasName) {
                                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                            } else {
                                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                            },
                            PackageManager.DONT_KILL_APP,
                        )
                    }
                    result.success(null)
                } catch (error: Exception) {
                    result.error("icon_update_failed", error.message, null)
                }
            }
    }

    private val launcherAliases = mapOf(
        "sandalwood" to "MainActivitySandalwood",
        "oliveBranch" to "MainActivityOliveBranch",
        "emeraldArch" to "MainActivityEmeraldArch",
        "roseMarble" to "MainActivityRoseMarble",
        "roseLeaves" to "MainActivityRoseLeaves",
    )
}
