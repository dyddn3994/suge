package com.ssafy.suge_store.src.point

import android.os.Bundle
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.navigation.Navigation
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.ssafy.suge_store.R
import com.ssafy.suge_store.config.BaseFragment
import com.ssafy.suge_store.databinding.FragmentPointBinding
import com.ssafy.suge_store.databinding.ItemSelectStoreBinding
import com.ssafy.suge_store.src.models.Store
import com.ssafy.suge_store.src.viewmodels.StoreViewModel

class PointFragment: BaseFragment<FragmentPointBinding>(FragmentPointBinding::bind, R.layout.fragment_point) {
    private lateinit var pointAdapter: PointAdapter

    private val storeViewModel: StoreViewModel by activityViewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initView()
        initAdapter()
    }

    private fun initView() {
        // bottom navigation 클릭 상태 초기화
        requireActivity().findViewById<BottomNavigationView>(R.id.bottom_nav).menu.getItem(0).isChecked = true
    }

    private fun initAdapter() {
        pointAdapter = PointAdapter().apply {
            setStoreClickListener(object: PointAdapter.StoreClickListener {
                override fun storeItemClick(binding: ItemSelectStoreBinding, store: Store, position: Int) {
                    storeViewModel.selectedStore = store
                    Navigation.findNavController(binding.root).navigate(R.id.action_point_to_point_use)
                }
            })
        }

        binding.rvStoreSelect.apply {
            adapter = pointAdapter
            layoutManager = LinearLayoutManager(requireContext(), LinearLayoutManager.VERTICAL, false)
        }

        pointAdapter.setStoreList(storeViewModel.stores)
    }
}