//
//  Untitled.swift
//  tomatoV3
//
//  Created by max on 3/28/25.
//

import SwiftUI

struct HistoryView: View {
    let completedPomodoros: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if completedPomodoros == 0 {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("暂无历史记录")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("完成你的第一个番茄钟后，数据将显示在这里")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 100)
                } else {
                    List {
                        Section {
                            HStack {
                                Text("今日完成")
                                Spacer()
                                Text("\(completedPomodoros)")
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("本周完成")
                                Spacer()
                                Text("\(completedPomodoros)")
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("总完成数")
                                Spacer()
                                Text("\(completedPomodoros)")
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Section(header: Text("详细记录")) {
                            ForEach(0..<completedPomodoros, id: \.self) { index in
                                HStack {
                                    Text("番茄钟 #\(index + 1)")
                                    Spacer()
                                    Text(Date().addingTimeInterval(-Double(index) * 1500).formatted(date: .omitted, time: .shortened))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("历史记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}
