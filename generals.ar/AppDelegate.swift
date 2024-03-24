//
//  AppDelegate.swift
//  generals.ar
//
//  Created by Jack Nugent on 3/23/24.
//

import UIKit
import SwiftUI

class CustomUIHostingController<Content> : UIHostingController<Content> where Content: View {
    var timer: Timer?
    var board: Board
    
    required init(rootView: Content, board: Board) {
        self.board = board
        super.init(rootView: rootView)
    }
    
    // NOTE: NEVER USE THIS INIT METHOD
    required init?(coder: NSCoder) {
        self.board = Board()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in self.update()})
    }
    
    func update() {
         self.board.updateBoard()
        
        // TODO: erase
//        if self.board.board.count > 0 {
//            if let t = self.board.board[2][1] as? OpenTile {
//                print("INCREMENT TROOPS")
//                t.setTroopCount(newCount: t.troopCount + 1)
//            } else {
//                print("ERROR")
//            }
//        } else {
//            print("NO BOARD")
//        }
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create the SwiftUI view that provides the window contents.
        let board = Board()
        let contentView = ContentView(board: board)

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = CustomUIHostingController(rootView: contentView, board: board)
//        window.rootViewController = CustomUIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

