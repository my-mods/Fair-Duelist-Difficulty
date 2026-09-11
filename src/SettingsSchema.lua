-- Settings contract shared by the loader and Mod Setting Menu. MIT License.
return {
    {key="enabled", default=1, values={0,1}},
    {key="referenceDifficulty", default=3, values={0,1,2,3}},
    {key="enemyHealthPercent", default=-16.666666666666675, min=-90, max=400, integer=false},
    {key="enemyDamagePercent", default=-37.5, min=-90, max=400, integer=false},
    {key="staminaCostPercent", default=-42.857142857142861, min=-90, max=400, integer=false},
    {key="enemyAggressionPercent", default=0, min=-90, max=400, integer=false},
    {key="debugLogging", default=0, values={0,1}},
}
