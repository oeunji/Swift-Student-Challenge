import SwiftUI

struct VisionModeSelectView: View {
    var body: some View {
        ZStack {
            gridBackground
            VStack(spacing: 18) {
                Spacer()
                
                Text("Choose a Vision Mode")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .padding(.top, 12)
                
                Spacer()

                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        modeCard(
                            title: "Protanopia",
                            subtitle: "Reduced sensitivity to red.",
                            mode: .protanopia
                        )
                        modeCard(
                            title: "Deuteranopia",
                            subtitle: "Reduced sensitivity to green.",
                            mode: .deuteranopia
                        )
                    }
                    HStack(spacing: 14) {
                        modeCard(
                            title: "Tritanopia",
                            subtitle: "Reduced sensitivity to blue.",
                            mode: .tritanopia
                        )
                        modeCard(
                            title: "Achromatopsia",
                            subtitle: "No color perception.",
                            mode: .achromatopsia
                        )
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private var gridBackground: some View {
        Color.white
            .ignoresSafeArea()
            .overlay(
                GeometryReader { proxy in
                    let spacing: CGFloat = 30
                    let size = proxy.size
                    Path { path in
                        var x: CGFloat = 0
                        while x <= size.width {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                            x += spacing
                        }
                        var y: CGFloat = 0
                        while y <= size.height {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                            y += spacing
                        }
                    }
                    .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                }
            )
    }

    private func modeCard(title: String, subtitle: String, mode: VisionMode) -> some View {
        NavigationLink(destination: ColorblindDrawView(selectedMode: mode)) {
            VStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(red: 0.1647, green: 0.0275, blue: 0.0275))
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(red: 0.4275, green: 0.2706, blue: 0.2706))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: 400, minHeight: 200, alignment: .center)
            .padding(.horizontal, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(red: 0.8471, green: 0.8157, blue: 0.8157), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
