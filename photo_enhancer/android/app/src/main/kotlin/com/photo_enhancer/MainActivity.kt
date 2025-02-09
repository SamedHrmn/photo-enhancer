package com.photo_enhancer

import android.annotation.SuppressLint
import android.provider.Settings
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val CHANNEL = "photoEnhancerChannel"
    private val GCP_NUMBER = 82114047904L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getIntegrityToken" -> {
                    getIntegrityToken(result)
                }
                "getAndroidId" -> {
                    getAndroidId(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    @SuppressLint("HardwareIds")
    private fun getAndroidId(result: MethodChannel.Result){
        val androidId = Settings.Secure.getString(contentResolver,Settings.Secure.ANDROID_ID)
        result.success(androidId)

    }

    private fun getIntegrityToken(result: MethodChannel.Result) {
        val integrityManager = IntegrityManagerFactory.create(applicationContext)

        // Request the integrity token
        val tokenResponse = integrityManager.requestIntegrityToken(
            IntegrityTokenRequest.builder().setCloudProjectNumber(GCP_NUMBER)
                .setNonce(generateNonce()).build()
        )

        tokenResponse.addOnSuccessListener { integrityTokenResponse ->
            val integrityToken = integrityTokenResponse?.token()
            if (integrityToken != null) {
                result.success(integrityToken)
            } else {
                result.error("TOKEN_ERROR", "Integrity token is null", null)
            }
        }

        tokenResponse.addOnFailureListener { exception ->
            result.error(
                "TOKEN_ERROR",
                "Failed to get integrity token",
                exception.message
            )
        }
    }

    private fun generateNonce(): String {
        val nonce = UUID.randomUUID().toString()
        return nonce
    }

}
