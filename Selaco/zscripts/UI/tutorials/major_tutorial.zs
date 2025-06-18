class TutorialPopup {
    mixin UIDrawer;
    mixin HudDrawer;

    TutorialInfo info;
    string text;
    TutMsgType msgType;

    bool hasGasMask;

    const textScale = 1.0;
    const imageScale = 1.0;
    const centerHeader = 0;

    virtual void Init(TutorialInfo tut) {
        info = tut;
        checkForGasMask();
        
        build();
    }

    void checkForGasMask() {
        hasGasMask = players[consolePlayer].mo.FindInventory("GasMask");
    }

    ui virtual void Tick(uint ticks) {
        if(ticks == 0) { calcScreenScale(screenSize, virtualScreenSize, screenInsets); }
    }

    virtual double getHeight() {
        return 0;
    }

    virtual double getWidth() {
        return 0;
    }

    // Called at init, but also called when the level changes or a savegame is loaded
    virtual void build() {
        
    }

    ui virtual void Draw(string kbText, bool closing, double time) { }
}


class MajorTutorialPopup : TutorialPopup {
    TextureID topTex, midTex, botTex, fadeTex, warningTex;
    Vector2 topSize, midSize, botSize, imageSize, warningSize;

    int height;
    const messageTime = 1.2;

    override void Init(TutorialInfo tut) {
        Super.Init(tut);

        topTex = TexMan.CheckForTexture("TUTMTOP", Texman.Type_Any);
        midTex = TexMan.CheckForTexture("TUTMMID", Texman.Type_Any);
        botTex = TexMan.CheckForTexture("TUTMBOT", Texman.Type_Any);
        fadeTex = TexMan.CheckForTexture("TUTMBG2", Texman.Type_Any);

        warningTex = TexMan.CheckForTexture("TUTMWARN", Texman.Type_Any);

        topSize = TexMan.GetScaledSize(topTex);
        midSize = TexMan.GetScaledSize(midTex);
        botSize = TexMan.GetScaledSize(botTex);

        warningSize = TexMan.GetScaledSize(warningTex);

        imageSize = TexMan.GetScaledSize(info.image);

        height = 650;
    }

    override void Draw(string kbText, bool closing, double time) {
        let scale = (1.0, 1.0);

        int screenWidth = Screen.GetWidth();
		int screenHeight = Screen.GetHeight();
        float halfScreenWidth = screenWidth / 2.0;
        float halfScreenHeight = screenHeight / 2.0;
        float heightS = height * scale.y;

        float vScreenWidth = screenWidth / scale.x;
        float vScreenHeight = screenHeight / scale.x;

        Vector2 topSizeS = (topSize.x * scale.x, topSize.y * scale.y);

        // Draw warning before the actual window comes up
        if(!closing && time < messageTime) {
            Font f = "SELOFONT";//TutorialHandler.titleFonts[info.msgType];
            float tm2 = MIN(time / 0.3, 1.0);

            string txt = "INCOMING MESSAGE...";
            string txt2 = txt.mid(0, ceil(tm2 * txt.length()));
            
            DrawStr(f, txt2, (0, -90), flags: DR_TEXT_HCENTER | DR_SCREEN_CENTER, a: tm2, monoSpace: false);
            return;
        }
    }
}


class MajorTutorialMenu : GenericMenu {
    mixin UIDrawer;
    mixin HudDrawer;
    mixin CVARBuddy;
    mixin UIInputHandlerAccess;

    const alpha = 1.0;
    const DEFAULT_HEIGHT = 731;
    const tutWidth = 640;

    int height;

    int buttOffset;
    int headerTop;
    int imageOffset;
    
    int ticks;

    uint startTime;
    string text;
    int headerWidth;
    TutorialInfo info;
    TextureID topTex, midTex, botTex, fadeTex, warningTex, buttTex, buttTex2, buttTex3;
    Vector2 topSize, midSize, botSize, imageSize, warningSize, buttSize;
    Vector2 scale;
    Array<int> backKeys, rawBackKeys;
    int back1, back2;
    FixedBrokenLines printLines;

    int buttTextColor, headerTextColor, textColor;

    string kbText, closeText;
    bool closing;

    bool buttHover, mouseDown, showingMouse;

    Font textFont, titleFont;

    static const string buttTitles[] = {
        "Okay",
        "Close",
        "Understood",
        "Acknowledged",
        "Got It",
        "Continue"
    };

    double getRenderTime() {
		return (System.GetTimeFrac() + double(ticks - startTime)) * ITICKRATE;
	}

    override void Init(Menu parent) {
        mParentMenu = parent;

        calcScreenScale(screenSize, virtualScreenSize, screenInsets);
        // Limit screen scale to fit notifications

        
        DontBlur = false;
        DontDim = true;
        Animated = true;                // Thank the gods! Or the dogs. Depending on who you worship. I don't judge.
        ReceiveAllInputEvents = true;   // Receive everything so we can get gamepad inputs to close the menu
        menuactive = Menu.On;  
        SetMouseCapture(true);
        startTime = 0;
        closeText = buttTitles[random(0, 5)];

        // Get Keybinds
        Array<int> tempKeybinds;
        Bindings.GetAllKeysForCommand(rawBackKeys, "+use");
        Bindings.GetAllKeysForCommand(tempKeybinds, "+usereload");
        rawBackKeys.append(tempKeybinds);

        [back1, back2] = Bindings.GetKeysForCommand("+use");
        back1 = UIHelper.GetUIKey(back1);
        back2 = UIHelper.GetUIKey(back2);
        for(int x =0; x < rawBackKeys.size(); x++) {
            backKeys.push(UIHelper.GetUIKey(rawBackKeys[x]));
        }

        // Get event handler
        TutorialHandler handler = TutorialHandler.GetHandler();

        if(!handler || !handler.currentTut || !handler.currentTut.info) {
            Close();
        } else {
            // Get tutorial info from the active tutorial
            info = handler.currentTut.info;

            getTextures();

            kbText = handler.kbText;

            scale = getVirtualScreenScale();

            text = UIHelper.FilterKeybinds(info.txt);

            // Precalculate text sizes
            BrokenLines br = textFont.breakLines(text, tutWidth - (25 * 2));
            printLines = new("FixedBrokenLines");
            printLines.FromBrokenLines(br);

            headerWidth = titleFont.StringWidth(info.header);

            int fntHeight = textFont.getHeight() + 1;
            height = (fntHeight * printLines.count()) + imageSize.y + 60 + 190;
        }

        if(!isUsingGamepad()) {
            Screen.SetCursor("MOUSE");
            showingMouse = true;
        } else {
            Screen.SetCursor("NOTACRSR");
        }

        // Make sure virtual screen can fit the entire dialog
        if(virtualScreenSize.y < height + 100) {
            virtualScreenSize *= (height + 100) / virtualScreenSize.y;
        }
    }

    virtual void getTextures() {
        textFont = "PDA18FONT";
        titleFont = "SEL21FONT";
        topTex = TexMan.CheckForTexture("TUTMTOP", Texman.Type_Any);
        midTex = TexMan.CheckForTexture("TUTMMID", Texman.Type_Any);
        botTex = TexMan.CheckForTexture("TUTMBOT", Texman.Type_Any);
        fadeTex = TexMan.CheckForTexture("TUTMBG2", Texman.Type_Any);
        buttTex = TexMan.CheckForTexture("TUTBUTT", Texman.Type_Any);
        buttTex2 = TexMan.CheckForTexture("TUTBUTT2", Texman.Type_Any);
        buttTex3 = TexMan.CheckForTexture("TUTBUTT3", Texman.Type_Any);

        warningTex = TexMan.CheckForTexture("TUTMWARN", Texman.Type_Any);

        topSize = TexMan.GetScaledSize(topTex);
        midSize = TexMan.GetScaledSize(midTex);
        botSize = TexMan.GetScaledSize(botTex);
        
        buttSize = TexMan.GetScaledSize(buttTex);

        warningSize = TexMan.GetScaledSize(warningTex);

        imageSize = TexMan.GetScaledSize(info.image);

        buttTextColor = headerTextColor = textColor = 0xFFFFFFFF;

        buttOffset = 34;
        headerTop = 4;
    }

    virtual void CleanClose() {
        closing = true;
        startTime = ticks;
        S_StartSound ("ui/closeTutorialBig", CHAN_VOICE, CHANF_UI, snd_menuvolume);
    }

    override bool menuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_Back) {
            if(!closing && ticks - startTime > 30) {
                CleanClose();
            }

            return true;
        }
        return Super.menuEvent(mkey, fromcontroller);
    }

    override bool onUIEvent(UIEvent ev) {
        if(!showingMouse && (ev.type == UIEvent.Type_MouseMove || ev.type == UIEvent.Type_LButtonDown)) {
            showingMouse = true;
            Screen.SetCursor("MOUSE");
        }

        if(ev.type == UIEvent.Type_KeyDown) {
            if(!closing && ticks - startTime > 30) {
                for(int x = 0; x < backKeys.size(); x++) {
                    if(ev.KeyChar == backKeys[x]) {
                        CleanClose();
                        return true;
                    }
                }

                if(ev.KeyChar == back1 || ev.KeyChar == back2 || ev.KeyChar == UIEvent.Key_Escape || ev.KeyChar == UIEvent.Key_Back) {
                    CleanClose();
                    return true;
                }
            }
        } else if(!closing && (ev.type == UIEvent.Type_MouseMove || ev.type == UIEvent.Type_LButtonDown || ev.type == UIEvent.Type_LButtonUp)) {
            int screenWidth = Screen.GetWidth();
            int screenHeight = Screen.GetHeight();
            float halfScreenWidth = screenWidth / 2.0;
            float midHeight = (height * scale.y) - (topSize.y * scale.y) - (botSize.y * scale.y);
            float py = (screenHeight / 2.0) + floor((midHeight + (topSize.y * scale.y) + (botSize.y * scale.y)) / 2.0);

            bool mouseUp = !mouseDown;

            if(ev.type == UIEvent.Type_LButtonDown) {
                mouseDown = true;
            } else if(ev.type == UIEvent.Type_LButtonUp) {
                mouseDown = false;
            }

            mouseUp = !mouseDown && !mouseUp;
            
            // Check for mouse pos over the button
            // We are doing this manually because there is no need for the overhead of a framework for something as simple as a single button
            let buttPos = (round(halfScreenWidth - ((buttSize.x * scale.x) / 2.0)), floor(py - ((buttSize.y + buttOffset) * scale.y)));
            let bsize = (buttSize.x * scale.x, buttSize.y * scale.y);
            if( ev.mouseX > buttPos.x && ev.mouseX < buttPos.x + bsize.x &&
                ev.mouseY > buttPos.y && ev.mouseY < buttPos.y + bsize.y) {

                if(ev.type == UIEvent.Type_MouseMove) {
                    if(!buttHover) S_StartSound ("ui/hoverTutorialBig", CHAN_VOICE, CHANF_UI, snd_menuvolume);
                    buttHover = true;
                } else if(mouseUp) {
                    CleanClose();
                }
            } else {
                buttHover = false;
            }
        }

		return Super.onUIEvent(ev);
	}

    // Check for back key. Needed for gamepad input sometimes
    override bool OnInputEvent(InputEvent ev) { 
		if(ev.type == InputEvent.Type_KeyDown && !closing && ticks - startTime > 30) {
            for(int x = 0; x < rawBackKeys.size(); x++) {
                if(ev.KeyScan == rawBackKeys[x]) {
                    CleanClose();
                    return true;
                }
            }
        }

        return Super.OnInputEvent(ev);
	}

    override void Ticker() {
        if(closing && ticks - startTime > 11) {
            Close();
        }

        ticks++;
    }

    override void Drawer() {
        if(!info) {return;}
        Animated = true;

        int screenWidth = Screen.GetWidth();
		int screenHeight = Screen.GetHeight();
        float halfScreenWidth = screenWidth / 2.0;
        float halfScreenHeight = screenHeight / 2.0;
        float heightS = height * scale.y;

        float vScreenWidth = screenWidth / scale.x;
        float vScreenHeight = screenHeight / scale.x;

        Vector2 topSizeS = (topSize.x * scale.x, topSize.y * scale.y);

        double te = getRenderTime();
        float tm = MIN(te / 0.3, 1.0);

        if(closing) {
            tm = 1.0 - tm;
        }

        float alpha = (closing ? UIMath.EaseInXYA(0.0, 1.0, tm) : UIMath.EaseOutXYA(0.0, 1.0, tm)) * alpha;
        float midHeight = UIMath.EaseOutXYA(0, heightS - topSizeS.y - (botSize.y * scale.y), tm);

        Vector2 pos = (
            screenWidth / 2.0,
            screenHeight / 2.0
        );
        pos -= (floor(topSize.x / 2.0) * scale.x, floor((midHeight + topSizeS.y + (botSize.y * scale.y)) / 2.0));

        float bottom = pos.y + topSizeS.y + midHeight + (botSize.y * scale.y);

        // Set blur amount
        BlurAmount = CLAMP((tm * 0.4) + 0.6, 0.6, 1);

        // Draw Fade BG
        Screen.DrawTexture(fadeTex, false, 0, 0,
            DTA_Alpha, alpha * tm * 1.25,
            DTA_DestWidth, screenWidth,
            DTA_DestHeight, screenHeight,
            DTA_Filtering, true
        );

        // Draw BG top
        Screen.DrawTexture(topTex, false, pos.x, pos.y,
            DTA_Alpha, alpha,
            DTA_DestWidthF, topSizeS.x,
            DTA_DestHeightF, topSizeS.y,
            DTA_Filtering, true
        );

        // Mid
        Screen.DrawTexture(midTex, false,  pos.x, pos.y + topSizeS.y,
            DTA_Alpha, alpha,
            DTA_DestWidthF, midSize.x * scale.x,
            DTA_DestHeightF, midHeight,
            DTA_Filtering, true
        );
        // Bottom
        Screen.DrawTexture(botTex, false,  pos.x, (pos.y + topSizeS.y + midHeight),
            DTA_Alpha, alpha,
            DTA_DestWidthF, botSize.x * scale.x,
            DTA_DestHeightF, botSize.y * scale.y,
            DTA_Filtering, true
        );

        // Draw image
        float tm3 = MIN((te - 0.1) / 0.15, 1.0);
        Vector2 isize = (imageSize.x * scale.x, imageSize.y * scale.y);
        Screen.DrawTexture(info.image, true,  pos.x + (topSizeS.x / 2.0) - (isize.x / 2.0), pos.y + topSizeS.y + ((20 + imageOffset) * scale.y),
            DTA_Alpha, alpha * tm3,
            DTA_DestWidthF, isize.x,
            DTA_DestHeightF, isize.y,
            DTA_Filtering, true
        );

        // Draw Button
        int buttTop = floor(bottom - ((buttSize.y + buttOffset) * scale.y));
        Screen.DrawTexture(buttHover ? (mouseDown ? buttTex3 : buttTex2) : buttTex, true, round(halfScreenWidth - ((buttSize.x * scale.x) / 2.0)), buttTop,
            DTA_Alpha, alpha * tm3,
            DTA_DestWidthF, buttSize.x * scale.x,
            DTA_DestHeightF, buttSize.y * scale.y,
            DTA_Filtering, true
        );


        // Draw Text
        let tScale = scale;

        // Draw each line of text
        if(printLines && printLines.count()) {
            Font fnt = textFont;
            int fntHeight = fnt.getHeight() + 1;
            float totalHeight =  (fntHeight * printLines.count()) * scale.y;
            float top = (pos.y + topSizeS.y + isize.y + (5 * scale.y));
            float bot = buttTop;
            float t = (top + ((bot - top) / 2.0)) - (totalHeight / 2.0);

            float tm2 = MIN((te - 0.1) / 0.38, 1.0);

            for(int x = 0; x < printLines.count(); x++) {
                string line = printLines.stringAt(x);
                int y = (fntHeight * tScale.y) * x;
                int width = printLines.StringWidth(x);
                Screen.drawText(fnt, Font.CR_UNTRANSLATED, floor((halfScreenWidth - ((width / 2.0) * scale.x)) / tScale.x), floor((t + y) / tScale.y), line, 
                                DTA_Alpha, alpha * tm2,
                                DTA_VirtualWidthF, screenWidth / tScale.x,
                                DTA_VirtualHeightF, screenHeight / tScale.y,
                                DTA_Color, textColor,
                                DTA_KeepRatio, true,
                                DTA_Filtering, true);
            }
        }

        // Draw KB text
        if(kbText != "" && tm > 0.9) {
            Font sfnt = "SELOFONT";
            int width = sfnt.StringWidth(kbText);
            
            float tm2 = MIN((te - 0.3) / 0.15, 1.0);
            Screen.drawText(sfnt, Font.CR_UNTRANSLATED, floor(halfScreenWidth - ((width / 2.0) * scale.x)) / scale.x, (pos.y + topSizeS.y + midHeight + (botSize.y * scale.y) + (5 * scale.y)) / scale.y, kbText, 
                            DTA_Alpha, UIMath.EaseOutXYA(0.0, 1.0, tm2),
                            DTA_VirtualWidthF, screenWidth / tScale.x,
                            DTA_VirtualHeightF, screenHeight / tScale.y,
                            DTA_KeepRatio, true,
                            DTA_Filtering, true);
        }

        // Close Text
        {
            Font sfnt = "SEL16FONT";
            int width = sfnt.StringWidth(closeText);
            
            Screen.drawText(sfnt, Font.CR_UNTRANSLATED, floor(halfScreenWidth - ((width / 2.0) * scale.x)) / scale.x, (buttTop + (9 * scale.y)) / scale.y, closeText, 
                            DTA_Alpha, alpha * tm,
                            DTA_VirtualWidthF, screenWidth / tScale.x,
                            DTA_VirtualHeightF, screenHeight / tScale.y,
                            DTA_Color, buttTextColor,
                            DTA_KeepRatio, true,
                            DTA_Filtering, true);
        }

        // Header Text
        if(info.header != "") {
            int offset = floor((topSize.x / 2.0) - ((headerWidth) / 2.0));
            Screen.drawText(titleFont, Font.CR_UNTRANSLATED, (pos.x + (offset * scale.x)) / tscale.x, (pos.y + (headerTop * scale.x)) / tscale.y, info.header, 
                            DTA_Alpha, alpha * tm,
                            DTA_VirtualWidthF, screenWidth / scale.x,
                            DTA_VirtualHeightF, screenHeight / scale.y,
                            DTA_Color, headerTextColor,
                            DTA_KeepRatio, true,
                            DTA_Filtering, true);
        }
    }
}