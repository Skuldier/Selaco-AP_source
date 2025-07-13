class StatsHandler : EventHandler {
    mixin CVARBuddy;

    int foundSecrets, totalSecrets;
    int ticsLoaded, ticsUnloaded;

    static clearscope StatsHandler Instance() {
        let evt = StatsHandler(EventHandler.Find("StatsHandler"));
        return evt;
    }

    override void WorldUnloaded(WorldEvent e) {
        // Increase timer for this particular level and total value
        clockLevelTime();
    }

    void clockLevelTime() {
        double timePassed = level.totalTime - ticsLoaded;
        ticsLoaded = level.totalTime;

        Stats.AddStat(STAT_TIMER, timePassed, 0);
    }

    override void NetworkProcess(ConsoleEvent e) {
        if(e.name ~== "show_objectives") {
            Objectives.ShowObjectives();
        }

        if(e.name ~== "cheat_ach" && sv_cheats > 0) {
            // Give internal achievements
            for(int x = 0; x < IACH_COUNT; x++) {
                Stats.SetInternalAchievement(x);
            }
        }
    }

	override void ConsoleProcess(ConsoleEvent e) {
        if(e.name ~== "stats") {
            Console.Printf("\c[BRICK]Current Level: %d  Info Level Num: %d", Level.levelnum, Level.info.levelnum);
            Stats.Print();
        }
        
        if(e.name ~== "show_objectives") {
            EventHandler.SendNetworkEvent("show_objectives");
        }

        if(e.name ~== "print_objectives" && sv_cheats > 0) {
            let os = Objectives.FindObjectives();
            if(os) {
                for(int x = 0; x < os.objs.size(); x++) {
                    let o = os.objs[x];
                    string title = o.title;
                    string mapName = "Unknown";

                    let info = LevelInfo.FindLevelByNum(o.mapNum);
                    if(info) mapName = StringTable.Localize(info.LevelName);
                    if(o.status == Objective.STATUS_COMPLETE) title = String.Format("%s [%s]", title, "Complete");
                    Console.Printf("%s [%d - %s  Tag: %d]", title, o.mapNum, mapName, o.tag);

                    for(int y = 0; y < o.children.size(); y++) {
                        let o2 = o.children[y];
                        string title = o2.title;
                        string mapName = "Unknown";

                        let info = LevelInfo.FindLevelByNum(o2.mapNum);
                        if(info) mapName = StringTable.Localize(info.LevelName);
                        if(o.status == Objective.STATUS_COMPLETE) title = String.Format("%s [%s]", title, "Complete");
                        Console.Printf("\t%s [%d - %s  Tag: %d]", title, o.mapNum, mapName, o2.tag);
                    }
                }
                
                if(os.history.size()) {
                    Console.Printf("Historical Objectives ========");
                }

                for(int x = 0; x < os.history.size(); x++) {
                    let o = os.history[x];
                    string title = o.title;
                    string mapName = "Unknown";

                    let info = LevelInfo.FindLevelByNum(o.mapNum);
                    if(info) mapName = StringTable.Localize(info.LevelName);
                    if(o.status == Objective.STATUS_COMPLETE) title = String.Format("%s [%s]", title, "Complete");
                    Console.Printf("%s [%d - %s]", title, o.mapNum, mapName);

                    for(int y = 0; y < o.children.size(); y++) {
                        let o2 = o.children[y];
                        string title = o2.title;
                        string mapName = "Unknown";

                        let info = LevelInfo.FindLevelByNum(o2.mapNum);
                        if(info) mapName = StringTable.Localize(info.LevelName);
                        if(o.status == Objective.STATUS_COMPLETE) title = String.Format("%s [%s]", title, "Complete");
                        Console.Printf("\t%s [%d - %s]", title, o.mapNum, mapName);
                    }
                }
            }
        }

        if(e.name ~== "maps") {
            int num = LevelInfo.GetLevelInfoCount();
            Console.Printf("\c[GOLD]%d Levels", num);

            for(int x =0; x < num; x++) {
                let i = LevelInfo.GetLevelInfo(x);
                Console.Printf("\c[GOLD]Map %d: %s", i.levelNum, i.MapName);
            }
        }
	}

    override void WorldLoaded (WorldEvent e) {
        ticsUnloaded = 0;
        ticsLoaded = level.totalTime;

        if(!e.IsReopen) {
            updateSecretCount();
        }

        // Dirty. Dirty..
        if(sv_cheats > 0) {
            Stats.AddStat(STAT_YOUCHEATED, 1, 0);
        }
    }

    override void WorldTick() {
        if(level.mapTime == 5 || foundSecrets < Level.found_secrets && !g_halflikemode) {
            updateSecretCount();
        }
    }

    void updateSecretCount() {
        let secretTracker = Stats.GetTracker(STAT_SECRETS_FOUND);
        if(secretTracker && level.levelNum < StatTracker.MAX_LEVEL_NUM && level.levelNum >= 0) {
            foundSecrets = max(Level.found_secrets, int(secretTracker.levelValues[level.levelnum]));
            totalSecrets = max(Level.total_secrets, int(secretTracker.levelPossibleValues[level.levelnum]));

            Stats.AddStat(STAT_SECRETS_FOUND, foundSecrets - int(secretTracker.levelValues[level.levelnum]), Level.total_secrets - int(secretTracker.levelPossibleValues[level.levelnum]));
        } else {
            totalSecrets = Level.total_secrets;
            foundSecrets = Level.found_secrets;
        }

         if(level.mapName != "TITLEMAP") {
            let secretTracker = Stats.GetTracker(STAT_SECRETS_FOUND);
        }
    }
}


class LevelTimer : Inventory {

}