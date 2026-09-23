# Kail Kampung — Godot Mobile

Native Godot port of **Kail Kampung v0.4**, a top-down Indonesian fishing RPG.

## Open in Godot
1. Install Godot 4.3 or newer.
2. Open Godot Project Manager.
3. Click **Import**.
4. Select this repository's `project.godot`.
5. Open the project and press **F6/F5**.

The project uses a 720x1280 portrait viewport and includes touch controls, so it is designed for mobile first.

## Mobile controls
- D-pad: walk
- `E`: interact with NPCs / gates
- `MANCING`: cast, hook, hold/release during fish fight
- `STATUS`: character stats and progression

Keyboard test controls are also included: WASD/arrows, E, Space.

## Current native Godot features
- Desa Karang Tirta and Rawa Kedung Wungu
- NPC personality/banter system
- One random banter per NPC interaction
- Pak Darto starter quest
- Pak Beni 70 cm record side quest
- Bu Yati fish sales
- Bang Rian bait shop
- Mbak Tika coffee/jamu shop
- 12 fish species
- Fish traits: calm, runner, diver, heavy, ambusher, brutal, slippery
- Fishing tension/progress minigame
- Random spot events (feeding/current/quiet)
- Day/night + weather visuals
- XP, levels, titles, stamina
- Inventory/save system using `user://kail_kampung_save.json`
- Android export preset

## Android
Godot still needs the local Android SDK/JDK and Android export templates installed before creating APK/AAB files.
The included Android preset uses package ID:

`com.bravocompanion.kailkampung`

For Google Play release, create a release keystore locally and configure it in Godot Editor > Export > Android. Do not commit the keystore or passwords.

## Legacy browser build
The previous HTML v0.4 is kept in `legacy/Kail_Kampung_v0.4.html` as a reference while the game is migrated to native Godot.
