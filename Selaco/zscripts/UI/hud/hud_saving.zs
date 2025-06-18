class SavingAnimation ui {
    mixin UIDrawer;

    Shape2D shape;
    Shape2DTransform transform;
    UITexture emblemTex;
    double uiScale;
    double startTime;

    bool preparing, showEmblem;

    const EMB_ROT_SPEED = 120.0;
    const FADE_TIME = 0.15;
    const COMPLETED_LIFE = 2.0;
    const COMPLETED_TOTAL_LIFE = COMPLETED_LIFE + FADE_TIME;

    SavingAnimation init() {
        emblemTex = UITexture.Get("EMBLEMZ");
        shape = new("Shape2D");
        transform = new("Shape2DTransform");
        uiScale = 1.0;

        preparing = true;
        showEmblem = true;

        int vc = 0;
        Shape2DHelper.AddQuad(shape, (emblemTex.size.x * -0.5, emblemTex.size.y * -0.5), emblemTex.size, (0,0), (1,1), vc);

        return self;
    }

    bool hasCompleted(double time) {
        return preparing && time - startTime > 20 || !preparing && time - startTime > COMPLETED_TOTAL_LIFE;
    }

    void setUIScale(double newScale = 1.0) {
        uiscale = newScale;

        screenSize = (Screen.GetWidth(), Screen.GetHeight());
        virtualScreenSize = (Screen.GetWidth() / uiScale, Screen.GetHeight() / uiScale);
    }

    void Draw(double time) {
        if(showEmblem && !makeTexReady(emblemTex.texID)) return;

        let scScale = getVirtualScreenScale();
        let centerPos = (screenSize / 2.0) - (0, screenSize.y / 4.0);
        let alpha = CLAMP( preparing ? (time - startTime) / FADE_TIME : 1.0 - ((time - startTime - 2.0) / FADE_TIME),  0.0, 1.0 );

        if(showEmblem) {
            // Draw rotating save icon
            transform.clear();
            transform.scale(preparing ? scScale + ((0.5,0.5) * (1.0 - UIMath.EaseInOutCubicF(alpha))) : scScale);
            transform.rotate(EMB_ROT_SPEED * time);
            transform.translate(centerPos);
            shape.setTransform(transform);

            Screen.DrawShape(emblemTex.texID, false, shape, 
                DTA_Alpha, alpha,
                DTA_Filtering, true
            );
        }
        
        // Need relative coords now instead of screen coords
        centerPos = (virtualScreenSize / 2.0) - (0, virtualScreenSize.y / 4.0) + (0, 10);

        // Draw Text
        DrawStr('SMALLFONT', 
            preparing ? "SAVING PROGRESS..." : "GAME SAVED!",
            centerPos,
            flags: DR_TEXT_CENTER,
            a: alpha,
            monoSpace: false,
            scale: (4, 4) + (showEmblem ? (0, 0) : ((0.5,0.5) * (1.0 - UIMath.EaseInOutCubicF(alpha))))
        );
    }
}