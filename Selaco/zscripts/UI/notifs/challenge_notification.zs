class ChallengeNotification : Notification {
    int vOffset, xOffset;
    int textOffset;

    transient ui TextureID bgTex[5];
    transient ui TextureID imageTex;
    transient ui bool ready;

    string microText, microTitle;

    bool isMicro, challengeComplete;

    const textLeft = 110;
    const slideOffset = 600;

    const slideTime = 0.4;
    const mainImgTime = 0.2;
    const textFadeInTime = 0.8;
    const textFadeOutTime = 0.2;
    const textFadeOutTimeOffset = 0.6;
    const showTime = double(5.0);
    const endTime1 = showTime - slideTime;
    const fadeImgTime = 0.1;
    const mainEndTime = showTime - fadeImgTime;


    override void init(string title, string text, string image, int props) {
        Super.init(title.MakeUpper(), UIHelper.FilterKeybinds(text), image, props);
        
        // Create text for micro version, removing newlines
        microText = self.text;
        microText.Replace("\n", "   ");

        // Generate 1 line title
        Array<String> titleLines;
        self.title.Split(titleLines, "\n");
        microTitle = titleLines.size() > 0 ? titleLines[0] : self.title;

        if(image != "") {
            TextureID texID = TexMan.CheckForTexture(image, TexMan.Type_Any);
            if(texID.isValid()) {
                let texsize = TexMan.GetScaledSize(texID);
                textOffset = MAX(0, (texsize.x / 2.0) - 57);
            }
        }

        challengeComplete = true;
    }

    override void update(double time, string title, string text, string image, int props) {
        Super.update(time, title, text, image, props);

        // Create text for micro version, removing newlines
        microText = self.text;
        microText.Replace("\n", "   ");

        // Generate 1 line title
        Array<String> titleLines;
        self.title.Split(titleLines, "\n");
        microTitle = titleLines.size() > 0 ? titleLines[0] : self.title;
    }

    override bool fastForward(double time) {
        if(time > endTime1) return true;        // If we are already disappearing, don't do anything
        startTime -= endTime1 - time;           // Shift start time into the past to fast forward
        return true;
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        let evt = TutorialHandler.GetHandler();
        isMicro = evt && evt.isShowing() && evt.getCurrentHeight() > 1;     // Major tutorials don't have a height, so don't go micro for those
        vOffset = isMicro ?  evt.getCurrentHeight() + 35 : 0;

        S_StartSound(challengeComplete ? "ui/challengecompleted" : "ui/challengeUpdated", CHAN_VOICE, CHANF_UI, snd_menuvolume);

        Super.start(time);
    }

    override void tick(double time) {
        let evt = TutorialHandler.GetHandler();
        isMicro = evt && evt.isShowing();
        vOffset = isMicro ?  evt.getCurrentHeight() + 35 : 0;

        ticks++;
    }

    ui void build() {
        for(int x = 0; x < bgTex.size(); x++) {
            bgTex[x] = TexMan.CheckForTexture(String.Format("ACH_BG%d", x));
        }
        imageTex = TexMan.CheckForTexture(image);
    }

    ui bool isReady() {
        if(ready) return true;

        bool isReady = true;
        for(int x = bgTex.size() - 1; x >= 0; x--) {
            if(!makeTexReady(bgTex[x]))
                isReady = false;
        }

        return isReady;
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = (100 + xOffset, 80 + vOffset) + offset;
        Font titleFnt = "TITLEA";
        Font textFnt = "SELOFONT";

        double te = time - startTime;

        if(!bgTex[0].isValid()) build();
        if(!isReady()) return;
        ready = true;

        // Draw normal
        if(!isMicro) {
            // Clip slider so it doesn't draw behind the logo
            Clip(pos.x + 50, pos.y - 120, 1000, 240);

            // Draw background
            if(te < slideTime) {
                float tm = UIMath.EaseInCubicf(1.0 - (te / slideTime));
                DrawTexAdvanced(bgTex[1], pos - (slideOffset * tm, 0), a: alpha, desaturate: hasGasMask ? 255 : 0, color: hasGasMask ? 0xFF00D786 : 0xFFFFFFFF);
            } else if(te > showTime - slideTime) {
                float tm = UIMath.EaseOutCubicf(abs(endTime1 - te) / slideTime);
                DrawTexAdvanced(bgTex[1], pos - (slideOffset * tm, 0), a: alpha, desaturate: hasGasMask ? 255 : 0, color: hasGasMask ? 0xFF00D786 : 0xFFFFFFFF);
            } else {
                DrawTexAdvanced(bgTex[1], pos, a: alpha, desaturate: hasGasMask ? 255 : 0, color: hasGasMask ? 0xFF00D786 : 0xFFFFFFFF);
            }

            ClearClip();

            double imga = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / fadeImgTime);
            double sca = challengeComplete ? (te >= mainImgTime ? 0.0 : (1.0 - (te / mainImgTime)) * 2.5) : 0.0;

            // Draw icon background
            DrawTexAdvanced(bgTex[2], pos, a: alpha * imga, desaturate: hasGasMask ? 255 : 0, color: hasGasMask ? 0xFF00D786 : 0xFFFFFFFF);

            // Draw images
            if(image != "") {
                Vector2 imagePos = pos + (49, 49), imgScale = (sca + 1, sca + 1);
                DrawTexAdvanced(bgTex[4], imagePos, flags: DR_NO_SPRITE_OFFSET | DR_IMG_CENTER, a: alpha * imga, scale: imgScale);
                DrawTexAdvanced(imageTex, imagePos, flags: DR_NO_SPRITE_OFFSET | DR_IMG_CENTER | DR_WAIT_READY, a: alpha * imga, scale: imgScale);
            }

            double textTm;
            if(te > showTime - (textFadeOutTime + textFadeOutTimeOffset)) {
                textTm = 1.0 - (abs(showTime - textFadeOutTime - textFadeOutTimeOffset - te) / textFadeOutTime);
            } else {
                textTm = te / textFadeInTime;
            }

            // Draw Text
            DrawStr(titleFnt, title, pos + (textLeft + textOffset, 5), a: alpha * textTm, monoSpace: false, linespacing: 1);
            DrawStr(textFnt, text, pos + (textLeft + textOffset, 52), a: alpha * textTm, monoSpace: false, linespacing: 3);

        } else {    // Draw micro version, because a tutorial is up
            Clip(pos.x + 26, pos.y - 120, 1000, 240);
            int tleft = textLeft / 2 + 3;
            int textWidth = MAX(textFnt.StringWidth(microTitle),  textFnt.StringWidth(microText));
            double textSlideOffset = 500 - (textWidth + tleft + 33);

            // Draw background
            if(te < slideTime) {
                float tm = UIMath.EaseInCubicf(1.0 - (te / slideTime));
                DrawTexAdvanced(bgTex[0], pos - (textSlideOffset + (600 * tm), 0), a: alpha, desaturate: hasGasMask ? 255 : 0, color: hasGasMask ? 0xFF00D786 : 0xFFFFFFFF);
            } else if(te > showTime - slideTime) {
                float tm = UIMath.EaseOutCubicf(abs(endTime1 - te) / slideTime);
                DrawTexAdvanced(bgTex[0], pos - (textSlideOffset + (600 * tm), 0), a: alpha, desaturate: hasGasMask ? 255 : 0, color: hasGasMask ? 0xFF00D786 : 0xFFFFFFFF);
            } else {
                DrawTexAdvanced(bgTex[0], pos - (textSlideOffset, 0), a: alpha, desaturate: hasGasMask ? 255 : 0, color: hasGasMask ? 0xFF00D786 : 0xFFFFFFFF);
            }
            
            ClearClip();

            double imga = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);
            double sca = challengeComplete ? (te >= mainImgTime ? 0.0 : (1.0 - (te / mainImgTime)) * 2.5) * 0.5 : 0.0;

            // Draw icon background
            DrawTexAdvanced(bgTex[3], pos, a: alpha);

            // Draw image
            if(image != "") { 
                Vector2 imgPos = pos + (25, 25), imgScale = (sca + 0.5, sca + 0.5);
                DrawTexAdvanced(bgTex[4], imgPos, flags: DR_NO_SPRITE_OFFSET | DR_IMG_CENTER, a: alpha * imga, scale: imgScale); 
                DrawTexAdvanced(imageTex, imgPos, flags: DR_NO_SPRITE_OFFSET | DR_IMG_CENTER, a: alpha * imga, scale: imgScale); 
            }

            double textTm;
            if(te > showTime - (textFadeOutTime + textFadeOutTimeOffset)) {
                textTm = 1.0 - (abs(showTime - textFadeOutTime - textFadeOutTimeOffset - te) / textFadeOutTime);
            } else {
                textTm = te / textFadeInTime;
            }

            // Draw Text
            //DrawStr(titleFnt, title, pos + (textLeft + textOffset, 12), translation: titleColor, a: alpha * textTm, monoSpace: false);
            DrawStr(textFnt, microTitle, pos + (tleft + textOffset, 3), a: alpha * textTm, monoSpace: false);
            DrawStr(textFnt, microText, pos + (tleft + textOffset, 25), a: alpha * textTm, monoSpace: false);
        }
    }
}

class ChallengeProgressNotification : ChallengeNotification {
    override void init(string title, string text, string image, int props) {
        Super.init(title, text, image, props);

        challengeComplete = false;
    }
}

class ChallengeMedalNotification : Notification {
    transient ui TextureID bg2, bg4, prog7, prog8, texImg;

    const showTime = double(2.0);
    const fadeImgTime = 0.1;
    const mainEndTime = showTime - fadeImgTime;
    const mainImgTime = 0.16;

    const progBarWidth = 100;
    const halfProgBarWidth = progBarWidth / 2;
    const goldColor = 0xFFFBC200;

    bool playSound;
    int lowVal, highVal;

    ui void getTextures() {
        bg2 = TexMan.CheckForTexture("ACH_BG2");
        bg4 = TexMan.CheckForTexture("ACH_BG4");
        prog7 = TexMan.CheckForTexture("PADPROG7");
        prog8 = TexMan.CheckForTexture("PADPROG8");
    }

    override bool fastForward(double time) {
        if(time > mainEndTime) return true;     // If we are already disappearing, don't do anything
        startTime -= mainEndTime - time;        // Shift start time into the past to fast forward
        return true;
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        if(playSound) S_StartSound("ui/challengeUpdated", CHAN_VOICE, CHANF_UI, snd_menuvolume);

        Super.start(time);
    }

    override void tick(double time) {
        ticks++;
    }

    // Special case, just reset this here
    override void update(double time, string title, string text, string image, int props) {
        if(title != "|") self.title = title;
        ticks = 0;
        startTime = time;
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = (0, 170) + offset;
        double te = time - startTime;

        double imga = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / fadeImgTime);
        double sca = te >= mainImgTime ? 0.0 : (1.0 - (te / mainImgTime)) * 1.7;

        if(!bg2.isValid()) getTextures();
        if(image != "" && !texImg.isValid()) texImg = TexMan.CheckForTexture(image);


        if(!(TexMan.MakeReady(bg2) && TexMan.MakeReady(bg4) && TexMan.MakeReady(prog7) && TexMan.MakeReady(prog8))) return;

        // Draw icon background
        DrawTexAdvanced(bg2, pos, flags: DR_NO_SPRITE_OFFSET | DR_IMG_CENTER | DR_SCREEN_HCENTER, a: alpha * imga, desaturate: hasGasMask ? 255 : 0, color: hasGasMask ? 0xFF00D786 : 0xFFFFFFFF);

        if(image != "") { 
            DrawTexAdvanced(bg4, pos, flags: DR_NO_SPRITE_OFFSET | DR_IMG_CENTER | DR_SCREEN_HCENTER, a: alpha * imga, scale: (sca + 1, sca + 1));
            DrawTexAdvanced(texImg, pos, flags: DR_NO_SPRITE_OFFSET | DR_IMG_CENTER | DR_SCREEN_HCENTER | DR_WAIT_READY, a: alpha * imga, scale: (sca + 1, sca + 1));
        }

        // Text
        DrawStr('SELOFONT', title, pos + (0, 57), flags: DR_TEXT_HCENTER | DR_SCREEN_HCENTER, a: alpha * imga, monoSpace: false, scale: (0.92, 1));

        // Don't draw progress if we don't have numbers set
        if(highVal == 0) { return; }

        // Draw progress bar
        bool complete = lowVal == highVal;
        Font mfont = 'SELOFONT';
        string progTxt = String.Format("%d/%d", lowVal, highVal);
        int tWidth = mfont.stringWidth(progTxt) * 0.87;
        int center = -((tWidth + 8 + progBarWidth) / 2.0);
        float prog = float(lowVal) / float(highVal);
        Vector2 progPos = pos + (center + tWidth + 8, 87);

        // Progress text 
        DrawStr(mfont, progTxt, pos + (center, 81), flags: DR_SCREEN_HCENTER, translation: complete ? goldColor : 0xFFEEEEEE, a: alpha * imga, monoSpace: false, scale: (0.87, 0.87));

        // Bar background
        if(!complete) DrawTex(prog7, progPos - (4,4), DR_SCREEN_HCENTER, a: alpha * imga);

        // Clipped progress bar
        Clip(progPos.x, 0, MAX(5, float(progBarWidth) * prog), virtualScreenSize.y, DR_SCREEN_HCENTER);
        DrawTexCol(prog8, progPos, complete ? goldColor : 0xFFFFFFFF, DR_SCREEN_HCENTER, a: alpha * imga);
        Screen.ClearClipRect();
    }
}