package com.bdqrgen.shared

expect object QRCodeGenerator {
    fun generateWebsiteQRWithText(url: String): ByteArray?
    fun generateWifiQRWithText(ssid: String, password: String): ByteArray?
    fun generateContactQRWithText(name: String, phone: String, email: String): ByteArray?
}