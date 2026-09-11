-- Read the setting rules and save only the keys the mod asked for.
-- config files again ffs im so tired
local M = {sessions={}}
local function trim(s) return (s or ""):match("^%s*(.-)%s*$") end
local function split(s)
    local out = {}; for part in ((s or "") .. "|"):gmatch("(.-)|") do out[#out+1]=trim(part) end
    return out
end
local function finite(s)
    local n=tonumber(s); return n and n==n and math.abs(n)<=1000000000 and n or nil
end
function M.index(setting,value)
    if setting.kind=="slider" then return finite(value) and value>=setting.minimum and value<=setting.maximum and 1 or nil end
    for i,v in ipairs(setting.values) do if v==value then return i end end
end
function M.format(setting,value)
    if setting.kind~="slider" then return setting.labels[M.index(setting,value)] end
    local text=string.format("%."..setting.decimals.."f",value)
    if tonumber(text)==0 then text=string.format("%."..setting.decimals.."f",0) end
    return setting.prefix..text..setting.suffix
end
function M.snap(setting,value)
    if value<=setting.minimum then return setting.minimum end
    if value>=setting.maximum then return setting.maximum end
    local steps=math.floor((value-setting.minimum)/setting.step+0.5)
    return math.max(setting.minimum,math.min(setting.maximum,tonumber(string.format("%.6f",setting.minimum+steps*setting.step))))
end
function M.parse(content)
    local raw, categories, current = {}, {}, nil
    for line in (content .. "\n"):gmatch("([^\n]*)\n") do
        local name=trim(line):match("^%[([^%]]+)%]$")
        if name then
            current=nil
            if name=="Setting" or name:match("^Setting%.") then
                assert(#raw<256, "more than 256 settings")
                current={}; raw[#raw+1]=current
            elseif name:match("^Category%.") then
                local group=name:sub(10)
                assert(#group>0 and #group<=4096 and not categories[group],"invalid/duplicate visibility category")
                current={}; categories[group]=current
            end
        elseif current and not trim(line):match("^[;#]") and trim(line)~="" then
            local k,v=line:match("^%s*([^=]+)=(.*)$")
            if k then k=trim(k); assert(current[k]==nil,"duplicate setting key "..k); current[k]=trim(v) end
        end
    end
    local out, ids, conditions={},{},{}
    for i,r in ipairs(raw) do
        local before=#out
        local kind=trim(r.Type):lower()
        if kind=="slider" or kind=="integer" or kind=="percent" or kind=="stepped" then
            local minimum,maximum,step=finite(r.Minimum),finite(r.Maximum),finite(r.Step or "1")
            local default=finite(r.Default)
            local decimals=tonumber(r.Decimals or (kind=="slider" and "2" or "0"))
            assert(minimum and maximum and minimum<maximum and step and step>=0.000001 and step<=maximum-minimum,"invalid slider range/step")
            assert(default and default>=minimum and default<=maximum,"slider default outside range")
            assert(decimals and decimals%1==0 and decimals>=0 and decimals<=6,"invalid slider decimals")
            if kind=="integer" then assert(minimum%1==0 and maximum%1==0 and step%1==0 and default%1==0,"integer slider has fractional values") end
            local id=r.Id or ("setting_"..i); assert(#id>0 and #id<=128 and not ids[id],"invalid/duplicate setting Id"); ids[id]=true
            local suffix=r.Suffix or (kind=="percent" and "%" or "")
            if suffix:match("^%a") then suffix=" "..suffix end
            local s={id=id,kind="slider",label=r.Label or id,description=r.Description or "",group=r.Group or r.Section or r.Category or "Settings",
                minimum=minimum,maximum=maximum,step=step,default=default,decimals=decimals,prefix=r.Prefix or "",suffix=suffix,
                file=r.ConfigFile,key=r.ConfigKey or id,section=r.ConfigSection}
            for _,t in ipairs({s.label,s.description,s.group,s.prefix,s.suffix}) do assert(#t<=4096 and not t:find("[%z\1-\8\11\12\14-\31\127]"),"invalid slider text") end
            out[#out+1]=s
        end
        if kind=="toggle" or kind=="picker" or kind=="preset" then
            local values,labels=split(r.PresetValues or r.Presets),split(r.PresetLabels or (kind=="toggle" and "Off|On" or nil))
            assert(#values>=2 and #values<=64 and #labels==#values,"choice requires 2 to 64 matching values and labels")
            assert(kind~="toggle" or #values==2,"toggle requires exactly two values")
            local seen={}
            for n,v in ipairs(values) do
                local number=finite(v)
                assert(number and not seen[number],"invalid or duplicate choice value")
                assert(labels[n]~="","empty choice label")
                values[n]=number; seen[number]=true
                assert(#labels[n]<=4096 and not labels[n]:find("[%z\1-\8\11\12\14-\31\127]"),"invalid choice label")
            end
            local default=r.Default and finite(r.Default) or values[1]
            assert(default and seen[default],"choice default must match a value")
            local id=r.Id or ("setting_"..i)
            assert(#id>0 and #id<=128 and not ids[id],"invalid/duplicate setting Id")
            ids[id]=true
            for _,s in ipairs({r.Label or id,r.Description or "",r.Group or r.Section or r.Category or "Settings"}) do
                assert(#s<=4096 and not s:find("[%z\1-\8\11\12\14-\31\127]"),"invalid choice text")
            end
            out[#out+1]={id=id,kind=kind=="toggle" and "toggle" or "picker",label=r.Label or id,description=r.Description or "",
                group=r.Group or r.Section or r.Category or "Settings",values=values,labels=labels,default=default,
                file=r.ConfigFile,key=r.ConfigKey or id,section=r.ConfigSection,
                targetIds=r.PresetTargets and split(r.PresetTargets),custom=r.CustomValue and finite(r.CustomValue),
                matrixText=r.PresetMatrix}
        end
        if #out>before then conditions[#out]=r end
    end
    local byId,owners={},{}
    for i,setting in ipairs(out) do byId[setting.id]=i end
    local function condition(r)
        if not r or (r.VisibleWhen==nil and r.VisibleValues==nil) then return nil end
        local target=byId[r.VisibleWhen]
        assert(target and r.VisibleValues,"visibility requires a setting Id and VisibleValues")
        local source=out[target]
        assert(source.kind=="toggle" or source.kind=="picker","visibility source must be a toggle or picker")
        local values={}
        for _,rawValue in ipairs(split(r.VisibleValues)) do
            local value=finite(rawValue)
            assert(value and M.index(source,value) and not values[value],"invalid/duplicate visibility value")
            values[value]=true
        end
        return {target=target,values=values}
    end
    local used={}
    for i,setting in ipairs(out) do
        setting.visibility={}
        local rowRule,groupRule=condition(conditions[i]),condition(categories[setting.group])
        if rowRule then setting.visibility[#setting.visibility+1]=rowRule end
        if groupRule then setting.visibility[#setting.visibility+1]=groupRule end
        used[setting.group]=true
    end
    for group in pairs(categories) do assert(used[group],"visibility category has no settings") end
    -- Do not let settings hide each other in a loop, or let a child hide its own category.
    local visiting,done={},{}
    local function visit(i)
        assert(not visiting[i],"cyclic visibility dependency")
        if done[i] then return end
        visiting[i]=true
        for _,rule in ipairs(out[i].visibility) do visit(rule.target) end
        visiting[i]=nil; done[i]=true
    end
    for i in ipairs(out) do visit(i) end
    for i,setting in ipairs(out) do
        assert(not setting.matrixText or setting.targetIds,"preset matrix requires targets")
        if setting.targetIds then
            assert(setting.kind=="picker" and setting.custom and M.index(setting,setting.custom),"linked preset requires a declared CustomValue")
            setting.targets={}
            if setting.matrixText then
                local rows=split(setting.matrixText)
                assert(#rows==#setting.values,"preset matrix needs one row per choice")
                setting.matrix={}
                for n,text in ipairs(rows) do
                    local value=setting.values[n]
                    if value==setting.custom then assert(text=="-","Custom matrix row must be -")
                    else
                        local row=split((text:gsub(",","|")))
                        assert(#row==#setting.targetIds,"preset matrix width differs from targets")
                        for k,cell in ipairs(row) do row[k]=assert(finite(cell),"invalid preset matrix number") end
                        setting.matrix[value]=row
                    end
                end
                setting.matrixText=nil
            end
            for column,id in ipairs(setting.targetIds) do
                local target=byId[id]
                assert(target and target~=i and not owners[target],"missing, self or overlapping preset target")
                local child=out[target]
                assert(not child.targetIds and not child.targets,"nested preset targets are unsupported")
                assert(setting.matrix or child.kind=="picker","preset targets must be ordinary pickers without a matrix")
                for _,value in ipairs(setting.values) do
                    assert(value==setting.custom or M.index(child,setting.matrix and setting.matrix[value][column] or value),"preset value outside target choices/range")
                end
                owners[target]=i
                setting.targets[#setting.targets+1]=target
            end
            setting.targetIds=nil
        end
    end
    return out
end
local function pathFor(provider, setting)
    local f=setting.file
    assert(type(f)=="string" and #f>0 and #f<=240,"choice requires ConfigFile")
    f=f:gsub("\\","/")
    assert(not f:find('[:%c<>"|?*]') and not f:match("^/") and not f:match("/$"),"invalid ConfigFile")
    for part in (f.."/"):gmatch("(.-)/") do
        assert(part~="" and part~="." and part~=".." and not part:match("[ .]$"),"invalid ConfigFile component")
        local stem=part:match("^[^.]+"):upper()
        assert(stem~="CON" and stem~="PRN" and stem~="AUX" and stem~="NUL" and
            not stem:match("^COM[1-9]$") and not stem:match("^LPT[1-9]$"),"reserved ConfigFile component")
    end
    assert(not f:lower():match("mod_settings%.ini$"),"manifest cannot be a config target")
    local base=assert(provider.path and provider.path:match("^(.*)[/\\][^/\\]+$"),"provider directory unavailable")
    return base.."/"..f
end
-- Find the exact existing assignment. Refuse duplicate or unclear keys.
local function assignment(content, setting)
    assert(type(setting.key)=="string" and #setting.key>0 and not setting.key:find("[\r\n=]"),"invalid ConfigKey")
    local section=""; local matches={}; local offset=1
    for full in (content.."\n"):gmatch("([^\n]*\n)") do
        local line=full:gsub("\r?\n$","")
        local header=trim(line):match("^%[([^%]]+)%]%s*$")
        if header then section=trim(header)
        elseif not trim(line):match("^[;#]") then
            local prefix,key,space,value,suffix=line:match("^(%s*)([^=]-)(%s*=%s*)([^;#]*)(.*)$")
            if key and trim(key)==setting.key and (not setting.section or section==setting.section) then
                local leading,number,trailing=value:match("^(%s*)(.-)(%s*)$")
                matches[#matches+1]={first=offset+#prefix+#key+#space+#leading,
                    last=offset+#prefix+#key+#space+#value-#trailing-1,value=finite(number)}
            end
        end
        offset=offset+#full
    end
    assert(#matches==1,"config key missing or ambiguous: "..setting.key)
    local found=matches[1]
    assert(M.index(setting,found.value),"configured value is outside declared choices")
    return found
end
M.assignment=assignment
M.fs={}
function M.fs.read(path)
    local f=io.open(path,"rb"); if not f then return nil end
    local content=f:read(1048577); f:close()
    assert(content and #content<=1048576,"config exceeds 1 MiB")
    return content
end
function M.fs.write(path,content)
    local f,err=io.open(path,"wb"); assert(f,err)
    local ok,why=f:write(content); local closed,closeError=f:close()
    assert(ok and closed,why or closeError or "config write failed")
end
function M.fs.rename(a,b) local ok,err=os.rename(a,b); assert(ok,err) end
function M.fs.remove(path) os.remove(path) end
function M.replace(path,expected,content,fs)
    local tmp,backup=path..".dmm-toggle.tmp",path..".dmm-toggle.bak"
    assert(fs.read(tmp)==nil and fs.read(backup)==nil,"previous toggle transaction files need review")
    assert(fs.read(path)==expected,"config changed externally; reopen this mod before applying")
    local wrote,err=pcall(fs.write,tmp,content)
    if not wrote then fs.remove(tmp); error(err) end
    if fs.read(tmp)~=content or fs.read(path)~=expected then fs.remove(tmp); error("config changed or temporary write verification failed") end
    local moved,why=pcall(fs.rename,path,backup)
    if not moved then fs.remove(tmp); error(why) end
    local installed,installError=pcall(function()
        assert(fs.read(backup)==expected,"config changed during replacement")
        fs.rename(tmp,path)
    end)
    if not installed then
        local restored,restoreError=pcall(fs.rename,backup,path)
        if restored then fs.remove(tmp) end
        error(tostring(installError)..(restored and "; original restored" or "; rollback failed: "..tostring(restoreError).."; backup: "..backup))
    end
    fs.remove(backup)
end
function M.open(provider)
    local model={provider=provider,items=provider.choices or {},committed={},pending={},fs=M.fs}
    local function summarize(values)
        for i,setting in ipairs(model.items) do
            if setting.targets then
                if setting.matrix then
                    local matched=setting.custom
                    for _,preset in ipairs(setting.values) do
                        local row=setting.matrix[preset]
                        if row then
                            local same=true
                            for column,target in ipairs(setting.targets) do
                                if math.abs(values[target]-row[column])>0.000001 then same=false; break end
                            end
                            if same then matched=preset; break end
                        end
                    end
                    values[i]=matched
                else
                    local value=values[setting.targets[1]]
                    for _,target in ipairs(setting.targets) do
                        if values[target]~=value then value=setting.custom; break end
                    end
                    values[i]=M.index(setting,value) and value or setting.custom
                end
            end
        end
    end
    local function fill(values,setting,value)
        if setting.targets and value~=setting.custom then
            for column,target in ipairs(setting.targets) do
                values[target]=setting.matrix and setting.matrix[value][column] or value
            end
        end
    end
    local ok,err=pcall(function()
        assert(not provider.choiceError,provider.choiceError)
        local cached=M.sessions[provider.id] or {}
        for i,s in ipairs(model.items) do
            local value=s.default
            if provider.testOnly then
                if M.index(s,cached[s.id]) then value=cached[s.id] end
            else
                local path=pathFor(provider,s)
                assert(not model.path or model.path==path,"settings must use one config file per mod")
                model.path=path
                if not model.original then model.original=assert(model.fs.read(path),"existing config file required") end
                value=assignment(model.original,s).value
            end
            model.committed[i],model.pending[i]=value,value
        end
        for i,setting in ipairs(model.items) do if not setting.matrix then fill(model.pending,setting,model.pending[i]) end end
        summarize(model.pending)
        for i,value in ipairs(model.pending) do model.committed[i]=value end
    end)
    if not ok then model.error=tostring(err) end
    function model:dirty()
        for i,v in ipairs(self.pending) do if v~=self.committed[i] then return true end end
        return false
    end
    -- Check visibility when opening or changing values. No idle polling needed.
    function model:visibility()
        local visible={}
        local function resolve(i)
            if visible[i]~=nil then return visible[i] end
            local shown=true
            for _,rule in ipairs(self.items[i].visibility or {}) do
                if not resolve(rule.target) or not rule.values[self.pending[rule.target]] then shown=false; break end
            end
            visible[i]=shown
            return shown
        end
        for i in ipairs(self.items) do resolve(i) end
        return visible
    end
    function model:set(i,value)
        local setting=self.items[i]
        if self.error or not setting or not M.index(setting,value) then return end
        self.pending[i]=value
        if setting.targets then fill(self.pending,setting,value)
        else summarize(self.pending) end
    end
    function model:change(i,direction)
        if self.error or not self.items[i] then return end
        local setting=self.items[i]
        if setting.kind=="slider" then
            local value=self.pending[i]+(direction==1 and -setting.step or setting.step)
            self:set(i,math.max(setting.minimum,math.min(setting.maximum,tonumber(string.format("%.6f",value)))))
        elseif setting.kind=="picker" then
            local index=assert(M.index(setting,self.pending[i]))
            index=math.max(1,math.min(#setting.values,index+(direction==1 and -1 or 1)))
            self:set(i,setting.values[index])
        else
            self:set(i,direction and setting.values[direction] or
                (self.pending[i]==setting.values[1] and setting.values[2] or setting.values[1]))
        end
    end
    function model:slide(i,normalized)
        local setting=self.items[i]
        if self.error or not setting or setting.kind~="slider" or not finite(normalized) then return end
        normalized=math.max(0,math.min(1,normalized))
        self:set(i,M.snap(setting,setting.minimum+normalized*(setting.maximum-setting.minimum)))
    end
    function model:reset(i)
        if self.error then return end
        if i then if self.items[i] then self:set(i,self.items[i].default) end
        else
            for n,s in ipairs(self.items) do self.pending[n]=s.default end
            for n,s in ipairs(self.items) do fill(self.pending,s,self.pending[n]) end
            summarize(self.pending)
        end
    end
    function model:restore() for i,v in ipairs(self.committed) do self.pending[i]=v end end
    function model:apply()
        if self.error then return false,self.error end
        if not self:dirty() then return true end
        local ok,err=pcall(function()
            if self.provider.testOnly then
                local saved={}; for i,s in ipairs(self.items) do saved[s.id]=self.pending[i] end
                M.sessions[self.provider.id]=saved
            else
                local edits,targets={},{}
                for i,s in ipairs(self.items) do
                    local hit=assignment(self.original,s)
                    assert(not targets[hit.first],"multiple choices target one config key")
                    targets[hit.first]=true
                    if self.pending[i]~=hit.value then
                        hit.text=string.format("%.17g",self.pending[i]); edits[#edits+1]=hit
                    end
                end
                table.sort(edits,function(a,b) return a.first>b.first end)
                local content=self.original
                for _,e in ipairs(edits) do content=content:sub(1,e.first-1)..e.text..content:sub(e.last+1) end
                M.replace(self.path,self.original,content,self.fs)
                self.original=content
            end
            for i,v in ipairs(self.pending) do self.committed[i]=v end
        end)
        return ok,not ok and tostring(err) or nil
    end
    return model
end
return M
