package uz.bato.veylo

import android.app.*
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

class AppBlockerForegroundService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private var blockedPackages: List<String> = emptyList()
    private var isRunning = false

    private val monitorRunnable = object : Runnable {
        override fun run() {
            if (isRunning) {
                checkForegroundApp()
                handler.postDelayed(this, 250) // Har 0.25 sekundda tezkor tekshiradi
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val packages = intent?.getStringArrayListExtra("blockedPackages")
        if (packages != null) {
            blockedPackages = packages
        }

        createNotificationChannel()
        val notification = NotificationCompat.Builder(this, "APP_BLOCKER_CHANNEL")
            .setContentTitle("Kiber-Qalqon himoyada")
            .setContentText("Ilovalar cheklovi faol")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        startForeground(1001, notification)

        if (!isRunning) {
            isRunning = true
            handler.post(monitorRunnable)
        }

        return START_STICKY
    }

    private fun checkForegroundApp() {
        if (blockedPackages.isEmpty()) return

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        
        // Oxirgi 5 sekund ichidagi aktivlikni olish
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            time - 5000,
            time
        )

        if (!stats.isNullOrEmpty()) {
            var myForegroundApp = ""
            var lastTimeUsed = 0L

            for (usageStats in stats) {
                if (usageStats.lastTimeUsed > lastTimeUsed) {
                    lastTimeUsed = usageStats.lastTimeUsed
                    myForegroundApp = usageStats.packageName
                }
            }

            // Agar ekrandagi ilova bloklangan bo'lsa va bu bizning ilovamiz bo'lmasa
            if (myForegroundApp.isNotEmpty() && 
                myForegroundApp != packageName && 
                blockedPackages.contains(myForegroundApp)) {
                
                // Bloklangan ilovani darhol yopish (Home ekraniga otib yuborish)
                val lockIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                }
                startActivity(lockIntent)
            }
        }
    }

    override fun onDestroy() {
        isRunning = false
        handler.removeCallbacks(monitorRunnable)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "APP_BLOCKER_CHANNEL",
                "App Blocker Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}