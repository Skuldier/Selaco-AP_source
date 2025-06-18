class ProgressNotification : Notification {
    const fadeInTime = 0.2;
    const fadeOutTime = 0.2;
    const showTime = 4.0;

    String earnText, topText;
    transient ui Shape2D drawShape;
    transient ui Shape2DTransform shapeTransform;
    transient ui NineSlice bgSlices;

    override void init(string title, string text, string image, int props) {
        Super.init(title, text, image, props);

        earnText = StringTable.Localize("$NOTIFICATION_CREDITS_EARNED");
        topText = StringTable.Localize("$NOTIFICATION_LEVEL_PROGRESS");

        if(hasGasMask) {
            self.title.replace("\c[HI]", "\c[HI3]");
            self.title.replace("\c[OMNIBLUE]", "\c[HI3]");

            self.text.replace("\c[HI]", "\c[HI3]");
            self.text.replace("\c[OMNIBLUE]", "\c[HI3]");

            earnText.replace("\c[HI]", "\c[HI3]");
            earnText.replace("\c[OMNIBLUE]", "\c[HI3]");

            topText.replace("\c[HI]", "\c[HI3]");
            topText.replace("\c[OMNIBLUE]", "\c[HI3]");
        }
    }

    override void update(double time, string title, string text, string image, int props) {
        Super.update(time, title, text, image, props);
    }

    ui void build() {
        makeReady("PRGPADF2");
        makeReady("PRGPADF1");

        bgSlices = NineSlice.Create(hasGasMask ? "PRGPADF2" : "PRGPADF1", (160, 86), (210, 89));

        // Pre-calculate sizes and shit
        // Calculate broken lines
        Font fnt = 'SEL21FONT';
        int fntHeight = fnt.getHeight() + 1;
        double twidth = max(220, ceil(max(fnt.stringWidth(title) * 0.85714, fnt.stringWidth(text) * 0.85714)) + 12 + 24);

        drawShape = new("Shape2D");
        bgSlices.buildShape(drawShape, (0,0), (twidth, 94));
        shapeTransform = new("Shape2DTransform");
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        Super.start(time);
    }

    override bool fastForward(double time) {
        double te = time - startTime;
        if(te < showTime - fadeOutTime) {
            startTime = time + (fadeOutTime / 2.0) - showTime;
        }
        return true;
    }

    /*override void tick(double time) {
        Super.tick(time);
    }*/

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        if(!drawShape || !shapeTransform) {
            build();
        }

        if(!makeTexReady(bgSlices.texture.texID)) return;

        Vector2 pos = (hasGasMask ? (190, -420) : (110,  -330)) + (offset * 0.7);
        
        // If we don't have a bottom line of text, stay lower
        if(props == 0) pos.y += 30;

        double te = time - startTime;
        double tm = 1.0;

        // Determine fade
        if(te < fadeInTime) {
            tm = min(1.0, te / fadeInTime);
            
            // Reposition for slide
            pos += (UIMath.EaseInCubicf(1.0 - tm) * (-130, 0));
        } else {
            double fadeTime = showTime - fadeOutTime;
            if(te >= fadeTime) tm = 1.0 - ((te - fadeTime) / (showTime - fadeTime));

            // Reposition for slide
            pos += (UIMath.EaseInCubicf(1.0 - tm) * (-130, 0));
        }

        Font fnt = 'SEL21FONT';
        double twidth = max(220, ceil(max(fnt.stringWidth(title) * 0.85714, fnt.stringWidth(text) * 0.85714)) + 12 + 24);
        double midwidth = twidth - 160 - 26;
        
        let shapeScale = getVirtualScreenScale();
        let shapePos = pos;
        adjustXY(shapePos.x, shapePos.y, DR_SCREEN_BOTTOM);
        shapeTransform.Clear();
        shapeTransform.Scale(shapeScale);
        shapeTransform.Translate((shapePos.x * shapeScale.x, shapePos.y * shapeScale.y));
        drawShape.SetTransform(shapeTransform);
        Screen.drawShape(
            bgSlices.texture.texID,
            true,
            drawShape,
            DTA_Alpha, alpha * tm,
            DTA_Filtering, true
        );

        //DrawImg("PRGPAD1", pos, DR_SCREEN_BOTTOM, a: tm * alpha);
        //DrawImgAdvanced("PRGPAD2", pos + (160, 0), DR_SCREEN_BOTTOM | DR_SCALE_IS_SIZE, a: tm * alpha, scale: (midwidth, 94));
        //DrawImg("PRGPAD3", pos + (160 + midwidth, 0), DR_SCREEN_BOTTOM, a: tm * alpha);

        DrawStr('SEL16FONT', topText, pos + (12, 3), flags: DR_SCREEN_BOTTOM, a: alpha * tm, monoSpace: false);
        DrawStr('SEL21FONT', title, pos + (12, 32), flags: DR_SCREEN_BOTTOM, a: alpha * tm, monoSpace: false, scale: (0.85714, 0.85714));
        DrawStr('SEL21FONT', text, pos + (12, 56), flags: DR_SCREEN_BOTTOM, a: alpha * tm * 0.9, monoSpace: false, scale: (0.85714, 0.85714) * 0.85);

        if(props > 0) {
            DrawStr('SEL16FONT', String.Format("- %d %s - ", props, earnText), pos + (110, 98), DR_SCREEN_BOTTOM | DR_TEXT_HCENTER, Font.CR_YELLOW, a: alpha * tm * 0.75, monoSpace: false, scale: (0.85, 0.85));
        }
    }
}

class ProgressCompleteNotification : ProgressNotification { }