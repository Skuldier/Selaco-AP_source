class ArmorHudDrawer : OverlayDrawer {
    TextureID subTex;

    Vector2 texSize;
    Vector2 scaleAdjust;     
    // The entire hex pattern is based off a 1920x1080 image, we have to scale the sprites to match any scaling that's happening

    const subGfx = "V_ARMB";
    const maxAlpha = 0.75;

    override OverlayDrawer Init(string texture) {
        Super.Init(texture);

        subTex = TexMan.checkForTexture(subGfx, TexMan.Type_Any);
        texSize = TexMan.getScaledSize(tid);

        int scWidth = Screen.GetWidth();
        int scHeight = Screen.GetHeight();
        CalcScaleAdjust(Screen.GetWidth(), Screen.GetHeight());

        return self;
    }

    void CalcScaleAdjust(int scWidth, int scHeight) {
        float adj = scWidth < 1920 || scHeight < 1080 ? MIN(float(scWidth) / 1920.0,  float(scHeight) / 1080.0) : 1.0;
        // Special adjustment for 4K
        if(scHeight >= 2000 && scWidth >= 3000) {
            adj = 2.0;
        }
        scaleAdjust = (adj, adj);
    }


    override void screenSizeChanged(int scWidth, int scHeight, double scale) { 
        Super.screenSizeChanged(scWidth, scHeight, scale);
        CalcScaleAdjust(scWidth, scHeight);
    }


    override void Draw(int scWidth, int scHeight, double tm, Vector2 offset) {
        if(disabled) return;
        if(!makeTexReady(tid) || !makeTexReady(subTex)) return;
        
        double te = GetTE(tm);
        double time = MSTime() / 1000.0;

        if(te > fade) { return; }
        
        double ote = GetOTE(tm);
        float a = maxAlpha * (fade <= 0 ? alpha : MIN(1.0, 1.0 - (te / fade)) * alpha);
        double pulse = 1.0 - (abs(sin(ote * 180.0)) * 0.25);
        double subA = MIN(1.0, 1.0 - UIMath.EaseOutCubicf(ote * 0.75));
        
        //COnsole.printf("Ticks: %d TM: %f TE: %f A: %f SUBA: %f", ticks, tm, te, a, subA);

        Vector2 voffset = offset * -1.6;
        Vector2 size = (texSize.x * scaleAdjust.x, texSize.y * scaleAdjust.y);
        Vector2 tl = voffset - (20, 20);
        Vector2 tr = (scWidth - size.x + voffset.x + 20, voffset.y - 20);
        Vector2 bl = (voffset.x - 20, scHeight - size.y + voffset.y + 20);
        Vector2 br = (scWidth - size.x + voffset.x + 20, scHeight - size.y + voffset.y + 20);

        // Draw fading base
        if(subA > 0.0001) {
            // Top Left
            Screen.DrawTexture(subTex, false, tl.x, tl.y,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_ALPHA, a * subA);

            // Top Right
            Screen.DrawTexture(subTex, false, tr.x, tr.y,
                    DTA_DestWidthF, size.x,
                    DTA_DestHeightF, size.y,
                    DTA_FlipX, true,
                    DTA_ALPHA, a * subA);

            // Bottom Left
            Screen.DrawTexture(subTex, false, bl.x, bl.y,
                    DTA_DestWidthF, size.x,
                    DTA_DestHeightF, size.y,
                    DTA_FlipY, true,
                    DTA_ALPHA, a * subA);

            // Bottom Right
            Screen.DrawTexture(subTex, false, br.x, br.y,
                    DTA_DestWidthF, size.x,
                    DTA_DestHeightF, size.y,
                    DTA_FlipX, true,
                    DTA_FlipY, true,
                    DTA_ALPHA, a * subA);
        }
        
        // Draw overlay
        // Top Left
        Screen.DrawTexture(tid, false, tl.x, tl.y,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_ALPHA, a * pulse);

        // Top Right
        Screen.DrawTexture(tid, false, tr.x, tr.y,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_FlipX, true,
                DTA_ALPHA, a * pulse);

        // Bottom Left
        Screen.DrawTexture(tid, false, bl.x, bl.y,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_FlipY, true,
                DTA_ALPHA, a * pulse);

        // Bottom Right
        Screen.DrawTexture(tid, false, br.x, br.y,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_FlipX, true,
                DTA_FlipY, true,
                DTA_ALPHA, a * pulse);
    }
}