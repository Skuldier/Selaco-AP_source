class InvasionNotification : Notification {
    const goldColor = 0xFFFBC200;

    int titleColor;
    string statusText, statusText2;

    const slideTime1 = 0.3;
    const slideTime2 = 0.5;
    const mainImgTime = 0.2;
    const textFadeInTime = 0.6;
    const textFadeOutTime = 0.2;
    const textFadeOutTimeOffset = 0.5;
    const showTime = double(7.0);
    const endTime1 = showTime - slideTime1;
    const endTime2 = showTime - slidetime2;
    const mainEndTime = showTime - mainImgTime;

    double imgAlphaCnt, imgAlpha, toff;

    ui Shape2D drawShape;
    ui Shape2DTransform shapeTransform;
    ui NineSlice bgSlices;
    ui float mainHeight, mainWidth;


    override void init(string title, string text, string image, int props) {
        Super.init(title, UIHelper.FilterKeybinds(text, shortMode: true), image, props);

        toff = frandom(0, 100);
        titleColor = 0xFFC60000;
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void tick(double time) {
        Super.tick(time);

        imgAlphaCnt = MIN(0.9, imgAlphaCnt + 0.1);
        imgAlpha = frandom(imgAlphaCnt, 1.0);
    }

    /*override void update(double time, string title, string text, string image, int props) {
        Super.update(time, title, text, image, props);
    }*/

    override void start(double time) {
        Super.start(time);

        S_StartSound ("ui/openTutorialInvasion", CHAN_VOICE, CHANF_UI, snd_menuvolume);
    }

    ui void build() {
        makeReady("INVMINPO");
        bgSlices = NineSlice.Create("INVMINPO", (56, 56), (364, 126));

        // Pre-calculate sizes and shit
        // Calculate broken lines
        Font fnt = 'SEL21FONT';
        int fntHeight = fnt.getHeight() + 1;
        mainHeight = 220;
        mainWidth = max(420, fnt.stringWidth(title) + 118);

        fnt = 'PDA16FONT';
        fntHeight = fnt.getHeight() + 1;

        BrokenLines lines = fnt.BreakLines(text, mainWidth - 40);
        mainHeight = max(100, lines.count() * fntHeight + 75);

        drawShape = new("Shape2D");
        bgSlices.buildShape(drawShape, (0,0), (mainWidth, mainHeight));
        shapeTransform = new("Shape2DTransform");
    }

    ui double adjustBG(double tm) {
        drawShape.clear();
        double bgHeight = 75 + double(mainHeight - 75) * tm;
        bgSlices.buildShape(drawShape, (0,0), (mainWidth, bgHeight));
        return bgHeight;
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = (hasGasMask ? (190, -380 - round(mainHeight)) : (110, -360 - round(mainHeight))) + (offset * 0.7);
        Font titleFnt = "SEL21FONT";
        Font textFnt = "PDA16FONT";

        double te = time - startTime;
        double imga = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);
        
        double mtm = te < slideTime1 ? UIMath.EaseInCubicf(te / slideTime1) :
                     (te > showTime - slideTime2 ? UIMath.EaseInOutCubicf(1.0 - abs(endTime2 - te) / slideTime1) : 1.0);
        
        if(drawShape == null) build();
        double bgHeight = adjustBG(mtm);

        if(!makeTexReady(bgSlices.texture.texID)) return;

        pos.y += round((mainHeight - bgHeight) / 2.0);

        let shapeScale = getVirtualScreenScale();
        let shapePos = pos;
        adjustXY(shapePos.x, shapePos.y, 0);
        shapeTransform.Clear();
        shapeTransform.Scale(shapeScale);
        shapeTransform.Translate((shapePos.x * shapeScale.x, screenSize.y + (shapePos.y * shapeScale.y)));
        drawShape.SetTransform(shapeTransform);
        Screen.drawShape(
            bgSlices.texture.texID,
            true,
            drawShape,
            DTA_Alpha, alpha * mtm,
            DTA_Filtering, true
        );

        // Draw Text
        double textTm;
        if(te > showTime - (textFadeOutTime + textFadeOutTimeOffset)) {
            textTm = 1.0 - (abs(showTime - textFadeOutTime - textFadeOutTimeOffset - te) / textFadeOutTime);
        } else {
            textTm = te / textFadeInTime;
        }

        let hmainWidth = round(mainWidth / 2.0);
        DrawStr(titleFnt, title, pos + (hmainWidth, 14), DR_SCREEN_BOTTOM | DR_TEXT_HCENTER, /*titleColor,*/ a: alpha * textTm, monoSpace: false);
        
        Clip(0, pos.y + 55, 1000, bgHeight - 55 - 15, DR_SCREEN_BOTTOM);

        DrawStrMultiline(textFnt, text, pos + (20, 58), mainWidth - 40, DR_SCREEN_BOTTOM, titleColor, a: alpha * textTm);
        //DrawStr(textFnt, statusText, pos + (textLeft - slide2x + 300, 49), DR_SCREEN_BOTTOM | DR_TEXT_RIGHT, a: alpha * textTm, monoSpace: false, scale: (1, 1));
        
        Screen.ClearClipRect();
    }
}