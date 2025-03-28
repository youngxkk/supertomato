//
//  Settings.swift
//  tomatoV3
//
//  Created by max on 3/28/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pomodoro: PomodoroModel
    
    @State private var focusMinutes: Int = UserDefaults.standard.integer(forKey: "focusMinutes") > 0 ?
        UserDefaults.standard.integer(forKey: "focusMinutes") : 25
    @State private var shortBreakMinutes: Int = UserDefaults.standard.integer(forKey: "shortBreakMinutes") > 0 ?
        UserDefaults.standard.integer(forKey: "shortBreakMinutes") : 5
    @State private var longBreakMinutes: Int = UserDefaults.standard.integer(forKey: "longBreakMinutes") > 0 ?
        UserDefaults.standard.integer(forKey: "longBreakMinutes") : 15
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("计时设置")) {
                    Stepper(value: $focusMinutes, in: 1...60) {
                        HStack {
                            Text("专注时间")
                            Spacer()
                            Text("\(focusMinutes) 分钟")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Stepper(value: $shortBreakMinutes, in: 1...30) {
                        HStack {
                            Text("短休时间")
                            Spacer()
                            Text("\(shortBreakMinutes) 分钟")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Stepper(value: $longBreakMinutes, in: 1...60) {
                        HStack {
                            Text("长休时间")
                            Spacer()
                            Text("\(longBreakMinutes) 分钟")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button("重置所有设置") {
                        focusMinutes = 25
                        shortBreakMinutes = 5
                        longBreakMinutes = 15
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(focusMinutes, forKey: "focusMinutes")
        UserDefaults.standard.set(shortBreakMinutes, forKey: "shortBreakMinutes")
        UserDefaults.standard.set(longBreakMinutes, forKey: "longBreakMinutes")
        pomodoro.loadSettings()
    }
}
