package com.zubid.app.ui.activity

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.zubid.app.MainActivity
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.local.SessionManager
import com.zubid.app.data.model.RegisterRequest
import com.zubid.app.databinding.ActivityRegisterBinding
import com.zubid.app.util.LocaleHelper
import kotlinx.coroutines.launch

class RegisterActivity : AppCompatActivity() {

    private lateinit var binding: ActivityRegisterBinding
    private lateinit var sessionManager: SessionManager

    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        sessionManager = SessionManager(this)
        binding = ActivityRegisterBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupViews()
    }

    private fun setupViews() {
        binding.btnBack.setOnClickListener {
            finish()
        }

        binding.btnRegister.setOnClickListener {
            val name = binding.inputName.text.toString().trim()
            val email = binding.inputEmail.text.toString().trim()
            val password = binding.inputPassword.text.toString()
            val confirmPassword = binding.inputConfirmPassword.text.toString()

            if (validateInput(name, email, password, confirmPassword)) {
                performRegister(name, email, password, confirmPassword)
            }
        }

        binding.btnLogin.setOnClickListener {
            finish()
        }
    }

    private fun validateInput(name: String, email: String, password: String, confirmPassword: String): Boolean {
        if (name.isEmpty()) {
            binding.inputName.error = "Name is required"
            return false
        }
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
        if (password != confirmPassword) {
            binding.inputConfirmPassword.error = "Passwords do not match"
            return false
        }
        return true
    }

    private fun performRegister(name: String, email: String, password: String, confirmPassword: String) {
        showLoading(true)
        
        lifecycleScope.launch {
            try {
                val response = ApiClient.apiService.register(
                    RegisterRequest(name, email, password, confirmPassword)
                )
                
                if (response.isSuccessful && response.body()?.success == true) {
                    response.body()?.let { authResponse ->
                        authResponse.token?.let { sessionManager.saveAuthToken(it) }
                        authResponse.user?.let { sessionManager.saveUser(it) }
                    }
                    Toast.makeText(this@RegisterActivity, "Registration successful!", Toast.LENGTH_SHORT).show()
                    startMainActivity()
                } else {
                    showError(response.body()?.message ?: "Registration failed")
                }
            } catch (e: Exception) {
                showError("Network error: ${e.message}")
            } finally {
                showLoading(false)
            }
        }
    }

    private fun showLoading(show: Boolean) {
        binding.progressBar.visibility = if (show) View.VISIBLE else View.GONE
        binding.btnRegister.isEnabled = !show
    }

    private fun showError(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
    }

    private fun startMainActivity() {
        val intent = Intent(this, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)
        finish()
    }
}

