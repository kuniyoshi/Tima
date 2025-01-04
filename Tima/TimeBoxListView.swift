import SwiftUI

struct TimeBoxListView: View {
    private let counts: [(String, Int)]

    init(_ counts: [(String, Int)]) {
        self.counts = counts
    }

    var body: some View {
        List {
            Section(header: Text("Daily TimeBoxes")) {
                ForEach(counts, id: \.0) { (date, count) in
                    HStack {
                        Text("\(date)")
                            .font(.headline)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0..<count, id: \.self) { _ in
                                Image(systemName: "circle.fill")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    TimeBoxListView([
        ("2025-01-03", 4),
        ("2025-01-02", 3),
        ("2025-01-01", 8)
    ])
}
