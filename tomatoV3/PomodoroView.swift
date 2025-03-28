//
//  ContentView.swift
//  tomatoV3
//
//  Created by max on 3/28/25.
//


import SwiftUI
import UserNotifications

struct PomodoroView: View {
    @StateObject private var pomodoro = PomodoroModel()
    @State private var showingSettings = false
    @State private var showingHistory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // 模式选择
                    Picker("Timer Mode", selection: $pomodoro.timerMode) {
                        Text("专注").tag(TimerMode.focusing)
                        Text("短休").tag(TimerMode.shortBreak)
                        Text("长休").tag(TimerMode.longBreak)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .disabled(pomodoro.timerIsActive)
                    .onChange(of: pomodoro.timerMode) { _ in
                        pomodoro.resetTimer()
                    }
                    
                    // 计时器显示
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(colorForMode(pomodoro.timerMode))
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(pomodoro.progress))
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .foregroundColor(colorForMode(pomodoro.timerMode))
                            .rotationEffect(Angle(degrees: 270))
                            .animation(.linear, value: pomodoro.progress)
                        
                        Text(pomodoro.timeString)
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .accessibilityLabel("剩余时间 \(pomodoro.timeString)")
                    }
                    .frame(width: 300, height: 300)
                    .padding()
                    
                    // 控制按钮
                    HStack(spacing: 40) {
                        if pomodoro.timerIsActive {
                            Button {
                                pomodoro.pauseTimer()
                            } label: {
                                Image(systemName: "pause.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 80)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("暂停计时器")
                        } else {
                            Button {
                                pomodoro.startTimer()
                            } label: {
                                Image(systemName: "play.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 80)
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("开始计时器")
                        }
                        
                        Button {
                            pomodoro.resetTimer()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("重置计时器")
                    }
                    
                    // 番茄计数
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.red)
                        Text("已完成: \(pomodoro.completedPomodoros)")
                            .font(.headline)
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("番茄时钟")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingHistory = true
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(pomodoro)
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(completedPomodoros: pomodoro.completedPomodoros)
            }
        }
    }
    
    private func colorForMode(_ mode: TimerMode) -> Color {
        switch mode {
        case .focusing: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}




class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
