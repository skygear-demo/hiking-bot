//
//  NLP.swift
//  KLPlatform
//
//  Created by KL on 22/3/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

struct textWithPartOfSpeech{
    var text: String
    var partOfSpeech: String
}

struct textEntity{
    var text: String
    var entity: String
}

class NLP{
    
    static let keyword = ["weather", "suggestion", "beginner", "Lamma Island"]
    static let tagger = NSLinguisticTagger(tagSchemes:[.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    static let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    
    static func determineLanguage(for text: String) -> String{
        tagger.string = text
        return tagger.dominantLanguage!
    }
    
    static func tokenizeText(for text: String) -> [String]{
        var token: [String] = []
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { tag, tokenRange, stop in
            let word = (text as NSString).substring(with: tokenRange)
            token.append(word)
        }
        return token
    }
    
    static func lemmatization(for text: String) {
        tagger.string = text
        let range = NSRange(location:0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange, stop in
            if let lemma = tag?.rawValue {
                print(lemma)
            }
        }
    }
    
    static func searchKeyWord(for text: String) -> [String]{
        // return the first found key, if key is not found, return nil
        var result: [String] = []
        tagger.string = text
        let range = NSRange(location:0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange, stop in
            if let lemma = tag?.rawValue{
                if keyword.contains(lemma){
                    result.append(lemma)
                }else{
                    print(lemma)
                }
            }
        }
        return result
    }
    
    static func partsOfSpeech(for text: String) -> [textWithPartOfSpeech]{
        var texts: [textWithPartOfSpeech] = []
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, _ in
            if let tag = tag {
                let word = (text as NSString).substring(with: tokenRange)
                texts.append(textWithPartOfSpeech(text: word, partOfSpeech: tag.rawValue))
            }
        }
        return texts
    }
    
    static func namedEntityRecognition(for text: String) -> [textEntity]{
        var texts: [textEntity] = []
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                let name = (text as NSString).substring(with: tokenRange)
                texts.append(textEntity(text: name, entity: tag.rawValue))
            }
        }
        return texts
    }
    
    static func getThreeRandomNonRepeatedKeyword() -> [String]{
        var result: [String] = []
        var tmp = keyword
        var ran = 0
        for _ in 1...3{
            ran = Int(arc4random_uniform(UInt32(tmp.count)))
            result.append(tmp[ran])
            tmp.remove(at: ran)
        }
        
        return result
    }
}
