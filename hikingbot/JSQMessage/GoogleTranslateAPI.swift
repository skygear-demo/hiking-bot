//
//  GoogleTranslateAPI.swift
//  KLPlatform
//
//  Created by KL on 24/3/2018.
//  Copyright © 2018 KL. All rights reserved.
//


import Foundation
import Alamofire

typealias SearchComplete = (_ isSuccessful: Bool, _ response: String) -> Void

class GoogleTranslateAPI {
    
    static func requestTranslation(target: String, textToTranslate: String, completeion: @escaping SearchComplete) {
        
        // Add URL parameters
        let urlParams = [
            "target": target,
            "q": textToTranslate,
            "key": "AIzaSyBqI8Oi8NsHEDPqoF3tgQ1hX7cjjC8QIEk",
            ]
        
        // Fetch Request
        Alamofire.request("https://translation.googleapis.com/language/translate/v2", parameters: urlParams)
            .validate()
            .responseJSON { (response) in
                print(response)
                if let json = response.result.value as? [String: Any] {
                    if let data = json["data"] as? [String: Any] {
                        if let translations = data["translations"] as? [[String:Any]] {
                            let translatedTextDict = translations[0]
                            if let result = translatedTextDict["translatedText"] as? String {
                                completeion(true, result)
                            }
                        }
                    }
                }
                
        }
        
    }
    
}
