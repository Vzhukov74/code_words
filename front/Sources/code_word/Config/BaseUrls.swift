//
//  BaseUrls.swift
//  project-name
//
//  Created by Vladislav Zhukov on 04.01.2025.
//

import Foundation

struct BaseUrls {
    var baseUrl: URL {
//        #if LOCAL
//            #if !SKIP
//            URL(string: "http://127.0.0.1:8080/")!
//            #else
//            URL(string: "http://192.168.31.236:8080/")!
//            #endif
//        #else
            URL(string: "https://mdlab.tech/")!
//        #endif
    }
}
