//
//  HeaderViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import DropDown

class HeaderViewController: UIViewController {
    
    @IBOutlet weak var lbl_location: UILabel!
    @IBOutlet weak var lbl_weekday: UILabel!
    @IBOutlet weak var lbl_dt: UILabel!
    @IBOutlet weak var lbl_temp: UILabel!
    @IBOutlet weak var lbl_main_desc: UILabel!
    @IBOutlet weak var lbl_desc: UILabel!
    @IBOutlet weak var lbl_clouds: UILabel!
    @IBOutlet weak var lbl_temp_range: UILabel!
    @IBOutlet weak var lbl_wind_speed: UILabel!
    @IBOutlet weak var lbl_pressure: UILabel!
    @IBOutlet weak var lbl_humidity: UILabel!
    @IBOutlet weak var img_weather: UIImageView!
    @IBOutlet weak var lbl_sunrise: UILabel!
    @IBOutlet weak var lbl_sunset: UILabel!
    @IBOutlet weak var btn_settings: UIButton!
    
    @IBOutlet weak var ic_sunrise: UIImageView!
    @IBOutlet weak var ic_sunset: UIImageView!
    @IBOutlet weak var ic_alert: UIImageView!
    @IBOutlet weak var ic_alert_temp: UIImageView!
    @IBOutlet weak var ic_alert_wind: UIImageView!
    @IBOutlet weak var ic_alert_pressure: UIImageView!
    @IBOutlet weak var ic_wind_direction: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn_settings.setImageTintColor(.white)
        
        ic_alert.image = ic_alert.image?.imageWithColor(color1: UIColor.orange)
        ic_alert.visibilityh = .gone
        
        ic_alert_temp.image = ic_alert_temp.image?.imageWithColor(color1: UIColor.orange)
        ic_alert_temp.visibilityh = .gone
        
        ic_alert_wind.image = ic_alert_wind.image?.imageWithColor(color1: UIColor.orange)
        ic_alert_wind.visibilityh = .gone
        
        ic_alert_pressure.image = ic_alert_pressure.image?.imageWithColor(color1: UIColor.orange)
        ic_alert_pressure.visibilityh = .gone
        
    }
    

    @IBAction func refreshLocation(_ sender: Any) {
        isWeatherLocationChanged = false
        gWeatherViewController.newCityName = ""
        gWeatherViewController.getCurrentUserLocation()
    }
    
    @IBAction func openWeatherSettings(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = self.btn_settings
        dropDown.dataSource = [
            "  " + "change_city".localized(), "  " + "change_location".localized(),
            "  " + "change_celsius".localized(), "  " + "change_fahrenheit".localized(), "  " + "change_kelvin".localized()]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            if idx == 0{
                gWeatherViewController.showInputDialog(title: "enter_city_name".localized(), button_text: "ok".localized().uppercased(), index: 1)
            }else if idx == 1{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PickWeatherLocationViewController")
                vc!.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
            }else if idx == 2{
                UserDefaults.standard.set("celsius", forKey: "temp_scale")
                if isWeatherLocationChanged {
                    if gWeatherViewController.newCityName.count > 0{
                        gWeatherViewController.getWeatherData3(city: gWeatherViewController.newCityName, scale: .celsius)
                    }else if gWeatherViewController.newLocation != nil {
                        gWeatherViewController.getWeather(location: gWeatherViewController.newLocation)
                    }
                }else{
                    gWeatherViewController.getCurrentUserLocation()
                }
            }else if idx == 3{
                UserDefaults.standard.set("fahrenheit", forKey: "temp_scale")
                if isWeatherLocationChanged {
                    if gWeatherViewController.newCityName.count > 0{
                        gWeatherViewController.getWeatherData3(city: gWeatherViewController.newCityName, scale: .fahrenheit)
                    } else if gWeatherViewController.newLocation != nil {
                        gWeatherViewController.getWeather(location: gWeatherViewController.newLocation)
                    }
                }else{
                    gWeatherViewController.getCurrentUserLocation()
                }
            }else if idx == 4{
                UserDefaults.standard.set("kelvin", forKey: "temp_scale")
                if isWeatherLocationChanged {
                    if gWeatherViewController.newCityName.count > 0{
                        gWeatherViewController.getWeatherData3(city: gWeatherViewController.newCityName, scale: .kelvin)
                    } else if gWeatherViewController.newLocation != nil {
                        gWeatherViewController.getWeather(location: gWeatherViewController.newLocation)
                    }
                }else{
                    gWeatherViewController.getCurrentUserLocation()
                }
            }
        }
                
        DropDown.appearance().textColor = UIColor.white
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        DropDown.appearance().backgroundColor = UIColor(rgb: 0x003333, alpha: 1.0)
        DropDown.appearance().selectionBackgroundColor = UIColor(rgb: 0x003333, alpha: 1.0)
        DropDown.appearance().cellHeight = 50
        
        dropDown.separatorColor = UIColor.white
        dropDown.width = 190
                
        dropDown.show()
    }
    
    @IBAction func back(_ sender: Any) {
        gWeatherViewController.dismiss()
    }
}
