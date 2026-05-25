#!/usr/bin/env swift
import AppKit
import CoreText

let pixelSize: Int = 1024

func makeContext() -> (NSBitmapImageRep, CGContext, CGFloat) {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { fatalError("alloc fail") }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    return (rep, NSGraphicsContext.current!.cgContext, CGFloat(pixelSize))
}

func savePNG(_ rep: NSBitmapImageRep, to path: String) {
    NSGraphicsContext.restoreGraphicsState()
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: path))
    print("  ✓ \(path)")
}

let outDir = "icon-options"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

// MARK: - Helpers

func fillBackground(_ ctx: CGContext, size: CGFloat, top: NSColor, bottom: NSColor) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [top.cgColor, bottom.cgColor] as CFArray,
        locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: size), end: CGPoint(x: 0, y: 0), options: [])
}

func radialGlow(_ ctx: CGContext, size: CGFloat, color: NSColor, alpha: CGFloat = 0.5, scale: CGFloat = 0.55) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [color.withAlphaComponent(alpha).cgColor, color.withAlphaComponent(0).cgColor] as CFArray,
        locations: [0, 1])!
    ctx.drawRadialGradient(g,
        startCenter: CGPoint(x: size/2, y: size/2), startRadius: 0,
        endCenter: CGPoint(x: size/2, y: size/2), endRadius: size * scale,
        options: [])
}

// MARK: - Variant 1: Brass "A" (current)

func variant1() {
    let (rep, ctx, size) = makeContext()
    fillBackground(ctx, size: size,
        top: NSColor(srgbRed: 0.18, green: 0.10, blue: 0.06, alpha: 1),
        bottom: NSColor(srgbRed: 0.05, green: 0.03, blue: 0.04, alpha: 1))
    radialGlow(ctx, size: size, color: NSColor(srgbRed: 0.95, green: 0.70, blue: 0.20, alpha: 1), alpha: 0.45)
    let font = NSFont(name: "Times New Roman Bold", size: size * 0.62)!
    let str = NSAttributedString(string: "A", attributes: [
        .font: font,
        .foregroundColor: NSColor(srgbRed: 0.95, green: 0.72, blue: 0.22, alpha: 1)
    ])
    let line = CTLineCreateWithAttributedString(str)
    let b = CTLineGetImageBounds(line, ctx)
    ctx.textPosition = CGPoint(x: (size - b.width)/2 - b.minX, y: (size - b.height)/2 - b.minY)
    CTLineDraw(line, ctx)
    savePNG(rep, to: "\(outDir)/01-brass-letter.png")
}

// MARK: - Variant 2: Phoenix silhouette + flame

func variant2() {
    let (rep, ctx, size) = makeContext()
    fillBackground(ctx, size: size,
        top: NSColor(srgbRed: 0.20, green: 0.05, blue: 0.05, alpha: 1),
        bottom: NSColor(srgbRed: 0.05, green: 0.02, blue: 0.02, alpha: 1))

    // Flame backdrop
    let flame = CGMutablePath()
    flame.move(to: CGPoint(x: size/2, y: size*0.05))
    flame.addCurve(to: CGPoint(x: size/2, y: size*0.78),
        control1: CGPoint(x: size*0.05, y: size*0.30),
        control2: CGPoint(x: size*0.35, y: size*0.55))
    flame.addCurve(to: CGPoint(x: size/2, y: size*0.05),
        control1: CGPoint(x: size*0.65, y: size*0.55),
        control2: CGPoint(x: size*0.95, y: size*0.30))
    ctx.saveGState()
    ctx.addPath(flame)
    ctx.clip()
    let flameGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            NSColor(srgbRed: 1.0, green: 0.85, blue: 0.40, alpha: 0.9).cgColor,
            NSColor(srgbRed: 0.95, green: 0.40, blue: 0.10, alpha: 0.95).cgColor,
            NSColor(srgbRed: 0.45, green: 0.10, blue: 0.05, alpha: 0).cgColor
        ] as CFArray, locations: [0, 0.5, 1])!
    ctx.drawLinearGradient(flameGrad,
        start: CGPoint(x: size/2, y: size*0.05),
        end: CGPoint(x: size/2, y: size*0.78),
        options: [])
    ctx.restoreGState()

    // Bird silhouette (stylized phoenix)
    let bird = CGMutablePath()
    bird.move(to: CGPoint(x: size*0.50, y: size*0.78))
    // Body
    bird.addQuadCurve(to: CGPoint(x: size*0.30, y: size*0.55),
        control: CGPoint(x: size*0.32, y: size*0.72))
    // Left wing
    bird.addCurve(to: CGPoint(x: size*0.10, y: size*0.45),
        control1: CGPoint(x: size*0.20, y: size*0.65),
        control2: CGPoint(x: size*0.10, y: size*0.60))
    bird.addCurve(to: CGPoint(x: size*0.32, y: size*0.42),
        control1: CGPoint(x: size*0.15, y: size*0.30),
        control2: CGPoint(x: size*0.28, y: size*0.32))
    // Head
    bird.addCurve(to: CGPoint(x: size*0.55, y: size*0.25),
        control1: CGPoint(x: size*0.40, y: size*0.35),
        control2: CGPoint(x: size*0.48, y: size*0.28))
    // Crest
    bird.addLine(to: CGPoint(x: size*0.58, y: size*0.18))
    bird.addLine(to: CGPoint(x: size*0.60, y: size*0.25))
    bird.addLine(to: CGPoint(x: size*0.65, y: size*0.20))
    bird.addLine(to: CGPoint(x: size*0.65, y: size*0.30))
    // Right wing
    bird.addCurve(to: CGPoint(x: size*0.90, y: size*0.45),
        control1: CGPoint(x: size*0.72, y: size*0.32),
        control2: CGPoint(x: size*0.85, y: size*0.30))
    bird.addCurve(to: CGPoint(x: size*0.70, y: size*0.55),
        control1: CGPoint(x: size*0.90, y: size*0.60),
        control2: CGPoint(x: size*0.80, y: size*0.65))
    // Body close
    bird.addQuadCurve(to: CGPoint(x: size*0.50, y: size*0.78),
        control: CGPoint(x: size*0.68, y: size*0.72))
    bird.closeSubpath()

    ctx.addPath(bird)
    ctx.setFillColor(NSColor(srgbRed: 0.10, green: 0.03, blue: 0.02, alpha: 1).cgColor)
    ctx.fillPath()

    savePNG(rep, to: "\(outDir)/02-phoenix.png")
}

// MARK: - Variant 3: Crescent moon + flame (mythic emblem)

func variant3() {
    let (rep, ctx, size) = makeContext()
    fillBackground(ctx, size: size,
        top: NSColor(srgbRed: 0.10, green: 0.08, blue: 0.18, alpha: 1),
        bottom: NSColor(srgbRed: 0.04, green: 0.03, blue: 0.08, alpha: 1))
    radialGlow(ctx, size: size, color: NSColor(srgbRed: 1.0, green: 0.85, blue: 0.40, alpha: 1), alpha: 0.30)

    // Crescent moon
    let center = CGPoint(x: size/2, y: size/2)
    let r1 = size * 0.30
    let r2 = size * 0.26

    ctx.setFillColor(NSColor(srgbRed: 0.98, green: 0.85, blue: 0.45, alpha: 1).cgColor)
    ctx.beginPath()
    ctx.addArc(center: center, radius: r1, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()

    // Cut-out (slight offset to make crescent)
    ctx.setBlendMode(.destinationOut)
    ctx.beginPath()
    ctx.addArc(center: CGPoint(x: center.x + size*0.10, y: center.y + size*0.04),
        radius: r2, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()
    ctx.setBlendMode(.normal)

    // Small flame inside crescent
    let flame = CGMutablePath()
    let fx = center.x - size*0.05
    let fy = center.y
    flame.move(to: CGPoint(x: fx, y: fy + size*0.12))
    flame.addQuadCurve(to: CGPoint(x: fx, y: fy - size*0.10),
        control: CGPoint(x: fx - size*0.05, y: fy))
    flame.addQuadCurve(to: CGPoint(x: fx, y: fy + size*0.12),
        control: CGPoint(x: fx + size*0.05, y: fy))
    ctx.addPath(flame)
    ctx.setFillColor(NSColor(srgbRed: 1.0, green: 0.55, blue: 0.15, alpha: 0.95).cgColor)
    ctx.fillPath()

    savePNG(rep, to: "\(outDir)/03-crescent-flame.png")
}

// MARK: - Variant 4: Ottoman tile / geometric

func variant4() {
    let (rep, ctx, size) = makeContext()
    fillBackground(ctx, size: size,
        top: NSColor(srgbRed: 0.55, green: 0.18, blue: 0.18, alpha: 1),
        bottom: NSColor(srgbRed: 0.30, green: 0.08, blue: 0.10, alpha: 1))

    let center = CGPoint(x: size/2, y: size/2)
    let gold = NSColor(srgbRed: 0.95, green: 0.80, blue: 0.35, alpha: 1).cgColor

    // Outer ring
    ctx.setStrokeColor(gold)
    ctx.setLineWidth(size * 0.012)
    ctx.beginPath()
    ctx.addArc(center: center, radius: size*0.42, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.strokePath()

    // Inner ring
    ctx.beginPath()
    ctx.addArc(center: center, radius: size*0.36, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.strokePath()

    // 8-pointed star
    let star = CGMutablePath()
    let outerR = size * 0.30
    let innerR = size * 0.16
    let points = 8
    for i in 0..<(points * 2) {
        let angle = .pi/2 + Double(i) * .pi / Double(points)
        let r = (i % 2 == 0) ? outerR : innerR
        let x = center.x + CGFloat(cos(angle)) * r
        let y = center.y + CGFloat(sin(angle)) * r
        if i == 0 { star.move(to: CGPoint(x: x, y: y)) }
        else { star.addLine(to: CGPoint(x: x, y: y)) }
    }
    star.closeSubpath()
    ctx.addPath(star)
    ctx.setFillColor(gold)
    ctx.fillPath()

    // Center disc
    ctx.beginPath()
    ctx.setFillColor(NSColor(srgbRed: 0.30, green: 0.08, blue: 0.10, alpha: 1).cgColor)
    ctx.addArc(center: center, radius: size*0.10, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()

    // Inner dot
    ctx.beginPath()
    ctx.setFillColor(gold)
    ctx.addArc(center: center, radius: size*0.04, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()

    savePNG(rep, to: "\(outDir)/04-ottoman-star.png")
}

// MARK: - Variant 5: Eye of Anka (mystic)

func variant5() {
    let (rep, ctx, size) = makeContext()
    fillBackground(ctx, size: size,
        top: NSColor(srgbRed: 0.08, green: 0.10, blue: 0.22, alpha: 1),
        bottom: NSColor(srgbRed: 0.02, green: 0.02, blue: 0.05, alpha: 1))
    radialGlow(ctx, size: size, color: NSColor(srgbRed: 0.95, green: 0.75, blue: 0.30, alpha: 1), alpha: 0.35)

    let center = CGPoint(x: size/2, y: size/2)

    // Almond eye shape
    let eye = CGMutablePath()
    let eyeW = size * 0.65
    let eyeH = size * 0.32
    eye.move(to: CGPoint(x: center.x - eyeW/2, y: center.y))
    eye.addQuadCurve(to: CGPoint(x: center.x + eyeW/2, y: center.y),
        control: CGPoint(x: center.x, y: center.y - eyeH/2))
    eye.addQuadCurve(to: CGPoint(x: center.x - eyeW/2, y: center.y),
        control: CGPoint(x: center.x, y: center.y + eyeH/2))

    ctx.addPath(eye)
    ctx.setFillColor(NSColor(srgbRed: 0.95, green: 0.85, blue: 0.55, alpha: 1).cgColor)
    ctx.fillPath()

    // Iris
    ctx.beginPath()
    ctx.setFillColor(NSColor(srgbRed: 0.55, green: 0.20, blue: 0.10, alpha: 1).cgColor)
    ctx.addArc(center: center, radius: size*0.13, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()

    // Pupil
    ctx.beginPath()
    ctx.setFillColor(NSColor(srgbRed: 0.05, green: 0.02, blue: 0.02, alpha: 1).cgColor)
    ctx.addArc(center: center, radius: size*0.06, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()

    // Highlight
    ctx.beginPath()
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.85).cgColor)
    ctx.addArc(center: CGPoint(x: center.x - size*0.025, y: center.y - size*0.020),
        radius: size*0.020, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()

    // Outer outline
    ctx.addPath(eye)
    ctx.setStrokeColor(NSColor(srgbRed: 0.45, green: 0.25, blue: 0.10, alpha: 1).cgColor)
    ctx.setLineWidth(size * 0.008)
    ctx.strokePath()

    savePNG(rep, to: "\(outDir)/05-eye.png")
}

// MARK: - Variant 6: Feather mark (minimal)

func variant6() {
    let (rep, ctx, size) = makeContext()
    fillBackground(ctx, size: size,
        top: NSColor(srgbRed: 0.95, green: 0.88, blue: 0.78, alpha: 1),  // cream
        bottom: NSColor(srgbRed: 0.85, green: 0.72, blue: 0.55, alpha: 1)) // warm tan

    // Single elegant feather
    let center = CGPoint(x: size/2, y: size/2)
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y)
    ctx.rotate(by: -.pi/8)

    let feather = CGMutablePath()
    let h = size * 0.55
    let w = size * 0.16
    feather.move(to: CGPoint(x: 0, y: -h/2))
    feather.addQuadCurve(to: CGPoint(x: 0, y: h/2),
        control: CGPoint(x: w, y: 0))
    feather.addQuadCurve(to: CGPoint(x: 0, y: -h/2),
        control: CGPoint(x: -w, y: 0))

    ctx.addPath(feather)
    let featherGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            NSColor(srgbRed: 0.55, green: 0.15, blue: 0.10, alpha: 1).cgColor,
            NSColor(srgbRed: 0.85, green: 0.50, blue: 0.18, alpha: 1).cgColor
        ] as CFArray, locations: [0, 1])!
    ctx.saveGState()
    ctx.addPath(feather)
    ctx.clip()
    ctx.drawLinearGradient(featherGrad,
        start: CGPoint(x: 0, y: -h/2),
        end: CGPoint(x: 0, y: h/2),
        options: [])
    ctx.restoreGState()

    // Spine
    ctx.setStrokeColor(NSColor(srgbRed: 0.35, green: 0.08, blue: 0.04, alpha: 1).cgColor)
    ctx.setLineWidth(size * 0.012)
    ctx.beginPath()
    ctx.move(to: CGPoint(x: 0, y: -h/2))
    ctx.addLine(to: CGPoint(x: 0, y: h/2))
    ctx.strokePath()

    // Barbs
    ctx.setStrokeColor(NSColor(srgbRed: 0.35, green: 0.08, blue: 0.04, alpha: 0.4).cgColor)
    ctx.setLineWidth(size * 0.005)
    for i in 1...8 {
        let y = -h/2 + h * CGFloat(i) / 9
        let offset = w * (1.0 - abs(CGFloat(i) - 4.5) / 5.0) * 0.85
        ctx.beginPath()
        ctx.move(to: CGPoint(x: 0, y: y))
        ctx.addLine(to: CGPoint(x: offset, y: y - 12))
        ctx.move(to: CGPoint(x: 0, y: y))
        ctx.addLine(to: CGPoint(x: -offset, y: y - 12))
        ctx.strokePath()
    }

    ctx.restoreGState()
    savePNG(rep, to: "\(outDir)/06-feather.png")
}

variant1()
variant2()
variant3()
variant4()
variant5()
variant6()
print("\nAll variants written to \(outDir)/")
