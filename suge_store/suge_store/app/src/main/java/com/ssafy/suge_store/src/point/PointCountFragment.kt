package com.ssafy.suge_store.src.point

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.navigation.Navigation
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.ValueEventListener
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.FragmentPointCountBinding
import com.ssafy.suge_store.src.models.Coupon
import com.ssafy.suge_store.src.models.CouponLog
import com.ssafy.suge_store.src.models.User
import com.ssafy.suge_store.src.viewmodels.StoreViewModel
import com.ssafy.suge_store.src.viewmodels.UserViewModel

private const val TAG = "PointCountFragment_로그"
class PointCountFragment: BaseFragment<FragmentPointCountBinding>(FragmentPointCountBinding::bind, R.layout.fragment_point_count) {

    private var pointCount = 1

    // ViewModel
    private val userViewModel: UserViewModel by activityViewModels()
    private val storeViewModel: StoreViewModel by activityViewModels()

    // firebase db
    private val database: DatabaseReference by lazy { Firebase.database.reference }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
    }

    @SuppressLint("SetTextI18n")
    private fun initView() {
        binding.apply {
            tvPlus.setOnClickListener {
                 tvCount.text = (++pointCount).toString()
            }
            tvMinus.setOnClickListener {
                if (tvCount.text.toString() != "1") {
                    tvCount.text = (--pointCount).toString()
                }
            }

            btnCountCheck.setOnClickListener {
                showLoadingDialog(requireContext())
                accumulate(userViewModel.selectedUserEmail, storeViewModel.selectedStore.storeName, pointCount)
            }
        }
    }

    // db 포인트 적립
    private fun accumulate(email: String, storeName: String, count: Int) {
        database.child("user")
            .orderByChild("email")
            .equalTo(email)
            .addListenerForSingleValueEvent(object: ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    for (user in snapshot.children) {
                        val userInfo = user.getValue(User::class.java) as User
                        var earnedCount = 0
                        userInfo.coupons.forEach {
                            if (it.value.storeName == storeName) {
                                earnedCount = it.value.count
                                return@forEach
                            }
                        }

                        if (earnedCount == 0) {
                            user.ref
                                .child("coupons")
                                .push()
                                .setValue(Coupon(storeName, count))
                            makeCouponLog(storeName, count, System.currentTimeMillis(), 1, user.ref)
                            dismissLoadingDialog()
                            showSnackbar("쿠폰 적립이 완료되었습니다.")
                            Navigation.findNavController(binding.root).navigate(R.id.fragment_point)
                        }
                        else {
                            user.ref
                                .child("coupons")
                                .orderByChild("storeName")
                                .equalTo(storeName)
                                .addListenerForSingleValueEvent(object: ValueEventListener {
                                    override fun onDataChange(snapshot: DataSnapshot) {
                                        // 적립 기록 존재
                                        Log.d(TAG, "onDataChange: ")
                                        for (coupon in snapshot.children) {
                                            Log.d(TAG, "onDataChange: $earnedCount")
                                            coupon.ref
                                                .setValue(Coupon(storeName, count + earnedCount))
                                        }

                                        makeCouponLog(storeName, count, System.currentTimeMillis(), 1, user.ref)

                                        dismissLoadingDialog()
                                        showSnackbar("쿠폰 적립이 완료되었습니다.")
                                        Navigation.findNavController(binding.root).navigate(R.id.fragment_point)
                                    }
                                    override fun onCancelled(error: DatabaseError) {
                                        // 적립 실패
                                        Log.d(TAG, "onCancelled: ${error.message}")
                                        dismissLoadingDialog()
                                        showSnackbar("포인트 적립에 실패하였습니다.")
                                    }
                                })
                        }
                    }
                }
                override fun onCancelled(error: DatabaseError) {
                    // 이름 조회 실패
                    Log.d(TAG, "onCancelled finding name: ${error.message}")
                    dismissLoadingDialog()
                    showSnackbar("포인트 적립에 실패하였습니다.")
                }
            })
    }
    
    // 로그 남기기
    fun makeCouponLog(storeName: String, count: Int, date: Long, flag: Int, userRef: DatabaseReference) {
        userRef.child("couponLog")
            .push()
            .setValue(CouponLog(storeName, count, date, flag))
    }
}