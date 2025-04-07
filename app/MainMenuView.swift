import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("👁️ Myopia Prevention")
                    .font(.largeTitle)
                    .bold()

                NavigationLink(destination: ContentView()) {
                    Text("🕒 20-20-20 Rule Reminder")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink(destination: EyeExerciseView()) {
                    Text("🧘 Eye Break Exercises")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}
