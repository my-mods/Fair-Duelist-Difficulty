Fair Duelist Difficulty

- Added configurable enemy attack cooldown and coordination profiles.
- Personal INI now uses Saved/Config, inherits shipped defaults, and preserves existing files and legacy preferences.


Enemy health is now 75% of Fair, reduced from 90%. Enemy damage and combat stamina costs remain at Fair values. Preset and RPG descriptions now state the 25% enemy health reduction.

Add INI configuration for health, damage and stamina multipliers. Defaults preserve 75% of Fair enemy health and Fair damage/stamina costs. INI overrides require UE4SS.

INI multipliers now use original Duelist as their reference. Legacy Fair-relative values are converted with the same effective balance. Fixed valid INI settings incorrectly disabling runtime overrides.
