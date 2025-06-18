#include "ZScripts/UI/notifs/notification_drawer.zs"
#include "ZScripts/UI/notifs/notification_item.zs"
#include "ZScripts/UI/notifs/email_notification.zs"
#include "ZScripts/UI/notifs/map_notification.zs"
#include "ZScripts/UI/notifs/subtitle_notification.zs"
#include "ZScripts/UI/notifs/challenge_notification.zs"
#include "ZScripts/UI/notifs/objectives_notification.zs"
#include "ZScripts/UI/notifs/armor_notification.zs"
#include "ZScripts/UI/notifs/low_health_notification.zs"
#include "ZScripts/UI/notifs/progress_notification.zs"
#include "ZScripts/UI/notifs/area_notification.zs"
#include "ZScripts/UI/notifs/invasion_notification.zs"
#include "ZScripts/UI/notifs/weapon_notification.zs"
#include "ZScripts/UI/notifs/pb_notification.zs"


class Notification play {
    mixin UIDrawer;
    mixin CVARBuddy;

    enum Property {
        PROP_NONE           = 0,
        PROP_DRAW_BG        = 1,
        PROP_NO_TEXT_FILTER = 2,
        PROP_FORCED         = 4,

        PROP_TAG_1          = 1 << 10,
        PROP_TAG_2          = 1 << 11,
        PROP_TAG_3          = 1 << 12,
        PROP_TAG_4          = 1 << 13,
        PROP_TAG_5          = 1 << 14,
        PROP_TAG_6          = 1 << 15
    }

    string title, text, image;
    uint ticks;
    int props;
    Name tag;
    double startTime;
    string snd;
    bool hasGasMask;        // Gas mask will alter how some notifiations render
    bool ignoresHUDScaling;


    virtual void init(string title = "", string text = "", string image = "", int props = 0) {
        startTime = 0;
        self.title = StringTable.Localize(title.Filter());
        self.text = StringTable.Localize(text.Filter());
        self.image = image;
        self.props = props;

        checkForGasMask();
    }

    // For longer lived notifications, we might want to check more frequently for the mask instead of just at init()
    void checkForGasMask() {
        hasGasMask = players[consolePlayer].mo.FindInventory("GasMask");
    }

    virtual void update(double time, string title = "|", string text = "|", string image = "|", int props = -1) {
        if(title != "|") self.title = StringTable.Localize(title.Filter());
        if(text != "|") self.text = StringTable.Localize(text.Filter());
        if(image != "|") self.image = image;
        if(props != -1) self.props = props;

        updateStartTime(time);
    }

    virtual void updateStartTime(double time) {
        // We have had an update, so move the start time to extend our life
        if(startTime != 0 && time - startTime > 1.0) {
            startTime = time - 1.0;                     // Add one second to the possible time
            ticks = (time - startTime) * TICKRATE;      // Update ticks so self time calculation works
            // TODO: Change this, I don't like messing with the tick count
        }
    }

    virtual void start(double time, bool isFirst = true, bool isLast = true) {
        startTime = time;

        if(snd != "") {
            S_StartSound(snd, CHAN_VOICE, CHANF_UI, snd_menuvolume);
        }
    }

    // Return TRUE when the notification manager can remove this notif and show the next
    virtual bool isComplete(double time) {
        return false;
    }

    // When destroying a notif, use a recycler to save resources that can be recycled instead
    // of destroyed. Can potentially be used for tearing down UIViews
    virtual void teardown(UIRecycler recycler) {
        
    }

    // Offset may be provided to allow element slots to be pushed out of the way for more important
    // screen elements (such as pushing map updates downward when a tutorial is showing)
    virtual ui void draw(Vector2 offset, double time, double tm, double alpha = 1.0, double scale = 1.0) {

    }

    // Force the notif to be cut short, possibly animating out before it is replaced
    // Most of these will probably just disappear but this is to allow for a transition
    virtual void cancel() {
        
    }

    virtual void tick(double time) {
    }

    // Called when we want to speed this notification up to show another notification
    virtual bool fastForward(double time) {
        return false;
    }

    // Sometimes it may be important to get the height of the notif to render things above or below (such as pickups)
    // Calculate the height here
    int getHeight() {
        return 40;  
    }


    // Static accessorrz
    static clearscope NotificationItem GetItem() {
        return players[consolePlayer].mo ? NotificationItem(players[consolePlayer].mo.FindInventory("NotificationItem")) : null;
    }

    static NotificationItem GetOrCreateItem(Actor mo = null) {
        if(mo == null) {
            mo = players[consolePlayer].mo;
        }

        let item = NotificationItem(mo.FindInventory("NotificationItem"));
        if(!item) item = NotificationItem(mo.GiveInventoryType("NotificationItem"));

        return item;
    }

    static int Queue(Notification notif, int slot = NotificationItem.SLOT_TOP_LEFT, Actor ac = null, bool important = false) {
        if(!ac) ac = players[consolePlayer].mo;

        if(ac) {
            NotificationItem item = GetOrCreateItem(ac);

            if(item) {
                return important ? item.queueImportantNotif(notif, slot) : item.queueNotif(notif, slot);
            } else {
                Console.Printf("\c[RED]Failed to queue a notification (%s) : No notif item found on player actor!", notif.title);
            }
        } else {
            Console.Printf("\c[RED]Failed to queue a notification (%s) : No player actor!", notif.title);
        }

        return -1;
    }


    static int QueueNew(String cls, string title = "", string text = "", string image = "", int slot = NotificationItem.SLOT_TOP_LEFT, int props = 0, Name tag = "none", bool important = false) {
        let ac = players[consolePlayer].mo;

        if(ac) {
            NotificationItem item = GetOrCreateItem(ac);

            if(item) {
                Notification n = Notification(new(cls));

                if(!n) {
                    Console.Printf("\c[RED]Failed to create a new notification of tye %s (%s)", cls, title);
                    return false;
                }

                n.tag = tag;
                n.init(title, text, image, props);
                return important ? item.queueImportantNotif(n, slot) : item.queueNotif(n, slot);
            } else {
                Console.Printf("\c[RED]Failed to queue a notification (%s) : No notif item found on player actor!", title);
            }
        } else {
            Console.Printf("\c[RED]Failed to queue a new notification (%s) : No player actor!", title);
        }

        return 0;
    }

    static int QueueOrUpdate(Class<Notification> cls, string title = "", string text = "", string image = "", int slot = NotificationItem.SLOT_TOP_LEFT, int props = 0, Name tag = "none") {
        Notification n;
        int pos;
        [n, pos] = QueueOrUpdateCls(cls, title, text, image, slot, props, tag);
        return pos;
    }


    static Notification, int, bool QueueOrUpdateCls(Class<Notification> cls, string title = "", string text = "", string image = "", int slot = NotificationItem.SLOT_TOP_LEFT, int props = 0, Name tag = "none") {
        let ac = players[consolePlayer].mo;

        if(ac) {
            NotificationItem item = GetOrCreateItem(ac);

            if(item) {
                // Find an existing notification of the same type and update it instead of making a new one
                Notification n;
                int nPos = -1;
                bool created = false;
                [n, nPos] = item.find(cls, tag: tag);

                if(n) {
                    n.update(item.ticks * ITICKRATE, title, text, image, props);
                } else {
                    n = Notification(new(cls));
                    n.tag = tag;
                    n.init(title, text, image, props);
                    nPos = item.queueNotif(n, slot);
                    created = true;
                }

                return n, nPos, created;
            } else {
                Console.Printf("\c[RED]Failed to queue a notification (%s) : No notif item found on player actor!", title);
            }
        } else {
            Console.Printf("\c[RED]Failed to queue a new notification (%s) : No player actor!", title);
        }

        return null, -1, false;
    }


    // Same as QueueOrUpdate but only shows the notification if there is none already in that slot
    // Or updates any showing or in the queue
    static int QueueOrUpdateUnimportant(Class<Notification> cls, string title = "", string text = "", string image = "", int slot = NotificationItem.SLOT_TOP_LEFT, int props = 0, Name tag = "none") {
        let ac = players[consolePlayer].mo;

        if(ac) {
            NotificationItem item = GetOrCreateItem(ac);

            if(item) {
                // Find an existing notification of the same type and update it instead of making a new one
                Notification n;
                int nPos;
                [n, nPos] = item.find(cls, tag: tag);

                if(n) {
                    n.update(item.ticks * ITICKRATE, title, text, image, props);
                } else {
                    if(item.notifs[slot] != null) { return false; }     // Skip if there is a notification already showing
                    
                    n = Notification(new(cls));
                    n.tag = tag;
                    n.init(title, text, image, props);
                    nPos = item.queueNotif(n, slot);
                }

                return nPos;
            } else {
                Console.Printf("\c[RED]Failed to queue a notification (%s) : No notif item found on player actor!", title);
            }
        } else {
            Console.Printf("\c[RED]Failed to queue a new notification (%s) : No player actor!", title);
        }

        return -1;
    }


    static int UpdateOnly(Class<Notification> cls, string title = "", string text = "", string image = "", int props = 0, Name tag = "none") {
        let ac = players[consolePlayer].mo;

        if(ac) {
            NotificationItem item = GetOrCreateItem(ac);

            if(item) {
                // Find an existing notification of the same type and update it instead of making a new one
                Notification n;
                int nPos;
                [n, nPos] = item.find(cls, tag: tag);

                if(n) {
                    n.update(item.ticks * ITICKRATE, title, text, image, props);
                }

                return nPos;
            } else {
                Console.Printf("\c[RED]Failed to update a notification (%s) : No notif item found on player actor!", title);
            }
        } else {
            Console.Printf("\c[RED]Failed to update a new notification (%s) : No player actor!", title);
        }

        return -1;
    }

    // Fast forward active notifs with this tag, and remove any others from the queue
    static bool Remove(Name tag, bool useFF = true) {
        let ac = players[consolePlayer].mo;

        if(ac) {
            NotificationItem item = GetOrCreateItem(ac);

            if(item) {
                return item.remove(tag, useFF);
            } else {
                Console.Printf("\c[RED]Failed to remove a notification (%s) : No notif item found on player actor!", tag);
            }
        } else {
            Console.Printf("\c[RED]Failed to remove a notification (%s) : No player actor!", tag);
        }

        return false;
    }


    // TODO: NoOverride currently does nothing.
    static bool Subtitle(String source = "", String text = "", double time = -1, bool noOverride = 0, int props = 0) {
        if(!(props & PROP_FORCED) && CVar.GetCVar("snd_subtitles").getInt() <= 0) return false;  // Cancel if subtitles are disabled

        let ac = players[consolePlayer].mo;

        if(ac) {
            NotificationItem item = GetOrCreateItem(ac);

            if(item) {
                SubtitleNotification n = new("SubtitleNotification");

                n.init(source, text, "", props);

                if(time > 0) {
                    n.showTime = time;
                }

                item.queueImportantNotif(n, NotificationItem.SLOT_MID_LEFT);

                return true;
            } else {
                Console.Printf("\c[RED]Failed to queue a notification (%s) : No notif item found on player actor!", source);
            }
        } else {
            Console.Printf("\c[RED]Failed to queue a new notification (%s) : No player actor!", source);
        }

        return false;
    }
}