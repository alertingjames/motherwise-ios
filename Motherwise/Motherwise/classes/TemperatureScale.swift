//
//  TemperatureScale.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import Foundation

enum TemperatureScale: String {
    case celsius = "metric"
    case kelvin = "kelvin"
    case fahrenheit = "imperial"
    
    func symbolForScale() -> String {
        switch(self) {
        case .celsius:
            return "℃"
        case .kelvin:
            return "K"
        case .fahrenheit:
            return "℉"
        }
    }
}
