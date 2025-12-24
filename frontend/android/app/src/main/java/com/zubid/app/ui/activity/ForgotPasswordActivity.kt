package com.zubid.app.ui.activity

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.model.ForgotPasswordRequest
import com.zubid.app.data.model.ResetPasswordRequest
import com.zubid.app.databinding.ActivityForgotPasswordBinding
import com.zubid.app.util.LocaleHelper
import kotlinx.coroutines.launch

class ForgotPasswordActivity : AppCompatActivity() {

    private lateinit var binding: ActivityForgotPasswordBinding
    private var currentMethod: String = "email"
    private var sentToValue: String = ""

    override fun attachBaseContext(newBase: android.content.Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityForgotPasswordBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupViews()
    }

    private fun setupViews() {
        binding.btnBack.setOnClickListener { finish() }

        // Method toggle
        binding.radioEmail.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                currentMethod = "email"
                binding.inputEmail.visibility = View.VISIBLE
                binding.inputPhone.visibility = View.GONE
            }
        }

        binding.radioPhone.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                currentMethod = "phone"
                binding.inputEmail.visibility = View.GONE
                binding.inputPhone.visibility = View.VISIBLE
            }
        }

        binding.btnSendOtp.setOnClickListener { requestOtp() }
        binding.btnResetPassword.setOnClickListener { resetPassword() }
        binding.btnResendOtp.setOnClickListener { requestOtp() }
    }

    private fun requestOtp() {
        val email = if (currentMethod == "email") binding.inputEmail.text.toString().trim() else null
        val phone = if (currentMethod == "phone") binding.inputPhone.text.toString().trim() else null

        if (email.isNullOrEmpty() && phone.isNullOrEmpty()) {
            Toast.makeText(this, "Please enter your ${currentMethod}", Toast.LENGTH_SHORT).show()
            return
        }

        sentToValue = email ?: phone ?: ""
        showLoading(true)

        lifecycleScope.launch {
            try {
                val request = ForgotPasswordRequest(
                    email = email,
                    phone = phone,
                    method = currentMethod
                )
                val response = ApiClient.apiService.forgotPassword(request)

                if (response.isSuccessful) {
                    response.body()?.let { res ->
                        if (res.error == null) {
                            showStep2()
                            val destination = if (currentMethod == "email") "email" else "phone"
                            binding.otpSentMessage.text = "A verification code has been sent to your $destination"
                            Toast.makeText(this@ForgotPasswordActivity, res.message ?: "Code sent!", Toast.LENGTH_LONG).show()
                        } else {
                            Toast.makeText(this@ForgotPasswordActivity, res.error, Toast.LENGTH_LONG).show()
                        }
                    }
                } else {
                    val errorBody = response.errorBody()?.string()
                    Toast.makeText(this@ForgotPasswordActivity, "Failed to send code: $errorBody", Toast.LENGTH_LONG).show()
                }
            } catch (e: Exception) {
                Toast.makeText(this@ForgotPasswordActivity, "Network error: ${e.message}", Toast.LENGTH_LONG).show()
            } finally {
                showLoading(false)
            }
        }
    }

    private fun resetPassword() {
        val otp = binding.inputOtp.text.toString().trim()
        val newPassword = binding.inputNewPassword.text.toString()
        val confirmPassword = binding.inputConfirmPassword.text.toString()

        if (otp.length != 6) {
            Toast.makeText(this, "Please enter the 6-digit code", Toast.LENGTH_SHORT).show()
            return
        }

        if (newPassword.isEmpty()) {
            Toast.makeText(this, "Please enter a new password", Toast.LENGTH_SHORT).show()
            return
        }

        if (newPassword.length < 8) {
            Toast.makeText(this, "Password must be at least 8 characters", Toast.LENGTH_SHORT).show()
            return
        }

        if (newPassword != confirmPassword) {
            Toast.makeText(this, "Passwords do not match", Toast.LENGTH_SHORT).show()
            return
        }

        showLoading(true)

        lifecycleScope.launch {
            try {
                val request = ResetPasswordRequest(
                    email = if (currentMethod == "email") sentToValue else null,
                    phone = if (currentMethod == "phone") sentToValue else null,
                    token = otp,
                    newPassword = newPassword
                )
                val response = ApiClient.apiService.resetPassword(request)

                if (response.isSuccessful) {
                    response.body()?.let { res ->
                        if (res.error == null) {
                            Toast.makeText(this@ForgotPasswordActivity, "Password reset successful! Please login.", Toast.LENGTH_LONG).show()
                            finish()
                        } else {
                            Toast.makeText(this@ForgotPasswordActivity, res.error, Toast.LENGTH_LONG).show()
                        }
                    }
                } else {
                    val errorBody = response.errorBody()?.string()
                    Toast.makeText(this@ForgotPasswordActivity, "Reset failed: $errorBody", Toast.LENGTH_LONG).show()
                }
            } catch (e: Exception) {
                Toast.makeText(this@ForgotPasswordActivity, "Network error: ${e.message}", Toast.LENGTH_LONG).show()
            } finally {
                showLoading(false)
            }
        }
    }

    private fun showStep2() {
        binding.step1Layout.visibility = View.GONE
        binding.step2Layout.visibility = View.VISIBLE
        binding.subtitle.text = "Enter the verification code and your new password"
    }

    private fun showLoading(show: Boolean) {
        binding.progressBar.visibility = if (show) View.VISIBLE else View.GONE
        binding.btnSendOtp.isEnabled = !show
        binding.btnResetPassword.isEnabled = !show
    }
}
