import SwiftUI
import UserNotifications
import AVFoundation

struct ContentView: View {
    let timerDuration = 15
    let countdownDuration = 3
    let breakDuration = 20

    enum Phase: Equatable {
        case idle
        case mainTimer(remaining: Int)
        case countdown(remaining: Int)
        case breakTime(remaining: Int)
    }

    @State private var phase: Phase = .idle
    @State private var lastPhase: Phase = .idle
    @State private var backgroundColor: Color = .white
    @State private var countdownText: String = ""
    @State private var audioPlayer: AVAudioPlayer?
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: backgroundColor)

            VStack(spacing: 40) {
                Text("👁️ Myopia Prevention")
                    .font(.largeTitle)
                    .bold()

                switch phase {
                case .idle:
                    Button(action: startMainTimer) {
                        Text("Start Timer")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                    }

                case .mainTimer(let remaining):
                    Text("Next break in \(formatTime(remaining))")
                        .font(.title2)
                        .foregroundColor(.gray)

                case .countdown(let remaining):
                    Text("Look 20 ft away in \(remaining)...")
                        .font(.title)

                case .breakTime(let remaining):
                    Text("Look away! \(remaining) seconds left...")
                        .font(.title2)
                }

                if phase != .idle {
                    Button("❌ Stop") {
                        stopCycle()
                    }
                    .foregroundColor(.red)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 2)
                    )
                }
            }
            .padding()
        }
        .onAppear {
            requestNotificationPermission()
            evaluatePhase()
            startLoop()
        }
        .onDisappear {
            stopCycle()  // ✅ Automatically stop when leaving the view
        }
    }

    func startMainTimer() {
        let now = Date()
        UserDefaults.standard.set(now, forKey: "startTime")
        scheduleAllNotifications(from: now)
        evaluatePhase()
        startLoop()
    }

    func stopCycle() {
        UserDefaults.standard.removeObject(forKey: "startTime")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        timer?.invalidate()
        backgroundColor = .white
        phase = .idle
        lastPhase = .idle
    }

    func getStartTime() -> Date? {
        UserDefaults.standard.object(forKey: "startTime") as? Date
    }

    func evaluatePhase() {
        guard let start = getStartTime() else {
            phase = .idle
            return
        }

        let elapsed = Int(Date().timeIntervalSince(start))

        if elapsed < timerDuration {
            phase = .mainTimer(remaining: timerDuration - elapsed)
            backgroundColor = .white

        } else if elapsed < timerDuration + countdownDuration {
            let left = countdownDuration - (elapsed - timerDuration)
            phase = .countdown(remaining: left)
            backgroundColor = Color.red.opacity(0.2)

            if case .countdown = lastPhase {} else {
                playChime()

                if UIApplication.shared.applicationState != .active {
                    let content = UNMutableNotificationContent()
                    content.title = "Eye Break Incoming"
                    content.body = "Look away in 3 seconds..."
                    content.sound = .default

                    let request = UNNotificationRequest(identifier: "countdownNow", content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                }
            }

        } else if elapsed < timerDuration + countdownDuration + breakDuration {
            let left = breakDuration - (elapsed - timerDuration - countdownDuration)
            phase = .breakTime(remaining: left)
            backgroundColor = Color.blue.opacity(0.2)

            if case .breakTime = lastPhase {} else {
                playChime()

                if UIApplication.shared.applicationState != .active {
                    let content = UNMutableNotificationContent()
                    content.title = "Time to Look Away"
                    content.body = "Look at something 20 ft away for 20 seconds."
                    content.sound = .default

                    let request = UNNotificationRequest(identifier: "breakStartNow", content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                }
            }

        } else {
            let newStart = Date()
            UserDefaults.standard.set(newStart, forKey: "startTime")
            scheduleAllNotifications(from: newStart)
            phase = .mainTimer(remaining: timerDuration)
            backgroundColor = .white

            playChime()

            if UIApplication.shared.applicationState != .active {
                let content = UNMutableNotificationContent()
                content.title = "Break Over"
                content.body = "Back to focus. Timer restarted."
                content.sound = .default

                let request = UNNotificationRequest(identifier: "breakEndNow", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request)
            }
        }

        lastPhase = phase
    }

    func startLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            evaluatePhase()
        }
    }

    func scheduleAllNotifications(from base: Date) {
        scheduleNotification(
            at: base.addingTimeInterval(TimeInterval(timerDuration)),
            title: "Get Ready!",
            body: "Look away in 3 seconds",
            id: "countdown"
        )
        scheduleNotification(
            at: base.addingTimeInterval(TimeInterval(timerDuration + countdownDuration)),
            title: "Time for an Eye Break!",
            body: "Look 20 ft away for 20 seconds",
            id: "breakStart"
        )
        scheduleNotification(
            at: base.addingTimeInterval(TimeInterval(timerDuration + countdownDuration + breakDuration)),
            title: "Break Over!",
            body: "Back to focus. Timer restarting.",
            id: "breakEnd"
        )
    }

    func scheduleNotification(at date: Date, title: String, body: String, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: date.timeIntervalSinceNow,
            repeats: false
        )
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }

    func playChime() {
        guard let soundURL = Bundle.main.url(forResource: "chime", withExtension: "wav") else {
            print("Chime sound not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }

    func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
