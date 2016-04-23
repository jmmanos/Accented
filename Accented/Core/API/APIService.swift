//
//  APIService.swift
//  Accented
//
//  Created by You, Tiangong on 4/22/16.
//  Copyright © 2016 Tiangong You. All rights reserved.
//

import UIKit
import OAuthSwift

// Stream definitions
enum StreamType : String {
    case Popular = "popular"
    case HighestRated = "highest_rated"
    case Upcoming = "upcoming"
    case Editors = "editors"
    case FreshToday = "fresh_today"
    case FreshYesterday = "fresh_yesterday"
    case FreshWeek = "fresh_week"
    case User = "user"
}

class APIService: NSObject {
    
    // API base url
    let baseUrl = "https://api.500px.com/v1/"
    
    // Singleton instance
    static let sharedInstance = APIService()
    private override init() {
        let authenticationService = AuthenticationService.sharedInstance
        client = OAuthSwiftClient(consumerKey: authenticationService.consumerKey,
                                  consumerSecret: authenticationService.consumerSecret,
                                  accessToken: authenticationService.accessToken!,
                                  accessTokenSecret: authenticationService.accessTokenSecret!)
    }
    
    // OAuth client for making API calls
    var client : OAuthSwiftClient
    
}
