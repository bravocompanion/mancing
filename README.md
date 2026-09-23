# Kail Kampung — Godot Mobile

Native Godot mobile build of **Kail Kampung v0.5**, a top-down Indonesian fishing RPG.

## Open in Godot
1. Install a Godot 4.x release compatible with this project (4.3+).
2. Open Godot Project Manager.
3. Click **Import**.
4. Select this repository's `project.godot`.
5. Open the project and press **F5**.

The project uses a **720x1280 portrait viewport** and is designed mobile-first.

## Mobile controls
- D-pad: walk
- `E`: interact with NPCs / gates
- `MANCING`: cast, hook, hold/release during fish fight
- `STATUS`: character stats and progression
- `MISI`: daily mission and reward
- `ALAT`: gear upgrades when standing near Bang Rian

Keyboard testing is also available with WASD/arrows, E and Space.

## v0.5 highlights
- Daily fishing missions with money + XP rewards
- Daily fish-market multiplier that changes selling prices
- Functional Rod / Line / Hook upgrades up to level 3
- Mobile vibration feedback when a fish bites and when a catch lands
- Gurame added to Desa Karang Tirta
- Legendary-style **Tapah Tua Kedung Wungu** encounter
  - requires at least angler level 4
  - only appears in Rawa Kedung Wungu
  - only during a storm at night
- Trophy-record notification for unusually large catches
- Compact v0.5 HUD overlay showing current market and daily mission
- v0.5 systems save separately in `user://kail_kampung_v05_ext.json`, while the original game save remains compatible

## Core game features
- Desa Karang Tirta and Rawa Kedung Wungu
- NPC personality/banter system with one random banter per interaction
- Pak Darto starter quest
- Pak Beni 70 cm record side quest
- Bu Yati fish sales
- Bang Rian bait shop and gear upgrades
- Mbak Tika coffee/jamu shop
- 13+ fish species depending on encounter conditions
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

Current Android version metadata:
- version code: `5`
- version name: `0.5`

Before exporting APK/AAB, configure the Android export requirements in your local Godot editor. For a Play Store release, create a release keystore locally and configure it in the Android export preset. **Do not commit keystores or passwords.**

## Updating locally
If you already cloned the repository:

```bash
git checkout main
git pull origin main
```

If Godot asks whether to reload changed files from disk, choose **Reload from Disk**.
