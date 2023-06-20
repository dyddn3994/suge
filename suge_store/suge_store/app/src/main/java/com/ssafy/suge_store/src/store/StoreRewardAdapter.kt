package com.ssafy.suge_store.src.store

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.ssafy.suge_store.databinding.ItemRewardNameBinding
import com.ssafy.suge_store.src.models.Reward

class StoreRewardAdapter(): RecyclerView.Adapter<StoreRewardAdapter.StoreRewardViewHolder>() {

    var rewardList: ArrayList<Reward> = arrayListOf()

    inner class StoreRewardViewHolder(val binding: ItemRewardNameBinding): RecyclerView.ViewHolder(binding.root) {

        fun bindInfo(reward: Reward) {
            binding.apply {
                tvReward.text = reward.toString()

                clRewardCreate.setOnClickListener {
                    rewardClickListener.rewardItemClick(binding, reward, layoutPosition)
                }
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StoreRewardViewHolder {
        val binding = ItemRewardNameBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return StoreRewardViewHolder(binding)
    }

    override fun onBindViewHolder(holder: StoreRewardViewHolder, position: Int) {
        holder.bindInfo(rewardList[position])
    }

    override fun getItemCount(): Int {
        return rewardList.size
    }

    @SuppressLint("NotifyDataSetChanged")
    fun setRewards(rewardList: ArrayList<Reward>) {
        rewardList.sort()
        this.rewardList = rewardList
        notifyDataSetChanged()
    }

    // 리워드 등록
    @SuppressLint("NotifyDataSetChanged")
    fun insertReward(reward: Reward) {
        rewardList.add(reward)
        rewardList.sort()
        notifyDataSetChanged()
    }

    // 리워드 수정
    @SuppressLint("NotifyDataSetChanged")
    fun updateReward(position: Int, reward: Reward) {
        rewardList[position] = reward
        rewardList.sort()
        notifyDataSetChanged()
    }

    // 리워드 삭제
    fun deleteReward(position: Int) {
        rewardList.removeAt(position)
        notifyItemRemoved(position)
    }

    // 이벤트 처리 listener
    interface RewardClickListener {
        fun rewardItemClick(binding: ItemRewardNameBinding, reward: Reward, position: Int)
    }
    private lateinit var rewardClickListener: RewardClickListener
    fun setRewardClickListener(rewardClickListener: RewardClickListener) {
        this.rewardClickListener = rewardClickListener
    }
}