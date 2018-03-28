//
//  IntentHandler.swift
//  hikingbot
//
//  Created by KL on 28/3/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation
import ApiAI
import SKYKit


class IntentHandler{
    
    static func getWeatherFromServer(date: String, completion: (_ success: Bool, _ text: String)->()) {
        
        let query = SKYQuery(recordType: "HikeBotDatabase", predicate: nil)
        
        SKYContainer.default().publicCloudDatabase.perform(query) { (results, error) in
            if error != nil {
                print ("error querying todos: \(error)")
                return
            }
            
            print ("Received \(results?.count).")
            for record in results as! [SKYRecord] {
                print ("x: \(record["name"])")
            }
        }
        
        completion(true, "\(date) weather very good lol")
    }
    
    static func processReponse(response: AIResponse, completion: (_ hasNewText: Bool, _ text: String)->()) {
        
        if (response.result.metadata.intentName == "weather intent" && !response.result.actionIncomplete.boolValue){
            let date = response.result.parameters["date"] as! AIResponseParameter
            getWeatherFromServer(date: date.stringValue, completion: { (sucess, text) in
                if sucess{
                    completion(sucess, text)
                }else{
                    completion(sucess, "")
                }
            })
        }else{
            completion(false, "")
        }
    }
}
