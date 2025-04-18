//
//  ContentView.swift
//  tomatoV3
//
//  Created by max on 3/29/25.
//


import SwiftUI

struct PomodoroView: View {
    @StateObject private var pomodoro = PomodoroModel()
    @State private var showingSettings = false
    @State private var showingHistory = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // 判断是否为iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // 根据设备类型调整大小
    private var circleSize: CGFloat {
        isIPad ? 460 : 300
    }
    
    private var buttonSize: CGFloat {
        isIPad ? 120 : 80
    }
    
    private var timeFontSize: CGFloat {
        isIPad ? 100 : 60
    }
    
    private var topPadding: CGFloat {
        isIPad ? 30 : 10
    }
    
    private var spacing: CGFloat {
        isIPad ? 60 : 40
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 主界面背景
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    // 主内容区域
                    ScrollView {
                        VStack(spacing: spacing) {
                            // 模式选择器
                            Picker("Timer Mode", selection: $pomodoro.timerMode) {
                                Text("专注").tag(TimerMode.focusing)
                                Text("短休").tag(TimerMode.shortBreak)
                                Text("长休").tag(TimerMode.longBreak)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal, isIPad ? 100 : 20)
                            .disabled(pomodoro.timerIsActive)
                            .onChange(of: pomodoro.timerMode) {
                                pomodoro.resetTimer()
                            }
                            
                            // 圆形进度条
                            ZStack {
                                // 背景圆环
                                Circle()
                                    .stroke(lineWidth: isIPad ? 25 : 20)
                                    .opacity(0.3)
                                    .foregroundColor(colorForMode(pomodoro.timerMode))
                                
                                // 进度圆环
                                Circle()
                                    .trim(from: 0.0, to: CGFloat(pomodoro.progress))
                                    .stroke(style: StrokeStyle(
                                        lineWidth: isIPad ? 25 : 20,
                                        lineCap: .round,
                                        lineJoin: .round))
                                    .foregroundColor(colorForMode(pomodoro.timerMode))
                                    .rotationEffect(Angle(degrees: 270))
                                    .animation(.linear, value: pomodoro.progress)
                                
                                // 时间显示
                                Text(pomodoro.timeString)
                                    .font(.system(size: timeFontSize, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .accessibilityLabel("剩余时间 \(pomodoro.timeString)")
                            }
                            .frame(width: circleSize, height: circleSize)
                            .padding(.vertical, isIPad ? 40 : 20)
                            
                            // 控制按钮
                            HStack(spacing: spacing) {
                                if pomodoro.timerIsActive {
                                    // 暂停按钮
                                    Button {
                                        pomodoro.pauseTimer()
                                    } label: {
                                        Image(systemName: "pause.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .frame(width: buttonSize, height: buttonSize)
                                            .background(Color.orange)
                                            .clipShape(Circle())
                                    }
                                    .accessibilityLabel("暂停计时器")
                                } else {
                                    // 开始按钮
                                    Button {
                                        pomodoro.startTimer()
                                    } label: {
                                        Image(systemName: "play.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .frame(width: buttonSize, height: buttonSize)
                                            .background(Color.green)
                                            .clipShape(Circle())
                                    }
                                    .accessibilityLabel("开始计时器")
                                }
                                
                                // 重置按钮
                                Button {
                                    pomodoro.resetTimer()
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .frame(width: buttonSize, height: buttonSize)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                                .accessibilityLabel("重置计时器")
                            }
                            
                            // 修改后的番茄计数显示部分
                            VStack {
                                Spacer() // 这将把下面的内容推到屏幕底部
                                
                                HStack {
                                    Image(systemName: "flag.fill")
                                        .foregroundColor(.red)
                                    Text("已完成: \(pomodoro.completedPomodoros)")
                                        .font(isIPad ? .title : .headline)
                                }
                                .padding(.bottom, 60) // 设置距离底部30点的间距
                            }
                        }
                        .frame(minHeight: geometry.size.height)
                        .padding(.top, topPadding)
                    }
                    
                    // 全屏提醒覆盖层
                    if pomodoro.showAlert {
                        AlertView(
                            title: pomodoro.alertTitle,
                            message: pomodoro.alertMessage,
                            primaryColor: pomodoro.alertColor,
                            onDismiss: {
                                pomodoro.showAlert = false
                            }
                        )
                        .transition(.opacity)
                        .zIndex(1)
                        .accessibilityElement(children: .combine)
                        .accessibility(addTraits: .isModal)
                        .accessibilityHint("计时结束提醒，双击关闭")
                    }
                }
            }
            .navigationTitle("番茄时钟")
            .navigationBarTitleDisplayMode(isIPad ? .inline : .automatic)
            .toolbar {
                // 历史记录按钮
                ToolbarItem(placement: isIPad ? .primaryAction : .navigationBarLeading) {
                    Button {
                        showingHistory = true
                    } label: {
                        Image(systemName: "text.rectangle.page")
                            .accessibilityLabel("查看历史记录")
                    }
                }
                
                // 设置按钮
                ToolbarItem(placement: isIPad ? .primaryAction : .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .accessibilityLabel("打开设置")
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // 应用从后台返回时检查计时器状态
            if pomodoro.timerIsActive {
                let backgroundTime = UserDefaults.standard.double(forKey: "backgroundTime")
                let currentTime = Date().timeIntervalSince1970
                let elapsed = currentTime - backgroundTime
                
                if elapsed > Double(pomodoro.secondsLeft) {
                    pomodoro.timerCompleted()
                } else {
                    pomodoro.secondsLeft -= Int(elapsed)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            // 应用进入后台时记录时间
            if pomodoro.timerIsActive {
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "backgroundTime")
            }
        }
    }
    
    // 根据模式返回对应颜色
    private func colorForMode(_ mode: TimerMode) -> Color {
        switch mode {
        case .focusing: return .blue
        case .shortBreak: return .green
        case .longBreak: return .red
        }
    }
}

// 预览代码
struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PomodoroView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 15"))
                .previewDisplayName("iPhone 15")
            
            PomodoroView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro 12.9")
        }
    }
}
