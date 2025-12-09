package com.zubid.app.ui.activity

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.zubid.app.R
import com.zubid.app.data.local.SessionManager
import com.zubid.app.databinding.ActivityProfileBinding
import com.zubid.app.util.ImagePickerHelper
import com.zubid.app.util.LocaleHelper
import java.io.File

class ProfileActivity : AppCompatActivity() {

    private lateinit var binding: ActivityProfileBinding
    private lateinit var sessionManager: SessionManager
    private var currentPhotoPath: String? = null

    private val cameraLauncher = registerForActivityResult(
        ActivityResultContracts.TakePicture()
    ) { success ->
        if (success && currentPhotoPath != null) {
            val bitmap = ImagePickerHelper.getBitmapFromPath(currentPhotoPath!!)
            bitmap?.let { processAndSaveImage(it) }
        }
    }

    private val galleryLauncher = registerForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let {
            val bitmap = ImagePickerHelper.getBitmapFromUri(this, it)
            bitmap?.let { bmp -> processAndSaveImage(bmp) }
        }
    }

    private val cameraPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        if (permissions.all { it.value }) {
            openCamera()
        } else {
            Toast.makeText(this, "Camera permission required", Toast.LENGTH_SHORT).show()
        }
    }

    private val galleryPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            openGallery()
        } else {
            Toast.makeText(this, "Storage permission required", Toast.LENGTH_SHORT).show()
        }
    }

    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityProfileBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sessionManager = SessionManager(this)

        setupViews()
        loadUserProfile()
        loadSavedProfileImage()
    }

    private fun setupViews() {
        binding.btnBack.setOnClickListener { finish() }

        binding.userAvatar.setOnClickListener { showImagePickerDialog() }
        binding.btnChangePhoto.setOnClickListener { showImagePickerDialog() }

        binding.btnEditProfile.setOnClickListener {
            Toast.makeText(this, "Edit profile coming soon", Toast.LENGTH_SHORT).show()
        }

        binding.btnChangePassword.setOnClickListener {
            Toast.makeText(this, "Change password coming soon", Toast.LENGTH_SHORT).show()
        }

        binding.btnLogout.setOnClickListener {
            sessionManager.logout()
            Toast.makeText(this, "Logged out", Toast.LENGTH_SHORT).show()
            startActivity(Intent(this, LoginActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            })
            finish()
        }
    }

    private fun showImagePickerDialog() {
        val options = arrayOf(
            getString(R.string.take_photo),
            getString(R.string.choose_gallery),
            getString(R.string.cancel)
        )
        AlertDialog.Builder(this, R.style.AlertDialogTheme)
            .setTitle(getString(R.string.change_photo))
            .setItems(options) { dialog, which ->
                when (which) {
                    0 -> checkCameraPermissionAndOpen()
                    1 -> checkGalleryPermissionAndOpen()
                    2 -> dialog.dismiss()
                }
            }
            .show()
    }

    private fun checkCameraPermissionAndOpen() {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arrayOf(Manifest.permission.CAMERA)
        } else {
            arrayOf(Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE)
        }
        if (permissions.all { ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED }) {
            openCamera()
        } else {
            cameraPermissionLauncher.launch(permissions)
        }
    }

    private fun checkGalleryPermissionAndOpen() {
        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_IMAGES
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }
        if (ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED) {
            openGallery()
        } else {
            galleryPermissionLauncher.launch(permission)
        }
    }

    private fun openCamera() {
        val photoFile = File.createTempFile("profile_", ".jpg", cacheDir)
        currentPhotoPath = photoFile.absolutePath
        val photoUri = androidx.core.content.FileProvider.getUriForFile(
            this, "${packageName}.fileprovider", photoFile
        )
        cameraLauncher.launch(photoUri)
    }

    private fun openGallery() {
        galleryLauncher.launch("image/*")
    }

    private fun processAndSaveImage(bitmap: Bitmap) {
        val resized = ImagePickerHelper.resizeBitmap(bitmap, 500)
        val file = ImagePickerHelper.saveBitmapToFile(this, resized, "profile_image.jpg")
        file?.let {
            sessionManager.saveProfileImagePath(it.absolutePath)
            loadSavedProfileImage()
            Toast.makeText(this, getString(R.string.photo_updated), Toast.LENGTH_SHORT).show()
        }
    }

    private fun loadSavedProfileImage() {
        val imagePath = sessionManager.getProfileImagePath()
        if (!imagePath.isNullOrEmpty()) {
            val file = File(imagePath)
            if (file.exists()) {
                Glide.with(this)
                    .load(file)
                    .circleCrop()
                    .placeholder(R.drawable.ic_person)
                    .into(binding.userAvatar)
            }
        }
    }

    private fun loadUserProfile() {
        val user = sessionManager.getUser()
        if (user != null) {
            binding.userName.text = user.name
            binding.userEmail.text = user.email
            binding.memberSince.text = "Member since 2024"
            binding.totalBids.text = "24"
            binding.wonAuctions.text = "5"
            binding.wishlistItems.text = "12"
        } else {
            binding.userName.text = "Guest User"
            binding.userEmail.text = "Not logged in"
            binding.memberSince.text = ""
            binding.totalBids.text = "0"
            binding.wonAuctions.text = "0"
            binding.wishlistItems.text = "0"
        }
    }
}

