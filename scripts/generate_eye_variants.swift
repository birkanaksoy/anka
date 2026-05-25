#!/usr/bin/env swift
import AppKit
import CoreText

let pixelSize: Int = 1024

func makeContext() -> (NSBitmapImageRep, CGContext, CGFloat) {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixelSize, pixelsHigh: pixelSize,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    ) else { fatalError() }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    return (rep, NSGraphicsContext.current!.cgContext, CGFloat(pixelSize))
}

func savePNG(_ rep: NSBitmapImageRep, to path: String) {
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
    print("  ✓ \(path)")
}

let outDir = "icon-options"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

// MARK: - Shared building blocks

func darkPhoenixBackground(_ ctx: CGContext, size: CGFloat) {
    // Deep ember background
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            NSColor(srgbRed: 0.22, green: 0.04, blue: 0.04, alpha: 1).cgColor,
            NSColor(srgbRed: 0.04, green: 0.01, blue: 0.02, alpha: 1).cgColor
        ] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: size), end: CGPoint(x: 0, y: 0), options: [])
    // Golden radial glow behind the eye
    let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            NSColor(srgbRed: 1.0, green: 0.65, blue: 0.20, alpha: 0.45).cgColor,
            NSColor(srgbRed: 0.95, green: 0.30, blue: 0.05, alpha: 0).cgColor
        ] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(glow,
        startCenter: CGPoint(x: size/2, y: size/2), startRadius: 0,
        endCenter: CGPoint(x: size/2, y: size/2), endRadius: size*0.55, options: [])
}

/// Sharper raptor almond eye outline.
/// `tilt` rotates the eye for the hawk-like hooded look.
func raptorEyePath(center: CGPoint, width: CGFloat, height: CGFloat, hood: CGFloat = 0.4) -> CGPath {
    // hood: how much the upper lid arches downward at the inner corner
    let p = CGMutablePath()
    let leftCorner = CGPoint(x: center.x - width/2, y: center.y)
    let rightCorner = CGPoint(x: center.x + width/2, y: center.y)

    // Upper lid (more hooded / raptor)
    p.move(to: leftCorner)
    p.addCurve(to: rightCorner,
        control1: CGPoint(x: center.x - width*0.25, y: center.y - height*0.55 * (1 + hood*0.3)),
        control2: CGPoint(x: center.x + width*0.10, y: center.y - height*0.55))
    // Lower lid (gentler)
    p.addCurve(to: leftCorner,
        control1: CGPoint(x: center.x + width*0.15, y: center.y + height*0.45),
        control2: CGPoint(x: center.x - width*0.30, y: center.y + height*0.45))
    return p
}

func drawIris(_ ctx: CGContext, center: CGPoint, radius: CGFloat,
              outer: NSColor, mid: NSColor, inner: NSColor) {
    // Outer ring
    ctx.beginPath()
    ctx.setFillColor(outer.cgColor)
    ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()
    // Mid
    ctx.beginPath()
    ctx.setFillColor(mid.cgColor)
    ctx.addArc(center: center, radius: radius*0.78, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()
    // Inner blooming
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [inner.cgColor, mid.withAlphaComponent(0).cgColor] as CFArray,
        locations: [0, 1])!
    ctx.drawRadialGradient(grad,
        startCenter: center, startRadius: 0,
        endCenter: center, endRadius: radius*0.78, options: [])

    // Radial striations (iris fibers)
    ctx.setStrokeColor(outer.withAlphaComponent(0.55).cgColor)
    ctx.setLineWidth(radius * 0.04)
    let lines = 28
    for i in 0..<lines {
        let a = Double(i) * .pi * 2 / Double(lines)
        let x1 = center.x + CGFloat(cos(a)) * radius * 0.30
        let y1 = center.y + CGFloat(sin(a)) * radius * 0.30
        let x2 = center.x + CGFloat(cos(a)) * radius * 0.78
        let y2 = center.y + CGFloat(sin(a)) * radius * 0.78
        ctx.beginPath()
        ctx.move(to: CGPoint(x: x1, y: y1))
        ctx.addLine(to: CGPoint(x: x2, y: y2))
        ctx.strokePath()
    }
}

func drawPupil(_ ctx: CGContext, center: CGPoint, radius: CGFloat, withFlame: Bool = false) {
    ctx.beginPath()
    ctx.setFillColor(NSColor(srgbRed: 0.02, green: 0.01, blue: 0.02, alpha: 1).cgColor)
    ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()

    if withFlame {
        // Small flame reflection inside pupil
        let flame = CGMutablePath()
        let h = radius * 0.85
        let w = radius * 0.35
        flame.move(to: CGPoint(x: center.x, y: center.y + h/2))
        flame.addQuadCurve(to: CGPoint(x: center.x, y: center.y - h/2),
            control: CGPoint(x: center.x - w, y: center.y))
        flame.addQuadCurve(to: CGPoint(x: center.x, y: center.y + h/2),
            control: CGPoint(x: center.x + w, y: center.y))
        ctx.addPath(flame)
        let fg = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                NSColor(srgbRed: 1.0, green: 0.95, blue: 0.55, alpha: 1).cgColor,
                NSColor(srgbRed: 1.0, green: 0.45, blue: 0.10, alpha: 1).cgColor
            ] as CFArray, locations: [0, 1])!
        ctx.saveGState()
        ctx.addPath(flame); ctx.clip()
        ctx.drawLinearGradient(fg,
            start: CGPoint(x: center.x, y: center.y - h/2),
            end: CGPoint(x: center.x, y: center.y + h/2), options: [])
        ctx.restoreGState()
    }

    // Tiny specular highlight
    ctx.beginPath()
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.9).cgColor)
    ctx.addArc(
        center: CGPoint(x: center.x - radius*0.4, y: center.y - radius*0.4),
        radius: radius*0.16, startAngle: 0, endAngle: .pi*2, clockwise: false)
    ctx.fillPath()
}

// MARK: - Variant 07: Raptor Anka — sharp golden eye, no extras

func variantRaptorBasic() {
    let (rep, ctx, size) = makeContext()
    darkPhoenixBackground(ctx, size: size)

    let center = CGPoint(x: size/2, y: size/2)
    let eyeW = size * 0.78
    let eyeH = size * 0.40

    let eye = raptorEyePath(center: center, width: eyeW, height: eyeH, hood: 0.5)

    // Sclera (warm cream)
    ctx.addPath(eye)
    ctx.setFillColor(NSColor(srgbRed: 0.98, green: 0.88, blue: 0.55, alpha: 1).cgColor)
    ctx.fillPath()

    // Clip to eye for iris
    ctx.saveGState()
    ctx.addPath(eye); ctx.clip()
    drawIris(ctx, center: center, radius: size*0.20,
        outer: NSColor(srgbRed: 0.55, green: 0.15, blue: 0.05, alpha: 1),
        mid:   NSColor(srgbRed: 0.95, green: 0.55, blue: 0.10, alpha: 1),
        inner: NSColor(srgbRed: 1.0,  green: 0.85, blue: 0.30, alpha: 1))
    drawPupil(ctx, center: center, radius: size*0.075)
    ctx.restoreGState()

    // Heavy upper lid outline (raptor brow)
    ctx.addPath(eye)
    ctx.setStrokeColor(NSColor(srgbRed: 0.15, green: 0.03, blue: 0.02, alpha: 1).cgColor)
    ctx.setLineWidth(size * 0.018)
    ctx.strokePath()

    savePNG(rep, to: "\(outDir)/07-anka-eye-raptor.png")
}

// MARK: - Variant 08: Eye with flame reflection in pupil

func variantFlameReflection() {
    let (rep, ctx, size) = makeContext()
    darkPhoenixBackground(ctx, size: size)

    let center = CGPoint(x: size/2, y: size/2)
    let eyeW = size * 0.75
    let eyeH = size * 0.42
    let eye = raptorEyePath(center: center, width: eyeW, height: eyeH, hood: 0.6)

    ctx.addPath(eye)
    ctx.setFillColor(NSColor(srgbRed: 1.0, green: 0.92, blue: 0.65, alpha: 1).cgColor)
    ctx.fillPath()

    ctx.saveGState()
    ctx.addPath(eye); ctx.clip()
    drawIris(ctx, center: center, radius: size*0.22,
        outer: NSColor(srgbRed: 0.50, green: 0.10, blue: 0.04, alpha: 1),
        mid:   NSColor(srgbRed: 0.95, green: 0.40, blue: 0.08, alpha: 1),
        inner: NSColor(srgbRed: 1.0,  green: 0.80, blue: 0.25, alpha: 1))
    drawPupil(ctx, center: center, radius: size*0.085, withFlame: true)
    ctx.restoreGState()

    ctx.addPath(eye)
    ctx.setStrokeColor(NSColor(srgbRed: 0.18, green: 0.04, blue: 0.02, alpha: 1).cgColor)
    ctx.setLineWidth(size * 0.020)
    ctx.strokePath()

    savePNG(rep, to: "\(outDir)/08-anka-eye-flame.png")
}

// MARK: - Variant 09: Eye with flame "lashes" (small flames above the eye)

func variantFlameLashes() {
    let (rep, ctx, size) = makeContext()
    darkPhoenixBackground(ctx, size: size)

    let center = CGPoint(x: size/2, y: size/2 + size*0.05)
    let eyeW = size * 0.72
    let eyeH = size * 0.38
    let eye = raptorEyePath(center: center, width: eyeW, height: eyeH, hood: 0.55)

    // Flame plumes above the eye
    for i in 0..<7 {
        let t = Double(i) / 6.0
        let x = center.x - eyeW/2 + eyeW * CGFloat(t)
        let baseY = center.y - eyeH*0.55
        let height = size * (0.10 + 0.08 * sin(t * .pi))
        let width = size * 0.04
        let flame = CGMutablePath()
        flame.move(to: CGPoint(x: x, y: baseY))
        flame.addQuadCurve(to: CGPoint(x: x, y: baseY - height),
            control: CGPoint(x: x - width, y: baseY - height*0.5))
        flame.addQuadCurve(to: CGPoint(x: x, y: baseY),
            control: CGPoint(x: x + width, y: baseY - height*0.5))
        ctx.addPath(flame)
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                NSColor(srgbRed: 1.0, green: 0.85, blue: 0.30, alpha: 0.95).cgColor,
                NSColor(srgbRed: 0.95, green: 0.30, blue: 0.05, alpha: 0).cgColor
            ] as CFArray, locations: [0, 1])!
        ctx.saveGState()
        ctx.addPath(flame); ctx.clip()
        ctx.drawLinearGradient(g,
            start: CGPoint(x: x, y: baseY),
            end: CGPoint(x: x, y: baseY - height), options: [])
        ctx.restoreGState()
    }

    ctx.addPath(eye)
    ctx.setFillColor(NSColor(srgbRed: 0.98, green: 0.88, blue: 0.55, alpha: 1).cgColor)
    ctx.fillPath()

    ctx.saveGState()
    ctx.addPath(eye); ctx.clip()
    drawIris(ctx, center: center, radius: size*0.19,
        outer: NSColor(srgbRed: 0.50, green: 0.12, blue: 0.05, alpha: 1),
        mid:   NSColor(srgbRed: 0.95, green: 0.50, blue: 0.10, alpha: 1),
        inner: NSColor(srgbRed: 1.0,  green: 0.85, blue: 0.30, alpha: 1))
    drawPupil(ctx, center: center, radius: size*0.072)
    ctx.restoreGState()

    ctx.addPath(eye)
    ctx.setStrokeColor(NSColor(srgbRed: 0.15, green: 0.03, blue: 0.02, alpha: 1).cgColor)
    ctx.setLineWidth(size * 0.018)
    ctx.strokePath()

    savePNG(rep, to: "\(outDir)/09-anka-eye-lashes.png")
}

// MARK: - Variant 10: Eye framed by curved feather strokes

func variantFeatherFramed() {
    let (rep, ctx, size) = makeContext()
    darkPhoenixBackground(ctx, size: size)

    let center = CGPoint(x: size/2, y: size/2)

    // Feather strokes above and below — like brow + cheek feathers
    let featherColor = NSColor(srgbRed: 0.95, green: 0.55, blue: 0.15, alpha: 0.85).cgColor
    ctx.setStrokeColor(featherColor)
    ctx.setLineCap(.round)

    // Upper feathers (arching down from above the eye)
    for i in 0..<11 {
        let t = Double(i) / 10.0
        let x = center.x - size*0.36 + size*0.72 * CGFloat(t)
        let topY = center.y - size*0.20 - size*0.25 * CGFloat(sin(t * .pi))
        let bottomY = center.y - size*0.20
        ctx.setLineWidth(size * 0.012 * CGFloat(0.6 + 0.4 * sin(t * .pi)))
        ctx.beginPath()
        ctx.move(to: CGPoint(x: x, y: topY))
        ctx.addQuadCurve(to: CGPoint(x: x + size*0.02, y: bottomY),
            control: CGPoint(x: x + size*0.01, y: (topY + bottomY) / 2))
        ctx.strokePath()
    }
    // Lower feathers (cheek)
    ctx.setStrokeColor(NSColor(srgbRed: 0.65, green: 0.20, blue: 0.05, alpha: 0.7).cgColor)
    for i in 0..<9 {
        let t = Double(i) / 8.0
        let x = center.x - size*0.32 + size*0.64 * CGFloat(t)
        let topY = center.y + size*0.20
        let bottomY = center.y + size*0.20 + size*0.20 * CGFloat(sin(t * .pi))
        ctx.setLineWidth(size * 0.010 * CGFloat(0.6 + 0.4 * sin(t * .pi)))
        ctx.beginPath()
        ctx.move(to: CGPoint(x: x, y: topY))
        ctx.addQuadCurve(to: CGPoint(x: x + size*0.02, y: bottomY),
            control: CGPoint(x: x + size*0.01, y: (topY + bottomY) / 2))
        ctx.strokePath()
    }

    // Eye
    let eyeW = size * 0.62
    let eyeH = size * 0.34
    let eye = raptorEyePath(center: center, width: eyeW, height: eyeH, hood: 0.5)

    ctx.addPath(eye)
    ctx.setFillColor(NSColor(srgbRed: 0.98, green: 0.88, blue: 0.55, alpha: 1).cgColor)
    ctx.fillPath()

    ctx.saveGState()
    ctx.addPath(eye); ctx.clip()
    drawIris(ctx, center: center, radius: size*0.16,
        outer: NSColor(srgbRed: 0.50, green: 0.10, blue: 0.04, alpha: 1),
        mid:   NSColor(srgbRed: 0.95, green: 0.45, blue: 0.10, alpha: 1),
        inner: NSColor(srgbRed: 1.0,  green: 0.85, blue: 0.30, alpha: 1))
    drawPupil(ctx, center: center, radius: size*0.060, withFlame: true)
    ctx.restoreGState()

    ctx.addPath(eye)
    ctx.setStrokeColor(NSColor(srgbRed: 0.15, green: 0.03, blue: 0.02, alpha: 1).cgColor)
    ctx.setLineWidth(size * 0.016)
    ctx.strokePath()

    savePNG(rep, to: "\(outDir)/10-anka-eye-feathered.png")
}

variantRaptorBasic()
variantFlameReflection()
variantFlameLashes()
variantFeatherFramed()
print("\nAnka-eye variants ready in \(outDir)/")
