class AchieveNotif {
    String title, text, icon;
}

class GlobalStatHandler : StaticEventHandler {
    mixin UIDrawer;
	mixin ScreenSizeChecker;
	mixin HUDScaleChecker;
	mixin HudDrawer;
    mixin CVARBuddy;

    Array<AchieveNotif> pAchievementQueue;
    ui Array<AchieveNotif> achievementQueue;

    bool disableEverything;
    int notifPending;
    String notifText, notifSubtext, pTrophyPic;

    ui Shape2DTransform notifTransform;
    ui Shape2D notifShape;
    ui uint uiTicks, notifTicks;
    ui String uiNotifText, uiNotifSubtext;
    ui bool statsConnected, notifLeft;
    ui TextureID notifBG, tropyPic;
    ui float notifWidth;


    override void onRegister() {
        SetOrder(int.max);
        notifPending = -1000;
        disableEverything = iGetCVAR("g_statdb") <= 0;
    }

    override void StatProcess(StatsEvent e) {
        // Any achievement update with text is a new achievement aquired
        // Notify the user
        if(e.IsAchievement && e.Text != "") {
            let p = AchieveNotif(new("AchieveNotif"));
            p.title = StringTable.Localize("$ACHIEVEMENT_POP_UP_UNLOCKED");
            p.text = "\c[HI]" .. e.Text;
            p.icon = "ACHIEVPC";
            achievementQueue.push(p);
        }
    }

    override void ConsoleProcess(ConsoleEvent e) {
        if(e.Name == "achieve") {
            Console.Printf("Achieving...");
            
            let p = AchieveNotif(new("AchieveNotif"));
            p.title = "Achievement Unlocked";
            p.text = "Test Achievement 1";
            p.icon = "ACHIEVPC";
            achievementQueue.push(p);

            p = AchieveNotif(new("AchieveNotif"));
            p.title = "Achievement Unlocked";
            p.text = "Test Achievement 2";
            p.icon = "ACHIEVPC";
            achievementQueue.push(p);

            p = AchieveNotif(new("AchieveNotif"));
            p.title = "Achievement Unlocked";
            p.text = "Test Achievement 3";
            p.icon = "ACHIEVPC";
            achievementQueue.push(p);

            p = AchieveNotif(new("AchieveNotif"));
            p.title = "Achievement Unlocked";
            p.text = "Test Achievement 4";
            p.icon = "ACHIEVPC";
            achievementQueue.push(p);

            p = AchieveNotif(new("AchieveNotif"));
            p.title = "Achievement Unlocked";
            p.text = "Test Achievement 5";
            p.icon = "ACHIEVPC";
            achievementQueue.push(p);
        }
    }

    override void UITick() {
        if(disableEverything) return;

        if(notifPending == level.totalTime) {
            let p = AchieveNotif(new("AchieveNotif"));
            p.title = notifText;
            p.text = notifSubtext;
            p.icon = pTrophyPic;
            achievementQueue.push(p);
        }

        // Check for connection to stats service
        // Only show after intro and not when a menu is open
        if(!menuActive && uiticks % 10 == 0) {
            let handler = IntroHandler(StaticEventHandler.Find("IntroHandler"));
            if(!handler || handler.ticks > handler.introTicks + 10) {
                bool isConnected = StatDatabase.isAvailable();
                if(isConnected && !statsConnected) {
                    if(achievementQueue.size() == 0) {
                        // Notify valid!
                        setNotif("Achievements", StringTable.Localize("$ACHIEVEMENT_POP_UP_AVAILABLE"), "ACHIEVPC");
                    }
                    statsConnected = isConnected;
                } else if(!isConnected && statsConnected) {
                    // Notify disconnect!
                    setNotif("Achievements", StringTable.Localize("$ACHIEVEMENT_POP_UP_UNAVAILABLE"), "NOACHIEV");
                    statsConnected = isConnected;
                } else if(!menuActive && !notifOpen() && achievementQueue.size() > 0) {
                    let ach = achievementQueue[0];
                    achievementQueue.delete(0);

                    setNotif(ach.title, ach.text, ach.icon);
                }
            }
        }

		if(screenSizeChanged() || hudScaleChanged()) {
        	getScreenScale(screenSize, virtualScreenSize);
        }

        // Don't progress notification if menu is open
        if(menuActive && notifTicks != 0 && notifTicks == uiTicks) {
            notifTicks++;
        }
        
        uiTicks++;
	}

    ui bool notifOpen() {
        return notifTicks > 0 && uiTicks - notifTicks < 300;
    }

    ui void setNotif(String title, String text, String icon = "ACHIEVPC") {
        notifTicks = uiTicks;
        uiNotifText = title;
        uiNotifSubtext = text;

        notifBG = TexMan.CheckForTexture("ACHIEVBG");
        tropyPic = TexMan.CheckForTexture(icon);

        // Determine width based on text size
        Font fnt = "SEL21FONT";
        double f1 = fnt.stringWidth(title);
        double f2 = fnt.stringWidth(text) * 0.9;
        notifWidth = max(300, f1 + 148);
        notifWidth = max(notifWidth, f2 + 148);

        // If the difference between text sizes is extreme, left align everything
        notifLeft = abs(f2 - f1) > 150;
    }


    void worldSetNotif(String title, String text, String icon = "ACHIEVPC") {
        notifPending = level.totalTime + 1;
        notifText = title;
        notifSubtext = text;
        pTrophyPic = icon;
    }


    ui void buildNotifShape(double width = 98, double height = 94) {
        if(!notifShape) notifShape = new("Shape2D");
        else notifShape.clear();
        if(!notifTransform) notifTransform = new("Shape2DTransform");

        int vertCount;
        double hw = width * 0.5;
        double hh = height * 0.5;

        // Left
        Shape2DHelper.AddQuadRawUV(notifShape, (-hw, -hh), (49, height), (0, 0), (0.5, 1), vertCount);

        if(width > 98) {
            // Center
            Shape2DHelper.AddQuadRawUV(notifShape, (-hw + 49, -hh), (width - 98, height), (0.5,0), (0.5, 1), vertCount);
        }
        
        // Right
        Shape2DHelper.AddQuadRawUV(notifShape, (hw - 49, -hh), (49, height), (0.5, 0), (1, 1), vertCount);
    }


    const CLOSING_TIME = 5.2;
    
    override void RenderOverlay(RenderEvent e) {
        if(disableEverything) return;
        
        if(notifOpen()) {
            Vector2 scScale = getVirtualScreenScale();

            double time = (double(uiTicks - notifTicks) + e.fracTic) * ITICKRATE;
            bool closing = time > CLOSING_TIME;

            double tm, width, scale, alpha, scaleTM;

            if(closing) {
                time -= CLOSING_TIME;
                tm = clamp(time / 0.7, 0, 1);
                tm = UIMath.EaseInOutCubicF(tm);
                width = clamp((notifWidth + 50) * (1.0 - tm), 98, notifWidth);
                scaleTM = clamp(1.0 - ((time - 0.7) / 0.2), 0, 1);
                scale = (UIMath.EaseOutBackF(scaleTM) * 0.5) + 0.5;
                alpha = scaleTM;
            } else {
                tm = clamp(time / 1.0, 0, 1);
                tm = UIMath.EaseInOutCubicF(tm);
                width = max(notifWidth * tm, 98);
                scaleTM = clamp((time / 0.2), 0, 1);
                scale = (UIMath.EaseOutBackF(scaleTM) * 0.5) + 0.5;
                alpha = scaleTM;
            }
            

            buildNotifShape(width);
            notifTransform.clear();
            notifTransform.scale((scale, scale));
            notifTransform.translate((virtualScreenSize.x * 0.5, virtualScreenSize.y * 0.9) );
            notifTransform.scale(scScale);
            notifShape.setTransform(notifTransform);
            
            Screen.drawShape(
                notifBG, 
                false,
                notifShape,
                DTA_Alpha, alpha,
                DTA_Filtering, true
            );

            if(closing) scaleTM = clamp(1.0 - ((time - 0.7) / 0.17), 0, 1);
            else scaleTM = clamp((time / 0.25), 0, 1);

            scale = (UIMath.EaseOutBackF(scaleTM) * 0.5) + 0.5;
            Vector2 imgOff = ((-(width - 98) * 0.5), 0);
            DrawTexAdvanced(tropyPic, (virtualScreenSize.x * 0.5, virtualScreenSize.y * 0.9) + imgOff, DR_SCALE_IS_SIZE | DR_IMG_CENTER, a: alpha, scale: (64, 64) * scale);

            Vector2 strOff;
            if(closing) {
                alpha = 1.0 - UIMath.EaseOutCubicF(clamp((time - 0.15) / 0.25, 0, 1));
                if(notifLeft) strOff = (imgOff.x + 32 + 15, -2);
                else strOff = (12 * (1.0 - tm), -2);
            } else {
                alpha = UIMath.EaseInCubicF(clamp((time - 0.55) / 0.25, 0, 1));
                if(notifLeft) strOff = (imgOff.x + 32 + 15, -2);
                else strOff = (12 * tm, -2);
            }

            if(notifLeft) DrawStr("SEL21FONT", uiNotifText, (virtualScreenSize.x * 0.5, virtualScreenSize.y * 0.9) + strOff, DR_TEXT_BOTTOM, a: alpha, monoSpace: false);
            else DrawStr("SEL21FONT", uiNotifText, (virtualScreenSize.x * 0.5, virtualScreenSize.y * 0.9) + strOff, DR_TEXT_HCENTER | DR_TEXT_BOTTOM, a: alpha, monoSpace: false);

            if(closing) alpha = 1.0 - UIMath.EaseOutCubicF(clamp(time / 0.25, 0, 1));
            else alpha = UIMath.EaseInCubicF(clamp((time - 0.7) / 0.25, 0, 1));
            strOff.y = 2;

            if(notifLeft) DrawStr("SEL21FONT", uiNotifSubtext, (virtualScreenSize.x * 0.5, virtualScreenSize.y * 0.9) + strOff, a: alpha, monoSpace: false, scale: (0.9, 0.9));
            else DrawStr("SEL21FONT", uiNotifSubtext, (virtualScreenSize.x * 0.5, virtualScreenSize.y * 0.9) + strOff, DR_TEXT_HCENTER, a: alpha, monoSpace: false, scale: (0.9, 0.9));
        }
    }
}