class NotificationDrawer ui {
    mixin CVARBuddy;
    mixin HUDScaleReader;

    UIRecycler recycler;
    
    private double uiscale, hudscale;
    private Vector2 screenInsetRaw;
    uint ticks;

    NotificationItem notifItem;
    
    void setUIScale(double newScale = 1.0) {
        uiscale = newScale;
        hudscale = getHUDScale();

        Vector2 screenSize = (Screen.GetWidth(), Screen.GetHeight());
        Vector2 virtualScreenSize = (Screen.GetWidth() / uiScale, Screen.GetHeight() / uiScale);
        
        // Set insets as a percentage of the screen width/height
        CVar ix = CVar.FindCVar('hud_inset_x');
        CVar iy = CVar.FindCVar('hud_inset_y');
        double ixx = ix ? clamp(ix.getFloat(), 0.0, 1.0) : 0;
        double iyy = iy ? clamp(iy.getFloat(), 0.0, 1.0) : 0;
        screenInsetRaw = (ixx, iyy);
        Vector2 screenInsets = (
            clamp(virtualScreenSize.x * 0.5 * ixx, 0, max(0, (virtualScreenSize.x * 0.5) - 1078)),
            virtualScreenSize.y * 0.5 * iyy
        );

        if(notifItem) {
            for(int x = 0; x < NotificationItem.SLOTS_NUM_TOTAL; x++) {
                let n = notifItem.notifs[x];
                
                if(n) {
                    n.screenSize = screenSize;
                    n.virtualScreenSize = n.ignoresHUDScaling ? virtualScreenSize * hudscale : virtualScreenSize;
                    n.screenInsets = n.ignoresHUDScaling ? screenInsets * hudScale :  screenInsets;
                    n.calcTightScreen();
                    n.calcUltrawide();
                }
            }
        }
    }

    void tick() {
        if(!notifItem) {
            ticks++;
            return;
        }

        if(ticks % 38 == 0 || hudscale == 0) hudscale = getHUDScale();

        Vector2 screenSize = (Screen.GetWidth(), Screen.GetHeight());
        Vector2 virtualScreenSize = (Screen.GetWidth() / uiScale, Screen.GetHeight() / uiScale);
        Vector2 screenInsets = (
            clamp(virtualScreenSize.x * 0.5 * screenInsetRaw.x, 0, max(0, (virtualScreenSize.x * 0.5) - 1078)),
            virtualScreenSize.y * 0.5 * screenInsetRaw.y
        );

        for(int x = 0; x < NotificationItem.SLOTS_NUM_TOTAL; x++) {
            if(notifItem.notifs[x]) {
                notifItem.notifs[x].screenSize = screenSize;
                notifItem.notifs[x].virtualScreenSize = notifItem.notifs[x].ignoresHUDScaling ? virtualScreenSize * hudscale : virtualScreenSize;
                notifItem.notifs[x].screenInsets = notifItem.notifs[x].ignoresHUDScaling ? screenInsets * hudScale :  screenInsets;
                notifItem.notifs[x].calcTightScreen();
                notifItem.notifs[x].calcUltrawide();
            }
        }

        ticks++;
    }

    ui void draw(double tm, Vector2 offset = (0,0), bool hideCenter = false) {
        if(!notifItem) { return; }

        let time = (double(notifItem.ticks) * ITICKRATE) + (tm * ITICKRATE);

        for(int x = 0; x < NotificationItem.SLOTS_NUM_TOTAL; x++) {
            if(notifItem.notifs[x] && (!hideCenter || x != NotificationItem.SLOT_TOP_MID)) notifItem.notifs[x].draw(offset, time, tm);
        }
    }
}