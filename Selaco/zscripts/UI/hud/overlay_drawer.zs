// TODO: Remove the concept of overlays as a seperate object
// Now that we have the HudElement class just make them a subclass of that
class OverlayDrawer ui {
    TextureID tid;
    float alpha;
    double lastAlpha, targetAlpha, targetAlphaFactor;
    double fade, introTime;
    int padding;
    uint ts, ots, ticks, holdTicks;
    bool disabled;
    Vector2 scale;

    const TICKRATE = double(35.0);
    const ITICKRATE = double(1.0/35.0);
    

    virtual OverlayDrawer Init(string texture, Vector2 scale = (1,1)) {
        tid = TexMan.checkForTexture(texture, TexMan.Type_Any);
        lastAlpha = 1.0;
        alpha = 1.0;
        fade = 0;
        ticks = 0;          // I shouldn't have to do this, but I do.
        padding = 0;        // Added padding to image to adjust for potential offsets
        disabled = false;
        targetAlpha = -1;   // No target
        targetAlphaFactor = 0.25;
        self.scale = scale;

        return self;
    }

    virtual void Tick() {
        lastAlpha = alpha;

        if(targetAlpha >= 0) {
            double na = alpha + ((targetAlpha - alpha) * targetAlphaFactor);
            if(targetAlpha ~== 0 && alpha < 0.01) {
                na = 0;
            }
            SetAlpha(na);
        }

        ticks++;
    }

    virtual void Draw(int scWidth, int scHeight, double tm, Vector2 offset) {
        if(disabled) return;

        double te = GetTE(tm);
        
        if((te > fade && fade >= 0) || alpha < 0.001) { return; }

        if(!makeTexReady(tid)) return;  // Wait on texture load instead of blocking
        
        double fadea = MIN(1.0, 1.0 - (fade == 0 ? 0 : (te / fade)));
        double intro = introTime ~== 0 ? 1 : MIN(1.0, GetOTE(tm) / introTime);
        double a = UIMath.LerpD(lastAlpha, alpha, tm);

        if(padding > 0) {
            Screen.DrawTexture(tid, false, offset.x - padding, offset.y - padding,
                DTA_DestWidthF, scWidth + (padding * 2),
                DTA_DestHeightF, scHeight + (padding * 2),
                DTA_ALPHA, fade <= 0 ? a : (fadea * a * intro));
        } else {
            Screen.DrawTexture(tid, false, 0, 0,
                DTA_DestWidthF, scWidth,
                DTA_DestHeightF, scHeight,
                DTA_ALPHA, fade <= 0 ? a : (fadea * a * intro));
        }
    }

    virtual void SetAlpha(float a) {
        lastAlpha = alpha;
        alpha = a;
    }

    virtual void SetTargetAlpha(float a) {
        targetAlpha = a;
    }

    virtual void SetFade(double fd = 3.0, bool restart = false) {
        double te = GetTE();

        ts = ticks;

        if(restart || fade - te < 0.05) {
            Restart();
        }

        fade = fd;
    }

    virtual void Restart() {
        ots = ticks;
        ts = ticks;
    }

    virtual void screenSizeChanged(int scWidth, int scHeight, double scale = 1.0) { 
        self.scale = (scale,  scale);
    }

    // Get time elapsed since fade started
    protected double GetTE(double tm = 0.0) {
        // This is a bit of a hack, but TE on the first tick will always be 0. We don't want to start fading overlays until they have been displayed for at least 1 tick
        if(ticks - ts == 0) {
            return 0;
        }
        return (double(ticks - ts) / TICKRATE) + (tm * ITICKRATE);
    }

    // Get time elapsed since last restart
    protected double GetOTE(double tm = 0.0) {
        return (double(ticks - ots) / TICKRATE) + (tm * ITICKRATE);
    }

    ui bool makeReady(string texture) {
        return TexMan.MakeReady(TexMan.CheckForTexture(texture));
    }

    ui bool makeTexReady(TextureID texture) {
        return TexMan.MakeReady(texture);
    }
}