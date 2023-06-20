package com.ssafy.suge_store.src.viewmodels

import androidx.lifecycle.ViewModel
import com.ssafy.suge_store.src.models.User

class UserViewModel: ViewModel() {
    lateinit var userInfo: User
    lateinit var selectedUserEmail: String

    // test
//    var userInfo = User("asdf@mail.com", "여민스")
//    var selectedUserEmail = "test3@test.com"
}