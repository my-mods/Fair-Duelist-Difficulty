-- Persistent personal settings for Windows. MIT; see LICENSE.txt.
-- Only the shipped defaults belong to the mod manager. Never open a personal
-- file for writing: create a temporary file and rename it without replacement.
local M = {}

local function read(path)
    local file, err, code = io.open(path, 'rb')
    if not file then return nil, err, code end
    local text, readError = file:read('*a')
    file:close()
    return text, readError
end

local function createIfMissing(path, text)
    -- Windows CRT rename fails if the destination exists, including when it
    -- appears after our existence check. Do not use this on POSIX, where rename
    -- replaces the destination. No shell commands or Vortex-managed writes.
    if package.config:sub(1, 1) ~= '\\' then return nil, 'Windows is required for no-replace file creation' end
    local reserved, token = pcall(os.tmpname)
    if not reserved then return nil, token end
    os.remove(token) -- Remove only the scratch file reserved by os.tmpname, if any.
    local basename = assert(token:match('([^/\\]+)$'), 'Invalid temporary filename')
    local temporary = path .. '.' .. basename .. '.tmp'
    local file, err = io.open(temporary, 'a+b')
    if not file then return nil, err end
    if file:seek('end') ~= 0 then
        file:close()
        return nil, 'Temporary filename is already occupied; retrying without modifying it'
    end
    local written, writeError = file:write(text)
    local closed, closeError = file:close()
    if not written or not closed then
        os.remove(temporary)
        return nil, writeError or closeError
    end
    local renamed, renameError = os.rename(temporary, path)
    if not renamed then
        os.remove(temporary)
        -- A concurrent launch/user may have created the personal file first.
        local existing, existingError = read(path)
        if existing ~= nil then return existing end
        return nil, renameError or existingError
    end
    return text
end

local function personalTemplate(defaults)
    local lines = {
        '; PERSONAL FAIR DUELIST OVERRIDES - preserved across mod updates.',
        '; Uncomment only the settings you want to override, then restart the game.',
        '; Commented/omitted settings inherit the current shipped defaults.',
        '; This reference is copied once; see FairDuelist.defaults.ini for updates.',
        '',
    }
    for line in (defaults .. '\n'):gmatch('(.-)\n') do
        if line:match('^%s*[%w_]+%s*=') and not line:match('^referenceDifficulty=') then line = '; ' .. line end
        lines[#lines+1] = line
    end
    return table.concat(lines, '\n')
end
function M.load(directory, Config)
    local function fail(message, path)
        print('[FairDuelist] ' .. message .. '; INI overrides disabled\n')
        return {enabled=false}, path or ''
    end
    local text, err = read(directory .. 'FairDuelist.defaults.ini')
    if not text then return fail('Cannot read shipped defaults: ' .. tostring(err)) end
    local defaults, errors = Config.parse(text)
    if #errors > 0 then return fail(table.concat(errors, '; ')) end
    local base = os.getenv('LOCALAPPDATA')
    if not base or not (base:match('^%a:[/\\]') or base:match('^\\\\')) then
        return fail('LOCALAPPDATA must be an absolute Windows path; no managed fallback is used')
    end
    local folder = base:gsub('[/\\]+$', '') .. '/Dawnwalker/Saved/Config/'
    local path = folder .. 'FairDuelist.ini'
    local personal, errorText, code = read(path)
    if personal == nil then
        if code ~= 2 then return fail('Cannot read ' .. path .. ': ' .. tostring(errorText), path) end
        personal, errorText = createIfMissing(path, personalTemplate(text))
        if personal == nil then return fail('Cannot create ' .. path .. ': ' .. tostring(errorText), path) end
    end
    local config, problems = Config.parse(personal, defaults)
    if #problems > 0 then return fail(table.concat(problems, '; '), path) end
    return config, path
end
return M
