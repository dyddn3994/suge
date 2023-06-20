package com.ssafy.suge_store.src.point

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
import com.journeyapps.barcodescanner.ScanContract
import com.journeyapps.barcodescanner.ScanIntentResult
import com.journeyapps.barcodescanner.ScanOptions
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.FragmentPointUseBinding
import com.ssafy.suge_store.src.models.Coupon
import com.ssafy.suge_store.src.models.CouponLog
import com.ssafy.suge_store.src.models.User
import com.ssafy.suge_store.src.viewmodels.StoreViewModel
import com.ssafy.suge_store.src.viewmodels.UserViewModel

private const val TAG = "PointUseFragment_로그"
class PointUseFragment: BaseFragment<FragmentPointUseBinding>(FragmentPointUseBinding::bind, R.layout.fragment_point_use) {

    // ViewModel
    private val userViewModel: UserViewModel by activityViewModels()
    private val storeViewModel: StoreViewModel by activityViewModels()

    // firebase db
    private val database: DatabaseReference by lazy { Firebase.database.reference }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
    }

    private fun initView() {
        binding.apply {
            tvStoreName.text = storeViewModel.selectedStore.storeName

            clQrScan.setOnClickListener {
                val options = ScanOptions()
                    .setPrompt("적립할 QR 코드를 스캔해 주세요")
                    .setOrientationLocked(false)
                earnMilesBarcodeLauncher.launch(options)
            }

            clPointUse.setOnClickListener {
                val options = ScanOptions()
                    .setPrompt("사용할 쿠폰의 QR 코드를 스캔해 주세요")
                    .setOrientationLocked(false)
                useMilesBarcodeLauncher.launch(options)
            }
        }
    }

    // 마일리지 적립
    private val earnMilesBarcodeLauncher = registerForActivityResult(ScanContract()) { result: ScanIntentResult ->
        if (result.contents == null) {
            showSnackbar("QR코드 스캔 실패")
        } else {
            userViewModel.selectedUserEmail = result.contents
            Navigation.findNavController(binding.root).navigate(R.id.action_point_use_to_point_count)
        }
    }

    // 마일리지 적립
    private val useMilesBarcodeLauncher = registerForActivityResult(ScanContract()) { result: ScanIntentResult ->
        if (result.contents == null) {
            showSnackbar("QR코드 스캔 실패")
        } else {
            Log.d(TAG, "scanned data: ${result.contents}")
            showLoadingDialog(requireContext())
            val (email, count) = result.contents.split(" ")
            usePoint(email, storeViewModel.selectedStore.storeName, count.toInt())
        }
    }

    // db 포인트 사용
    private fun usePoint(email: String, storeName: String, count: Int) {
        database.child("user")
            .orderByChild("email")
            .equalTo(email)
            .addListenerForSingleValueEvent(object: ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    for (user in snapshot.children) {
                        // 해당 사용자가 해당 가게로 적립한 적 있는지 조회, 있으면 +, 없으면 추가
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
                            makeCouponLog(storeName, count, System.currentTimeMillis(), 2, user.ref)
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
                                        for (coupon in snapshot.children) {
                                            Log.d(TAG, "onDataChange: $earnedCount")
                                            coupon.ref
                                                .setValue(Coupon(storeName, earnedCount - count))
                                        }

                                        makeCouponLog(storeName, count, System.currentTimeMillis(), 2, user.ref)

                                        dismissLoadingDialog()
                                        showSnackbar("쿠폰 사용이 완료되었습니다.")
                                        Navigation.findNavController(binding.root).navigate(R.id.fragment_point)
                                    }
                                    override fun onCancelled(error: DatabaseError) {
                                        // 사용 실패
                                        Log.d(TAG, "onCancelled: ${error.message}")
                                        dismissLoadingDialog()
                                        showSnackbar("포인트 사용에 실패하였습니다.")
                                    }
                                })
                        }
                    }
                }
                override fun onCancelled(error: DatabaseError) {
                    // 이름 조회 실패
                    Log.d(TAG, "onCancelled: ${error.message}")
                    dismissLoadingDialog()
                    showSnackbar("포인트 사용에 실패하였습니다.")
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