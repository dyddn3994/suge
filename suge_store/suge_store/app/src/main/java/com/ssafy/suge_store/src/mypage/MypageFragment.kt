package com.ssafy.suge_store.src.mypage

import android.app.AlertDialog
import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.navigation.Navigation
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.ApplicationClass
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.DialogDefaultBinding
import com.ssafy.suge_store.databinding.FragmentMypageBinding
import com.ssafy.suge_store.src.viewmodels.UserViewModel

class MypageFragment: BaseFragment<FragmentMypageBinding>(FragmentMypageBinding::bind, R.layout.fragment_mypage) {

    // ViewModel
    private val userViewModel: UserViewModel by activityViewModels()

    // 로그아웃 dialog
    private val signOutDialog: Dialog by lazy {
        BottomSheetDialog(requireContext()).apply {
            setContentView(R.layout.dialog_default)
        }
    }
    private val signOutDialogBinding: DialogDefaultBinding by lazy {
        DialogDefaultBinding.bind(signOutDialog.findViewById(R.id.cl_dialog_default))
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
        initDialog()
    }

    private fun initView() {
        // bottom navigation 클릭 상태 초기화
        requireActivity().findViewById<BottomNavigationView>(R.id.bottom_nav).menu.getItem(2).isChecked = true

        binding.apply {
            // 사용자 이름 설정
            tvUserName.text = userViewModel.userInfo.name

            // 회원정보 수정
            clEditUser.setOnClickListener {
                Navigation.findNavController(binding.root).navigate(R.id.action_mypage_to_user_edit)
            }

            // 로그아웃 버튼
            clLogout.setOnClickListener {
                signOutDialog.show()
            }
        }
    }

    private fun initDialog() {
        signOutDialogBinding.apply {
            tvContent.text = "정말 로그아웃 하시겠습니까?"

            // 취소 버튼
            btnCancel.setOnClickListener {
                signOutDialog.dismiss()
            }

            // 확인 버튼
            btnOk.setOnClickListener {
                signOutDialog.dismiss()
                ApplicationClass.firebaseAuth.signOut()
                Navigation.findNavController(binding.root).apply {
                    popBackStack()
                    navigate(R.id.fragment_login)
                }
            }
        }
    }
}