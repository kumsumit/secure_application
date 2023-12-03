package org.jezequel.secure_application

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.view.WindowManager.LayoutParams
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent


/** SecureApplicationPlugin */
class SecureApplicationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, LifecycleObserver {
  private var activity: Activity? = null
  private lateinit var instance: SecureApplicationPlugin

  override fun onDetachedFromActivity() {
    // not used for now but might be used to add some features in the future
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    if (::instance.isInitialized)
      instance.activity = binding.activity
    else
      this.activity = binding.activity
    val lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    lifecycle.addObserver(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    if (::instance.isInitialized)
      instance.activity = binding.activity
    else
      this.activity = binding.activity
    val lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    lifecycle.addObserver(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // not used for now but might be used to add some features in the future
  }


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    instance = SecureApplicationPlugin()
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "secure_application")
    channel.setMethodCallHandler(instance)
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
  fun connectListener() {
    // not used for now but might be used to add some features in the future
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "secure" -> {
          activity?.window?.addFlags(LayoutParams.FLAG_SECURE)
          result.success(true)
        }
        "open" -> {
          activity?.window?.clearFlags(LayoutParams.FLAG_SECURE)
          result.success(true)
        }
        "opacity" -> {
          // Implementation available only on ios
          result.success(true)
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
