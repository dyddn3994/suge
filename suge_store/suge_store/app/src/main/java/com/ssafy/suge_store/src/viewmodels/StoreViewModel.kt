package com.ssafy.suge_store.src.viewmodels

import androidx.lifecycle.ViewModel
import com.ssafy.suge_store.src.models.Store

class StoreViewModel: ViewModel() {
    lateinit var stores: ArrayList<Store>
    lateinit var selectedStore: Store
}