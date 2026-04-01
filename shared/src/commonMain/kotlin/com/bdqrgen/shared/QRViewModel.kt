package com.bdqrgen.shared

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class QRViewModel {
    private val _websiteQrState = MutableStateFlow(QrCodeState())
    val websiteQrState: StateFlow<QrCodeState> = _websiteQrState.asStateFlow()

    private val _wifiQrState = MutableStateFlow(QrCodeState())
    val wifiQrState: StateFlow<QrCodeState> = _wifiQrState.asStateFlow()

    private val _contactQrState = MutableStateFlow(QrCodeState())
    val contactQrState: StateFlow<QrCodeState> = _contactQrState.asStateFlow()

    private val scope = CoroutineScope(Dispatchers.Default)

    fun generateWebsiteQR(url: String) {
        if (url.isBlank()) {
            _websiteQrState.value = QrCodeState()
            return
        }
        scope.launch {
            _websiteQrState.value = _websiteQrState.value.copy(isLoading = true)
            val bitmap = QRCodeGenerator.generateWebsiteQRWithText(url)
            _websiteQrState.value = QrCodeState(
                bitmap = bitmap,
                isLoading = false,
                errorMessage = if (bitmap == null) "Failed to generate QR code" else null
            )
        }
    }

    fun generateWifiQR(ssid: String, password: String) {
        if (ssid.isBlank() || password.isBlank()) {
            _wifiQrState.value = QrCodeState()
            return
        }
        scope.launch {
            _wifiQrState.value = _wifiQrState.value.copy(isLoading = true)
            val bitmap = QRCodeGenerator.generateWifiQRWithText(ssid, password)
            _wifiQrState.value = QrCodeState(
                bitmap = bitmap,
                isLoading = false,
                errorMessage = if (bitmap == null) "Failed to generate QR code" else null
            )
        }
    }

    fun generateContactQR(name: String, phone: String, email: String) {
        if (name.isBlank() || (phone.isBlank() && email.isBlank())) {
            _contactQrState.value = QrCodeState()
            return
        }
        scope.launch {
            _contactQrState.value = _contactQrState.value.copy(isLoading = true)
            val bitmap = QRCodeGenerator.generateContactQRWithText(name, phone, email)
            _contactQrState.value = QrCodeState(
                bitmap = bitmap,
                isLoading = false,
                errorMessage = if (bitmap == null) "Failed to generate QR code" else null
            )
        }
    }

    fun clearMessages() {
        _websiteQrState.value = _websiteQrState.value.copy(errorMessage = null)
        _wifiQrState.value = _wifiQrState.value.copy(errorMessage = null)
        _contactQrState.value = _contactQrState.value.copy(errorMessage = null)
    }
}

data class QrCodeState(
    val bitmap: ByteArray? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false
        other as QrCodeState
        return bitmap?.contentEquals(other.bitmap) == true &&
                isLoading == other.isLoading &&
                errorMessage == other.errorMessage
    }

    override fun hashCode(): Int {
        var result = bitmap?.contentHashCode() ?: 0
        result = 31 * result + isLoading.hashCode()
        result = 31 * result + errorMessage.hashCode()
        return result
    }
}