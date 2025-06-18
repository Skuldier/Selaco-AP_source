enum BBAchType {
    BB_ACH_BUILD = 0,
    BB_ACH_CLICK,
    BB_ACH_COOKIE,
    BB_ACH_STEPS,
    BB_ACH_UPGRADE,
    BB_ACH_BURGERS,
    BB_ACH_BPS,
    BB_ACH_PRESTIGE,
    BB_ACH_CUSTOM
}


class BBAchievement {
    int type, subject, amount;
    int value;
}


extend class BBItem {
    Map<string, BBAchievement> achievements;


    void loadAchievements() {
        Array<String> gKeys;
        Globals.GetKeys(gKeys);

        achievements.clear();

        for(int x = 0; x < gKeys.size(); x++) {
            if(gKeys[x].indexOf("BB_ACH_") == 0) {
                int value = Globals.GetInt(gKeys[x]);
                if(value > 0) {
                    string achievString = gKeys[x].mid(7);
                    BBAchievement a = new("BBAchievement");
                    bool success = DecodeAchievement(gKeys[x].mid(7), a);
                    a.value = value;
                    
                    if(success) achievements.insert(achievString, a);
                }
            }
        }
    }


    void saveAchievements() {
        foreach(key, a : achievements) {
            Globals.SetInt(String.Format("BB_ACH_%s", key), a.value);
        }
    }

    static void WipeAchievements() {
        Array<String> gKeys;
        Globals.GetKeys(gKeys);

        for(int x = 0; x < gKeys.size(); x++) {
            if(gKeys[x].indexOf("BB_ACH_") == 0) {
                Globals.Set(gKeys[x], "");
            }
        }
    }

    // Decode achievement string in format (type)_(subject)_(amount)
    // Returns: BBAchievement, success
    clearscope static bool DecodeAchievement(string txt, out BBAchievement ach) {
        if(txt.length() < 9) {
            if(developer) ThrowAbortException("Invalid achievement string: %s", txt);
            else return false;
        }

        let t = txt.mid(0, 3).ToInt();
        let s = txt.mid(4, 3).ToInt();
        let a = txt.mid(8).ToInt();

        //if(developer) Console.Printf("Decoded achievement (%s): (%s) %d, (%s) %d, (%s) %d", txt, txt.mid(0, 3), t, txt.mid(4, 3), s, txt.mid(8, 3), a);

        ach.type = t;
        ach.subject = s;
        ach.amount = a;

        return true;
    }


    clearscope static string EncodeAchievement(BBAchievement ach) {
        return String.Format("%03d_%03d_%d", ach.type, ach.subject, ach.amount);
    }

    clearscope static string EncodeAchievementParts(int type, int subject, int amount) {
        return String.Format("%03d_%03d_%d", type, subject, amount);
    }

    const ACH_BUILDING_AND_UPGRADES = 5;
    static const int ACH_CLICK_ACHIEVEMENTS[] = { 100, 1000, 10000, 100000 };
    static const int ACH_BURGER_ACHIEVEMENTS[] = { 1, 2, 3, 4, 5, 6 };
    static const int ACH_BPS_ACHIEVEMENTS[] = { 1, 2, 3, 4, 5, 6 };
    static const int ACH_STEPS_ACHIEVEMENTS[] = { 1000, 5000, 10000, 100000, 200000 };
    static const int ACH_COOKIE_ACHIEVEMENTS[] = { 10, 50, 100, 200, 500 };


    void detectAchievements(bool notify = false) {
        // TODO: Cache last achievement level and only check after that

        // Check for building achievements
        for(int x = 0; x < buildings.size(); x++) {
            for(int y = 1; y <= ACH_BUILDING_AND_UPGRADES; y++) {
                detectAchievement(BB_ACH_BUILD, x, y, notify);
            }
            for(int y = 1; y <= ACH_BUILDING_AND_UPGRADES; y++) {
                detectAchievement(BB_ACH_UPGRADE, x, y, notify);
            }
        }

        // Check Click achievements
        foreach(a : ACH_CLICK_ACHIEVEMENTS) {
            detectAchievement(BB_ACH_CLICK, 0, a, notify);
        }

        // Check Golden Burger achievements
        foreach(a : ACH_COOKIE_ACHIEVEMENTS) {
            detectAchievement(BB_ACH_COOKIE, 0, a, notify);
        }

        // Check Steps achievements
        foreach(a : ACH_STEPS_ACHIEVEMENTS) {
            detectAchievement(BB_ACH_STEPS, 0, a, notify);
        }

        // Check burger achievements
        foreach(a : ACH_BURGER_ACHIEVEMENTS) {
            detectAchievement(BB_ACH_BURGERS, 0, a, notify);
        }

        // Check BPS achievements
        foreach(a : ACH_BPS_ACHIEVEMENTS) {
            detectAchievement(BB_ACH_BPS, 0, a, notify);
        }

        // Prestige achievements
        for(int x = 1; x < 100; x++) {
            detectAchievement(BB_ACH_PRESTIGE, 0, x, notify);
        }
    }


    clearscope int findAchievementLevel(int type, int subject) {
        if(type == BB_ACH_BUILD || type == BB_ACH_UPGRADE) {
            // Decode each achievement and find the largers number that matches array values
            int gv = -1; // Largest value found

            for(int x = 0; x < ACH_BUILDING_AND_UPGRADES; x++) {
                string code = EncodeAchievementParts(type, subject, type == BB_ACH_UPGRADE ? upgradeFormula(subject, x) : buildingFormula(subject, x));
                BBAchievement ach;
                bool exists = false;
                [ach, exists] = achievements.checkValue(code);
                if(exists && ach && ach.value > 0) gv = max(gv, x);
            }

            return gv;
        } else {
            int gv = -1; // Largest value found

            // TODO: Remove duplication here, I cannot pass the const arrays to a function so bleh
            switch(type) {
                case BB_ACH_CLICK:
                    for(int x = 0; x < ACH_CLICK_ACHIEVEMENTS.size(); x++) {
                        string code = EncodeAchievementParts(type, 0, ACH_CLICK_ACHIEVEMENTS[x]);
                        BBAchievement ach;
                        bool exists = false;
                        [ach, exists] = achievements.checkValue(code);
                        if(exists && ach && ach.value > 0) gv = max(gv, x);
                    }
                    break;
                case BB_ACH_COOKIE:
                    for(int x = 0; x < ACH_COOKIE_ACHIEVEMENTS.size(); x++) {
                        string code = EncodeAchievementParts(type, 0, ACH_COOKIE_ACHIEVEMENTS[x]);
                        BBAchievement ach;
                        bool exists = false;
                        [ach, exists] = achievements.checkValue(code);
                        if(exists && ach && ach.value > 0) gv = max(gv, x);
                    }
                    break;
                case BB_ACH_STEPS:
                    for(int x = 0; x < ACH_STEPS_ACHIEVEMENTS.size(); x++) {
                        string code = EncodeAchievementParts(type, 0, ACH_STEPS_ACHIEVEMENTS[x]);
                        BBAchievement ach;
                        bool exists = false;
                        [ach, exists] = achievements.checkValue(code);
                        if(exists && ach && ach.value > 0) gv = max(gv, x);
                    }
                    break;
                case BB_ACH_BURGERS:    
                    for(int x = 0; x < ACH_BURGER_ACHIEVEMENTS.size(); x++) {
                        string code = EncodeAchievementParts(type, 0, ACH_BURGER_ACHIEVEMENTS[x]);
                        BBAchievement ach;
                        bool exists = false;
                        [ach, exists] = achievements.checkValue(code);
                        if(exists && ach && ach.value > 0) gv = max(gv, x);
                    }
                    break;
                case BB_ACH_BPS:
                    for(int x = 0; x < ACH_BPS_ACHIEVEMENTS.size(); x++) {
                        string code = EncodeAchievementParts(type, 0, ACH_BPS_ACHIEVEMENTS[x]);
                        BBAchievement ach;
                        bool exists = false;
                        [ach, exists] = achievements.checkValue(code);
                        if(exists && ach && ach.value > 0) gv = max(gv, x);
                    }
                    break;
                case BB_ACH_PRESTIGE:
                    for(int x = 1; x < 100; x++) {
                        string code = EncodeAchievementParts(type, 0, x);
                        BBAchievement ach;
                        bool exists = false;
                        [ach, exists] = achievements.checkValue(code);
                        if(exists && ach && ach.value > 0) gv = max(gv, x);
                    }
                    break;
                default:
                    if(developer) Console.Printf("Unknown achievement type: %d", type);
                    return -1;
            }

            return gv;
        }

        return -1;
    }


    clearscope int buildingFormula(int subject, int amount) {
        if(subject < BBItem.Build_MirrorUniverse) {
            return amount * 25 + (amount / 2 * 25);
        }

        return max(1, amount * 5 + (amount / 2 * 5));
    }

    clearscope int upgradeFormula(int subject, int amount) {
        if(subject >= BBItem.Build_MirrorUniverse) {
            return max(1, amount * 2);
        }

        return max(1, amount * 5);
    }

    clearscope double burgerFormula(int amount) {
        return 10.0 ** double(amount + 1);
    }


    bool detectAchievement(int type, int subject, int amount, bool notify = false) {
        if(type == BB_ACH_BUILD) {
            amount = buildingFormula(subject, amount);
            if(buildings[subject].count < amount) return false;
        } else if(type == BB_ACH_CLICK) {
            if(clickCounter < amount) return false;
        } else if(type == BB_ACH_UPGRADE) {
            amount = upgradeFormula(subject, amount);
            if(buildings[subject].numUpgrades < amount) return false;
        } else if(type == BB_ACH_COOKIE) {
            if(goldBurgerCount < amount) return false;
        } else if(type == BB_ACH_STEPS) {
            if(stepCounter < amount) return false;
        } else if(type == BB_ACH_BURGERS) {
            if(maxBurgers < burgerFormula(amount)) return false;
        } else if(type == BB_ACH_BPS) {
            if(bps < burgerFormula(amount)) return false;
        } else if(type == BB_ACH_PRESTIGE) {
            if(prestige < amount) return false;
        }

        bool isNew;
        string code;
        [code, isNew] = addAchievement(type, subject, amount, 1);
        if(developer && isNew) Console.Printf("Achievement unlocked: %s", code);
        if(notify && isNew) EventHandler.SendInterfaceEvent(owner.PlayerNumber(), "bbach", type, subject, amount);

        return isNew;
    }


    string, bool addAchievement(int type, int subject, int amount, int value) {
        string key = EncodeAchievementParts(type, subject, amount);
        if(achievements.CheckKey(key)) return key, false;

        BBAchievement a = new("BBAchievement");
        a.type = type;
        a.subject = subject;
        a.amount = amount;
        a.value = value;

        achievements.insert(key, a);

        return key, true;
    }
}