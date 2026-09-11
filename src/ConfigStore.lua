-- Numeric Mod Setting Menu storage with one-time legacy import. MIT.
local M = {}
function M.load(directory, Config)
    local Store = dofile(directory .. 'SettingsStore.lua')
    local schema = dofile(directory .. 'SettingsSchema.lua')
    local names = {'Story','Fair','Challenging','Duelist'}
    local adjustments = {'enemyHealth', 'enemyDamage', 'staminaCost', 'enemyAggression'}
    local function percentages(cfg)
        for _, key in ipairs(adjustments) do cfg[key .. 'Percent'] = (cfg[key .. 'Multiplier'] - 1) * 100 end
        return cfg
    end
    local function migrate(text)
        local current, err = Store.parse(text, schema)
        if current then return text end
        -- A partially edited percentage file must be repaired, never silently reset.
        for _, key in ipairs(adjustments) do
            if ('\n' .. text):find('\n%s*' .. key .. 'Percent%s*=') then return nil, err end
        end
        local oldSchema = {}
        for i, setting in ipairs(schema) do
            local old = {}; for k, v in pairs(setting) do old[k] = v end
            if old.key:match('Percent$') then
                old.key = old.key:gsub('Percent$', 'Multiplier'); old.min = 0.1; old.max = 5
            end
            oldSchema[i] = old
        end
        local previous, pe = Store.parse(text, oldSchema)
        if not previous then return nil, pe end
        percentages(previous)
        local replacements = {}
        for _, key in ipairs(adjustments) do
            replacements[key .. 'Multiplier'] = key .. 'Percent = ' .. string.format('%.17g', previous[key .. 'Percent'])
        end
        local section = ''
        return (text:gsub('[^\r\n]+', function(line)
            local clean = line:gsub('^\239\187\191', ''):gsub('[;#].*$', '')
            section = clean:match('^%s*%[([^%]]+)%]%s*$') or section
            local key = clean:match('^%s*([%w_]+)%s*=')
            if section == 'Settings' and replacements[key] then
                return (line:match('^%s*') or '') .. replacements[key] .. ' ' .. (line:match('[;#].*$') or '')
            end
            return line
        end))
    end
    local function prepare()
        local path = Store.path(directory)
        local text, err, code = Store.read(path)
        if not text then return code == 2, err end
        local updated, me = migrate(text)
        if not updated then return nil, me end
        if updated == text then return true end
        local parsed, pe = Store.parse(updated, schema)
        if not parsed then return nil, pe end
        local backup, be, bc = Store.read(path .. '.backup')
        if backup or bc ~= 2 then return nil, 'Settings migration backup exists or is inaccessible: ' .. tostring(be or '') end
        local tmp = path .. '.percentage-new'
        local pending, te, tc = Store.read(tmp)
        if pending or tc ~= 2 then return nil, 'Recover pending percentage migration: ' .. tostring(te or tmp) end
        local ready, ce = Store.create(tmp, updated)
        if not ready then return nil, ce end
        if Store.read(path) ~= text then os.remove(tmp); return nil, 'Settings changed during migration' end
        local saved, se = os.rename(path, path .. '.backup')
        if not saved then os.remove(tmp); return nil, se end
        local installed, ie = os.rename(tmp, path)
        if not installed then
            local restored, re = os.rename(path .. '.backup', path)
            os.remove(tmp)
            return nil, tostring(ie) .. (restored and '' or '; restore settings.ini.backup: ' .. tostring(re))
        end
        if Store.read(path) ~= updated then return nil, 'Cannot verify migrated settings; original retained in settings.ini.backup' end
        return true
    end
    local prepared, prepareError = prepare()
    if not prepared then
        print('[FairDuelist] Settings rejected: ' .. tostring(prepareError) .. '\n')
        return {enabled=false}, Store.path(directory)
    end
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
        return percentages(cfg), nil, personal and {{path=legacyPath, text=personal}} or nil
    end)
    if not values then print('[FairDuelist] Settings rejected: '..tostring(err)..'\n'); return {enabled=false}, path end
    values.referenceDifficulty=names[values.referenceDifficulty+1]
    values.enabled=values.enabled==1; values.debugLogging=values.debugLogging==1
    for _, key in ipairs(adjustments) do values[key .. 'Multiplier'] = 1 + values[key .. 'Percent'] / 100 end
    return values, path
end
return M
