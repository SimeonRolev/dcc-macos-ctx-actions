//
//  Constants.swift
//  dcc-ctx-actions
//
//  Created by Simeon Rolev on 12/16/19.
//  Copyright © 2019 Simeon Rolev. All rights reserved.
//

import Foundation

struct Environment {
    static func getEnvFromAppName(appName: String) -> Environment? {
        if appName == "Vectorworks Cloud Services" {
            return ENV_PROD
        }
        
        let label = appName.replacingOccurrences(of: "Vectorworks Cloud Services ", with: "")
        switch label {
            case "beta":
                return ENV_BETA
            case "qa":
                return ENV_QA
            case "devel":
                return ENV_QA
            default :
                return nil
        }
    }
    
    var index: Int = -1
    var config: String = ""
    var label: String = ""
}

let ENV_PROD = Environment(index: 0, config: "dcc.main.prod_settings", label: "prod")
let ENV_BETA = Environment(index: 1, config: "dcc.main.beta_settings", label: "beta")
let ENV_QA = Environment(index: 2, config: "dcc.main.beta_settings", label: "qa")
let ENV_DEV = Environment(index: 3, config: "dcc.main.test_settings", label: "devel")


let BG_SERVICE_NAME = "Vectorworks Cloud Services Background Service"
