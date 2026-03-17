# custom_floating_navigation_bar

A beautiful floating navigation bar with customizable notch position for Flutter.

## Preview


![Preview](https://raw.githubusercontent.com/pks050505/floating_navigation_bar/main/preview.gif)

## Installation

Add this to your `pubspec.yaml`:
```yaml
dependencies:
  custom_floating_navigation_bar: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## Basic Usage
```dart
import 'package:custom_floating_navigation_bar/custom_floating_navigation_bar.dart';

Scaffold(
  extendBody: true,
  bottomNavigationBar: CustomFloatingNavigationBar(
    currentIndex: _currentIndex,
    onTap: _onTap,
    floatingWidget: const MyFloatingButton(),
    onFloatingTap: (_) => _onTap(2),
    items: [
      NavItem(
        index: 0,
        label: 'Home',
        outlineIcon: const Icon(Icons.home_outlined),
        filledIcon: const Icon(Icons.home),
      ),
      NavItem(
        index: 1,
        label: 'Chat',
        outlineIcon: const Icon(Icons.chat_bubble_outline),
        filledIcon: const Icon(Icons.chat_bubble),
      ),
      NavItem(
        index: 3,
        label: 'Call',
        outlineIcon: const Icon(Icons.call_outlined),
        filledIcon: const Icon(Icons.call),
      ),
      NavItem(
        index: 4,
        label: 'More',
        outlineIcon: const Icon(Icons.more_horiz),
        filledIcon: const Icon(Icons.more_horiz),
      ),
    ],
  ),
)
```

## Floating Position Options

### Center (Default)
```dart
CustomFloatingNavigationBar(
  floatingPosition: FloatingPosition.center, // default
  onFloatingTap: (_) => _onTap(2),
  // ...
)
```

### Left
```dart
CustomFloatingNavigationBar(
  floatingPosition: FloatingPosition.left,
  onFloatingTap: (_) => _onTap(0),
  // ...
)
```

### Right
```dart
CustomFloatingNavigationBar(
  floatingPosition: FloatingPosition.right,
  onFloatingTap: (_) => _onTap(4),
  // ...
)
```

### Custom Slot
```dart
CustomFloatingNavigationBar(
  floatingPosition: FloatingPosition.custom,
  customFloatingSlotIndex: 1, 
  onFloatingTap: (_) => _onTap(1),
  // ...
)
```

## Badge Support
```dart
NavItem(
  index: 1,
  label: 'Chat',
  outlineIcon: const Icon(Icons.chat_bubble_outline),
  filledIcon: const Icon(Icons.chat_bubble),
  showBadge: true,      // ← badge on/off
  badgeText: '3',       // ← null = sirf dot dikhega
),
```

## All Parameters

### CustomFloatingNavigationBar

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `currentIndex` | `int` | required | Active tab index |
| `onTap` | `Function(int)` | required | Tab tap callback |
| `items` | `List<NavItem>` | required | Nav items |
| `floatingWidget` | `Widget` | required | Center floating widget |
| `floatingPosition` | `FloatingPosition` | `center` | Notch position |
| `customFloatingSlotIndex` | `int?` | `null` | Custom slot (FloatingPosition.custom mein) |
| `onFloatingTap` | `Function(int)?` | `null` | Floating tap callback |
| `floatingSize` | `double` | `64` | Floating button size |
| `floatingLift` | `double` | `30` | Floating button upar kitna uthega |
| `centerGapWidth` | `double` | `80` | Notch gap width |
| `barHeight` | `double` | `64` | Nav bar height |
| `notchRadius` | `double` | `40` | Notch curve radius |
| `topRadius` | `double` | `14` | Top corners radius |
| `bottomRadius` | `double` | `20` | Bottom corners radius |
| `leftRadius` | `double` | `24` | Left corner radius |
| `rightRadius` | `double` | `12` | Right corner radius |

### NavItem

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `index` | `int` | required | Tab index |
| `label` | `String` | required | Tab label |
| `outlineIcon` | `Widget` | required | Unselected icon |
| `filledIcon` | `Widget` | required | Selected icon |
| `showBadge` | `bool` | `false` | Badge show/hide |
| `badgeText` | `String?` | `null` | Badge text (null = dot) |

## License
MIT
```

---

## Final File Structure:
```
floating_navigation_bar/
├── example/
│   ├── lib/
│   │   └── main.dart       ← pub.dev Example tab
│   └── pubspec.yaml
├── lib/
│   ├── custom_floating_navigation_bar.dart  ← public exports
│   └── src/
│       ├── navbar.dart
│       └── nav_item.dart
├── README.md               ← ⭐ sabse important
├── CHANGELOG.md
├── LICENSE
└── pubspec.yaml