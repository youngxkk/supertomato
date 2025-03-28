//
//  PomodoroModel.swift
//  tomatoV3
//
//  Created by max on 3/28/25.
//

import Foundation
import SwiftUICore

enum TimerMode {
    case focusing
    case shortBreak
    case longBreak
}

class PomodoroModel: ObservableObject {
    @Published var timerMode: TimerMode = .focusing
    @Published var secondsLeft: Int = 25 * 60
    @Published var timerIsActive: Bool = false
    @Published var completedPomodoros: Int = 0
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var alertColor: Color = .red
    
    var timer: Timer?
    var totalSeconds: Int {
        switch timerMode {
        case .focusing: return UserDefaults.standard.integer(forKey: "focusMinutes") > 0 ?
                          UserDefaults.standard.integer(forKey: "focusMinutes") * 60 : 25 * 60
        case .shortBreak: return UserDefaults.standard.integer(forKey: "shortBreakMinutes") > 0 ?
                              UserDefaults.standard.integer(forKey: "shortBreakMinutes") * 60 : 5 * 60
        case .longBreak: return UserDefaults.standard.integer(forKey: "longBreakMinutes") > 0 ?
                             UserDefaults.standard.integer(forKey: "longBreakMinutes") * 60 : 15 * 60
        }
    }
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        if UserDefaults.standard.integer(forKey: "focusMinutes") == 0 {
            UserDefaults.standard.set(25, forKey: "focusMinutes")
        }
        if UserDefaults.standard.integer(forKey: "shortBreakMinutes") == 0 {
            UserDefaults.standard.set(5, forKey: "shortBreakMinutes")
        }
        if UserDefaults.standard.integer(forKey: "longBreakMinutes") == 0 {
            UserDefaults.standard.set(15, forKey: "longBreakMinutes")
        }
        resetTimer()
    }
    
    func startTimer() {
        timerIsActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.secondsLeft > 0 {
                self.secondsLeft -= 1
            } else {
                self.timerCompleted()
            }
        }
    }
    
    func pauseTimer() {
        timerIsActive = false
        timer?.invalidate()
    }
    
    func resetTimer() {
        pauseTimer()
        secondsLeft = totalSeconds
    }
    
    // 修改timerCompleted方法
    func timerCompleted() {
        pauseTimer()
        
        // 设置提醒内容
        if timerMode == .focusing {
            alertTitle = "一个专注结束"
//            alertMessage = "您已完成一个番茄钟!\n该休息一下了"
            alertColor = .blue
            completedPomodoros += 1
            timerMode = completedPomodoros % 4 == 0 ? .longBreak : .shortBreak
        } else {
            alertTitle = "休息时间结束"
//            alertMessage = "休息时间到!\n准备好继续专注了吗?"
            alertColor = .red
            timerMode = .focusing
            
            // 休息结束使用标准振动
            VibrationManager.shared.vibrate(type: .success)
        }
        
        
        showAlert = true
        
        // 触发系统通知
        NotificationManager.shared.scheduleNotification(title: alertTitle, body: alertMessage)
        resetTimer()
        
//        NotificationManager.shared.requestPermission()

        
    }
    
    func switchMode(to mode: TimerMode) {
        timerMode = mode
        resetTimer()
    }
    
    var progress: Double {
        1 - Double(secondsLeft) / Double(totalSeconds)
    }
    
    var timeString: String {
        let minutes = secondsLeft / 60
        let seconds = secondsLeft % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

