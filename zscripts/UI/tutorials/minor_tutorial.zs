class MinorTutorialPopup : TutorialPopup {
    
    const textAreaTop = 36;
    const textAreaLeft = 15;
    const titleHeight = 34;
    
    transient BrokenLines printLines;
    transient Vector2 imagePos;
    transient TextureID backgroundImage;
    transient NineSlice bgSlices;
    transient Shape2D drawShape;
    transient Shape2DTransform shapeTransform;
    transient int textAreaHeight;
    transient int tutHeight;

    const tutWidth = 580;
    //const tutHeight = 90;


    override void Init(TutorialInfo tut) {
        Super.Init(tut);
    }

    override void build() {
        Font fnt = "PDA16FONT";
        
        int fntHeight = fnt.getHeight() + 1;
        
        backgroundImage = TexMan.CheckForTexture(hasGasMask ? "PANTUT2G" : "PANTUT2", TexMan.Type_Any);
        bgSlices = NineSlice.Create(hasGasMask ? "PANTUT2G" : "PANTUT2", (297, 38), (463, 93));

        // Pre-calculate sizes and shit
        // Calculate broken lines
        // Do necessary text replacement
        // Find keybinds in the format of $<+use>$
        text = UIHelper.FilterKeybinds(info.txt);
        if(hasGasMask) {
            text.replace("\c[HI]", "\c[HI3]");
            text.replace("\c[OMNIBLUE]", "\c[HI3]");
        }

        Vector2 tsize = TexMan.GetScaledSize(info.image);

        // Precalculate text sizes
        printLines = fnt.breakLines(text, (tutWidth - tsize.x - (15 * 2)) / textScale);

        int fullTextHeight = fntHeight * textScale * (printlines ? printLines.count() : 1);
        textAreaHeight = fullTextHeight + 20;
        
        // Calc image pos
        if(info.image.isValid()) {
            imagePos = (
                tutWidth - tsize.x - 10,
                20 + round((tutHeight / 2) - (tsize.y / 2))
            );
        }

        tutHeight = 35 + 8 + textAreaHeight + 2;

        drawShape = new("Shape2D");
        bgSlices.buildShape(drawShape, (0,0), (tutWidth, tutHeight));
        shapeTransform = new("Shape2DTransform");      
    }

    override double getHeight() {
        return tutHeight + 23;
    }

    override double getWidth() {
        return tutWidth;
    }

    override void Draw(string kbText, bool closing, double time) {
        let scale = (1.0, 1.0);
        Font fnt = 'PDA16FONT';

        int fntHeight = fnt.getHeight() + 1;
        int screenWidth = Screen.GetWidth();
		int screenHeight = Screen.GetHeight();
        
        float tm = MIN(time / 0.3, 1.0);
        if(closing) {
            tm = 1.0 - tm;
        }

        float alpha = closing ? UIMath.EaseInXYA(0.0, 1.0, tm) : UIMath.EaseOutXYA(0.0, 1.0, tm);
        Vector2 pos = (
            UIMath.EaseOutXYA(0.0, 100.0, tm),
            80
        );

        if(!drawShape || !printLines) {
            build();
        }

        if(!makeTexReady(bgSlices.texture.texID)) {
            makeTexReady(info.image);
        }

        // Draw BG
        let shapePos = pos;
        adjustXY(shapePos.x, shapePos.y, 0);
        let shapeScale = getVirtualScreenScale();//(virtualScreenSize.x / screenSize.x, virtualScreenSize.y / screenSize.y);
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

        let tScale = textScale * scale;

        // Draw each line of text
        if(printLines) {
            float fullHeight = fntHeight * textScale * printLines.count();
            float startY = (textAreaHeight / 2.0) - (fullHeight / 2.0);

            for(int x = 0; x < printLines.count(); x++) {
                string line = printLines.stringAt(x);
                float y = ((fntHeight * textScale) * x) + startY;

                DrawStr(fnt, line, pos + (textAreaLeft, textAreaTop + y), a: alpha, monospace: false);
            }
        }

        // Draw header text if set
        if(info.header != "") {
            Font titleFnt = "SEL21FONT";
            int offset = 15;
            float y = (titleHeight / 2.0) - ((titleFnt.getHeight() * textScale) / 2.0);

            DrawStr(titleFnt, info.header, pos + (15, y), a: alpha, monospace: false);
        }

         if(kbText != "" && tm > 0.9) {
            float tm2 = MIN((time - 0.3) / 0.4, 1.0);
            int yOff = tutHeight + 3;

            DrawStr('SELOFONT', kbText, pos + (10, yOff), a: UIMath.EaseOutXYA(0.0, 1.0, tm2), monoSpace: false);
        }

        // Draw image if there is one
        if(makeTexReady(info.image)) DrawTexAdvanced(info.image, pos + imagePos, a: alpha, desaturate: 255);
    }

}