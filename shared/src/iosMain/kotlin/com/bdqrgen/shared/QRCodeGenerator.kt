package com.bdqrgen.shared

import platform.CoreImage.CIFilter
import platform.CoreGraphics.CGImage
import platform.UIKit.UIImage
import platform.Foundation.NSData
import platform.Foundation.create
import platform.CoreGraphics.CGImagePropertyOrientation
import platform.CoreGraphics.CGColorSpaceCreateDeviceRGB

@objc
actual object QRCodeGenerator {
    
    actual fun generateWebsiteQRWithText(url: String): ByteArray? {
        val image = generateQRImage(url) ?: return null
        return addTextToImage(image, url)
    }

    actual fun generateWifiQRWithText(ssid: String, password: String): ByteArray? {
        val wifiString = "WIFI:T:WPA;S:${escapeWifiString(ssid)};P:${escapeWifiString(password)};;"
        val text = "Network: $ssid\nPassword: $password"
        val image = generateQRImage(wifiString) ?: return null
        return addTextToImage(image, text)
    }

    actual fun generateContactQRWithText(name: String, phone: String, email: String): ByteArray? {
        val vCardString = generateVCardString(name, phone, email)
        val text = buildString {
            append("Name: $name")
            if (phone.isNotBlank()) append("\nPhone: $phone")
            if (email.isNotBlank()) append("\nEmail: $email")
        }
        val image = generateQRImage(vCardString) ?: return null
        return addTextToImage(image, text)
    }

    private fun generateQRImage(content: String): UIImage? {
        return try {
            val filter = CIFilter("CIQRCodeGenerator")
            filter.setValue(content, forKey = "inputMessage")
            filter.setValue("H", forKey = "inputCorrectionLevel")
            
            val outputImage = filter.outputImage ?: return null
            
            val scale = 10.0
            let {
                val transform = CGAffineTransformMakeScale(scale, scale)
                outputImage.imageByApplyingTransform(transform)
            }
            
            val context = CIContext()
            val cgImage = context.createCGImage(outputImage, outputImage.extent)
            cgImage?.let { UIImage(it) }
        } catch (e: Exception) {
            null
        }
    }

    private fun addTextToImage(image: UIImage, text: String): ByteArray? {
        return try {
            val imageSize = image.size
            val scale = image.scale
            val width = (imageSize.width * scale).toInt()
            val height = (imageSize.height * scale).toInt()
            
            val textSize: CGFloat = 24.0
            val font = UIFont.systemFontOfSize(textSize)
            
            val paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignmentLeft
            paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            
            val attributes = mapOf(
                NSFontAttributeName to font,
                NSForegroundColorAttributeName to UIColor.blackColor,
                NSParagraphStyleAttributeName to paragraphStyle
            )
            
            val maxWidth = (imageSize.width - 40).toFloat()
            val wrappedLines = wrapText(text, attributes, maxWidth)
            
            let {
                val lineHeight = font.lineHeight + 8
                val textAreaHeight = (wrappedLines.count() * lineHeight).toInt() + 40
                
                UIGraphicsBeginImageContextWithOptions(
                    CGSize(imageSize.width, imageSize.height + textAreaHeight.toDouble()),
                    false,
                    scale
                )
                
                UIColor.whiteColor.setFill()
                UIRectFill(CGRectMake(0.0, 0.0, imageSize.width, imageSize.height + textAreaHeight.toDouble()))
                
                image.drawAtPoint(CGPointMake(0.0, 0.0))
                
                val startY = imageSize.height + 30.0
                wrappedLines.forEachIndexed { index, line ->
                    val y = startY + index * lineHeight
                    (line as NSString).drawAtPoint(
                        CGPointMake(20.0, y.toDouble()),
                        with = attributes
                    )
                }
                
                val resultImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                resultImage?.pngData()
            }
        } catch (e: Exception) {
            image.pngData()
        }
    }

    private fun wrapText(text: String, attributes: Map<Any?, Any>, maxWidth: CGFloat): List<String> {
        val lines = mutableListOf<String>()
        val inputLines = text.split("\n")
        
        inputLines.forEach { line ->
            val nsLine = line as NSString
            val lineWidth = nsLine.sizeWithAttributes(attributes).width
            
            if (lineWidth <= maxWidth) {
                lines.add(line)
            } else {
                var currentLine = ""
                val words = line.split(" ")
                
                words.forEach { word ->
                    val testLine = if (currentLine.isEmpty()) word else "$currentLine $word"
                    val testWidth = (testLine as NSString).sizeWithAttributes(attributes).width
                    
                    if (testWidth <= maxWidth) {
                        currentLine = testLine
                    } else {
                        if (currentLine.isNotEmpty()) {
                            lines.add(currentLine)
                        }
                        currentLine = word
                    }
                }
                
                if (currentLine.isNotEmpty()) {
                    lines.add(currentLine)
                }
            }
        }
        
        return lines
    }

    private fun escapeWifiString(input: String): String {
        return input
            .replace("\\", "\\\\")
            .replace(";", "\\;")
            .replace(",", "\\,")
            .replace(":", "\\:")
            .replace("\"", "\\\"")
    }

    private fun generateVCardString(name: String, phone: String, email: String): String {
        return buildString {
            append("BEGIN:VCARD\n")
            append("VERSION:3.0\n")
            append("FN:$name\n")
            if (phone.isNotBlank()) append("TEL:$phone\n")
            if (email.isNotBlank()) append("EMAIL:$email\n")
            append("END:VCARD")
        }
    }
}

@objc
class QRCodeGeneratorHelper {
    companion object {
        @objc
        fun escapeWifiString(input: String): String {
            return input
                .replace("\\", "\\\\")
                .replace(";", "\\;")
                .replace(",", "\\,")
                .replace(":", "\\:")
                .replace("\"", "\\\"")
        }

        @objc
        fun generateVCardString(name: String, phone: String, email: String): String {
            return buildString {
                append("BEGIN:VCARD\n")
                append("VERSION:3.0\n")
                append("FN:$name\n")
                if (phone.isNotBlank()) append("TEL:$phone\n")
                if (email.isNotBlank()) append("EMAIL:$email\n")
                append("END:VCARD")
            }
        }
    }
}