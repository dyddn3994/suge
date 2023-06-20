package com.ssafy.suge_store.src.main

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.KeyEvent
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.navigation.Navigation
import androidx.navigation.fragment.findNavController
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.play.core.integrity.p
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.ValueEventListener
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.ApplicationClass.Companion.firebaseAuth
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.FragmentLoginBinding
import com.ssafy.suge_store.src.models.User
import com.ssafy.suge_store.src.viewmodels.UserViewModel

private const val TAG = "LoginFragment_로그"
class LoginFragment: BaseFragment<FragmentLoginBinding>(FragmentLoginBinding::bind, R.layout.fragment_login) {

    private val userViewModel: UserViewModel by activityViewModels()

    // firebase db
    private val userRef: DatabaseReference by lazy { Firebase.database.getReference("user") }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        if (firebaseAuth.currentUser == null || firebaseAuth.currentUser!!.email == null) {
            initView()
            initEditText()
        }
        else {
            showLoadingDialog(requireContext())
            setUserName(firebaseAuth.currentUser!!.email!!)
        }
    }

    private fun initView() {
        Log.d(TAG, "initView: ${Navigation.findNavController(binding.root).backQueue}")
        binding.apply {
            // 로그인 버튼 클릭
            btnLogin.setOnClickListener {
                // 입력값 공백
                if (etId.text.isNullOrBlank()) tilId.error = "이메일을 입력하세요"
                else tilId.isErrorEnabled = false
                if (etPwd.text.isNullOrBlank()) tilPwd.error = "비밀번호를 입력하세요"
                else tilPwd.isErrorEnabled = false

                // 전체 입력 완료
                if (tilId.error.isNullOrBlank() && tilPwd.error.isNullOrBlank()) {
                    showLoadingDialog(requireContext())
                    signIn(etId.text.toString(), etPwd.text.toString())
                }
            }

            // 회원가입 클릭
            tvSignUp.setOnClickListener {
                Navigation.findNavController(binding.root).navigate(R.id.action_login_to_sign_up)
            }

            // 구글 로그인 버튼
            btnGoogleLogin.setOnClickListener {
                googleSignIn()
            }

        }
    }

    private fun initEditText() {
        binding.apply {
            // Id, Password 엔터 클릭할 때 동작
            etId.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER){
                    etPwd.requestFocus()
                }
                false
            }
            etPwd.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    btnLogin.performClick()
                }
                false
            }

            // error가 활성화 된 상태에서 입력하면 비활성화
            etId.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilId.isErrorEnabled) tilId.isErrorEnabled = false
                }
            })
            etPwd.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilPwd.isErrorEnabled) tilPwd.isErrorEnabled = false
                }
            })
        }
    }

    // 로그인
    private fun signIn(email: String, pwd: String) {
        firebaseAuth.signInWithEmailAndPassword(email, pwd)
            .addOnCompleteListener(requireActivity()) { task ->
                if (task.isSuccessful) {
                    setUserName(email)
                }
                else {
                    Log.d(TAG, "signIn fail: ${task.exception}")
                    dismissLoadingDialog()
                    showSnackbar("로그인에 실패하였습니다.")
                }
            }
    }

    // 구글 로그인
    private fun googleSignIn() {
        val options = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(getString(R.string.default_web_client_id))
            .requestEmail().build()
        val client = GoogleSignIn.getClient(requireActivity(), options)
        startActivityForResult(client.signInIntent, 1)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == 1) {
            // 구글 로그인
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            var account: GoogleSignInAccount? = null
            try {
                account = task.getResult(ApiException::class.java)
                firebaseAuthWithGoogle(account!!.idToken)

            } catch (e: ApiException) {
                Log.d(TAG, "google signIn fail: ${task.exception}")
                dismissLoadingDialog()
                showSnackbar("로그인에 실패하였습니다.")
            }
        }
    }

    // firebase 구글 로그인
    private fun firebaseAuthWithGoogle(idToken: String?) {
        val credential = GoogleAuthProvider.getCredential(idToken, null)
        firebaseAuth.signInWithCredential(credential)
            .addOnCompleteListener(requireActivity()) { task ->
                if (task.isSuccessful) {
                    setUserName(firebaseAuth.currentUser?.email!!)
                }
            }
    }

    // 이름 조회하여 데이터 가져오기
    private fun setUserName(email: String) {
        Firebase.database.reference
            .child("user") // 객체 명
            .orderByChild("email") // where email = ?
            .equalTo(email)
            .addListenerForSingleValueEvent(object: ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    // 이름 조회 성공
                    var userInfo: User? = null
                    for (user in snapshot.children) {
                        userInfo = user.getValue(User::class.java) as User
                    }

                    if (userInfo == null) {
                        userInfo = User(email, "회원")
                        userRef.push().setValue(userInfo)
                    }
                    userViewModel.userInfo = userInfo

                    dismissLoadingDialog()
                    Navigation.findNavController(binding.root).apply {
                        navigate(R.id.action_login_to_home)
//                        popBackStack()
                    }
                }
                override fun onCancelled(error: DatabaseError) {
                    // 이름 조회 실패
                    Log.d(TAG, "onCancelled: ${error.message}")
                    showSnackbar("로그인에 실패하였습니다.")
                    dismissLoadingDialog()
                }
            })
    }
}