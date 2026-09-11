-- Numeric Mod Setting Menu storage with one-time legacy import. MIT.
local M = {}
function M.load(directory, Config)
    local Store = dofile(directory .. 'SettingsStore.lua')
    local schema = dofile(directory .. 'SettingsSchema.lua')
    local names = {'Story','Fair','Challenging','Duelist'}
    local values, err, path = Store.load(directory, schema, function()
        local text, e = Store.read(directory .. 'FairDuelist.defaults.ini')
        if not text then return nil, e end
        local defaults, problems = Config.parse(text)
        if #problems > 0 then return nil, table.concat(problems, '; ') end
        local base = os.getenv('LOCALAPPDATA')
        if not base then return nil, 'LOCALAPPDATA unavailable for legacy migration' end
        local legacyPath = base .. '/Dawnwalker/Saved/Config/FairDuelist.ini'
        local personal, pe, pc = Store.read(legacyPath)
        if not personal and pc ~= 2 then return nil, pe end
        local cfg, errors = Config.parse(personal or '', defaults)
        if #errors > 0 then return nil, table.concat(errors, '; ') end
        for i, name in ipairs(names) do if cfg.referenceDifficulty == name then cfg.referenceDifficulty = i-1; break end end
        cfg.enabled = cfg.enabled and 1 or 0; cfg.debugLogging = cfg.debugLogging and 1 or 0
        return cfg, nil, personal and {{path=legacyPath, text=personal}} or nil
    end)
    if not values then print('[FairDuelist] Settings rejected: '..tostring(err)..'\n'); return {enabled=false}, path end
    values.referenceDifficulty=names[values.referenceDifficulty+1]
    values.enabled=values.enabled==1; values.debugLogging=values.debugLogging==1
    return values, path
end
return M
