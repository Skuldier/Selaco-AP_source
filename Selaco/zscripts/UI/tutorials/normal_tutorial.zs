class NormalTutorialPopup : TutorialPopup {
    const textAreaTop = 45;
    const textAreaLeft = 15;
    const titleHeight = 34;
    const tutWidth = 615;

    transient BrokenLines printLines;
    transient Vector2 imagePos;
    transient NineSlice bgSlices;
    transient Shape2D drawShape;
    transient Shape2DTransform shapeTransform;

    transient int textAreaHeight;
    transient int tutHeight;
    
    override void Init(TutorialInfo tut) {
        Super.Init(tut);
    }

    override void build() {
        bgSlices = NineSlice.Create(hasGasMask ? "PANTUTGM" : "PANTUT", (300, 60), (560, 180));

        Vector2 tsize = TexMan.GetScaledSize(info.image);

        // Pre-calculate sizes and shit
        // Calculate broken lines
        Font fnt = "PDA16FONT";
        int fntHeight = fnt.getHeight() + 1;

        // Do necessary text replacement
        // Find keybinds in the format of $<+use>$
        text = UIHelper.FilterKeybinds(info.txt);
        if(hasGasMask) {
            text.replace("\c[HI]", "\c[HI3]");
            text.replace("\c[OMNIBLUE]", "\c[HI3]");
        }

        // Precalculate text sizes
        printLines = fnt.breakLines(text, (tutWidth - tsize.x - (15 * 2)) / textScale);

        int fullTextHeight = fntHeight * textScale * (printlines ? printLines.count() : 1);
        textAreaHeight = fullTextHeight + 20;
        tutHeight = 35 + 8 + MAX(textAreaHeight + 5, tsize.y + 5);

        // Calc image pos
        if(info.image.isValid()) {
            imagePos = (
                tutWidth - tsize.x - 10,
                30// + round((tutHeight / 2) - (tsize.y / 2))
            );
        }

        drawShape = new("Shape2D");
        bgSlices.buildShape(drawShape, (0,0), (tutWidth, tutHeight));
        shapeTransform = new("Shape2DTransform");
    }

    override double getHeight() {
        return tutHeight + 20;//236 + 20;
    }

    override double getWidth() {
        return tutWidth;
    }


    override void Draw(string kbText, bool closing, double time) {
        float tm = MIN(time / 0.3, 1.0);
        if(closing) {
            tm = 1.0 - tm;
        }

        float alpha = closing ? UIMath.EaseInXYA(0.0, 1.0, tm) : UIMath.EaseOutXYA(0.0, 1.0, tm);
        Vector2 pos = (
            UIMath.EaseOutXYA(0.0, 100.0, tm),
            80
        );

        // Draw BG
        if(!drawShape || !printLines) {
            build();
        }

        if(!makeTexReady(bgSlices.texture.texID)) {
            makeTexReady(info.image);
        }

        let shapePos = pos;
        adjustXY(shapePos.x, shapePos.y, 0);
        let shapeScale = getVirtualScreenScale();
        shapeTransform.Clear();
        shapeTransform.Scale(shapeScale);
        shapeTransform.Translate((shapePos.x * shapeScale.x, shapePos.y * shapeScale.y));
        drawShape.SetTransform(shapeTransform);
        Screen.drawShape(
            bgSlices.texture.texID,
            true,
            drawShape,
            DTA_Alpha, alpha,
            DTA_Filtering, true
        );

        Font fnt = "PDA16FONT";
        int fntHeight = fnt.getHeight() + 1;

        // Draw each line of text
        if(printLines) {
            int fntHeight = fnt.getHeight() + 1;

            for(int x = 0; x < printLines.count(); x++) {
                string line = printLines.stringAt(x);
                int y = (fntHeight * textScale) * x;

                DrawStr(fnt, line, pos + (textAreaLeft, textAreaTop + y), a: alpha, monoSpace: false);
            }
        }

        // Draw header text if set
        if(info.header != "") {
            Font titleFnt = 'SEL21FONT';
            float y = (titleHeight / 2.0) - ((titleFnt.getHeight() * textScale) / 2.0);

            DrawStr(titleFnt, info.header, pos + (15, y), a: alpha, monoSpace: false);
        }


        if(kbText != "" && tm > 0.9) {
            float tm2 = MIN((time - 0.3) / 0.4, 1.0);
            DrawStr('SELOFONT', kbText, pos + (10, tutHeight + 5), a: UIMath.EaseOutXYA(0.0, 1.0, tm2), monoSpace: false);
        }

        // Draw image if there is one
        if(makeTexReady(info.image)) DrawTexAdvanced(info.image, pos + imagePos, a: alpha, desaturate: 255);
    }
}