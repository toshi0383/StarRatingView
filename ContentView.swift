import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            StarRatingView(rating: 0) { value in}
                .frame(height: 60)
            StarRatingView(rating: 2.5) { value in}
                .frame(height: 60)
            StarRatingView(rating: 5) { value in}
                .frame(height: 60)
            StarRatingView(rating: 5, spacing: 10) { value in}
                .frame(height: 100)
            StarRatingView(rating: 5, spacing: 10) { value in}
                .frame(height: 300)
        }
    }
}

struct StarRatingView: View {
    @State private var rating: Float
    private let spacing: CGFloat
    var onChangeValue: (Float) -> Void

    init(rating: Float = 2.5, spacing: CGFloat = 5, onChangeValue: @escaping (Float) -> Void) {
        self.rating = rating
        self.spacing = spacing
        self.onChangeValue = onChangeValue
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                ForEach(0..<5) { index in
                    starType(for: index)
                        .onTapGesture {
                            updateRating(at: index)
                        }
                }
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    let step = Float(geometry.size.width / 10)
                    let newRating = max(min(Float(value.location.x) / step * 0.5, 5.0), 0.0)
                    updateRating(value: newRating)
                }))
        }
        .aspectRatio(5, contentMode: .fit)
    }

    private func starType(for index: Int) -> some View {
        let isHalf = rating - Float(index) > 0 && rating - Float(index) < 1
        return Group {
            if index < Int(rating) {
                FullStar()
                    .foregroundColor(.yellow)
            } else if isHalf {
                HalfStar()
            } else {
                EmptyStar()
                    .foregroundColor(.gray)
            }
        }
    }

    private func updateRating(value: Float) {
        rating = (value * 2).rounded() / 2
        onChangeValue(rating)
    }

    private func updateRating(at index: Int) {
        let newRating = Float(index + 1)
        rating = rating == newRating ? 0 : newRating
        onChangeValue(rating)
    }
}

struct FullStar: Shape {
    func path(in rect: CGRect) -> Path {
        StarShape().path(in: rect)
    }
}

struct HalfStar: View {
    var body: some View {
        ZStack(alignment: .center) {
            EmptyStar()
                .foregroundColor(.yellow)
            FullStar()
                .foregroundColor(.gray)
                .mask(alignment: .center) {
                    HStack(spacing: 0) {
                        Color.clear
                        Rectangle()
                    }
                }
        }
    }
}

struct EmptyStar: Shape {
    func path(in rect: CGRect) -> Path {
        StarShape().path(in: rect)
    }
}
struct StarShape: Shape {
    var points: Int = 5
    var innerRatio: CGFloat = 0.5 // The ratio of the inner radius to the outer radius

    func path(in rect: CGRect) -> Path {
        let drawPoints = points * 2
        let outerRadius: CGFloat = min(rect.size.width, rect.size.height) / 2
        let innerRadius: CGFloat = outerRadius * innerRatio
        let center = CGPoint(x: rect.midX, y: rect.midY)

        var path = Path()

        // Start from the top
        let startAngle = (-CGFloat.pi / 2)
        let angleIncrement = .pi / CGFloat(points)

        for i in 0..<drawPoints {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = startAngle + (angleIncrement * CGFloat(i))

            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )

            if i == 0 {
                path.move(to: point) // move to the start point
            } else {
                path.addLine(to: point) // draw line to next point
            }
        }

        path.closeSubpath()
        return path
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
