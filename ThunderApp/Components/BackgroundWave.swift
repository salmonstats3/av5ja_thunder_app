//
//  BackgroundWave.swift
//  ThunderApp
//
//  Created by devonly on 2024/06/11.
//  Copyright © 2024 Magi. All rights reserved.
//

import SwiftUI

struct BackgroundWave: View {
    @Environment(\.colorScheme) var colorScheme
    @State var offset = Angle(degrees: 0)
    @State var isAnimating = false
    var backgroundColor: Color { colorScheme == .dark ? .black : .white }

    var body: some View {
        GeometryReader(content: { geometry in
            ZStack(
                alignment: .top,
                content: {
                    backgroundColor.edgesIgnoringSafeArea(.all)
                    Wave(startAngle: Angle(degrees: 0), offset: offset / 2)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: geometry.frame(in: .local).width, height: geometry.frame(in: .local).height * 4 / 5 + 10)
                    Wave(startAngle: Angle(degrees: 0), offset: offset)
                        .fill(Color.blue.opacity(0.5))
                        .frame(width: geometry.frame(in: .local).width, height: geometry.frame(in: .local).height * 4 / 5)
                    Wave(startAngle: Angle(degrees: 40), offset: -offset)
                        .fill(Color.blue.opacity(0.9))
                        .frame(width: geometry.frame(in: .local).width, height: geometry.frame(in: .local).height * 4 / 5)
                }
            )
        }).edgesIgnoringSafeArea(.all).onAppear(perform: {
            isAnimating.toggle()
            if isAnimating {
                withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: false)) {
                    offset = Angle(degrees: 720)
                }
            }
        }).onDisappear(perform: { isAnimating.toggle() })
    }
}

struct Wave: Shape {
    let graphWidth: CGFloat = 0.8
    let waveHeight: CGFloat = 30
    /// 初期の位相ズレ
    let startAngle: Angle
    /// アニメーションのためのオフセット
    var offset = Angle(degrees: 0)

    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let offsetValue: CGFloat = 40.0
        path.move(to: CGPoint(x: rect.maxX + offsetValue, y: rect.maxY - waveHeight))
        path.addLine(to: CGPoint(x: rect.maxX + offsetValue, y: 0))
        path.addLine(to: CGPoint(x: 0 - offsetValue, y: 0))
        path.addLine(to: CGPoint(x: 0 - offsetValue, y: rect.maxY - waveHeight))

        for angle in stride(from: 0.0, to: 480.0, by: 5) {
            let theta: Double = Angle(degrees: startAngle.degrees + angle + offset.degrees).radians
            let x = CGFloat(angle / 360.0) * (rect.width)
            let y = rect.maxY + CGFloat(sin(theta)) * waveHeight / 2 - waveHeight / 2
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    BackgroundWave()
}
