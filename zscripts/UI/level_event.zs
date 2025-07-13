enum GAME_DETAIL {
    GAMEDETAIL_LOW = 0,
    GAMEDETAIL_MEDIUM = 1,
    GAMEDETAIL_HIGH = 2,
}

class ChartVertical : actor {
    default {
        +NOINTERACTION
        +FLATSPRITE
        RenderStyle "Translucent";
        alpha 0.3;
        radius 2;
        height 2;
        scale 0.07;
    }
    states {
        spawn:
            TNT1 A 0;
            NAVP B -1 bright {
                SleepIndefinite();
            }
            stop;
    }
}

// Given to Dawn for location handling
class AreaTracker : Inventory {
    int curLevel, curArea;
    String curLevelName, curAreaName;
    String curLocation;

    default {
        Inventory.MaxAMount 1;
    }

    override void Travelled() {
        // We are in a new map, possibly reset locations
        Super.Travelled();
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();

        curArea = -1;
        curLevel = -1;
        curAreaName = "";
        curLevelName = "";
    }
}


class LevelEventHandler : StaticEventHandler {
    mixin CVARBuddy;

    // SPACE BRO
    SPACEBRO_CABINET spaceBroCabinet;
    bool spaceBroPaidFor;

    // End level
    string endLevelCon, endLevelReset;
    int endLevelResetNum;
    
    // Settings Menu
    ui int settingsPos[2];

    // Main Menu
    ui String mainMenuPos;
    
    // Death
    int deathCountdown;

    // Timing
    bool hasAutosaved;
    uint totalTicks;
    int autosaveTime, quicksaveTime;
    int levelReturnTime;                // Signals an autosave after returning to a lavel ~5 minutes
    int lastMovingAutoSaveTime;
    int gameDetailSetting;

    static clearscope LevelEventHandler Instance() {
        return LevelEventHandler(StaticEventHandler.Find("LevelEventHandler"));
    }

    static clearscope AreaTracker GetAreaTracker() {
        let p = players[consolePlayer].mo;
        let inv = AreaTracker(p.FindInventory('AreaTracker'));
        //if(!inv) inv = p.GiveInventory('AreaTracker');
        return inv;
    }

    static void EndLevel(string continueFunc = "", string resetFunc = "") {
        let evt = LevelEventHandler(StaticEventHandler.Find("LevelEventHandler"));
        if (evt) {
            evt.endLevelCon = continueFunc;
            evt.endLevelReset = resetFunc;
            evt.endLevelResetNum = 0;
            // TODO: Reset totalticks every time a level is ended (after presenting the menu)
            Dawn d = Dawn(players[0].mo);
            if(d) {
                d.invulnerableInMenu = true;    // This will undo itself as soon as menus close
            }
            
            ShaderHandler.Instance().LevelSetCameraGrain(false);
            Menu.SetMenu("EndLevelMenu");
        }
    }

    static singleunit void Intermission(int stayFunc = 0, bool endEpisode = false) {
        let evt = LevelEventHandler.Instance();
        if (evt) {
            evt.endLevelCon = "";
            evt.endLevelReset = "";
            evt.endLevelResetNum = stayFunc;

            Dawn d = Dawn(players[0].mo);
            if(d) {
                d.invulnerableInMenu = true;    // This will undo itself as soon as menus close
            }

            ShaderHandler.Instance().LevelSetCameraGrain(false);
            if(endEpisode) {
                SetAchievement("GAME_GAMEOVER");
                if(g_randomizer && RandomizerHandler.Instance()) SetAchievement("GAME_RANDOMIZER");
                
                Menu.SetMenu("EndEpisodeMenu"); // Menu must be set before modes are unlocked!
                
                // Unlock finished-game things
                if(sv_cheats == 0) {
                    // Increase completion count
                    Globals.SetInt("g_chapter1_complete", Globals.GetInt("g_chapter1_complete") + 1);

                    // Unlock specific things
                    let skill = Stats.GetLowestSkill();
                    if(skill > 2 && skill < 6)  // Unlock Hardboiled if beating on Captain and above
                        Globals.SetInt("g_hardboiled", 1);
                    Globals.SetInt("g_randomizer", 1);

                    // Check number of secrets, and unlock Bottomless Mags 
                    StatTracker secretTracker = Stats.FindTracker(STAT_SECRETS_FOUND);
                    if(secretTracker && secretTracker.value >= 50) {
                        Globals.SetInt("g_bottomlessMags", 1);
                    }
                }
            }
            else Menu.SetMenu("EndLevelMenu");
        }
    }


    static void EndStarlightMap(string continueFunc = "", string resetFunc = "") {
        let evt = LevelEventHandler(StaticEventHandler.Find("LevelEventHandler"));
        if (evt) {
            evt.endLevelCon = continueFunc;
            evt.endLevelReset = resetFunc;

            Dawn d = Dawn(players[0].mo);
            if(d) {
                d.invulnerableInMenu = true;    // This will undo itself as soon as menus close
            }

            Menu.SetMenu("StarlightMenu");
        }
    }


    static void RollCredits() {
        // Tell shaders to shut up until the level is over
        ShaderHandler.Instance().LevelSetEnabled(false);
        ShaderHandler.Instance().LevelSetCameraGrain(false);
        
        Menu.SetMenu("EndGameCreditsMenu");
    }


    static void StartSpaceBro(SPACEBRO_CABINET brocab) {
        let i = Instance();

        if(brocab) {
            // Make sure the scores are created
            SpaceBroScores.FindOrCreate();

            i.spaceBroCabinet = brocab;
            i.spaceBroPaidFor = true;
            Menu.SetMenu("SpaceBroMenu");
        }
    }

    static void ShowWorkshop() {
        Menu.SetMenu("WorkshopMenu");
    }

    void WorkshopClosed() {
        // Check to see if the player fully upgraded a weapon while in the workshop
        let d = Dawn(players[consolePlayer].mo);
        if(d) {
            Array< class<WeaponUpgrade> > classes;
            int numClasses = AllActorClasses.size();
            for(int x = 0; x < numClasses; x++) {
                if(AllActorClasses[x] is 'WeaponUpgrade' && !(AllActorClasses[x] is 'WeaponAltFire')) {
                    class<WeaponUpgrade> cls = (class<WeaponUpgrade>)(AllActorClasses[x]);
                    readonly<WeaponUpgrade> wu = GetDefaultByType(cls);
                    if(wu) {
                        classes.push(cls);
                    }
                }
            }

            // Check each weapon the player has and see if all upgrades are obtained
            for(int x = 0; x < 10; x++) {
                for(int y = 0; y < players[consolePlayer].weapons.SlotSize(x); y++) {
                    let weapon = SelacoWeapon(players[consolePlayer].mo.FindInventory(players[consolePlayer].weapons.GetWeapon(x, y)));
                    
                    if(weapon) {
                        int countedClasses = 0;

                        for(int i = 0; i < classes.size(); i++) {
                            readonly<WeaponUpgrade> wu = GetDefaultByType(classes[i]);
                            if(!wu || wu.weapon != weapon.getClass()) continue;
                            if(d.countInv(classes[i]) <= 0) {
                                weapon = null;
                                break;
                            }
                            countedClasses++;
                        }

                        if(weapon && countedClasses > 0) {
                            // We have all upgrades for this class! Give achievement.
                            SetAchievement("GAME_UPGRADES");
                            return;
                        }
                    }
                }
            }
        }
    }

    // Grants a soldier a flashlight. Dissapears when dead
    static void assignSoldierFlashlight(int targetTID)
    {
		ThinkerIterator it = ThinkerIterator.Create("EnemySoldier");
		EnemySoldier soldier = EnemySoldier(it.Next());

		// Find soldier to give a flashlight to
		for (; soldier; soldier = EnemySoldier(it.Next())) 
		{
			if(soldier.tid != targetTID)
				continue;

            // Spawn the flashlight for selected soldier
            bool succ;
			[succ, soldier.flashLightActor] = soldier.A_SPAWNITEMEX("SoldierFlashlight", flags: SXF_SETMASTER); 

            // Remove selflighting until we remove the flashlight
            soldier.selflighting = "000000";
		}
    }

    static void removeSoldierFlashlight(int targetTID)
    {
 		ThinkerIterator it = ThinkerIterator.Create("EnemySoldier");
		EnemySoldier soldier = EnemySoldier(it.Next());

		// Find the source of the quake
		for (; soldier; soldier = EnemySoldier(it.Next())) 
		{
			if(soldier.tid != targetTID && !soldier.flashLightActor)
				continue;
            if(soldier.flashLightActor)
            {
                soldier.flashLightActor.destroy();
            }
            soldier.selflighting = "696969";
		}       
    }

    static singleunit void SetAchievement(string achievementName)
    {
        if(achievementName ~== "GAME_WILSON")
        {
            achievementName = "GAME_ESCORTWILSON";
        }
        
        // Do debug stuff
        if(developer) {
            string cheater;
            if(sv_cheats)
            {
                cheater = "\n\c[red]Wait, ewww. Are you using cheats!? No achievement for you.";
            }
            players[consoleplayer].mo.A_PRINTBOLD(string.format("DEBUG: You should now have the '%s' achievement.%s", achievementName, cheater), 8.0);
            players[consoleplayer].mo.A_PLAYSOUND("ACHIEV", CHAN_AUTO);
        }

        StatDatabase.SetAchievement(achievementName, 1);
    }


    void addMutatorString(out String ms, String ident) {
        ms.AppendFormat("%s\c[GOLD]%s\c-", ms == "" ? "Mutators: " : ", ", StringTable.Localize(ident));
    }

    override String, Int GetSavegameComment() { 
        // Create base savegame data
        String str = SystemTime.Format("%c", -1);
        
        let campaignType = StringTable.Localize(g_randomizer ? "$MENU_RANDOMIZER_CAMPAIGN" : "$MENU_STANDARD_CAMPAIGN");

        str.AppendFormat("\n%s\n%s\n", campaignType, Level.LevelName);

        let skillName = StringTable.Localize(String.Format("$SKILL_%d", skill));
        str.AppendFormat("%s: %s\n", StringTable.Localize("$SKILL_TITLE"), skillName);

        int levelTime = Level.time / TICRATE;
        str.AppendFormat("Time: %02d:%02d:%02d", levelTime / 3600, (levelTime % 3600) / 60, levelTime % 60);

        // Add mutators
        // TODO: Make an easy way to retrieve what mutators are currently active
        String ms = "";
        if(g_hardcoremode)  addMutatorString(ms, "$GAMEPLAY_MODIFIER_HARDCORE");
        if(g_bottomlessMags)  addMutatorString(ms, "$GAMEPLAY_MODIFIER_BOTTOMLESSMAGS");
        if(g_scarcityMode)  addMutatorString(ms, "$GAMEPLAY_MODIFIER_ITEMSCARCITY");
        if(g_rifleStart)    addMutatorString(ms, "$GAMEPLAY_MODIFIER_RIFLESTART");
        if(g_hardboiled)    addMutatorString(ms, "$GAMEPLAY_MODIFIER_HARDBOILED");
        if(g_nohealthregeneration)    addMutatorString(ms, "$GAMEPLAY_MODIFIER_NOHEALTHREGEN");
        if(g_armorup)       addMutatorString(ms, "$GAMEPLAY_MODIFIER_ARMORUP");
        if(g_extraammo)     addMutatorString(ms, "$GAMEPLAY_MODIFIER_EXTRAAMMO");
        if(g_halflikemode)  addMutatorString(ms, "$GAMEPLAY_MODIFIER_HALFLIKE");
        if(g_legacypickups) addMutatorString(ms, "$GAMEPLAY_MODIFIER_LEGACYPICKUPS");
        if(g_freshStart)    addMutatorString(ms, "$GAMEPLAY_MODIFIER_FRESHSTART");
        if(g_harshInvasion) addMutatorString(ms, "$GAMEPLAY_MODIFIER_MAXINVASION");
        if(g_defensiveEnemies)      addMutatorString(ms, "$GAMEPLAY_MODIFIER_DEFENSIVEENEMIES");
        if(g_burgerflipperStart)    addMutatorString(ms, "$GAMEPLAY_MODIFIER_BURGERFLIPPERSTART");
        
        if(ms != "") str.AppendFormat("\n%s", ms);

        // Add mod files
        Array<String> modList;
        UIHelper.GetModList(modList);

        if(modList.size() > 0) {
            str = str .. "\n\n\c[DARKGRAY]Mods:\n";
            for(int x = 0; x < modList.size(); x++) {
                str.AppendFormat("\c[DARKGRAY]%s\n", modList[x]);
            }
        }
        
        return str, 0;
    }

    // Increases completion so we know that the intermission has already once played
    void updateStarlightSeen() {
        StarlightCompletion sc;

        switch(level.levelNum) {
            case 15:
                sc = StarlightCompletion(players[consolePlayer].mo.findInventory("StarlightGreenCompleted"));
                break;
            case 17:
                sc = StarlightCompletion(players[consolePlayer].mo.findInventory("StarlightRedCompleted"));
                break;
            case 18:
                sc = StarlightCompletion(players[consolePlayer].mo.findInventory("StarlightBlueCompleted"));
                break;
            case 19:
                sc = StarlightCompletion(players[consolePlayer].mo.findInventory("StarlightPurpleCompleted"));
                break;
        }

        if(sc && sc.amount == 1) {
            sc.amount = 2;
        }
    }


    void PutPlayerInNearestTransitionObject(int player) {
        let p = players[player].mo;
        if(!p) return;

        BlockThingsIterator it = BlockThingsIterator.Create(p, 750);
        while (it.Next()) {
            let mo = DawnLevelTransitioner(it.thing);
            if(mo) {
                if(	mo.posInside(p.pos.xy) ) {
                    p.SetOrigin(mo.pos, false);
                    break;
                }
            }
        }
    }

    
    override void NetworkProcess(ConsoleEvent e) {
        // Toggle Hud
        if(e.name == "toggle_hud") {
            iSetCVAR("hud_enabled", !(iGetCVar("hud_enabled") > 0));
            return;
        }/* else if(e.name == "world_tilt") {
            Dawn.SetWorldTilt(e.args[0], e.args[1]);
        }*/

        if(e.name == "debug_skillchange") {
            if(sv_cheats) {
                Level.SetNewSkill(e.args[0]);
            }

            return;
        }

        if(e.name == "debug_lowestskill") {
            Console.Printf("Lowest Skill: %d", Stats.GetLowestSkill(e.player));

            return;
        }

        if(e.name == "debug_crash") {
            int abcdefg = random(69, 420) / 0;
            return;
        }

        if(e.name == "change_skill") {
            if(e.args[0] < 5 && e.args[0] >= 0) {
                Level.SetNewSkill(e.args[0]);

                Notification.Subtitle("", String.Format("%s \c[HI]%s", StringTable.Localize("$SKILL_CHANGED"), StringTable.Localize(String.Format("$SKILL_%d", e.args[0]))), 3.0, props: Notification.PROP_FORCED);

                // If this were multiplayer we would have to do this for each player
                // Set the minimum skill for this level
                Stats.LogSkill(e.player);
            }
            return;
        }

        if(e.name ~== "debug_purplespot") {
            // Count purplespot actors for debugging infinite spawns
            int count = 0;
            ThinkerIterator it = ThinkerIterator.Create('OMINOUS_PurpleSpot');
            Thinker spot;
            while(spot = it.Next()) if(spot is 'OMINOUS_PurpleSpot') count++;
            it = ThinkerIterator.Create('OMINOUS_PurpleSpot', Thinker.STAT_SLEEP_FOREVER);
            while(spot = it.Next()) if(spot is 'OMINOUS_PurpleSpot') count++;
            
            Console.Printf("Purplespots: %d", count);
            return;
        }

        if(e.name ~== "debug_purplespot_delete") {
            // Delete purplespot actors that have been piling up due to an accidental infinite spawn
            Array<Thinker> spots;
            int count = 0;
            ThinkerIterator it = ThinkerIterator.Create('OMINOUS_PurpleSpot');
            Thinker spot;
            while(spot = it.Next()) if(spot is 'OMINOUS_PurpleSpot') {
                count++;
                spots.push(spot);
            }

            it = ThinkerIterator.Create('OMINOUS_PurpleSpot', Thinker.STAT_SLEEP_FOREVER);
            while(spot = it.Next()) if(spot is 'OMINOUS_PurpleSpot') {
                count++;
                spots.push(spot);
            }

            for(int x = 0; x < spots.size(); x++) {
                if(spots[x] && !spots[x].bDestroyed) spots[x].destroy();
            }

            Console.Printf("Deleted %d Purplespots", count);
            return;
        }


        if(sv_cheats && e.name.indexOf("debug_trait:") == 0) {
            class<WeaponTrait> trait = (class<WeaponTrait>) (e.name.mid(12));
            SelacoWeapon weapon = SelacoWeapon(players[e.player].readyWeapon);
            PlayerPawn pawn = PlayerPawn(players[e.player].mo);
            int rarity = e.args[0];
            if(rarity < 0) rarity = random(0,4);
            
            if(trait && weapon && pawn) {
                Console.Printf("Giving Trait: %s to %s", trait ? trait.getClassName() : 'none', weapon.getClassName());
                WeaponTrait traitObj = WeaponTrait(Actor.Spawn(trait, weapon.pos, NO_REPLACE));
                traitObj.rollStats(3, weapon.getClass());
                pawn.AddInventory(traitObj);
                weapon.addUpgrade(traitObj);
            }
        }

        if(e.name ~== "debug_egg") {
            if(e.args[0] > 1000) {
                Globals.SetInt("g_randomizer", e.args[0] - 1000);
            } else {
                Globals.SetInt("g_hardboiled", e.args[0]);
            }
            return;
        }

        if(e.name ~== "debug_sweep_blockmap") {
            // Sweep as much of the blockmap as we can in increments, attempting to crash the game by triggering a null reference
            int count;
            
            for(int x = -80000; x <= 80000; x += 10000) {
                for(int y = -80000; y <= 80000; y += 10000) {
                    BlockThingsIterator it = BlockThingsIterator.CreateFromPos(x, y, 0, 1024, 40000, false);
                    
                    while (it.Next()) {                        
                        if (!it.thing) {
                            Console.Printf("Null thing: %f %f", it.position.x, it.position.y);
                            continue;
                        }

                        ++count;
                    }
                }
            }
            

            Console.Printf("Swept %d objects, obviously the game didn't crash.", count);

            return;
        }

        // Reset progress on owned altfires
        // Use with caution!
        if(e.name == "resetaltfires") {
            if(e.args[0] == 1) ResetAltfires();
            return;
        }

        if(e.name == "resetTutorials") {
            if(e.args[0] == 1) UIHelper.ResetTutorials();
            return;
        }

        if(e.name == "debug_globals") {
            if(developer) {
                Array<String> gKeys;
                Globals.GetKeys(gKeys);

                for(int x = 0; x < gKeys.size(); x++) {
                    Console.Printf("Global: \c[ICE]%s \c-Val: \c[ICE]%s", gKeys[x], Globals.Get(gKeys[x]));
                }
            }
            return;
        }

        // Toggle Flashlight
        if(e.name == "Toggle_Flashlight") {
            PlayerPawn pawn = players[e.player].mo;
			let d = Dawn(pawn);
            if((d) && d.countInv("FlashlightItem") > 0) {
				FlashlightItem flashLight = FlashlightItem(d.FindInventory("FlashlightItem"));
				flashLight.ToggleFlashlight();
            }
            return;
        }

        // Switch to Last Weapon
        if(e.name == "LastWeapon") {
            PlayerPawn pawn = players[e.player].mo;
			let d = Dawn(pawn);
            if(d) {
                d.switchToLastWeapon();
            }
            return;
        }

        // Change Equipment
        if(e.name == "switchGadget") {

            PlayerPawn pawn = players[e.player].mo;
            if((pawn) && pawn.player.ReadyWeapon && selacoWeapon(pawn.player.ReadyWeapon)) {
				selacoWeapon(pawn.player.ReadyWeapon).cycleThrowables();
            }
            return;
        }


        // Use Medkit
        if(e.name == "UseMedkit") {
            PlayerPawn pawn = players[e.player].mo;
			let d = Dawn(pawn);
            let success = d.validateMedkit();
            if (success == Dawn.Medkit_Success) {
                d.setupHealing();
            } else {
                d.rejectHealing(success);
            }
            return;

        // Throw a grenade
        } else if(e.name == "ThrowGadget") {
            PlayerPawn pawn=players[0].mo;
            // Only throw grenades if we are not in a camera
            if(pawn && (players[e.player].camera == null || players[e.player].camera == pawn) && selacoWeapon(pawn.player.ReadyWeapon))
            {
                SelacoWeapon weapon = selacoWeapon(pawn.player.ReadyWeapon);
                if(weapon)
                {
                    weapon.throwEquipmentItem();
                }

            }             
            // TODO: Stop using an inventory item for this
            return;
        } else if(e.name == "OpenCodex") {
            PDAManager.OpenCodex();
            return;
        } else if(e.name == "WorkshopClosed") {
            WorkshopClosed();
            return;
        }

        // Place Marker
        if(e.name == "Place_Marker") {

            PlayerPawn pawn = players[e.player].mo;
			let d = Dawn(pawn);
            d.PlaceMarker();
            return;
        }

        // Autosave
        if(e.name == "quicksaveselaco") {
			let d = Dawn(players[0].mo);
            if(d && d.quicksaveTimerCurrent == 0 && d.countinv("isPlaying") == 1) {
                d.quicksaveTimerCurrent = d.QUICKSAVE_DELAY_TIMER;
                d.checkSaveValidation(isQuicksave: true);
            }
            return;
        }

        if(e.name == "endLevelCon") {
            // Tell shaders to shut up until the level is over
            ShaderHandler.Instance().LevelSetEnabled(false);
            ShaderHandler.Instance().LevelSetCameraGrain(false);

            // Return the music to what played before
            MusicHandler musicHandler = MusicHandler.instance();
            S_ChangeMusic(musicHandler.getPreviousTrack());

            if(e.args[0] == 69) RollCredits();
            else {
                if(endLevelCon != "") { players[ConsolePlayer].mo.ACS_NamedExecute(endLevelCon); }
            
                // If there is a pending level transition, run it
                let handler = LevelTransitionHandler.Instance();
                if(handler.levelNumArg >= 0) {
                    handler.startLevelTransition();
                }
            }
        } else if(e.name == "endLevelRes") {
            ShaderHandler.Instance().LevelSetEnabled(true);
            ShaderHandler.Instance().LevelSetCameraGrain(true);
            if(endLevelReset != "") players[ConsolePlayer].mo.ACS_NamedExecute(endLevelReset);
            if(endLevelResetNum != 0) 
            {
                ACS_Execute(endLevelResetNum);
            }

            // If there is no stay script, attempt to place the player at the nearest transition object
            if(endLevelReset == "" && endLevelResetNum == 0) {
                PutPlayerInNearestTransitionObject(consolePlayer);
            }
            returnTrackAfterIntermission();

            endLevelReset = "";
            endLevelResetNum = 0;
            endLevelCon = "";
        } else if(e.name == "endStarlightCon") {
            if(endLevelCon != "") players[ConsolePlayer].mo.ACS_NamedExecute(endLevelCon);
            updateStarlightSeen();
        } else if(e.name == "endStarlightRes") {
            if(endLevelReset != "") players[ConsolePlayer].mo.ACS_NamedExecute(endLevelReset);
        } else if(e.name == "spaceBroOver") {
            if(spaceBroCabinet) {
                spaceBroCabinet.gameFinished();
            }
        } else if(e.name == "spaceBroStartedGame") {
            spaceBroPaidFor = false;

            if(spaceBroCabinet) {
                spaceBroCabinet.gameStarted();
            }
        } else if(e.name == "spaceBroLevel") {
            if(!e.IsManual && spaceBroCabinet && e.args[0] == 10) {
                SetAchievement("GAME_BRO");
            }
        } else if(e.name == "spaceBroPurchase") {
            // Remove credits from the player, we purchased a new game!
            players[e.player].mo.takeInventory('CreditsCount', e.args[0] ? e.args[0] : 2);
        } else if(e.name == "spaceBroScore" && !e.IsManual) {
            // Won't save if it's not a high score, so don't bother to test
            SpaceBroScores.FindOrCreate().logHighScore(e.args[0]);
        } else if((e.name == "continue" || e.name == "quickload") && !e.IsManual) {
            // Set player state to continue after dying
            players[consolePlayer].playerstate = PST_ENTER;
        } else if(e.name.indexOf("buy:") == 0 && (!e.IsManual || sv_cheats > 0)) {
            // TODO: Check for upgrade station
            WeaponUpgrade.BuyUpgrade(e.name.mid(4), e.player);
        } else if(e.name.indexOf("upg:") == 0 && (!e.IsManual || sv_cheats > 0)) {
            // TODO: Check for upgrade station
            WeaponUpgrade.SetUpgradeEnabled(e.name.mid(4), e.player, e.args[0]);
        } else if(e.name.indexOf("alf:") == 0 && (!e.IsManual || sv_cheats > 0)) {
            // TODO: Check for upgrade station
            WeaponAltFire.SetUpgradeEnabled(e.name.mid(4), e.player, e.args[0]);
        } else if(e.name.indexOf("ammo1:") == 0 && (!e.IsManual || sv_cheats > 0)) {
            // TODO: Check for upgrade station
            // Buy the specified ammo
            class<SelacoAmmo> am = (class<SelacoAmmo>) (e.name.mid(6));
            if(am) {
                int ammoAmount = GetDefaultByType(am).shopAmount;
                int cost = GetDefaultByType(am).shopPrice;
                let moneyInv = players[e.player].mo.FindInventory('CreditsCount');

                if(moneyInv && moneyInv.amount >= cost) {
                    players[e.player].mo.takeInventory('CreditsCount', cost);
                    players[e.player].mo.giveInventory(am, ammoAmount);
                }
            }
        } else if(e.name.indexOf("ammo2:") == 0 && (!e.IsManual || sv_cheats > 0)) {
            // TODO: Check for upgrade station
            // Buy full amount of the specified ammo
            class<SelacoAmmo> am = (class<SelacoAmmo>)(e.name.mid(6));
            if(am) {
                let def = GetDefaultByType(am);
                let inv = players[e.player].mo.FindInventory(am);
                let moneyInv = players[e.player].mo.FindInventory('CreditsCount');
                int amountOfAmmo = (inv ? inv.maxAmount : def.maxAmount) - (inv ? inv.amount : 0);
                int cost = def.shopPrice * (amountOfAmmo / def.shopAmount);
                
                if(moneyInv && moneyInv.amount >= cost) {
                    players[e.player].mo.takeInventory('CreditsCount', cost);
                    players[e.player].mo.giveInventory(am, amountOfAmmo);
                }
            }
        } else if(e.name.indexOf("weaponSpawn:") == 0 && sv_cheats > 0) {
            WeaponPickup.DebugSpawnPickup(players[consolePlayer].mo, e.name.mid(12));
        }
        else if(e.name ~== "giveAltfires") 
        {
            if(sv_cheats > 0) 
            {
                SelacoWeapon.GiveAltfires(e.player);
            }
        } else if(e.name ~== "giveSafeRooms") {
            if(sv_cheats > 0) {
                // Unlock all maps tagged with saferooms
                for(int lev = 0; lev < LevelInfo.GetLevelInfoCount(); lev++) {
                    let i = LevelInfo.GetLevelInfo(lev);
                    if(i.flags3 & LEVEL3_SAFEROOM) {
                        SafeRoomItem.UnlockSaferoom(i.levelNum);
                    }
                }
            }
        }
    }

    void returnTrackAfterIntermission()
    {
        // Return the music to what played before
        MusicHandler musicHandler = MusicHandler.instance();
        musicHandler.fadeToNewTrack(musicHandler.getPreviousTrack(), "", false);
        musicHandler.fadeoverride = 0.3;
    }

    override void worldTick() {
        totalTicks++;

        if(autosaveTime >= 0 && level.time >= autosaveTime + 22) {
            autosaveTime = -1;
            quicksaveTime = -1;

            if(!hasAutosaved) Level.MakeAutosave();
            hasAutosaved = true;
        } else if(quicksaveTime >= 0 && level.time >= quicksaveTime + 22) {
            autosaveTime = -1;
            quicksaveTime = -1;

            Level.MakeQuicksave();
        } else if(level.maptime == 0) {
            // Autosave game if not in Hardcore Mode
            let plr = players[consoleplayer].mo;
            if(plr && plr.countinv("hardcoreMode") == 0 && plr.countinv("BombTimer06") == 0) {
                // Special case for 01A, since 01A will autosave manually after the fade-in
                if(!hasAutosaved && !(level.mapName ~== "SE_01A")) {
                    Level.MakeAutosave();
                }
                hasAutosaved = true;
            }
        } else if(requiresAutosave || (levelReturnTime != 0 && level.maptime > 0)) {
            // Make an auto save if we have returned to this map after 5 minutes or so
            let plr = players[consoleplayer].mo;
            if(plr && plr.countinv("hardcoreMode") == 0 && plr.countinv("BombTimer06") == 0) {
                if(!hasAutosaved) Level.MakeAutosave();
                hasAutosaved = true;
            }

            // Special case for marking 01B as having saved
            if(requiresAutosave && level.mapName ~== "SE_01B" && LocalLevelHandler.Instance()) {
                LocalLevelHandler.Instance().hasAutosavedIn01B = true;
            }

            // These are largely the same thing, but they must both exist because two different entry points to the auto save exist
            levelReturnTime = 0;
            requiresAutosave = false;
        }

        if(deathCountdown > 0 || (deathCountdown == 0 && players[consolePlayer].mo && players[consolePlayer].mo.health == 0)) {
            if(Level.maptime >= players[consolePlayer].respawn_time && 
                (
                    players[consolePlayer].cmd.buttons & BT_ATTACK      || 
                    players[consolePlayer].cmd.buttons & BT_ALTATTACK   || 
                    players[consolePlayer].cmd.buttons & BT_USE         ||
                    players[consolePlayer].cmd.buttons & BT_USER1       ||  
                    --deathCountdown == 0
                )) {
                deathCountdown  = 0;
                Menu.SetMenu("DeathMenu");
            }
        }

        // Update Game Detail 
        if(level.time % 40 == 0) {
            gameDetailSetting = players[consolePlayer].mo.getCvar("g_gamedetail");
        }
        processPickups();   // Defined in hud_element_pickups.zs
    }

    override void uiTick() {
        if(quicksaveTime >= 0 && quicksaveTime == level.time - 1 || autosaveTime >= 0 && autosaveTime == level.time - 1) {
            S_StartSound("ui/savegame", CHAN_VOICE, CHANF_UI, snd_menuvolume);
            HUD.SaveStarted();
        }
        else if(quicksaveTime >= 0 && level.time >= quicksaveTime + 22) HUD.SaveCompleted();
        else if(autosaveTime >= 0 && level.time >= autosaveTime + 22) HUD.SaveCompleted();

        processPickupsUI();   // Defined in hud_element_pickups.zs
    }


    override bool SkillShouldChange(int oldSkill, int newSkill) {
        if(oldSkill >= 5) {
            if(oldSkill == 5) Console.Printf("\c[RED]You chose SMF, sucks to be you.");
            return false;
        }/* else if(oldSkill < newSkill) {
            Console.Printf("\c[RED]You can only lower difficulty.");
            return false;
        }*/

        return true;
    }


    override void NewGame() {
        totalTicks = 0;
        spaceBroCabinet = null;
        spaceBroPaidFor = false;
        endLevelCon = "";
        endLevelReset = "";
        autosaveTime = -1;
        quicksaveTime = -1;
        deathCountdown = -1;
        levelReturnTime = 0;
        hasAutosaved = false;
        lastMovingAutoSaveTime = 0;
        requiresAutosave = false;

        // TODO: Set levels visited max value to how many valid levels there are in the game
    }

    
    bool requiresAutosave;
    override void WorldLoaded(WorldEvent e) {
        // Display current objectives when you load a save game
        if(e.isSaveGame) {
            Notification.QueueOrUpdate('ObjectivesNotification', slot: NotificationItem.SLOT_MID_RIGHT);

            // Player loaded save, give a brief moment of protection
            PlayerPawn pawn=players[consoleplayer].mo;
            let d = Dawn(pawn);
            if(d)  
                d.A_PLAYSOUND("ui/loadgame", chan_auto);
                d.activateSaveProtection();

            lastMovingAutoSaveTime = level.totalTime;   // Reset auto-save map transition timer
        }

        if(e.isSaveGame || e.IsReopen) {
            // If the weapon wheel is open, close it
            // The wheel handler is not capable of doing this itself since it is not a static event handler
            let wheel = WeaponWheelHandler.Instance();
            if(wheel) wheel.forceClosed();
        }

        autosaveTime = -1;
        quicksaveTime = -1;
        deathCountdown = -1;
        hasAutosaved = false;

        for(int i = 0; i < players.size(); i++) {
            let p = players[i].mo;
            if(p) {
                // Make sure all players have an area tracker
                p.GiveInventory('AreaTracker', 1);

                // Recalculate stats on weapons, in case there is an update
                for(Inventory item = p.Inv; item != NULL; item = item.Inv) {
                    let sw = SelacoWeapon(item);
                    if(sw) {
                        sw.calculateStats();
                    }
                }
            }
        }

        // Update stats to verify that all of them have been created
        // This can happen when we add new stats and the player loads an old save file that doesn't contain the old stats
        if(e.isSaveGame) {
            Stats.WorldInit();
        }
        
        // Increase stat
        if(!e.IsReopen) {
            if(level.levelNum >= 6 || g_randomizer) for(int x = 0; x < players.size(); x++) if(players[x].mo) players[x].mo.GiveInventory("ChallengesUnlocked", 1);

            Stats.AddStat(STAT_LEVELS_VISITED, 1, 0);
            levelReturnTime = 0;
        } else if(level.totalTime > lastMovingAutoSaveTime + (TICRATE * 60 * 5)) {
            lastMovingAutoSaveTime = level.totalTime;
            levelReturnTime = level.totalTime;
            if(developer) Console.Printf("Last moving save time indicates we want a save");
        } else {
            levelReturnTime = 0;
        }

        // Special case to fix a problem generated in SE_01B where an auto save after turning off lockdown was not happening
        if(LocalLevelHandler.Instance() && !LocalLevelHandler.Instance().hasAutosavedIn01B && level.mapName ~== "SE_01B") {
            let d = Dawn(players[consoleplayer].mo);
            if(d) {
                if(d.countinv("hardcoreMode") == 0) {
                    // Check location to see if its near the return spawn
                    if((d.pos.xy - (1615, -1976)).length() < 512) {
                        if(developer) Console.Printf("Autosaving 01b %d", level.totalTime);
                        requiresAutosave = true;
                    }
                }
            }
        }
    }

    override void WorldUnloaded(WorldEvent e) {
        Globals.Save();
    }

    // Will be called if the user is trying to save via console command or menus
    // Will not be called if internal save functions are used to save the game
    override bool IsSaveAllowed(bool quicksave) {
        if(!sv_cheats && ( players[consolePlayer].mo && players[consolePlayer].mo.FindInventory("HardcoreMode") )) {
            // Validate save through GWYN Machine
            let handler = GWYNHandler.Instance();
            if(!handler || !handler.currentMachine || !handler.boughtSave) {
                return false;
            }
        }

        // TODO: If quicksave, use the system that checks for danger before quicksaving
        return true;
    }

    override void PlayerDied(PlayerEvent e) {
        // Start countdown for death menu
        if(e.PlayerNumber == consolePlayer && deathCountdown < 0) {
            deathCountdown = TICRATE * 4;
        }

        if(e.PlayerNumber == consolePlayer && skill == SKILL_SMF && level.totalTime <= (TICRATE * 5)) {
            SetAchievement("GAME_UNFAIR");
        }
    }

    override void PlayerEntered(PlayerEvent e) {
        Stats.LogSkill(e.playerNumber);
    }

    static void StartQuickSave() {
        let i = Instance();
        i.quicksaveTime = level.time;
        i.autosaveTime = -1;
    }

    static void StartAutoSave() {
        let i = Instance();
        i.autosaveTime = level.time;
        i.quicksaveTime = -1;
    }

    static void LocationEntered(String name, bool force = false) {
        let i = Instance();
        let tracker = GetAreaTracker();

        if(i && (tracker.curLocation != name || force)) {
            // Localize the text because we never add ``$`` in ACS >:(
	        string locationLocalized;
            locationLocalized.AppendFormat("$%s", name);
            
            // Some weird Cockatrice magic that is probably not important.
            Notification.Remove("LOC");
            Notification.QueueNew('LocationNotification', "$NOW_ENTERING", locationLocalized, "", NotificationItem.SLOT_TOP_MID, 0, "LOC");
            tracker.curLocation = name;
        }
    }

    static void AreaEntered(String areaName, bool force = false, int overrideAreaNum = 0) {
        let i = Instance();
        let tracker = GetAreaTracker();
        int isHalfLike = players[consolePlayer].mo.getCvar("g_halflikemode");
        if(i && (force || (tracker.curLevel != level.levelGroup || tracker.curArea != level.areaNum || tracker.curAreaName != areaName))) {
	        string areaLocalized;
            areaLocalized.AppendFormat("$%s", areaName);
            tracker.curArea = level.areaNum;
            if(overrideAreaNum)
            {
                tracker.curArea = overrideAreaNum;
            }
            tracker.curLevel = level.levelGroup;
            tracker.curAreaName = areaName;
            Notification.Remove("AREA");

            if(level.levelGroup == 7) {
                // Exception for Starlight
                Notification.QueueNew('AreaNotification', StringTable.Localize("$SPECIAL_LEVEL"), areaLocalized, "", NotificationItem.SLOT_TOP_MID, 0, "AREA");
            } else if(isHalfLike) {
                Notification.QueueNew('AreaNotification', "", areaLocalized, "", NotificationItem.SLOT_TOP_MID, 0, "AREA");
            } else {
                Notification.QueueNew('AreaNotification', String.Format("%s %d-%d", StringTable.Localize("$LEVEL"), level.levelGroup, tracker.curArea), areaLocalized, "", NotificationItem.SLOT_TOP_MID, 0, "AREA");
            }
        }
    }

    static void FloorAreaEntered(String areaName, String floorSuffix, bool force = false) {
        let i = Instance();
        let tracker = GetAreaTracker();
	    string floorLocalized, floorSuffixLocalized;
        floorLocalized.AppendFormat("$%s", areaName);
        floorSuffixLocalized.AppendFormat("$%s", floorSuffix);
        if(i && (force || (tracker.curLevel != level.levelGroup || tracker.curArea != level.areaNum || tracker.curAreaName != areaName))) {
            tracker.curArea = level.areaNum;
            tracker.curLevel = level.levelGroup;
            tracker.curAreaName = areaName;
            Notification.Remove("AREA");
            Notification.QueueNew('AreaNotification', String.Format("%s %s", StringTable.Localize("$FLOOR"), StringTable.Localize(floorSuffixLocalized)), floorLocalized, "", NotificationItem.SLOT_TOP_MID, 0, "AREA");
        }
    }

    static void StarlightAreaEntered(String areaColor, String areaName, bool force = false) {
        let i = Instance();
        let tracker = GetAreaTracker();

        if(i && (force || (tracker.curLevel != level.levelGroup || tracker.curArea != level.areaNum || tracker.curAreaName != areaName))) {
	        string areaLocalized, colorLocalized;
            areaLocalized.AppendFormat("$%s", areaName);
            colorLocalized.AppendFormat("$%s", areaColor);
            tracker.curArea = level.areaNum;
            tracker.curLevel = level.levelGroup;
            tracker.curAreaName = areaName;
            Notification.Remove("AREA");
            Notification.QueueNew('AreaNotification', String.Format("Starlight - %s", StringTable.Localize(colorLocalized)), areaLocalized, "", NotificationItem.SLOT_TOP_MID, 0, "AREA");
        }
    }

    static void LevelEntered(String levelName, bool force = false) {
        let i = Instance();
        let tracker = GetAreaTracker();
        int isHalfLike = players[consolePlayer].mo.getCvar("g_halflikemode");
        if(i && (force || (tracker.curLevel != level.levelGroup || tracker.curLevelName != levelName))) {
	        string levelLocalized;
            levelLocalized.AppendFormat("$%s", levelName);
            tracker.curArea = 0;
            tracker.curAreaName = "";
            tracker.curLevel = level.levelGroup;
            tracker.curLevelName = levelName;
            Notification.Remove("LEVEL");

            if(level.levelGroup == 7) {
                // Exception for Starlight
                Notification.QueueNew('LevelNotification', StringTable.Localize("$SPECIAL_LEVEL"), levelLocalized, " ", NotificationItem.SLOT_TOP_MID, 0, "LEVEL");
            } else if(isHalfLike) {
                Notification.QueueNew('LevelNotification', String.Format("", level.levelGroup), levelLocalized, " ", NotificationItem.SLOT_TOP_MID, 0, "LEVEL");
            } else {   
                Notification.QueueNew('LevelNotification', String.Format("%s %d", StringTable.Localize("$LEVEL"), level.levelGroup), levelLocalized, " ", NotificationItem.SLOT_TOP_MID, 0, "LEVEL");
            }
            
        }
    }

    static void SaferoomExtensionEntered() {
        let i = Instance();
        let tracker = GetAreaTracker();
        Notification.Remove("LEVEL");
        Notification.QueueNew('LevelNotification', "", StringTable.Localize("$GENERAL_LOCATION_SAFEROOM_EXTENSION"), " ", NotificationItem.SLOT_TOP_MID, 0, "LEVEL");
    }

    static void FloorLevelEntered(String levelName, bool force = false) {
        let i = Instance();
        let tracker = GetAreaTracker();

        if(i && (force || (tracker.curLevel != level.levelGroup || tracker.curLevelName != levelName))) {
            tracker.curArea = 0;
            tracker.curAreaName = "";
            tracker.curLevel = level.levelGroup;
            tracker.curLevelName = levelName;
            Notification.Remove("LEVEL");
            Notification.QueueNew('LevelNotification', String.Format("%s %d", StringTable.Localize("$FLOOR"), level.levelGroup), levelName, " ", NotificationItem.SLOT_TOP_MID, 0, "LEVEL");
        }
    }

    static void dawnTalkACS(string voiceLine, string voiceSubtitle = "", float subtitleTime = 2, int settingRequirementMin = DIALOG_ALL)
    {
        let d = Dawn(players[consolePlayer].mo);
        d.dawnTalk(voiceLine, voiceSubtitle, subtitleTime, settingRequirementMin);
    }


    // Find all altfire/upgrade classes and remove them from globals
    void ResetAltfires() {
        for(int x = AllActorClasses.size() - 1; x >= 0; x--) {
            let cls = AllActorClasses[x];
            if(cls is 'WeaponUpgrade') {
                Globals.Set(String.Format("%s", cls.getClassName()).MakeLower(), "");
                if(developer) Console.Printf("\c[RED]Reset progress for %s", cls.getClassName());
            }
        }

        Globals.Save();
    }


    override void PreSave(int saveType) {

    }

    override void PostSave(int saveType) {
        // We dont use this for anything else but autosaves for now
        if (saveType != SAVE_AUTO) {
            return;
        }

        // Get the player
        let d = Dawn(players[consoleplayer].mo);
        if(!d) {
            return;
        }

        // Apply Save Protection
        d.prepareSaveProtection();
    }

    override bool HandleError(int err, string msg) {
        // Show fatal error menu
        let mnu = new("ErrorMenu").init(Menu.GetCurrentMenu(), err, msg);
        mnu.ActivateMenu();
        return true;
    }
}


class LevelUtil play {
    // Wakes actors in sector, optionally with TID
    static int WakeSector(int sectorTag, int actorTag = 0) {
        Array<int> sectors;
        int theEnwokening = 0;

        SectorTagIterator st = Level.CreateSectorTagIterator(sectorTag);
        int secID = st.Next();
        while(secID > 0) {
            Sector s = level.sectors[secID];
            Actor act;
            for (act = s.thinglist; act != NULL; act = act.snext) {
                if(actorTag == 0 || act.tid == actorTag) {
                    act.wake();
                    theEnwokening++;
                }
            }

            secID = st.Next();
        }

        return theEnwokening;
    }
}


// Event handler that is non-static for handling per-level stuff
class LocalLevelHandler : EventHandler {
    mixin CVARBuddy;

    Array< class<MasterMarker> > mapMarkerClasses;
    Array<MasterMarker> mapMarkers;
    bool hasAutosavedIn01B;
    static clearscope LocalLevelHandler Instance() {
        return LocalLevelHandler(EventHandler.Find("LocalLevelHandler"));
    }

    override void worldTick() {
        if((level.mapTime + 5) % 14 == 0) {
            checkMapMarkers();
        }
    }

    // Ignores UTF. FU UTF
    private bool compareStrings(string a, string b) {
        if(!a && b) return false;
        else if(!b && a) return true;
        else if(!b && !a) return false;

        int len = min(a.length(), b.length());
        for(int x = 0; x < 24 && x < len; x++) {
            int ac = a.ByteAt(x);
            int bc = b.ByteAt(x);
            if(ac > 90) ac -= 32;
            if(bc > 90) bc -= 32;
            if(ac != bc) return ac > bc;
        }
        return false;
    }

    void newMapMarkerAdded(MasterMarker marker) {
        class<MasterMarker> cls = marker.getClass();
        readonly< MasterMarker > def = GetDefaultByType(cls);
        string label = StringTable.Localize(def.mapLabel);

        mapMarkers.push(marker);

        for(int x = 0; x < mapMarkerClasses.size(); x++) {
            if(cls == mapMarkerClasses[x]) return;
        }
        
        if(mapMarkerClasses.size() == 0) {
            mapMarkerClasses.push(cls);
            return;
        }

        // Insert marker in roughly alphabetical order
        for(int x = 0; x < mapMarkerClasses.size(); x++) {
            if(!compareStrings(label, StringTable.Localize(GetDefaultByType(mapMarkerClasses[x]).mapLabel))) {
                mapMarkerClasses.insert(x, cls);
                return;
            }
        }

        mapMarkerClasses.push(cls);
    }

    void mapMarkerDeleted(MasterMarker marker) {
        bool lastOne = true;
        class<MasterMarker> cls = marker.getClass();
        
        for(int x = mapMarkers.size() - 1; x >= 0; x--) {
            // Remove dead references
            if(!mapMarkers[x]) {
                mapMarkers.delete(x);
                continue;
            }

            // Check if this is the only marker of this type
            // And remove
            if(mapMarkers[x] is cls) {
                if(mapMarkers[x] != marker) {
                    lastOne = false;
                } else {
                    mapMarkers.delete(x);
                    continue;
                }
            }
        }

        if(lastOne) {
            for(int x = 0; x < mapMarkerClasses.size(); x++) {
                if(mapMarkerClasses[x] == cls) {
                    mapMarkerClasses.delete(x);
                    return;
                }
            }
        }
    }

    void checkMapMarkers() {
        int iconSize = iGetCVAR("g_iconSize", 1);
        bool enable = iGetCVAR("g_enablemapicons");
        bool showCompleted = iGetCVAR("g_showcompletedicons");

        // Update map markers
        // Also remove dead references while we are in there
        for(int x = mapMarkers.size() - 1; x >= 0; x--) {
            if(!mapMarkers[x]) {
                mapMarkers.delete(x);
                continue;
            }
            
            mapMarkers[x].updateMapIcons(iconSize, enable, showCompleted);
        }
    }
}


class Demo : PickupableDecoration {
	default {
		tag "Demo Object";
		+SHOOTABLE
		-SOLID
		+CANNOTPUSH
		+BloodSplatter
		+NOBLOODDECALS
		+USESPECIAL
        -FLATSPRITE
        -WALLSPRITE
		PickupableDecoration.grabSound "pickup/dishwasher";
		PickupableDecoration.landingSound "land/dishwasher";
		Activation THINGSPEC_Switch;
		Health 10;
		mass 300;
		BloodType "WaterSplashBaseSmallShort", "WaterSplashBaseSmallShort", "WaterSplashBaseSmallShort";
		Radius 5;
		Height 10;
	}
	states {
		Idle:
		Spawn:
			JLLL A -1;
			stop;
		Death:
			TNT1 A 0 {
				A_playSound("script/GWYNBRK");
				A_SpawnItemEx("WaterSplashBaseSmall", 0, 0, 4, frandom(0.2,0.3), frandom(0.2,0.3), 2); 
			}
			stop;
	}
}
