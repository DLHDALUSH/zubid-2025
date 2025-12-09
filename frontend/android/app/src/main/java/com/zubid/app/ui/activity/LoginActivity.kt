package com.zubid.app.ui.activity

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.lifecycleScope
import com.zubid.app.MainActivity
import com.zubid.app.R
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.local.SessionManager
import com.zubid.app.data.model.LoginRequest
import com.zubid.app.databinding.ActivityLoginBinding
import com.zubid.app.util.BiometricHelper
import com.zubid.app.util.LocaleHelper
import kotlinx.coroutines.launch

class LoginActivity : AppCompatActivity() {

    private lateinit var binding: ActivityLoginBinding
    private lateinit var sessionManager: SessionManager
    private var biometricHelper: BiometricHelper? = null

    override fun attachBaseContext(newBase: android.content.Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)

        sessionManager = SessionManager(this)

        // Check if already logged in
        if (sessionManager.isLoggedIn()) {
            // Try biometric if enabled
            if (sessionManager.isBiometricEnabled() && BiometricHelper.isBiometricAvailable(this)) {
                binding = ActivityLoginBinding.inflate(layoutInflater)
                setContentView(binding.root)
                setupViews()
                showBiometricPrompt()
            } else {
                startMainActivity()
            }
            return
        }

        binding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupViews()
        checkBiometricAvailability()
    }

    private fun setupViews() {
        binding.btnLogin.setOnClickListener {
            val email = binding.inputEmail.text.toString().trim()
            val password = binding.inputPassword.text.toString()

            if (validateInput(email, password)) {
                performLogin(email, password)
            }
        }

        binding.btnRegister.setOnClickListener {
            startActivity(Intent(this, RegisterActivity::class.java))
        }

        binding.btnSkip.setOnClickListener {
            startMainActivity()
        }
    }

    private fun validateInput(email: String, password: String): Boolean {
        if (email.isEmpty()) {
            binding.inputEmail.error = "Email is required"
            return false
        }
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            binding.inputEmail.error = "Invalid email format"
            return false
        }
        if (password.isEmpty()) {
            binding.inputPassword.error = "Password is required"
            return false
        }
        if (password.length < 6) {
            binding.inputPassword.error = "Password must be at least 6 characters"
            return false
        }
        return true
    }

    private fun performLogin(email: String, password: String) {
        showLoading(true)
        
        lifecycleScope.launch {
            try {
                val response = ApiClient.apiService.login(LoginRequest(email, password))
                
                if (response.isSuccessful && response.body()?.success == true) {
                    response.body()?.let { authResponse ->
                        authResponse.token?.let { sessionManager.saveAuthToken(it) }
                        authResponse.user?.let { sessionManager.saveUser(it) }
                    }
                    startMainActivity()
                } else {
                    showError(response.body()?.message ?: "Login failed")
                }
            } catch (e: Exception) {
                // For demo: allow skip on network error
                showError("Network error: ${e.message}")
            } finally {
                showLoading(false)
            }
        }
    }

    private fun showLoading(show: Boolean) {
        binding.progressBar.visibility = if (show) View.VISIBLE else View.GONE
        binding.btnLogin.isEnabled = !show
        binding.btnRegister.isEnabled = !show
    }

    private fun showError(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
    }

    private fun startMainActivity() {
        startActivity(Intent(this, MainActivity::class.java))
        finish()
    }

    private fun checkBiometricAvailability() {
        if (BiometricHelper.isBiometricAvailable(this)) {
            biometricHelper = BiometricHelper(this)
            binding.btnBiometric?.visibility = View.VISIBLE
            binding.btnBiometric?.setOnClickListener {
                showBiometricPrompt()
            }
        } else {
            binding.btnBiometric?.visibility = View.GONE
        }
    }

    private fun showBiometricPrompt() {
        biometricHelper = BiometricHelper(this)
        biometricHelper?.authenticate(
            title = getString(R.string.biometric_title),
            subtitle = getString(R.string.biometric_subtitle),
            negativeButtonText = getString(R.string.biometric_cancel),
            callback = object : BiometricHelper.BiometricCallback {
                override fun onSuccess() {
                    startMainActivity()
                }

                override fun onError(errorCode: Int, errorMessage: String) {
                    // User cancelled or error - stay on login screen
                    if (errorCode != 10 && errorCode != 13) { // Not user cancelled
                        Toast.makeText(this@LoginActivity, errorMessage, Toast.LENGTH_SHORT).show()
                    }
                }

                override fun onFailed() {
                    Toast.makeText(this@LoginActivity, "Authentication failed", Toast.LENGTH_SHORT).show()
                }
            }
        )
    }
}

