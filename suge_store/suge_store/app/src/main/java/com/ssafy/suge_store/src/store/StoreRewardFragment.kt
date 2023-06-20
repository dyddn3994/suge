package com.ssafy.suge_store.src.store

import android.app.Dialog
import android.os.Bundle
import android.renderscript.Sampler.Value
import android.util.Log
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.navigation.Navigation
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.ValueEventListener
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.DialogDefaultBinding
import com.ssafy.suge_store.databinding.DialogRewardCreateBinding
import com.ssafy.suge_store.databinding.FragmentStoreRewardBinding
import com.ssafy.suge_store.databinding.ItemRewardNameBinding
import com.ssafy.suge_store.src.models.Reward
import com.ssafy.suge_store.src.viewmodels.StoreViewModel

private const val TAG = "StoreRewardFragment_로그"
class StoreRewardFragment: BaseFragment<FragmentStoreRewardBinding>(FragmentStoreRewardBinding::bind, R.layout.fragment_store_reward) {

    // db 데이터 처리를 완료하였는지 여부
    // listener형태로 데이터 결과를 받아 반복해서 데이터를 처리하는 문제를 해결하기 위함. 차후 변경 필요
    private var dataInserted = false

    // dialog 수정/삭제 시 사용되는 선택된 reward index
    private var selectedRewardIdx = 0

    // ViewModel
    private val storeViewModel by activityViewModels<StoreViewModel>()

    // 리워드 생성 dialog
    private val rewardDialog: Dialog by lazy {
        BottomSheetDialog(requireContext()).apply {
            setContentView(R.layout.dialog_reward_create)
        }
    }
    private val rewardDialogBinding: DialogRewardCreateBinding by lazy {
        DialogRewardCreateBinding.bind(rewardDialog.findViewById(R.id.cl_dialog_layout))
    }

    // 매장 삭제 dialog
    private val storeRemoveDialog: Dialog by lazy {
        BottomSheetDialog(requireContext()).apply {
            setContentView(R.layout.dialog_default)
        }
    }
    private val storeRemoveDialogBinding: DialogDefaultBinding by lazy {
        DialogDefaultBinding.bind(storeRemoveDialog.findViewById(R.id.cl_dialog_default))
    }

    // firebase db
    private val database: DatabaseReference by lazy { Firebase.database.reference }

    // adapter
    private lateinit var storeRewardAdapter: StoreRewardAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
        initDialog()
        initAdapter()
    }

    private fun initView() {
        binding.apply {
            // 리워드 추가 버튼
            clAddReward.setOnClickListener {
                openRewardCreateDialog()
            }

            // 수정 완료 버튼
            btnEditReward.setOnClickListener {
                updateDbReward(storeViewModel.selectedStore.storeName)
            }

            // 매장 삭제 버튼
            btnRemoveStore.setOnClickListener {
                storeRemoveDialog.show()
            }
        }
    }

    private fun initDialog() {
        rewardDialogBinding.apply {
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

            // 취소 버튼 클릭
            btnCancel.setOnClickListener {
                closeDialog()
            }
        }

        storeRemoveDialogBinding.apply {
            tvContent.text = "정말 매장을 삭제하시겠습니까?"

            // 취소
            btnCancel.setOnClickListener {
                storeRemoveDialog.dismiss()
            }

            // 확인
            btnOk.setOnClickListener {
                deleteStore(storeViewModel.selectedStore.storeName)
            }
        }
    }

    private fun initAdapter() {
        storeRewardAdapter = StoreRewardAdapter().apply {
            setRewardClickListener(object: StoreRewardAdapter.RewardClickListener {
                override fun rewardItemClick(binding: ItemRewardNameBinding, reward: Reward, position: Int) {
                    selectedRewardIdx = position
                    openRewardUpdateDialog(reward)
                }
            })
            setRewards(storeViewModel.selectedStore.rewards)
        }

        binding.rvStoreReward.apply {
            adapter = storeRewardAdapter
            layoutManager = LinearLayoutManager(requireContext(), LinearLayoutManager.VERTICAL, false)
        }
    }

    // 리워드 등록
    private fun openRewardCreateDialog() {
        rewardDialogBinding.apply {
            btnRewardCreate.visibility = View.VISIBLE
            btnRewardUpdate.visibility = View.GONE
            btnRewardDelete.visibility = View.GONE
        }
        rewardDialog.show()
    }

    // 리워드 수정
    private fun openRewardUpdateDialog(reward: Reward) {
        rewardDialogBinding.apply {
            btnRewardCreate.visibility = View.GONE
            btnRewardUpdate.visibility = View.VISIBLE
            btnRewardDelete.visibility = View.VISIBLE

            etRewardName.setText(reward.reward)
            etRewardCount.setText(reward.count.toString())
        }
        rewardDialog.show()
    }

    // 매장 삭제
    private fun deleteStore(storeName: String) {
        database.child("store")
            .orderByChild("storeName")
            .equalTo(storeName)
            .addListenerForSingleValueEvent(object: ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    for (storeSnapShot in snapshot.children) {
                        storeSnapShot.ref.removeValue()
                    }

                    storeRemoveDialog.dismiss()
                    showSnackbar("매장이 삭제되었습니다.")
                    Navigation.findNavController(binding.root).apply {
                        popBackStack()
                        navigate(R.id.fragment_home)
                    }
                }
                override fun onCancelled(error: DatabaseError) {
                    Log.d(TAG, "onCancelled: ${error.message}")
                    showSnackbar("매장 삭제에 실패하였습니다.")
                }
            })
    }

    private fun closeDialog() {
        rewardDialogBinding.apply {
            etRewardName.setText("")
            etRewardCount.setText("")
            rewardDialog.dismiss()
        }
    }

    private fun updateDbReward(storeName: String) {
        database.child("store")
            .orderByChild("storeName")
            .equalTo(storeName)
            .addListenerForSingleValueEvent(object: ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    if (dataInserted) return
                    dataInserted = true

                    for (userSnapshot in snapshot.children) {
                        userSnapshot.ref.setValue(storeViewModel.selectedStore)
                    }

                    showSnackbar("매장 정보가 수정되었습니다.")
                    findNavController().popBackStack()
                }
                override fun onCancelled(error: DatabaseError) {
                    Log.d(TAG, "onCancelled: ${error.message}")
                }
            })
    }
}