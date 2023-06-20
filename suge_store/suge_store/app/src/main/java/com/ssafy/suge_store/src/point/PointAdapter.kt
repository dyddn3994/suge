package com.ssafy.suge_store.src.point

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.ssafy.suge_store.databinding.ItemSelectStoreBinding
import com.ssafy.suge_store.databinding.ItemStoreTitleBinding
import com.ssafy.suge_store.src.models.Store

class PointAdapter(private var stores: ArrayList<Store> = arrayListOf()): RecyclerView.Adapter<PointAdapter.PointViewHolder>() {

    inner class PointViewHolder(val binding: ItemSelectStoreBinding): RecyclerView.ViewHolder(binding.root) {

        fun bindInfo(store: Store) {
            binding.apply {
                tvStoreName.text = store.storeName

                clStoreList.setOnClickListener {
                    storeClickListener.storeItemClick(binding, store, layoutPosition)
                }
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PointViewHolder {
        val binding = ItemSelectStoreBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return PointViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PointViewHolder, position: Int) {
        holder.bindInfo(stores[position])
    }

    override fun getItemCount(): Int {
        return stores.size
    }

    fun setStoreList(storeList: ArrayList<Store>) {
        stores = storeList
    }

    // 이벤트 처리 listener
    interface StoreClickListener {
        fun storeItemClick(binding: ItemSelectStoreBinding, store: Store, position: Int)
    }
    private lateinit var storeClickListener: StoreClickListener
    fun setStoreClickListener(storeClickListener: StoreClickListener) {
        this.storeClickListener = storeClickListener
    }
}