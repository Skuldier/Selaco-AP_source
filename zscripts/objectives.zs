enum ObjectiveNotify {
    OBJECTIVE_NOTIFY_NONE = 0,
    OBJECTIVE_NOTIFY_FULL = 1,
    OBJECTIVE_NOTIFY_LIST = 2
}

class Objective {
    mixin CVARBuddy;

    enum ObjectiveStatus {
        STATUS_ACTIVE       = 0,
        STATUS_COMPLETE     = 1,
        STATUS_CANCELLED    = 2
    }

    const TICKS_AFTER_COMPLETION = 35 * 3;

    Objective parent;       // Not sure if this will save properly with the savegames
    Array<Objective> children;  // Ditto

    string title, description, icon;
    int tag;                // Set the tag so you can find the objective again later
    int mapNum;             // 0 if not specific to a map
    int order;              // Used for sorting
    bool hideOutsideMap;    // Hide when player is not on the specified map

    int ticks;              // Tick count total
    int ticsFinish;
    int mapTicsStarted;     // Time in map at start, used to sort in Codex

    ObjectiveStatus status;


    Objective find(int tag) {
        if(self.tag == tag) { return self; }
        for(int x = 0; x < children.size(); x++) {
            if(children[x].tag == tag) { return children[x]; }
        }
        return null;
    }

    play void complete(int notify = OBJECTIVE_NOTIFY_FULL) {
        if(status == STATUS_ACTIVE && iGetCVar("g_showobjectives") > 0) {
            ticsFinish = ticks;    // Finish time is used for animating changes

            if(notify == OBJECTIVE_NOTIFY_FULL) {
                Notification.QueueNew(parent ? 'SubObjectiveCompleteNotification' : 'ObjectiveCompleteNotification', "\c[HI]Objective Completed", title, slot: NotificationItem.SLOT_TOP_MID);
            }
            
            if(notify >= OBJECTIVE_NOTIFY_FULL) {
                if(notify != OBJECTIVE_NOTIFY_FULL) {
                    // Play the appropriate sound
                    S_StartSound(parent ? "ui/completeSubObjective" : "ui/completeObjective", CHAN_VOICE, CHANF_UI, snd_menuvolume);
                }
                Notification.QueueOrUpdate('ObjectivesNotification', slot: NotificationItem.SLOT_MID_RIGHT);
            }
        }
        status = STATUS_COMPLETE;
    }

    play void cancel(int notify = OBJECTIVE_NOTIFY_LIST) {
        status = STATUS_CANCELLED;
        ticsFinish = ticks;

        // TODO: Notify
    }

    play void update(int notify = OBJECTIVE_NOTIFY_FULL) {
        if(iGetCVar("g_showobjectives") > 0) {
            if(notify == OBJECTIVE_NOTIFY_FULL) {
                Notification.QueueNew('ObjectiveNotification', "\c[HI]Objective Updated", title, slot: NotificationItem.SLOT_TOP_MID);
            }

            if(notify >= OBJECTIVE_NOTIFY_FULL) {
                Notification.QueueOrUpdate('ObjectivesNotification', slot: NotificationItem.SLOT_MID_RIGHT);
            }
        }
    }

    play void addChild(Objective o) {
        // Find location to push (Insert Sort)
        if(children.size() > 0) {
            for(int x = 0; x < children.size(); x++) {
                if(children[x].order > o.order) {
                    children.Insert(x, o);
                    break;
                } else if(x + 1 == children.size()) {
                    children.Push(o);
                    break;
                }
            }
        } else {
            children.Push(o);
        }
        
        o.parent = self;
    }

    // Removes child and does not reassign a parent
    play bool removeChild(Objective o) {
        for(int x = 0; x < children.size(); x++) {
            if(children[x] == o) {
                children.delete(x);
                return true;
            }
        }

        return false;
    }

    play void tick() {
        ticks++;
        for(int x = 0; x < children.size(); x++) { children[x].tick(); }
    }
}


class Objectives : Inventory {
    Array<Objective> objs;
    Array<Objective> history;   // Save previous objectives here for CODEX to sort and read

    int autoTagCounter;
    //int ticks;
    
    default {
        Inventory.MaxAmount 1;
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();
        
        autoTagCounter = -1000;
    }

    clearscope Objective find(int tag) {
        Objective ret = null;
        for(int x = 0; x < objs.size(); x++) { if(ret = objs[x].find(tag)) break; }
        return ret;
    }

    // Add a new objective, and optionally notify the player
    // If no tag provided, a default one will be returned
    int add(string icon, string title, string description = "", int tag = -1, int parent = -1, int mapNum = -1, bool onlyInMap = false, int notify = OBJECTIVE_NOTIFY_FULL, int order = 0) {
        if(tag < 0) {
            tag = autoTagCounter--;
        }

        // New objective
        let o = new('Objective');
        o.icon = icon == "" ? "OBJICON" : icon;
        o.title = StringTable.Localize(title.filter());
        o.description = StringTable.Localize(description.filter());
        o.tag = tag;
        o.mapNum = mapNum >= 0 ? mapNum : Level.levelnum;
        o.hideOutsideMap = onlyInMap;
        o.mapTicsStarted = Level.time;
        o.order = order;

        // Add as child or into main list
        if(parent != -1 && parent != 0) {
            let p = find(parent);
            if(p) {
                p.addChild(o);
            } else {
                Console.Printf("\c[RED]Objective [%s] added to non-existent parent. Aborting.", title);
                return -1;
            }
        } else {
            // Insert, sorted
            if(objs.size() > 0) {
                for(int x = 0; x < objs.size(); x++) {
                    if(objs[x].order > o.order) {
                        objs.Insert(x, o);
                        break;
                    } else if(x + 1 == objs.size()) {
                        objs.Push(o);
                        break;
                    }
                }
            } else {
                objs.Push(o);
            }
        }

        // Notify the player
        if(getCVar("g_showobjectives") > 0) {
            if(notify == OBJECTIVE_NOTIFY_FULL) {
                Notification.QueueNew(parent != -1 && parent != 0 ? 'SubObjectiveNotification' : 'ObjectiveNotification', "\c[HI]New Objective Received", title, slot: NotificationItem.SLOT_TOP_MID);
            }

            if(notify >= OBJECTIVE_NOTIFY_FULL) {
                if(notify != OBJECTIVE_NOTIFY_FULL) {
                    S_StartSound(parent != -1 && parent != 0 ? "ui/getSubObjective" : "ui/getObjective", CHAN_VOICE, CHANF_UI, snd_menuvolume);
                }

                Notification.QueueOrUpdate('ObjectivesNotification', slot: NotificationItem.SLOT_MID_RIGHT);
            }
        }

        return tag;
    }


    bool update(int tag, string icon = "", string title = "-", string description = "-", int notify = OBJECTIVE_NOTIFY_FULL, int newOrder = -1) {
        if(tag < 0) {
            tag = autoTagCounter--;
        }

        // New objective
        let o = find(tag);

        if(!o) {
            Console.Printf("\c[RED]Failed to find objective %d for update! (%s)", tag, title);
            return false;
        }

        if(icon != "") o.icon = icon;
        if(title != "-") o.title = StringTable.Localize(title.filter());
        if(description != "-") o.description = StringTable.Localize(description.filter());
        if(newOrder != -1) {
            o.order = newOrder;

            let p = o.parent;
            if(p) {
                p.removeChild(o);
                p.addChild(o);
            } else {
                if(objs.size() > 1) {
                    // Remove from list, and reinsert sorted
                    for(int x = 0; x < objs.size(); x++) {
                        if(objs[x] == o) {
                            objs.delete(x);
                            break;
                        }
                    }
                    
                    for(int x = 0; x < objs.size(); x++) {
                        if(objs[x].order > o.order) {
                            objs.Insert(x, o);
                            break;
                        } else if(x + 1 == objs.size()) {
                            objs.Push(o);
                            break;
                        }
                    }
                }
            }
        }
        
        // Notify the player
        o.Update(notify);

        return true;
    }

    // Complete objective and notify the player
    // If this objective has sub-tasks they will be completed as well
    // Returns TRUE if objective was found
    bool complete(int tag, int notify = OBJECTIVE_NOTIFY_FULL) {
        let o = find(tag);
        if(o) {
            // Special case for a missing objective clear in 01A
            if(tag == 995) {
                // Find 995 and complete all sub objectives
                for(int x = 0; x < o.children.size(); x++) {
                    o.children[x].complete(OBJECTIVE_NOTIFY_NONE);
                }
            }

            o.complete(notify);
            return true;
        }
        return false;
    }

    // Cancel objective, full notify is disabled by default
    // If this objective has sub-tasks they will be cancelled as well
    // Returns TRUE if objective was found
    bool cancel(int tag, int notify = OBJECTIVE_NOTIFY_LIST) {
        let o = find(tag);
        if(o) {
            o.cancel(notify);
            return true;
        }
        return false;
    }


    // Trigger the objectives notification at any time
    void show() {
        Notification.QueueOrUpdate('ObjectivesNotification', slot: NotificationItem.SLOT_MID_RIGHT);
    }

    override void Tick() {
        Super.Tick();

        for(int x = 0; x < objs.size(); x++) { 
            if(objs[x].status > 0 && objs[x].ticks - Objective.TICKS_AFTER_COMPLETION >= objs[x].ticsFinish) {
                // This objective is done, move it to the cache
                Objective o = objs[x];
                objs.Delete(x--);
                history.Push(o);
                continue;
            }
            objs[x].tick(); 
        }
    }

    // Static Accessors =========================================================
    // Get the Objectives item for this session, or create one if it does not yet exist
    static Objectives GetObjectives(int player = -1) {
        if(player < 0) player = consolePlayer;
        if(!players[player].mo) return null;

        Objectives o = Objectives(players[player].mo.FindInventory("Objectives"));
        if(!o) {
            players[player].mo.GiveInventory("Objectives", 1);
            o = Objectives(players[player].mo.FindInventory("Objectives"));
            //o.init();
        }

        return o;
    }

    // Used out of play context, finds objectives object but will not create it
    clearscope static Objectives FindObjectives(int player = -1) {
        if(player < 0) player = consolePlayer;
        if(!players[player].mo) return null;
        return Objectives(players[player].mo.FindInventory("Objectives"));
    }

    // TODO: If this were multiplayer we would need to accept the activator here
    static int AddObjective(string icon, string title, string description = "", int tag = -1, int parent = -1, int mapNum = -1, bool onlyInMap = false, int notify = OBJECTIVE_NOTIFY_FULL, int order = 0) {
        let o = GetObjectives();
        return o.add(icon, title, description, tag, parent, mapNum, onlyInMap, notify, order);
    }

    static bool UpdateObjective(int tag, string icon = "-", string title = "-", string description = "-", int notify = OBJECTIVE_NOTIFY_FULL, int newOrder = -1) {
        let o = GetObjectives();
        return o.update(tag, icon, title, description, notify, newOrder);
    }

    static bool CompleteObjective(int tag, int notify = OBJECTIVE_NOTIFY_FULL) {
        let o = GetObjectives();

        return o.complete(tag, notify);
    }

    static bool CancelObjective(int tag, int notify = OBJECTIVE_NOTIFY_LIST) {
        let o = GetObjectives();
        return o.cancel(tag, notify);
    }

    static void ShowObjectives() {
        GetObjectives().Show();
    }

    static int ObjectiveStatus(int tag) {
        let objs = GetObjectives();
        if(objs) {
            let o = objs.find(tag);
            return o ? o.status : -1;
        }
        return -1;
    }
}