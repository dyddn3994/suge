package com.ssafy.suge_store.src.home

import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Bundle
import android.renderscript.Sampler.Value
import android.util.Log
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.navigation.Navigation
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.FragmentHomeBinding
import com.ssafy.suge_store.databinding.ItemStoreTitleBinding
import com.ssafy.suge_store.src.viewmodels.UserViewModel
import com.ssafy.suge_store.src.models.Store
import com.ssafy.suge_store.src.viewmodels.StoreViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

private const val TAG = "HomeFragment_로그"
class HomeFragment: BaseFragment<FragmentHomeBinding>(FragmentHomeBinding::bind, R.layout.fragment_home) {

    private lateinit var homeAdapter: HomeAdapter

    private val userViewModel: UserViewModel by activityViewModels()
    private val storeViewModel: StoreViewModel by activityViewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Log.d(TAG, "initView: ${Navigation.findNavController(binding.root).backQueue}")
        showLoadingDialog(requireContext())

        initView()
        initAdapter()
        initStoreList()
    }

    private fun initView() {
        // bottom navigation 클릭 상태 초기화
        requireActivity().findViewById<BottomNavigationView>(R.id.bottom_nav).menu.getItem(1).isChecked = true

        binding.apply {
            // 사용자 이름 출력
            tvName.text = userViewModel.userInfo.name

            // 매장 추가 버튼 클릭
            ivAddStore.setOnClickListener {
                Navigation.findNavController(binding.root).navigate(R.id.action_home_to_store_create)
            }
        }
    }

    private fun initAdapter() {
        homeAdapter = HomeAdapter().apply { 
            setStoreClickListener(object: HomeAdapter.StoreClickListener {
                override fun storeItemClick(binding: ItemStoreTitleBinding, store: Store, position: Int) {
                    storeViewModel.selectedStore = store
                    Navigation.findNavController(binding.root).navigate(R.id.action_home_to_store_reward)
                }
            })
        }
        binding.rvStoreList.apply {
            adapter = homeAdapter
            layoutManager = LinearLayoutManager(requireContext(), LinearLayoutManager.VERTICAL, false)
        }
    }

    private fun initStoreList() {
        Firebase.database.reference
            .child("store")
            .orderByChild("ownerEmail")
            .equalTo(userViewModel.userInfo.email)
            .addListenerForSingleValueEvent(object: ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    // 가게 조회 성공
                    val storeList = arrayListOf<Store>()
                    for (child in snapshot.children) {
                        val store = child.getValue(Store::class.java) as Store
                        storeList.add(store)
                    }

                    storeViewModel.stores = storeList
                    homeAdapter.setStoreList(storeList)
                    dismissLoadingDialog()
                }

                override fun onCancelled(error: DatabaseError) {
                    // 가게 조회 실패
                    Log.d(TAG, "onCancelled: ${error.message}")
                    dismissLoadingDialog()
                }
            })
    }
}