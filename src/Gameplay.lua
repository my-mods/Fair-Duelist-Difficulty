-- Fair Duelist INI configuration. Original code: MIT.
local dir = debug.getinfo(1, 'S').source:sub(2):match('^(.*[/\\])')
local Config = dofile(dir .. 'Config.lua')
local cfg, path = Config.load(dir)
local diagnostics = dofile(dir .. 'UE4SSCommonDiagnostics.lua').new({debugLogging=cfg.debugLogging,prefix='[FairDuelist] ',output=function(text) print(text .. '\n') end})
local function log(message) diagnostics.debug(message) end
if not cfg.enabled then return end
local Aggression = dofile(dir .. 'Aggression.lua')
local game = Config.gameValues(cfg)
local assetPath = '/Game/_Dawnwalker/Combat/DA_DifficultyConfig.DA_DifficultyConfig'
local applied, candidate = nil, nil
local lastError, started, searches, writes = nil, 0, 0, 0
local function valid(object) return object and object:IsValid() end
local function apply()
    local object = candidate
    if not valid(object) then
        searches = searches + 1
        object = StaticFindObject(assetPath)
    end
    if not valid(object) then return false end
    if object:GetFullName() ~= 'DifficultyConfig ' .. assetPath then candidate = nil; return false end
    if valid(applied) and applied:GetAddress() == object:GetAddress() then return true end
    -- Borrowed map/struct wrappers are used only inside this game-thread callback.
    local row = object.RPGDifficulties:Find(3):get()
    local old = {row.HealthMultiplier, row.DamageMultiplier, row.PlayerCombatStaminaCostsMultiplier}
    for _, value in ipairs(old) do assert(type(value) == 'number', 'Unexpected difficulty schema') end
    local applyAggression, restoreAggression = Aggression.prepare(object, cfg.referenceDifficulty, cfg.enemyAggressionMultiplier, Session)
    local changedWrites = 0
    local ok, err = pcall(function()
        changedWrites = applyAggression()
        for field, value in pairs({HealthMultiplier=game.enemyHealthMultiplier,
            DamageMultiplier=game.enemyDamageMultiplier, PlayerCombatStaminaCostsMultiplier=game.staminaCostMultiplier}) do
            local changed = Session.change(tostring(object:GetAddress())..':RPG:'..field, function()
                if not valid(object) then return nil, false end
                return object.RPGDifficulties:Find(3):get()[field]
            end, function(target) object.RPGDifficulties:Find(3):get()[field] = target end, value)
            if changed then changedWrites = changedWrites + 1 end
        end
        assert(math.abs(row.HealthMultiplier - game.enemyHealthMultiplier) < 0.00001, 'Health write failed')
        assert(math.abs(row.DamageMultiplier - game.enemyDamageMultiplier) < 0.00001, 'Damage write failed')
        assert(math.abs(row.PlayerCombatStaminaCostsMultiplier - game.staminaCostMultiplier) < 0.00001, 'Stamina write failed')
    end)
    if not ok then
        restoreAggression()
        row.HealthMultiplier, row.DamageMultiplier, row.PlayerCombatStaminaCostsMultiplier = table.unpack(old)
        error(err)
    end
    applied, candidate = object, nil
    writes = writes + changedWrites
    if cfg.debugLogging then log(string.format('Applied %s-relative health=%.3f damage=%.3f stamina=%.3f aggression=%s; searches=%d writes=%d elapsed=%.3fs; INI=%s', cfg.referenceDifficulty, cfg.enemyHealthMultiplier, cfg.enemyDamageMultiplier, cfg.staminaCostMultiplier, cfg.enemyAggressionMultiplier, searches, writes, os.clock()-started, path)) end
    return true
end
local pending = false
local function wake(object)
    if object then candidate = object end
    if pending then return end
    pending = true
    ExecuteInGameThreadWithDelay(16, function()
        pending = false
        local ok, err = pcall(apply)
        if not ok and tostring(err) ~= lastError then
            lastError = tostring(err)
            diagnostics.error('Difficulty application failed: %s', lastError)
        end
    end)
end
started = os.clock()
NotifyOnNewObject('/Script/DogwoodStats.DifficultyConfig', wake)
wake()
