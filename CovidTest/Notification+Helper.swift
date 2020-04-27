//
//  Notification+Helper.swift
//  CovidTest
//
//  Created by shihab on 4/20/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let kDidLoadLocationInformation = Notification.Name("didLoadLocationInformation")
    static let kDidLoadLocationInformationForCity = Notification.Name("didLoadLocationInformationForCity")
    static let kDidLoadPastCasesInformation = Notification.Name("didLoadPastCasesInformation")
    static let kDidLoadSummaryPastCasesInformationNotification = Notification.Name("didLoadSummaryPastCasesInformationNotification")
    static let kDidLoadSummaryInformation = Notification.Name("didLoadSummaryInformation")
    static let kDidLoadLocationServiceNotification = Notification.Name("kDidLoadLocationServiceNotification")
}
