-- Confirmed vanilla difficulty changes reset the absolute balance values. MIT.
-- Verified native signatures: Steam build 25232147, RebelSettings.
local M = {}
function M.new(api, directory, report)
    local Config=api.dofile(directory..'Config.lua')
    local Store=api.dofile(directory..'ConfigStore.lua')
    local bridge={}
    local prefix='/Script/RebelSettings.RebelGameUserSettings:'
    local registered, factory, binding, preview, confirmation, queued = {},nil,nil,nil,nil,nil
    local function unwrap(v)
        if type(v)=='number' or type(v)=='boolean' then return v end
        return v and v:get()
    end
    local function valid(o) return o and o:IsValid() end
    local function levels(settings)
        local rpg, action={},{}
        assert(settings:GetSettingAsDifficulty(69,rpg) and settings:GetSettingAsDifficulty(70,action),'Cannot read current difficulty')
        local r,a=rpg.OutDifficulty,action.OutDifficulty
        assert(type(r)=='number' and r%1==0 and r>=0 and r<=3 and type(a)=='number' and a%1==0 and a>=0 and a<=3,'Invalid current difficulty')
        return r,a
    end
    function bridge.observe()
        if not valid(factory) then factory=api.StaticFindObject('/Script/RebelSettings.Default__RebelGameUserSettings') end
        assert(valid(factory),'Game settings factory unavailable')
        local settings=factory:Get(); assert(valid(settings),'Game settings unavailable')
        local r,a=levels(settings)
        return r,a
    end
    function bridge.attach(callback)
        binding=callback
        return function() if binding==callback then binding=nil end end
    end
    local function enqueue(settings,rpg,action)
        if queued then
            if queued.settings:GetAddress()~=settings:GetAddress() then queued.settings=settings; queued.rpg=false; queued.action=false end
            queued.rpg=queued.rpg or rpg; queued.action=queued.action or action
            return
        end
        queued={settings=settings,rpg=rpg,action=action}
        api.ExecuteInGameThreadWithDelay(16,function()
            local job=queued; queued=nil
            local ok,err=pcall(function()
                if not valid(job.settings) then return end
                local r,a=levels(job.settings)
                local cfg,path,original=Store.load(directory,Config,function()
                    local initial=Config.defaults()
                    Config.preset(initial,r,'RPG'); Config.preset(initial,a,'Action')
                    return initial
                end)
                if not original then error('Cannot reset invalid settings: '..path) end
                if job.rpg then Config.preset(cfg,r,'RPG') end
                if job.action then Config.preset(cfg,a,'Action') end
                local saved,se=Store.save(directory,Config,cfg,original)
                assert(saved,se)
                if binding then binding(cfg,r,a) end
                if cfg.debugLogging==1 then report('Vanilla difficulty confirmed; saved '..Config.names[cfg.difficultyPreset+1]..' balance') end
            end)
            if not ok then report('Difficulty reset failed: '..tostring(err)) end
        end)
    end
    local function hook(name,pre,post)
        local a,b=api.RegisterHook(prefix..name,pre,post)
        assert(a and b,'Hook registration failed: '..name)
        registered[#registered+1]={prefix..name,a,b}
    end
    local ok,err=pcall(function()
        hook('PreviewDifficultyPreset',function() end,function(context,_,result)
            if unwrap(result)==true then preview=unwrap(context) end
        end)
        hook('ConfirmSettings',function(context)
            local settings=unwrap(context)
            confirmation=nil
            if not valid(settings) then return end
            local same=valid(preview) and preview:GetAddress()==settings:GetAddress()
            local rpg=same or settings:IsSettingUnconfirmed(69)
            local action=same or settings:IsSettingUnconfirmed(70)
            if rpg or action then confirmation={settings=settings,rpg=rpg,action=action} end
        end,function(context,_,result)
            local request=confirmation; confirmation=nil
            if unwrap(result)~=true then return end
            preview=nil
            if request then
                local settings=unwrap(context)
                if valid(settings) and settings:GetAddress()==request.settings:GetAddress() then enqueue(settings,request.rpg,request.action) end
            end
        end)
        for _,name in ipairs({'ResetUnconfirmedSettings','ResetUnconfirmedSettingsFromSet','ResetUnconfirmedSetting'}) do
            hook(name,function() preview=nil; confirmation=nil end,function() end)
        end
    end)
    if not ok then
        for _,h in ipairs(registered) do pcall(api.UnregisterHook,table.unpack(h)) end
        error(err)
    end
    return bridge
end
return M
