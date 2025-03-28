//
//  AlertView..swift
//  tomatoV3
//
//  Created by max on 3/28/25.
//

import SwiftUI
import UIKit


struct AlertView: View {
    let title: String
    let message: String
    let primaryColor: Color
    let onDismiss: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            primaryColor.opacity(0.96)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)  // 新增这行设置白色
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isPulsing)
                
                VStack(spacing: 15) {
                    Text(title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text(message)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(.white)
                
                Button(action: onDismiss) {
                    Text("ok")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(primaryColor)
                        .frame(width: 200, height: 60)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(radius: 10)
                }
                .padding(.top, 30)
            }
            .padding(40)
        }
        .onAppear {
            isPulsing = true
            // 触发振动反馈
            VibrationManager.shared.vibrate(type: .success)
        }
    }
}


//增强振动管理器 (VibrationManager)
enum VibrationType {
    case light
    case medium
    case heavy
    case success
    case error
    case warning
    case longCompletion // 新增长时间振动类型
}

class VibrationManager {
    static let shared = VibrationManager()
    
    private init() {}
    
    func vibrate(type: VibrationType) {
        switch type {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
        case .longCompletion:
            // 长时间振动模式：组合多种振动
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.notificationOccurred(.success)
            
            // 延迟执行第二次振动
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
                impactGenerator.impactOccurred()
                
                // 第三次振动
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let secondNotification = UINotificationFeedbackGenerator()
                    secondNotification.notificationOccurred(.warning)
                }
            }
        }
    }
    
    // 新增可配置振动方法
    func extendedVibration(duration: TimeInterval, intensity: CGFloat) {
        guard duration > 0 else { return }
        
        let startTime = Date()
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        
        // 持续振动效果
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= duration {
                timer.invalidate()
                return
            }
            
            // 动态调整强度
            let currentIntensity = min(intensity, 1.0) * (1.0 - CGFloat(elapsed/duration))
            generator.impactOccurred(intensity: max(currentIntensity, 0.3))
        }
    }
}
