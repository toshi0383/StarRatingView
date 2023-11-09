import SwiftUI

struct ContentView: View {
    @State var innerRadiusRatio: CGFloat = 0.5
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
            StarRatingView(rating: 5, spacing: 10, innerRadiusRatio: innerRadiusRatio) { value in}
                .frame(height: 300)

            Slider(value: $innerRadiusRatio, in: (0.0...1.0), label: { Text(verbatim: "innerRadiusRatio") })
                .padding()
                .tint(.black)
        }
    }
}

struct StarRatingView: View {
    @State private var rating: Float
    private let spacing: CGFloat
    var innerRadiusRatio: CGFloat
    var onChangeValue: (Float) -> Void

    init(
        rating: Float = 2.5,
        spacing: CGFloat = 5,
        innerRadiusRatio: CGFloat = 0.5,
        onChangeValue: @escaping (Float) -> Void
    ) {
        self.rating = rating
        self.spacing = spacing
        self.innerRadiusRatio = innerRadiusRatio
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
                StarShape(innerRatio: innerRadiusRatio)
                    .foregroundColor(.yellow)
            } else if isHalf {
                halfStar
            } else {
                StarShape(innerRatio: innerRadiusRatio)
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

    @ViewBuilder
    private var halfStar: some View {
        ZStack(alignment: .center) {
            StarShape(innerRatio: innerRadiusRatio)
                .foregroundColor(.yellow)
            StarShape(innerRatio: innerRadiusRatio)
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
