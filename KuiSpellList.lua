local MAJOR, MINOR = 'KuiSpellList-1.0', 10
local KuiSpellList = LibStub:NewLibrary(MAJOR, MINOR)
local _

if not KuiSpellList then
    -- already registered
    return
end

local listeners = {}

local system = {
    -- system applied auras (PVP flags)
    -- buffs
    [23333] = true, -- Horde Flag
    [23335] = true, -- Alliance Flag
    [34976] = true, -- Netherstorm Flag
    [140876] = true, -- alliance mine cart
    [141210] = true, -- horde mine cart
    -- debuffs
    [112055] = true, -- Orb of power
    [121164] = true, -- Orb of power
    [121175] = true, -- Orb of power
    [121177] = true, -- Orb of power
}

local cc = {
    -- debuffs which may be important in PVP
    DRUID = {
        [99] = true, -- Incapacitating Roar
        [339] = true, -- Entangling Roots
        [5211] = true, -- mighty bash
        [22570] = true, -- maim
        [33786] = true, -- Cyclone
        [78675] = true, -- solar beam silence
        [102359] = true, -- Mass Entanglement
    },
    HUNTER = {
        [1499] = true, -- Freezing Trap
        [3355] = true,
        [5116] = true, -- Concussive Shot
        [19386] = true, -- Wyvern Sting
        [24394] = true, -- Intimidation
        [64803] = true, -- Entrapment
        [117405] = true, -- binding shot
        [117526] = true, -- Blinding Shot stun
        [120761] = true, -- glaive toss slow
        [121414] = true, -- glaive toss slow 2
        [135299] = true, -- Ice Trap
        [136634] = true, -- Narrow Escape
    },
    MAGE = {
        [116] = true, -- frostbolt debuff
        [118] = true, -- Polymorph
        [122] = true, -- Frost Nova
        [28271] = true, -- Polymorph
        [28272] = true, -- Polymorph
        [31589] = true, -- slow
        [31661] = true, -- Dragon's Breath
        [33395] = true, -- Freeze
        [44572] = true, -- Deep Freeze
        [61305] = true, -- Polymorph
        [61721] = true, -- Polymorph
        [61780] = true, -- Polymorph
        [102051] = true, -- Frostjaw
        [113724] = true, -- Ring of Frost
        [157997] = true, -- Ice Nova
        [126819] = true, -- Polymorph
        [161353] = true, -- Polymorph
        [161354] = true, -- Polymorph
        [161355] = true, -- Polymorph
        [161372] = true, -- Polymorph
    },
    DEATHKNIGHT = {
        [45524] = true, -- chains of ice
        [108194] = true, -- asphyxiate stun
        [115000] = true, -- remorseless winter slow
        [115001] = true, -- remorseless winter stun
    },
    MONK = {
        [115078] = true, -- paralysis
        [116095] = true, -- disable
        [116330] = true, -- dizzying haze slow
        [119381] = true, -- Leg Sweep
        [119392] = true, -- Charging Ox Wave
        [120086] = true, -- fists of fury stun
        [123394] = true, -- Breath of Fire incapacitate
    },
    PALADIN = {
        [853] = true, -- Hammer of Justice
        [10326] = true, -- Turn Evil
        [20066] = true, -- Repentance
        [31935] = true,  -- avenger's shield silence
        [105593] = true, -- Fist of Justice
        [115750] = true, -- Blinding Light
        [119072] = true, -- holy wrath stun
    },
    PRIEST = {
        [605] = true, -- Dominate Mind
        [8122] = true, -- Psychic Scream
        [15487] = true, -- silence
        [88625] = true, -- Holy Word: Chastise
        [64044] = true, -- Psychic Horror
        [114404] = true, -- void tendril root
    },
    ROGUE = {
        [408] = true, -- Kidney Shot
        [1776] = true, -- Gouge
        [1833] = true, -- Cheap Shot
        [2094] = true, -- Blind
        [3409] = true,   -- crippling poison
        [6770] = true, -- Sap
        [88611] = true,  -- smoke bomb
        [115196] = true, -- debilitating poison
    },
    SHAMAN = {
        [3600] = true,   -- earthbind totem passive
        [8056] = true,   -- frost shock slow
        [51490] = true,  -- thunderstorm slow
        [51514] = true, -- Hex
        [63374] = true, -- Frozen Power
        [63685] = true,  -- frost shock root
        [64695] = true,   -- earthgrab totem root
        [116947] = true,   -- earthgrab totem slow
        [118905] = true, -- Static Charge
    },
    WARLOCK = {
        [710] = true,  -- banish
        [5484] = true, -- Howl of Terror
        [5782] = true, -- Fear
        [6789] = true, -- Mortal Coil
        [30283] = true, -- Shadowfury
        [118699] = true,
        [111397] = true, -- blood fear
        [171018] = true, -- meteor strike (abyssal stun)
    },
    WARRIOR = {
        [1715] = true,   -- hamstring
        [5246] = true,   -- Intimidating Shout
        [7922] = true,   -- charge stun
        [12323] = true,  -- piercing howl
        [18498] = true,  -- gag order
        [107566] = true, -- staggering shout
        [107570] = true, -- Stormbolt
        [132168] = true, -- shockwave stun
    },
    Racial = {
        [28730] = true, -- arcane torrent
        [25046] = true,
        [50613] = true,
        [69179] = true,
        [80483] = true,
        [129597] = true,
        [20549] = true, -- war stomp
        [107079] = true, -- quaking palm
    },
}

local whitelist = {
    -- auras which the player applies and needs to keep track of
    DRUID = {
        [770] = true, -- faerie fire
        [1079] = true, -- rip
        [1822] = true, -- rake
        [155722] = true, -- rake 6.0
        [8921] = true, -- moonfire
        [164812] = true,
        [77758] = true, -- bear thrash; td ma
        [106830] = true, -- cat thrash
        [93402] = true, -- sunfire
        [164815] = true,
        [33745] = true, -- lacerate

        [6795] = true, -- growl
        [16914] = true, -- hurricane

        [1126] = true, -- mark of the wild

        [774] = true, -- rejuvenation
        [8936] = true, -- regrowth
        [33763] = true, -- lifebloom
        [48438] = true, -- wild growth
        [102342] = true, -- ironbark

        -- talents
        [102351] = true, -- cenarion ward
        [102355] = true, -- faerie swarm
        [61391] = true, -- typhoon daze
    },
    HUNTER = {
        [1130] = true, -- hunter's mark
        [3674] = true, -- black arrow
        [53301] = true, -- explosive shot
        [118253] = true, -- serpent sting

        [20736] = true, -- distracting shot
        [131894] = true, -- murder by way of crow

        [13812] = true, -- explosive trap
        [34477] = true, -- misdirection
    },
    MAGE = {
        [11366] = true, -- pyroblast
        [12654] = true, -- ignite
        [83853] = true, -- combustion

        [1459] = true, -- arcane brilliance

        -- talents
        [111264] = true, -- ice ward
        [114923] = true, -- nether tempest
        [44457] = true, -- living bomb
        [112948] = true, -- frost bomb
    },
    DEATHKNIGHT = {
        [55095] = true, -- frost fever
        [55078] = true, -- blood plague
        [114866] = true, -- soul reaper

        [43265] = true, -- death and decay
        [49560] = true, -- death grip taunt
        [50435] = true, -- chillblains
        [56222] = true, -- dark command

        [3714] = true, -- path of frost
        [57330] = true, -- horn of winter
    },
    WARRIOR = {
        [86346] = true,  -- colossus smash

        [355] = true,    -- taunt
        [772] = true,    -- rend
        [1160] = true,   -- demoralizing shout
        [64382] = true,  -- shattering throw
        [115767] = true, -- deep wounds; td

        [469] = true,    -- commanding shout
        [3411] = true,   -- intervene
        [6673] = true,   -- battle shout

        -- talents
        [114029] = true, -- safeguard
        [114030] = true, -- vigilance
        [113344] = true, -- bloodbath debuff
        [132169] = true, -- storm bolt debuff
    },
    PALADIN = {
        [114163] = true, -- eternal flame

        [20925] = { colour = {1,1,.3} }, -- sacred shield
        [65148] = true, -- sacred shield absorb
        [148039] = true, -- sacred shield, 3 charges

        [53563] = { colour = {1,.5,0} }, -- beacon of light
        [156910] = true, -- beacon of faith
        [157007] = true, -- beacon of insight

        [19740] = { colour = {.2,.2,1} }, -- blessing of might
        [20217] = { colour = {1,.3,.3} }, -- blessing of kings

        [26573] = true,  -- consecration; td
        [31803] = true,  -- censure; td

        -- hand of...
        [114039] = true, -- purity
        [6940] = true,   -- sacrifice
        [1044] = true,   -- freedom
        [1038] = true,   -- salvation
        [1022] = true,   -- protection

        [2812] = true,   -- denounce
        [62124] = true,  -- reckoning

        [114165] = true, -- holy prism
        [114916] = true, -- execution sentence dot
        [114917] = true, -- stay of execution hot
    },
    WARLOCK = {
        [5697]  = true,  -- unending breath
        [20707]  = true, -- soulstone
        [109773] = true, -- dark intent

        [172] = true,    -- corruption (demo version)
        [146739] = true, -- corruption
        [114790] = true, -- Soulburn: Seed of Corruption
        [348] = true,    -- immolate
        [108686] = true, -- immolate (aoe)
        [157736] = true, -- immolate (green?)

        [980] = true,    -- agony
        [27243] = true,  -- seed of corruption
        [30108] = true,  -- unstable affliction
        [47960] = true,  -- shadowflame
        [48181] = true,  -- haunt
        [80240] = true,  -- havoc

        [1098] = true,   -- enslave demon

        -- metamorphosis:
        [603] = true,    -- doom
        [124915] = true, -- chaos wave
    },
    SHAMAN = {
        [8050] = true,   -- flame shock
        [17364] = true,  -- stormstrike
        [61882] = true,  -- earthquake

        [546] = true,    -- water walking
        [974] = true,    -- earth shield
        [61295] = true,  -- riptide

        [51514] = true,  -- hex
    },
    PRIEST = {
        [139] = true,    -- renew
        [6346] = true,   -- fear ward
        [33206] = true,  -- pain suppression
        [41635] = true,  -- prayer of mending buff
        [47753] = true,  -- divine aegis
        [47788] = true,  -- guardian spirit
        [114908] = true, -- spirit shell shield
        [152118] = true, -- clarity of will

        [17] = true,     -- power word: shield
        [21562] = true,  -- power word: fortitude

        [2096] = true,   -- mind vision
        [9484] = true,   -- shackle undead
        [111759] = true, -- levitate

        [589] = true,    -- shadow word: pain
        [2944] = true,   -- devouring plague
        [158831] = true, -- devouring plague
        [14914] = true,  -- holy fire
        [34914] = true,  -- vampiric touch

        -- talents:
        [129250] = true, -- power word: solace
        [155361] = true, -- void entropy
    },
    ROGUE = {
        [703] = true,    -- garrote
        [1943] = true,   -- rupture
        [79140] = true,  -- vendetta
        [84617] = true,  -- revealing strike
        [122233] = true, -- crimson tempest

        [2818] = true,   -- deadly poison
        [8680] = true,   -- wound poison

        [26679] = true,  -- deadly throw

        [57934] = true,  -- tricks of the trade

        -- talents:
        [137619] = true, -- marked for death
    },
    MONK = {
        [116189] = true, -- provoke taunt
        [123725] = true, -- breath of fire
        [122470] = true, -- touch of karma
        [128531] = true, -- blackout kick debuff
        [130320] = true, -- rising sun kick debuff

        [138130] = true, -- storm, earth and fire 1
        [138131] = true, -- storm, earth and fire 2

        [116781] = true, -- legacy of the white tiger
        [116844] = true, -- ring of peace

        [116849] = true, -- life cocoon
        [132120] = true, -- enveloping mist
        [119611] = true, -- renewing mist
        [157681] = true, -- chi explosion hot

        -- talents:
        [116841] = true, -- tiger's lust
        [124081] = true, -- zen sphere
    },
}

KuiSpellList.RegisterChanged = function(table, method)
    -- register listener for whitelist updates
    tinsert(listeners, { table, method })
end

KuiSpellList.WhitelistChanged = function()
    -- inform listeners of whitelist update
    for _,listener in ipairs(listeners) do
        if (listener[1])[listener[2]] then
            (listener[1])[listener[2]]()
        end
    end
end

KuiSpellList.AppendSpells = function(from, to)
    for spellid,val in pairs(from) do
        to[spellid] = val
    end
    return to
end

KuiSpellList.GetDefaultSpells = function(class,onlyClass)
    -- get spell list, ignoring KuiSpellListCustom
    local list = {}

    -- return a copy of the list rather than a reference
    list = KuiSpellList.AppendSpells(whitelist[class], list)
    list = KuiSpellList.AppendSpells(cc[class], list)

    if not onlyClass then
        -- also merge racial spells
        list = KuiSpellList.AppendSpells(cc.Racial, list)
    end

    return list
end

KuiSpellList.GetMergedList = function(list)
    -- get specified spell list and merge with KuiSpellListCustom if it is set
    local list = KuiSpellList.GetDefaultSpells(list, list == 'Global')

    if KuiSpellListCustom then
        local lists = list == 'Global' and {list} or {list, 'GlobalSelf'}
        for _,group in pairs(lists) do
            if KuiSpellListCustom.Ignore and KuiSpellListCustom.Ignore[group]
            then
                -- remove ignored spells
                for spellid,_ in pairs(KuiSpellListCustom.Ignore[group]) do
                    list[spellid] = nil
                end
            end

            if KuiSpellListCustom.Classes and KuiSpellListCustom.Classes[group]
            then
                -- merge custom added spells
                for spellid,_ in pairs(KuiSpellListCustom.Classes[group]) do
                    list[spellid] = true
                end
            end
        end
    end

    return list
end

-- legacy
KuiSpellList.GetImportantSpells = KuiSpellList.GetMergedList
