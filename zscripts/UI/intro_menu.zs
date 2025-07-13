class IntroMenu : UIMenu {

    override void init(Menu parent) {
        Super.init(parent);
        menuActive = Menu.OnNoPause;
        DontDim = true;
        DontBlur = true;
        AnimatedTransition = false;
        Animated = true;
        
        hideCursor();
    }

    override bool onBack() {
        bool firstRun = false;

        // Check for firstRun param, and don't try to skip on first run
        let handler = IntroHandler(StaticEventHandler.Find('IntroHandler'));
        if(handler) {
            firstRun = handler.firstRun;
        }

        if(firstRun) { return true; }
        
        // Prevent the first few ticks from allowing back
        if(ticks < 10) {
            return true;
        }
        
        ACS_Execute(-int('ExecuteMenuSkip'), 0);  // Why does this work from menus? :gzdoom:
        
        if(handler) {
            MenuSound('menu/backup');
            SetMusicVolume(0);
            // Let the intro handler know it needs to ramp the music back up
            handler.notifyMusicBumped();
        }

        Close();
        return true;
    }

    override void ticker() {
        Super.ticker();
        Animated = true;
    }
}