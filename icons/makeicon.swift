// Generates the BLEUnlock LTS app icon. Usage: swift makeicon.swift <outdir>
import Cocoa

func render(_ size: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = ctx
    let c = ctx.cgContext
    let k = CGFloat(size) / 1024
    c.translateBy(x: 0, y: CGFloat(size)); c.scaleBy(x: k, y: -k)   // top-left origin, 1024 grid
    let cs = CGColorSpaceCreateDeviceRGB()

    // Squircle (macOS icon grid: 824pt body)
    let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    let squircle = NSBezierPath(roundedRect: body, xRadius: 185, yRadius: 185).cgPath
    c.saveGState()
    c.addPath(squircle); c.clip()
    let grad = CGGradient(colorsSpace: cs, colors: [CGColor(red: 0.07, green: 0.09, blue: 0.22, alpha: 1), CGColor(red: 0.16, green: 0.20, blue: 0.55, alpha: 1), CGColor(red: 0.24, green: 0.45, blue: 0.95, alpha: 1)] as CFArray, locations: [0, 0.55, 1])!
    c.drawLinearGradient(grad, start: CGPoint(x: 300, y: 100), end: CGPoint(x: 760, y: 924), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    // soft top highlight
    let hl = CGGradient(colorsSpace: cs, colors: [CGColor(red: 1, green: 1, blue: 1, alpha: 0.22), CGColor(red: 1, green: 1, blue: 1, alpha: 0)] as CFArray, locations: [0, 1])!
    c.drawLinearGradient(hl, start: CGPoint(x: 512, y: 100), end: CGPoint(x: 512, y: 480), options: [.drawsAfterEndLocation])
    c.restoreGState()

    // Padlock (same proportions as the original icon), with a soft shadow
    c.saveGState()
    c.setShadow(offset: CGSize(width: 0, height: 14), blur: 26, color: CGColor(red: 0, green: 0, blue: 0.1, alpha: 0.45))
    c.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    c.addPath(NSBezierPath(roundedRect: CGRect(x: 320, y: 480, width: 385, height: 288), xRadius: 34, yRadius: 34).cgPath)
    c.fillPath()
    // open shackle
    c.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1)); c.setLineWidth(48); c.setLineCap(.butt)
    let sh = CGMutablePath()
    sh.move(to: CGPoint(x: 392, y: 430)); sh.addLine(to: CGPoint(x: 392, y: 400))
    sh.addArc(center: CGPoint(x: 512, y: 400), radius: 120, startAngle: .pi, endAngle: 0, clockwise: false)
    sh.addLine(to: CGPoint(x: 632, y: 482))
    c.addPath(sh); c.strokePath()
    c.restoreGState()

    // keyhole
    c.setFillColor(CGColor(red: 0.16, green: 0.20, blue: 0.55, alpha: 1))
    c.fillEllipse(in: CGRect(x: 464, y: 578, width: 96, height: 96))
    c.addPath(NSBezierPath(roundedRect: CGRect(x: 492, y: 636, width: 40, height: 80), xRadius: 14, yRadius: 14).cgPath); c.fillPath() // slot

    // Bluetooth signal arcs (top right)
    c.setStrokeColor(CGColor(red: 0.62, green: 0.85, blue: 1, alpha: 0.95)); c.setLineCap(.round); c.setLineWidth(30)
    for (i, r) in [70.0, 120.0, 170.0].enumerated() {
        c.setAlpha(1.0 - CGFloat(i) * 0.22)
        c.addArc(center: CGPoint(x: 700, y: 330), radius: CGFloat(r), startAngle: -.pi * 0.42, endAngle: .pi * 0.02, clockwise: false)
        c.strokePath()
    }
    NSGraphicsContext.current = nil
    return rep.representation(using: .png, properties: [:])!
}

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
for (name, px) in [("mac-16x16",16),("mac-16x16@2x",32),("mac-32x32",32),("mac-32x32@2x",64),("mac-128x128",128),("mac-128x128@2x",256),("mac-256x256",256),("mac-256x256@2x",512),("mac-512x512",512),("mac-512x512@2x",1024)] {
    try! render(px).write(to: URL(fileURLWithPath: out + "/" + name + ".png"))
}
