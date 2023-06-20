package com.ssafy.suge_store.src.splash

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.FragmentSplashBinding

class SplashFragment: BaseFragment<FragmentSplashBinding>(FragmentSplashBinding::bind, R.layout.fragment_splash) {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Handler(Looper.getMainLooper()).postDelayed({
        }, 1_000)
    }
}