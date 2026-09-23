# Kail Kampung — Godot Mobile

Native Godot port of **Kail Kampung v0.4**, a top-down Indonesian fishing RPG.

## Open in Godot
1. Install a Godot 4.x release compatible with this project (4.3+).
2. Open Godot Project Manager.
3. Click **Import**.
4. Select this repository's `project.godot`.
5. Open the project and press **F5**.

The project uses a **720x1280 portrait viewport** and includes touch controls, so it is mobile-first.

## Mobile controls
- D-pad: walk
- `E`: interact with NPCs / gates
- `MANCING`: cast, hook, hold/release during fish fight
- `STATUS`: character stats and progression

Keyboard testing is also available with WASD/arrows, E and Space.

## Native Godot features currently migrated
- Desa Karang Tirta and Rawa Kedung Wungu
- NPC personality/banter system with one random banter per interaction
- Pak Darto starter quest
- Pak Beni 70 cm record side quest
- Bu Yati fish sales
- Bang Rian bait shop
- Mbak Tika coffee/jamu shop
- 12 fish species
- Fish traits: calm, runner, diver, heavy, ambusher, brutal and slippery
- Fishing tension/progress minigame
- Random fishing conditions (feeding/current/quiet)
- Day/night and weather visuals
- XP, levels, titles and stamina
- Local save using `user://kail_kampung_save.json`
- Android export preset

## Android
The repository includes an Android export preset with package ID:

`com.bravocompanion.kailkampung`

Before exporting APK/AAB, configure the Android export requirements in your local Godot editor. For a Play Store release, create a release keystore locally and configure it in the Android export preset. **Do not commit keystores or passwords.**

## Migration note
This repository is now the **native Godot/mobile codebase**. The earlier browser prototype remains a design/gameplay reference but is not required to open or run this Godot project.
