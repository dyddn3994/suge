package com.ssafy.suge_store.config

import android.app.Application
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase

class ApplicationClass: Application() {

    companion object {
        // firebase auth
        val firebaseAuth: FirebaseAuth by lazy { Firebase.auth }
    }

    override fun onCreate() {
        super.onCreate()

    }
}