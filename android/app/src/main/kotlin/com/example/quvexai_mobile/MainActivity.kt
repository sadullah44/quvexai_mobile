package com.example.quvexai_mobile

import android.app.AlarmManager // Gerekli
import android.content.Context // Gerekli
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "quvexai/exact_alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "requestExactAlarmPermission") {
                    // Android 12 (API 31) ve üzeri için kontrol
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        
                        // --- DÜZELTME: ÖNCE KONTROL ET ---
                        // Eğer izin verilmemişse (!canScheduleExactAlarms) sayfayı aç.
                        if (!alarmManager.canScheduleExactAlarms()) {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                            startActivity(intent)
                            result.success(false)
                        } else {
                            // İzin zaten varsa hiçbir şey yapma, sadece true dön.
                            result.success(true)
                        }
                        // ---------------------------------
                        
                    } else {
                        // Eski Android sürümlerinde bu izne gerek yok
                        result.success(true)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}