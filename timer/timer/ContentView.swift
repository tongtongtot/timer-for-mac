//
//  ContentView.swift
//  timer
//
//  Created by thomas on 2023/2/10.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var timeText_minute = "0"
    @State var timeText_second = "0.00"
    @State var change = 0.0
    @State var minute = 0
    @State var second = 0
    @State var start_btn = "开始倒计时"
    @State var timeText_all = 0.00
    @State var timeText_tmp = 0.00
    @State var is_start = false
    @State private var startTime = Date()
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var soundPlayer: AVAudioPlayer?
    var body: some View {
        VStack {
            Image(systemName: "clock")
            HStack {
                Button("+") {
                    self.minute += 1
                }
                Button("-") {
                    self.minute -= 1
                    self.minute = max(0, self.minute)
                }
                Text(String(minute) + "分" + String(second) + "秒")
                    .frame(minWidth: 40, maxWidth: 300)
                Button("+") {
                    self.second += 1
                    self.second = min(self.second, 59)
                }
                Button("-") {
                    self.second -= 1
                    self.second = max(0,self.second)
                }
            }
            Text("剩余时间: " + timeText_minute + "分" + timeText_second + "秒")
                .onReceive(timer){ _ in
                    if self.is_start {
                        timeText_tmp = timeText_all - Date().timeIntervalSince(self.startTime)
                        if timeText_tmp < 0.00 {
                            self.stoptime()
                        }
                        self.gettimeText()
                    }
                }
                //.frame(width: self.width)
            HStack {
                Button(start_btn){
                    if self.start_btn == "暂停倒计时" {
                        timeText_all = timeText_tmp
                        is_start = false
                        self.stopTimer()
                        start_btn = "继续倒计时"
                    }
                    else if self.start_btn == "开始倒计时"{
                        self.timeText_all = 60 * Double(self.minute) + Double(self.second)
                        self.resume()
                    }
                    else{
                        self.resume()
                    }
                }
                Button("停止倒计时"){
                    self.stoptime()
                }
            }
        }
        .padding()
    }
    func resume(){
        is_start = true
        self.start_btn = "暂停倒计时"
        startTime = Date()
        self.startTimer()
    }
    func gettimeText() {
        timeText_minute = String(Int(timeText_tmp / 60))
        if timeText_tmp - Double(Int(timeText_tmp / 60) * 60) <= 0.00 {
            timeText_second = "0.00"
            self.stoptime()
        }
        else {
            timeText_second = String(format: "%.2f", timeText_tmp - Double(Int(timeText_tmp / 60) * 60) + 0.0005)
        }
    }
    func stoptime() {
        self.playAudio(forResource: "lingling", ofType: "aac")
        is_start = false
        timeText_minute = "0"
        timeText_second = "0.00"
        //self.gettimeText()
        self.start_btn = "开始倒计时"
        self.stopTimer()
    }
    func stopTimer() {
        timer.upstream.connect().cancel()
    }
    func startTimer() {
        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    }
    func playAudio(forResource: String, ofType: String) {
        //定义路径
        let path = Bundle.main.path(forResource: forResource, ofType: ofType)!
        //定义url
        let url = URL(fileURLWithPath: path)

        do {
            //尝试使用预设的声音播放器获取目标文件
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            //播放声音————停止的话使用stop()方法
            soundPlayer?.play()
        } catch {
            //加载文件失败，这里用于防止应用程序崩溃
            print("音频文件出现问题")
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
