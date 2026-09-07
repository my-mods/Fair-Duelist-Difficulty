# Fair Duelist Difficulty

Modifies the existing Duelist preset in The Blood of Dawnwalker.
Select Fair Duelist in the game's difficulty settings. This is the renamed Duelist slot, not a fifth preset.

[Download the Vortex archive](https://github.com/my-mods/Fair-Duelist-Difficulty/raw/refs/heads/main/Fair-Duelist.zip)

Enemy health: 75% of Fair (25% less health).
Enemy damage: Fair (100%, reduced from Duelist 160%).
Player combat stamina costs: Fair (100%, reduced from Duelist 175%).
Enemy aggression, animation speed, parry timing and directional indicator settings: original Duelist.

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
After the first launch, edit `%LOCALAPPDATA%/Dawnwalker/Saved/Config/Windows/FairDuelist.ini`, then restart the game and load your save. Keep RPG Difficulty on Fair Duelist. Values are multipliers relative to original Duelist:

```ini
[FairDuelist]
referenceDifficulty=Duelist
enabled=true
enemyHealthMultiplier=0.833333333333
enemyDamageMultiplier=0.625
staminaCostMultiplier=0.571428571429
debugLogging=false
```

Each multiplier accepts 0.1 through 5.0. Lower health shortens fights; lower enemy damage makes hits less punishing; lower stamina cost makes combat actions cheaper. Invalid settings disable INI overrides for that launch. `enabled=false` disables the INI overrides; the packaged 75% health preset remains active. The INI is read at startup. Action difficulty and unblockable attacks are not controlled by these values.

The tooltips describe the packaged default of 25% less health; personal INI values take precedence. Set `debugLogging=true` for setup values and failures in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`. If the personal INI could not be created, copy the packaged `FairDuelist.defaults.ini` there as `FairDuelist.ini`.

The mod ships a defaults template and creates the personal INI only when missing. To restore the packaged balance, disable INI overrides. To remove the entire mod, disable it through Vortex and deploy.

A multiplier of 1.0 means original Duelist. Defaults preserve the existing balance: 75% of Fair enemy health, Fair damage and Fair stamina costs. For 25% less health than original Duelist, use enemyHealthMultiplier=0.75 (67.5% of Fair health).

Existing INIs without referenceDifficulty use the old Fair reference and are converted while retaining their effective settings. Migration replaces the INI after saving the complete original as FairDuelist.ini.fair-reference.bak; comments remain in that backup. Back up personal preferences before updating. If migration cannot write safely, the old file stays supported using its Fair reference. Do not manually add the new marker without converting the old numbers.
