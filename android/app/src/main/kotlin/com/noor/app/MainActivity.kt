package com.noor.app

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val iconChannel = "com.noor.app/launcher_icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, iconChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "setThemeIcon") {
                    result.notImplemented()
                    return@setMethodCallHandler
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
