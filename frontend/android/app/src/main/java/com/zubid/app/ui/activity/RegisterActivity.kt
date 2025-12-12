package com.zubid.app.ui.activity

import android.app.DatePickerDialog
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

            if (validateInput(username, email, idNumber, phone, address, password)) {
                performRegister(username, email, idNumber, phone, address, password)
            }
        }

        binding.btnLogin.setOnClickListener {
            finish()
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
                val response = ApiClient.apiService.register(
                    RegisterRequest(
                        username = username,
                        email = email,
                        password = password,
                        idNumber = idNumber,
                        birthDate = selectedBirthDate,
                        phone = phone,
                        address = address
                    )
                )

                if (response.isSuccessful) {
                    response.body()?.let { authResponse ->
                        if (authResponse.error == null) {
                            authResponse.user?.let { sessionManager.saveUser(it) }
                            Toast.makeText(this@RegisterActivity, "Registration successful!", Toast.LENGTH_SHORT).show()
                            startMainActivity()
                        } else {
                            showError(authResponse.error)
                        }
                    }
                } else {
                    // Try to parse error from response
                    showError("Registration failed. Please try again.")
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

