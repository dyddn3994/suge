package com.ssafy.suge_store.src.models

data class Store(
    var storeName: String,
    var ownerEmail: String,
    var rewards: ArrayList<Reward>
) {
    constructor(): this("", "", arrayListOf())
}
