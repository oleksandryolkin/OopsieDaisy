# OopsieDaisy

**A minimal macOS menu bar utility that fixes words typed in the wrong keyboard layout — automatically, invisibly, and entirely offline.**

Type `ghbdsn`, get `привіт`. No dialogs, no clipboard tricks, no internet connection. The moment you finish a word in the wrong layout, OopsieDaisy switches your input source, deletes it, and retypes it correctly — just like the classic Punto Switcher, reimplemented natively for macOS.

## How it works

1. OopsieDaisy runs quietly in the menu bar — no Dock icon, no windows.
2. It watches your keystrokes system-wide and buffers the word you're currently typing.
3. When you finish a word (`Space`, `Enter`, `Tab`, or punctuation), it checks whether that word looks like it was typed in the wrong layout.
4. If it does: your input source switches, the wrong word is deleted, and the correct one is typed in its place — before you've even noticed.

Everything happens locally on your Mac. No network requests, no telemetry, no data collection.

## Features

- **Fully automatic** — no hotkeys to remember, no manual re-typing.
- **Works in any app** — browsers, chat apps, editors, terminals (with sensible exclusions, see below).
- **Not limited to Ukrainian/English** — works with any pair of keyboard layouts you have enabled in System Settings, thanks to how layout translation is implemented (see [Architecture](#architecture)).
- **Privacy-respecting** — never touches password fields or other secure input contexts, and doesn't buffer anything while one is focused.
- **Zero dependencies, zero network access** — spelling validation uses macOS's own offline spell checker.

## Requirements

- macOS with two or more keyboard layouts enabled (System Settings → Keyboard → Input Sources).
- Two system permissions — **Input Monitoring** and **Accessibility**. OopsieDaisy will prompt for both on first launch.

## Installation

OopsieDaisy isn't on the App Store — and can't be, by design (see [why](#why-not-on-the-app-store)). Build it from source with Xcode:

```bash
git clone https://github.com/oleksandryolkin/OopsieDaisy.git
cd OopsieDaisy
open OopsieDaisy.xcodeproj
```

Press **Run** in Xcode. On first launch, macOS will ask for permissions in two stages:

1. **Input Monitoring** — grant it (System Settings → Privacy & Security → Input Monitoring), then **quit and relaunch** OopsieDaisy for the grant to take effect. Without this, it can't observe keystrokes at all.
2. **Accessibility** — this one is only requested the first time OopsieDaisy actually tries to *fix* a word, i.e. the first time you type something in the wrong layout after launching. Grant it (System Settings → Privacy & Security → Accessibility); no relaunch needed for this one.

If OopsieDaisy is missing either permission, the menu bar item shows which one and offers a shortcut straight to the right Settings pane.

## Permissions & privacy

OopsieDaisy asks for two system permissions, and nothing else — no network access, no analytics:

- **Input Monitoring** — lets it observe keystrokes system-wide, so it can tell what word you just typed.
- **Accessibility** — needed to actually perform the fix: synthesizing the backspace/retype (`CGEventPost`) and switching the active keyboard layout (`TISSelectInputSource`) both require it, even though merely *observing* keystrokes only needs Input Monitoring.

- It **never** reads or stores the content of what you type beyond the single word currently in progress, which is discarded the moment you move on to the next one.
- It **never** processes input while a secure field (like a password box) has focus — checked via `IsSecureEventInputEnabled`, before a single keystroke is buffered.
- A short built-in exclusion list (Terminal, code editors, password managers) skips autocorrection in contexts where "gibberish" is often intentional.

## Supported layouts

Layout translation is implemented using macOS's own `UCKeyTranslate` API against the real layout data of the keyboards you have enabled — not a hardcoded character table. That means it generalizes beyond Ukrainian/English to most alphabetic layout pairs where a letter corresponds to a physical key.

| Category | Support |
|---|---|
| Latin ↔ Cyrillic (e.g. English/Ukrainian) | ✅ Fully supported, tested |
| Latin layouts with dead-key diacritics (Spanish, French, German, Portuguese...) | ⚠️ Plain letters work; accented characters composed via dead keys may not reconstruct perfectly |
| CJK (Chinese, Japanese, Korean) | ❌ Not applicable — these use IME-based composition (pinyin/romaji → candidate selection), a fundamentally different input model than direct layout mapping |

## Architecture

| Component | Responsibility |
|---|---|
| `KeyboardMonitor` | Listen-only `CGEventTap`; buffers the in-progress word by physical key code, never blocks real input |
| `LayoutConverter` | Reconstructs what any other enabled layout would have produced, via `UCKeyTranslate` on that layout's own data |
| `WordValidator` | Offline word-validity check backed by `NSSpellChecker` — no bundled dictionaries |
| `TextInjector` | Synthesizes the backspace + retype correction as real key events, tagged to avoid feedback loops |
| `InputSourceManager` | Reads/switches the active keyboard layout via the TIS APIs |
| `CorrectionEngine` | Ties it all together: decides whether a finished word needs fixing, and applies the fix |

## Why not on the App Store?

App Sandbox — required for App Store distribution — blocks the system-wide `CGEventTap` and cross-process `CGEventPost` calls this app depends on, regardless of user-granted permissions. Apple doesn't offer an entitlement to unlock this for sandboxed apps. This puts OopsieDaisy in the same category as tools like Karabiner-Elements and BetterTouchTool, which are distributed directly rather than through the App Store.

## Status

Early-stage MVP. Built and tested on macOS with Xcode 26.
