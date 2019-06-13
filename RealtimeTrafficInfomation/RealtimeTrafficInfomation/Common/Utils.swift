//
//  Utils.swift
//  RealtimeTrafficInfomation
//
//  Created by justin on 2019/6/12.
//  Copyright © 2019 jlai. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct Utils {

    /// NSManagedObjectContext
    public static var coreDataContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate// swiftlint:disable:this force_cast
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
}
