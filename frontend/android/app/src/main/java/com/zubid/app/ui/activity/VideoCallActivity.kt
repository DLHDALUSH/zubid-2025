package com.zubid.app.ui.activity

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.zubid.app.R
import com.zubid.app.data.websocket.CallState
import com.zubid.app.databinding.ActivityVideoCallBinding

class VideoCallActivity : AppCompatActivity() {

    private lateinit var binding: ActivityVideoCallBinding

    private var participantId: String = ""
    private var participantName: String = ""
    private var participantAvatar: String? = null
    private var isOutgoing: Boolean = true

    private var isMuted = false
    private var isVideoEnabled = true
    private var callState = CallState.IDLE
    private var callStartTime = 0L

    private val handler = Handler(Looper.getMainLooper())
    private val durationRunnable = object : Runnable {
        override fun run() {
            if (callState == CallState.CONNECTED) {
                updateCallDuration()
                handler.postDelayed(this, 1000)
            }
        }
    }

    companion object {
        private const val EXTRA_PARTICIPANT_ID = "participant_id"
        private const val EXTRA_PARTICIPANT_NAME = "participant_name"
        private const val EXTRA_PARTICIPANT_AVATAR = "participant_avatar"
        private const val EXTRA_IS_OUTGOING = "is_outgoing"
        private const val PERMISSION_REQUEST_CODE = 100

        fun newIntent(
            context: Context,
            participantId: String,
            participantName: String,
            participantAvatar: String?,
            isOutgoing: Boolean = true
        ): Intent {
            return Intent(context, VideoCallActivity::class.java).apply {
                putExtra(EXTRA_PARTICIPANT_ID, participantId)
                putExtra(EXTRA_PARTICIPANT_NAME, participantName)
                putExtra(EXTRA_PARTICIPANT_AVATAR, participantAvatar)
                putExtra(EXTRA_IS_OUTGOING, isOutgoing)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        binding = ActivityVideoCallBinding.inflate(layoutInflater)
        setContentView(binding.root)

        participantId = intent.getStringExtra(EXTRA_PARTICIPANT_ID) ?: ""
        participantName = intent.getStringExtra(EXTRA_PARTICIPANT_NAME) ?: ""
        participantAvatar = intent.getStringExtra(EXTRA_PARTICIPANT_AVATAR)
        isOutgoing = intent.getBooleanExtra(EXTRA_IS_OUTGOING, true)

        setupUI()
        checkPermissions()
    }

    private fun setupUI() {
        binding.tvRemoteName.text = participantName
        
        participantAvatar?.let { url ->
            Glide.with(this)
                .load(url)
                .placeholder(R.drawable.ic_person)
                .error(R.drawable.ic_person)
                .into(binding.ivRemoteAvatar)
        }

        if (isOutgoing) {
            binding.tvCallStatus.text = getString(R.string.calling)
            callState = CallState.OUTGOING
        } else {
            binding.tvCallStatus.text = getString(R.string.connecting)
            callState = CallState.INCOMING
        }

        setupClickListeners()
    }

    private fun setupClickListeners() {
        binding.btnMute.setOnClickListener { toggleMute() }
        binding.btnToggleVideo.setOnClickListener { toggleVideo() }
        binding.btnEndCall.setOnClickListener { endCall() }
        binding.btnFlipCamera.setOnClickListener { flipCamera() }
    }

    private fun checkPermissions() {
        val permissions = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO
        )

        val notGranted = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (notGranted.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, notGranted.toTypedArray(), PERMISSION_REQUEST_CODE)
        } else {
            startCall()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                startCall()
            } else {
                Toast.makeText(this, R.string.permissions_required, Toast.LENGTH_SHORT).show()
                finish()
            }
        }
    }

    private fun startCall() {
        // Simulate call connecting after 2 seconds
        handler.postDelayed({
            if (callState != CallState.ENDED) {
                onCallConnected()
            }
        }, 2000)
    }

    private fun onCallConnected() {
        callState = CallState.CONNECTED
        callStartTime = System.currentTimeMillis()
        
        binding.tvCallStatus.text = getString(R.string.connected)
        binding.tvCallDuration.visibility = View.VISIBLE
        
        handler.post(durationRunnable)
        
        // Hide status text after 2 seconds
        handler.postDelayed({
            binding.tvCallStatus.visibility = View.GONE
        }, 2000)
    }

    private fun updateCallDuration() {
        val duration = (System.currentTimeMillis() - callStartTime) / 1000
        val minutes = duration / 60
        val seconds = duration % 60
        binding.tvCallDuration.text = String.format("%02d:%02d", minutes, seconds)
    }

    private fun toggleMute() {
        isMuted = !isMuted
        binding.btnMute.setImageResource(
            if (isMuted) R.drawable.ic_mic_off else R.drawable.ic_mic
        )
        // TODO: Actually mute the audio track
    }

    private fun toggleVideo() {
        isVideoEnabled = !isVideoEnabled
        binding.btnToggleVideo.setImageResource(
            if (isVideoEnabled) R.drawable.ic_video_call else R.drawable.ic_video_off
        )
        binding.ivLocalPlaceholder.visibility = if (isVideoEnabled) View.GONE else View.VISIBLE
        // TODO: Actually toggle the video track
    }

    private fun flipCamera() {
        // TODO: Flip between front and back camera
        Toast.makeText(this, R.string.camera_flipped, Toast.LENGTH_SHORT).show()
    }

    private fun endCall() {
        callState = CallState.ENDED
        handler.removeCallbacks(durationRunnable)
        // TODO: Send end call signal via WebSocket
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
        if (callState != CallState.ENDED) {
            // Clean up call resources
        }
    }
}

