package bored.codebyk.mintcalc

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.os.Build

class MainActivity: FlutterActivity() {
    private var applicationContext: Context? = null
    private val CHANNEL = "bored.codebyk.mintcalc/androidversion"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
          call, result ->
          // This method is invoked on the main thread.
          // TODO
          if (call.method == "getAndroidVersion") {
            val android_V = getAndroidVersion()
            result.success(android_V)
          } else if (call.method == "getAppVersion"){
            val appV = getAppVersion()
            result.success(appV)
          } else {
            result.notImplemented()
          }
        }
      }

    fun getAndroidVersion(): Int {
        return Build.VERSION.SDK_INT
    }

    fun getAppVersion(): String {
      val packageManager = applicationContext!!.packageManager
      val info = packageManager.getPackageInfo(applicationContext!!.packageName, 0)
      return info.versionName
    }
}
