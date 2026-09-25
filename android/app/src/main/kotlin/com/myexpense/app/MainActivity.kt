package com.myexpense.app

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "com.myexpense.app/sms_receiver"
    private val SMS_METHOD_CHANNEL = "com.myexpense.app/sms_permissions"
    private var eventSink: EventChannel.EventSink? = null

    private val localSmsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == SmsReceiver.ACTION_SMS_RECEIVED) {
                val sender = intent.getStringExtra(SmsReceiver.EXTRA_SENDER) ?: ""
                val body = intent.getStringExtra(SmsReceiver.EXTRA_BODY) ?: ""

                val map = mapOf(
                    "sender" to sender,
                    "body" to body,
                    "timestamp" to System.currentTimeMillis()
                )
                eventSink?.success(map)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkSmsPermission" -> {
                    val hasReceive = ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
                    val hasRead = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                    result.success(hasReceive && hasRead)
                }
                "requestSmsPermission" -> {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
                        101
                    )
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        val filter = IntentFilter(SmsReceiver.ACTION_SMS_RECEIVED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(localSmsReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(localSmsReceiver, filter)
        }
    }

    override fun onPause() {
        super.onPause()
        try {
            unregisterReceiver(localSmsReceiver)
        } catch (_: Exception) {}
    }
}
