import SwiftUI
import AVFoundation

struct MatchOpacity: View {
    @State private var targetOpacity: Double
    @State private var currentOpacity: Double = 0.5
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject private var cameraBrightnessDetector = CameraBrightnessDetector()
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")

    init (score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        _targetOpacity = State(initialValue: Double.random(in: 0.0...1.0))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Your guess was \(Int(currentOpacity))%" :
                    "Congratulations, you nailed it! 🎉" :
                    "Change the opacity to \(Int(targetOpacity))%"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .animation(.easeInOut, value: madeGuess)
            
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .frame(width: 200, height: 100)
                .foregroundColor(.blue.opacity(cameraBrightnessDetector.opacity))
        
            Button(action: {
//                if compareValuesDouble(value1: lightIntensityManager.lightIntensity, value2: targetOpacity, threshold: 0.1) && madeGuess == false {
//                    score += 1
//                }
                
                madeGuess = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    shouldSwitchView = true
                    cameraBrightnessDetector.stopSession()
                }
            }) {
                Text("Submit")
            }
            .padding()
            
        }
        .confettiCannon(counter: $score, num: 50)
        .onAppear {
            cameraBrightnessDetector.startSession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                currentOpacity = cameraBrightnessDetector.opacity
            }
        }
        .onDisappear {
            cameraBrightnessDetector.stopSession()
        }
        
    }
}
class CameraBrightnessDetector: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var opacity: Double = -1
    
    private var captureSession: AVCaptureSession?
    private var videoDevice: AVCaptureDevice?
    
    override init() {
        super.init()
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupCamera()
            self.captureSession?.startRunning()
        }
    }
    
    private func setupCamera() {
        DispatchQueue.main.async {
            self.captureSession = AVCaptureSession()
            
            guard let captureSession = self.captureSession,
                  let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            
            self.videoDevice = device
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let device = self.videoDevice else { return }
        
        // Check if device is fully initialized
        guard device.activeFormat.maxISO > 0 else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let context = CIContext()
        let extent = ciImage.extent
        
        var averageBrightness: Double = 0
        
        // Calculate average brightness of each pixel in the image
        for y in stride(from: 0, to: extent.height, by: 20) {
            for x in stride(from: 0, to: extent.width, by: 20) {
                let pixel = CGPoint(x: x, y: y)
                
                var pixelColor: CUnsignedChar = 0
                
                // Render the CIImage to a CGImage and extract the color of the pixel
                if let cgImage = context.createCGImage(ciImage, from: extent),
                   let data = cgImage.dataProvider?.data,
                   let pointer = CFDataGetBytePtr(data) {
                    let bytesPerPixel = 4
                    let bytesPerRow = cgImage.bytesPerRow
                    let pixelIndex = Int(pixel.y) * bytesPerRow + Int(pixel.x) * bytesPerPixel
                    
                    pixelColor = pointer[pixelIndex]
                }
                
                let brightness = Double(pixelColor) / 255.0
                
                averageBrightness += brightness
            }
        }
        
        averageBrightness /= Double(extent.width * extent.height / 400)
        let normalizedBrightness = 1.0 - averageBrightness
        
        DispatchQueue.main.async {
            self.opacity = normalizedBrightness
        }
    }
    
}
