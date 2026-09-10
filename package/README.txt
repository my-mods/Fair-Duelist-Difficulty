# Fair Duelist Difficulty

Modifies the existing Duelist preset in The Blood of Dawnwalker.
Select Fair Duelist in the game's difficulty settings. This is the renamed Duelist slot, not a fifth preset.

[Download the Vortex archive](https://github.com/my-mods/Fair-Duelist-Difficulty/raw/refs/heads/main/Fair-Duelist.zip)

Enemy health: 75% of Fair (25% less health).
Enemy damage: Fair (100%, reduced from Duelist 160%).
Player combat stamina costs: Fair (100%, reduced from Duelist 175%).
Enemy attack pressure: configurable; defaults to the selected Action preset. Animation speed, parry timing and directional indicators remain controlled by the game.

Customization: keep RPG Difficulty on Fair Duelist to retain your INI balance (defaults: enemy health 75%, damage 100%, and combat stamina costs 100%). Changing Action Difficulty changes attack speed, aggression and parry timing, but does not change the RPG values. Indicators, consumables and other custom options can be changed independently. The overall preset may display Custom; that alone does not remove the RPG changes. Selecting another RPG difficulty or overall preset changes the balance accordingly. For the exact intended setup, keep Action Difficulty on Fair Duelist and directional indicators off.
Other presets and player maximum health are unchanged.

Installation: import Fair-Duelist.zip into Vortex, choose the game-root installer if prompted, enable and deploy. Restart the game and select Fair Duelist.
Requirements: The Blood of Dawnwalker; Vortex with its Dawnwalker extension. UE4SS is required for INI overrides; the packaged default preset can run without it.
Update: replace the same Vortex mod entry with the new archive and deploy.
Uninstall: disable/remove this mod in Vortex and deploy; restart the game.
Conflicts: replaces /Game/_Dawnwalker/Combat/DA_DifficultyConfig, /Game/_Dawnwalker/Combat/StringTables/ST_Difficulties, and /Game/_Dawnwalker/System/Settings/ST_Settings_Tab_Game. Text mods replacing these string tables may conflict. Use only one mod replacing each of these assets; Fair Duelist Difficulty must win for these values to apply. Archive filenames alone cannot detect this conflict.
Compatibility: built for the PC version; conflicts are listed above.

Original difficulty data belongs to Rebel Wolves and its respective rights holders. This mod changes three difficulty multipliers and the corresponding menu text.

## INI configuration

The INI feature requires UE4SS with ExecuteInGameThreadWithDelay support (develop build 97b7e501c or compatible). [UE4SS downloads](https://github.com/UE4SS-RE/RE-UE4SS/releases).
After the first launch, edit `%LOCALAPPDATA%/Dawnwalker/Saved/Config/FairDuelist.ini`, then restart the game and load your save. Keep RPG Difficulty on Fair Duelist. Values are multipliers relative to original Duelist:

```ini
[FairDuelist]
referenceDifficulty=Duelist
enabled=true
enemyHealthMultiplier=0.833333333333
enemyDamageMultiplier=0.625
staminaCostMultiplier=0.571428571429
enemyAggression=game
debugLogging=false
```

Each multiplier accepts 0.1 through 5.0. Lower health shortens fights; lower enemy damage makes hits less punishing; lower stamina cost makes combat actions cheaper. Invalid settings disable INI overrides for that launch. `enabled=false` disables the INI overrides; the packaged 75% health preset remains active. The INI is read at startup. The three multipliers affect RPG balance. The aggression setting affects the Fair Duelist Action slot only.

The tooltips describe the packaged default of 25% less health; personal INI values take precedence. Set `debugLogging=true` for setup values and failures in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`. If the personal INI could not be created, copy the packaged `FairDuelist.defaults.ini` there as `FairDuelist.ini`.

The personal INI follows the same location and override rules as the other Dawnwalker mods: `%LOCALAPPDATA%/Dawnwalker/Saved/Config/FairDuelist.ini` (no Windows subfolder). On first launch, the mod creates a commented reference. Uncomment only settings you want to override; omitted/commented values inherit the shipped `FairDuelist.defaults.ini`, which is read every startup. Keep `referenceDifficulty=Duelist` active. Existing personal files are never rewritten. The personal file is outside Vortex-managed directories.

`enemyAggression=game` preserves the selected Action preset. With Action Difficulty set to Fair Duelist, choose `story`, `fair`, `challenging`, or `duelist` to copy that preset's attack cooldowns and permissions for attacking while other enemies attack or react. For example, `enemyAggression=fair` combines Fair attack pressure with Duelist animation/parry settings. Other Action slots remain unchanged. This does not copy level-based AI scaling, animation speed, parry windows, boss phase mechanics, or scripted red/unblockable attacks. It cannot guarantee fewer unblockables from a boss.

To restore inherited settings, comment out your overrides and restart. `enabled=false` disables runtime overrides while the packaged preset remains installed.

A multiplier of 1.0 means original Duelist. Defaults preserve the existing balance: 75% of Fair enemy health, Fair damage and Fair stamina costs. For 25% less health than original Duelist, use enemyHealthMultiplier=0.75 (67.5% of Fair health).

If the new path is missing, an existing `Saved/Config/Windows/FairDuelist.ini` is copied first, or a legacy `Scripts/FairDuelist.ini` is copied if present. The source and its comments remain untouched. Existing INIs without `referenceDifficulty` retain the old Fair reference for their explicit numeric values; conversion happens only in memory. Do not add the marker to an old INI without converting its numbers. Unreadable or invalid files disable runtime overrides and report the problem in UE4SS.log without overwriting preferences.
