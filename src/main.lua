-- Settings are read only after save-load completion. No startup settings work.
local directory = assert(debug.getinfo(1, 'S').source:sub(2):match('^(.*[/\\])'))
local function report(message) print('[Save Settings] '..message..'\n') end
local session = dofile(directory..'UE4SSCommonSession.lua').new(_G, directory, report)
local ok, err = pcall(function()
    FairDuelistNative = dofile(directory..'NativeDifficulty.lua').new(_G, directory, report)
    dofile(directory..'UE4SSDawnwalkerSaveLoad.lua').start(_G, session, directory..'Gameplay.lua', report)
end)
if not ok then report('Difficulty integration unavailable: '..tostring(err)) end
