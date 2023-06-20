package com.ssafy.suge_store.src.main

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.MotionEvent
import android.view.inputmethod.InputMethodManager
import androidx.core.view.ViewCompat.canScrollVertically
import androidx.core.view.isVisible
import androidx.navigation.Navigation
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.textfield.TextInputEditText
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.BaseActivity
import com.ssafy.suge_store.databinding.ActivityMainBinding
import com.ssafy.suge_store.src.home.HomeFragment
import com.ssafy.suge_store.src.mypage.MypageFragment
import com.ssafy.suge_store.src.point.PointFragment

private const val TAG = "MainActivity_로그"
class MainActivity: BaseActivity<ActivityMainBinding>(ActivityMainBinding::inflate) {
    // 스크롤중인지 여부
    private var isScrolling = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initBottomNav()
    }

    // 배경 클릭시 키보드 내리기
    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        if (ev?.action == MotionEvent.ACTION_UP) {
            val imm: InputMethodManager = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.hideSoftInputFromWindow(currentFocus?.windowToken, 0)

            // TextInputEditText에서 focus 제거
            if (currentFocus is TextInputEditText) currentFocus!!.clearFocus()
        }

        // 스크롤 제어 포함
//        when (ev?.action) {
//            MotionEvent.ACTION_UP -> {
//                if (!isScrolling) {
//                    val imm: InputMethodManager = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
//                    imm.hideSoftInputFromWindow(currentFocus?.windowToken, 0)
//
//                    // TextInputEditText에서 focus 제거
//                    if (currentFocus is TextInputEditText) currentFocus!!.clearFocus()
//                }
//                isScrolling = false
//            }
//            MotionEvent.ACTION_MOVE -> {
//                isScrolling = true
//            }
//        }
        return super.dispatchTouchEvent(ev)
    }

    private fun initBottomNav() {
        // 특정 fragment에서 bottom navigation 안보이게 설정
        val noBottomNavigationConfig = AppBarConfiguration(setOf(
            R.id.fragment_login,
            R.id.fragment_sign_up
        ))
        (supportFragmentManager.findFragmentById(R.id.fcv_main) as NavHostFragment).navController.addOnDestinationChangedListener { _, destination, _ ->
            binding.bottomNav.isVisible = !noBottomNavigationConfig.topLevelDestinations.contains(destination.id)
        }

        binding.bottomNav.apply {
            menu.findItem(R.id.menu_home).isChecked = true
            setOnItemSelectedListener { item ->
                when (item.itemId) {
                    R.id.menu_point -> {
                        Navigation.findNavController(binding.fcvMain).apply {
                            popBackStack()
                            navigate(R.id.fragment_point)
                        }
                    }
                    R.id.menu_home -> {
                        Navigation.findNavController(binding.fcvMain).apply {
                            popBackStack()
                            navigate(R.id.fragment_home)
                        }
                    }
                    R.id.menu_more -> {
                        Navigation.findNavController(binding.fcvMain).apply {
                            popBackStack()
                            navigate(R.id.fragment_mypage)
                        }
                    }
                }
                true
            }
        }
    }
}