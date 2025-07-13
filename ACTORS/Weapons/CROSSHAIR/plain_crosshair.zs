class PlainCrosshair : CustomCrosshair {
    TextureID tex;


    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();
    }

    override void draw(double fracTic, double alpha, Vector2 offset) { 
        if(!weapon) return;

        Color crosscolor = crosshaircolor;
        Color col   = Color(255, crosscolor.r, crosscolor.g, crosscolor.b);

        // Draw tex
        DrawXTex(tex, offset, 0, a: alpha, color: col, center: (0.5, 0.5));
    }
}