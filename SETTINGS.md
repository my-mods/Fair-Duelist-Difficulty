# Settings

Install [Mod Setting Menu 1.0.5 or later](https://www.nexusmods.com/thebloodofdawnwalker/mods/271) and UE4SS through Vortex. On first use, load a save once to initialize the settings file, then return to Main Menu > Mod Settings > All Mods. Select this mod, change settings and press Apply. **Load a save after Apply.** Restore discards unapplied changes; Reset selects this mod’s defaults.

The stable menu ID is `oOCamilleOo_FairDuelist`. The mod generates `settings.ini` beside `mod_settings.ini` in its UE4SS mod folder. This generated file is the authoritative settings store and is not shipped in the ZIP. Existing supported preferences are imported on first use. After the new settings are saved and verified, the successfully imported legacy files are deleted if their contents are unchanged. Migration or save failures retain the originals. Cleanup failures are logged and do not prevent using the new settings. Files left by an earlier migration are not deleted automatically. Back up `settings.ini` before removing/reinstalling the mod or moving its folder. Restore that backup into the same runtime folder before launching. Do not restore an old INI over it.

Missing, duplicate or invalid settings stop configuration loading and are reported in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`. Preserve the file before correcting it. If a menu save fails, preserve its temporary/backup files and follow the menu’s recovery instructions. Settings are read only when a save loads. Waiting at the main menu performs no settings work; travel and possession events use the current snapshot. Settings are never polled. `debugLogging` controls additional diagnostic logging; it defaults to Off.

| Group | Setting | Choices or range |
| --- | --- | --- |
| General | Runtime difficulty overrides | Off, On |
| Balance | Reference difficulty | Story, Fair, Challenging, Duelist |
| Balance | Enemy health | -90% to 400% relative to the reference |
| Balance | Enemy damage | -90% to 400% relative to the reference |
| Balance | Combat stamina cost | -90% to 400% relative to the reference |
| Balance | Enemy attack pressure | -90% to 400% relative to the reference |
| Diagnostics | Debug logging | Off, On |

The four balance sliders display percentage adjustments: `0%` matches the reference difficulty, `-25%` reduces its value by a quarter, and `25%` increases it by a quarter. Sliders move in one percentage point steps. Existing multiplier preferences convert automatically on the next save load without rounding; the original file is retained as `settings.ini.backup`. Display values are rounded to one decimal place. Attack pressure adjusts inverse cooldowns, not animation speed.

Console commands are not used to change settings.

Conditional rows and groups show relevant controls as you edit. Hidden options keep their saved values; hiding an option does not reset it. The interface uses toggles, labeled choices and sliders; the numeric representation in settings.ini is an implementation detail.
