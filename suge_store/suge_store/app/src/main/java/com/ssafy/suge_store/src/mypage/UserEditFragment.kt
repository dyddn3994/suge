package com.ssafy.suge_store.src.mypage

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.KeyEvent
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.navigation.Navigation
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.ApplicationClass
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.FragmentUserEditBinding
import com.ssafy.suge_store.src.viewmodels.UserViewModel

private const val TAG = "UserEditFragment_로그"
class UserEditFragment: BaseFragment<FragmentUserEditBinding>(FragmentUserEditBinding::bind, R.layout.fragment_user_edit) {

    // ViewModel
    private val userViewModel by activityViewModels<UserViewModel>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
        initEditText()
    }

    private fun initView() {
        binding.apply {
            // 이름 및 이메일 input 기본값 설정
            etEmail.setText(userViewModel.userInfo.email)
            etName.setText(userViewModel.userInfo.name)

            // 변경 버튼
            btnEditUser.setOnClickListener {
                if (etCurrentPassword.text.isNullOrBlank()) tilCurrentPassword.error = "현재 비밀번호를 입력해 주세요."
                else tilCurrentPassword.isErrorEnabled = false
                if (etNewPassword.text.isNullOrBlank()) tilNewPassword.error = "신규 비밀번호를 입력해 주세요."
                else tilNewPassword.isErrorEnabled = false

                if (tilCurrentPassword.error.isNullOrBlank() && tilNewPassword.error.isNullOrBlank()) {
                    // 현재 비밀번호 동일한지 확인
                    showLoadingDialog(requireContext())
                    ApplicationClass.firebaseAuth.signInWithEmailAndPassword(ApplicationClass.firebaseAuth.currentUser?.email!!, etCurrentPassword.text.toString())
                        .addOnCompleteListener(requireActivity()) { task ->
                            if (!task.isSuccessful) {
                                tilCurrentPassword.error = "비밀번호를 다시 입력해 주세요."
                                dismissLoadingDialog()
                            }
                            else {
                                setNewPassword(etNewPassword.text.toString())
                            }
                        }
                }
            }
        }
    }

    private fun initEditText() {
        binding.apply {
            // EditText enter 클릭 시 동작
            etCurrentPassword.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    etNewPassword.requestFocus()
                }
                false
            }
            etNewPassword.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    btnEditUser.performClick()
                }
                false
            }

            // error가 활성화 된 상태에서 입력하면 비활성화
            etCurrentPassword.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilCurrentPassword.isErrorEnabled) tilCurrentPassword.isErrorEnabled = false
                }
            })
            etNewPassword.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilNewPassword.isErrorEnabled) tilNewPassword.isErrorEnabled = false
                }
            })
        }
    }

    // 신규 비밀번호 등록
    private fun setNewPassword(newPassword: String) {
        ApplicationClass.firebaseAuth.currentUser!!.updatePassword(newPassword)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    dismissLoadingDialog()
                    showSnackbar("비밀번호 변경이 완료되었습니다. 다시 로그인 하세요.")
                    ApplicationClass.firebaseAuth.signOut()
                    Navigation.findNavController(binding.root).apply {
                        popBackStack()
                        navigate(R.id.fragment_login)
                    }
                }
                else {
                    Log.d(TAG, "setNewPassword: ${task.exception!!.message}")
                    dismissLoadingDialog()
                    showSnackbar("비밀번호 변경에 실패하였습니다.")
                }
            }
    }

    // 현재 비밀번호 체크
    // 비동기 처리 문제 해결 못함
//    private fun isNotSameCurrentPassword(email: String, password: String): Boolean {
//        var isSame = false
//        ApplicationClass.firebaseAuth.signInWithEmailAndPassword(email, password)
//            .addOnCompleteListener(requireActivity()) { task ->
//                isSame = !task.isSuccessful
//                Log.d(TAG, "isNotSameCurrentPassword in: $isSame")
//            }
//        Log.d(TAG, "isNotSameCurrentPassword: $isSame")
//        return isSame
//    }
}