import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image("logo") // Your logo name in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)

                Text("Sightly")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Helping you protect your vision.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = false
                }
            }
        }
    }
}
