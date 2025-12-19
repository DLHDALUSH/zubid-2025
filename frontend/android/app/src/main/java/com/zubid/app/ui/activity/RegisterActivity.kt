package com.zubid.app.ui.activity

import android.app.DatePickerDialog
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
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
import java.text.SimpleDateFormat
import java.util.*

class RegisterActivity : AppCompatActivity() {

    private lateinit var binding: ActivityRegisterBinding
    private lateinit var sessionManager: SessionManager
    private var selectedBirthDate: String = ""

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

        // Date picker for birth date
        binding.inputBirthDate.setOnClickListener {
            showDatePicker()
        }

        binding.btnRegister.setOnClickListener {
            val username = binding.inputUsername.text.toString().trim()
            val email = binding.inputEmail.text.toString().trim()
            val idNumber = binding.inputIdNumber.text.toString().trim()
            val phone = binding.inputPhone.text.toString().trim()
            val address = binding.inputAddress.text.toString().trim()
            val password = binding.inputPassword.text.toString()

            if (!isNetworkAvailable()) {
                showError("No internet connection. Please check your network and try again.")
                return@setOnClickListener
            }

            if (validateInput(username, email, idNumber, phone, address, password)) {
                performRegister(username, email, idNumber, phone, address, password)
            }
        }

        binding.btnLogin.setOnClickListener {
            finish()
        }

        // Add test buttons for debugging (remove in production)
        binding.inputUsername.setOnLongClickListener {
            testApiConnectivity()
            true
        }

        binding.inputEmail.setOnLongClickListener {
            fillTestData()
            true
        }
    }

    private fun showDatePicker() {
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.YEAR, -18) // Default to 18 years ago

        val datePickerDialog = DatePickerDialog(
            this,
            { _, year, month, dayOfMonth ->
                val cal = Calendar.getInstance()
                cal.set(year, month, dayOfMonth)
                val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
                selectedBirthDate = dateFormat.format(cal.time)
                binding.inputBirthDate.setText(selectedBirthDate)
            },
            calendar.get(Calendar.YEAR),
            calendar.get(Calendar.MONTH),
            calendar.get(Calendar.DAY_OF_MONTH)
        )

        // Max date is 18 years ago (must be 18+)
        val maxDate = Calendar.getInstance()
        maxDate.add(Calendar.YEAR, -18)
        datePickerDialog.datePicker.maxDate = maxDate.timeInMillis

        datePickerDialog.show()
    }

    private fun validateInput(username: String, email: String, idNumber: String,
                              phone: String, address: String, password: String): Boolean {
        if (username.isEmpty()) {
            binding.inputUsername.error = "Username is required"
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
        if (idNumber.isEmpty()) {
            binding.inputIdNumber.error = "ID Number is required"
            return false
        }
        if (selectedBirthDate.isEmpty()) {
            binding.inputBirthDate.error = "Date of Birth is required"
            return false
        }
        if (phone.isEmpty()) {
            binding.inputPhone.error = "Phone number is required"
            return false
        }
        if (address.isEmpty()) {
            binding.inputAddress.error = "Address is required"
            return false
        }
        if (address.length < 5) {
            binding.inputAddress.error = "Address must be at least 5 characters"
            return false
        }
        if (password.isEmpty()) {
            binding.inputPassword.error = "Password is required"
            return false
        }
        if (password.length < 8) {
            binding.inputPassword.error = "Password must be at least 8 characters"
            return false
        }
        // Check password complexity
        if (!password.any { it.isLowerCase() }) {
            binding.inputPassword.error = "Password must contain a lowercase letter"
            return false
        }
        if (!password.any { it.isUpperCase() }) {
            binding.inputPassword.error = "Password must contain an uppercase letter"
            return false
        }
        if (!password.any { it.isDigit() }) {
            binding.inputPassword.error = "Password must contain a number"
            return false
        }
        if (!password.any { it in "!@#\$%^&*()_+-=[]{}|;:,.<>?" }) {
            binding.inputPassword.error = "Password must contain a special character"
            return false
        }
        return true
    }

    private fun performRegister(username: String, email: String, idNumber: String,
                                phone: String, address: String, password: String) {
        showLoading(true)

        lifecycleScope.launch {
            try {
                val registerRequest = RegisterRequest(
                    username = username,
                    email = email,
                    password = password,
                    idNumber = idNumber,
                    birthDate = selectedBirthDate,
                    phone = phone,
                    address = address
                )

                android.util.Log.d("RegisterActivity", "Sending registration request: $registerRequest")

                val response = ApiClient.apiService.register(registerRequest)

                android.util.Log.d("RegisterActivity", "Response code: ${response.code()}")
                android.util.Log.d("RegisterActivity", "Response message: ${response.message()}")

                if (response.isSuccessful) {
                    response.body()?.let { authResponse ->
                        android.util.Log.d("RegisterActivity", "Response body: $authResponse")
                        if (authResponse.error == null) {
                            authResponse.user?.let { sessionManager.saveUser(it) }
                            Toast.makeText(this@RegisterActivity,
                                authResponse.message ?: "Registration successful!",
                                Toast.LENGTH_SHORT).show()
                            startMainActivity()
                        } else {
                            showError(authResponse.error)
                        }
                    } ?: run {
                        showError("Registration failed: Empty response from server")
                    }
                } else {
                    // Try to parse error from response body
                    val errorBody = response.errorBody()?.string()
                    android.util.Log.e("RegisterActivity", "Error response: $errorBody")

                    try {
                        val gson = com.google.gson.Gson()
                        val errorResponse = gson.fromJson(errorBody, com.zubid.app.data.model.AuthResponse::class.java)
                        showError(errorResponse.error ?: "Registration failed: ${response.code()} ${response.message()}")
                    } catch (e: Exception) {
                        android.util.Log.e("RegisterActivity", "Failed to parse error response", e)
                        showError("Registration failed: ${response.code()} ${response.message()}")
                    }
                }
            } catch (e: java.net.SocketTimeoutException) {
                android.util.Log.e("RegisterActivity", "Timeout error", e)
                showError("Registration timeout. Please check your internet connection and try again.")
            } catch (e: java.net.UnknownHostException) {
                android.util.Log.e("RegisterActivity", "Network error", e)
                showError("Cannot connect to server. Please check your internet connection.")
            } catch (e: java.net.ConnectException) {
                android.util.Log.e("RegisterActivity", "Connection error", e)
                showError("Cannot connect to server. Please try again later.")
            } catch (e: Exception) {
                android.util.Log.e("RegisterActivity", "Registration error", e)
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

    private fun isNetworkAvailable(): Boolean {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connectivityManager.activeNetwork ?: return false
        val networkCapabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
        return networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }

    private fun testApiConnectivity() {
        lifecycleScope.launch {
            try {
                android.util.Log.d("RegisterActivity", "Testing API connectivity...")
                Toast.makeText(this@RegisterActivity, "Testing API connectivity...", Toast.LENGTH_SHORT).show()

                // Try health check first
                val response = ApiClient.apiService.healthCheck()
                android.util.Log.d("RegisterActivity", "Health check response: ${response.code()}")

                if (response.isSuccessful) {
                    val body = response.body()
                    android.util.Log.d("RegisterActivity", "Health check body: $body")
                    Toast.makeText(this@RegisterActivity, "API is healthy! Status: ${body?.get("status")}", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(this@RegisterActivity, "API health check failed: ${response.code()}", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                android.util.Log.e("RegisterActivity", "API test failed", e)
                Toast.makeText(this@RegisterActivity, "API test failed: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun fillTestData() {
        val timestamp = System.currentTimeMillis()
        binding.inputUsername.setText("testuser$timestamp")
        binding.inputEmail.setText("test$timestamp@example.com")
        binding.inputIdNumber.setText("ID$timestamp")
        binding.inputPhone.setText("+1234567890")
        binding.inputAddress.setText("123 Test Street, Test City, Test Country")
        binding.inputPassword.setText("TestPass123!")
        selectedBirthDate = "1990-01-01"
        binding.inputBirthDate.setText(selectedBirthDate)
        Toast.makeText(this, "Test data filled. You can now test registration.", Toast.LENGTH_SHORT).show()
    }
}

