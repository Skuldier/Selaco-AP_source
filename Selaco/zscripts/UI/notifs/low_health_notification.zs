// Heal your bad self.
class LowHealthNotification : Notification {
    bool showMedkitInfo;

    const fadeInTime = 0.05;
    const fadeOutTime = 0.35;
    const showTime = 10.0;

    override void init(string title, string text, string image, int props) {
        Super.init(
            UIHelper.FilterKeybinds(StringTable.Localize("$LOWHEALTH"), shortMode: true), 
            UIHelper.FilterKeybinds(StringTable.Localize("$LOWHEALTH_MEDKIT"), shortMode: true), 
            "", 
            props
        );

        showMedkitInfo = props > 0;
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void update(double time, string title, string text, string image, int props) {
        Super.update(time, title, text, image, props);

        showMedkitInfo = props > 0;
    }

    override void start(double time) {
        Super.start(time);
    }

    override bool fastForward(double time) {
        double te = time - startTime;
        if(te < showTime - fadeOutTime) {
            startTime = time + fadeOutTime - showTime;
        }
        return true;
    }

    override void tick(double time) {
        // Periodically check for medkits to update the message
        if(ticks % 5 == 0) showMedkitInfo = players[consolePlayer].mo.countInv('MedkitCount') > 0;

        Super.tick(time);
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        // Don't render if the weapon bar is showing
        let hudd = HUD(StatusBar);
        let wpbar = hudd ? HUD(StatusBar).wpbar : null;
        if(wpbar && wpbar.bstate != WeaponBar.BAR_HIDDEN) {
            return;
        }

        Vector2 pos = (virtualScreenSize.x * 0.5, virtualScreenSize.y * 0.75);
        Vector2 sc = getVirtualScreenScale();
        double te = time - startTime;
        double tm = 1.0;
        double a = (0.5 + (sin(time * 360.0) * 0.5)) * 0.35;

        // Determine fade
        if(te < fadeInTime) {
            tm = min(te / fadeInTime, 1.0);
        } else {
            double fadeTime = showTime - fadeOutTime;
            if(te >= fadeTime) tm = 1.0 - ((te - fadeTime) / (showTime - fadeTime));
        }

        // Thanks 4chan, you finally made a good point!
        //DrawStr('SELOFONT', title, pos, flags: DR_TEXT_HCENTER, a: (alpha * tm) - a, monoSpace: false);
        if(showMedkitInfo)  DrawStr('SEL27OFONT', text, pos + (0, 25), flags: DR_TEXT_HCENTER, a: alpha * tm, monoSpace: false);
    }
}