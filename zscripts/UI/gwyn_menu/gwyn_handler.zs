enum GwynShopItems {
    GWYN_SHOP_MEDKIT         = 0,
    GWYN_SHOP_CONFIDENCE     = 1,
    GWYN_SHOP_SAVEGAME       = 2,
    GWYN_SHOP_QUICKFIX       = 3
}

class ConfidenceBooster : Inventory {
    // Temporary class until this is implemented. At least we know if it's purchased or not
    default { Inventory.MaxAmount 1; }
}

class GWYNHandler : StaticEventHandler {
    int slotItems[4];
    int shopID;
    bool boughtSomething, boughtSave;
    int amountSpent;
    string successScript;

    Array<int> itemsBought;

    GwynMachine currentMachine;

    const MAX_BONUS_HEALTH = 100;

    static const int itemCosts[] = {
        200,    // Medkit
        4000,   // Confidence booster
        300,    // Savegame
        75      // Quickfix
    };

    static const string itemNames[] = {
        "MedkitCount",
        "ConfidenceBooster",
        "GwynQuicksave",    // Not actually an item, won't be used
        "HealyMcHealerson"  // Not actually an item, won't be used
    };

    static const string itemDescriptions[] = {
        "$GWYN_MENU_NAME_MEDKIT",
        "$GWYN_MENU_NAME_BOOSTER",
        "$GWYN_MENU_NAME_SAVE",
        "$GWYN_MENU_NAME_HEAL"
    };

    static const string itemFullDescriptions[] = {
        "$GWYN_MENU_DESCRIPTION_MEDKIT",
        "$GWYN_MENU_DESCRIPTION_BOOSTER",
        "$GWYN_MENU_DESCRIPTION_SAVE",
        "$GWYN_MENU_DESCRIPTION_HEAL"
    };

    static GWYNHandler Instance() {
        return GWYNHandler(StaticEventHandler.Find("GWYNHandler"));
    }

    static void ShowMenu(string successScript, int shopID, int item1 = GWYN_SHOP_MEDKIT, int item2 = GWYN_SHOP_QUICKFIX, int item3 = GWYN_SHOP_CONFIDENCE, int item4 = GWYN_SHOP_SAVEGAME) {
        if(menuActive) {
            return;
        }

        let evt = GWYNHandler(StaticEventHandler.Find("GWYNHandler"));
        if (evt) {
            evt.slotItems[0] = item1;
            evt.slotItems[1] = item2;
            evt.slotItems[2] = item3;
            evt.slotItems[3] = item4;
            evt.successScript = successScript;
            evt.boughtSomething = false;
            evt.itemsBought.clear();
            evt.shopID = shopID;
            evt.findGwynMachine(players[consolePlayer].mo);

            S_StartSound ("ui/gwyn/use", CHAN_VOICE, CHANF_UI, snd_menuvolume);
            Menu.SetMenu("GwynMenu");
        }
    }

    static clearscope bool, Inventory HasEnoughMoney(int itemID, int player = -999, int multiplier = 1) {
        int cost = GWYNHandler.itemCosts[itemID] * multiplier;
        let p = players[player != -999 ? player : consolePlayer].mo;
        let i = p.FindInventory("CreditsCount");

        if(!i) { return false, null; }

        return i.amount >= cost, i;
    }

    static clearscope bool CanBuyMore(int itemID, int player = -999, int multiplier = 1) {
        let p = players[player != -999 ? player : consolePlayer].mo;
        string itemName = GWYNHandler.itemNames[itemID];

        switch(itemID) {
            case GWYN_SHOP_QUICKFIX:
                return multiplier < 2 && (p.health < (p.GetMaxHealth(true) + MAX_BONUS_HEALTH));
            case GWYN_SHOP_SAVEGAME:
                return true;    // You can always save, although the interface will only save once while it's open
            default:            // Assume inventory based item
                let i = p.FindInventory(itemName);
                return !i || i.amount + multiplier <= i.MaxAmount;        
        }
    }

    void findGwynMachine(Actor src) {
        ThinkerIterator it = ThinkerIterator.Create("GwynMachine");
		GwynMachine machine = GwynMachine(it.Next());
		for (; machine; machine = GwynMachine(it.Next())) {
			if(src.Distance2DSquared(machine) <= (512*512) || (shopID != 0 && machine.tid == shopID)) {
				currentMachine = machine;
                return;
			}
		}
    }

    void reset() {
        successScript = "";
        boughtSomething = false;
        boughtSave = false;
        shopID = -1;
        currentMachine = null;
        itemsBought.clear();
        amountSpent = 0;
    }

    override void NewGame() {
        reset();
    }

    override void WorldLoaded(WorldEvent e) {
        reset();
    }

    override void NetworkProcess(ConsoleEvent e) {
        if(e.name == "gwynBuy") {
            int item = slotItems[CLAMP(e.args[0], 0, 3)];

            if(successScript != "" || shopID != 0) {
                // Verify purchase
                bool hasMunny;
                Inventory mi;
                int cost = itemCosts[item];
                string itemName = itemNames[item];


                [hasMunny, mi] = GWYNHandler.HasEnoughMoney(item, e.player);

                if(hasMunny) {
                    let p = players[e.player].mo;

                    // Perform specific operations
                    switch(item) {
                        case GWYN_SHOP_QUICKFIX:
                            // Return player to full health
                            // Checking this here just in case the player is over-health
                            // Commenting this out, now we just give 25hp
                            /*if(p.Health < p.GetMaxHealth(true)) {
                                let amountHealed = p.GetMaxHealth(true) - p.Health;

                                players[e.player].Health = p.GetMaxHealth(true);
                                p.Health = players[e.player].Health;
                                mi.amount -= cost;
                                boughtSomething = true;
                                itemsBought.push(item);

                                checkForSimp();

                                // Potential healing from quick-fix is always the same as amount healed
                                // it would be unfair to punish this stat % for not healing from zero!
                                Stats.AddStat(STAT_HEALED, amountHealed, amountHealed);
                            }*/
                            int maxHP = p.GetMaxHealth(true) + MAX_BONUS_HEALTH;
                            if(p.Health < maxHP) {
                                int healHealth = min(maxHP, p.Health + 25);
                                let amountHealed = healHealth - p.health;

                                players[e.player].Health = healHealth;
                                p.Health = players[e.player].Health;
                                mi.amount -= cost;
                                boughtSomething = true;
                                itemsBought.push(item);
                                amountSpent += cost;
                                
                                checkForSimp();

                                // Potential healing from quick-fix is always the same as amount healed
                                // it would be unfair to punish this stat % for not healing from zero!
                                Stats.AddStat(STAT_HEALED, amountHealed, 0);
                            }
                            break;
                        case GWYN_SHOP_SAVEGAME:
                            // Save the game. ACS Is currently handling this
                            // Not anymore noob
                            mi.amount -= cost;
                            boughtSomething = true;
                            boughtSave = true;  // Allows the event handler to detect a valid save and allow it
                            amountSpent += cost;

                            checkForSimp();

                            // The actual UI is going to handle this now
                            break;
                        default:
                            // Assume this is an item, and give it to the user if there is room
                            let i = p.FindInventory(itemName);
                            if(!i || i.amount < i.MaxAmount) {
                                p.GiveInventory(itemName, 1);
                                mi.amount -= cost;
                                boughtSomething = true;
                                itemsBought.push(item);
                                amountSpent += cost;
                                checkForSimp();
                            } else {
                                Console.Printf("\c[GOLD]Player %d cannot be given more %s. Max: %d", e.player, itemName, i ? i.MaxAmount :  -999);
                            }
                            break;
                    }

                    // callback to script
                    players[e.player].mo.ACS_NamedExecute(successScript, 0, item, 0);
                } else {
                    Console.Printf("\c[RED]Player %d tried to buy item %d with no money! What a cheapskate!", e.player, item);
                }
            } else {
                Console.Printf("\c[RED]Received a GWYNBUY command with no success script set! \nIgnoring.");
            }
        }

        if(e.name == "gwynReset") {
            leaveShop(e.player);
        }
    }


    void leaveShop(int player = -1) {
        if(player == -1) player = consolePlayer;

        // Let ACS know that we finished shopping
        if(successScript != "") players[player].mo.ACS_NamedExecute(successScript, 0, -1, 1);

        // Tell GWYN to talk about this
        if(boughtSomething && currentMachine) {
            // Call from the thing ID
            currentMachine.buySuccess();
        } else if(currentMachine) {
            currentMachine.buyFail();
        }

        reset();
    }

    void checkForSimp() {
        int medkits = 0;
        bool hasRestore = false;
        bool hasConfidence = false;

        /*if(1){//itemsBought.size() >= 6) {
            for(int x = 0; x < itemsBought.size(); x++) {
                switch(itemsBought[x]) {
                    case GWYN_SHOP_QUICKFIX:
                        hasRestore = true;
                        break;
                    case GWYN_SHOP_MEDKIT:
                        medkits++;
                        break;
                    case GWYN_SHOP_CONFIDENCE:
                        hasConfidence = true;
                        break;
                    default:
                        break;
                }
            }
        }
        

        if(medkits >= 5 && hasRestore && hasConfidence) {
            StatDatabase.SetAchievement("GAME_SIMP", 1);
        }*/

        if(amountSpent >= 5000) {
            StatDatabase.SetAchievement("GAME_SIMP", 1);
        }
    }
}