package com.ssafy.suge_store.src.models

data class Coupon(
    var storeName: String,
    var count: Int
) {
    constructor(): this("", 0)
}