struct PDAEntryInfo {
    int status;
    //int group;
}

class PDAAppSettings {
    Vector2 pos, size;      // Normalized coords, not absolute
    int order;              // 0 = Closed
}

class PDAEntry : Inventory {
    const STATUS_NOTFOUND   = 0;
    const STATUS_NEW        = 1;
    const STATUS_READ       = 2;
    const STATUS_LAST_OPEN  = 3;    // Implies it is found and it has been read

    const NUM_AREA = 32;
    const NUM_ENTRY = 64;
    const INVALID = 999999;

    int lastOpenArea;
    int lastOpenEntry;
    int hasUnreadMail;                          // Must be cleared manually
    int unreadArea, unreadItem, unreadCounter;  // Added later, could have replaced hasUnreadMail
    int lastSelectedInvasionTier;


    PDAEntryInfo entries[NUM_AREA][NUM_ENTRY];  // Why does this need to be backwards?
    PDAAppSettings appSettings[50];

    // Run only when inventory item is first created
    override void BeginPlay() {
		Super.BeginPlay ();
        lastOpenArea = -1;
        lastOpenEntry = -1;
        lastSelectedInvasionTier = -1;

        // This probably doesn't need to be done, But I had problems once when it wasn't. - Cock
        for(int x = 0; x < NUM_AREA; x++) {
            for(int y = 0; y < NUM_ENTRY; y++) {
                entries[x][y].status = 0;
            }
        }
	}

    void SetLastOpen(int area, int entryNum) {
        lastOpenArea = area;
        lastOpenEntry = entryNum;
    }

    override void Tick() {
        Super.Tick();
        
        // PDA Uses this to determine if we opened recently after a new Datapad was found
        if(unreadCounter < INVALID) unreadCounter++;
    }
}


class PDAManager : StaticEventHandler {
    const INVALID = 999999;

    static private PDAEntry GetEntry(Actor activator) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);

        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        if (evt) {
            let item = PDAEntry(activator.FindInventory("PDAEntry", true));

            // Create the PDA Item in player inventory if it does not yet exist
            if(!item && activator) {
                // Add the item to the player's inventory
                item = PDAEntry(Actor.Spawn("PDAEntry"));
                item.BecomeItem();
                activator.AddInventory(item);
            }

            return item;
        }
        
        return null;
    }

    // Set absolute value for specified entry
    // Returns TRUE if the entry value is successfully set
    static bool SetEntry(Actor activator, int area, int entryNum, int value) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);
        
        PDAEntry item = GetEntry(activator);
        if(item) {
            if(item.entries[area][entryNum].status == PDAEntry.STATUS_NEW && value >= PDAEntry.STATUS_READ) {
                // Decrease count of unread if we are changing status
                item.hasUnreadMail = MAX(item.hasUnreadMail - 1, 0);
            }

            if(value == PDAEntry.STATUS_LAST_OPEN) {
                item.entries[area][entryNum].status = PDAEntry.STATUS_READ;
                item.SetLastOpen(area, entryNum);   // Special case, may also alter other records
            } else {
                item.entries[area][entryNum].status = value;
                item.entries[area][0].status = 1;

                if(value == PDAEntry.STATUS_NEW) {
                    if(item.unreadCounter > 1 || area != item.unreadArea || entryNum < item.unreadItem) {
                        item.unreadArea = area;
                        item.unreadItem = entryNum;
                        item.unreadCounter = 0;
                    }
                }
            }
            return true;
        } else if(!activator) {
            Console.Printf("\c[YELLOW]PDA Manager: Tried to add entry from a non-player actor!");
        }
        return false;
    }

    // Set absolute value for all entries in the specified area and group ID
    // This might be a little slow unfortunately because it has to do a bit of Stringtable stuff
    // Maybe eventually we can move this to JSON or something
    static int, int AddEntriesFromGroup(Actor activator, int area, int group, bool notify = false) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);
        
        PDAEntry item = GetEntry(activator);
        if(item) {
            int firstID = -1;
            int numAdded = 0;

            // Do this for all entries that share the group ID
            for(int x = 1; x < PDAEntry.NUM_ENTRY; x++) {
                string tag = String.Format("PDA_G_%d_%d", area, x);
                string groupSID = StringTable.Localize("$" .. tag);
                int groupID = groupSID != tag ? groupSID.toInt(10) : -1;

                if(groupID == group) {
                    if(item.entries[area][x].status == PDAEntry.STATUS_NOTFOUND) {
                        item.entries[area][x].status = PDAEntry.STATUS_NEW;

                        // For now adding an entry will also unlock the area for the PDA
                        item.entries[area][0].status = 1;
                        item.hasUnreadMail++;
                    }

                    if(firstID == -1 || item.unreadItem > x) {
                        item.unreadArea = area;
                        item.unreadItem = x;
                        item.unreadCounter = 0;
                        firstID = x;
                    }

                    numAdded++;
                }
            }

            if(notify && firstID > 0) {
                ShowNotification(area, firstID, numAdded);
            }

            return numAdded, firstID;
        } else if(!activator) {
            Console.Printf("\c[YELLOW]PDA Manager: Tried to add entry from a non-player actor!");
        }

        return 0, -1;
    }

    static void SetAppPos(int playerID, int appID, Vector2 pos, Vector2 size, int order = -1) {
        PDAEntry item = GetEntry(players[playerID].mo);
        if(item) {
            let settings = item.appSettings[appID];

            if(!settings) {
                settings = PDAAppSettings(new('PDAAppSettings'));
                item.appSettings[appID] = settings;
            }

            if(!(pos ~== (0,0) && size ~== (0,0))) {
                settings.pos = pos;
                settings.size = size;
            }
            
            settings.order = order;
        }
    }

    static bool ClearUnread(Actor activator, int area = -1, int entryNum = -1) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);
        
        PDAEntry item = GetEntry(activator);
        if(item) {
            item.hasUnreadMail = 0;

            if(area == -1) {
                // Nothing more to do here
                return true;
            }

            if(entryNum == -1) {
                // Clear all entries in the area
                for(int x = 0; x < PDAEntry.NUM_ENTRY; x++) {
                    if(item.entries[area][x].status == PDAEntry.STATUS_NEW) {
                        item.entries[area][x].status = PDAEntry.STATUS_READ;
                    }
                }
            } else {
                // Clear the specific entry
                if(item.entries[area][entryNum].status == PDAEntry.STATUS_NEW) {
                    item.entries[area][entryNum].status = PDAEntry.STATUS_READ;
                }
            }
            
            return true;
        } else if(!activator) {
            Console.Printf("\c[YELLOW]PDA Manager: Tried to clear unread entry flag from a non-player actor!");
        }

        return false;
    }

    static bool ClearTimeout(Actor activator) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);
        
        PDAEntry item = GetEntry(activator);
        if(item) {
            item.unreadCounter = INVALID;
            return true;
        } else if(!activator) {
            Console.Printf("\c[YELLOW]PDA Manager: Tried to clear timeout from non-player actor!");
        }

        return false;
    }


    static void ShowNotification(int area, int entrynum, int numEntries = 1, string username = "", string portrait = "", string pickupMessage = "") {
        string usr = username ? username : StringTable.Localize(String.Format("$PDA_N_%d_%d", area, entrynum));
        let notifImage = portrait ? portrait : StringTable.Localize(String.Format("$PDA_PI_%d_%d", area, entrynum));
        let notifText = String.Format(StringTable.Localize("$NOTIFICATION_DATAPAD_MESSAGE"), usr, numEntries);

        // Create a notification about this new PDA entry
        let n = new("EmailNotification");
        n.init(String.Format("\c[HI]%s", StringTable.Localize("$NOTIFICATION_DATAPAD_DOWNLOAD")), pickupMessage ? pickupMessage : notifText, notifImage);
        Notification.Queue(n, NotificationItem.SLOT_BOT_LEFT);
    }


    // Add the entry and sets to NEW if entry is not yet present. 
    // Returns TRUE if the entry is successfully set, or if it already existed
    static bool AddEntry(Actor activator, int area, int entryNum, bool notify = false, int numEntries = 1) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);

        PDAEntry item = GetEntry(activator);
        if(item) {
            if(item.entries[area][entryNum].status == PDAEntry.STATUS_NOTFOUND) {
                item.entries[area][entryNum].status = PDAEntry.STATUS_NEW;
                
                // For now adding an entry will also unlock the area for the PDA
                item.entries[area][0].status = 1;
                item.hasUnreadMail++;

                // Set unread item, used by PDA when opening
                if(item.unreadCounter > 1 || area != item.unreadArea || entryNum < item.unreadItem) {
                    item.unreadArea = area;
                    item.unreadItem = entryNum;
                    item.unreadCounter = 0;
                }

                if(notify) {
                    ShowNotification(area, entryNum, numEntries);
                }
            }

            return true;
        } else if(!activator) {
            Console.Printf("PDA Manager: Tried to add entry from a non-player actor!");
        }
        return false;
    }

    static bool RemoveEntry(Actor activator, int area, int entryNum) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);
        
        PDAEntry item = GetEntry(activator);
        if(item) {
            if(item.entries[area][entryNum].status > PDAEntry.STATUS_NOTFOUND) {
                if(item.entries[area][entryNum].status == PDAEntry.STATUS_NEW) {
                    item.hasUnreadMail = MAX(item.hasUnreadMail - 1, 0);
                }
                
                item.entries[area][entryNum].status = PDAEntry.STATUS_NOTFOUND;
                return true;
            }
        } else if(!activator) {
            Console.Printf("PDA Manager: Tried to remove entry from a non-player actor!");
        }

        return false;
    }

    static int EntryStatus(Actor activator, int area, int entryNum) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);
        
        PDAEntry item = GetEntry(activator);
        if(item) {
            return item.entries[area][entryNum].status;
        }

        return PDAEntry.STATUS_NOTFOUND;
    }

    static void Spew(Actor activator) {
        // Just ignore the activator from now on, there is only one DAWN
        activator = Actor(players[consoleplayer].mo);
        
        PDAEntry item = GetEntry(activator);
        if(!item) {
            Console.Printf("No PDA Item in Inventory");
        } else {
            
            for(int x = 0 ; x < PDAEntry.NUM_AREA; x++) {
                string line = "";
                for(int y = 0; y < PDAEntry.NUM_ENTRY; y++) {
                    line = line .. item.entries[x][y].status;
                }
                Console.Printf("[%d]: %s", x, line);
            }
        }
    }

    // Cheat
    static void GiveAll(int playerNumber) {
        // Give all entries that have definitions in LANGUAGE
        for(int x = 0; x < PDAEntry.NUM_AREA; x++) {
            for(int y = 0; y < PDAEntry.NUM_ENTRY; y++) {
                string index = String.Format("PDA_N_%d_%d", x, y);
                string str = StringTable.Localize("$" .. index);
                if(!(str ~== index)) {
                    // This entry exists, give it to the player
                    AddEntry(players[playerNumber].mo, x, y);
                }
            }
        }
    }

    static void OpenCodex() {
        if(players[consolePlayer].mo && players[consolePlayer].mo.health > 0) Menu.SetMenu("PDAMenu3");
    }

    static void SetLastInvasionTier(int player, int val) {
        let a = Actor(players[player].mo);
        
        PDAEntry item = GetEntry(a);
        if(item) {
            item.lastSelectedInvasionTier = val;
        }
    }

    static clearscope int GetLastSelectedInvasionTier(int player) {
        let a = Actor(players[player].mo);
        
        PDAEntry item = PDAEntry(a.FindInventory("PDAEntry", true));
        if(item) {
            return item.lastSelectedInvasionTier;
        }

        return -1;
    }

    override void NetworkProcess(ConsoleEvent e) {
        Array<String> cmds;
        e.Name.Split(cmds, ":");

        // Args version. This was dumb to use parsing
        if(e.name == "pdaEntrySet") {
            SetEntry(players[e.player].mo, e.args[0], e.args[1], e.args[2]);
            return;
        }

        if(cmds.Size() > 1) {
            if(cmds.Size() > 3 && cmds[0] == "pdaEntrySet") {
                int a = cmds[1].ToInt(10);
                int b = cmds[2].ToInt(10);
                int val = cmds[3].ToInt(10);    // Why didn't I use args here?
                
                SetEntry(players[e.player].mo, a, b, val);
            } else if(cmds[0] == "pdaAppPos" && cmds.Size() == 5) {
                double x = cmds[1].ToDouble();
                double y = cmds[2].ToDouble();
                double w = cmds[3].ToDouble();
                double h = cmds[4].ToDouble();

                int appID = e.args[0];
                int order = e.args[1];

                // Save
                SetAppPos(e.player, appID, (x, y), (w, h), order);
            }
        } else if(e.Name ~== "pdaUnreadClear") {
            ClearUnread(players[e.player].mo, e.args[0], e.args[1]);
        } else if(e.Name ~== "pdaTimeoutClear") {
            ClearTimeout(players[e.player].mo);
        } else if(e.name ~== "givePDA") {
            if(sv_cheats > 0) {
                GiveAll(e.player);
            }
        } else if(e.name ~== "lInvTier") {
            SetLastInvasionTier(e.player, e.args[0]);
        } else if(e.name ~== "spewPDA") {
            if(sv_cheats > 0) {
                Spew(players[e.player].mo);
            }
        }
    }
}