package com.ssafy.suge_store.src.models

data class User(
    var email: String,
    var name: String,
    var flag: Int,
    var coupons: HashMap<String, Coupon>
) {
    constructor(): this("","", 2, hashMapOf())
    constructor(email: String, name: String): this(email, name, 2, hashMapOf())
}
