class SubtitleNotification : Notification {
    int titleColor, fontSize;
    double showTime, inverseScale;
    bool showBackground;
    
    const textTimeMult = 0.02;
    const fadeInTime = 0.16;
    const fadeOutTime = 0.35;
    const smallLineWidth = 600;

    override void init(string title, string text, string image, int props) {
        Super.init(title, title != "" ? String.Format("\c%s%s: \c-%s", hasGasMask ? "[HI3]" : "[HI]", StringTable.Localize(title.filter()), StringTable.Localize(text.filter())) : text, image, props);
        
        if(hasGasMask) {
            self.text.replace("\c[HI]", "\c[HI3]");
            self.text.replace("\c[OMNIBLUE]", "\c[HI3]");
        }

        // Set time based on how long the subtitle is
        showTime = 3.0 + (text.Length() * textTimeMult);
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        Super.start(time);

        showBackground = iGetCVar("snd_subtitlebg", 0);
        fontSize = iGetCVar("snd_subtitlesize", 2);
        inverseScale = fGetCVar("hud_scaling", 1.0);
        inverseScale = inverseScale <= 0.0 ? 1.0 : 1.0 / inverseScale;
    }

    override void tick(double time) {
        Super.tick(time);

        showBackground = iGetCVar("snd_subtitlebg", 0);
        fontSize = iGetCVar("snd_subtitlesize", 2);
        inverseScale = fGetCVar("hud_scaling", 1.0);
        inverseScale = inverseScale <= 0.0 ? 1.0 : 1.0 / inverseScale;
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        // On small screens, don't draw subtitles and the weapon bar at the same time
        if(isTightScreen) {
            let wpbar = HUD(StatusBar).wpbar;
			if(wpbar && wpbar.bstate != WeaponBar.BAR_HIDDEN) {
				return;
			}
        }

        Vector2 pos = (virtualScreenSize.x * 0.15, -300);
        Font fnt = "PDA16FONT";
        let inverseScale = inverseScale;

        // Get correct font size, instead of a scale which looks like shit let's just use different sized fonts
        switch(fontSize) {
            case 1:
                fnt = "PDA13FONT";
                break;
            case 3:
                fnt = "PDA18FONT";
                break;
            case 4:
                fnt = "PDA35OFONT";
                inverseScale *= 0.65;
                break;
        }

        double te = time - startTime;
        double tm = 1.0;

        // Determine fade
        if(te < fadeInTime) {
            tm = min(1.0, te / fadeInTime);
        } else {
            double fadeTime = showTime - fadeOutTime;
            if(te >= fadeTime) tm = 1.0 - ((te - fadeTime) / (showTime - fadeTime));
        }

        // I don't like calling this in a render function but it's necessary in case a notification is on screen when the game is saved
        BrokenLines br = fnt.breakLines(text, text.Length() > 140 ? (virtualScreenSize.x * 0.70) / inverseScale : (virtualScreenSize.x * 0.32) / inverseScale);

        int lineHeight = round(fnt.getHeight() * inverseScale);
        pos.y -= br.count() * lineHeight;   // Draw upwards instead of downward


        // If enabled, draw background
        if(showBackground) {
            int maxWidth = 0;
            for(int x = 0; x < br.count(); x++) {
                maxWidth = MAX(maxWidth, br.stringWidth(x) * inverseScale);
            }

            Dim(0xFF111111, 0.5 * tm, pos.x - 10, pos.y - 4, maxWidth + 20, lineHeight * br.count() + 9, DR_SCREEN_BOTTOM);
        }

        // Draw each line of text
        for(int x = 0; x < br.count(); x++) {
            DrawStr(fnt, br.stringAt(x), pos + (0, x * lineHeight), DR_SCREEN_BOTTOM, a: alpha * tm, monoSpace: false, scale: (inverseScale, inverseScale));
        }
    }
}