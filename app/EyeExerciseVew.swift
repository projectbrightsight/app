import SwiftUI

struct EyeExerciseView: View {
    @State private var intervalMinutes = 2
    @State private var currentExercise = ""
    @State private var timer: Timer?

    let exercises = [
        "👁️ Look up, down, left, right",
        "🔄 Roll your eyes in circles",
        "📍 Focus on a near object, then far",
        "🧘 Close your eyes and relax",
        "🔁 Blink rapidly 10 times",
        "👀 Trace a figure 8 in the air with your eyes"
    ]

    var body: some View {
        VStack(spacing: 30) {
            Text("🧘 Eye Break Exercises")
                .font(.largeTitle)
                .bold()

            Text("Exercise every \(intervalMinutes) min")
                .font(.headline)

            Stepper("Set Interval", value: $intervalMinutes, in: 1...60)

            if !currentExercise.isEmpty {
                Text(currentExercise)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button("Start Exercises") {
                startExerciseTimer()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("❌ Stop") {
                stopExerciseTimer()
                currentExercise = ""
            }
            .foregroundColor(.red)
        }
        .padding()
    }

    func startExerciseTimer() {
        currentExercise = getRandomExercise()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(intervalMinutes * 60), repeats: true) { _ in
            currentExercise = getRandomExercise()
        }
    }

    func stopExerciseTimer() {
        timer?.invalidate()
        timer = nil
    }

    func getRandomExercise() -> String {
        exercises.randomElement() ?? ""
    }
}
