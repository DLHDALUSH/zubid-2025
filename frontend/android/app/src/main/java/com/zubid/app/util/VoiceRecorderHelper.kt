package com.zubid.app.util

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.Build
import android.os.Handler
import android.os.Looper
import java.io.File
import java.io.IOException

class VoiceRecorderHelper(private val context: Context) {

    private var mediaRecorder: MediaRecorder? = null
    private var mediaPlayer: MediaPlayer? = null
    private var audioFile: File? = null
    private var isRecording = false
    private var isPlaying = false
    private var recordingStartTime = 0L
    
    private val handler = Handler(Looper.getMainLooper())
    private var amplitudeCallback: ((Int) -> Unit)? = null
    private var durationCallback: ((Int) -> Unit)? = null
    private var playbackProgressCallback: ((Int, Int) -> Unit)? = null

    fun setAmplitudeCallback(callback: (Int) -> Unit) {
        amplitudeCallback = callback
    }

    fun setDurationCallback(callback: (Int) -> Unit) {
        durationCallback = callback
    }

    fun setPlaybackProgressCallback(callback: (Int, Int) -> Unit) {
        playbackProgressCallback = callback
    }

    fun startRecording(): Boolean {
        val recordingDir = File(context.cacheDir, "voice_messages")
        if (!recordingDir.exists()) {
            recordingDir.mkdirs()
        }

        audioFile = File(recordingDir, "voice_${System.currentTimeMillis()}.m4a")

        mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            MediaRecorder(context)
        } else {
            @Suppress("DEPRECATION")
            MediaRecorder()
        }

        mediaRecorder?.apply {
            try {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setAudioEncodingBitRate(128000)
                setAudioSamplingRate(44100)
                setOutputFile(audioFile?.absolutePath)
                prepare()
                start()
                isRecording = true
                recordingStartTime = System.currentTimeMillis()
                startAmplitudeMonitor()
                return true
            } catch (e: IOException) {
                e.printStackTrace()
                release()
                return false
            } catch (e: IllegalStateException) {
                e.printStackTrace()
                release()
                return false
            }
        }
        return false
    }

    fun stopRecording(): Pair<File?, Int>? {
        if (!isRecording) return null
        
        val duration = ((System.currentTimeMillis() - recordingStartTime) / 1000).toInt()
        
        try {
            mediaRecorder?.apply {
                stop()
                release()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        mediaRecorder = null
        isRecording = false
        handler.removeCallbacksAndMessages(null)
        
        return Pair(audioFile, duration)
    }

    fun cancelRecording() {
        try {
            mediaRecorder?.apply {
                stop()
                release()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        mediaRecorder = null
        isRecording = false
        handler.removeCallbacksAndMessages(null)
        
        audioFile?.delete()
        audioFile = null
    }

    private fun startAmplitudeMonitor() {
        handler.post(object : Runnable {
            override fun run() {
                if (isRecording) {
                    try {
                        val amplitude = mediaRecorder?.maxAmplitude ?: 0
                        amplitudeCallback?.invoke(amplitude)
                        
                        val duration = ((System.currentTimeMillis() - recordingStartTime) / 1000).toInt()
                        durationCallback?.invoke(duration)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                    handler.postDelayed(this, 100)
                }
            }
        })
    }

    fun playAudio(filePath: String, onComplete: () -> Unit) {
        stopPlayback()

        val player = MediaPlayer()
        try {
            player.setDataSource(filePath)
            player.prepare()
            player.start()
            this.isPlaying = true
            mediaPlayer = player
            startPlaybackMonitor()
            player.setOnCompletionListener {
                this.isPlaying = false
                onComplete()
            }
        } catch (e: IOException) {
            e.printStackTrace()
            player.release()
        }
    }

    private fun startPlaybackMonitor() {
        handler.post(object : Runnable {
            override fun run() {
                if (isPlaying && mediaPlayer != null) {
                    try {
                        val current = mediaPlayer?.currentPosition ?: 0
                        val total = mediaPlayer?.duration ?: 0
                        playbackProgressCallback?.invoke(current, total)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                    handler.postDelayed(this, 100)
                }
            }
        })
    }

    fun stopPlayback() {
        mediaPlayer?.apply {
            if (isPlaying()) {
                stop()
            }
            release()
        }
        mediaPlayer = null
        isPlaying = false
    }

    fun isRecording() = isRecording
    fun isPlaying() = isPlaying
    fun getRecordingFile() = audioFile

    fun release() {
        cancelRecording()
        stopPlayback()
        handler.removeCallbacksAndMessages(null)
    }
}

