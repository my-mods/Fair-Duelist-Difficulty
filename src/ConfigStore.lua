-- Absolute Mod Setting Menu storage and lossless legacy import. MIT.
local M = {}
local function oldSchema(percent)
    local schema={{key='enabled',values={0,1}},{key='referenceDifficulty',values={0,1,2,3}},{key='debugLogging',values={0,1}}}
    for _,key in ipairs({'enemyHealth','enemyDamage','staminaCost','enemyAggression'}) do
        schema[#schema+1]={key=key..(percent and 'Percent' or 'Multiplier'),min=percent and -90 or 0.1,max=percent and 400 or 5}
    end
    return schema
end
local function convert(old, Config, reference, percent)
    local cfg=Config.defaults()
    cfg.enabled=old.enabled; cfg.debugLogging=old.debugLogging
    Config.preset(cfg,reference)
    for _,key in ipairs({'enemyHealth','enemyDamage','staminaCost'}) do
        local multiplier=percent and ((100+old[key..'Percent'])/100) or old[key..'Multiplier']
        cfg[key..'Percent']=cfg[key..'Percent']*multiplier
    end
    local aggression=percent and ((100+old.enemyAggressionPercent)/100) or old.enemyAggressionMultiplier
    for _,key in ipairs({'attackDelayPercent','lowHealthAttackDelayPercent','rangedAttackDelayPercent'}) do cfg[key]=cfg[key]/aggression end
    cfg.difficultyPreset=Config.classify(cfg)
    return cfg
end
function M.load(directory, Config, initial)
    local Store=dofile(directory..'SettingsStore.lua')
    local File=dofile(directory..'SettingsFile.lua')
    local schema=dofile(directory..'SettingsSchema.lua')
    local path=Store.path(directory)
    local text,err,code=Store.read(path)
    local function reject(e) print('[FairDuelist] Settings rejected: '..tostring(e)..'\n'); return {enabled=0},path end
    if text then
        local current,e=Store.parse(text,schema)
        if current then current.difficultyPreset=Config.classify(current); return current,path,text end
        if text:find('settingsVersion%s*=') then return reject(e) end
        local percent=text:find('enemyHealthPercent%s*=')~=nil
        local old,oe=Store.parse(text,oldSchema(percent))
        if not old then return reject(oe) end
        local cfg=convert(old,Config,old.referenceDifficulty,percent)
        local updated=File.render(text,schema,cfg)
        local checked,ce=Store.parse(updated,schema)
        if not checked then return reject(ce) end
        local ok,me=File.replace(Store,path,text,updated,'.absolute-v2.backup',true)
        if not ok then return reject(me) end
        return cfg,path,updated
    end
    if code~=2 then return reject(err) end
    -- A previous interrupted conversion must never be treated as a fresh install.
    for _,suffix in ipairs({'.absolute-v2.backup','.absolute-write.backup'}) do
        local backup,be,bc=Store.read(path..suffix)
        if backup or bc~=2 then return reject('Recover '..path..suffix..': '..tostring(be or '')) end
    end
    local values,e=Store.load(directory,schema,function()
        local base=os.getenv('LOCALAPPDATA')
        if not base then return nil,'LOCALAPPDATA unavailable for legacy import' end
        local legacyPath=base..'/Dawnwalker/Saved/Config/FairDuelist.ini'
        local personal,pe,pc=Store.read(legacyPath)
        if not personal then
            if pc~=2 then return nil,pe end
            return initial and initial() or Config.defaults()
        end
        local Legacy=dofile(directory..'LegacyConfig.lua')
        local cfg,problems=Legacy.parse(personal)
        if #problems>0 then return nil,table.concat(problems,'; ') end
        local reference
        for i,name in ipairs(Config.names) do if name==cfg.referenceDifficulty then reference=i-1 end end
        cfg.enabled=cfg.enabled and 1 or 0; cfg.debugLogging=cfg.debugLogging and 1 or 0
        -- Preserve the legacy original; this format migration does not delete preferences.
        return convert(cfg,Config,assert(reference),false)
    end)
    if not values then return reject(e) end
    values.difficultyPreset=Config.classify(values)
    return values,path,Store.read(path)
end
function M.save(directory, Config, values, expected)
    local Store=dofile(directory..'SettingsStore.lua')
    local File=dofile(directory..'SettingsFile.lua')
    local schema=dofile(directory..'SettingsSchema.lua')
    local path=Store.path(directory)
    local text,err=Store.read(path)
    if not text then return nil,err end
    if expected and text~=expected then return nil,'Settings changed externally; reopen the menu' end
    local parsed,e=Store.parse(text,schema)
    if not parsed then return nil,e end
    values.difficultyPreset=Config.classify(values)
    local updated=File.render(text,schema,values)
    local valid,ve=Store.parse(updated,schema)
    if not valid then return nil,ve end
    return File.replace(Store,path,text,updated,'.absolute-write.backup',false)
end
return M
