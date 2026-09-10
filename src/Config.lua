local M = {}
M.baseline = {enemyHealthMultiplier=0.9, enemyDamageMultiplier=1.6, staminaCostMultiplier=1.75}
M.defaults = {referenceDifficulty='Duelist', enabled=true, enemyHealthMultiplier=0.75/0.9, enemyDamageMultiplier=1/1.6, staminaCostMultiplier=1/1.75, debugLogging=false, enemyAggression='game'}
function M.parse(text, inherited)
    local cfg, errors, section, seen = {}, {}, '', {}
    for key, value in pairs(inherited or M.defaults) do cfg[key] = value end
    for line in (text .. '\n'):gmatch('(.-)\r?\n') do
        line = line:gsub('^\239\187\191', ''):gsub('[;#].*$', ''):match('^%s*(.-)%s*$')
        local heading = line:match('^%[([^%]]+)%]$')
        if heading then section = heading
        elseif line ~= '' and section == 'FairDuelist' then
            local key, value = line:match('^([%w_]+)%s*=%s*(.-)%s*$')
            if not key or M.defaults[key] == nil or seen[key] then errors[#errors+1] = 'Invalid or duplicate setting: '..line
            else
                seen[key] = true
                if key == 'referenceDifficulty' then
                    if value == 'Duelist' then cfg[key] = value else errors[#errors+1] = 'referenceDifficulty must be Duelist' end
                elseif key == 'enemyAggression' then
                    value = value:lower()
                    if ({game=true,story=true,fair=true,challenging=true,duelist=true})[value] then cfg[key]=value
                    else errors[#errors+1]='enemyAggression must be game, story, fair, challenging or duelist' end
                elseif type(M.defaults[key]) == 'boolean' then
                    value = value:lower()
                    if value == 'true' or value == 'false' then cfg[key] = value == 'true'
                    else errors[#errors+1] = 'Expected true/false: '..key end
                else
                    local n = tonumber(value)
                    if n and n == n and n >= 0.1 and n <= 5 then cfg[key] = n
                    else errors[#errors+1] = 'Expected multiplier between 0.1 and 5: '..key end
                end
            end
        end
    end
    local legacy = not seen.referenceDifficulty
    if legacy then
        for key, base in pairs(M.baseline) do if seen[key] then cfg[key] = cfg[key] / base end end
    end
    if #errors > 0 then
        for key, value in pairs(M.defaults) do if key ~= 'debugLogging' then cfg[key] = value end end
        cfg.enabled = false
    end
    return cfg, errors, legacy
end
function M.gameValues(cfg)
    local result = {}
    for key, base in pairs(M.baseline) do result[key] = cfg[key] * base end
    return result
end
function M.serialize(cfg)
    return string.format([=[; FAIR DUELIST - PERSONAL BALANCE SETTINGS
; In your personal INI, uncomment and edit overrides, then restart and load.
; Keep RPG Difficulty set to Fair Duelist. UE4SS is needed for INI overrides.
; Lines starting with ; are comments and do not change any settings.
;
; REFERENCE: ORIGINAL DUELIST
; 1.0 = original Duelist value; 0.75 = 25%% less; 0.5 = half; 1.25 = 25%% more.
; Each multiplier accepts 0.1 through 5.0. Use a decimal point, not a comma.
; Lower enemy health = fewer hits needed to kill enemies.
; Lower enemy damage = less damage received from enemy attacks.
; Lower stamina cost = less stamina spent on combat actions, not a larger pool.
; These settings do not change your maximum health, red/unblockable attacks,
; boss health-segment mechanics, attack speed, or parry timing.
; Action Difficulty and directional indicators are separate in-game settings.
;
; EXAMPLES: RPG VALUES ONLY (health / damage / stamina cost)
; Copy the three numbers onto their matching active settings below.
; Do not add duplicate active keys or uncomment all examples together.
;
; Original Duelist: 1.0 / 1.0 / 1.0
; Fair:             1.111111111111 / 0.625 / 0.571428571429
; Challenging:      1.111111111111 / 0.8125 / 0.857142857143
; Story:            0.555555555556 / 0.25 / 0.285714285714
; Fair Duelist:     0.833333333333 / 0.625 / 0.571428571429 (packaged default)
;
; Fair/Challenging health exceeds 1.0 because original Duelist has 10%% less
; enemy health than Fair. These examples reproduce each preset's RPG values;
; they do not select its Action difficulty or its other gameplay options.
; The packaged default is 75%% of Fair health, with Fair damage/stamina costs.
; For 25%% less health than DUELIST instead, set enemyHealthMultiplier=0.75.
;
[FairDuelist]
; Leave this marker set to Duelist. Old INIs without it use the Fair reference.
; Do not add this marker to an old INI without converting its values.
referenceDifficulty=Duelist

; false disables INI overrides only; the packaged default preset remains active.
enabled=%s

; Enemy health relative to original Duelist (default: 75%% of Fair health).
enemyHealthMultiplier=%.12g

; Enemy attack damage relative to original Duelist (default: Fair damage).
enemyDamageMultiplier=%.12g

; Your combat stamina costs relative to original Duelist (default: Fair costs).
staminaCostMultiplier=%.12g

; Attack pressure override for ACTION Difficulty = Fair Duelist only.
; game = preserve the game settings (default).
; story / fair / challenging / duelist = that preset's attack cooldowns
; and permission to attack while other enemies attack or react.
; Does not copy animation/parry scaling or change scripted unblockable attacks.
enemyAggression=%s

; true logs applied values and configuration errors to:
; Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log
debugLogging=%s
]=], tostring(cfg.enabled), cfg.enemyHealthMultiplier, cfg.enemyDamageMultiplier, cfg.staminaCostMultiplier, cfg.enemyAggression, tostring(cfg.debugLogging))
end

function M.load(dir)
    return dofile(dir .. 'ConfigStore.lua').load(dir, M)
end
return M
