enum StatType {
    STAT_HITS                       = 0,
    STAT_HEADSHOTS                  = 1,
    STAT_KILLS_RIFLEMAN             = 2,    // Challenge: Basic rifleman
    STAT_KILLS_ENGINEER             = 3,    // Challenge: Shotgunner
    STAT_EXPLOSIVE_KILLS            = 4,
    STAT_PROPS_PUNTED               = 5,
    STAT_KILLS                      = 6,
    STAT_HEALED                     = 7,    // Health healed vs Potential (Amount actually healed vs max possible from healing item)
    STAT_CRATES_DESTROYED           = 8,
    STAT_STORAGECABINETS_OPENED     = 9,
    STAT_COLLISION_KILLS            = 10,
    STAT_DATAPADS_FOUND             = 11,
    STAT_MELEE_KILLS                = 12,
    STAT_WALLNAILS                  = 13,
    STAT_CREDITS                    = 14,   // Not actually being used or initialized, replaced by STAT_CREDITS_COLLECTED
    STAT_GIBBED                     = 15,
    STAT_DEMOLITION                 = 16,
    STAT_KILLS_JUGGERNAUT           = 17,
    STAT_KILLS_ENFORCER             = 18,
    STAT_FROZEN_KILL                = 19,
    STAT_KILLS_PLASMATROOPER        = 20,
    STAT_FIRE_KILL                  = 21,
    STAT_KILLS_HEADSHOT             = 22,
    STAT_FOOD_EATEN                 = 23,
    STAT_EXTINGUISHER_KILLS         = 24,
    STAT_ARCHNOCOLA_CONSUMED        = 25,
    STAT_SHOTS_FIRED                = 26,
    STAT_EXPLOSIVEBARRELS_DESTROYED = 27,
    STAT_ITEMS_PICKEDUP             = 28,
    STAT_LIGHTSWITCHES              = 29,
    STAT_CRAWLER_KILL               = 30,
    STAT_SHOCKED_KILL               = 31,
    STAT_STEALTH_KILL               = 32,
    STAT_STEP_COUNTER               = 33,
    STAT_SANDWICH_EATEN             = 34,
    STAT_HOTDOGS_EATEN              = 35,
    STAT_BURGERS_EATEN              = 36,
    STAT_BANANAS_EATEN              = 37,
    STAT_APPLES_EATEN               = 38,
    STAT_PLUSHIES_KILLED            = 39,
    STAT_KEYPAD_UNLOCKED            = 40,
    STAT_KILLS_SIEGER               = 41,
    STAT_CALORIE_INTAKE             = 42,
    STAT_ARMOR                      = 43,
    STAT_GLASS_DESTOYED             = 44,
    STAT_TURRETS_HACKED             = 45,
    STAT_KILLS_TURRETS              = 46,
    STAT_CREDITS_COLLECTED          = 47,
    STAT_VACBOT_PET                 = 48,
    STAT_SECRETS_FOUND              = 49,
    STAT_CAKES_EATEN                = 50,
    STAT_PIZZASLICES_EATEN          = 51,
    STAT_HOT_DROP                   = 52,
    STAT_BARREL_KILLS               = 53,
    STAT_CABINETCARDS_FOUND         = 54,
    STAT_TRADINGCARDS_FOUND         = 55,
    STAT_UPGRADES_FOUND             = 56,
    STAT_YOUCHEATED                 = 57,
    STAT_VACBOTS_MURDERED           = 58,
    STAT_THROWING_KNIFES            = 59,
    STAT_TOILETS_FLUSHED            = 60,
    STAT_TOILETS_DESTROYED          = 61,
    STAT_SLIDE_COUNT                = 62,
    STAT_DASH_COUNT                 = 63,
    STAT_SLIDE_JUMP                 = 64,
    STAT_KILLS_GUNNER               = 65,
    STAT_HEADSHOT_DISTANCE          = 66,
    STAT_KILLS_SAWDRONE             = 67,
    STAT_MINES_DESTROYED            = 68,
    STAT_MINES_DISARMED             = 69,
    STAT_SILENCER_KILL              = 70,
    STAT_FRIES_EATEN                = 71,
    STAT_ROACHES_KILLED             = 72,
    STAT_ISAACS_KILLED              = 73,
    STAT_DONUTS_EATEN               = 74,
    STAT_RAILGUNCRATE               = 75,
    STAT_KILLS_SNIPER               = 76,
    STAT_POPCORN_EATEN              = 77,
    STAT_KILLS_SHOCKDROID           = 78,
    STAT_BEER_CONSUMED              = 79,
    STAT_CLEARANCE_CARDS            = 80,
    STAT_BUNNYHOPPERS_CONSUMED      = 81,
    STAT_LEVELS_VISITED             = 82,   // Used to keep track of which levels we have actually been to
    STAT_SUPPLYCHESTS_OPENED        = 83,
    STAT_FISH_KILLED                = 84,   // Adding a stat counter for this really hurts my heart.
    STAT_KILLS_AIRDRONE             = 85,
    STAT_KILLS_INFECTED             = 86,
    STAT_WEAPONPARTS_PICKEDUP       = 87,
    STAT_CARS_DESTROYED             = 88,
    STAT_SAFEROOM_TIER              = 89,
    STAT_PROTEINSHAKES_USED         = 90,
    STAT_VENDINGMACHINES_USED       = 91,
    STAT_MACHINEGUN_AMMO            = 92,
    STAT_CRICKET_AMMO               = 93,
    STAT_SHOTGUN_AMMO               = 94,
    STAT_PLASMA_AMMO                = 95,
    STAT_NAILGUN_AMMO               = 96,
    STAT_GRENADESHELL_AMMO          = 97,
    STAT_DMR_AMMO                   = 98,
    STAT_RAILGUN_AMMO               = 99,
    STAT_GRENADES_FOUND             = 100,
    STAT_MINES_FOUND                = 101,
    STAT_ICEGRENADES_FOUND          = 102,
    STAT_SUPERDONUTS_EATEN          = 103,
    STAT_WATERMELONPIECES_EATEN     = 104,
    STAT_WATERBOTTLES_CONSUMED      = 105,
    STAT_TIMER                      = 106,  // Stores time spent globally and on every level
    STAT_RIFLESHOT                  = 107,
    STAT_SHOTGUN                    = 108,
    STAT_ROARINGCRICKET             = 109,
    STAT_SMG                        = 110,
    STAT_NAILGUN                    = 111,
    STAT_GRENADELAUNCHER            = 112,
    STAT_PLASMARIFLE                = 113,
    STAT_MARKSMANRIFLE              = 114,
    STAT_RAILGUN                    = 115,
    STAT_SIGNS_REMOVED              = 116,
    STAT_SQUADLEADER_KILLS          = 117,
    STAT_MAGNUM_KILL                = 118,
    STAT_RIFLE_KILL                = 119,
    STAT_SHOTGUN_KILL              = 120,
    STAT_SMG_KILL                  = 121,
    STAT_GRENADELAUNCHER_KILL      = 122,
    STAT_NAILGUN_KILL              = 123,
    STAT_PLASMARIFLE_KILL          = 124,
    STAT_RAILGUN_KILL              = 125,
    STAT_FISTS_KILL                = 126,
    STAT_DMR_KILL                  = 127,
    STAT_UPGRADES_BOUGHT           = 128,
    STAT_SKILL                     = 129,
    STAT_BULLETS_EVADED            = 130,
    STAT_WEAPONKITS                = 131,
    STAT_WALLHUMPS                 = 137,
    STAT_TARGETDUMMY_KILLS          = 138,
    STAT_HEADS_KICKED               = 139,
    STAT_LEGS_SHOT                 = 140,
    STAT_EQUIPMENTITEMS_THROWN      = 141,
    STAT_SLIDE_HITS                 = 150,
    STAT_MELEE_HITS                 = 151,
    STAT_ENEMIES_SHOCKED            = 152,
    STAT_JUNCTIONBOXES_DESTROYED    = 153,
    STAT_JUMPCOUNTER                = 154,
    STAT_COUNT
}


enum InternalAchievement {
    IACH_NONE       = 0,
    IACH_WILSON     = 1,    // Homecoming with Wilson
    IACH_VACBOT1    = 2,    // Repair VACBOT
    IACH_VACBOT2    = 3,    // Save VACBOT from facility explosion
    IACH_COUNT
}


struct StatDatabase native play 
{
	native static clearscope bool isAvailable();
	native static clearscope bool, int GetAchievement(String key);
	native static clearscope bool, double GetStat(String key);
	native static singleunit bool SetAchievement(String key, int value);
	native static singleunit bool SetStat(String key, double value);
	native static singleunit bool AddStat(String key, double amount);
}

// Progress info, helpers for end of level, mission reports etc
struct ProgressInfo {
    int secretsFound, secretsTotal;
    int datapadsFound, datapadsTotal;
    int tradingCardsFound, tradingCardsTotal;
    int upgradesFound, upgradesTotal;
    int clearanceTotal, clearanceFound;
    int cabinetCardsFound, cabinetCardsTotal;
    int cabinetsUnlocked, cabinetsTotal;
    int kills, totalEnemies;
    bool hasUnvisitedLevels;
};


class ChallengesUnlocked : Inventory {
    default {
        Inventory.MaxAmount 1;
    }
}


class StatTracker {
    const MAX_LEVEL_NUM = 101;

    int player;
    string displayName, globalID;
    double value, possibleValue;    // Global values
    bool globalAdd;
    bool alwaysShow;                // Always show in codex

    // Level specific values
    // These can be examined per episode or hub later
    double levelValues[MAX_LEVEL_NUM];
    double levelPossibleValues[MAX_LEVEL_NUM];

    static StatTracker Create(Class<StatTracker> cls, string name, int player, string global_ident = "", bool globalAdd = false) {
        let st = StatTracker(new(cls));
        st.displayName = name;
        st.player = player;
        st.value = st.possibleValue = 0;
        st.globalID = global_ident;
        st.globalAdd = globalAdd;

        st.init();
        st.configure();

        return st;
    }

    virtual void init() {}
    virtual void configure() {}

    play virtual void add(double val, double possibleVal = -999999) {
        if(possibleVal == -999999) {
            possibleVal = val;
        }

        // Add to total
        value += val;
        possibleValue += possibleVal;
        
        // Add to current level
        if(level.levelnum >= 0 && level.levelnum < MAX_LEVEL_NUM) {
            levelValues[level.levelnum] += val;
            levelPossibleValues[level.levelnum] += possibleVal;
        }

        // Add to stat database
        if(globalID != "" && val > 0) {
            if(globalAdd) StatDatabase.AddStat(globalID, val);
            else StatDatabase.SetStat(globalID, value);
        }
    }

    // This isn't very well thought through
    play virtual void reset(bool onlyValue = false, bool allLevels = false) {
        value = 0;
        if(!onlyValue) possibleValue = 0;

        if(allLevels) {
            for(int x = 0; x < MAX_LEVEL_NUM; x++) {
                levelValues[x] = 0;
                if(!onlyValue) levelPossibleValues[x] = 0;
            }
        } else {
            if(level.levelnum >= 0 && level.levelnum < MAX_LEVEL_NUM) {
                levelValues[level.levelnum] = 0;
                if(!onlyValue) levelPossibleValues[level.levelnum] = 0;
            }
        }
    }

    virtual void consolePrint() {
        Console.Printf("%s: Value [%.2f] of [%.2f]", displayName, value, possibleValue);
        for(int x = 0; x < MAX_LEVEL_NUM; x++) {
            if(levelValues[x] > 0 || levelPossibleValues[x] > 0) {
                Console.Printf("\c[GREY]    Level #%d: Value [%.2f] of [%.2f]", x, levelValues[x], levelPossibleValues[x]);
            }
        }
    }
}


struct StatGroup {
    Array<int> indices;     // Indices
    string name;            // Secretery Not Sure
    bool hideFromCodex;     // Be a sneaky mofo
}

// Stat item intends to store all stats for a save inside the single item
// Use StatManager for ease of use with interacting with the StatItem
class Stats : Inventory {
    StatTracker trackers[STAT_COUNT];
    transient StatGroup   groups[7];
    Array<int>  achievements;

    default {
        Inventory.MaxAmount 1;
    }

    // This now gets called every time a map starts!
    void init() {
        int pnum = Owner.PlayerNumber();

        // TODO: I forget why we need the player number stored in each tracker, that doesn't seem to make sense. Possibly remove that.
        // We can't keep these static because ZScript is butts for that.

        // Hey Cockatrice, how are you doing today? - Nexxtic
        // Great, thanks for asking. - @Cockatrice
        // NOTE: CHANGING INDICES OR DELETING TRACEKRS WILL RESULT IN VM ABORTS WHEN LOADING OLD SAVE FILES
        if(!trackers[STAT_HITS])                        trackers[STAT_HITS] =                       StatTracker.Create('StatTracker',                "$STAT_HITS",                      pnum);
        if(!trackers[STAT_HEADSHOTS])                   trackers[STAT_HEADSHOTS] =                  StatTracker.Create('StatTracker',                "$STAT_HEADSHOTS",                 pnum);
        if(!trackers[STAT_KILLS_HEADSHOT])              trackers[STAT_KILLS_HEADSHOT] =             StatTracker.Create('StatTracker',                "$STAT_KILLS_HEADSHOT",            pnum);
        if(!trackers[STAT_KILLS_RIFLEMAN])              trackers[STAT_KILLS_RIFLEMAN] =             StatTracker.Create('RiflemanChallenge',          "$STAT_KILLS_RIFLEMAN",            pnum);
        if(!trackers[STAT_KILLS_ENGINEER])              trackers[STAT_KILLS_ENGINEER] =             StatTracker.Create('EngineerChallenge',          "$STAT_KILLS_ENGINEER",            pnum);
        if(!trackers[STAT_KILLS_HEADSHOT])              trackers[STAT_KILLS_HEADSHOT] =             StatTracker.Create('StatTracker',                "$STAT_KILLS_HEADSHOT",            pnum);
        if(!trackers[STAT_EXPLOSIVE_KILLS])             trackers[STAT_EXPLOSIVE_KILLS] =            StatTracker.Create('StatTracker',                "$STAT_KILLS_RIFLEMAN",            pnum);
        if(!trackers[STAT_PROPS_PUNTED])                trackers[STAT_PROPS_PUNTED] =               StatTracker.Create('StatTracker',                "$STAT_PROPS_PUNTED",              pnum);
        if(!trackers[STAT_KILLS])                       trackers[STAT_KILLS] =                      StatTracker.Create('StatTracker',                "$STAT_KILLS",                     pnum,   "player_kills", true);
        if(!trackers[STAT_HEALED])                      trackers[STAT_HEALED] =                     StatTracker.Create('StatTracker',                "$STAT_HEALED",                    pnum);
        if(!trackers[STAT_ARMOR])                       trackers[STAT_ARMOR] =                      StatTracker.Create('StatTracker',                "$STAT_ARMOR",                     pnum);
        if(!trackers[STAT_CRATES_DESTROYED])            trackers[STAT_CRATES_DESTROYED] =           StatTracker.Create('ScavengerChallenge',         "$STAT_CRATES_DESTROYED",          pnum);
        if(!trackers[STAT_STORAGECABINETS_OPENED])      trackers[STAT_STORAGECABINETS_OPENED] =     StatTracker.Create('StorageCabinetChallenge',    "$STAT_STORAGECABINETS_OPENED",    pnum);
        if(!trackers[STAT_COLLISION_KILLS])             trackers[STAT_COLLISION_KILLS] =            StatTracker.Create('StatTracker',                "$STAT_COLLISION_KILLS",           pnum);
        if(!trackers[STAT_DATAPADS_FOUND])              trackers[STAT_DATAPADS_FOUND] =             StatTracker.Create('KnowledgeChallenge',         "$STAT_DATAPADS_FOUND",            pnum);
        if(!trackers[STAT_MELEE_KILLS])                 trackers[STAT_MELEE_KILLS] =                StatTracker.Create('StatTracker',                "$STAT_MELEE_KILLS",               pnum);
        if(!trackers[STAT_WALLNAILS])                   trackers[STAT_WALLNAILS] =                  StatTracker.Create('StatTracker',                "$STAT_WALLNAILS",                 pnum);
        if(!trackers[STAT_GIBBED])                      trackers[STAT_GIBBED] =                     StatTracker.Create('StatTracker',                "$STAT_GIBBED",                    pnum);
        if(!trackers[STAT_DEMOLITION])                  trackers[STAT_DEMOLITION] =                 StatTracker.Create('DemolishingChallenge',       "$STAT_DEMOLITION",                pnum);
        if(!trackers[STAT_KILLS_JUGGERNAUT])            trackers[STAT_KILLS_JUGGERNAUT] =           StatTracker.Create('JuggernautChallenge',        "$STAT_KILLS_JUGGERNAUT",          pnum);
        if(!trackers[STAT_KILLS_ENFORCER])              trackers[STAT_KILLS_ENFORCER] =             StatTracker.Create('EnforcerChallenge',          "$STAT_KILLS_ENFORCER",            pnum);
        if(!trackers[STAT_FROZEN_KILL])                 trackers[STAT_FROZEN_KILL] =                StatTracker.Create('StatTracker',                "$STAT_FROZEN_KILL",               pnum);
        if(!trackers[STAT_KILLS_SIEGER])                trackers[STAT_KILLS_SIEGER] =               StatTracker.Create('SiegerChallenge',            "$STAT_KILLS_SIEGER",              pnum);
        if(!trackers[STAT_KILLS_PLASMATROOPER])         trackers[STAT_KILLS_PLASMATROOPER] =        StatTracker.Create('PlasmaTrooperChallenge',     "$STAT_KILLS_PLASMATROOPER",       pnum);
        if(!trackers[STAT_FIRE_KILL])                   trackers[STAT_FIRE_KILL] =                  StatTracker.Create('StatTracker',                "$STAT_FIRE_KILL",                 pnum);
        if(!trackers[STAT_FOOD_EATEN])                  trackers[STAT_FOOD_EATEN] =                 StatTracker.Create('StatTracker',                "$STAT_FOOD_EATEN",                pnum);
        if(!trackers[STAT_ARCHNOCOLA_CONSUMED])         trackers[STAT_ARCHNOCOLA_CONSUMED] =        StatTracker.Create('StatTracker',                "$STAT_ARCHNOCOLA_CONSUMED",       pnum);
        if(!trackers[STAT_EXTINGUISHER_KILLS])          trackers[STAT_EXTINGUISHER_KILLS] =         StatTracker.Create('StatTracker',                "$STAT_EXTINGUISHER_KILLS",        pnum);
        if(!trackers[STAT_SHOTS_FIRED])                 trackers[STAT_SHOTS_FIRED] =                StatTracker.Create('StatTracker',                "$STAT_SHOTS_FIRED",               pnum);
        if(!trackers[STAT_EXPLOSIVEBARRELS_DESTROYED])  trackers[STAT_EXPLOSIVEBARRELS_DESTROYED] = StatTracker.Create('StatTracker',                "$STAT_EXPLOSIVEBARRELS_DESTROYED",pnum);
        if(!trackers[STAT_ITEMS_PICKEDUP])              trackers[STAT_ITEMS_PICKEDUP] =             StatTracker.Create('StatTracker',                "$STAT_ITEMS_PICKEDUP",            pnum);
        if(!trackers[STAT_LIGHTSWITCHES])               trackers[STAT_LIGHTSWITCHES] =              StatTracker.Create('StatTracker',                "$STAT_LIGHTSWITCHES",             pnum);
        if(!trackers[STAT_CRAWLER_KILL])                trackers[STAT_CRAWLER_KILL] =               StatTracker.Create('CrawlerChallenge',           "$STAT_CRAWLER_KILL",              pnum);
        if(!trackers[STAT_SHOCKED_KILL])                trackers[STAT_SHOCKED_KILL] =               StatTracker.Create('StatTracker',                "$STAT_SHOCKED_KILL",              pnum);
        if(!trackers[STAT_STEALTH_KILL])                trackers[STAT_STEALTH_KILL] =               StatTracker.Create('StatTracker',                "$STAT_STEALTH_KILL",              pnum);
        if(!trackers[STAT_STEP_COUNTER])                trackers[STAT_STEP_COUNTER] =               StatTracker.Create('StatTracker',                "$STAT_STEP_COUNTER",              pnum,   "player_footsteps", false);
        if(!trackers[STAT_SANDWICH_EATEN])              trackers[STAT_SANDWICH_EATEN] =             StatTracker.Create('StatTracker',                "$STAT_SANDWICH_EATEN",            pnum);
        if(!trackers[STAT_HOTDOGS_EATEN])               trackers[STAT_HOTDOGS_EATEN] =              StatTracker.Create('StatTracker',                "$STAT_HOTDOGS_EATEN",             pnum);
        if(!trackers[STAT_BURGERS_EATEN])               trackers[STAT_BURGERS_EATEN] =              StatTracker.Create('StatTracker',                "$STAT_BURGERS_EATEN",             pnum);
        if(!trackers[STAT_BEER_CONSUMED])               trackers[STAT_BEER_CONSUMED] =              StatTracker.Create('StatTracker',                "$STAT_BEER_CONSUMED",             pnum); 
        if(!trackers[STAT_LEVELS_VISITED])              trackers[STAT_LEVELS_VISITED] =             StatTracker.Create('StatTracker',                "Levels Visited",                  pnum);  // Will not be displayed to user       
        if(!trackers[STAT_BUNNYHOPPERS_CONSUMED])       trackers[STAT_BUNNYHOPPERS_CONSUMED] =      StatTracker.Create('StatTracker',                "$STAT_BUNNYHOPPERS_CONSUMED",     pnum);           
        if(!trackers[STAT_DONUTS_EATEN])                trackers[STAT_DONUTS_EATEN] =               StatTracker.Create('StatTracker',                "$STAT_DONUTS_EATEN",              pnum);
        if(!trackers[STAT_SUPERDONUTS_EATEN])           trackers[STAT_SUPERDONUTS_EATEN] =          StatTracker.Create('StatTracker',                "$STAT_SUPERDONUTS_EATEN",         pnum);
        if(!trackers[STAT_FRIES_EATEN])                 trackers[STAT_FRIES_EATEN] =                StatTracker.Create('StatTracker',                "$STAT_FRIES_EATEN",               pnum);
        if(!trackers[STAT_BANANAS_EATEN])               trackers[STAT_BANANAS_EATEN] =              StatTracker.Create('StatTracker',                "$STAT_BANANAS_EATEN",             pnum);
        if(!trackers[STAT_APPLES_EATEN])                trackers[STAT_APPLES_EATEN] =               StatTracker.Create('StatTracker',                "$STAT_APPLES_EATEN",              pnum);
        if(!trackers[STAT_CAKES_EATEN])                 trackers[STAT_CAKES_EATEN] =                StatTracker.Create('StatTracker',                "$STAT_CAKES_EATEN",               pnum);
        if(!trackers[STAT_PLUSHIES_KILLED])             trackers[STAT_PLUSHIES_KILLED] =            StatTracker.Create('StatTracker',                "$STAT_PLUSHIES_KILLED",           pnum);
        if(!trackers[STAT_KEYPAD_UNLOCKED])             trackers[STAT_KEYPAD_UNLOCKED] =            StatTracker.Create('KeypadChallenge',            "$STAT_KEYPAD_UNLOCKED",           pnum);
        if(!trackers[STAT_CALORIE_INTAKE])              trackers[STAT_CALORIE_INTAKE] =             StatTracker.Create('StatTracker',                "$STAT_CALORIE_INTAKE",            pnum);
        if(!trackers[STAT_GLASS_DESTOYED])              trackers[STAT_GLASS_DESTOYED] =             StatTracker.Create('StatTracker',                "$STAT_GLASS_DESTOYED",            pnum);
        if(!trackers[STAT_TURRETS_HACKED])              trackers[STAT_TURRETS_HACKED] =             StatTracker.Create('StatTracker',                "$STAT_TURRETS_HACKED",            pnum);
        if(!trackers[STAT_KILLS_TURRETS])               trackers[STAT_KILLS_TURRETS] =              StatTracker.Create('StatTracker',                "$STAT_KILLS_TURRETS",             pnum);
        if(!trackers[STAT_CREDITS_COLLECTED])           trackers[STAT_CREDITS_COLLECTED] =          StatTracker.Create('CreditsChallenge',           "$STAT_CREDITS_COLLECTED",         pnum);
        if(!trackers[STAT_VACBOT_PET])                  trackers[STAT_VACBOT_PET] =                 StatTracker.Create('StatTracker',                "$STAT_VACBOT_PET",                pnum);
        if(!trackers[STAT_SECRETS_FOUND])               trackers[STAT_SECRETS_FOUND] =              StatTracker.Create('SecretChallenge',            "$STAT_SECRETS_FOUND",             pnum);
        if(!trackers[STAT_PIZZASLICES_EATEN])           trackers[STAT_PIZZASLICES_EATEN] =          StatTracker.Create('StatTracker',                "$STAT_PIZZASLICES_EATEN",         pnum);
        if(!trackers[STAT_HOT_DROP])                    trackers[STAT_HOT_DROP] =                   StatTracker.Create('StatTracker',                "$STAT_HOT_DROP",                  pnum);
        if(!trackers[STAT_BARREL_KILLS])                trackers[STAT_BARREL_KILLS] =               StatTracker.Create('StatTracker',                "$STAT_BARREL_KILLS",              pnum);
        if(!trackers[STAT_CABINETCARDS_FOUND])          trackers[STAT_CABINETCARDS_FOUND] =         StatTracker.Create('ProgressStatTracker',        "$STAT_CABINETCARDS_FOUND",        pnum);
        if(!trackers[STAT_TRADINGCARDS_FOUND])          trackers[STAT_TRADINGCARDS_FOUND] =         StatTracker.Create('ProgressStatTracker',        "$STAT_TRADINGCARDS_FOUND",        pnum);
        if(!trackers[STAT_UPGRADES_FOUND])              trackers[STAT_UPGRADES_FOUND] =             StatTracker.Create('ProgressStatTracker',        "$STAT_UPGRADES_FOUND",            pnum);
        if(!trackers[STAT_YOUCHEATED])                  trackers[STAT_YOUCHEATED] =                 StatTracker.Create('StatTracker',                "$STAT_YOUCHEATED",                pnum);
        if(!trackers[STAT_VACBOTS_MURDERED])            trackers[STAT_VACBOTS_MURDERED] =           StatTracker.Create('StatTracker',                "$STAT_VACBOTS_MURDERED",          pnum);
        if(!trackers[STAT_THROWING_KNIFES])             trackers[STAT_THROWING_KNIFES] =            StatTracker.Create('StatTracker',                "$STAT_THROWING_KNIFES",           pnum);
        if(!trackers[STAT_TOILETS_FLUSHED])             trackers[STAT_TOILETS_FLUSHED] =            StatTracker.Create('StatTracker',                "$STAT_TOILETS_FLUSHED",           pnum);
        if(!trackers[STAT_TOILETS_DESTROYED])           trackers[STAT_TOILETS_DESTROYED] =          StatTracker.Create('StatTracker',                "$STAT_TOILETS_DESTROYED",         pnum);
        if(!trackers[STAT_SLIDE_COUNT])                 trackers[STAT_SLIDE_COUNT] =                StatTracker.Create('StatTracker',                "$STAT_SLIDE_COUNT",               pnum);
        if(!trackers[STAT_DASH_COUNT])                  trackers[STAT_DASH_COUNT] =                 StatTracker.Create('StatTracker',                "$STAT_DASH_COUNT",                pnum);
        if(!trackers[STAT_SLIDE_JUMP])                  trackers[STAT_SLIDE_JUMP] =                 StatTracker.Create('StatTracker',                "$STAT_SLIDE_JUMP",                pnum);
        if(!trackers[STAT_KILLS_GUNNER])                trackers[STAT_KILLS_GUNNER] =               StatTracker.Create('GunnerChallenge',            "$STAT_KILLS_GUNNER",              pnum);
        if(!trackers[STAT_HEADSHOT_DISTANCE])           trackers[STAT_HEADSHOT_DISTANCE] =          StatTracker.Create('StatTracker',                "$STAT_HEADSHOT_DISTANCE",         pnum);
        if(!trackers[STAT_KILLS_SAWDRONE])              trackers[STAT_KILLS_SAWDRONE] =             StatTracker.Create('SawdroneChallenge',          "$STAT_KILLS_SAWDRONE",            pnum);
        if(!trackers[STAT_MINES_DESTROYED])             trackers[STAT_MINES_DESTROYED] =            StatTracker.Create('MineChallenge',              "$STAT_MINES_DESTROYED",           pnum);
        if(!trackers[STAT_MINES_DISARMED])              trackers[STAT_MINES_DISARMED] =             StatTracker.Create('MineChallenge',              "$STAT_MINES_DISARMED",            pnum);
        if(!trackers[STAT_SILENCER_KILL])               trackers[STAT_SILENCER_KILL] =              StatTracker.Create('StatTracker',                "$STAT_SILENCER_KILL",             pnum);
        if(!trackers[STAT_ROACHES_KILLED])              trackers[STAT_ROACHES_KILLED] =             StatTracker.Create('StatTracker',                "$STAT_ROACHES_KILLED",            pnum);
        if(!trackers[STAT_ISAACS_KILLED])               trackers[STAT_ISAACS_KILLED] =              StatTracker.Create('StatTracker',                "$STAT_ISAACS_KILLED",             pnum);
        if(!trackers[STAT_RAILGUNCRATE])                trackers[STAT_RAILGUNCRATE] =               StatTracker.Create('StatTracker',                "$STAT_RAILGUNCRATE",              pnum);
        if(!trackers[STAT_KILLS_SNIPER])                trackers[STAT_KILLS_SNIPER] =               StatTracker.Create('SniperChallenge',            "$STAT_KILLS_SNIPER",              pnum);
        if(!trackers[STAT_POPCORN_EATEN])               trackers[STAT_POPCORN_EATEN] =              StatTracker.Create('StatTracker',                "$STAT_POPCORN_EATEN",             pnum);
        if(!trackers[STAT_KILLS_SHOCKDROID])            trackers[STAT_KILLS_SHOCKDROID] =           StatTracker.Create('StatTracker',                "$STAT_KILLS_SHOCKDROID",          pnum);
        if(!trackers[STAT_CLEARANCE_CARDS])             trackers[STAT_CLEARANCE_CARDS] =            StatTracker.Create('StatTracker',                "$STAT_CLEARANCE_CARDS",           pnum);
        if(!trackers[STAT_FISH_KILLED])                 trackers[STAT_FISH_KILLED] =                StatTracker.Create('StatTracker',                "$STAT_FISH_KILLED",               pnum);
        if(!trackers[STAT_KILLS_AIRDRONE])              trackers[STAT_KILLS_AIRDRONE] =             StatTracker.Create('AirdroneChallenge',          "$STAT_KILLS_AIRDRONE",            pnum);
        if(!trackers[STAT_SUPPLYCHESTS_OPENED])         trackers[STAT_SUPPLYCHESTS_OPENED] =        StatTracker.Create('StatTracker',                "$STAT_SUPPLYCHESTS_OPENED",       pnum);
        if(!trackers[STAT_KILLS_INFECTED])              trackers[STAT_KILLS_INFECTED] =             StatTracker.Create('InfectedChallenge',          "$STAT_KILLS_INFECTED",            pnum);
        if(!trackers[STAT_WEAPONPARTS_PICKEDUP])        trackers[STAT_WEAPONPARTS_PICKEDUP] =       StatTracker.Create('WeaponPartChallenge',        "$STAT_WEAPONPARTS_PICKEDUP",      pnum);
        if(!trackers[STAT_CARS_DESTROYED])              trackers[STAT_CARS_DESTROYED] =             StatTracker.Create('StatTracker',                "$STAT_CARS_DESTROYED",            pnum);
        if(!trackers[STAT_SAFEROOM_TIER])               trackers[STAT_SAFEROOM_TIER] =              StatTracker.Create('StatTracker',                "$STAT_SAFEROOM_TIER",             pnum);
        if(!trackers[STAT_PROTEINSHAKES_USED])          trackers[STAT_PROTEINSHAKES_USED] =         StatTracker.Create('StatTracker',                "$STAT_PROTEINSHAKES_USED",        pnum);
        if(!trackers[STAT_MACHINEGUN_AMMO])             trackers[STAT_MACHINEGUN_AMMO] =            StatTracker.Create('StatTracker',                "$STAT_MACHINEGUN_AMMO",           pnum);
        if(!trackers[STAT_CRICKET_AMMO])                trackers[STAT_CRICKET_AMMO] =               StatTracker.Create('StatTracker',                "$STAT_CRICKET_AMMO",              pnum);
        if(!trackers[STAT_SHOTGUN_AMMO])                trackers[STAT_SHOTGUN_AMMO] =               StatTracker.Create('StatTracker',                "$STAT_SHOTGUN_AMMO",              pnum);
        if(!trackers[STAT_PLASMA_AMMO])                 trackers[STAT_PLASMA_AMMO] =                StatTracker.Create('StatTracker',                "$STAT_PLASMA_AMMO",               pnum);
        if(!trackers[STAT_NAILGUN_AMMO])                trackers[STAT_NAILGUN_AMMO] =               StatTracker.Create('StatTracker',                "$STAT_NAILGUN_AMMO",              pnum);
        if(!trackers[STAT_GRENADESHELL_AMMO])           trackers[STAT_GRENADESHELL_AMMO] =          StatTracker.Create('StatTracker',                "$STAT_GRENADESHELL_AMMO",         pnum);
        if(!trackers[STAT_DMR_AMMO])                    trackers[STAT_DMR_AMMO] =                   StatTracker.Create('StatTracker',                "$STAT_DMR_AMMO",                  pnum);
        if(!trackers[STAT_RAILGUN_AMMO])                trackers[STAT_RAILGUN_AMMO] =               StatTracker.Create('StatTracker',                "$STAT_RAILGUN_AMMO",              pnum);
        if(!trackers[STAT_GRENADES_FOUND])              trackers[STAT_GRENADES_FOUND] =             StatTracker.Create('StatTracker',                "$STAT_GRENADES_FOUND",            pnum);
        if(!trackers[STAT_MINES_FOUND])                 trackers[STAT_MINES_FOUND] =                StatTracker.Create('StatTracker',                "$STAT_MINES_FOUND",               pnum);
        if(!trackers[STAT_ICEGRENADES_FOUND])           trackers[STAT_ICEGRENADES_FOUND] =          StatTracker.Create('StatTracker',                "$STAT_ICEGRENADES_FOUND",         pnum);
        if(!trackers[STAT_WATERMELONPIECES_EATEN])      trackers[STAT_WATERMELONPIECES_EATEN] =     StatTracker.Create('StatTracker',                "$STAT_WATERMELONPIECES_EATEN",   pnum);
        if(!trackers[STAT_WATERBOTTLES_CONSUMED])       trackers[STAT_WATERBOTTLES_CONSUMED] =      StatTracker.Create('StatTracker',                "$STAT_WATERBOTTLES_CONSUMED",    pnum);
        if(!trackers[STAT_TIMER])                       trackers[STAT_TIMER] =                      StatTracker.Create('StatTracker',                "Timer",                          pnum);
        if(!trackers[STAT_SIGNS_REMOVED])               trackers[STAT_SIGNS_REMOVED] =              StatTracker.Create('StatTracker',                "$STAT_SIGNS_REMOVED",            pnum);
        if(!trackers[STAT_VENDINGMACHINES_USED])        trackers[STAT_VENDINGMACHINES_USED] =       StatTracker.Create('StatTracker',                "$STAT_VENDINGMACHINES_USED",     pnum);
        if(!trackers[STAT_SQUADLEADER_KILLS])           trackers[STAT_SQUADLEADER_KILLS] =          StatTracker.Create('SquadleaderChallenge',       "$STAT_KILLS_SQUADLEADER",        pnum);
        if(!trackers[STAT_UPGRADES_BOUGHT])             trackers[STAT_UPGRADES_BOUGHT] =            StatTracker.Create('StatTracker',                "$STAT_UPGRADES_BOUGHT",          pnum);
        if(!trackers[STAT_SKILL])                       trackers[STAT_SKILL] =                      StatTracker.Create('StatTrackerSkill',           "Skill",                          pnum);
        if(!trackers[STAT_BULLETS_EVADED])              trackers[STAT_BULLETS_EVADED] =             StatTracker.Create('StatTrackerSkill',           "$STAT_BULLETS_EVADED",           pnum);
        if(!trackers[STAT_WEAPONKITS])                  trackers[STAT_WEAPONKITS] =                 StatTracker.Create('WeaponKitChallenge',         "$STAT_WEAPONKITS",               pnum);
        if(!trackers[STAT_WALLHUMPS])                   trackers[STAT_WALLHUMPS] =                  StatTracker.Create('StatTracker',                "$STAT_WALLHUMPS",                pnum);
        if(!trackers[STAT_TARGETDUMMY_KILLS])           trackers[STAT_TARGETDUMMY_KILLS] =          StatTracker.Create('StatTracker',                "$STAT_TARGETDUMMY_KILLS",        pnum);
        if(!trackers[STAT_HEADS_KICKED])                trackers[STAT_HEADS_KICKED] =               StatTracker.Create('StatTracker',                "$STAT_HEADS_KICKED",             pnum);
        if(!trackers[STAT_LEGS_SHOT])                   trackers[STAT_LEGS_SHOT] =                  StatTracker.Create('StatTracker',                "$STAT_LEGS_SHOT",                pnum);
        if(!trackers[STAT_EQUIPMENTITEMS_THROWN])       trackers[STAT_EQUIPMENTITEMS_THROWN] =      StatTracker.Create('StatTracker',                "$STAT_EQUIPMENTITEMS_THROWN",    pnum);
        if(!trackers[STAT_SLIDE_HITS])                  trackers[STAT_SLIDE_HITS] =                 StatTracker.Create('StatTracker',                "$STAT_SLIDE_HITS",               pnum);
        if(!trackers[STAT_MELEE_HITS])                  trackers[STAT_MELEE_HITS] =                 StatTracker.Create('StatTracker',                "$STAT_MELEE_HITS",               pnum);
        if(!trackers[STAT_ENEMIES_SHOCKED])             trackers[STAT_ENEMIES_SHOCKED] =            StatTracker.Create('StatTracker',                "$STAT_ENEMIES_SHOCKED",          pnum);
        if(!trackers[STAT_JUNCTIONBOXES_DESTROYED])     trackers[STAT_JUNCTIONBOXES_DESTROYED] =    StatTracker.Create('StatTracker',                "$STAT_JUNCTIONBOXES_DESTROYED",  pnum);
        if(!trackers[STAT_JUMPCOUNTER])                 trackers[STAT_JUMPCOUNTER] =                StatTracker.Create('StatTracker',                "$STAT_JUMPCOUNTER",              pnum);
        // Set always show
        if(trackers[STAT_UPGRADES_BOUGHT]) {
            trackers[STAT_UPGRADES_BOUGHT].alwaysShow = true;
        }

        // Weapons
        if(!trackers[STAT_RIFLESHOT])       trackers[STAT_RIFLESHOT]         =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_ASSAULTRIFLE")),     pnum);
        if(!trackers[STAT_SHOTGUN])         trackers[STAT_SHOTGUN]           =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_SHOTGUN")),          pnum);
        if(!trackers[STAT_ROARINGCRICKET])  trackers[STAT_ROARINGCRICKET]    =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_ROARINGCRICKET")),   pnum);
        if(!trackers[STAT_SMG])             trackers[STAT_SMG]               =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_SMG")),              pnum);
        if(!trackers[STAT_NAILGUN])         trackers[STAT_NAILGUN]           =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_NAILGUN")),          pnum);
        if(!trackers[STAT_GRENADELAUNCHER]) trackers[STAT_GRENADELAUNCHER]   =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_GRENADELAUNCHER")),  pnum);
        if(!trackers[STAT_PLASMARIFLE])     trackers[STAT_PLASMARIFLE]       =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_PLASMARIFLE")),      pnum);
        if(!trackers[STAT_MARKSMANRIFLE])   trackers[STAT_MARKSMANRIFLE]     =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_MARKSMANRIFLE")),    pnum);
        if(!trackers[STAT_RAILGUN])         trackers[STAT_RAILGUN]           =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_SHOTS_FIRED"), stringtable.Localize("$WEAPON_RAILGUN")),          pnum);
        

        if(!trackers[STAT_MAGNUM_KILL])          trackers[STAT_MAGNUM_KILL]           =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_ROARINGCRICKET")),          pnum);
        if(!trackers[STAT_RIFLE_KILL])           trackers[STAT_RIFLE_KILL]            =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_ASSAULTRIFLE")),          pnum);
        if(!trackers[STAT_SHOTGUN_KILL])         trackers[STAT_SHOTGUN_KILL]          =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_SHOTGUN")),          pnum);
        if(!trackers[STAT_SMG_KILL])             trackers[STAT_SMG_KILL]              =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_SMG")),          pnum);
        if(!trackers[STAT_NAILGUN_KILL])         trackers[STAT_NAILGUN_KILL]          =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_NAILGUN")),          pnum);
        if(!trackers[STAT_GRENADELAUNCHER_KILL]) trackers[STAT_GRENADELAUNCHER_KILL]       =      StatTracker.Create('StatTracker',           string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_GRENADELAUNCHER")),          pnum);
        if(!trackers[STAT_PLASMARIFLE_KILL])     trackers[STAT_PLASMARIFLE_KILL]      =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_PLASMARIFLE")),          pnum);
        if(!trackers[STAT_DMR_KILL])             trackers[STAT_DMR_KILL]              =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_MARKSMANRIFLE")),          pnum);
        if(!trackers[STAT_RAILGUN_KILL])         trackers[STAT_RAILGUN_KILL]          =      StatTracker.Create('StatTracker',                string.format("%s (%s)", stringtable.Localize("$STAT_KILLS"), stringtable.Localize("$WEAPON_RAILGUN")),          pnum);

        // Now create groups for these to appear in the Codex
        groups[0].name = "$STAT_CATEGORY_GENERAL";
        groups[0].indices.clear();
        groups[0].indices.push(STAT_SECRETS_FOUND);
        groups[0].indices.push(STAT_CABINETCARDS_FOUND);
        groups[0].indices.push(STAT_CLEARANCE_CARDS);
        groups[0].indices.push(STAT_STORAGECABINETS_OPENED);
        groups[0].indices.push(STAT_DATAPADS_FOUND);
        groups[0].indices.push(STAT_SAFEROOM_TIER);
        groups[0].indices.push(STAT_WEAPONKITS);
        
        groups[1].name = "$STAT_CATEGORY_COMBAT_GLOBAL";
        groups[1].indices.clear();
        groups[1].indices.push(STAT_HITS);
        groups[1].indices.push(STAT_KILLS);
        groups[1].indices.push(STAT_HEADSHOTS);
        groups[1].indices.push(STAT_KILLS_HEADSHOT);
        groups[1].indices.push(STAT_MELEE_KILLS);
        groups[1].indices.push(STAT_EXPLOSIVE_KILLS);
        groups[1].indices.push(STAT_COLLISION_KILLS);
        groups[1].indices.push(STAT_WALLNAILS);
        groups[1].indices.push(STAT_FROZEN_KILL);
        groups[1].indices.push(STAT_FIRE_KILL);
        groups[1].indices.push(STAT_SHOCKED_KILL);
        groups[1].indices.push(STAT_GIBBED);
        groups[1].indices.push(STAT_BARREL_KILLS);
        groups[1].indices.push(STAT_EXTINGUISHER_KILLS);
        groups[1].indices.push(STAT_STEALTH_KILL);
        groups[1].indices.push(STAT_THROWING_KNIFES);
        groups[1].indices.push(STAT_SILENCER_KILL);
        groups[1].indices.push(STAT_HEADSHOT_DISTANCE);
        groups[1].indices.push(STAT_BULLETS_EVADED);
        groups[1].indices.push(STAT_LEGS_SHOT);
        groups[1].indices.push(STAT_EQUIPMENTITEMS_THROWN);
        groups[1].indices.push(STAT_SLIDE_HITS);
        groups[1].indices.push(STAT_MELEE_HITS);
        groups[1].indices.push(STAT_ENEMIES_SHOCKED);

        groups[2].name = "$STAT_CATEGORY_COMBAT_WEAPONS";
        groups[2].indices.clear();
        groups[2].indices.push(STAT_SHOTS_FIRED);
        groups[2].indices.push(STAT_UPGRADES_BOUGHT);
        groups[2].indices.push(STAT_ROARINGCRICKET);
        groups[2].indices.push(STAT_MAGNUM_KILL);
        groups[2].indices.push(STAT_RIFLESHOT);
        groups[2].indices.push(STAT_RIFLE_KILL);
        groups[2].indices.push(STAT_SHOTGUN);
        groups[2].indices.push(STAT_SHOTGUN_KILL);
        groups[2].indices.push(STAT_SMG);
        groups[2].indices.push(STAT_SMG_KILL);
        groups[2].indices.push(STAT_NAILGUN);
        groups[2].indices.push(STAT_NAILGUN_KILL);
        groups[2].indices.push(STAT_GRENADELAUNCHER);
        groups[2].indices.push(STAT_GRENADELAUNCHER_KILL);
        groups[2].indices.push(STAT_PLASMARIFLE);
        groups[2].indices.push(STAT_PLASMARIFLE_KILL);
        groups[2].indices.push(STAT_MARKSMANRIFLE);
        groups[2].indices.push(STAT_DMR_KILL);
        groups[2].indices.push(STAT_RAILGUN);
        groups[2].indices.push(STAT_RAILGUN_KILL);

        groups[3].name = "$STAT_CATEGORY_COMBAT_KILLS";
        groups[3].indices.clear();
        groups[3].indices.push(STAT_KILLS_RIFLEMAN);
        groups[3].indices.push(STAT_KILLS_ENGINEER);
        groups[3].indices.push(STAT_CRAWLER_KILL);
        groups[3].indices.push(STAT_KILLS_TURRETS);
        groups[3].indices.push(STAT_KILLS_SNIPER);
        groups[3].indices.push(STAT_SQUADLEADER_KILLS);
        groups[3].indices.push(STAT_KILLS_PLASMATROOPER);
        groups[3].indices.push(STAT_KILLS_ENFORCER);
        groups[3].indices.push(STAT_KILLS_JUGGERNAUT);
        groups[3].indices.push(STAT_KILLS_SIEGER);
        groups[3].indices.push(STAT_KILLS_GUNNER);
        groups[3].indices.push(STAT_KILLS_SAWDRONE);
        groups[3].indices.push(STAT_KILLS_AIRDRONE);
        groups[3].indices.push(STAT_KILLS_INFECTED);
        groups[3].indices.push(STAT_KILLS_SHOCKDROID);
        groups[3].indices.push(STAT_TARGETDUMMY_KILLS);
        
        groups[4].name = "$STAT_CATEGORY_EXPLORATION";
        groups[4].indices.clear();
        groups[4].indices.push(STAT_WALLHUMPS);
        groups[4].indices.push(STAT_HEALED);
        groups[4].indices.push(STAT_ARMOR);
        groups[4].indices.push(STAT_ITEMS_PICKEDUP);
        groups[4].indices.push(STAT_CREDITS_COLLECTED);
        groups[4].indices.push(STAT_CRATES_DESTROYED);
        groups[4].indices.push(STAT_DEMOLITION);
        groups[4].indices.push(STAT_SUPPLYCHESTS_OPENED);
        groups[4].indices.push(STAT_WEAPONPARTS_PICKEDUP);
        groups[4].indices.push(STAT_MACHINEGUN_AMMO);
        groups[4].indices.push(STAT_CRICKET_AMMO);
        groups[4].indices.push(STAT_SHOTGUN_AMMO);
        groups[4].indices.push(STAT_PLASMA_AMMO);
        groups[4].indices.push(STAT_NAILGUN_AMMO);
        groups[4].indices.push(STAT_GRENADESHELL_AMMO);
        groups[4].indices.push(STAT_DMR_AMMO);
        groups[4].indices.push(STAT_RAILGUN_AMMO);
        groups[4].indices.push(STAT_GRENADES_FOUND);
        groups[4].indices.push(STAT_MINES_FOUND);
        groups[4].indices.push(STAT_ICEGRENADES_FOUND);

        groups[5].name = "$STAT_CATEGORY_WELLNESS";
        groups[5].indices.clear();
        groups[5].indices.push(STAT_JUMPCOUNTER);
        groups[5].indices.push(STAT_STEP_COUNTER);
        groups[5].indices.push(STAT_CALORIE_INTAKE);
        groups[5].indices.push(STAT_FOOD_EATEN);
        groups[5].indices.push(STAT_BURGERS_EATEN);
        groups[5].indices.push(STAT_HOTDOGS_EATEN);
        groups[5].indices.push(STAT_FRIES_EATEN);
        groups[5].indices.push(STAT_DONUTS_EATEN);
        groups[5].indices.push(STAT_SANDWICH_EATEN);
        groups[5].indices.push(STAT_BANANAS_EATEN);
        groups[5].indices.push(STAT_ARCHNOCOLA_CONSUMED);
        groups[5].indices.push(STAT_BEER_CONSUMED);
        groups[5].indices.push(STAT_BUNNYHOPPERS_CONSUMED);
        groups[5].indices.push(STAT_APPLES_EATEN);
        groups[5].indices.push(STAT_CAKES_EATEN);
        groups[5].indices.push(STAT_PIZZASLICES_EATEN);
        groups[5].indices.push(STAT_POPCORN_EATEN);
        groups[5].indices.push(STAT_SUPERDONUTS_EATEN);
        groups[5].indices.push(STAT_WATERMELONPIECES_EATEN);
        groups[5].indices.push(STAT_WATERBOTTLES_CONSUMED);

        groups[6].name = "$STAT_CATEGORY_OTHER";
        groups[6].indices.clear();
        groups[6].indices.push(STAT_JUNCTIONBOXES_DESTROYED);
        groups[6].indices.push(STAT_HEADS_KICKED);
        groups[6].indices.push(STAT_VENDINGMACHINES_USED);
        groups[6].indices.push(STAT_PROTEINSHAKES_USED);
        groups[6].indices.push(STAT_PROPS_PUNTED);
        groups[6].indices.push(STAT_CARS_DESTROYED);
        groups[6].indices.push(STAT_ROACHES_KILLED);
        groups[6].indices.push(STAT_ISAACS_KILLED);
        groups[6].indices.push(STAT_SLIDE_COUNT);
        groups[6].indices.push(STAT_SLIDE_JUMP);
        groups[6].indices.push(STAT_DASH_COUNT);
        groups[6].indices.push(STAT_HOT_DROP);
        groups[6].indices.push(STAT_MINES_DESTROYED);
        groups[6].indices.push(STAT_MINES_DISARMED);
        groups[6].indices.push(STAT_VACBOT_PET);
        groups[6].indices.push(STAT_VACBOTS_MURDERED);
        groups[6].indices.push(STAT_TOILETS_FLUSHED);
        groups[6].indices.push(STAT_TOILETS_DESTROYED);
        groups[6].indices.push(STAT_TURRETS_HACKED);
        groups[6].indices.push(STAT_GLASS_DESTOYED);
        groups[6].indices.push(STAT_PLUSHIES_KILLED);
        groups[6].indices.push(STAT_EXPLOSIVEBARRELS_DESTROYED);
        groups[6].indices.push(STAT_LIGHTSWITCHES);
        groups[6].indices.push(STAT_FISH_KILLED);
        groups[6].indices.push(STAT_RAILGUNCRATE);
        groups[6].indices.push(STAT_SIGNS_REMOVED);
    }


    // Static Accessors =========================================================
    // Get the stats item for this session, or create one if it does not yet exist
    static Stats GetStats(int player = -1) {
        if(player < 0) player = consolePlayer;
        
        if(!players[player].mo) return null;

        Stats stat = Stats(players[player].mo.FindInventory("Stats"));
        if(!stat) {
            players[player].mo.GiveInventory("Stats", 1);
            stat = Stats(players[player].mo.FindInventory("Stats"));
            stat.init();
        }

        return stat;
    }

    // Used out of play context, finds stats object but will not create it
    clearscope static Stats FindStats(int player = -1) {
        if(player < 0) player = consolePlayer;
        if(!players[player].mo) return null;
        return Stats(players[player].mo.FindInventory("Stats"));
    }

    static void WorldInit(int player = -1) {
        // Do not create a new one because we would just end up initing twice
        let s = FindStats(player);
        if(s) s.init();
    }

    // Print all stats to console
    clearscope static void Print() {
        let s = FindStats();

        if(!s) {
            Console.Printf("\c[RED]No Stats Inventory Object!");
            return;
        }
        for(int x = 0; x < STAT_COUNT; x++) {
            if(s.trackers[x]) {
                s.trackers[x].consolePrint();
            } else {
                Console.Printf("\c[RED]No stats object found at: %d", x);
            }
        }
    }

    // These are silent for now, no notifications
    static void SetInternalAchievement(int ach, int player = -1) {
        let s = GetStats(player);
        if(s && s.achievements.find(ach) == s.achievements.size()) {
            s.achievements.push(ach);   
        }
    }

    static void AddStat(StatType stype, int val, int possibleVal = -999999, int player = -1) {
        let s = GetStats(player);
        if(s && s.trackers[stype]) s.trackers[stype].add(val, possibleVal);
    }

    static void AddStatF(StatType stype, double val, double possibleVal = -999999, int player = -1) {
        let s = GetStats(player);
        if(s && s.trackers[stype]) s.trackers[stype].add(val, possibleVal);
    }

    static void ResetStat(StatType stype, bool onlyValue = false, int player = -1) {
        let s = GetStats(player);
        if(s && s.trackers[stype]) s.trackers[stype].reset(onlyValue);
    }

    static StatTracker GetTracker(StatType stype, int player = -1) {
        let s = GetStats(player);
        return s ? s.trackers[stype] : null;
    }

    clearscope static StatTracker FindTracker(StatType stype, int player = -1) {
        let s = FindStats(player);
        return s ? s.trackers[stype] : null;
    }

    clearscope static double, double GetTrackerValue(StatType stype, int player = -1, double defaultV = 0, double defaultPV = 0) {
        let s = FindStats(player);

        if(!s || s.trackers[stype] == null) {
            return defaultV, defaultPV;
        } else {
            return s.trackers[stype].value, s.trackers[stype].possibleValue;
        }
    }

    clearscope static int GetLowestSkill(int player = -1) {
        let s = FindStats(player);
        if(!s) return skill;

        StatTracker skills = s.trackers[STAT_SKILL];
        int lowestSkill = skill;

        for(int x = 0; x < skills.levelValues.size(); x++) {
            int s = int(skills.levelValues[x]);
            if(s < lowestSkill) lowestSkill = s;
        }

        return lowestSkill;
    }

    static void LogSkill(int player = -1) {
        let skillTracker = Stats.GetTracker(STAT_SKILL, player);
        if(skillTracker) {
            if(level.levelnum >= 0 && level.levelnum < skillTracker.levelValues.size()) {
                int newSkill = min(skillTracker.levelValues[level.levelnum], skill);
                if(newSkill != int(skillTracker.levelValues[level.levelnum])) {
                    skillTracker.levelValues[level.levelnum] = newSkill;
                    skillTracker.levelPossibleValues[level.levelnum] += 1;
                } else if(skillTracker.levelValues[level.levelnum] != skill) {
                    skillTracker.levelPossibleValues[level.levelnum] += 1;
                }
            }
        }
    }

    clearscope static bool HasVisitedLevelName(string levelName, int player = -1) {
        let li = LevelInfo.FindLevelInfo(levelName);
        if(!li || li.levelNum == 0) return false;
        return hasVisitedLevel(li.levelNum);
    }

    clearscope static bool HasVisitedLevel(int levelNum, int player = -1) {
        let s = FindStats(player);
        if(!s) return false;
        StatTracker vLevels = s.trackers[STAT_LEVELS_VISITED];
        if(vLevels && levelNum < vLevels.levelValues.size()) {
            return vLevels.levelValues[levelNum] > 0;
        }
        return false;
    }

    clearscope static bool HasFullyCompletedLevelGroup(int levelGroup, int player = -1) {
        let s = FindStats(player);
        if(!s) return false;

        ProgressInfo pi;
        GetProgressInfo(pi, player, levelGroup);

        if( pi.secretsFound >= pi.secretsTotal && 
            pi.datapadsFound >= pi.datapadsTotal && 
            pi.tradingCardsFound >= pi.tradingCardsTotal &&
            pi.clearanceFound >= pi.clearanceTotal &&
            pi.upgradesFound >= pi.upgradesTotal &&
            pi.cabinetCardsFound >= pi.cabinetCardsTotal &&
            pi.cabinetsUnlocked >= pi.cabinetsTotal
        ) return true;

        return false;
    }

    clearscope static void GetProgressInfo(out ProgressInfo progress, int player = -1, int levelGroup = -1) {
        let s = FindStats(player);
        if(!s) return;

        if(levelGroup == -1) levelGroup = level.levelGroup;
        
        // Get trackers
        StatTracker secretTracker           = s.trackers[STAT_SECRETS_FOUND];
        StatTracker datapadTracker          = s.trackers[STAT_DATAPADS_FOUND];
        StatTracker tradingCardTracker      = s.trackers[STAT_TRADINGCARDS_FOUND];
        StatTracker upgradesTracker         = s.trackers[STAT_UPGRADES_FOUND];
        StatTracker clearanceTracker        = s.trackers[STAT_CLEARANCE_CARDS];
        StatTracker cabinetCardTracker      = s.trackers[STAT_CABINETCARDS_FOUND];
        StatTracker cabinetTracker          = s.trackers[STAT_STORAGECABINETS_OPENED];
        StatTracker killTracker             = s.trackers[STAT_KILLS];
        StatTracker cheats                  = s.trackers[STAT_YOUCHEATED];
        StatTracker vLevels                 = s.trackers[STAT_LEVELS_VISITED];

        if(levelGroup != 0) {

            for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
                let info = LevelInfo.GetLevelInfo(y);
                if(info.levelGroup != levelGroup) continue;

                int x = info.levelnum;

                progress.secretsFound += secretTracker && secretTracker.levelValues.size() > x ? secretTracker.levelValues[x] : 0;
                progress.secretsTotal += secretTracker && secretTracker.levelPossibleValues.size() > x ? secretTracker.levelPossibleValues[x] : 0;
                
                progress.datapadsFound += datapadTracker && datapadTracker.levelValues.size() > x  ? datapadTracker.levelValues[x] : 0;
                progress.datapadsTotal += datapadTracker && datapadTracker.levelPossibleValues.size() > x ? datapadTracker.levelPossibleValues[x] : 0;

                progress.tradingCardsFound += tradingCardTracker && tradingCardTracker.levelValues.size() > x  ? tradingCardTracker.levelValues[x] : 0;
                progress.tradingCardsTotal += tradingCardTracker && tradingCardTracker.levelPossibleValues.size() > x ? tradingCardTracker.levelPossibleValues[x] : 0;

                progress.upgradesFound += upgradesTracker && upgradesTracker.levelValues.size() > x  ? upgradesTracker.levelValues[x] : 0;
                progress.upgradesTotal += upgradesTracker && upgradesTracker.levelPossibleValues.size() > x ? upgradesTracker.levelPossibleValues[x] : 0;

                progress.clearanceFound += clearanceTracker && clearanceTracker.levelValues.size() > x  ? clearanceTracker.levelValues[x] : 0;
                progress.clearanceTotal += clearanceTracker && clearanceTracker.levelPossibleValues.size() > x ? clearanceTracker.levelPossibleValues[x] : 0;

                progress.cabinetCardsFound += cabinetCardTracker && cabinetCardTracker.levelValues.size() > x  ? cabinetCardTracker.levelValues[x] : 0;
                progress.cabinetCardsTotal += cabinetCardTracker && cabinetCardTracker.levelPossibleValues.size() > x ? cabinetCardTracker.levelPossibleValues[x] : 0;

                progress.cabinetsUnlocked += cabinetTracker && cabinetTracker.levelValues.size() > x  ? cabinetTracker.levelValues[x] : 0;
                progress.cabinetsTotal += cabinetTracker && cabinetTracker.levelPossibleValues.size() > x ? cabinetTracker.levelPossibleValues[x] : 0;

                progress.kills += killTracker && killTracker.levelValues.size() > x  ? killTracker.levelValues[x] : 0;
                progress.totalEnemies += killTracker && killTracker.levelPossibleValues.size() > x ? killTracker.levelPossibleValues[x] : 0;
            
                if(!vLevels || vLevels.levelValues.size() <= x || vLevels.levelValues[x] <= 0) progress.hasUnvisitedLevels = true;
            }
        }
    }
}



// Special handling classes for challenges
// Note: Challenges mostly expect whole numbers
// Behaviour is undefined when using less than whole numbers
class ChallengeStatTracker : StatTracker {
    mixin CVARBuddy;

    bool skipInitialSound;          // Wether to play the challenge sound or not, kill challenges should set this to true
    double challengeValue;          // Track challenge value independant of actual value
                                    // because level 1-1 will not track challenges

    string notifText, image;
    string medalText, medalImage;
    double previousGoalValue, nextValue, initialValue, notifyAtProgress, notifyCounter, medalCounter;
    double medalAtProgress, medalAtCounter;
    double challengeIncrement, challengeIncrementMultiplier, challengesCompleted;
    double rewardBase, rewardMultiplier;
    Class<Inventory> rewardType;

    override void init() {
        Super.init();

        initialValue = 0; // Will be set after INIT
        notifText = "Challenge Completed!";
        image = "CLNG";
        nextValue = 1;
        previousGoalValue = 0;
        notifyAtProgress = 0.25;
        notifyCounter = 0;
        challengeIncrement = 1;
        challengeIncrementMultiplier = 2;
        challengesCompleted = 0;
        medalAtProgress = 0;            // Show a medal at this amount of progress
        medalAtCounter = 1;             // Show a medal every nth time
        rewardBase = 0;
        rewardMultiplier = 0;
        rewardType = "CreditsCount";
    }

    override void configure() {
        initialValue = nextValue;
    }

    virtual string getStatusText(bool inProgress = true) {
        double v = round(challengeValue);
        double pv = MAX(1.0, round(nextValue)); // Don't show lower than 1 for first challenge
        
        if(inProgress) {
            return String.Format("\c[DarkGray]Status:\c- %.0f/%.0f", v, pv);
        }

        return "\c[HI]--Complete!--";       
    }

    virtual string getRewardText(bool inProgress = true) {
        double r = calcReward(challengesCompleted + 1);
        return String.Format("\c[DarkGray]Reward:\c%s %.0f %s", rewardType is 'CreditsCount' ? "f" : "[WHITE]", r, rewardType is 'CreditsCount' ? "Credits" :  "Weapon Parts"); // TODO: Credits logo
    }

    virtual string getNotifText(bool inProgress = true) {
        return notifText;
    }
    
    virtual string getNotifLowerText(bool inProgress = true) {
        return String.Format("%s\n%s", getStatusText(inProgress), getRewardText(inProgress));
    }

    bool getChallengesUnlocked() {
        let player = player;
        if(player < 0) player = consolePlayer;

        if(players[player].mo) {
            return players[player].mo.countInv('ChallengesUnlocked') > 0;
        }

        return false;
    }

    override void add(double val, double possibleVal) {
        Super.add(val, possibleVal);
        
        if(!getChallengesUnlocked()) return; // No challenges until 02B

        challengeValue += val;

        double prevVal = challengeValue;
        double prevNVal = nextValue;
        double prevPrevVal = previousGoalValue; // Seriously these variable names are awful

        // If we have exceeded or equalled our next challenge step, complete the challenge
        if(challengeValue > nextValue || challengeValue ~== nextValue) {
            completeChallenge();
        } else if(val > 0 && iGetCVar('g_showChallenges', 2) == 1) {
            // Check for progress on challenge, and notify if necessary
            notifyCounter += val;
            if(notifyAtProgress != 0) {
                double nextNotify = floor((calcChallengeValue(challengesCompleted + 1) - nextValue) * notifyAtProgress);

                if(notifyCounter > nextNotify || notifyCounter ~== nextNotify) {
                    notifyCounter = 0;
                    
                    if(iGetCVar('g_showChallenges', 2) > 0) {
                        // Do the notification
                        // Unimportant means that it will skip the notification if there is already one showing
                        Notification.QueueOrUpdateUnimportant("ChallengeProgressNotification", getNotifText(true), getNotifLowerText(true), image, NotificationItem.SLOT_TOP_LEFT, tag: getClassName());
                    }
                } else {
                    Notification.UpdateOnly("ChallengeProgressNotification", getNotifText(true), getNotifLowerText(true), image, tag: getClassName());
                }
            }
        }


        if(val > 0 && medalImage != "" && iGetCVar('g_showChallenges', 2) > 1) {
            medalCounter += val;

            double nextNotify = floor((calcChallengeValue(challengesCompleted + 1) - nextValue) * medalAtProgress);
            if((medalAtCounter != 0 && int(challengeValue) % medalAtCounter == 0) || (medalAtProgress != 0 && medalCounter > nextNotify || medalCounter ~== nextNotify)) {
                // Display a center-screen medal
                Notification notif;
                int qPos;
                bool created;
                [notif, qPos, created] = Notification.QueueOrUpdateCls("ChallengeMedalNotification", medalText, "", medalImage, NotificationItem.SLOT_TOP_MID, tag: getClassName());
                
                ChallengeMedalNotification cNotif = ChallengeMedalNotification(notif);
                if(cNotif) {
                    cNotif.lowVal = int(prevVal - prevPrevVal);
                    cNotif.highVal = int(prevNVal - prevPrevVal);

                    if(created) {
                        cNotif.playSound = qPos > 0;
                    }
                }
            } else {
                // Update any showing or queued medals
                let i = Notification.GetItem();
                if(i) {
                    let cNotif = ChallengeMedalNotification(i.find("ChallengeMedalNotification", tag: getClassName()));
                    if(cNotif) {
                        cNotif.lowVal = int(prevVal - prevPrevVal);
                        cNotif.highVal = int(prevNVal - prevPrevVal);
                    }
                }
            }
        }
    }

    play virtual void completeChallenge(bool showNotification = true) {
        // Reward
        giveReward(challengesCompleted + 1.0);

        // Create a notification that this challenge was completed
        if(showNotification) {
            Notification.QueueNew("ChallengeNotification", getNotifText(false), getNotifLowerText(false), image, NotificationItem.SLOT_TOP_LEFT);
        }

        // Increment challenge
        increaseChallenge();

        // Check for another completion
        if(challengeValue > nextValue || challengeValue ~== nextValue) {
            completeChallenge(false);   // Don't spam notifications
        }

        notifyCounter = 0;
        medalCounter = 0;   // I don't really need both of these do I?
    }
    
    virtual double calcReward(double level) {
        return rewardBase * MAX(1.0, (level * rewardMultiplier));
    }

    play virtual void giveReward(double camount) {
        if(rewardBase > 0 || rewardMultiplier > 0) {
            let i = players[player].mo.GiveInventory(rewardType, calcReward(camount));
        }
    }

    play virtual void increaseChallenge() {
        challengesCompleted += 1.0;

        previousGoalValue = nextValue;
        nextValue = calcChallengeValue(challengesCompleted);
    }

    virtual double calcChallengeValue(double level) {
        double val = initialValue;
        for(int x = 0; x <= level; x++) {
           val += challengeIncrement * (challengeIncrementMultiplier * double(x));
        }
        return val;
    }

    override void consolePrint() {
        Console.Printf("%s: Count [%.2f] next reward in [%.2f] Currently at level [%d]", displayName, challengeValue, nextValue, challengesCompleted);
        for(int x = 0; x < MAX_LEVEL_NUM; x++) {
            if(levelValues[x] > 0 || levelPossibleValues[x] > 0) {
                Console.Printf("\c[GREY]    Level #%d: Value [%.2f] of [%.2f]", x, levelValues[x], levelPossibleValues[x]);
            }
        }
    }
}


class StatTrackerSkill : StatTracker {
    override void init() {
        Super.init();

        for(int x = 0; x < levelValues.size(); x++) {
            levelValues[x] = 999;
        }
    }

    override void consolePrint() {
        Console.Printf("%s: Value [%.2f] of [%.2f]", displayName, value, possibleValue);
        for(int x = 0; x < MAX_LEVEL_NUM; x++) {
            if(levelPossibleValues[x] > 0 && levelValues[x] < 999) {
                Console.Printf("\c[GREY]    Level #%d: Value [%.2f] of [%.2f]", x, levelValues[x], levelPossibleValues[x]);
            }
        }
    }
}

class StatTrackerKills : StatTracker {

}


class JuggernautChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Titan Slayer\c-\nDefeat Juggernauts";
        image = "ACH_6";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 50;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Titan Slayer!";
        medalImage = "ACH_6";
    }
}

class InfectedChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Mercy Kill\c-\nKill infected humans";
        image = "ACH_32";
        nextValue = 25;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Mercy Kill";
        medalImage = "ACH_32";
    }
}


class ExplosiveKillChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]TOASTED!\c-\nGet Explosive Kills";
        image = "ACH_7";
        nextValue = 5;
        challengeIncrement = 10;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Explosive Kill!";
        medalImage = "ACH_7";
    }
}

class RiflemanChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]RIFLEMAN Kill\c-\nKill Riflemen";
        image = "ACH_1";
        nextValue = 25;
        challengeIncrement = 10;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Riflemen Kill!";
        medalImage = "ACH_1";
        medalAtCounter = 5;
    }
}

class SniperChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Countersnipe\c-\nKill Snipers";
        image = "ACH_51";
        nextValue = 5;
        challengeIncrement = 10;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Countersnipe";
        medalImage = "ACH_51";
        medalAtCounter = 5;
    }
}


class WeaponKitChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Ordnance\c-\nCollect Weapon Kits";
        image = "ACH_52";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Weapon Kit Collected!";
        medalImage = "ACH_52";
        medalAtCounter = 2;
    }
}


class GunnerChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Gunner Kill\c-\nKill Gunners";
        image = "ACH_50";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 5;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Gunner Kill!";
        medalImage = "ACH_50";
        medalAtCounter = 5;
    }
}

class SquadleaderChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Squad Leader Kill\c-\nKill Squad Leaders";
        image = "ACH_43";
        nextValue = 3;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 5;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Squad  Leader Kill!";
        medalImage = "ACH_43";
        medalAtCounter = 5;
    }
}


class EngineerChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]ENGINEER KILL\c-\nKill Engineers";
        image = "ACH_2";
        nextValue = 25;
        challengeIncrement = 10;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Engineer Kill!";
        medalImage = "ACH_2";
        medalAtCounter = 5;
    }
}

class ScavengerChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Scavenger\c-\nDestroy Item Crates";
        image = "ACH_11";
        nextValue = 10;
        challengeIncrement = 50;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Scavenger!";
        medalImage = "ACH_11";
        medalAtProgress = 0.25;
        medalAtCounter = 0;
    }
}


class MeleeCollisionChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Collision\c-\nKill enemies with melee collisions";
        image = "ACH_8";
        nextValue = 10;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Collision!";
        medalImage = "ACH_8";
        medalAtCounter = 5;
    }
}

class KnowledgeChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Crisis Insight\c-\nDownload Datapads ";
        image = "ACH_23";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Crisis Insight";
        medalImage = "ACH_23";
    }
}

class MeleeChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Blunt Force\c-\nKill an enemy with a melee hit";
        image = "ACH_31";
        nextValue = 10;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Blunt Force!";
        medalImage = "ACH_31";
        medalAtCounter = 5;
    }
}

class NailgunChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Pinned\c-\nNail enemies onto the walls";
        image = "ACH_19";
        nextValue = 10;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Pinned!";
        medalImage = "ACH_19";
        medalAtCounter = 5;
    }
}

class Creditschallenge : ChallengeStatTracker {
    override void init() {
        Super.init();
        notifText = "\c[HI]Credits Obtained\c-\nCollect credits";
        image = "ACH_24";
        nextValue = 2500;
        challengeIncrement = 500;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Credits Obtained";
        medalImage = "ACH_24";
        medalAtCounter = 100;
    }
}

class GibbedChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Gibbed\c-\nGib enemies";
        image = "ACH_25";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Gibbed!";
        medalImage = "ACH_25";
        medalAtCounter = 2;
    }
}

class DemolishingChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Wrecking Crew\c-\nDestroy wallcracks";
        image = "ACH_22";
        nextValue = 3;
        challengeIncrement = 3;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Wrecking Crew!";
        medalImage = "ACH_22";
    }
}

class EnforcerChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Enforced\c-\nKill Enforcers";
        image = "ACH_26";
        nextValue = 10;
        challengeIncrement = 10;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Enforcer Killed!";
        medalImage = "ACH_26";
        medalAtCounter = 2;
    }
}

class FrozenChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Chilled\c-\nKill enemies frozen in ice";
        image = "ACH_29";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Chilled!";
        medalImage = "ACH_29";
        medalAtCounter = 5;
    }
}

class PlasmaTrooperChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Plasma Trooper Kills\c-\nKill Plasma Troopers";
        image = "ACH_17";
        nextValue = 25;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Plasma Trooper Killed!";
        medalImage = "ACH_17";
        medalAtCounter = 2;
    }
}

class BurningEnemiesChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Roasted\c-\nBurn enemies down";
        image = "ACH_33";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Roasted!";
        medalImage = "ACH_33";
    }   
}

class HeadshotChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Marksman\c-\nKill enemies with headshots";
        image = "ACH_34";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Marksman!";
        medalImage = "ACH_34";
        medalAtCounter = 5;
    }   
}

class ExtinguishedChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Extinguished\c-\nKill enemies by destroying Fire Extinguishers";
        image = "ACH_5";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Extinguished!";
        medalImage = "ACH_5";
    } 
}  

class CrawlerChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();
        notifText = "\c[HI]Exterminator\c-\nKill Crawlermines";
        image = "ACH_35";
        nextValue = 25;
        challengeIncrement = 25;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Exterminator!";
        medalImage = "ACH_35";
        medalAtCounter = 5;
    }   
}

class MineChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();
        notifText = "\c[HI]Minesweeper\c-\nDestroy or Disarm Enemy Mines";
        image = "ACH_47";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Minesweeper";
        medalImage = "ACH_47";
    }   
}

class ShockKillChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Shocked\c-\nKill shocked enemies";
        image = "ACH_28";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Shocked!";
        medalImage = "ACH_28";
    }   
}

class AirDroneChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Anti-Air\c-\nKill Air Drones";
        image = "ACH_46";
        nextValue = 10;
        challengeIncrement = 10;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Anti-Air";
        medalImage = "ACH_46";
    }   
}

class SawdroneChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Buzz off\c-\nKill Saw Drones";
        image = "ACH_48";
        nextValue = 25;
        challengeIncrement = 10;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Buzz off";
        medalImage = "ACH_48";
    }   
}

class WeaponPartChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Weaponsmith\c-\nPick up Weapon Parts";
        image = "ACH_49";
        nextValue = 250;
        challengeIncrement = 250;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Weaponsmith";
        medalImage = "ACH_49";
        medalAtCounter = 20;
    }   
}

class StealthKillChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Swift & Silent\c-\nKill unalerted enemies";
        image = "ACH_36";
        nextValue = 5;
        challengeIncrement = 10;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Swift & Silent";
        medalImage = "ACH_36";
    }   
}

class KeypadChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Master of Unlocking\c-\nEnter correct keypad combinations";
        image = "ACH_37";
        nextValue = 3;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 50;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Master of Unlocking";
        medalImage = "ACH_37";
        medalAtProgress = 0.25;
        medalAtCounter = 0;
    }   
}

class SiegerChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Sieger Killed\c-\nKill siegers";
        image = "ACH_38";
        nextValue = 10;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Sieger Killed!";
        medalImage = "ACH_38";
        medalAtCounter = 2;
    }   
}

class HackerChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Convert Turrets\c-\Convert Sentry Turrets to fight by your side.";
        image = "ACH_39";
        nextValue = 3;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Turret Converted!";
        medalImage = "ACH_39";
    }   
}

class HotDropChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Hotdrop\c-\nShoot enemies preparing a grenade";
        image = "ACH_40";
        nextValue = 3;
        challengeIncrement = 3;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Hot Drop!";
        medalImage = "ACH_40";
    }   
}

class BarrelsoFunChallenge : ChallengeStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Barrels o' Fun\c-\nKill an enemy with an explosive barrel";
        image = "ACH_41";
        nextValue = 5;
        medalAtProgress = 0.25;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Barrels 'o Fun!";
        medalImage = "ACH_41";
        medalAtCounter = 5;
    }   
}



// Progress Trackers ===============================
// These are not necessarily challenges, but they do produce notifications


class ProgressStatTracker : ChallengeStatTracker {
    mixin CVARBuddy;

    bool onlyFinalNotification;
    bool isChallenge;               // if isChallenge = false, we don't use any of the challenge funcs
    int rewardCash;

    override void init() {
        Super.init();

        rewardCash = 250;
        onlyFinalNotification = false;
        isChallenge = false;
    }

    virtual string getProgressTitle(double v, double pv) {
        if(v == pv) {
            return String.Format("\c[green]%d/%d\c- %s", v, pv, StringTable.Localize(displayName));
        }
        return String.Format("\c[HI]%d/%d\c- %s", v, pv, StringTable.Localize(displayName));
    }

    virtual string getProgressText(double v, double pv) {
        // TODO: Calculate the level slice to determine how many there actually are in this level
        if(value == possibleValue) {
            return String.Format("\c[DARKGREEN]%d/%d\c[DARKGRAY] in current Level", v, pv);
        }
        return String.Format("\c[DARKGRAY]%d/%d in current Level", v, pv);
    }

    override void add(double val, double possibleVal) {
        if(isChallenge) {
            Super.add(val, possibleVal);
        } else {
            StatTracker.add(val, possibleVal);
        }
        
        // We only want to notify if we made progress
        if(val == 0) return;

        
        int levnum = Level.levelnum;
        
        if(levnum <= 0 || levnum >= MAX_LEVEL_NUM) return;

        // Determine total possible level values that we know about
        double t, tp;
        for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
            let info = LevelInfo.GetLevelInfo(y);
            if(info.levelGroup != level.levelGroup) continue;

            if(levelValues.size() > info.levelnum) t += levelValues[info.levelnum];
            if(levelPossibleValues.size() > info.levelnum) tp += levelPossibleValues[info.levelnum];
        }

        // Check for completion
        if(levelValues[levnum] == levelPossibleValues[levnum] && levelValues[levnum] != 0) {
            //players[player].mo.GiveInventory("CreditsCount", rewardCash);
            
            Notification.QueueNew(
                'ProgressCompleteNotification', 
                getProgressTitle(levelValues[levnum], levelPossibleValues[levnum]),
                getProgressText(t, tp),
                slot : NotificationItem.SLOT_BOT_LEFT,
                props: 0//rewardCash
            );
        } else {
            Notification.QueueNew(
                'ProgressNotification', 
                getProgressTitle(levelValues[levnum], levelPossibleValues[levnum]),
                getProgressText(t, tp),
                slot : NotificationItem.SLOT_BOT_LEFT
            );
        }
    }
}


class StorageCabinetChallenge : ProgressStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Treasure\c-\nUnlock Storage Cabinets";
        image = "ACH_3";
        nextValue = 3;
        challengeIncrement = 3;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Treasure!";
        medalImage = "ACH_3";

        isChallenge = true;
    }
}


class SecretChallenge : ProgressStatTracker {
    override void init() {
        Super.init();

        notifText = "\c[HI]Secret Found\c-\nFind Secrets";
        image = "ACH_12";
        nextValue = 5;
        challengeIncrement = 5;
        challengeIncrementMultiplier = 2;
        rewardBase = 25;
        rewardMultiplier = 1;
        rewardType = "WeaponParts";
        medalText = "Secret Found!";
        medalImage = "ACH_12";

        isChallenge = true;
    }
}












































// Wes sucks