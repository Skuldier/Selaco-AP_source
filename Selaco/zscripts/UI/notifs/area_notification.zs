class AreaNotification : Notification {
    int titleColor;

    string playSound;
    UITexture backgroundTex;
    Font titleFnt;
    Font textFnt;

    double fadeTime;
    double showTime;
    double endTime1;
    double mainEndTime;
    double mainImgTime;
    

    override void init(string title, string text, string image, int props) {
        playSound = "ui/NewArea";

        Super.init(title, UIHelper.FilterKeybinds(text, shortMode: true), image, props);

        if(hasGasMask) {
            self.text.replace("\c[HI]", "\c[HI3]");
            self.text.replace("\c[OMNIBLUE]", "\c[HI3]");
        }

        titleColor = hasGasMask ? Font.FindFontColor("HI3") : Font.FindFontColor("HI");

        fadeTime = 0.5;
        showTime = 3.5;
        mainImgTime = 0.2;
        endTime1 = showTime - fadeTime;
        mainEndTime = showTime - mainImgTime;

        //backgroundTex = UITexture.Get("AREABG");
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        Super.start(time);

        titleFnt = "SEL46FONT";
        textFnt = "SEL52FONT";

        S_StartSound(playSound, CHAN_VOICE, CHANF_UI);
    }

    /*override void tick(double time) {

    }*/

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = (0, 270);
        double te = time - startTime;
        double tm = UIMath.EaseOutCubicf(clamp(te / 0.2, 0.0, 1.0));
        double a = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);
        double aa = alpha * a * tm;
        
        double sctm = UIMath.Lerpf(0.95, 1.0, tm);
        Vector2 scale = (sctm, sctm) * 0.85;

        // Text params
        let mpos = pos - (0, 3);
        let tpos = pos + (0, 3);

        // Draw Text Shadow
        ///(Font fnt, String str, Vector2 pos, int baseCol = 0xFFFFFFFF, int col = 0xFFFFFFFF, int flags = 0, double a = 1., bool monoSpace = true, int linespacing = 0, Vector2 scale = (1, 1), bool filter = true, int desaturate = 0)
        DrawStrCol(titleFnt, title, mpos + (3,3), col: 0xFF000000, flags: DR_TEXT_HCENTER | DR_TEXT_BOTTOM | DR_SCREEN_HCENTER, /*translation: 0xFF000000,*/ a: aa * 0.2, monoSpace: false, scale: scale);
        DrawStrCol(textFnt, text, tpos + (3,3), col: 0xFF000000, flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, /*translation: 0xFF000000,*/ a: aa * 0.2, monoSpace: false, scale: scale);

        // Draw text
        DrawStr(titleFnt, title, mpos, flags: DR_TEXT_HCENTER | DR_TEXT_BOTTOM | DR_SCREEN_HCENTER, translation: titleColor, a: aa, monoSpace: false, scale: scale);
        DrawStr(textFnt, text, tpos, flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, a: aa, monoSpace: false, scale: scale);
    }
}


class LevelNotification : AreaNotification {
    override void init(string title, string text, string image, int props) {
        Super.init(title, text, image, props);

        playSound = "ui/NewLevel";

        fadeTime = 2.2;
        showTime = 4.2;
        mainImgTime = 0.2;
        endTime1 = showTime - fadeTime;
        mainEndTime = showTime - mainImgTime;
    }


    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = (0, 270);
        double te = time - startTime;
        double tm = UIMath.EaseOutCubicf(clamp(te / 0.65, 0.0, 1.0));
        double a = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);
        double aa = alpha * a * tm;
        
        double sctm = UIMath.Lerpf(0.98, 1.0, tm);
        Vector2 scale = (1, 1);

        // Text params
        let mpos = pos - (0, 5);
        let tpos = pos + (0, 5);
        let shadowMove = UIMath.EaseOutCubicf(te / showTime);
        let ta = te < mainEndTime ? UIMath.EaseOutCubicf(te / mainEndTime) : 1.0 - ((te - mainEndTime) / mainImgTime);
        ta *= aa * 0.2;

        // Draw Text Shadow
        DrawStrCol(titleFnt, title, mpos + (4, shadowMove * 8), col: 0xFF000000, flags: DR_TEXT_HCENTER | DR_TEXT_BOTTOM | DR_SCREEN_HCENTER, /*translation: 0xFF000000,*/ a: ta, monoSpace: false, scale: scale);
        DrawStrCol(textFnt, text, tpos + (6, shadowMove * 10), col: 0xFF000000, flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, /*translation: 0xFF000000,*/ a: ta, monoSpace: false, scale: scale);
        
        //DrawStr(titleFnt, title, mpos + (4, shadowMove * 8), flags: DR_TEXT_HCENTER | DR_TEXT_BOTTOM  | DR_SCREEN_HCENTER, translation: 0xFF000000, a: ta, monoSpace: false, scale: scale);
        //DrawStr(textFnt, text, tpos + (6, shadowMove * 10), flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, translation: 0xFF000000, a: ta, monoSpace: false, scale: scale);
       
        // Draw text
        DrawStr(titleFnt, title, mpos, flags: DR_TEXT_HCENTER | DR_TEXT_BOTTOM | DR_SCREEN_HCENTER, translation: titleColor, a: aa, monoSpace: false, scale: scale);
        DrawStr(textFnt, text, tpos, flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, a: aa, monoSpace: false, scale: scale);
    }
}




class LocationNotification : AreaNotification {
    TextureID bgTex;

    override void init(string title, string text, string image, int props) {
        Super.init(title, text, image, props);

        //ignoresHUDScaling = true;

        bgTex = TexMan.CheckForTexture(hasGasMask ? "PANOBJ3" : "PANOBJ");
        playSound = "ui/NewRoom";

        fadeTime = 0.25;
        showTime = 3.1;
        mainImgTime = 0.2;
        endTime1 = showTime - fadeTime;
        mainEndTime = showTime - mainImgTime;
    }

    override void start(double time) {
        Super.start(time);

        titleFnt = "SEL21FONT";
        textFnt = "SEL21FONT";
    }


    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        if(!makeTexReady(bgTex)) return;

        // Hack the overall scale to be slightly larger
        let oldVS = virtualScreenSize;
        virtualScreenSize *= 0.9;

        Vector2 pos = (0, 180);
        double te = time - startTime;
        double tm = UIMath.EaseOutCubicf(clamp(te / 0.22, 0.0, 1.0));
        double a = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);
        double aa = alpha * a * tm;

        // Text params
        let mpos = pos + (0, 13);
        let tpos = pos + (0, 40);

        // Background
        DrawTexAdvanced(bgTex, pos, flags: DR_NO_SPRITE_OFFSET | DR_IMG_HCENTER | DR_SCREEN_HCENTER, a: aa);

        // Draw text
        DrawStr(titleFnt, title, mpos, flags: DR_TEXT_HCENTER | DR_TEXT_VCENTER | DR_SCREEN_HCENTER, translation: titleColor, a: aa, monoSpace: false, scale: (0.79, 0.79));
        DrawStr(textFnt, text, tpos, flags: DR_TEXT_HCENTER | DR_TEXT_VCENTER | DR_SCREEN_HCENTER, a: aa, monoSpace: false, scale: (1,1));

        virtualScreenSize = oldVS;
    }
}
