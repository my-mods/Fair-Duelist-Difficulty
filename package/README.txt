# Fair Duelist - Customizable Difficulty

Customize enemy health, damage, combat stamina costs and attack delays with absolute percentages. Choose Story, Fair, Challenging or Duelist to load its balance values, then adjust individual controls to create Custom balance.

[Download the Vortex archive](https://github.com/my-mods/Fair-Duelist-Customizable-Difficulty/raw/refs/heads/main/Fair-Duelist-Customizable-Difficulty.zip)

`100%` means the unscaled game value, `50%` means half, and `150%` means one and a half times. These are absolute values: damage at `0%` is zero damage. Attack delays use the same scale; lower delays allow more frequent attacks.

| Balance preset | Enemy health | Enemy damage | Combat stamina cost | Attack delay | Low-health delay | Ranged delay |
| --- | --- | --- | --- | --- | --- | --- |
| Story | 50% | 40% | 50% | 200% | 200% | 200% |
| Fair | 100% | 100% | 100% | 140% | 120% | 140% |
| Challenging | 100% | 130% | 150% | 120% | 100% | 120% |
| Duelist | 90% | 160% | 175% | 100% | 60% | 100% |

Choose and confirm a difficulty in the game settings to load its standard balance, then open Mod Settings to customize individual values. Apply saves your changes; load a save to use them. Restore discards unapplied changes, and Reset selects Duelist defaults. The game retains its original Story/Fair/Challenging/Duelist names.

**Choosing and confirming a difficulty in the game's settings replaces your custom balance.** A full preset resets all balance controls. Changing only RPG Difficulty resets health, damage and stamina costs; changing only Action Difficulty resets attack delays and the coordinated-attack option. Canceling an unconfirmed preview preserves your saved custom balance. The mod controls these listed values; animation speed, parry windows, indicators and other game options follow the game's own settings.

## Installation and updates

Requires UE4SS for Dawnwalker and [Mod Setting Menu 1.0.5.1](https://www.nexusmods.com/thebloodofdawnwalker/mods/271). Uses the original menu without replacing any of its files.

Close the game and back up your generated `Dawnwalker/Binaries/Win64/ue4ss/Mods/FairDuelist/settings.ini`. Replace/reinstall the existing Fair Duelist entry from `Fair-Duelist-Customizable-Difficulty.zip` through Vortex. When replacing the build that included a menu extension, disable Fair Duelist and deploy first to restore the original menu file, then reinstall this ZIP. Deploy and restart. When updating from the old asset-based package, disable it and deploy first so Vortex removes `zzz_FairDuelist_P.pak`, `.ucas` and `.utoc`, then install the replacement archive. Keep only one Fair Duelist entry active. Reinstalling replaces the package layout; redeployment alone does not change an old installer plan.

On first use, load a save, then open Mod Settings > Fair Duelist - Customizable Difficulty. Outdated or invalid settings files are replaced with current Duelist defaults at startup. Old multipliers and personal INI values are not imported. New installations start from the currently selected native RPG and Action difficulties. See [SETTINGS.md](SETTINGS.md) for configuration and recovery.

To uninstall, disable/remove Fair Duelist in Vortex and deploy. Restart the game. Back up generated preferences before removing the mod.

## Compatibility

The runtime uses Lua and does not replace the game's difficulty data or string tables. At runtime, enabled overrides apply the same absolute balance values to all four difficulty rows; confirming a native difficulty selection resets the corresponding values. Other mods writing those same runtime fields conflict.

**Logging** is the final menu setting and the only diagnostic control. Leave it Off for normal play; On writes troubleshooting details to `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`. Failures are reported even when Logging is Off. No configuration polling is used.

## Credits

Original game difficulty data belongs to Rebel Wolves and its respective rights holders. Fair Duelist also bundles pinned MIT-licensed [ue4ss-common](https://github.com/my-mods/ue4ss-common) helpers; no separate shared-library installation is required.

# Settings

Choose and confirm a starting difficulty in the game's settings, then open Mod Settings > Fair Duelist - Customizable Difficulty to adjust individual controls. Press Apply, then load a save. Restore discards unapplied changes; Reset loads Duelist defaults. Warning: confirming another difficulty in the game's settings replaces the corresponding custom values; canceled previews preserve them.

All percentages are absolute, measured against the unscaled game value. `100%` is normal, `50%` is half, and `150%` is one and a half times. `0%` damage is zero damage. Attack-delay percentages measure cooldown length; a lower value means a shorter delay, rather than a slower animation.

| Setting | Range or choices |
| --- | --- |
| Override difficulty balance | Off, On |
| Enemy health | 0–500% |
| Enemy damage | 0–800% |
| Combat stamina cost | 0–875% |
| Enemy attack delay | 0–2000% |
| Low-health enemy attack delay | 0–2000% |
| Ranged enemy attack delay | 0–2000% |
| Attacks while another enemy blocks | Off, On |
| Logging | Off, On |

Sliders move by one percentage point and display one decimal place. Existing fractional preferences retain their precision until edited. Native Story/Fair/Challenging/Duelist values are listed in the README. Custom is recognized from the actual control values. The coordinated-attack option is Off for Story/Fair and On for Challenging/Duelist.

## Storage and migration

The stable menu ID is `oOCamilleOo_FairDuelist`; the runtime folder remains `FairDuelist`. Generated `settings.ini` is the authoritative store and is never shipped. Its version marker distinguishes absolute percentages from the older relative-percentage format.

At startup, outdated or invalid settings.ini files are replaced in full with current Duelist defaults. Old multipliers and personal INI values are not imported. Valid current settings are retained. Back up preferences before updating if you want to keep a reference. New installations initialize from the currently selected native RPG and Action difficulties on first save load.

Back up your generated preferences before reinstalling or uninstalling. Do not overwrite an absolute settings file with an old INI. Invalid, duplicate or missing required values stop loading and are reported in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`.

An interrupted conversion retains `settings.ini.absolute-v2.backup`; an interrupted later write retains `settings.ini.absolute-write.backup`. If the primary file is missing, preserve any transaction files and recover the complete matching backup before restarting. The mod refuses to overwrite unresolved backups or a settings file changed during a write.

## When values apply

Mod Settings Apply writes the selected percentages. Load a save to apply that snapshot to gameplay. Confirmed changes in the game's own difficulty settings reset and save the corresponding percentages and refresh the active combat settings. A full preset resets both RPG and action balance; an individual RPG/Action change resets only its controls. Unrelated settings changes and canceled difficulty previews preserve your balance. There are no console commands or background settings polls.

**Logging** is the final menu setting and the only diagnostic control. Leave it Off for normal play; On writes troubleshooting details to `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`.
