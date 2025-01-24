//
//  LifeFrameApp.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

@main
struct MemoriesSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var vm = HomeVM()
    private var popUpVM = BottomPopUpVM()
    private var quickActionSettings = QuickActionVM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quickActionSettings)
                .environmentObject(popUpVM)
                .environmentObject(vm)
                .onAppear {
                    let os = UIDevice.current.userInterfaceIdiom
                    if os == .phone {
                        AppDelegate.orientationLock = .portrait
                    } else if os == .pad || os == .mac {
                        AppDelegate.orientationLock = .landscape
                    }
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: AppDelegate.orientationLock))
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
       
    // MARK: - Device Orientation
    
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

