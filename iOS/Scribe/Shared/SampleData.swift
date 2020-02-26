//
//  SampleData.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-06.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import RealmSwift

public class SampleData {
    
    public init() {}
    
    // TODO re-write sample objects without using Realm
    public func generateSampleData() {
        var sampleTexts = [Text]()
        sampleTexts.append(generateSampleText(name: "The Bacchae", author: "Euripides"))
        sampleTexts.append(generateSampleText(name: "The Nicomachean Ethics", author: "Aristotle"))
        
        let passage1 = generateSamplePassage(content: "So, the son of Zeus is back in Thebes: I Dionysus, son of Semele--daught of Cadmus--who was struck from my mother in a lightning stroke. I am changed, of course, a god made man.")
        
        let passage2 = generateSamplePassage(content: "Ye gods! What is this? Tiresias the prophet decked out like a spotted goat! And my grandfather--it's preposterous--playing the Baccant with a fennel wand?")
        let passage3 = generateSamplePassage(content: "Every craft and every investigation, and likewise every action and decision, seems to aim at some good; hence the good has been well described as that at which everything aims.")
        let passage4 = generateSamplePassage(content: "Well, perhaps we shall find the best good if we first find the function of a human being. For just as the good, i.e., <doing> well, for a flautist, a sculptor, and every craftsman, and, in general, for whatever has a function and characteristic action, seems to depend on it's function, the same seems to be true for a human being, if a human being has some function.")
        
        //sampleTexts[0].Passages!.append(passage1)
        //sampleTexts[0].Passages!.append(passage2)
        //sampleTexts[1].Passages!.append(passage3)
        //sampleTexts[1].Passages!.append(passage4)
        
//        do {
//            let realm = try Realm()
//            
//            for text in sampleTexts {
//                try realm.write {
//                    realm.add(text)
//                }
//            }
//        } catch {
//            print("Failed to initialize Realm: \(error)")
//        }
        
        // If test data is generated do not generate again, save to user defaults
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "testDataLoaded")
    }
    
    public func generateSampleText(name: String, author: String) -> Text {
        let sampleText = Text()
        sampleText.Name = name
        sampleText.Author = author
        
        return sampleText
    }
    
    public func generateSamplePassage(content: String) -> Passage {
        let samplePassage = Passage()
        samplePassage.Content = content
        
        return samplePassage
    }
}
