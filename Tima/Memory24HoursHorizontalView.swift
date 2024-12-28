import SwiftUI

struct Memory24HourHorizontalView: View {
    let spans: [(Int, Int)]

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.primary.opacity(0.2))
                    .frame(height: 40)
                    .cornerRadius(5)

                ForEach(0..<25) { hour in
                    DividerView(hour: hour)
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
        }
    }
}

struct DividerView: View {
    let hour: Int

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let x = width * CGFloat(hour) / 24

            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1, height: hour % 6 == 0 ? 20 : 10)
                    .offset(x: x)

                if hour % 6 == 0 && hour != 24 {
                    Text("\(hour)")
                        .font(.caption)
                        .offset(x: x - 10, y: 15)
                }
            }
        }
    }
}

#Preview {
    Memory24HourHorizontalView(spans: [(300, 2)])
}
