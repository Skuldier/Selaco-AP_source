struct HHSprite {
    Vector2 pos;
    double time, ts, length;
    float scale;

    const sizeDiv = 0.25;
    const sizeDivInv = 1.0 - sizeDiv;

    void randomize(double life, double start, bool firstFrame = false) {
        length = frandom(life * 0.6, life * 1.2);
        time = firstFrame ? frandom(0.0, length) : 0.0;
        ts = start + time;
        scale = frandom(1.0, 3.0);

        switch(random(0,3)) {
            case 0:
                pos = (frandom(0, sizeDiv), frandom(0, sizeDiv));
                break;
            case 1:
                pos = (frandom(sizeDivInv, 1.0), frandom(0, sizeDiv));
                break;
            case 2:
                pos = (frandom(0, sizeDiv), frandom(sizeDivInv, 1.0));
                break;
            default:
                pos = (frandom(sizeDivInv, 1.0), frandom(sizeDivInv, 1.0));
                break;
        }
    }
}



class HealthHudDrawer : OverlayDrawer {
    TextureID healTex;
    Vector2 healSize;

    HHSprite sprites[8];

    const spTime = 0.75;
    const spSpeed = 4.0;
    const spTMul = 1.05;

    override OverlayDrawer Init(string texture) {
        Super.Init(texture);

        for(int x = 0; x < sprites.size(); x++) {
            sprites[x].randomize(spTime, 0.0, true);
        }

        healTex = TexMan.checkForTexture("HLSPRITE", TexMan.Type_Any);
        healSize = TexMan.getScaledSize(healTex);

        makeTexReady(healTex);
        
        return self;
    }

    override void Tick() {
        Super.Tick();
        
        double te = GetTE();
        if(fade - te > 0.001) {
            double tm = GetOTE();
            for(int x = 0; x < sprites.size(); x++) {

                if(tm - sprites[x].ts > sprites[x].length) {
                    sprites[x].randomize(spTime, tm);
                }
            }
        }
    }

    override void Restart() {
        Super.Restart();
        for(int x = 0; x < sprites.size(); x++) {
            sprites[x].randomize(spTime, 0, true);
        }
    }

    /*override void ScreenSizeChanged(int scWidth, int scHeight, double scale) {
		Super.ScreenSizeChanged(scWidth, scHeight, scale);

    }*/

    override void Draw(int scWidth, int scHeight, double tm, Vector2 offset) {
        if(disabled) return;
        
        double te = GetTE(tm);

        if(fade - te > 0.001) {
            Super.Draw(scWidth, scHeight, tm, offset);
        }

        if((fade * spTMul) - te > 0.001) {
            if(!makeTexReady(healTex)) return;

            double ote = GetOTE(tm);
            double xtm = MIN(1.0, ote / 0.15);

            // Draw all of the heal symbols
            for(int x = 0; x < sprites.size(); x++) {
                double xte = ote - sprites[x].ts;
                double m = MIN(1.0, xte / sprites[x].length);
                double rm = MIN(1.0, xte / (sprites[x].length * 0.2));

                Vector2 pos = (sprites[x].pos.x * scWidth, sprites[x].pos.y * scHeight) + ((0,-(healSize.y * spSpeed * scale.x)) * m);
                double a = MIN(1.0, 1.0 - (te / (fade * spTMul))) * (1.0 - UIMath.EaseInCubicF(m)) * rm * xtm;
                Screen.DrawTexture(healTex, false, pos.x, pos.y,
                    DTA_DestWidthF, healSize.x * sprites[x].scale * scale.x,
                    DTA_DestHeightF, healSize.y * sprites[x].scale * scale.y,
                    DTA_CenterBottomOffset, 1,
                    DTA_ALPHA, a);
            }
        }
    }
}


class PainHudDrawer : OverlayDrawer {
    override void Draw(int scWidth, int scHeight, double tm, Vector2 offset) {
        double te = GetTE(tm);
        double ote = GetOTE(tm);
        double pulse = 1.0 - (UIMath.EaseInOutCubicF(abs(sin(ote * 180.0))) * 0.25);
        
        if(te < fade) {
            Screen.DrawTexture(tid, false, 0, 0,
                DTA_DestWidthF, scWidth,
                DTA_DestHeightF, scHeight,
                DTA_ALPHA, fade <= 0 ? alpha : MIN(1.0, 1.0 - (te / fade)) * alpha * pulse);
        }
    }
}

