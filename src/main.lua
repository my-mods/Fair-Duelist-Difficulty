-- Fair Duelist INI configuration. Original code: MIT.
local dir = debug.getinfo(1, 'S').source:sub(2):match('^(.*[/\\])')
local Config = dofile(dir .. 'Config.lua')
local cfg, path = Config.load(dir)
local function log(message) if cfg.debugLogging then print('[FairDuelist] ' .. message .. '\n') end end
if not cfg.enabled then return end
local Aggression = dofile(dir .. 'Aggression.lua')
local game = Config.gameValues(cfg)
local assetPath = '/Game/_Dawnwalker/Combat/DA_DifficultyConfig.DA_DifficultyConfig'
local pending, attempts, applied, candidate, active = false, 0, nil, nil, false
local lastError, started, searches, writes = nil, 0, 0, 0
local function valid(object) return object and object:IsValid() end
local schedule
local function apply()
    local object = candidate
    if not valid(object) then
        searches = searches + 1
        object = StaticFindObject(assetPath)
    end
    if not valid(object) then return false end
    if object:GetFullName() ~= 'DifficultyConfig ' .. assetPath then candidate = nil; return false end
    if applied == object then return true end
    -- Borrowed map/struct wrappers are used only inside this game-thread callback.
    local row = object.RPGDifficulties:Find(3):get()
    local old = {row.HealthMultiplier, row.DamageMultiplier, row.PlayerCombatStaminaCostsMultiplier}
    for _, value in ipairs(old) do assert(type(value) == 'number', 'Unexpected difficulty schema') end
    local applyAggression, restoreAggression, aggressionWrites = Aggression.prepare(object, cfg.enemyAggression)
    local ok, err = pcall(function()
        applyAggression()
        row.HealthMultiplier = game.enemyHealthMultiplier
        row.DamageMultiplier = game.enemyDamageMultiplier
        row.PlayerCombatStaminaCostsMultiplier = game.staminaCostMultiplier
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
    writes = writes + 3 + aggressionWrites
    if cfg.debugLogging then log(string.format('Applied Duelist-relative health=%.3f damage=%.3f stamina=%.3f aggression=%s; searches=%d writes=%d elapsed=%.3fs; INI=%s', cfg.enemyHealthMultiplier, cfg.enemyDamageMultiplier, cfg.staminaCostMultiplier, cfg.enemyAggression, searches, writes, os.clock()-started, path)) end
    return true
end
schedule = function()
    if pending then return end
    pending = true
    ExecuteInGameThreadWithDelay(250, function()
        pending = false
        attempts = attempts + 1
        local ok, done = pcall(apply)
        if ok and done then return end
        if not ok then lastError = tostring(done) end
        if attempts < 20 then schedule()
        elseif cfg.debugLogging then log('Setup stopped after 20 attempts: ' .. (lastError or 'difficulty asset not ready')) end
    end)
end
local function wake(object, reset)
    if not active then return end
    if object then candidate = object end
    if reset then applied, candidate = nil, nil end
    if pending then return end
    attempts, searches, writes, started, lastError = 0, 0, 0, os.clock(), nil
    schedule()
end
for _, api in ipairs({'StaticFindObject', 'ExecuteInGameThreadWithDelay', 'NotifyOnNewObject', 'RegisterLoadMapPostHook'}) do
    if type(_G[api]) ~= 'function' then log('Required UE4SS API unavailable: '..api); return end
end
local ok, err = pcall(function()
    NotifyOnNewObject('/Script/DogwoodStats.DifficultyConfig', function(object) wake(object, false) end)
    RegisterLoadMapPostHook(function() wake(nil, true) end)
end)
if not ok then log('Lifecycle registration failed: '..tostring(err)); return end
active = true
wake(nil, false)
