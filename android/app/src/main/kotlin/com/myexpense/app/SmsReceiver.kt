package com.myexpense.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            if (messages != null && messages.isNotEmpty()) {
                for (sms in messages) {
                    val sender = sms.displayOriginatingAddress ?: sms.originatingAddress ?: ""
                    val body = sms.messageBody ?: ""

                    if (sender.isNotEmpty() && body.isNotEmpty()) {
                        val smsIntent = Intent(ACTION_SMS_RECEIVED).apply {
                            putExtra(EXTRA_SENDER, sender)
                            putExtra(EXTRA_BODY, body)
                            setPackage(context?.packageName)
                        }
                        context?.sendBroadcast(smsIntent)
                    }
                }
            }
        }
    }

    companion object {
        const val ACTION_SMS_RECEIVED = "com.myexpense.app.SMS_RECEIVED"
        const val EXTRA_SENDER = "sender"
        const val EXTRA_BODY = "body"
    }
}
