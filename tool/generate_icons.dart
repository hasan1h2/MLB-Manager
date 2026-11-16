// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  print('Generating MLB Manager App Icons...');

  const size = 1024;
  final masterIcon = img.Image(width: size, height: size);
  final foregroundIcon = img.Image(width: size, height: size);

  // Colors
  // Deep Navy background gradient
  const cNavyCenter = [26, 48, 80]; // #1A3050
  const cNavyEdge = [10, 25, 38];    // #0A1926
  const cElectricBlue = [0, 119, 254]; // #0077FE
  const cElectricLight = [77, 159, 255]; // #4D9FFF
  const cEmerald = [16, 185, 129]; // #10B981
  const cEmeraldLight = [52, 211, 153]; // #34D399
  const cGold = [245, 158, 11]; // #F59E0B
  const cGoldLight = [251, 191, 36]; // #FBBF24
  const cWhite = [255, 255, 255];

  // Helper for drawing anti-aliased pixels
  void blendPixel(img.Image target, int x, int y, List<int> rgb, double alpha) {
    if (x < 0 || x >= size || y < 0 || y >= size || alpha <= 0) return;
    if (alpha >= 1.0) {
      target.setPixelRgba(x, y, rgb[0], rgb[1], rgb[2], 255);
      return;
    }
    final existing = target.getPixel(x, y);
    final bgR = existing.r;
    final bgG = existing.g;
    final bgB = existing.b;
    final bgA = existing.a / 255.0;

    final outA = alpha + bgA * (1.0 - alpha);
    if (outA <= 0) return;
    final outR = ((rgb[0] * alpha + bgR * bgA * (1.0 - alpha)) / outA).round().clamp(0, 255);
    final outG = ((rgb[1] * alpha + bgG * bgA * (1.0 - alpha)) / outA).round().clamp(0, 255);
    final outB = ((rgb[2] * alpha + bgB * bgA * (1.0 - alpha)) / outA).round().clamp(0, 255);
    target.setPixelRgba(x, y, outR, outG, outB, (outA * 255).round().clamp(0, 255));
  }

  // 1. Draw Master Background (Radial Gradient + Rounded squircle)
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = (x - size / 2) / (size / 2);
      final dy = (y - size / 2) / (size / 2);
      final dist = math.sqrt(dx * dx + dy * dy);
      final t = (dist / 1.35).clamp(0.0, 1.0);

      // Smooth radial gradient
      final r = (cNavyCenter[0] * (1 - t) + cNavyEdge[0] * t).round();
      final g = (cNavyCenter[1] * (1 - t) + cNavyEdge[1] * t).round();
      final b = (cNavyCenter[2] * (1 - t) + cNavyEdge[2] * t).round();
      masterIcon.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // Draw background ambient glow ring in electric blue
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - 512.0;
      final dy = y - 512.0;
      final dist = math.sqrt(dx * dx + dy * dy);
      // Outer subtle glow ring at r=440..470
      if (dist >= 420 && dist <= 480) {
        final glowFactor = math.sin((dist - 420) / 60 * math.pi) * 0.28;
        blendPixel(masterIcon, x, y, cElectricBlue, glowFactor);
      }
    }
  }

  // Helper to draw filled rounded rectangle on an image
  void drawRoundedRect(
    img.Image target,
    double x1, double y1, double x2, double y2,
    double radius,
    List<int> rgb,
    [double opacity = 1.0]
  ) {
    final minX = (x1 - 1).floor().clamp(0, size - 1);
    final maxX = (x2 + 1).ceil().clamp(0, size - 1);
    final minY = (y1 - 1).floor().clamp(0, size - 1);
    final maxY = (y2 + 1).ceil().clamp(0, size - 1);

    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        double dist = 0.0;
        final inX = x >= x1 + radius && x <= x2 - radius;
        final inY = y >= y1 + radius && y <= y2 - radius;

        if (inX || inY) {
          if (x >= x1 && x <= x2 && y >= y1 && y <= y2) {
            dist = -1.0; // inside
          } else {
            dist = 1.0;
          }
        } else {
          // Corner distance
          final cx = x < x1 + radius ? x1 + radius : x2 - radius;
          final cy = y < y1 + radius ? y1 + radius : y2 - radius;
          final d = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
          dist = d - radius;
        }

        if (dist <= 0) {
          blendPixel(target, x, y, rgb, opacity);
        } else if (dist < 1.0) {
          blendPixel(target, x, y, rgb, opacity * (1.0 - dist));
        }
      }
    }
  }

  // Helper to draw on both master and foreground
  void drawOnBoth(void Function(img.Image) drawer) {
    drawer(masterIcon);
    drawer(foregroundIcon);
  }

  // 2. Draw Financial Shield Badge (Outer Border)
  // Badge size: 540x540 centered at 512, 512 (Safe zone is within 66% = 675px)
  drawOnBoth((img) {
    // Outer shield card in electric blue gradient
    drawRoundedRect(img, 240, 240, 784, 784, 110, cElectricBlue, 0.95);
    // Inner badge container (Dark navy)
    drawRoundedRect(img, 252, 252, 772, 772, 98, [12, 28, 45], 1.0);
    // Top highlight inside badge
    drawRoundedRect(img, 256, 256, 768, 380, 94, [24, 48, 76], 0.45);
  });

  // 3. Draw Financial Growth Chart Bars (Upper half of the badge)
  drawOnBoth((img) {
    // Bar 1: Left (Electric Blue)
    drawRoundedRect(img, 320, 410, 380, 500, 16, cElectricBlue, 1.0);
    drawRoundedRect(img, 324, 414, 376, 440, 12, cElectricLight, 0.7);

    // Bar 2: Middle (Info Blue / Cyan)
    drawRoundedRect(img, 410, 350, 470, 500, 16, [0, 162, 255], 1.0);
    drawRoundedRect(img, 414, 354, 466, 380, 12, [102, 204, 255], 0.7);

    // Bar 3: Right (Emerald Green - Growth)
    drawRoundedRect(img, 500, 290, 560, 500, 16, cEmerald, 1.0);
    drawRoundedRect(img, 504, 294, 556, 320, 12, cEmeraldLight, 0.7);

    // Growth Arrow: diagonal rising from (540, 310) to (680, 230)
    // Draw thick arrow shaft
    for (int t = 0; t <= 100; t++) {
      final px = 530.0 + (670.0 - 530.0) * (t / 100.0);
      final py = 350.0 + (220.0 - 350.0) * (t / 100.0);
      for (int dy = -9; dy <= 9; dy++) {
        for (int dx = -9; dx <= 9; dx++) {
          if (dx * dx + dy * dy <= 81) {
            blendPixel(img, (px + dx).round(), (py + dy).round(), cEmeraldLight, 0.9);
          }
        }
      }
    }
    // Arrow head at (670, 220)
    final headPoints = [
      [675.0, 215.0],
      [600.0, 220.0],
      [665.0, 285.0],
    ];
    // Draw filled polygon for arrowhead
    for (int y = 200; y <= 300; y++) {
      for (int x = 580; x <= 690; x++) {
        // Point in triangle check
        final d1 = (x - headPoints[1][0]) * (headPoints[0][1] - headPoints[1][1]) - (headPoints[0][0] - headPoints[1][0]) * (y - headPoints[1][1]);
        final d2 = (x - headPoints[2][0]) * (headPoints[1][1] - headPoints[2][1]) - (headPoints[1][0] - headPoints[2][0]) * (y - headPoints[2][1]);
        final d3 = (x - headPoints[0][0]) * (headPoints[2][1] - headPoints[0][1]) - (headPoints[2][0] - headPoints[0][0]) * (y - headPoints[0][1]);
        final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
        final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
        if (!(hasNeg && hasPos)) {
          blendPixel(img, x, y, cEmerald, 1.0);
        }
      }
    }
  });

  // 4. Draw Horizontal Wallet Divider Band
  drawOnBoth((img) {
    drawRoundedRect(img, 252, 510, 772, 532, 6, cElectricBlue, 0.9);
    drawRoundedRect(img, 252, 514, 772, 528, 4, cElectricLight, 0.6);
  });

  // 5. Draw Gold Vault Clasp / Coin Badge at Center Right
  drawOnBoth((img) {
    const cx = 512.0;
    const cy = 521.0;
    // Outer golden ring
    for (int y = 475; y <= 567; y++) {
      for (int x = 466; x <= 558; x++) {
        final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
        if (dist <= 38) {
          blendPixel(img, x, y, cGold, 1.0);
        }
        if (dist <= 30) {
          blendPixel(img, x, y, cGoldLight, 1.0);
        }
        if (dist <= 20) {
          blendPixel(img, x, y, [180, 83, 9], 1.0);
        }
        if (dist <= 12) {
          blendPixel(img, x, y, cWhite, 0.95);
        }
      }
    }
  });

  // 6. Draw "MLB" Bold Geometric Monogram on the lower half
  // Lower area: y from 565 to 745.
  drawOnBoth((img) {
    // Letter M: from x=305 to 445, y=575 to 730
    // Left vertical stem
    drawRoundedRect(img, 305, 575, 335, 730, 8, cWhite, 1.0);
    // Right vertical stem
    drawRoundedRect(img, 415, 575, 445, 730, 8, cWhite, 1.0);
    // Left diagonal
    for (int t = 0; t <= 100; t++) {
      final px = 320.0 + (375.0 - 320.0) * (t / 100.0);
      final py = 580.0 + (665.0 - 580.0) * (t / 100.0);
      for (int d = -13; d <= 13; d++) {
        blendPixel(img, (px + d).round(), py.round(), cWhite, 1.0);
      }
    }
    // Right diagonal
    for (int t = 0; t <= 100; t++) {
      final px = 430.0 + (375.0 - 430.0) * (t / 100.0);
      final py = 580.0 + (665.0 - 580.0) * (t / 100.0);
      for (int d = -13; d <= 13; d++) {
        blendPixel(img, (px + d).round(), py.round(), cWhite, 1.0);
      }
    }

    // Letter L: from x=475 to 585, y=575 to 730
    // Vertical stem
    drawRoundedRect(img, 475, 575, 505, 730, 8, cElectricLight, 1.0);
    // Horizontal base
    drawRoundedRect(img, 475, 700, 585, 730, 8, cElectricLight, 1.0);

    // Letter B: from x=605 to 715, y=575 to 730
    // Vertical stem
    drawRoundedRect(img, 605, 575, 635, 730, 8, cEmeraldLight, 1.0);
    // Top bar
    drawRoundedRect(img, 625, 575, 685, 605, 8, cEmeraldLight, 1.0);
    // Middle bar
    drawRoundedRect(img, 625, 638, 685, 668, 8, cEmeraldLight, 1.0);
    // Bottom bar
    drawRoundedRect(img, 625, 700, 685, 730, 8, cEmeraldLight, 1.0);
    // Top bowl right arc
    for (int a = -90; a <= 90; a++) {
      final rad = a * math.pi / 180.0;
      final px = 675.0 + math.cos(rad) * 31.0;
      final py = 606.0 + math.sin(rad) * 31.0;
      for (int d = -9; d <= 9; d++) {
        for (int dy = -9; dy <= 9; dy++) {
          if (d * d + dy * dy <= 81) {
            blendPixel(img, (px + d).round(), (py + dy).round(), cEmeraldLight, 1.0);
          }
        }
      }
    }
    // Bottom bowl right arc
    for (int a = -90; a <= 90; a++) {
      final rad = a * math.pi / 180.0;
      final px = 675.0 + math.cos(rad) * 31.0;
      final py = 669.0 + math.sin(rad) * 31.0;
      for (int d = -9; d <= 9; d++) {
        for (int dy = -9; dy <= 9; dy++) {
          if (d * d + dy * dy <= 81) {
            blendPixel(img, (px + d).round(), (py + dy).round(), cEmeraldLight, 1.0);
          }
        }
      }
    }
  });

  // 7. Save Master High-Resolution Assets
  final assetsIconsDir = Directory('assets/icons');
  if (!assetsIconsDir.existsSync()) assetsIconsDir.createSync(recursive: true);

  final assetsImagesDir = Directory('assets/images');
  if (!assetsImagesDir.existsSync()) assetsImagesDir.createSync(recursive: true);

  File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(masterIcon));
  File('assets/images/app_logo.png').writeAsBytesSync(img.encodePng(masterIcon));
  File('assets/icons/ic_launcher_foreground.png').writeAsBytesSync(img.encodePng(foregroundIcon));
  print('Saved master 1024x1024 icons to assets/icons/ and assets/images/');

  // 8. Generate Round Master Icon
  final roundMasterIcon = img.Image(width: size, height: size);
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - 512.0;
      final dy = y - 512.0;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist <= 508.0) {
        final p = masterIcon.getPixel(x, y);
        roundMasterIcon.setPixel(x, y, p);
      } else if (dist <= 512.0) {
        final alpha = (512.0 - dist) / 4.0;
        final p = masterIcon.getPixel(x, y);
        roundMasterIcon.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), (p.a * alpha).round());
      }
    }
  }

  // 9. Generate Android Mipmap Icons
  final androidMipmaps = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };

  final androidForegroundSizes = {
    'mdpi': 108,
    'hdpi': 162,
    'xhdpi': 216,
    'xxhdpi': 324,
    'xxxhdpi': 432,
  };

  for (var entry in androidMipmaps.entries) {
    final density = entry.key;
    final px = entry.value;
    final dir = Directory('android/app/src/main/res/mipmap-$density');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    // Standard square / legacy icon
    final resized = img.copyResize(masterIcon, width: px, height: px, interpolation: img.Interpolation.cubic);
    File('${dir.path}/ic_launcher.png').writeAsBytesSync(img.encodePng(resized));

    // Round launcher icon
    final resizedRound = img.copyResize(roundMasterIcon, width: px, height: px, interpolation: img.Interpolation.cubic);
    File('${dir.path}/ic_launcher_round.png').writeAsBytesSync(img.encodePng(resizedRound));

    // Adaptive foreground icon
    final fgPx = androidForegroundSizes[density]!;
    final resizedFg = img.copyResize(foregroundIcon, width: fgPx, height: fgPx, interpolation: img.Interpolation.cubic);
    File('${dir.path}/ic_launcher_foreground.png').writeAsBytesSync(img.encodePng(resizedFg));

    print('Generated mipmap-$density icons: ${px}px (launcher), ${fgPx}px (foreground)');
  }

  // Also put a fallback ic_launcher_foreground in res/drawable
  final drawableDir = Directory('android/app/src/main/res/drawable');
  if (!drawableDir.existsSync()) drawableDir.createSync(recursive: true);
  final fgDrawable = img.copyResize(foregroundIcon, width: 432, height: 432, interpolation: img.Interpolation.cubic);
  File('${drawableDir.path}/ic_launcher_foreground.png').writeAsBytesSync(img.encodePng(fgDrawable));

  // 10. Generate Web Icons
  final webDir = Directory('web');
  if (webDir.existsSync()) {
    final favicon = img.copyResize(masterIcon, width: 48, height: 48, interpolation: img.Interpolation.cubic);
    File('web/favicon.png').writeAsBytesSync(img.encodePng(favicon));

    final iconsDir = Directory('web/icons');
    if (!iconsDir.existsSync()) iconsDir.createSync(recursive: true);

    final icon192 = img.copyResize(masterIcon, width: 192, height: 192, interpolation: img.Interpolation.cubic);
    File('web/icons/Icon-192.png').writeAsBytesSync(img.encodePng(icon192));
    File('web/icons/Icon-maskable-192.png').writeAsBytesSync(img.encodePng(icon192));

    final icon512 = img.copyResize(masterIcon, width: 512, height: 512, interpolation: img.Interpolation.cubic);
    File('web/icons/Icon-512.png').writeAsBytesSync(img.encodePng(icon512));
    File('web/icons/Icon-maskable-512.png').writeAsBytesSync(img.encodePng(icon512));
    print('Generated Web icons (favicon, 192px, 512px, maskable)');
  }

  print('All launcher icon assets generated successfully!');
}
