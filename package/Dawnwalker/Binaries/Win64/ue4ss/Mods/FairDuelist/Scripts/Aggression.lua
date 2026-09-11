-- Only attack coordination/cooldowns are copied; AI scaling tables are untouched.
local M = {}
local profiles = {Story=0, Fair=1, Challenging=2, Duelist=3}
-- Owned scalar snapshots only, captured before any writes to the shared asset.
local originals, originalOwner
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
function M.prepare(object, profile, multiplier, session)
    assert(profiles[profile], 'Unknown reference difficulty')
    assert(type(multiplier)=='number' and multiplier>=0.1 and multiplier<=5, 'Invalid aggression multiplier')
    if not originals or not originalOwner:IsValid() or originalOwner:GetAddress() ~= object:GetAddress() then
        local snapshot = {}
        for name, key in pairs(profiles) do
            local row = object.ActionDifficulties:Find(key):get()
            local values = {}
            for field, kind in pairs(fields) do
                local value = row[field]
                assert(type(value)==kind, 'Unexpected aggression schema: ' .. field)
                if kind=='number' then assert(value>=0 and value<math.huge, 'Invalid aggression cooldown') end
                values[field] = value
            end
            snapshot[name] = values
        end
        originals, originalOwner = snapshot, object
    end
    local target = object.ActionDifficulties:Find(3):get()
    local source = originals[profile]
    local old, desired = {}, {}
    for field, kind in pairs(fields) do
        old[field], desired[field] = target[field], source[field]
        assert(type(old[field]) == kind and type(desired[field]) == kind, 'Unexpected aggression schema: ' .. field)
        if kind == 'number' then desired[field] = desired[field] / multiplier end
    end
    local function restore() for field, value in pairs(old) do target[field] = value end end
    local function apply()
        local writes = 0
        for field, value in pairs(desired) do
            local changed = session.change(tostring(object:GetAddress())..':Aggression:'..field, function()
                if not object:IsValid() then return nil, false end
                return object.ActionDifficulties:Find(3):get()[field]
            end, function(nextValue) object.ActionDifficulties:Find(3):get()[field] = nextValue end, value)
            if changed then writes = writes + 1 end
            local actual = target[field]
            assert(type(value)=='number' and type(actual)=='number' and math.abs(actual-value)<=1e-5*math.max(1,math.abs(value)) or actual==value, 'Aggression write failed: ' .. field)
        end
        return writes
    end
    return apply, restore
end
return M
