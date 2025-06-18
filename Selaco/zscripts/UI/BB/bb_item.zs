#include "ZScripts/UI/BB/bb_upgrade.zs"
#include "ZScripts/UI/BB/bb_item_achievements.zs"


struct BBBuilding {
    double cost, raise, bps;
    String name, description;
    int numUpgrades, count;
    bool isBuilding, mirrored;

    void set(String name, String desc, double cost, double raise, double bps, bool isBuilding = true, bool isMirrored = false) {
        //numUpgrades = 0;
        self.name = name;
        description = desc;
        self.cost = cost;
        self.raise = raise;
        self.bps = bps;
        self.isBuilding = isBuilding;
        //count = 0;
        mirrored = isMirrored;
    }

    clearscope double getBPS() const {
        return count * getEachBPS();
    }

    clearscope double getEachBPS() const {
        return (bps * BBItem.powd(2, numUpgrades));
    }
}


class BBGolden {
    double value, scaler;
    double spawnTime, endTime;
    int index;
}

enum BBSkin {
    BB_SKIN_DEFAULT = 0,
    BB_SKIN_GWYN,
    BB_SKIN_PRETTY,
    BB_SKIN_ISAAC,
    BB_SKIN_SPACE,
    BB_SKIN_VACBOT,
    BB_SKIN_GOLD,
    BB_SKIN_CASTLE,
    BB_SKIN_PIZZA,
    BB_SKIN_MAX
}

enum BBRewardType {
    BB_GEM  = 0,
    BB_SKIN = 1
}




class BBItem : Inventory {
    default { Inventory.MaxAmount 1; }

    const FLIPPER_COST = 12.0;
    const FLIPPER_RAISE = 1.15;
    const WORKER_COST = 100;
    const WORKER_RAISE = 1.15;
    const PRESTIGE_MULTIPLIER = 0.05;
    const GOLD_TIME = 13.0;

    double cps, bpc, bpcRaw, rawBps, bps, bpsc, bpscRaw, burgers, maxBurgers;
    double flipperSpeed;
    int prestige, gems;
    int clickCounter, stepCounter, goldBurgerCount;
    int flipperSpeedUpgrades;
    int goldBurgerCounter;
    int lastGoldBurgerTime;

    bool isGlobalGame;
    bool travelling;        // Keep track of travelling, since OnDestroy might be called after the a new map has loaded, saving the wrong data

    int skin;
    int skinUnlocks[BB_SKIN_MAX];

    transient ui bool hasPromptedUser;      // Have we already prompted about converting to a global game?

    Map<int, BBGolden> goldBurgers;
    

    static const int Rewards[] = {
        BB_GEM, 1,
        BB_SKIN, BB_SKIN_GWYN,
        BB_GEM, 2,
        BB_GEM, 3,
        BB_SKIN, BB_SKIN_PRETTY,
        BB_GEM, 2,
        BB_SKIN, BB_SKIN_ISAAC,
        BB_GEM, 2,
        BB_SKIN, BB_SKIN_SPACE,
        BB_GEM, 5,
        BB_SKIN, BB_SKIN_VACBOT,
        BB_GEM, 10,
        BB_SKIN, BB_SKIN_PIZZA,
        BB_GEM, 5,
        BB_GEM, 10,
        BB_SKIN, BB_SKIN_GOLD,
        BB_GEM, 3,
        BB_GEM, 3,
        BB_GEM, 10
    };

    Map<int, int> claimedRewards;

    enum Building_Types {
        Build_Flipper               = 0,
        Build_Worker                = 1,
        Build_Kitchen               = 2,
        Build_Frytruck              = 3,
        Build_Restaurant            = 4,
        Build_Factory               = 5,
        Build_Megaplex              = 6,
        Build_Gigaplex              = 7,
        Build_Offworld              = 8,
        Build_Consortium            = 9,
        Build_Portal                = 10,
        Build_MirrorUniverse        = 11,
        Build_Mirror_Worker         = 12,
        Build_Mirror_Kitchen        = 13,
        Build_Mirror_Frytruck       = 14,
        Build_Mirror_Restaurant     = 15,
        Build_Mirror_Factory        = 16,
        Build_Mirror_Megaplex       = 17,
        Build_Mirror_Gigaplex       = 18,
        Build_Mirror_Offworld       = 19,
        Build_Mirror_Consortium     = 20,
        Build_Mirror_Portal         = 21,
        Build_Mirror_MirrorUniverse = 22,

        Build_Count
    };


    BBBuilding buildings[Build_Count];
    transient bool builtBuildings;

    override void PostBeginPlay() {
        Super.PostBeginPlay();

        isGlobalGame = true;    // Only set when creating new game

        buildBuildings();
        loadGlobalGame();
        getAvailableUpgrades();
        recalcAll();
    }

    transient int lastSaveTick;
    override void PreTravelled() {
        Super.PreTravelled();

        saveGlobalGame();
        travelling = true;
    }


    override void Travelled() {
        Super.Travelled();

        travelling = false;
    }

    // Only use OnDestroy() to save game when quitting without going to a new level or main menu
    // Don't allow this to trigger during travel because it will save the wrong data
    override void OnDestroy() {
        if(!travelling) saveGlobalGame();
        
        Super.OnDestroy();
    }

    override void OwnerDied() {
        Super.OwnerDied();

        if(!travelling) saveGlobalGame(false);
    }


    clearscope bool isUnused() {
        if(burgers > 0 || prestige > 0) return false;

        for(int x = 0; x < buildings.size(); x++) {
            if(buildings[x].count > 0) {
                return false;
            }
        }

        if(countAchievements() > 0) return false;

        return true;
    }


    void loadGlobalGame() {
        // Only load if we are global and not cheating
        if(!isGlobalGame || sv_cheats > 0) {
            return;
        }

        if(developer) Console.Printf("\c[GREEN]Restoring Burger Flipper progress...");

        prestige = Globals.GetInt("BBPrestige");
        flipperSpeedUpgrades = Globals.GetInt("BBFlipperSpeedUpgrades");
        burgers = Globals.Get("BBBurgers").toDouble();
        maxBurgers = Globals.Get("BBMaxBurgers").toDouble();
        goldBurgers.clear();
        goldBurgerCounter = 0;
        lastGoldBurgerTime = 0;
        skin = Globals.GetInt("BBSkin");
        clickCounter = Globals.GetInt("BBClickCounter");
        stepCounter = Globals.GetInt("BBStepCounter");
        goldBurgerCount = Globals.GetInt("BBGoldBurgerCount");
        gems = Globals.GetInt("BBGems");

        // Load skin unlocks
        for(int x = 0; x < BB_SKIN_MAX; x++) {
            skinUnlocks[x] = Globals.GetInt(String.Format("BBSkinUnlock%d", x));
        }

        // Load rewards
        claimedRewards.clear();
        for(int x = 0; x < Rewards.size(); x += 2) {
            int rw = Globals.GetInt(String.Format("BBReward%d", x / 2));
            if(rw > 0) claimedRewards.insert(x / 2, rw);
        }

        // Load achievement progress
        loadAchievements();

        // Load building counts and upgrades
        for(int x = 0; x < buildings.size(); x++) {
            buildings[x].count = Globals.GetInt(String.Format("BBBuilding%d", x));
            buildings[x].numUpgrades = Globals.GetInt(String.Format("BBBuilding%dUpgrades", x));
        }

        // Detect new achievements
        detectAchievements();

        if(developer) Console.Printf("\c[GREEN]Done.");
    }


    void saveGlobalGame(bool shouldWrite = true) {
        if(!isGlobalGame) return;
        if(isUnused()) return;

        if(level.totalTime - lastSaveTick <= 2) return;
        lastSaveTick = level.totalTime;

        // Turn cheat protection back on
        if(sv_cheats != 0) return;

        if(developer) Console.Printf("\c[GREEN]Saving Burger Flipper progress...");

        Globals.SetInt("BBHasSave", 1);
        Globals.SetInt("BBPrestige", prestige);
        Globals.SetInt("BBFlipperSpeedUpgrades", flipperSpeedUpgrades);
        Globals.Set("BBBurgers", String.Format("%f", burgers));
        Globals.Set("BBMaxBurgers", String.Format("%f", maxBurgers));
        Globals.SetInt("BBSkin", skin);
        Globals.SetInt("BBClickCounter", clickCounter);
        Globals.SetInt("BBStepCounter", stepCounter);
        Globals.SetInt("BBGoldBurgerCount", goldBurgerCount);
        Globals.SetInt("BBGems", gems);

        // Save achievement progress
        saveAchievements();

        // Save skin unlocks
        for(int x = 0; x < BB_SKIN_MAX; x++) {
            Globals.SetInt(String.Format("BBSkinUnlock%d", x), skinUnlocks[x]);
        }

        // Save rewards
        for(int x = 0; x < Rewards.size(); x += 2)  Globals.Set(String.Format("BBReward%d", x / 2), "");
        foreach(key, value : claimedRewards) Globals.SetInt(String.Format("BBReward%d", key), value);
    
        // Save build counts and upgrades
        for(int x = 0; x < buildings.size(); x++) {
            if(buildings[x].count > 0) Globals.SetInt(String.Format("BBBuilding%d", x), buildings[x].count);
            else Globals.Set(String.Format("BBBuilding%d", x), "");

            if(buildings[x].numUpgrades > 0) Globals.SetInt(String.Format("BBBuilding%dUpgrades", x), buildings[x].numUpgrades);
            else Globals.Set(String.Format("BBBuilding%dUpgrades", x), "");
        }

        if(shouldWrite) Globals.Save();

        if(developer) Console.Printf("\c[GREEN]Saved.");
    }


    void restartGame(int prestige = 0) {
        if(developer) Console.Printf("\c[GREEN]Restarting Burger Flipper progress...");

        self.prestige = clamp(self.prestige + prestige, 0, 999);

        // Reset all buildings
        for(int x = 0; x < buildings.size(); x++) {
            buildings[x].count = 0;
            buildings[x].numUpgrades = 0;
        }

        // Reset all upgrades
        installedUpgrades.clear();
        availableUpgrades.clear();

        // Reset all stats
        burgers = 0;
        maxBurgers = 0;
        goldBurgers.clear();
        goldBurgerCounter = 0;
        lastGoldBurgerTime = 0;
        flipperSpeedUpgrades = 0;
        

        getAvailableUpgrades();
        recalcAll();
        saveGlobalGame();

        if(developer) Console.Printf("\c[GREEN]Done.");
    }


    void wipe() {
        clickCounter = goldBurgerCount = stepCounter = 0;
        skin = BB_SKIN_DEFAULT;
        gems = 0;

        // Clear skin unlocks
        for(int x = 0; x < BB_SKIN_MAX; x++) skinUnlocks[x] = 0;
        claimedRewards.clear();

        restartGame(-999999);
        achievements.clear();

        WipeGlobal();
    }

    static void WipeGlobal() {
        if(developer) Console.Printf("\c[RED]Wiping Burger Flipper progress...");

        Globals.Set("BBHasSave", "");
        Globals.Set("BBPrestige", "");
        Globals.Set("BBFlipperSpeedUpgrades", "");
        Globals.Set("BBBurgers", "");
        Globals.Set("BBMaxBurgers", "");
        Globals.Set("BBSkin", "");
        Globals.Set("BBClickCounter", "");
        Globals.Set("BBStepCounter", "");
        Globals.Set("BBGoldBurgerCount", "");
        Globals.Set("BBGems", "");

        // Wipe achievement progress
        WipeAchievements();

        // Wipe skin unlocks
        for(int x = 0; x < BB_SKIN_MAX; x++) {
            Globals.Set(String.Format("BBSkinUnlock%d", x), "");
        }

        // Wipe rewards, wipe more than defined just in case of future expansion
        for(int x = 0; x < 50; x++) {
            Globals.Set(String.Format("BBReward%d", x), "");
        }

        // Save build counts and upgrades
        for(int x = 0; x < 64; x++) {
            Globals.Set(String.Format("BBBuilding%d", x), "");
            Globals.Set(String.Format("BBBuilding%dUpgrades", x), "");
        }

        Globals.Save();

        if(developer) Console.Printf("\c[RED]Wiped.");
    }


    // Achievement stuff
    clearscope int countAchievements() {
        int cnt = int(achievements.countUsed());    // Cannot do this in one line, the compiler complains about type mismatch
        return cnt;
    }


    void claimReward(int reward) {
        if(reward >= Rewards.size()) return;
        bool exists = false;
        int val = 0;

        [val, exists] = claimedRewards.checkValue(reward);
        if(exists && val > 0) {
            EventHandler.SendInterfaceEvent(owner.PlayerNumber(), "bbrewardchanged");
            return;
        }

        int type = Rewards[reward * 2];
        int value = Rewards[reward * 2 + 1];

        if(type == BB_GEM) {
            gems += value;
        } else if(type == BB_SKIN) {
            skin = value;
            skinUnlocks[value] = 1;
        }

        claimedRewards.insert(reward, 1);

        saveGlobalGame();

        EventHandler.SendInterfaceEvent(owner.PlayerNumber(), "bbrewardchanged");
    }


    void buildBuildings() {
        buildings[Build_Flipper].set("$BB_Build_Flipper", "$BB_Build_FlipperD", FLIPPER_COST, FLIPPER_RAISE, 0.1, isBuilding: false);
        buildings[Build_Worker].set("$BB_Build_Worker", "$BB_Build_WorkerD", WORKER_COST, WORKER_RAISE, 1, isBuilding: false);
        buildings[Build_Kitchen].set("$BB_Build_Kitchen", "$BB_Build_KitchenD", 1150, 1.15, 8);
        buildings[Build_Frytruck].set("$BB_Build_Frytruck", "$BB_Build_FrytruckD", 13000, 1.15, 46);
        buildings[Build_Restaurant].set("$BB_Build_Restaurant", "$BB_Build_RestaurantD", 130000, 1.15, 264);
        buildings[Build_Factory].set("$BB_Build_Factory", "$BB_Build_FactoryD", 1417000, 1.15, 1518);
        buildings[Build_Megaplex].set("$BB_Build_Megaplex", "$BB_Build_MegaplexD", 15260000, 1.15, 8728);
        buildings[Build_Gigaplex].set("$BB_Build_Gigaplex", "$BB_Build_GigaplexD", 163500000, 1.15, 50188);
        buildings[Build_Offworld].set("$BB_Build_Offworld",  "$BB_Build_OffworldD", buildings[Build_Offworld - 1].cost * 10.75, 1.15, buildings[Build_Offworld - 1].bps * 5.75);
        buildings[Build_Consortium].set("$BB_Build_Consortium", "$BB_Build_ConsortiumD", buildings[Build_Consortium - 1].cost * 10.75, 1.15, buildings[Build_Consortium - 1].bps * 5.75);
        buildings[Build_Portal].set("$BB_Build_Portal", "$BB_Build_PortalD", buildings[Build_Portal - 1].cost * 10.75, 1.15, buildings[Build_Portal - 1].bps * 5.75);
        buildings[Build_MirrorUniverse].set( "$BB_Build_MirrorUniverse", "$BB_Build_MirrorUniverseD", buildings[Build_MirrorUniverse - 1].cost * 10.75, 1.15, buildings[Build_MirrorUniverse - 1].bps * 5.75);

        // Mirror World Hell
        buildings[Build_Mirror_Worker].set("$BB_Build_Worker", "$BB_Build_WorkerD",             buildings[Build_Mirror_Worker - 1].cost * 10.75,        1.17,       buildings[Build_Mirror_Worker - 1].bps * 5.75,      isBuilding: false, isMirrored: true);
        buildings[Build_Mirror_Kitchen].set("$BB_Build_Kitchen", "$BB_Build_KitchenD",          buildings[Build_Mirror_Kitchen - 1].cost * 10.75,       1.17,       buildings[Build_Mirror_Kitchen - 1].bps * 5.75,     isMirrored: true);
        buildings[Build_Mirror_Frytruck].set("$BB_Build_Frytruck", "$BB_Build_FrytruckD",       buildings[Build_Mirror_Frytruck - 1].cost * 10.75,      1.17,       buildings[Build_Mirror_Frytruck - 1].bps * 5.75,    isMirrored: true);
        buildings[Build_Mirror_Restaurant].set("$BB_Build_Restaurant", "$BB_Build_RestaurantD", buildings[Build_Mirror_Restaurant - 1].cost * 10.75,    1.17,       buildings[Build_Mirror_Restaurant - 1].bps * 5.75,  isMirrored: true);
        buildings[Build_Mirror_Factory].set("$BB_Build_Factory", "$BB_Build_FactoryD",          buildings[Build_Mirror_Factory - 1].cost * 10.75,       1.17,       buildings[Build_Mirror_Factory - 1].bps * 5.75,     isMirrored: true);
        buildings[Build_Mirror_Megaplex].set("$BB_Build_Megaplex", "$BB_Build_MegaplexD",       buildings[Build_Mirror_Megaplex - 1].cost * 10.75,      1.17,       buildings[Build_Mirror_Megaplex - 1].bps * 5.75,    isMirrored: true);
        buildings[Build_Mirror_Gigaplex].set("$BB_Build_Gigaplex", "$BB_Build_GigaplexD",       buildings[Build_Mirror_Gigaplex - 1].cost * 10.75,      1.17,       buildings[Build_Mirror_Gigaplex - 1].bps * 5.75,    isMirrored: true);
        buildings[Build_Mirror_Offworld].set("$BB_Build_Offworld",  "$BB_Build_OffworldD",      buildings[Build_Mirror_Offworld - 1].cost * 10.75,      1.17,       buildings[Build_Mirror_Offworld - 1].bps * 5.75,    isMirrored: true);
        buildings[Build_Mirror_Consortium].set("$BB_Build_Consortium", "$BB_Build_ConsortiumD", buildings[Build_Mirror_Consortium - 1].cost * 10.75,    1.17,       buildings[Build_Mirror_Consortium - 1].bps * 5.75,  isMirrored: true);
        buildings[Build_Mirror_Portal].set("$BB_Build_Portal", "$BB_Build_PortalD",             buildings[Build_Mirror_Portal - 1].cost * 10.75,        1.17,       buildings[Build_Mirror_Portal - 1].bps * 5.75,      isMirrored: true);
        buildings[Build_Mirror_MirrorUniverse].set( "$BB_Build_MirrorUniverse", "$BB_Build_MirrorUniverseD", buildings[Build_Mirror_MirrorUniverse - 1].cost * 10.75, 1.17, buildings[Build_Mirror_MirrorUniverse - 1].bps * 5.75, isMirrored: true);
        builtBuildings = true;
    }

    void checkBuildings() {
        if(!builtBuildings)
            buildBuildings();
    }

    // Check upgrades and calculate clicks "flips" per second
    void calcCPS() {
        calcFlipperSpeed();
        cps = (buildings[Build_Flipper].count / 10.0) * flipperSpeed;
    }

    // Check upgrades and calculate burgers per click
    void calcBPC() {
        bpc = BBItem.powd(2, buildings[Build_Flipper].numUpgrades) * (1.0 + double(countUpgrades() - buildings[Build_Flipper].numUpgrades) / 10.0);

        // Add upgrades
        for(int x = 0; x < installedUpgrades.size(); x++) {
            bpc += installedUpgrades[x].calculateAdditionalBPC();
        }
        
        bpcRaw = bpc;

        // Multiply by prestige
        bpc += (1.0 + double(prestige)) * (bpc * PRESTIGE_MULTIPLIER);
    }

    void calcFlipperSpeed() {
        flipperSpeed = 1.0 + flipperSpeedUpgrades;
    }

    clearscope int countUpgrades() {
        int up = 0;
        for(int x = 0; x < Build_Count; x++) {
            up += buildings[x].numUpgrades;
        }

        return up;
    }

    // Calculate burgers per second, without including clicks
    void calcBPS() {
        bps = 0;

        for(int x = Build_Worker; x < Build_Count; x++) {
            bps += buildings[x].getBPS();
        }

        // Add upgrades
        for(int x = 0; x < installedUpgrades.size(); x++) {
            bps += installedUpgrades[x].calculateAdditionalBPS();
        }

        rawBps = bps;
        
        // Multiply by prestige
        bps += (1.0 + double(prestige)) * (bps * PRESTIGE_MULTIPLIER);
    }

    // Calc burgers per second, including clicks
    void calcTotalBPS() {
        bpscRaw = rawBps + (cps * bpcRaw);
        bpsc = bps + (cps * bpc);
    }

    void recalcAll() {
        checkBuildings();
        calcBPS();
        calcCPS();
        calcBPC();
        calcTotalBPS();
    }

    

    override void tick() {
        checkBuildings();
        if(level.totalTime % TICRATE == 0 ) recalcAll();
        if((level.totalTime + 1) % TICRATE == 0) detectAchievements(true);

        if(burgers > 1000) {
            burgers = ceil(burgers + ITICKRATE * ((cps * bpc) + bps));
        } else {
            burgers += ITICKRATE * ((cps * bpc) + bps);
        }
        
        maxBurgers = max(maxBurgers, burgers);
        tickUpgrades();
        tickGoldBurgers();

        if(isGlobalGame && (level.totalTime % (TICRATE * 15)) == 0) {
            // Save every 15 seconds
            saveGlobalGame(false);  // Save to values but do not write to disk yet
        }
    }

    // Golden Burgers ==========================
    double goldenValue() {
        return max(50.0, (bpc * 125.0) + (bps * 5.0));
    }

    void generateGoldBurger() {
        lastGoldBurgerTime = level.totalTime;

        if(goldBurgers.CountUsed() < 5) {
            let g = new("BBGolden");
            g.value = goldenValue();
            g.spawnTime = level.totalTime;
            g.scaler = frandom(0.7, 1.2);
            g.endTime = level.totalTime + int( (GOLD_TIME * TICRATE) * g.scaler );
            g.index = goldBurgerCounter;
            

            goldBurgers.insert(goldBurgerCounter++, g);

            if(developer) Console.Printf("New gold burger spawned: %d : %f", level.totalTime, g.value);
        }
    }

    void consumeGoldBurger(int index) {
        if(goldBurgers.CheckKey(index)) {
            let g = goldBurgers.get(index);
            goldBurgers.remove(index);

            burgers += g.value;
            maxBurgers = max(maxBurgers, burgers);
            goldBurgerCount++;
        }
    }

    void tickGoldBurgers() {
        Array<int> indexes;

        // Remove stale burgers
        foreach(g : goldBurgers) {
            if(level.totalTime > g.endTime) {
                indexes.push(g.index);
            }
        }

        foreach(i : indexes) {
            goldBurgers.remove(i);
        }

        // Add a new gold burger randomly
        if(level.totalTime % 2 == 0 && level.totalTime > lastGoldBurgerTime + 15) {
            int chance = min(300, (level.totalTime - lastGoldBurgerTime) / 10);
            chance = min(chance + prestige * 150, 999);
            if(random(chance, 1101) == 999) {
                generateGoldBurger();
            }
        }
    }


    // Flippers ================================
    bool buyFlipper(int amount) {
        return buyBuilding(Build_Flipper, amount);
    }

    void loseFlipper(int amount) {
        buildings[Build_Flipper].count = max(0, buildings[Build_Flipper].count - amount);
        recalcAll();
    }

    // Workers ===================================
    bool buyWorker(int amount) {
        return buyBuilding(Build_Worker, amount);
    }


    // Buildings ===================================
    bool buyBuilding(int building, int amount) {
        checkBuildings();

        for(int x = 0; x < amount; x++) {
            double cost = getBuildingCost(building);
            if(burgers >= cost && prestige >= (building - BBItem.Build_MirrorUniverse)) {
                buildings[building].count++;
                // Give unionize achievement
                if(building == Build_Worker && buildings[building].count >= 100) {
                    StatDatabase.SetAchievement("GAME_UNIONIZE", 1);    // Giving multiple times does nothing so this should be fine
                }
                burgers -= cost;

                if(developer) Console.Printf("\c[YELLOW]BurgerFlipper: Bought %s, now has %d", buildings[building].name, buildings[building].count);

                recalcAll();
            } else {
                return false;
            }
        }
        
        return true;
    }


    bool buyUpgrade(int building) {
        checkBuildings();

        double cost = getUpgradeCost(building);
        if(burgers >= cost) {
            buildings[building].numUpgrades++;
            burgers -= cost;

            if(developer) Console.Printf("\c[YELLOW]BurgerFlipper: Upgraded %s, now has %d upgrades", buildings[building].name, buildings[building].numUpgrades);

            recalcAll();
        } else {
            return false;
        }
        
        return true;
    }


    bool buyUpgradeIndex(int index) {
        checkBuildings();

        if(availableUpgrades.size() > index) {
            let upgrade = availableUpgrades[index];
            if(upgrade && burgers >= upgrade.cost) {
                burgers -= upgrade.cost;
                installUpgrade(index);
                return true;
            }
        }

        return false;
    }


    bool flip(int amount) {
        burgers += amount * floor(bpc);
        if(burgers < 0) burgers = 0;
        clickCounter += amount;
        return true;
    }


    clearscope static float powf(float x, float n) {
        float y = 1.0;
        while (n-- > 0) y *= x;
        return y;
    }

    clearscope static double powd(double x, double n) {
        double y = 1.0;
        while (n-- > 0) y *= x;
        return y;
    }

    clearscope double getBuildingCost(int building) {
        return  max(    buildings[building].cost, 
                        buildings[building].cost * powf( buildings[building].raise, buildings[building].count )
                );
    }

    clearscope double getUpgradeCost(int building) {
        return  max(    buildings[building].cost * 10.0, 
                        buildings[building].numUpgrades * 5.0 * buildings[building].cost * 10.0
                );
    }

    static clearscope BBItem Find(int player = -1) {
        if(player == -1) player = consolePlayer;
        return players[player].mo ? BBItem(players[player].mo.FindInventory("BBItem")) : null;
    }
}


class BBHandler : StaticEventHandler {
    double lastFlipTime;

    override void WorldLoaded(WorldEvent e) {
        // Make sure BBItem has buildings
        let bb = BBItem.Find(consolePlayer);
        if(bb) {
            bb.checkBuildings();
            bb.loadGlobalGame();
            if(!bb.isGlobalGame) {
                bb.detectAchievements();
            }
        }

        lastFlipTime = MSTimeF();
    }

    override void WorldUnloaded(WorldEvent e) {
        // Save progress when world is unloaded
        let bb = BBItem.Find(consolePlayer);
        if(bb) {
            bb.saveGlobalGame();
        }
    }

    static const int costs[] = {0, 999, 1599, 2299};

    override void NetworkProcess (ConsoleEvent e) {
        if(!e.IsManual || sv_cheats > 0) {
            if(e.name == "bgfl+") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.buyFlipper(e.args[0]);
            } else if(e.name == "bgfl-" && sv_cheats > 0) {
                let bb = BBItem.Find(e.player);
                if(bb) bb.loseFlipper(e.args[0]);
            } else if(e.name == "bgflip") {
                let bb = BBItem.Find(e.player);
                if(bb) {
                    // Autoclicker detection
                    if(MSTimeF() - lastFlipTime < 51.1) {
                        bb.flip(-1);
                    } else {
                        bb.flip(e.args[0]);
                    }
                    lastFlipTime = MSTimeF();
                }
            } else if(e.name == "burgercheat") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.burgers += 100000.0 * double(e.args[0]);
            } else if(e.name == "burgercheat2") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.burgers += 1000000000000.0 * double(e.args[0]);
            } else if(e.name == "bglw+") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.buyWorker(e.args[0]);
            } else if(e.name == "bgbuild") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.buyBuilding(e.args[0], e.args[1]);
            } else if(e.name == "bgupgrade") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.buyUpgrade(e.args[0]);
            } else if(e.name == "bgupgradei") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.buyUpgradeIndex(e.args[0]);
            } else if(e.name == "bggold") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.consumeGoldBurger(e.args[0]);
            } else if(e.name == "bbpremium") {
                let mo = players[e.player].mo;
                if(mo.countInv("BBPremiumItem") < 1 && mo.countInv("CreditsCount") >= 1250) {
                    mo.TakeInventory("CreditsCount", 1250);
                    mo.GiveInventory("BBPremiumItem", 1);
                }
            } else if(e.name == "bbgem") {
                if(sv_cheats == 1) {
                    let bb = BBItem.Find(e.player);
                    if(bb) bb.gems += e.args[0];
                }
            } else if(e.name == "bbrestart") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.restartGame(-999999);
            } else if(e.name == "bbprestige") {
                let bb = BBItem.Find(e.player);
                if(bb && bb.buildings[min(BBItem.Build_Count - 1, BBItem.Build_MirrorUniverse + bb.prestige)].count > 0) {
                    bb.restartGame(1);
                } else if(bb) {
                    Console.Printf("\c[RED]Burger Flipper: Cannot prestige without first building a %s", StringTable.Localize( bb.buildings[BBItem.Build_MirrorUniverse + bb.prestige].name ));
                }
            } else if(e.name == "bbconvert") {
                let bb = BBItem.Find(e.player);
                if(bb && !bb.isGlobalGame) {
                    bb.isGlobalGame = true;
                    bb.loadGlobalGame();
                    bb.getAvailableUpgrades();
                    bb.recalcAll();
                    EventHandler.SendInterfaceEvent(e.player, "bbachupdate");
                }
            } else if(e.name == "bbwipe") {
                let bb = BBItem.Find(e.player);
                if(bb) bb.wipe();
                else BBItem.WipeGlobal();
            } else if(e.name == "bbskin") {
                let bb = BBItem.Find(e.player);
                if(bb && (sv_cheats == 1 || e.args[0] == 0 || bb.skinUnlocks[e.args[0]] == 1)) {
                    bb.skin = e.args[0];
                }
            } else if(e.name == "bbach") {
                // Cheat yourself an achievement. ANY ACHIEVEMENT! 
                // IT DOESN'T EVEN HAVE TO EXIST!!
                let bb = BBItem.Find(e.player);
                if(bb && sv_cheats == 1) {
                    let type = clamp(e.args[0], 0, BB_ACH_CUSTOM);
                    let subject = clamp(e.args[1], -999, 999);
                    let amount = max(e.args[2], 0);

                    // TODO: Verify achievement should exist!
                    let key = bb.addAchievement(type, subject, amount, 1);
                    if(developer) Console.Printf("Added achievement: %s", key);

                    // Notify UI of the achievement
                    EventHandler.SendInterfaceEvent(e.player, "bbach", type, subject, amount);
                }
            } else if(e.name == "bbsave") {
                // Save burger flipper progress
                let bb = BBItem.Find(e.player);
                if(bb) bb.saveGlobalGame();
            } else if(e.name == "bbclaim") {
                // Claim a reward
                let bb = BBItem.Find(e.player);
                if(bb) {
                    bb.claimReward(e.args[0]);
                }
            } else if(e.name == "bbskinbuy") {
                let bb = BBItem.Find(e.player);
                if(bb && bb.gems >= 20 && bb.skinUnlocks[BB_SKIN_CASTLE] == 0) {
                    bb.skinUnlocks[BB_SKIN_CASTLE] = 1;
                    bb.gems -= 20;
                    bb.skin = BB_SKIN_CASTLE;
                    bb.saveGlobalGame();
                }
            } else if(e.name == "bbuninstall") {
                players[e.player].mo.TakeInventory("BBItem", 1);
                EventHandler.SendInterfaceEvent(e.player, "bbgone");
            }
        }
    }
}