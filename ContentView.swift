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
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let originalSize = CGSize(width: 88.29, height: 80.5)
        let scale = min(rect.width / originalSize.width, rect.height / originalSize.height)

        let points = [
            CGPoint(x: 45.25, y: 0),
            CGPoint(x: 61.13, y: 23),
            CGPoint(x: 88.29, y: 30.75),
            CGPoint(x: 70.95, y: 52.71),
            CGPoint(x: 71.85, y: 80.5),
            CGPoint(x: 45.25, y: 71.07),
            CGPoint(x: 18.65, y: 80.5),
            CGPoint(x: 19.55, y: 52.71),
            CGPoint(x: 2.21, y: 30.75),
            CGPoint(x: 29.37, y: 23)
        ]

        let scaledPoints = points.map { CGPoint(x: $0.x * scale, y: $0.y * scale) }

        path.move(to: scaledPoints[0])
        for point in scaledPoints.dropFirst() {
            path.addLine(to: point)
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
