package com.ssafy.suge_store.src.models

data class Reward(
    var reward: String,
    var count: Int
): Comparable<Reward> {
    constructor(): this("", 0)

    override fun toString(): String {
        return "${count}개 리워드 - $reward"
    }

    override fun compareTo(other: Reward): Int {
        return this.count - other.count
    }
}
