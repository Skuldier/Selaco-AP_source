// "PrintBold" notification
// Meant to allow for basic center prints that go into the notification queue
class PBNotification : Notification {
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
        Super.init(title, UIHelper.FilterKeybinds(text, shortMode: true), image, props);

        if(hasGasMask) {
            self.text.replace("\c[HI]", "\c[HI3]");
            self.text.replace("\c[OMNIBLUE]", "\c[HI3]");
            self.title.replace("\c[HI]", "\c[HI3]");
            self.title.replace("\c[OMNIBLUE]", "\c[HI3]");
        }

        fadeTime = 0.5;
        showTime = 4.5;
        mainImgTime = 0.2;
        endTime1 = showTime - fadeTime;
        mainEndTime = showTime - mainImgTime;
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        Super.start(time);

        titleFnt = "SEL46FONT";
        textFnt = "SEL46FONT";

        S_StartSound(playSound, CHAN_VOICE, CHANF_UI);
    }


    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = (0, 340);
        double te = time - startTime;
        double tm = UIMath.EaseOutCubicf(clamp(te / 0.2, 0.0, 1.0));
        double a = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);
        double aa = alpha * a * tm;
        
        Vector2 scale = (0.85, 0.85);

        // Text params
        let mpos = pos - (0, 8);
        let tpos = pos + (0, 3);

        // Draw text
        DrawStr(titleFnt, title, mpos, flags: DR_TEXT_HCENTER | DR_TEXT_BOTTOM | DR_SCREEN_HCENTER, a: aa, monoSpace: false, scale: scale * 0.9);
        DrawStr(textFnt, text, tpos, flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, a: aa, monoSpace: false, scale: scale);
    }
}
