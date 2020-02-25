//
//  ViewController.swift
//  Trip Summary
//
//  Created by Student on 2020-02-24.
//  Copyright © 2020 Kaiyum. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

//     Exposed UI components
    @IBOutlet weak var appName: UILabel!
    
    @IBOutlet weak var currSpeed: UILabel!
    @IBOutlet weak var maxSpeed: UILabel!
    @IBOutlet weak var avgSpeed: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var maxAcceleration: UILabel!
    
    
    @IBOutlet weak var warningLabel: UILabel! // Rad = Exceed over 115 km/h
    @IBOutlet weak var statusLabel: UILabel! // Green = Active, Gray = Deactive
    
    @IBOutlet weak var map: MKMapView!
    
    
//     Local var
    let locationManager = CLLocationManager()
    
    var currentLocation : CLLocation?
    var previousLocation: CLLocation?
    
    var ticks : Int = 0
   
    var totalDistanceValue : Double = 0.0
    var currSpeedValue : Double = 0.0
    var previousSpeedValue : Double = 0.0
    var maxSpeedValue: Double = 0.0
//    var totalSpeed : Double = 0.0
    var avgSpeedvalue : Double =  0.0
//    {
//        self.totalSpeed / self.ticks
//    }
//
    
    let DISTANCE_UNIT_CONVERT : Double = 1000.0 // 1 km = 1000.0 m
    let TIME = 1 // every 1 sec, location is available to process
    let DISTANCE_UNIT = "km"
    let SPEED_UNIT = "km/h"
    let ACCELERATION = "km/s^2"
    let SPEED_LIMIT : Double = 115.0
    
    let TRANSPARENT = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    let DEACTIVE_COLOR = UIColor.gray
    let ACTIVE_COLOR = UIColor.green
    let WANRNING_COLOR = UIColor.red
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        SetupUI(isLoaded: true)
        locationManager.delegate = self
        
    }
    
    private func SetupUI(isLoaded : Bool){
        if(isLoaded){
            SetWarningLabel(color: TRANSPARENT)
            SetStatusLabel(color : DEACTIVE_COLOR)
        }
    }
    
    // Button events
    @IBAction func StartTripClicked(_ sender: UIButton) {
        //Instruct GPS to start gathering data
        locationManager.startUpdatingLocation()
        //Additionally get permission from user to use GPS
        locationManager.requestWhenInUseAuthorization()
                
        map.showsUserLocation = true
        
        SetStatusLabel(color: ACTIVE_COLOR)
    }
    
    @IBAction func StopTripClicked(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        map.showsUserLocation = false
        
        SetStatusLabel(color: DEACTIVE_COLOR)
        RestoreNormal()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            currentLocation = location
            
            if(previousLocation != nil){
                if let curr = currentLocation {
                    var distance = curr.distance(from: previousLocation!)
                
                    distance /= DISTANCE_UNIT_CONVERT
                    
                    print("current : (\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)")
                    print("previous : (\(previousLocation!.coordinate.latitude),\(previousLocation!.coordinate.longitude)")
                    
                    SetSpeedLabel()
                    CalculateTotalDistance(distance: distance)
                    CalculateSpeed(distance: distance)
                    SetRegion(location: location)
                    
                    previousLocation = currentLocation
                }
            }else{
                previousLocation = currentLocation
            }
            
            ticks += 1
        }
    }
    
    func CalculateTotalDistance( distance : Double ) {
        totalDistanceValue += distance
        
        SetDistanceLabel(value: totalDistanceValue)
    }
    
   private func SetDistanceLabel(value : Double){
        
        distance.text = String(format: "%.2f \(DISTANCE_UNIT)", value)
//        print("Total Distance \(String(format: "%.2f", value)) \(DISTANCE_UNIT)")
    }
    
    private func SetRegion(location : CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        map.setRegion(region, animated: true)
    }
    
    func CalculateSpeed(distance : Double) {
        currSpeedValue = currentLocation!.speed *  ( 3.6 )
        previousSpeedValue = previousLocation!.speed * (3.6)

        SetSpeedLabel()
        
//        Max Speed
        if(currSpeedValue > maxSpeedValue ){
            maxSpeedValue = currSpeedValue
        }
        
        SetMaxSpeedLabel()
    }
    
    private func SetSpeedLabel(){
        
        
        if(currSpeedValue >= (SPEED_LIMIT)){
            RaiseWarning()
            
        }else{
            RestoreNormal()
        }
        currSpeed.text = String(format : "%.2f \(SPEED_UNIT)" , currSpeedValue)
    }
    
    func SetMaxSpeedLabel() {
        maxSpeed.text = String(format: "%.2f \(SPEED_UNIT)", maxSpeedValue)
    }
    
    func RaiseWarning(){
        warningLabel.text = currSpeed.text!
        SetWarningLabel(color: WANRNING_COLOR)
    }
    func RestoreNormal() {
        warningLabel.text = ""
        SetWarningLabel(color: TRANSPARENT)
    }
    
    private func SetWarningLabel(color : UIColor) {
        warningLabel.backgroundColor = color
    }
    
    private func SetStatusLabel(color : UIColor){
        statusLabel.backgroundColor = color
    }
}

