import SwiftUI
import AVFoundation

/*
 * AudioPlayer made by Karin Prater
 * https://www.swiftyplace.com/
 * https://www.youtube.com/watch?v=HNAhPXOhZnY
*/
class AudioPlayer: ObservableObject {
    private var player = AVAudioPlayer()
    
    @Published var isPlaying: Bool = false
    let volume: Float
    
    init(name: String, type: String, volume: Float = 1) {
        self.volume = volume
        if let url = Bundle.main.url(forResource: name, withExtension: type) {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.setVolume(volume, fadeDuration: 0.3)
            } catch {
                print("Error getting audio")
            }
        }
    }
    
    func start(duration: Double = 0) {
        player.setVolume(volume, fadeDuration: duration)
        isPlaying = true
        player.play()
    }
    
    func pause() {
        isPlaying = false
        player.pause()
    }
    
    func pauseSmoothly(duration: Double = 0) {
        player.setVolume(0, fadeDuration: duration)
    }
    
    func toggle() {
        if isPlaying {
            pauseSmoothly(duration: 0.5)
        } else {
            start()
        }
    }
}
/*
 * IntSlider adapted from:
 * https://stackoverflow.com/questions/65736518/how-do-i-create-a-slider-in-swiftui-for-an-int-type-property
*/
struct IntSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let onSubmit: () -> Void
    
    var body: some View {
        let adjustedValue = Binding<Double>(
            get: { Double(self.value) },
            set: { self.value = Int($0) }
        )
        return Slider(
            value: adjustedValue,
            in: Double(range.lowerBound)...Double(range.upperBound),
            step: Double(step),
            onEditingChanged: { editing in
                if !editing {
                    self.onSubmit()
                }
            }
        )
    }
}

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

func compareValuesInt(value1: Int, value2: Int, threshold: Int) -> Bool {
    return value1 == value2 || abs(value1 - value2) <= threshold
}

func compareValuesDouble(value1: Double, value2: Double, threshold: Double) -> Bool {
    return value1 == value2 || abs(value1 - value2) <= threshold
}

func compareValuesDoubleHundred(value1: Double, value2: Double, threshold: Double) -> Bool {
    return value1 == value2 || abs(value1 - value2) <= threshold
}

func comparePoints(point1: CGPoint, point2: CGPoint, threshold: CGFloat) -> Bool {
    let xDifference = abs(point1.x - point2.x)
    let yDifference = abs(point1.y - point2.y)
    
    return xDifference <= threshold && yDifference <= threshold
}

func compareSizes(size1: CGSize, size2: CGSize, threshold: CGFloat) -> Bool {
    let widthDifference = abs(size1.width - size2.width)
    let heightDifference = abs(size1.height - size2.height)
    
    return widthDifference <= threshold && heightDifference <= threshold
}

// Euclidean Distance
func distanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> CGFloat {
    let dx = point1.x - point2.x
    let dy = point1.y - point2.y
    return sqrt(dx * dx + dy * dy)
}

// Distance to center is less than the radius
func constrainPointToCircle(center: CGPoint, radius: CGFloat, point: CGPoint) -> CGPoint {
    let distance = distanceBetweenPoints(point1: center, point2: point)
    if distance <= radius {
        return point
    } else {
        let ratio = radius / distance
        let x = center.x + (point.x - center.x) * ratio
        let y = center.y + (point.y - center.y) * ratio
        return CGPoint(x: x, y: y)
    }
}

func angleBetweenPoints(center: CGPoint, point: CGPoint) -> Double {
    let dx = point.x - center.x
    let dy = point.y - center.y
    let angle = atan2(dy, dx)
    return angle >= 0 ? Double(angle) : Double(angle) + 2 * Double.pi
}

func radiansToDegrees(_ radians: Double) -> Double {
    return radians * 180 / Double.pi
}
