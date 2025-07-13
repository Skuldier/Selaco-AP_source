class WeaponNotification : Notification {
    int titleColor;
    bool playedSound;

    const START_DELAY = 1.1;
    const SHOW_TIME = 5.0;
    const TITLE_FADE_DELAY = 0.4;
    const TITLE_FADE_TIME = 0.25;
    const TEXT_FADE_TIME = 0.25;
    const TEXT_FADE_DELAY = 0.6;
    const IMAGE_FADE_IN = 0.25;
    //const IMAGE_REVEAL_TIME = 0.25;
    const FADE_OUT_TIME = 4.0;

    override void init(string title, string text, string image, int props) {
        Super.init(title, text, image, props);

    }

    override bool isComplete(double time) {
        return time - startTime > SHOW_TIME + START_DELAY;
    }

    override bool fastForward(double time) {
        let te = time - startTime;
        if(te < START_DELAY) {
            startTime = time;                                      // Fast forwarad past the delay
        } else if(te > FADE_OUT_TIME + START_DELAY) {
            startTime -= 1000;                                     // If we are fading out just remove the whole notification
            return false;
        }
        return true;
    }

    override void start(double time, bool isFirst, bool isLast) {
        Super.start(time);

        titleColor = Font.FindFontColor("HI");

        let cv = CVar.GetCVar("neverswitchonpickup", players[consolePlayer]);

        // Remove start delay if this is not the only notification that needs to show
        if(!isFirst || !isLast || (cv && cv.GetInt() > 0)) {
            startTime -= START_DELAY;
        }
    }

    override void tick(double time) {
        Super.tick(time);

        if(!playedSound && time - startTime > START_DELAY) {
            S_StartSound("ui/newweapon", CHAN_VOICE, CHANF_UI, snd_sfxvolume);
            playedSound = true;
        }
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        // Hack the overall scale to be slightly lower on small screens since this notification likes to overlap stuff
        let oldVS = virtualScreenSize;
        if(isTightScreen) {
            // Don't render if there is a notification in the top-left
            let i = Notification.GetItem();
            if(i && i.notifs[NotificationItem.SLOT_TOP_LEFT] != null) {
                return;
            }

            // If there is a tutorial up, reduce opacity significantly
            let evt = TutorialHandler.GetHandler();
            if(evt.isShowing()) alpha *= 0.25;

            virtualScreenSize *= 1.25;
        }
        

        Vector2 pos = (0, 140);
        Font titleFont = "SEL52FONT";
        Font weaponFont = "SEL46FONT";

        double te = time - startTime;
        if(te < START_DELAY) return;

        te -= START_DELAY;
        double tm = 1.0;

        // Determine global fade
        if(te > FADE_OUT_TIME) {
            tm = min(1.0, 1.0 - ((te - FADE_OUT_TIME) / (SHOW_TIME - FADE_OUT_TIME)));
        }

        // Draw title
        if(te > TITLE_FADE_DELAY) {
            let te = te - TITLE_FADE_DELAY;
            double titleZoom = UIMath.EaseOutCubicF(min(1.0, te / TITLE_FADE_TIME));
            let tscale = (1, 1) * (0.85 + (0.15 * titleZoom));
            DrawStrCol(titleFont, title, pos + (0,3), col: 0xFF000000, flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, a: alpha * tm * titleZoom * 0.25, monoSpace: false, scale: tscale);
            DrawStr(titleFont, title, pos, DR_SCREEN_HCENTER | DR_TEXT_HCENTER, titleColor, a: alpha * tm * titleZoom, monoSpace: false, scale: tscale);
        }
        

        // Draw subtitle
        if(te > TEXT_FADE_DELAY) {
            let te = te - TEXT_FADE_DELAY;
            double subtitleZoom = UIMath.EaseOutCubicF(min(1.0, te / TEXT_FADE_TIME));
            let tscale = (0.75, 0.75) * (0.85 + (0.15 * subtitleZoom));
            DrawStrCol(weaponFont, text, pos + (0, 285) + (0,3), col: 0xFF000000, flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, a: alpha * tm * subtitleZoom * 0.25, monoSpace: false, scale: tscale);
            DrawStr(weaponFont, text, pos + (0, 285), DR_SCREEN_HCENTER | DR_TEXT_HCENTER, a: alpha * tm * subtitleZoom, monoSpace: false, scale: tscale);
        }

        let imgPos = pos + (0, 170);

        // Draw image base
        /*double imgFade = UIMath.EaseOutCubicF(min(1.0, te / IMAGE_FADE_IN));
        DrawImgAdvanced(image, imgPos, DR_SCREEN_HCENTER | DR_IMG_HCENTER | DR_IMG_VCENTER | DR_NO_SPRITE_OFFSET | DR_STENCIL, a: alpha * tm * imgFade, scale: imgScale, color: 0xFF284459);
        */

        // Draw image
        double imgReveal = UIMath.EaseInCubicF(min(1.0, te / IMAGE_FADE_IN));
        Vector2 imgScale = (1.4, 1.4) + ((1,1) * ((0.5 * (1.0 - imgReveal)) - (0.05 * (1.0 - tm))));

        //Clip(-300, 0, (imgReveal * 600), 1200, DR_SCREEN_HCENTER);
        DrawImgAdvanced(image, imgPos, DR_SCREEN_HCENTER | DR_IMG_HCENTER | DR_IMG_VCENTER | DR_NO_SPRITE_OFFSET | DR_WAIT_READY, a: alpha * tm * imgReveal, scale: imgScale);
        //ClearClip();

        virtualScreenSize = oldVS;
    }
}