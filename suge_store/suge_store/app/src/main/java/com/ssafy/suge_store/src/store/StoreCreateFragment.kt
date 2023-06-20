package com.ssafy.suge_store.src.store

import android.app.Dialog
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.KeyEvent
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.DialogRewardCreateBinding
import com.ssafy.suge_store.databinding.FragmentStoreCreateBinding
import com.ssafy.suge_store.databinding.ItemRewardNameBinding
import com.ssafy.suge_store.src.models.Reward
import com.ssafy.suge_store.src.models.Store
import com.ssafy.suge_store.src.viewmodels.UserViewModel

private const val TAG = "StoreCreateFragment_로그"
class StoreCreateFragment: BaseFragment<FragmentStoreCreateBinding>(FragmentStoreCreateBinding::bind, R.layout.fragment_store_create) {
    // 생성하고자 하는 리워드 리스트
    private val rewardList: ArrayList<Reward> by lazy {
        arrayListOf()
    }

    // dialog 수정/삭제 시 사용되는 선택된 reward index
    private var selectedRewardIdx = 0

    // firebase db
    private val storeRef: DatabaseReference by lazy { Firebase.database.getReference("store") }

    // ViewModel
    private val userViewModel: UserViewModel by activityViewModels()

    // 리워드 생성 dialog binding
    private val dialog: Dialog by lazy {
        BottomSheetDialog(requireContext()).apply {
            setContentView(R.layout.dialog_reward_create)
        }
    }
    private val dialogBinding: DialogRewardCreateBinding by lazy {
        DialogRewardCreateBinding.bind(dialog.findViewById(R.id.cl_dialog_layout))
    }

    private lateinit var storeRewardAdapter: StoreRewardAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
        initEditText()
        initDialog()
        initAdapter()
    }

    private fun initView() {
        binding.apply {
            // dialog 열기
            clAddReward.setOnClickListener {
                openCreateDialog()
            }

            // 가게 생성 버튼 클릭
            btnStoreCreate.setOnClickListener {
                if (etStoreName.text.isNullOrBlank()) tilStoreName.error = "가게 이름을 입력해주세요"
                else tilStoreName.isErrorEnabled = false

                if (tilStoreName.error.isNullOrBlank()) {
                    createStore(etStoreName.text.toString(), userViewModel.userInfo.email, storeRewardAdapter.rewardList)
                }
            }
        }
    }

    private fun initEditText() {
        binding.apply {
            etStoreName.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    etStoreName.clearFocus()
                }
                false
            }

            etStoreName.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilStoreName.isErrorEnabled) tilStoreName.isErrorEnabled = false
                }
            })
        }

        dialogBinding.apply {
            etRewardName.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    etRewardCount.requestFocus()
                }
                false
            }
            etRewardCount.setOnKeyListener { _, keyCode, keyEvent ->
                if (keyEvent.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_ENTER) {
                    etRewardCount.clearFocus()
                }
                false
            }

            etRewardName.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilRewardName.isErrorEnabled) tilRewardName.isErrorEnabled = false
                }
            })
            etRewardCount.addTextChangedListener(object: TextWatcher {
                override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                override fun afterTextChanged(p0: Editable?) {
                    if (tilRewardCount.isErrorEnabled) tilRewardCount.isErrorEnabled = false
                }
            })
        }
    }

    // 리워드 생성 dialog
    private fun initDialog() {
        dialogBinding.apply {
            // 리워드 등록 버튼 클릭
            btnRewardCreate.setOnClickListener {
                if (etRewardName.text.isNullOrBlank()) tilRewardName.error = "리워드 명을 입력해 주세요"
                else tilRewardName.isErrorEnabled = false
                if (etRewardCount.text.isNullOrBlank() || etRewardCount.text.toString() == "0") tilRewardCount.error = "리워드 개수를 입력해 주세요"
                else tilRewardCount.isErrorEnabled = false

                if (tilRewardName.error.isNullOrBlank()
                    && tilRewardCount.error.isNullOrBlank()) {
                    // list에 값 추가
                    val newReward = Reward(etRewardName.text.toString(), etRewardCount.text.toString().toInt())
                    storeRewardAdapter.insertReward(newReward)

                    closeDialog()
                }
            }

            // 리워드 수정 버튼 클릭
            btnRewardUpdate.setOnClickListener {
                if (etRewardName.text.isNullOrBlank()) tilRewardName.error = "리워드 명을 입력해 주세요"
                else tilRewardName.isErrorEnabled = false
                if (etRewardCount.text.isNullOrBlank() || etRewardCount.text.toString() == "0") tilRewardCount.error = "리워드 개수를 입력해 주세요"
                else tilRewardCount.isErrorEnabled = false

                if (tilRewardName.error.isNullOrBlank()
                    && tilRewardCount.error.isNullOrBlank()) {
                    val newReward = Reward(etRewardName.text.toString(), etRewardCount.text.toString().toInt())
                    storeRewardAdapter.updateReward(selectedRewardIdx, newReward)

                    closeDialog()
                }
            }

            // 리워드 삭제 버튼 클릭
            btnRewardDelete.setOnClickListener {
                storeRewardAdapter.deleteReward(selectedRewardIdx)
                closeDialog()
            }

            // 리워드 등록 취소 버튼 클릭
            btnCancel.setOnClickListener {
                closeDialog()
            }
        }
    }

    private fun initAdapter() {
        storeRewardAdapter = StoreRewardAdapter().apply {
            setRewardClickListener(object: StoreRewardAdapter.RewardClickListener {
                override fun rewardItemClick(binding: ItemRewardNameBinding, reward: Reward, position: Int) {
                    selectedRewardIdx = position
                    openUpdateDialog(reward)
                }
            })
        }

        binding.rvReward.apply {
            adapter = storeRewardAdapter
            layoutManager = LinearLayoutManager(requireContext(), LinearLayoutManager.VERTICAL, false)
        }
    }

    private fun createStore(storeName: String, ownerEmail: String, rewards: ArrayList<Reward>) {
        storeRef.push().setValue(Store(storeName, ownerEmail, rewards))
        showSnackbar("매장이 등록되었습니다.")
        findNavController().popBackStack()
    }

    // 리워드 등록
    private fun openCreateDialog() {
        dialogBinding.apply {
            btnRewardCreate.visibility = View.VISIBLE
            btnRewardUpdate.visibility = View.GONE
            btnRewardDelete.visibility = View.GONE
            
            tvRewardCreate.text = "리워드 등록"
        }
        dialog.show()
    }

    // 리워드 수정
    private fun openUpdateDialog(reward: Reward) {
        dialogBinding.apply {
            btnRewardCreate.visibility = View.GONE
            btnRewardUpdate.visibility = View.VISIBLE
            btnRewardDelete.visibility = View.VISIBLE

            tvRewardCreate.text = "리워드 수정"
            
            etRewardName.setText(reward.reward)
            etRewardCount.setText(reward.count.toString())
        }
        dialog.show()
    }
    
    // dialog 종료
    private fun closeDialog() {
        dialogBinding.apply {
            etRewardName.setText("")
            etRewardCount.setText("")
            dialog.dismiss()
        }
    }
}