local M = {}
M.defaults = {enabled=true, enemyHealthMultiplier=0.75, enemyDamageMultiplier=1.0, staminaCostMultiplier=1.0, debugLogging=false}
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
                if type(M.defaults[key]) == 'boolean' then
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
    -- Reject the whole gameplay configuration on errors, avoiding partial setups.
    if #errors > 0 then
        for key, value in pairs(M.defaults) do if key ~= 'debugLogging' then cfg[key] = value end end
        end
        cfg.enabled = false
    return cfg, errors
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
    local cfg, errors = M.parse(text)
    if cfg.debugLogging then for _, err in ipairs(errors) do print('[FairDuelist] '..err..'; using defaults\n') end end
    return cfg, path
end
return M
