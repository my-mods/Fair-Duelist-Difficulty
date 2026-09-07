local M = {}
M.baseline = {enemyHealthMultiplier=0.9, enemyDamageMultiplier=1.6, staminaCostMultiplier=1.75}
M.defaults = {referenceDifficulty='Duelist', enabled=true, enemyHealthMultiplier=0.75/0.9, enemyDamageMultiplier=1/1.6, staminaCostMultiplier=1/1.75, debugLogging=false}
function M.parse(text)
    local cfg, errors, section, seen = {}, {}, '', {}
    for key, value in pairs(M.defaults) do cfg[key] = value end
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
        local oldDefaults = {enemyHealthMultiplier=0.75, enemyDamageMultiplier=1, staminaCostMultiplier=1}
        for key, base in pairs(M.baseline) do cfg[key] = (seen[key] and cfg[key] or oldDefaults[key]) / base end
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
    return string.format('[FairDuelist]\nreferenceDifficulty=Duelist\nenabled=%s\n; Multipliers relative to original Duelist. 1.0 = original Duelist.\nenemyHealthMultiplier=%.12g\nenemyDamageMultiplier=%.12g\nstaminaCostMultiplier=%.12g\ndebugLogging=%s\n', tostring(cfg.enabled), cfg.enemyHealthMultiplier, cfg.enemyDamageMultiplier, cfg.staminaCostMultiplier, tostring(cfg.debugLogging))
end
function M.migrate(path, text, cfg)
    for key in pairs(M.baseline) do if cfg[key] < 0.1 or cfg[key] > 5 then return false end end
    local backupPath, tempPath = path..'.fair-reference.bak', path..'.duelist-migration.tmp'
    for _, name in ipairs({backupPath, tempPath}) do
        local existing = io.open(name, 'r')
        if existing then existing:close(); return false end
    end
    local output = io.open(tempPath, 'w')
    if not output then return false end
    local written = output:write(M.serialize(cfg)); local finished = output:close()
    if not written or not finished then return false end
    -- Rename preserves the full original; never truncate the active INI.
    if not os.rename(path, backupPath) then return false end
    if not os.rename(tempPath, path) then
        os.rename(backupPath, path)
        return false
    end
    return true
end

function M.load(dir)
    local base = os.getenv('LOCALAPPDATA')
    local path = base and (base..'/Dawnwalker/Saved/Config/Windows/FairDuelist.ini') or (dir..'FairDuelist.ini')
    local f = io.open(path, 'r')
    if not f then
        local defaults = assert(io.open(dir..'FairDuelist.defaults.ini', 'r'))
        local text = defaults:read('*a'); defaults:close()
        local output = io.open(path, 'w')
        if output then output:write(text); output:close() end
        -- The cooked preset remains the default if the personal directory is unavailable.
        local cfg = M.parse(text)
        if cfg.debugLogging and not output then print('[FairDuelist] Could not create INI: '..path..'\n') end
        return cfg, path
    end
    local text = f:read('*a'); f:close()
    local cfg, errors, legacy = M.parse(text)
    if legacy and #errors == 0 then
        local migrated = M.migrate(path, text, cfg)
        if cfg.debugLogging then print("[FairDuelist] Legacy Fair-reference INI converted in memory; file migrated="..tostring(migrated).."\n") end
    end
    if cfg.debugLogging then for _, err in ipairs(errors) do print('[FairDuelist] '..err..'; using defaults\n') end end
    return cfg, path
end
return M
