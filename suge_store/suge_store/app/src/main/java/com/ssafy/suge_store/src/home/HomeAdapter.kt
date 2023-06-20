package com.ssafy.suge_store.src.home

import android.annotation.SuppressLint
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.ssafy.suge_store.databinding.ItemStoreTitleBinding
import com.ssafy.suge_store.src.models.Store
import com.ssafy.suge_store.src.point.PointAdapter

private const val TAG = "HomeAdapter_로그"
class HomeAdapter(private var stores: ArrayList<Store> = arrayListOf()): RecyclerView.Adapter<HomeAdapter.HomeViewHolder>() {

    inner class HomeViewHolder(val binding: ItemStoreTitleBinding): RecyclerView.ViewHolder(binding.root) {

        fun bindInfo(store: Store) {
            binding.apply {
                tvStoreName.text = store.storeName

                clStoreTitle.setOnClickListener {
                    storeClickListener.storeItemClick(binding, store, layoutPosition)
                }
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): HomeViewHolder {
        val binding = ItemStoreTitleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return HomeViewHolder(binding)
    }

    override fun onBindViewHolder(holder: HomeViewHolder, position: Int) {
        holder.bindInfo(stores[position])
    }

    override fun getItemCount(): Int {
        return stores.size
    }

    @SuppressLint("NotifyDataSetChanged")
    fun setStoreList(storeList: ArrayList<Store>) {
        stores = storeList
        notifyDataSetChanged()
    }

    // 이벤트 처리 listener
    interface StoreClickListener {
        fun storeItemClick(binding: ItemStoreTitleBinding, store: Store, position: Int)
    }
    private lateinit var storeClickListener: StoreClickListener
    fun setStoreClickListener(storeClickListener: StoreClickListener) {
        this.storeClickListener = storeClickListener
    }
}