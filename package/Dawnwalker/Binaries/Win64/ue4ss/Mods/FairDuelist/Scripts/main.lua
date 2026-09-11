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
local applied, candidate, active = nil, nil, false
local readinessGeneration = 0
local lastError, started, searches, writes = nil, 0, 0, 0
local function valid(object) return object and object:IsValid() end
local readiness
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
    local applyAggression, restoreAggression, aggressionWrites = Aggression.prepare(object, cfg.referenceDifficulty, cfg.enemyAggressionMultiplier)
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
    if cfg.debugLogging then log(string.format('Applied %s-relative health=%.3f damage=%.3f stamina=%.3f aggression=%s; searches=%d writes=%d elapsed=%.3fs; INI=%s', cfg.referenceDifficulty, cfg.enemyHealthMultiplier, cfg.enemyDamageMultiplier, cfg.staminaCostMultiplier, cfg.enemyAggressionMultiplier, searches, writes, os.clock()-started, path)) end
    return true
end
local function wake(object, reset)
    if not active then return end
    if object then candidate = object end
    if reset then readinessGeneration=readinessGeneration+1;applied, candidate = nil, nil end
    -- A construction during a pending attempt updates its candidate only.
    -- A map reset cancels the obsolete generation and starts a fresh budget.
    local status = readiness.status()
    if not reset and (status.pending or status.running) then return end
    if reset or object then
        local ok, err = readiness.reset()
        if not ok then diagnostics.error('Readiness cancellation failed: %s',err); return end
    end
    searches, writes, started, lastError = 0, 0, os.clock(), nil
    readiness.wake()
end
for _, api in ipairs({'StaticFindObject', 'ExecuteInGameThreadWithDelay', 'CancelDelayedAction', 'NotifyOnNewObject', 'RegisterLoadMapPostHook'}) do
    if type(_G[api]) ~= 'function' then log('Required UE4SS API unavailable: '..api); return end
end
readiness = dofile(dir .. 'UE4SSCommonRetry.lua').new({
    schedule=ExecuteInGameThreadWithDelay,cancel=CancelDelayedAction,delay=250,limit=20,
    attempt=function()
        local generation=readinessGeneration
        local ok, done = pcall(apply)
        if generation~=readinessGeneration then applied,candidate=nil,nil;return 'retry' end
        if not ok then lastError=tostring(done) end
        return ok and done and 'done' or 'retry'
    end,
    onComplete=function(reason)
        if reason=='exhausted' and cfg.debugLogging then log('Setup stopped after 20 attempts: '..(lastError or 'difficulty asset not ready')) end
    end,
    onError=function(err) diagnostics.error('Readiness failed: %s',tostring(err)) end,
})
local ok, err = pcall(function()
    NotifyOnNewObject('/Script/DogwoodStats.DifficultyConfig', function(object) wake(object, false) end)
    RegisterLoadMapPostHook(function() wake(nil, true) end)
end)
if not ok then log('Lifecycle registration failed: '..tostring(err)); return end
active = true
wake(nil, false)
