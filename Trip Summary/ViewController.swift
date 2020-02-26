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
    var avgSpeedValue : Double =  0.0
    var accelerationValue : Double = 0.0
    var maxAccelerationValue : Double = 0.0

    let DISTANCE_UNIT_CONVERT : Double = 1000.0 // 1 km = 1000.0 m
    let TIME = 1 // every 1 sec, location is available to process
    let DISTANCE_UNIT = "km"
    let SPEED_UNIT = "km/h"
    let ACCELERATION_UNIT = "km/s^2"
    let SPEED_LIMIT : Double = 115.0
    
    let TRANSPARENT = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    let DEACTIVE_COLOR = UIColor.gray
    let ACTIVE_COLOR = UIColor.green
    let WANRNING_COLOR = UIColor.red
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI(isLoaded: true)
        locationManager.delegate = self
    }
    
    private func setupUI(isLoaded : Bool){
        if(isLoaded){
            setWarningLabel(color: TRANSPARENT)
            setStatusLabel(color : DEACTIVE_COLOR)
        }
    }
    
    // Button events
    @IBAction func startTripClicked(_ sender: UIButton) {
        clearStats()
        //Instruct GPS to start gathering data
        locationManager.startUpdatingLocation()
        //Additionally get permission from user to use GPS
        locationManager.requestWhenInUseAuthorization()
                
        map.showsUserLocation = true
        
        setStatusLabel(color: ACTIVE_COLOR)
    }
    
    @IBAction func stopTripClicked(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        map.showsUserLocation = false
        
        setStatusLabel(color: DEACTIVE_COLOR)
        restoreNormal()
    }
    
    func clearStats() {
        totalDistanceValue = 0.0
        currSpeedValue = 0.0
        previousSpeedValue = 0.0
        maxSpeedValue = 0.0
        avgSpeedValue =  0.0
        accelerationValue = 0.0
        maxAccelerationValue = 0.0
        
        setSpeedLabel()
        setAvgSpeedLabel()
        setMaxSpeedLabel()
        setStatusLabel(color: DEACTIVE_COLOR)
        setWarningLabel(color: TRANSPARENT)
        setDistanceLabel(value: 0.0)
        setMaxAccelerationLabel()
        
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
                    
                    setSpeedLabel()
                    calculateTotalDistance(distance: distance)
                    calculateSpeed(distance: distance)
                    
                    setRegion(location: location)
                    
                    previousLocation = currentLocation
                }
            }else{
                previousLocation = currentLocation
            }
            
            ticks += 1
        }
    }
    
    func calculateTotalDistance( distance : Double ) {
        totalDistanceValue += distance
        
        setDistanceLabel(value: totalDistanceValue)
    }
    
   private func setDistanceLabel(value : Double){
        
        distance.text = String(format: "%.2f \(DISTANCE_UNIT)", value)
//        print("Total Distance \(String(format: "%.2f", value)) \(DISTANCE_UNIT)")
    }
    
    private func setRegion(location : CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        map.setRegion(region, animated: true)
    }
    
    func calculateSpeed(distance : Double) {
        currSpeedValue = currentLocation!.speed *  ( 3.6 )
        previousSpeedValue = previousLocation!.speed * (3.6)
        
        
        
        setSpeedLabel()
        
        avgSpeedValue = (avgSpeedValue + currSpeedValue) / 2.0
        setAvgSpeedLabel()
        
//        maxAccelerationValue = abs()
        
//        Max Speed
        if(currSpeedValue > maxSpeedValue ){
            maxSpeedValue = currSpeedValue
        }
        setMaxSpeedLabel()
        
        accelerationValue = abs(currSpeedValue - previousSpeedValue)
        if(accelerationValue > maxAccelerationValue){
            maxAccelerationValue = accelerationValue
        }
        setMaxAccelerationLabel()
       
    }
    
    func setAvgSpeedLabel() {
        avgSpeed.text = String(format: "%.2f \(SPEED_UNIT)",avgSpeedValue)
    }
    
    func setMaxAccelerationLabel() {
        maxAcceleration.text = String(format: "%.2f \(ACCELERATION_UNIT)", maxAccelerationValue)
    }
    
    private func setSpeedLabel(){
        if(currSpeedValue >= (SPEED_LIMIT)){
            saiseWarning()
            
        }else{
            restoreNormal()
        }
        currSpeed.text = String(format : "%.2f \(SPEED_UNIT)" , currSpeedValue)
    }
    
    func setMaxSpeedLabel() {
        maxSpeed.text = String(format: "%.2f \(SPEED_UNIT)", maxSpeedValue)
    }
    
    func saiseWarning(){
        warningLabel.text = currSpeed.text!
        setWarningLabel(color: WANRNING_COLOR)
    }
    func restoreNormal() {
        warningLabel.text = ""
        setWarningLabel(color: TRANSPARENT)
    }
    
    private func setWarningLabel(color : UIColor) {
        warningLabel.backgroundColor = color
    }
    
    private func setStatusLabel(color : UIColor){
        statusLabel.backgroundColor = color
    }
}

