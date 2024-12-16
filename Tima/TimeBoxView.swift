import SwiftUI
import SwiftData

struct TimeBoxView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()

                VStack {
                    Button(action: toggleTimeBox) {
                        Image(systemName: "hourglass.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.green)
                            .padding()
                    }
                    .padding([.top, .leading, .trailing])

                    HStack {
                        Text("Remain")
                        Text("28:00")
                    }
                }

                Spacer()
            }

        }
    }

    private func toggleTimeBox() {

    }
}

#Preview {
    TimeBoxView()
}
