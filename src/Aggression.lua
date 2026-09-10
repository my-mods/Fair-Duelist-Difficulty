-- Only attack coordination/cooldowns are copied; AI scaling tables are untouched.
local M = {}
local profiles = {story=0, fair=1, challenging=2, duelist=3}
local fields = {
    bAllowAttackingWhileAnotherNPCIsPerformingBestNodeInject='boolean',
    bAllowAttackingWhileAnotherNPCIsAttacking='boolean',
    bAllowAttackingWhileAnotherNPCIsInParryReaction='boolean',
    bAllowAttackingWhileAnotherNPCIsInBlockReaction='boolean',
    bAllowAttackingWhileAnotherNPCIsInOmniblockReaction='boolean',
    HelperTicketCooldownMultiplier='number',
    LowHealthHelperTicketCooldownMultiplier='number',
    HelperRangedAttackCooldownMultiplier='number',
}
function M.prepare(object, profile)
    if profile == 'game' then return function() end, function() end, 0 end
    local index = assert(profiles[profile], 'Unknown aggression profile')
    local target = object.ActionDifficulties:Find(3):get()
    local source = object.ActionDifficulties:Find(index):get()
    local old, desired = {}, {}
    for field, kind in pairs(fields) do
        old[field], desired[field] = target[field], source[field]
        assert(type(old[field]) == kind and type(desired[field]) == kind, 'Unexpected aggression schema: ' .. field)
        if kind == 'number' then assert(desired[field] >= 0 and desired[field] < math.huge, 'Invalid aggression cooldown') end
    end
    local function restore() for field, value in pairs(old) do target[field] = value end end
    local function apply()
        for field, value in pairs(desired) do
            target[field] = value
            assert(target[field] == value, 'Aggression write failed: ' .. field)
        end
    end
    return apply, restore, 8
end
return M
