//
//  Constant.swift
//  FoodTrack
//
//  Created by Michał Rytych on 02/2/21.
//

import UIKit

struct Constant {
    static let appName = "🎯 FoodTrack"
    
    struct Segue {
        static let login = "LoginToMain"
        static let register = "RegisterToMain"
        static let group = "MainToItems"
        static let settings = "MainToSettings"
    }
    
    struct FireStore {
        struct Collections {
            static let group = "Group"
            static let item = "Item"
            static let message = "Message"
        }
        static let date = "Date"
        static let done = "Done"
        static let id = "ID"
        static let userID = "UserID"
    }

    struct Cell {
        static let group = "GroupCell"
        static let item = "ItemCell"
    }
    
    
}


