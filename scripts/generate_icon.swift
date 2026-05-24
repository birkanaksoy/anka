#!/usr/bin/env swift
import AppKit
import CoreText

// Renders Anka's placeholder app icon at 1024x1024 pixels.

let pixelSize: Int = 1024

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
) else { fatalError("Could not allocate bitmap rep") }

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
let size = CGFloat(pixelSize)

// Background gradient
let bg = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [
        NSColor(srgbRed: 0.18, green: 0.10, blue: 0.06, alpha: 1).cgColor,
        NSColor(srgbRed: 0.05, green: 0.03, blue: 0.04, alpha: 1).cgColor
    ] as CFArray,
    locations: [0, 1])!
ctx.drawLinearGradient(bg,
    start: CGPoint(x: 0, y: size),
    end: CGPoint(x: 0, y: 0),
    options: [])

// Radial brass glow
let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [
        NSColor(srgbRed: 0.95, green: 0.70, blue: 0.20, alpha: 0.45).cgColor,
        NSColor(srgbRed: 0.95, green: 0.70, blue: 0.20, alpha: 0).cgColor
    ] as CFArray,
    locations: [0, 1])!
ctx.drawRadialGradient(glow,
    startCenter: CGPoint(x: size/2, y: size/2), startRadius: 0,
    endCenter: CGPoint(x: size/2, y: size/2), endRadius: size * 0.55,
    options: [])

// Stylized brass "A"
let font = NSFont(name: "Times New Roman Bold", size: size * 0.62)
    ?? NSFont.systemFont(ofSize: size * 0.62, weight: .heavy)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor(srgbRed: 0.95, green: 0.72, blue: 0.22, alpha: 1)
]
let str = NSAttributedString(string: "A", attributes: attrs)
let line = CTLineCreateWithAttributedString(str)
let bounds = CTLineGetImageBounds(line, ctx)
let x = (size - bounds.width) / 2 - bounds.minX
let y = (size - bounds.height) / 2 - bounds.minY
ctx.textPosition = CGPoint(x: x, y: y)
CTLineDraw(line, ctx)

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Failed to encode PNG")
}
let outURL = URL(fileURLWithPath: CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "icon-1024.png")
try png.write(to: outURL)
print("Wrote \(outURL.path) at \(pixelSize)x\(pixelSize)")
