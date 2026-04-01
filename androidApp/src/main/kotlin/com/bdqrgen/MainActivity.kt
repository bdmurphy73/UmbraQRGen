package com.bdqrgen

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.core.content.FileProvider
import com.bdqrgen.shared.BDQRGenApp
import com.bdqrgen.shared.QRViewModel
import java.io.File
import java.io.FileOutputStream

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            BDQRGenApp(
                viewModel = QRViewModel(),
                onSave = { bytes -> saveImageToGallery(bytes) },
                onShare = { bytes -> shareImage(bytes) }
            )
        }
    }

    private fun saveImageToGallery(bytes: ByteArray) {
        try {
            val fileName = "qrcode_${System.currentTimeMillis()}.png"
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/BDQRGen")
                }
                
                val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                uri?.let {
                    contentResolver.openOutputStream(it)?.use { outputStream ->
                        outputStream.write(bytes)
                    }
                }
                Toast.makeText(this, "QR Code saved to gallery!", Toast.LENGTH_SHORT).show()
            } else {
                val directory = File(
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
                    "BDQRGen"
                )
                if (!directory.exists()) {
                    directory.mkdirs()
                }
                
                val file = File(directory, fileName)
                FileOutputStream(file).use { outputStream ->
                    outputStream.write(bytes)
                }
                Toast.makeText(this, "QR Code saved to gallery!", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(this, "Failed to save QR Code", Toast.LENGTH_SHORT).show()
        }
    }

    private fun shareImage(bytes: ByteArray) {
        try {
            val cachePath = File(cacheDir, "images")
            cachePath.mkdirs()
            
            val file = File(cachePath, "shared_qrcode.png")
            FileOutputStream(file).use { outputStream ->
                outputStream.write(bytes)
            }
            
            val uri = FileProvider.getUriForFile(
                this,
                "${packageName}.fileprovider",
                file
            )
            
            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = "image/png"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            
            startActivity(Intent.createChooser(shareIntent, "Share QR Code"))
        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(this, "Failed to share QR Code", Toast.LENGTH_SHORT).show()
        }
    }
}