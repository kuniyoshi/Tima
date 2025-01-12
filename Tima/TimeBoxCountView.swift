import SwiftUI

// Shows TimeBox counts to time bar
struct TimeBoxCountView: View {
    let spans: [(Int, Int)] // TODO: 共通化する?

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.primary.opacity(0.2))
                    .frame(height: 40)
                    .cornerRadius(5)

                ForEach(Array(spans.enumerated()), id: \.0) { _, span in
                    MemorySpanView(startMinutes: span.0, durationMinutes: span.1)
                }

                ForEach(0..<25) { hour in
                    DividerView(hour: hour)
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
        }
    }
}

private struct DividerView: View {
    let hour: Int

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let x = width * CGFloat(hour) / 24

            ZStack {
                Rectangle()
                    .fill(.black)
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

private struct MemorySpanView: View {
    let startMinutes: Int
    let durationMinutes: Int

    var body: some View {
        GeometryReader { geometry in
            let totalMinutes = 24 * 60
            let width = geometry.size.width
            let startX = width * CGFloat(startMinutes) / CGFloat(totalMinutes)
            let spanWidth = width * CGFloat(durationMinutes) / CGFloat(totalMinutes)

            Circle()
                .fill(.blue.opacity(0.5))
                .frame(width: spanWidth, height: 40)
                .offset(x: startX)
        }
    }
}

#Preview {
    TimeBoxCountView(spans: [(300, 20), (600, 60)])
}
