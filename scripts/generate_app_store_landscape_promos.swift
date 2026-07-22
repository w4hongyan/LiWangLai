import AppKit
import CoreText
import Foundation
import ImageIO

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let sourceDir = root.appendingPathComponent("AppStoreScreenshots/landscape")
let phoneOutput = root.appendingPathComponent("AppStoreScreenshots/1320x2868/promotional/07-quickdesk.png")
let padOutput = root.appendingPathComponent("AppStoreScreenshots/2064x2752/promotional/06-quickdesk.png")

let accent = NSColor(red: 0.72, green: 0.13, blue: 0.09, alpha: 1)
let ink = NSColor(red: 0.10, green: 0.085, blue: 0.07, alpha: 1)
let secondaryInk = NSColor(red: 0.37, green: 0.31, blue: 0.25, alpha: 1)
let warmGold = NSColor(red: 0.72, green: 0.49, blue: 0.24, alpha: 1)
let paper = NSColor(red: 0.985, green: 0.972, blue: 0.938, alpha: 1)

func registerFont(_ relativePath: String) -> String? {
    let url = root.appendingPathComponent(relativePath) as CFURL
    guard let provider = CGDataProvider(url: url), let cgFont = CGFont(provider) else { return nil }
    var error: Unmanaged<CFError>?
    CTFontManagerRegisterGraphicsFont(cgFont, &error)
    return cgFont.postScriptName as String?
}

let semiboldName = registerFont("LiWangLai/Resources/Fonts/SourceHanSerifSC-SemiBold.otf")
let regularName = registerFont("LiWangLai/Resources/Fonts/SourceHanSerifSC-Regular.otf")

func font(_ name: String?, size: CGFloat, weight: NSFont.Weight = .regular) -> NSFont {
    if let name, let result = NSFont(name: name, size: size) { return result }
    return NSFont.systemFont(ofSize: size, weight: weight)
}

func drawBackground(in rect: NSRect) {
    NSGradient(
        starting: paper,
        ending: NSColor(red: 0.98, green: 0.90, blue: 0.85, alpha: 1)
    )?.draw(in: rect, angle: 90)

    accent.withAlphaComponent(0.052).setFill()
    NSBezierPath(ovalIn: NSRect(x: -rect.width * 0.16, y: rect.height * 0.79, width: rect.width * 0.46, height: rect.width * 0.46)).fill()
    NSBezierPath(ovalIn: NSRect(x: rect.width * 0.80, y: rect.height * 0.88, width: rect.width * 0.27, height: rect.width * 0.27)).fill()

    if let plum = NSImage(contentsOf: root.appendingPathComponent("LiWangLai/Resources/Assets.xcassets/prototype_plum_branch_corner.imageset/prototype_plum_branch_corner.png")) {
        plum.draw(
            in: NSRect(x: rect.width * 0.77, y: rect.height * 0.89, width: rect.width * 0.24, height: rect.width * 0.20),
            from: .zero,
            operation: .sourceOver,
            fraction: 0.25
        )
    }
}

func drawBrand(_ text: String, number: String, canvas: NSSize, brandY: CGFloat, badge: NSRect, brandSize: CGFloat, badgeTextSize: CGFloat) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font(semiboldName, size: brandSize, weight: .semibold),
        .foregroundColor: accent,
        .kern: 4.0,
    ]
    (text as NSString).draw(at: NSPoint(x: canvas.width * 0.07, y: brandY), withAttributes: attrs)

    accent.setFill()
    NSBezierPath(roundedRect: badge, xRadius: badge.height * 0.26, yRadius: badge.height * 0.26).fill()
    let numberText = number as NSString
    let numberAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedDigitSystemFont(ofSize: badgeTextSize, weight: .bold),
        .foregroundColor: NSColor.white,
    ]
    let numberSize = numberText.size(withAttributes: numberAttrs)
    numberText.draw(
        at: NSPoint(x: badge.midX - numberSize.width / 2, y: badge.midY - numberSize.height / 2),
        withAttributes: numberAttrs
    )
}

func drawText(_ text: String, rect: NSRect, size: CGFloat, color: NSColor, semibold: Bool = false) {
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .byTruncatingTail
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font(semibold ? semiboldName : regularName, size: size, weight: semibold ? .bold : .regular),
        .foregroundColor: color,
        .paragraphStyle: style,
    ]
    (text as NSString).draw(in: rect, withAttributes: attrs)
}

func drawPill(_ text: String, rect: NSRect, fill: NSColor, textColor: NSColor, fontSize: CGFloat) {
    fill.setFill()
    NSBezierPath(roundedRect: rect, xRadius: rect.height / 2, yRadius: rect.height / 2).fill()
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font(semiboldName, size: fontSize, weight: .semibold),
        .foregroundColor: textColor,
    ]
    let value = text as NSString
    let valueSize = value.size(withAttributes: attrs)
    value.draw(
        at: NSPoint(x: rect.midX - valueSize.width / 2, y: rect.midY - valueSize.height / 2),
        withAttributes: attrs
    )
}

func drawDevice(screenshot: NSImage, outerRect: NSRect, screenRect: NSRect, radius: CGFloat) {
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
    shadow.shadowBlurRadius = 38
    shadow.shadowOffset = NSSize(width: 0, height: -14)
    shadow.set()
    NSColor.black.withAlphaComponent(0.12).setFill()
    NSBezierPath(roundedRect: outerRect, xRadius: radius, yRadius: radius).fill()
    NSGraphicsContext.restoreGraphicsState()

    NSColor(red: 0.985, green: 0.975, blue: 0.945, alpha: 1).setFill()
    NSBezierPath(roundedRect: outerRect, xRadius: radius, yRadius: radius).fill()
    accent.withAlphaComponent(0.30).setStroke()
    let outerBorder = NSBezierPath(roundedRect: outerRect, xRadius: radius, yRadius: radius)
    outerBorder.lineWidth = 4
    outerBorder.stroke()

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: screenRect, xRadius: max(18, radius * 0.52), yRadius: max(18, radius * 0.52)).addClip()
    screenshot.draw(in: screenRect, from: .zero, operation: .copy, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()
}

func drawFeatureCard(mark: String, title: String, subtitle: String, rect: NSRect, scale: CGFloat) {
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.09)
    shadow.shadowBlurRadius = 22 * scale
    shadow.shadowOffset = NSSize(width: 0, height: -5 * scale)
    shadow.set()
    NSColor(red: 1.0, green: 0.985, blue: 0.95, alpha: 0.95).setFill()
    NSBezierPath(roundedRect: rect, xRadius: 30 * scale, yRadius: 30 * scale).fill()
    NSGraphicsContext.restoreGraphicsState()

    let markRect = NSRect(x: rect.minX + 34 * scale, y: rect.midY - 42 * scale, width: 84 * scale, height: 84 * scale)
    accent.withAlphaComponent(0.11).setFill()
    NSBezierPath(ovalIn: markRect).fill()
    let markAttrs: [NSAttributedString.Key: Any] = [
        .font: font(semiboldName, size: 34 * scale, weight: .bold),
        .foregroundColor: accent,
    ]
    let markText = mark as NSString
    let markSize = markText.size(withAttributes: markAttrs)
    markText.draw(at: NSPoint(x: markRect.midX - markSize.width / 2, y: markRect.midY - markSize.height / 2), withAttributes: markAttrs)

    drawText(title, rect: NSRect(x: rect.minX + 150 * scale, y: rect.midY + 3 * scale, width: rect.width - 190 * scale, height: 55 * scale), size: 38 * scale, color: ink, semibold: true)
    drawText(subtitle, rect: NSRect(x: rect.minX + 150 * scale, y: rect.midY - 49 * scale, width: rect.width - 190 * scale, height: 48 * scale), size: 25 * scale, color: secondaryInk)
}

func stripAlpha(from url: URL, width: Int, height: Int) throws {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let sourceImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
          let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
          let context = CGContext(
              data: nil,
              width: width,
              height: height,
              bitsPerComponent: 8,
              bytesPerRow: width * 4,
              space: colorSpace,
              bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue
          ) else { fatalError("Unable to prepare RGB output") }
    context.interpolationQuality = .high
    context.draw(sourceImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let rgb = context.makeImage() else { fatalError("Unable to render RGB output") }
    let temporary = url.deletingLastPathComponent().appendingPathComponent(".\(url.lastPathComponent).rgb.png")
    guard let destination = CGImageDestinationCreateWithURL(temporary as CFURL, "public.png" as CFString, 1, nil) else {
        fatalError("Unable to create RGB destination")
    }
    CGImageDestinationAddImage(destination, rgb, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Unable to finalize RGB output") }
    _ = try FileManager.default.replaceItemAt(url, withItemAt: temporary)
}

func write(_ image: NSImage, to url: URL, width: Int, height: Int) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [.compressionFactor: 1.0]) else {
        fatalError("Unable to encode \(url.lastPathComponent)")
    }
    try png.write(to: url, options: .atomic)
    let resize = Process()
    resize.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
    resize.arguments = ["-z", "\(height)", "\(width)", url.path]
    resize.standardOutput = FileHandle.nullDevice
    resize.standardError = FileHandle.nullDevice
    try resize.run()
    resize.waitUntilExit()
    guard resize.terminationStatus == 0 else { fatalError("Unable to resize \(url.lastPathComponent)") }
    try stripAlpha(from: url, width: width, height: height)
}

func makePhonePromo() throws {
    guard let screenshot = NSImage(contentsOf: sourceDir.appendingPathComponent("iphone-quickdesk.jpg")) else {
        fatalError("Missing iPhone landscape screenshot")
    }
    let canvas = NSSize(width: 1320, height: 2868)
    let image = NSImage(size: canvas)
    image.lockFocus()
    guard let context = NSGraphicsContext.current else { fatalError("Missing graphics context") }
    context.imageInterpolation = .high

    drawBackground(in: NSRect(origin: .zero, size: canvas))
    drawBrand("礼往来  ·  APP STORE", number: "07", canvas: canvas, brandY: 2740, badge: NSRect(x: 1120, y: 2708, width: 106, height: 106), brandSize: 34, badgeTextSize: 39)
    drawText("横屏礼台，现场更从容", rect: NSRect(x: 88, y: 2530, width: 1145, height: 130), size: 88, color: ink, semibold: true)
    drawText("连续收礼、实时合计与宾客名单，一屏掌握", rect: NSRect(x: 92, y: 2442, width: 1135, height: 62), size: 38, color: secondaryInk)
    drawPill("手机横屏礼台模式", rect: NSRect(x: 92, y: 2292, width: 342, height: 72), fill: accent, textColor: .white, fontSize: 30)

    let outer = NSRect(x: 60, y: 1460, width: 1200, height: 650)
    let screen = NSRect(x: 92, y: 1521, width: 1136, height: 523)
    drawDevice(screenshot: screenshot, outerRect: outer, screenRect: screen, radius: 54)

    drawText("一台手机，就是一张高效礼台", rect: NSRect(x: 92, y: 1322, width: 1136, height: 72), size: 51, color: ink, semibold: true)
    drawFeatureCard(mark: "快", title: "连续登记", subtitle: "收一份记一份，现场录入少打断", rect: NSRect(x: 90, y: 1010, width: 1140, height: 220), scale: 1)
    drawFeatureCard(mark: "准", title: "实时合计", subtitle: "金额、笔数与本场进度随时可见", rect: NSRect(x: 90, y: 750, width: 1140, height: 220), scale: 1)
    drawFeatureCard(mark: "清", title: "宾客清单", subtitle: "快速查人，减少重记和漏记", rect: NSRect(x: 90, y: 490, width: 1140, height: 220), scale: 1)
    drawPill("婚礼 · 满月 · 乔迁现场都适用", rect: NSRect(x: 300, y: 260, width: 720, height: 92), fill: warmGold.withAlphaComponent(0.16), textColor: NSColor(red: 0.48, green: 0.31, blue: 0.14, alpha: 1), fontSize: 34)

    image.unlockFocus()
    try write(image, to: phoneOutput, width: 1320, height: 2868)
    print("Wrote \(phoneOutput.path)")
}

func makePadPromo() throws {
    guard let screenshot = NSImage(contentsOf: sourceDir.appendingPathComponent("ipad-quickdesk.jpg")) else {
        fatalError("Missing iPad landscape screenshot")
    }
    let canvas = NSSize(width: 2064, height: 2752)
    let image = NSImage(size: canvas)
    image.lockFocus()
    guard let context = NSGraphicsContext.current else { fatalError("Missing graphics context") }
    context.imageInterpolation = .high

    drawBackground(in: NSRect(origin: .zero, size: canvas))
    drawBrand("礼往来  ·  iPAD", number: "06", canvas: canvas, brandY: 2640, badge: NSRect(x: 1780, y: 2590, width: 132, height: 100), brandSize: 35, badgeTextSize: 40)
    drawText("横屏礼台，现场更从容", rect: NSRect(x: 140, y: 2415, width: 1720, height: 125), size: 86, color: ink, semibold: true)
    drawText("大屏连续登记，金额、名单与进度一屏掌握", rect: NSRect(x: 144, y: 2328, width: 1720, height: 60), size: 38, color: secondaryInk)

    drawPill("连续登记", rect: NSRect(x: 144, y: 2138, width: 480, height: 100), fill: accent.withAlphaComponent(0.11), textColor: accent, fontSize: 36)
    drawPill("实时合计", rect: NSRect(x: 792, y: 2138, width: 480, height: 100), fill: warmGold.withAlphaComponent(0.15), textColor: NSColor(red: 0.48, green: 0.31, blue: 0.14, alpha: 1), fontSize: 36)
    drawPill("快速查人", rect: NSRect(x: 1440, y: 2138, width: 480, height: 100), fill: accent.withAlphaComponent(0.11), textColor: accent, fontSize: 36)

    let outer = NSRect(x: 112, y: 390, width: 1840, height: 1570)
    let screen = NSRect(x: 150, y: 505, width: 1764, height: 1323)
    drawDevice(screenshot: screenshot, outerRect: outer, screenRect: screen, radius: 68)
    drawPill("适合婚礼、满月、乔迁等多人协作现场", rect: NSRect(x: 452, y: 190, width: 1160, height: 96), fill: warmGold.withAlphaComponent(0.16), textColor: NSColor(red: 0.48, green: 0.31, blue: 0.14, alpha: 1), fontSize: 34)

    image.unlockFocus()
    try write(image, to: padOutput, width: 2064, height: 2752)
    print("Wrote \(padOutput.path)")
}

try makePhonePromo()
try makePadPromo()
