// Armor BREAK!
class ArmorNotification : Notification {
    const fadeInTime = 0.05;
    const fadeOutTime = 0.35;
    const scaleTime = 0.15;

    const maxRot = 7.0;
    const showTime = 2.0;

    UITexture lTex, rTex;
    Shape2D lShape, rShape;
    Shape2DTransform lTrans, rTrans;

    override void init(string title, string text, string image, int props) {
        Super.init("", "", "", props);
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        Super.start(time);

        lTex = UITexture.Get("PHBREAK1");
        rTex = UITexture.Get("PHBREAK2");
        lShape = new("Shape2D");
        rShape = new("Shape2D");

        int vc = 0;
        Shape2DHelper.AddQuad(lShape, (-64,-64), (128,128), (0,0), (1,1), vc);
        vc = 0;
        Shape2DHelper.AddQuad(rShape, (-64,-64), (128,128), (0,0), (1,1), vc);

        lTrans = new("Shape2DTransform");
        rTrans = new("Shape2DTransform");
    }

    /*override void tick(double time) {
        Super.tick(time);
    }*/

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        // Don't render if the weapon bar is showing
        let hudd = HUD(StatusBar);
        let wpbar = hudd ? HUD(StatusBar).wpbar : null;
        if(hasGasMask > 0 || (wpbar && wpbar.bstate != WeaponBar.BAR_HIDDEN)) {
            return;
        }


        Vector2 pos = (virtualScreenSize.x * 0.5, virtualScreenSize.y * 0.75);
        Vector2 sc = getVirtualScreenScale();
        double te = time - startTime;
        double tm = 1.0;
        double rotTm = UIMath.EaseOutCubicf(te / showTime);
        double scaleTM = 1.0 - MIN(1.0, te / scaleTime);

        // Determine fade
        if(te < fadeInTime) {
            tm = min(te / fadeInTime, 1.0);
        } else {
            double fadeTime = showTime - fadeOutTime;
            if(te >= fadeTime) tm = 1.0 - ((te - fadeTime) / (showTime - fadeTime));
        }

        lTrans.clear();
        lTrans.scale((sc * scale) + ((1.0, 1.0) * 1.25 * scaleTM));
        lTrans.rotate(-maxRot * rotTm);
        lTrans.translate((pos.x * sc.x, pos.y * sc.y));
        lShape.setTransform(lTrans);

        rTrans.clear();
        rTrans.scale((sc * scale) + ((1.0, 1.0) * 1.25 * scaleTM));
        rTrans.rotate(maxRot * rotTm);
        rTrans.translate((pos.x * sc.x, pos.y * sc.y));
        rShape.setTransform(rTrans);


        Screen.drawShape(
            lTex.texID,
            true,
            lShape,
            DTA_Alpha, alpha * tm,
            DTA_Filtering, true
        );

        Screen.drawShape(
            rTex.texID,
            true,
            rShape,
            DTA_Alpha, alpha * tm,
            DTA_Filtering, true
        );

        DrawStr('SELACOFONT', "CAUTION: ARMOR LOST", pos + (0, 72), flags: DR_TEXT_HCENTER | DR_IGNORE_INSETS, translation: Font.CR_GRAY, a: alpha * tm, monoSpace: false, scale: (0.87, 1));
    }
}