import SwiftUI

private struct Particle: Identifiable {
    let id = UUID()
    let randomMaxRadius: CGFloat = .random(in: 150...300)
    let holdRadius: CGFloat = 40 * .random(in: 0.8...1.2)
    let randomAngle = Angle.degrees(Double.random(in: 0...360))
    let size: CGFloat = .random(in: 5...140)
    let initialOpacity: Double = .random(in: 0.01...0.2)
    let randomAnimationOffset: Double = .random(in: 0...20)
}

private struct ParticleGlowView: View {
    @ObservedObject var store: BreathingStore
    let particles: [Particle]
    let timelineDate: Date
    let center: CGPoint

    var body: some View {
        Canvas { context, size in
            let gatheredProgress = store.gatheredProgress
            let time = timelineDate.timeIntervalSince1970

            for particle in particles {
                var currentRadius: CGFloat
                var currentAngle = particle.randomAngle
                
                let shimmer = sin(time * .pi + particle.randomAnimationOffset * .pi)
                let dynamicOpacity = particle.initialOpacity * (0.7 + shimmer * 0.3)
                let dynamicSize = particle.size * (0.9 + shimmer * 0.1)

                if store.currentPhase == .hold {
                    currentRadius = particle.holdRadius
                    currentAngle += .degrees(time.truncatingRemainder(dividingBy: store.holdDuration) / store.holdDuration * 360)
                } else {
                    currentRadius = particle.holdRadius + (particle.randomMaxRadius - particle.holdRadius) * (1 - gatheredProgress)
                }
                
                let x = center.x + cos(currentAngle.radians) * currentRadius
                let y = center.y + sin(currentAngle.radians) * currentRadius
                
                let gradient = Gradient(colors: [Color.white.opacity(dynamicOpacity * 0.8), Color.white.opacity(0)])
                
                let particleRect = CGRect(x: x - dynamicSize / 2, y: y - dynamicSize / 2, width: dynamicSize, height: dynamicSize)
                context.fill(Ellipse().path(in: particleRect), with: .radialGradient(gradient, center: CGPoint(x: x, y: y), startRadius: 0, endRadius: dynamicSize / 2))
            }
        }
        .ignoresSafeArea()
        .opacity(store.hasStarted || store.isCompleted ? 1.0 : 0.0)
        .animation(store.currentAnimation, value: store.gatheredProgress)
    }
}

struct BreathingView: View {
    let onComplete: () -> Void
    
    @StateObject private var store: BreathingStore
    @State private var particles: [Particle] = []
    @State private var animationCenter: CGPoint = .zero
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        _store = StateObject(wrappedValue: BreathingStore(onComplete: onComplete))
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                backgroundGradient.ignoresSafeArea()
                
                ParticleGlowView(
                    store: store,
                    particles: particles,
                    timelineDate: timeline.date,
                    center: animationCenter
                )
                
                VStack(spacing: 0) {
                    headerText
                    Spacer()
                    breathingAnimationView(timeline: timeline)
                    Spacer()
                    bottomSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .onAppear(perform: setupParticles)
        .onDisappear(perform: store.stopBreathing)
    }
    
    private func setupParticles() {
        particles = (0..<40).map { _ in Particle() }
    }
    
    private func updateCenter(for geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        if frame.width > 0 && frame.height > 0 {
            self.animationCenter = CGPoint(x: frame.midX, y: frame.midY)
        }
    }
    
    private var headerText: some View {
        VStack(spacing: 16) {
            Text(localized: LocalizationKeys.Breathing.title)
                .font(.largeTitle).fontWeight(.bold).foregroundStyle(.white)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 12) {
                if !store.hasStarted {
                    Text(localized: LocalizationKeys.Breathing.instruction)
                        .font(.title3).fontWeight(.medium).foregroundStyle(.white.opacity(0.9))
                    Text(localized: LocalizationKeys.Breathing.focusMeditation)
                        .font(.body).foregroundStyle(.white.opacity(0.7))
                    Text(localized: LocalizationKeys.Breathing.startPractice)
                        .font(.caption).foregroundStyle(.white.opacity(0.6))
                } else if !store.isCompleted {
                    Text(localized: LocalizationKeys.Breathing.followRhythm)
                        .font(.title3).fontWeight(.medium).foregroundStyle(.white.opacity(0.9))
                    Text(localized: LocalizationKeys.Breathing.relaxBody)
                        .font(.body).foregroundStyle(.white.opacity(0.7))
                    let remaining = max(0, BreathingStore.totalCycles - store.currentCycle + 1)
                    Text(remaining > 0 ? LocalizationKeys.Breathing.remainingCycles.localized(with: remaining) : " ")
                        .font(.caption).foregroundStyle(.white.opacity(0.7))
                } else {
                    Text(localized: LocalizationKeys.Breathing.practiceComplete)
                        .font(.title3).fontWeight(.medium).foregroundStyle(.white)
                    Text(localized: LocalizationKeys.Breathing.enteringConnection)
                        .font(.body).foregroundStyle(.white.opacity(0.8))
                    Text(" ").font(.caption)
                }
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(minHeight: 120)
            .padding(.horizontal, 24)
        }
    }
    
    private func breathingAnimationView(timeline: TimelineViewDefaultContext) -> some View {
        ZStack {
            let gatheredProgress = store.gatheredProgress
            
            Group {
                Circle().fill(Color.blue.opacity(0.2)).frame(width: 250, height: 250).blur(radius: 90)
                    .scaleEffect(0.7 + (1 - gatheredProgress) * 0.7)
                nebulaView(color: .purple, rotation: Angle(degrees: timeline.date.timeIntervalSince1970 * 3), scale: 1.3, gatheredProgress: gatheredProgress)
                nebulaView(color: .blue, rotation: Angle(degrees: -timeline.date.timeIntervalSince1970 * 2.1), scale: 1.1, gatheredProgress: gatheredProgress)
            }
            .opacity(store.isCompleted ? 0.5 : 1.0)
            
            centralTextView
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear { updateCenter(for: geometry) }
                    .onChange(of: geometry.size) { updateCenter(for: geometry) }
            }
        )
    }
    
    private func nebulaView(color: Color, rotation: Angle, scale: CGFloat, gatheredProgress: Double) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Ellipse().fill(LinearGradient(colors: [color.opacity(0.4), color.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 150 + CGFloat(i * 35), height: 250 + CGFloat(i * 35))
                    .blur(radius: 40)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
        }
        .rotationEffect(rotation)
        .scaleEffect(scale * (0.7 + (1 - gatheredProgress) * 0.6))
        .opacity(0.5 + (1 - gatheredProgress) * 0.5)
        .animation(store.currentAnimation, value: gatheredProgress)
    }
    
    private var centralTextView: some View {
        ZStack {
            if !store.isCompleted {
                Text(store.breathingText)
                    .font(.largeTitle).fontWeight(.bold).foregroundStyle(.white)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    .shadow(color: .black.opacity(0.9), radius: 20, x: 0, y: 0)
            } else {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.white)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 140, height: 140)
                                .blur(radius: 40)
                                .scaleEffect(store.isCompleted ? 1.0 : 0.0)
                                .opacity(store.isCompleted ? 1 : 0)
                        )
                }
                .transition(.opacity.combined(with: .scale(scale: 1.2)))
            }
        }
        .animation(.easeInOut(duration: 0.6), value: store.isCompleted)
        .animation(.easeInOut(duration: 0.8), value: store.breathingText)
    }
    
    private var bottomSection: some View {
        VStack {
            if !store.hasStarted {
                Button(action: { store.startBreathing() }) {
                    buttonStyle(colors: [.orange, .red.opacity(0.8)], icon: "wind", text: LocalizationKeys.Breathing.Button.start.localized)
                }
            }
            
            Button(action: { store.completeBreathing(isSkipped: true) }) {
                Text(localized: LocalizationKeys.Common.Button.skip)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(10)
            }
            .opacity(store.isCompleted ? 0 : 1)
        }
        .padding(.horizontal, 40).frame(minHeight: 80)
    }
    
    private func buttonStyle(colors: [Color], icon: String, text: String) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
            .frame(height: 56)
            .overlay(
                HStack(spacing: 12) {
                    Image(systemName: icon).font(.title2)
                    Text(text).font(.headline).fontWeight(.semibold)
                }.foregroundStyle(.white)
            )
    }
    
    private var backgroundGradient: some View {
        LinearGradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.15, green: 0.15, blue: 0.2), Color(red: 0.2, green: 0.15, blue: 0.25)], startPoint: .top, endPoint: .bottom)
    }
}

private extension BreathingStore {
    var gatheredProgress: Double {
        if !hasStarted {
            return 0.0
        } else {
            switch currentPhase {
            case .inhale: return phaseProgress
            case .hold: return 1.0
            case .exhale: return phaseProgress
            }
        }
    }
    
    var currentAnimation: Animation {
        switch currentPhase {
        case .inhale: return .easeInOut(duration: inhaleDuration)
        case .hold: return .linear(duration: holdDuration)
        case .exhale: return .easeInOut(duration: exhaleDuration)
        }
    }
}

#Preview {
    BreathingView { print("Breathing completed") }
}
