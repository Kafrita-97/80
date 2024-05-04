//
//  ContentView.swift
//  80
//
//  Created by Juanma on 30/4/24.
//

import SwiftUI
import UIKit
import UserNotifications

struct ContentView: View {
    
    @State private var batteryLevel = UIDevice.current.batteryLevel
    @State private var batteryState = UIDevice.current.batteryState
    @State private var monitoringEnabled = false
    @State private var levelTimer: Timer?
    @State private var statusTimer: Timer?
    
    var body: some View {
        
        VStack {
            
            if monitoringEnabled {
                
                Text("Battery Level: \(batteryLevel * 100, specifier: "%.2f")%")
                
                switch batteryState {
                case .unknown:
                    Text("Battery state: Unknown")
                case .unplugged:
                    Text("Battery state: Dischargin")
                case .charging:
                    Text("Battery state: Charging")
                case .full:
                    Text("Battery state: Full charged")
                @unknown default:
                    Text("Battery state: Unknown")
                }
                
            } else {
                
                Text("Battery monitoring disabled")
            }
            
            Button("Enable Battery Monitoring") {
                enableBatteryMonitoring()
            }
            
            Button("Disable Battery Monitoring") {
                disableBatteryMonitoring()
            }
        }
        .padding()
        .onAppear(perform: {
            batteryLevelNotificationRequest()
        })
    }
    
    private func enableBatteryMonitoring() {
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        monitoringEnabled = true
        
        updateBatteryLevel()
        updateBatteryStatus()
    }
    
    private func disableBatteryMonitoring() {
        
        UIDevice.current.isBatteryMonitoringEnabled = false
        monitoringEnabled = false
        
        stopUpdateBatteryLevel()
        stopUpdateBatteryStatus()
    }
    
    private func updateBatteryLevel() {
        
        batteryLevel = UIDevice.current.batteryLevel
        
        levelTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            
            if batteryLevel >= 0.8 && batteryState.rawValue == 2 {
                batteryLevelNotification()
            }
            
            batteryLevel = UIDevice.current.batteryLevel
            print(batteryLevel)
        }
    }
    
    private func stopUpdateBatteryLevel() {
        levelTimer?.invalidate()
    }
    
    private func updateBatteryStatus() {
        
        batteryState = UIDevice.current.batteryState
        
        statusTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            batteryState = UIDevice.current.batteryState
            print(batteryState.rawValue)
        }
    }
    
    private func stopUpdateBatteryStatus() {
        statusTimer?.invalidate()
    }
    
    private func batteryLevelNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Batería del iPhone"
        content.body = "El iPhone está cargado al máximo recomendado del 80%."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func batteryLevelNotificationRequest() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
           
            if let error = error {
               
                print("Error requesting notificatioauthorization: \(error.localizedDescription)")
                
            } else if !granted {
                
                print("Notification authorization denied.")
           
            } else {
                
                print("Notification authorization granted.")
            }
        }
    }
}

#Preview {
    ContentView()
}
