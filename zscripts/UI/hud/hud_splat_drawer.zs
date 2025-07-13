class HUDSplat ui {
    UITexture tex;

    int corner;
    double startTime;
    double lifetime;

    const maxLife = double(2.7);
    const minLife = double(2.65);
    const startScale = 0.98;
    const scaleTime = 0.001;

    HUDSplat init(int corner, double startTime, UITexture t) {
        self.corner = corner;
        self.startTime = startTime + frandom(-0.001, 0.001);
        tex = t;

        // TODO: Double check that lifetime is as desired! This was previously broken (using random instead of frandom)
        lifetime = frandom(minLife, maxLife);
        return self;
    }

    void draw(int scWidth, int scHeight, double time, Vector2 offset, int padding, float alpha) {
        double te = time - startTime;

        if(!TexMan.makeReady(tex.texID)) return;

        double aScale = UIMath.Lerpd(startScale, 1.0, min(te / scaleTime, 1.0));
        Vector2 scale = (scWidth / 320.0, scHeight / 200.0) * aScale;
        Vector2 size = (tex.size.x * scale.x, tex.size.y * scale.y);
        Vector2 pos = (0,0) - (padding, padding) + offset;
        bool flipX, flipY;
        switch(corner) {
            case 1:
                pos = (scWidth - size.x, 0) + (padding, -padding) + offset;
                flipX = true;
                break;
            case 2:
                pos = (0, scHeight - size.y) - (padding, -padding) + offset;
                flipY = true;
                break;
            case 3:
                pos = (scWidth - size.x, scHeight - size.y) + (padding, padding) + offset;
                flipX = flipY = true;
                break;
            default:
                break;
        }

        float a = UIMath.EaseOutCubicf(1.0 - (te / lifetime)) * alpha;

        // Draw overlay
        Screen.DrawTexture(tex.texID, false, pos.x, pos.y,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_ALPHA, a,
                DTA_FlipX, flipX,
                DTA_FlipY, flipY);
    }
}


class SplatHUDDrawer : OverlayDrawer {
    const numSplatTex = 8;

    UITexture splatTexs[numSplatTex];
    int curCorner;

    Array<HUDSplat> splats;

    override OverlayDrawer Init(string texture) {
        Super.Init(texture);

        for(int x =0; x < numSplatTex; x++) {
            splatTexs[x] = UITexture.Get("HUDSPLA" .. (x + 1));
        }

        curCorner = random(0, 3);
        
        return self;
    }

    override void tick() {
        Super.tick();

        double time = GetTE(0);
        
        int size = splats.size();
        for(int x =0; x < size; x++) {
            if(time - splats[x].startTime > splats[x].lifetime) {
                splats.delete(x--);
                size--;
            }
        }
    }

    void addSplat(int count) {
        for(int x =0; x < count && splats.size() < 8; x++) {
            curCorner = (curCorner + 1) % 4;
            let splat = new("HUDSplat").init(curCorner, GetTE(1.0), splatTexs[random(0,numSplatTex - 1)]);
            splats.push(splat);
        }
    }

    void clearSplats() {
        splats.clear();
    }

    override void Draw(int scWidth, int scHeight, double tm, Vector2 offset) {
        if(disabled) return;

        double te = GetTE(tm);
        for(int x =0; x < splats.size(); x++) {
            splats[x].draw(scWidth, scHeight, te, offset, padding, alpha);
        }
    }
}