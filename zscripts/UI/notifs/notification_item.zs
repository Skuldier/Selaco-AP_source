class NotificationQueue {
    Array<Notification> notifs;
}

class NotificationItem : Inventory {
    enum NotifSlot {
        SLOT_TOP_LEFT   = 0,
        SLOT_MID_LEFT   = 1,
        SLOT_BOT_LEFT   = 2,
        SLOT_BOT_MID    = 3,
        SLOT_BOT_RIGHT  = 4,
        SLOT_MID_RIGHT  = 5,
        SLOT_TOP_RIGHT  = 6,
        SLOT_TOP_MID    = 7,
        SLOTS_NUM_TOTAL,

        SLOT_CENTER = SLOT_TOP_MID
    }

    enum NotifProps {
        PROP_IMPORTANT      = 1,
        PROP_CLEARQ         = 1 << 1,
        PROP_SHOWNEXT       = 1 << 2
    }

    NotificationQueue queue[SLOTS_NUM_TOTAL];
    Notification notifs[SLOTS_NUM_TOTAL];
    
    UIRecycler recycler;

    uint ticks;

    override void BeginPlay() {
        Super.BeginPlay();

        for(int x = 0; x < SLOTS_NUM_TOTAL; x++) {
            queue[x] = new("NotificationQueue");
            notifs[x] = null;
        }
    }

    override void tick() {
        Super.tick();
        
        double time = ticks * ITICKRATE;

        for(int x = 0; x < SLOTS_NUM_TOTAL; x++) {
            bool isFirst = true;
            let n = notifs[x];
            if(n) {
                isFirst = false;
                n.tick(time);
            }

            if(!n || n.isComplete(time)) {
                if(n) {
                    n.teardown(recycler);
                    n.destroy();
                }

                // Dequeue the next item
                let q = queue[x];
                notifs[x] = q.notifs.size() > 0 ? q.notifs[q.notifs.size() - 1] : null;
                if(notifs[x]) notifs[x].start(time, isFirst: isFirst, isLast: q.notifs.size() <= 1);
                q.notifs.pop();
            }
        }

        ticks++;
    }

    int queueNotif(Notification notif, int slot) {
        queue[slot].notifs.insert(0, notif);
        return queue[slot].notifs.size() - (notifs[slot] ? 0 : 1);
    }

    int queueImportantNotif(Notification notif, int slot, bool clearQueue = true) {
        // Fast forward the current notification
        if(notifs[slot]) {
            if(!notifs[slot].fastForward(ticks * ITICKRATE)) {
                notifs[slot].destroy();
                notifs[slot] = null;
            }
        }

        if(clearQueue) {
            queue[slot].notifs.clear();
            queueNotif(notif, slot);
            return queue[slot].notifs.size() - (notifs[slot] ? 0 : 1);
        } else {
            queue[slot].notifs.push(notif);
            return notifs[slot] ? 1 : 0;
        }
    }

    // Find the first notification of class CLS. Optionally restrict by TAG
    Notification, int find(class<Notification> cls, bool inQueue = true, Name tag = "none") {
        for(int x = 0; x < SLOTS_NUM_TOTAL; x++) {
            if(notifs[x] is cls) {
                if(tag != "none") {
                    if(notifs[x].tag == tag) {
                        return notifs[x], 0;
                    }
                } else {
                    return notifs[x], 0;
                }
            }
        }

        if(inQueue) {
            for(int x = 0; x < SLOTS_NUM_TOTAL; x++) {
                for(int y = 0; y < queue[x].notifs.size(); y++) {
                    if(queue[x].notifs[y] is cls) {
                        if(tag != "none") {
                            if(queue[x].notifs[y].tag == tag) {
                                return queue[x].notifs[y], queue[x].notifs.size() - y;
                            }
                        } else {
                            return queue[x].notifs[y], queue[x].notifs.size() - y;
                        }
                    }
                }
            }
        }

        return null, -1;
    }

    bool remove(Name tag, bool useFF = true) {
        bool hasRemoved = false;

        // Remove or fast forward active notifs
        for(int x = 0; x < SLOTS_NUM_TOTAL; x++) {
            if(notifs[x] && notifs[x].tag == tag) {
                let n = notifs[x];
                if(useFF && n.fastForward(ticks * ITICKRATE)) {
                    // Do nothing
                } else {
                    notifs[x] = null;
                    n.teardown(recycler);
                    n.destroy();
                }
                
                hasRemoved = true;
            }
        }

        // Just completely remove queued notifs of this tag
        for(int x = 0; x < SLOTS_NUM_TOTAL; x++) {
            for(int y = 0; y < queue[x].notifs.size(); y++) {
                let n = queue[x].notifs[y];
                if(n && n.tag == tag) {
                    queue[x].notifs.Delete(y);
                    n.teardown(recycler);
                    n.destroy();
                    y--;
                    hasRemoved = true;
                }
            }
        }

        return hasRemoved;
    }
}