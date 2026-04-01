package com.bdqrgen.shared

import androidx.compose.ui.graphics.ImageBitmap
import platform.UIKit.UIImage

actual fun ByteArray.toImageBitmap(): ImageBitmap {
    return try {
        val nsData = platform.Foundation.NSData.create(bytes = this.toByteArray())
        val image = UIImage.imageWithData(nsData)
        if (image != null) {
            ImageBitmap(512, 512)
        } else {
            ImageBitmap(1, 1)
        }
    } catch (e: Exception) {
        ImageBitmap(1, 1)
    }
}