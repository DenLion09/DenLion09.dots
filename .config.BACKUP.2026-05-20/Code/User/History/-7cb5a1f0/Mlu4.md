# Calculator

A React + TypeScript calculator web app with PEMDAS support, memory, and keyboard input.

## Features

- **Basic Operations**: Addition (+), Subtraction (-), Multiplication (×), Division (÷)
- **Order of Operations**: PEMDAS (Parentheses, Exponents, Multiplication/Division, Addition/Subtraction)
- **Continuous Calculations**: Chain operations without pressing equals (e.g., 2 + 3 + 5 = 10)
- **Memory**: Stores last 3 operations with recall
- **Keyboard Support**: Full numpad and operator key binding

## Usage

### Mouse/Touch

Click buttons on the calculator interface.

### Keyboard

| Key        | Action            |
| ---------- | ----------------- |
| 0-9        | Number entry      |
| .          | Decimal point     |
| +          | Addition          |
| -          | Subtraction       |
| \*         | Multiplication    |
| /          | Division          |
| Enter or = | Calculate         |
| Escape     | All Clear (AC)    |
| Backspace  | Delete last digit |

> All keyboard input is routed through the same event path as button clicks (`data-key` mapping), ensuring identical behavior for physical and virtual input.

### Buttons

| Button     | Action                                        |
| ---------- | --------------------------------------------- |
| AC         | All Clear — reset calculator to initial state |
| C          | Clear — clear current operand only            |
| DEL        | Delete last digit                             |
| ÷, ×, −, + | Operators (chain supported)                   |
| .          | Decimal point                                 |
| =          | Evaluate expression                           |

## Project Structure

```
src/
├── App.tsx           # Main calculator component
├── App.css          # Calculator styles
├── types/
│   └── calculator.ts   # TypeScript interfaces
└── utils/
    └── calculatorEngine.ts  # Shunting-Yard algorithm for PEMDAS
```

## Tech Stack

- React 19
- TypeScript
- Vite
- CSS (no frameworks)

## Known Issues

_No known issues._

## Build

```bash
npm run dev    # Development server
npm run build  # Production build
npm run lint  # Lint
```
