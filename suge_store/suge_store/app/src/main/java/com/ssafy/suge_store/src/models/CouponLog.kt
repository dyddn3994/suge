package com.ssafy.suge_store.src.models

data class CouponLog(
    var storeName: String,
    var count: Int,
    var date: Long,
    var flag: Int // 1: 적립 / 2: 사용
) {
    constructor(): this("", 0, 0, 0)
}
