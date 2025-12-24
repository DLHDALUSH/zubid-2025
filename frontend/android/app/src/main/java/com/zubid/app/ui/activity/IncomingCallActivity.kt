package com.zubid.app.ui.activity

import android.content.Context
import android.content.Intent
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.View
import android.view.WindowManager
import android.view.animation.AnimationUtils
import androidx.appcompat.app.AppCompatActivity
import com.bumptech.glide.Glide
import com.zubid.app.R
import com.zubid.app.databinding.ActivityIncomingCallBinding

class IncomingCallActivity : AppCompatActivity() {

    private lateinit var binding: ActivityIncomingCallBinding

    private var callerId: String = ""
    private var callerName: String = ""
    private var callerAvatar: String? = null
    private var callId: String = ""

    private var ringtone: Ringtone? = null
    private var vibrator: Vibrator? = null
    private val handler = Handler(Looper.getMainLooper())

    companion object {
        private const val EXTRA_CALLER_ID = "caller_id"
        private const val EXTRA_CALLER_NAME = "caller_name"
        private const val EXTRA_CALLER_AVATAR = "caller_avatar"
        private const val EXTRA_CALL_ID = "call_id"

        fun newIntent(
            context: Context,
            callerId: String,
            callerName: String,
            callerAvatar: String?,
            callId: String
        ): Intent {
            return Intent(context, IncomingCallActivity::class.java).apply {
                putExtra(EXTRA_CALLER_ID, callerId)
                putExtra(EXTRA_CALLER_NAME, callerName)
                putExtra(EXTRA_CALLER_AVATAR, callerAvatar)
                putExtra(EXTRA_CALL_ID, callId)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Keep screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // Show when locked and turn screen on (use modern API for Android O+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        binding = ActivityIncomingCallBinding.inflate(layoutInflater)
        setContentView(binding.root)

        callerId = intent.getStringExtra(EXTRA_CALLER_ID) ?: ""
        callerName = intent.getStringExtra(EXTRA_CALLER_NAME) ?: ""
        callerAvatar = intent.getStringExtra(EXTRA_CALLER_AVATAR)
        callId = intent.getStringExtra(EXTRA_CALL_ID) ?: ""

        setupUI()
        startRinging()
        startAnimations()
    }

    private fun setupUI() {
        binding.tvCallerName.text = callerName

        callerAvatar?.let { url ->
            Glide.with(this)
                .load(url)
                .placeholder(R.drawable.ic_person)
                .error(R.drawable.ic_person)
                .into(binding.ivCallerAvatar)
        }

        binding.btnAccept.setOnClickListener { acceptCall() }
        binding.btnDecline.setOnClickListener { declineCall() }
    }

    private fun startRinging() {
        // Play ringtone
        try {
            val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            ringtone = RingtoneManager.getRingtone(this, ringtoneUri)
            ringtone?.play()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Vibrate
        vibrator = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        val pattern = longArrayOf(0, 1000, 500, 1000, 500)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 0)
        }
    }

    private fun startAnimations() {
        val pulseAnimation = AnimationUtils.loadAnimation(this, android.R.anim.fade_in)
        pulseAnimation.duration = 500
        pulseAnimation.repeatMode = android.view.animation.Animation.REVERSE
        pulseAnimation.repeatCount = android.view.animation.Animation.INFINITE
        
        binding.ringingIndicator.getChildAt(0).startAnimation(pulseAnimation)
        
        handler.postDelayed({
            binding.ringingIndicator.getChildAt(1).startAnimation(pulseAnimation)
        }, 200)
        
        handler.postDelayed({
            binding.ringingIndicator.getChildAt(2).startAnimation(pulseAnimation)
        }, 400)
    }

    private fun acceptCall() {
        stopRinging()
        
        val intent = VideoCallActivity.newIntent(
            this,
            callerId,
            callerName,
            callerAvatar,
            isOutgoing = false
        )
        startActivity(intent)
        finish()
    }

    private fun declineCall() {
        stopRinging()
        // TODO: Send decline signal via WebSocket
        finish()
    }

    private fun stopRinging() {
        ringtone?.stop()
        vibrator?.cancel()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopRinging()
        handler.removeCallbacksAndMessages(null)
    }
}

