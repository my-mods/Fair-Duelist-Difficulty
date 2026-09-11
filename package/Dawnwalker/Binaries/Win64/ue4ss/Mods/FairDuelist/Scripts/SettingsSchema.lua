-- Settings contract shared by the loader and Mod Setting Menu. MIT License.
return {
    {key="enabled", default=1, values={0,1}},
    {key="referenceDifficulty", default=3, values={0,1,2,3}},
    {key="enemyHealthMultiplier", default=0.8333333333333333, min=0.1, max=5, integer=false},
    {key="enemyDamageMultiplier", default=0.625, min=0.1, max=5, integer=false},
    {key="staminaCostMultiplier", default=0.5714285714285714, min=0.1, max=5, integer=false},
    {key="enemyAggressionMultiplier", default=1, min=0.1, max=5, integer=false},
    {key="debugLogging", default=0, values={0,1}},
}
