package com.ssafy.suge_store.src.main

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.KeyEvent
import android.view.View
import androidx.navigation.fragment.findNavController
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.ApplicationClass.Companion.firebaseAuth
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.FragmentSignUpBinding
import com.ssafy.suge_store.src.models.User

private const val TAG = "SignUpFragment_로그"
class SignUpFragment: BaseFragment<FragmentSignUpBinding>(FragmentSignUpBinding::bind, R.layout.fragment_sign_up) {

    // firebase db
    private val userRef: DatabaseReference by lazy { Firebase.database.getReference("user") }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
        initEditText()
    }

    private fun initView() {
        binding.apply {
            // 회원가입 클릭
            btnSignUp.setOnClickListener {
                // 입력값 공백
                if (etName.text.isNullOrBlank()) tilName.error = "이름을 입력하세요"
                else tilName.isErrorEnabled = false
                if (etEmail.text.isNullOrBlank()) tilEmail.error = "이메일을 입력하세요"
                else tilEmail.isErrorEnabled = false
                if (etPwd.text.isNullOrBlank()) tilPwd.error = "비밀번호를 입력하세요"
                else tilPwd.isErrorEnabled = false
                if (etPwdCheck.text.isNullOrBlank()) tilPwdCheck.error = "비밀번호를 입력하세요"
                else if (etPwd.text.toString() != etPwdCheck.text.toString()) tilPwdCheck.error = "비밀번호를 다시 입력하세요"
                else tilPwdCheck.isErrorEnabled = false

                // 전체 입력 완료
                if (tilName.error.isNullOrBlank()
                    && tilEmail.error.isNullOrBlank()
                    && tilPwd.error.isNullOrBlank()
                    && tilPwdCheck.error.isNullOrBlank()
                ) {
                    signUp(etName.text.toString(), etEmail.text.toString(), etPwd.text.toString())
                }
            }
        }
    }

    private fun initEditText() {
        binding.apply {
            // Id, Password 엔터 클릭할 때 동작
            etName.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER){
                    etEmail.requestFocus()
                }
                false
            }
            etEmail.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    etPwd.requestFocus()
                }
                false
            }
            etPwd.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    etPwdCheck.requestFocus()
                }
                false
            }
            etPwdCheck.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    btnSignUp.performClick()
                }
                false
            }

            // error가 활성화 된 상태에서 입력하면 비활성화
            etName.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilName.isErrorEnabled) tilName.isErrorEnabled = false
                }
            })
            etEmail.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilEmail.isErrorEnabled) tilEmail.isErrorEnabled = false
                }
            })
            etPwd.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilPwd.isErrorEnabled) tilPwd.isErrorEnabled = false
                }
            })
            etPwdCheck.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilPwdCheck.isErrorEnabled) tilPwdCheck.isErrorEnabled = false
                }
            })
        }
    }

    // 회원가입
    private fun signUp(name: String, email: String, pwd: String) {
        firebaseAuth.createUserWithEmailAndPassword(email, pwd)
            .addOnCompleteListener(requireActivity()) { task ->
                if (task.isSuccessful) {
                    userRef.push().setValue(User(email, name))

                    firebaseAuth.signOut()
                    showSnackbar("회원가입에 성공하였습니다.")
                    findNavController().popBackStack()
                }
                else {
                    Log.d(TAG, "signUp: ${task.exception}")
                    showSnackbar("회원가입에 실패하였습니다.")
                }
            }
    }
}