# Snake Game 🐍

A classic snake game built with Godot 4.x for Android and iOS.

## Features

- Classic snake gameplay
- Touch swipe controls for mobile
- Keyboard support (WASD / Arrow keys)
- High score saving
- Responsive UI for different screen sizes

## Requirements

- Godot 4.2 or later
- For Android: Android SDK, NDK, JDK 17+
- For iOS: macOS, Xcode 14+, Apple Developer account

## Running the Game

1. Open Godot 4.x
2. Import this project
3. Press F5 or click "Play" to run

## Controls

**Mobile:**
- Swipe up/down/left/right to change direction

**Keyboard:**
- WASD or Arrow keys to move
- ESC to pause

## Project Structure

```
game-snake/
├── project.godot          # Godot project config
├── scenes/
│   ├── main.tscn          # Main entry scene
│   └── game/
│       └── game.tscn      # Game scene
├── scripts/
│   ├── autoload/          # Singleton managers
│   │   ├── game_manager.gd
│   │   ├── touch_input.gd
│   │   ├── audio_manager.gd
│   │   └── save_manager.gd
│   ├── game/              # Game logic
│   │   ├── snake.gd
│   │   ├── food.gd
│   │   └── game.gd
│   └── ui/                # UI controllers
│       └── main_menu.gd
└── assets/                # Sprites, audio, fonts
```

## Building for Android

1. Project → Export
2. Add Android platform
3. Configure keystore and package name
4. Export APK/AAB

## Building for iOS

1. Project → Export
2. Add iOS platform
3. Export Xcode project
4. Open in Xcode and build

## License

MIT
