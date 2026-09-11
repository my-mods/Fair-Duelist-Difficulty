local M = {}
M.baselines = {
    Story={enemyHealthMultiplier=0.5, enemyDamageMultiplier=0.4, staminaCostMultiplier=0.5},
    Fair={enemyHealthMultiplier=1, enemyDamageMultiplier=1, staminaCostMultiplier=1},
    Challenging={enemyHealthMultiplier=1, enemyDamageMultiplier=1.3, staminaCostMultiplier=1.5},
    Duelist={enemyHealthMultiplier=0.9, enemyDamageMultiplier=1.6, staminaCostMultiplier=1.75},
}
M.defaults = {referenceDifficulty='Duelist', enabled=true, enemyHealthMultiplier=0.75/0.9, enemyDamageMultiplier=1/1.6, staminaCostMultiplier=1/1.75, debugLogging=false, enemyAggressionMultiplier=1}
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
                    if M.baselines[value] then cfg[key] = value else errors[#errors+1] = 'referenceDifficulty must be Story, Fair, Challenging or Duelist' end
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
    if #errors > 0 then
        for key, value in pairs(M.defaults) do if key ~= 'debugLogging' then cfg[key] = value end end
        cfg.enabled = false
    end
    return cfg, errors
end
function M.gameValues(cfg)
    local result = {}
    for key, base in pairs(M.baselines[cfg.referenceDifficulty]) do result[key] = cfg[key] * base end
    return result
end
function M.serialize(cfg)
    return string.format([=[; FAIR DUELIST - PERSONAL BALANCE SETTINGS
; Edit your personal INI in %%LOCALAPPDATA%%/Dawnwalker/Saved/Config/FairDuelist.ini.
; Uncomment settings to override shipped defaults; restart the game after editing.
; Select Fair Duelist for RPG Difficulty (health/damage/stamina)
; and Action Difficulty (aggression). UE4SS is required for these overrides.
; Commented/omitted settings inherit current shipped defaults.
;
; All numeric multipliers use the chosen referenceDifficulty's ORIGINAL values.
; 1.0 = reference value; 0.75 = 25%% less; 1.25 = 25%% more. Range: 0.1 to 5.0.
; Changing the reference changes what ALL multipliers mean, including inherited ones.
; To match a reference's RPG balance and attack pressure, set all multipliers to 1.
;
; EXAMPLES (reference / health / damage / stamina / aggression):
; Fair:        Fair / 1 / 1 / 1 / 1
; Challenging: Challenging / 1 / 1 / 1 / 1
; Story:       Story / 1 / 1 / 1 / 1
; Duelist:     Duelist / 1 / 1 / 1 / 1
; Shorter Fair fights: Fair / 0.75 / 1 / 1 / 0.75
; These examples do not change animation speed, parry timing or other game options.
;
[FairDuelist]
; Choose Story, Fair, Challenging or Duelist. This is a calculation baseline.
referenceDifficulty=%s

; false disables runtime overrides; the packaged native preset remains installed.
enabled=%s

; Lower health means fewer hits needed to kill enemies.
; Packaged default: 75%% of Fair health, expressed relative to Duelist.
enemyHealthMultiplier=%.12g

; Lower damage means enemy hits hurt less. Packaged default: Fair damage.
enemyDamageMultiplier=%.12g

; Lower cost means combat actions spend less stamina, not a larger stamina pool.
; Packaged default: Fair stamina costs.
staminaCostMultiplier=%.12g

; Scales cooldown-based attack pressure relative to the chosen reference.
; 1 = reference cooldowns; 0.75 = cooldowns 1.333x as long; 1.25 = 0.8x as long.
; Formula: cooldown = reference cooldown / enemyAggressionMultiplier.
; Group-attack permissions come from the chosen reference and are not scaled.
; Actual attack frequency also depends on AI behavior; zero cooldowns stay zero.
; Does not change level-based AI scaling, speed, parries, boss phases or scripted
; red/unblockable attacks. Keep ACTION Difficulty set to Fair Duelist.
enemyAggressionMultiplier=%.12g

; true logs setup values and failures to Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log.
debugLogging=%s
]=], cfg.referenceDifficulty, tostring(cfg.enabled), cfg.enemyHealthMultiplier, cfg.enemyDamageMultiplier, cfg.staminaCostMultiplier, cfg.enemyAggressionMultiplier, tostring(cfg.debugLogging))
end

function M.load(dir)
    return dofile(dir .. 'ConfigStore.lua').load(dir, M)
end
return M
