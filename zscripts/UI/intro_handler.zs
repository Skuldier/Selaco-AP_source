#include "zscripts/UI/intro_handler_animation.zs"

class IntroSkipper : Inventory {
    default { Inventory.MaxAmount 1; }    
}



// Simple event handler used when launching the game to prevent skipping the Intro. Evil, I know.
// We actually allow skipping the intro after first launch now so this has less use
// Now this handler is responsible for drawing the smoke on the title screen as well
class IntroHandler : StaticEventHandler {
    mixin UIDrawer;
    mixin ScreenSizeChecker;
    mixin CVARBUDDY;

    bool disable, disableFog, firstRun;
    int ticks;
    
    Font fnt;

    int introTicks;

    bool loadingNewGame;
    ui double lastUIScale;
    ui bool loadingNewGameUI, showingBackground2;
    ui int loadingNewGameTicks, background2time, loadingSaveGameUI;
    ui double lastRenderTime;
    ui float curMusVolume;
    ui int uiTicks;

    ui UIView mainView;
    ui UIImage logoImage, bgImage;//, bgImage2;
    ui UIViewAnimator animator;
    
    UITexture emberTex;

    string pressText;

    const loadFadeTime = 2.0;               // total time to fade to black when starting a new game
    const fogTime = 5.0;                    // total time for each fog layer loop
    const numFog = 10;                      // number of fog layers
    const fogFragTime = numFog / fogTime;   // Initial time divide for each fog layer
    const fogAlpha = 1.0;                   // Max alpha for fog layers

    const numEmbers = 70;
    const emberSpeed = 0.6;
    const emberVertSpeed = 0.08;
    const emberTime = 5.0;
    const emberFragTime = numEmbers / emberTime;

    const CROSSFADE_BACK_TIME = 0.15;
    const CROSSFADE_TIME = 0.25;

    const TOS_ID = 2;   // Increase this every time we want to force a TOS
    const SPECTACLE_ID = 1;

    static clearscope bool startupCheck() {
        return IntroHandler.needsTOS() || IntroHandler.needsVisibility();
    }

    static clearscope bool needsTOS() {
        let cv = CVar.GetCVar("g_tos");
        return cv && cv.getInt() < TOS_ID;
    }

    static clearscope bool needsVisibility() {
        let cv = CVar.GetCVar("g_promptSpectacle");
        return cv && cv.getInt() < SPECTACLE_ID;
    }

    static clearscope void clearNeedsVisibility() {
        let cv = CVar.GetCVar("g_promptSpectacle");
        if(cv) cv.setInt(SPECTACLE_ID);
    }

    static clearscope void clearNeedsTOS() {
        let cv = CVar.GetCVar("g_tos");
        if(cv) cv.setInt(TOS_ID);
    }

    override void OnRegister() {
        let cv = CVar.GetCVar("g_skipintro");
        if(cv && cv.GetBool()) {
            //disable = true;
            introTicks = 0;
        } else {
            introTicks = 494 + 4;
        }

        firstRun = IntroHandler.startupCheck();
        
        let launch = CVar.GetCVar("g_launch_count");
        if(launch) launch.setInt(g_launch_count + 1);

        if(firstRun) introTicks -= 15;

        fnt = "SELACOFONT";

        pressText = StringTable.Localize("$PRESSANYKEY");
        emberTex = UITexture.Get("EMBRA0");

        SetOrder(99998);
    }

    override bool UIProcess (UiEvent e) {    
        if(!disable && ticks < introTicks) {
            return true;
        }

        return false;
    }

    // Not sure we need this, there are hardly any input events in the title screen, if any
    override bool InputProcess (InputEvent e) {
        if(!disable && ticks < introTicks && !(Menu.GetCurrentMenu() is 'StartupMenu')) {
            return true;
        }

        return false;
    }

    override void WorldTick () {
        disable = Level.MapName != "TITLEMAP";
        disableFog = disable || ticks < (introTicks - FADEINTICKS);

        if(disable) {
            //if (!bDESTROYED) Destroy(); // Destruct after first use
            return;
        }

        // Check with intro level if the intro sequence is over
        if(ticks < introTicks && ACS_ExecuteWithResult(-int('IsIntroOver'), 0)) {
            ticks = introTicks + 35;
        }

        if(!IntroHandler.startupCheck()) {
            ticks++;
        }
    }

    override void NewGame() {
        loadingNewGame = false;
    }

    override void WorldLoaded(WorldEvent e) {
        loadingNewGame = false;

        if(Level.MapName == "TITLEMAP") {
            // We have returned to the titlemap, so restart the timer
            introTicks = 494;
            ticks = 0;
            disable = false;
            disableFog = true;

            // Refresh firstrun status
            firstRun = IntroHandler.needsTOS() || IntroHandler.needsVisibility();
            if(firstRun) introTicks -= 15;
        } else {
            disable = true;
            disableFog = true;
        }
    }

    override void WorldUnloaded(WorldEvent e) {
        loadingNewGame = true;
    }

    clearscope double calcScale(out Vector2 screenSize, out Vector2 vScreenSize, Vector2 baselineResolution = (1920, 1080)) {
        screenSize = (Screen.GetWidth(), Screen.GetHeight());
		let uscale = fGetCVar("ui_scaling", 1.0);
		if(uscale <= 0.001) uscale = 1.0;

        let newScale = uscale * CLAMP(screenSize.y / baselineResolution.y, 0.5, 2.0);
		
		// If we are close enough to 1.0.. 
		if(abs(newScale - 1.0) < 0.08) {
			newScale = 1.0;
		} else if(abs(newScale - 2.0) < 0.08) {
			newScale = 2.0;
		}
        
        vScreenSize = screenSize / newScale;

        return newScale;
	}


    clearscope string getMenuImage() {
        string menuImg = "menu1";
        if(Screen.GetHeight() <= 600) {
            menuImg = "menu3";
        } else if(Screen.GetHeight() <= 1080 && Screen.GetWidth() <= 1920) {
            menuImg = "menu2";
        }
        return menuImg;
    }

    
    clearscope string getMenuImage2() {
        string menuImg = "menu6";
        if(Screen.GetHeight() <= 600) {
            menuImg = "menu8";
        } else if(Screen.GetHeight() <= 1080 && Screen.GetWidth() <= 1920) {
            menuImg = "menu7";
        }
        return menuImg;
    }


    override void UITick() {
        // First tick never seems to have joystick info :( 
        if(uiticks == 1 && IntroHandler.needsTOS()) {
            // Try to detect the steam deck here
            if(UIHelper.TestForSteamDeck()) {
                Console.Printf("\c[GOLD]Steam Deck detected! Setting options...");
                UIHelper.SetSteamdeckPresets();

                lastUIScale = calcScale(screenSize, virtualScreenSize, (1920, 1080));

                // Make sure any current menu updates itself
                let m = UIMenu(Menu.GetCurrentMenu());
                if(m) {
                    m.layoutChange(Screen.GetWidth(), Screen.GetHeight());
                }
            }
        }

        if(uiticks == 1) {
            // Make sure both menu images are loading, they are big and slow and need a hug
            TexMan.MakeReady(TexMan.CheckForTexture(getMenuImage()));
            //TexMan.MakeReady(TexMan.CheckForTexture(getMenuImage2()));

            // Load all the fog textures
            for(int x = 1; x <= 5; x++) {
                TexMan.MakeReady(TexMan.CheckForTexture(String.Format("MODEFOG%d", x)));
            }

            TexMan.MakeReady(TexMan.CheckForTexture("MENUVIGN"));
        }


        if(!mainView) {
            lastUIScale = calcScale(screenSize, virtualScreenSize, (1920, 1080));

            animator = new("UIViewAnimator");
            mainView = new("UIView").init((0,0), virtualScreenSize);
            mainView.scale = (lastUIScale, lastUIScale);

            // Determine background image size based on screen resolution
            bgImage = new("UIImage").init((0,0), (0,0), getMenuImage(), imgStyle: UIImage.Image_Aspect_Fill);
            bgImage.pinToParent();
            mainView.add(bgImage);

            /*bgImage2 = new("UIImage").init((0,0), (0,0), getMenuImage2(), imgStyle: UIImage.Image_Aspect_Fill);
            bgImage2.alpha = 0;
            bgImage2.pinToParent();
            mainView.add(bgImage2);*/

            logoImage = new("UIImage").init((0,0), (100,100), "SELACOLG");
            logoImage.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
            logoImage.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value: 0.26, isFactor: true);
            logoImage.pinWidth(UIView.Size_Min);
            logoImage.pinHeight(UIView.Size_Min);

            mainView.add(logoImage);
        } else {
            let fScale = calcScale(screenSize, virtualScreenSize, (1920, 1080));
            if(screenSizeChanged() || !(fScale != lastUIScale)) {
                mainView.frame.size = virtualScreenSize;
                mainView.scale = (fScale, fScale);
                mainView.requiresLayout = true;
                lastUIScale = uiScale;

                // Update the background graphic
                bgImage.setImage(getMenuImage());
                //bgImage2.setImage(getMenuImage2());
            }
        }

        //logoImage.hidden = menuActive > 0;

        mainView.tick();

        if(loadingNewGameUI) {
            loadingNewGameTicks--;

            if(loadingNewGameTicks == 0) {
                loadingNewGameUI = false;
            }
        }
        
        if(fogs.size() == 0) {
            // Create fogs
            for(int x = 0; x < numFog; x++) {
                let fog = new("BGFog");
                fog.img = UITexture.Get("MODEFOG" .. random(1,4));
                fog.bSize = (frandom(0, 1.3), frandom(0.0, 0.6));
                fog.life = x * fogFragTime;
                fogs.push(fog);
            }

            // Init mus volume (this should have been the first tick)
            curMusVolume = Level.MusicVolume;
        }

        if(embers.size() == 0) {
            for(int x = 0; x < numEmbers; x++) {
                makeEmber(x * emberFragTime);
            }
        }

        if(disable) {
            uiticks++;
            return;
        }

        if(curMusVolume < Level.MusicVolume) {
            curMusVolume = MIN(curMusVolume + 0.03, Level.MusicVolume);
            SetMusicVolume(curMusVolume);
        }

        // Open blocker menu if it's not open, after the first tick
        let m = Menu.GetCurrentMenu();
        if(!disable && ticks < introTicks && (!m || !(m is 'IntroMenu' || m is 'StartupMenu'))) {
            Menu.SetMenu("IntroMenu");
        }
        
        // Close blocker menu if it's still up
        if(disable || ticks >= introTicks) {
            if(Menu.GetCurrentMenu() is "IntroMenu") {
                Menu.GetCurrentMenu().Close();
            }
        }

        // Transition background image if the main menu is open
        m = Menu.GetCurrentMenu();
        bool menuUp = m && !(m is 'IntroMenu' || m is 'StartupMenu');
        if(menuUp && !showingBackground2) {
            // Do a crossfade animation
            showingBackground2 = true;
            background2time = ticks;

            animator.clear();
            /*let anim = new("UIViewFrameAnimation").initComponents(bgImage2, 0.25,
                toAlpha: 1.0,
                ease: Ease_Out
            );
            animator.add(anim);*/

            let anim2 = new("UIViewPinAnimation").initComponents(logoImage, 0.125,
                toScale: (1.1, 1.1),
                toAlpha: 0,
                ease: Ease_Out
            );
            animator.add(anim2);

        } else if(!menuUp && showingBackground2) {
            // Do a crossfade animation
            showingBackground2 = false;
            background2time = ticks;

            /*animator.clear();
            let anim = new("UIViewFrameAnimation").initComponents(bgImage2, 0.35,
                toAlpha: 0.0,
                ease: Ease_Out
            );
            
            animator.add(anim);*/

            let anim2 = new("UIViewPinAnimation").initComponents(logoImage, 0.15,
                toScale: (1, 1),
                toAlpha: 1,
                ease: Ease_Out
            );
            animator.add(anim2);
        }

        // New game loading only a few ticks, we want to restore "Press any key.." if loading fails
        // if(loadingNewGame && ticks - loadingNewGameTicks  > (int(loadFadeTime * 35.0) + 15)) {
        //     loadingNewGame = false;
        // }

        uiticks++;
    }

    
    const LOAD_TEXT = "Loading...";
    const FADEINTICKS = 6;
    const LOAD_FADEINTICKS = 50;
    const LOAD_FADEINOFFSET = 10;
    const LOAD_FADEINOFFSETTOTAL = LOAD_FADEINTICKS + LOAD_FADEINOFFSET;

    override void RenderOverlay(RenderEvent e) {
        // Render loading overlay
        if(loadingNewGameUI || loadingSaveGameUI) {
            if(loadingSaveGameUI) {
                double alpha = 1.0 - UIMath.EaseInCubicF( clamp((uiTicks - loadingSaveGameUI + LOAD_FADEINOFFSET + e.FracTic) / double(LOAD_FADEINTICKS), 0, 1) );
                Screen.Dim(0xFF000000, alpha, 0,0, Screen.GetWidth(), Screen.GetHeight());
                if(uiTicks - loadingSaveGameUI > LOAD_FADEINOFFSETTOTAL) loadingSaveGameUI = 0;
            } else {
                Screen.Dim(0xFF000000, 1.0, 0,0, Screen.GetWidth(), Screen.GetHeight());
            }
            
            // Draw Loading text
            if(loadingNewGameUI) {
                int left = Screen.GetWidth() - 40 - fnt.StringWidth(LOAD_TEXT);
                int top = Screen.GetHeight() - 40 - fnt.GetHeight();
                Screen.DrawText(fnt, Font.CR_WHITE, left, top, LOAD_TEXT,
                                DTA_KeepRatio, true,
                                DTA_Alpha, 1);
            }

            return;
        }
        
        if(disable && disableFog) return;

        if(ticks < (introTicks - FADEINTICKS)) {
            return;
        }
        
        // Draw the view system
        animator.step();
        mainView.draw();
        mainView.drawSubviews();
        Screen.ClearClipRect();    

        // Manually draw the fog
        double time = (ticks - introTicks + e.fracTic) / 35.0;
        double te = time - lastRenderTime;
        

        lastRenderTime = time;
        Vector2 screenSize = (Screen.GetWidth(), Screen.GetHeight());

        if(!disableFog) {// && !(showingBackground2 && ticks - background2time > 70)) {
            double fogFadeAlpha = MIN(1.0, time / 0.15);
            double fadeTime = (ticks /*- background2time*/ + e.fracTic) * ITICKRATE;
            double fadeAlpha = UIMath.EaseOutCubicf( /*showingBackground2 ? clamp(1.0 - (fadeTime / CROSSFADE_TIME), 0.0, 1.0) : */clamp((fadeTime / CROSSFADE_BACK_TIME), 0.0, 1.0) );

            drawFog(time, te, fogFadeAlpha * fadeAlpha);
        }

        /*if(showingBackground2) {
            double fadeTime = (ticks - background2time + e.fracTic) * ITICKRATE;
            double fadeAlpha = UIMath.EaseOutCubicf( showingBackground2 ? clamp(fadeTime / CROSSFADE_TIME, 0.0, 1.0) : clamp(1.0 - (fadeTime / CROSSFADE_BACK_TIME), 0.0, 1.0) );

            drawImpactsAndSmoke(time, te, fadeAlpha);
        }*/
        

        // Draw the press any key button
        if(!loadingNewGameUI && !disable) {
            // Draw press any key text
            if(!Menu.GetCurrentMenu()) {
                double alpha = MIN(1.0, time / 1.0) * (1.0 - abs(sin(time * 100) * 0.5));
                DrawStr(fnt, pressText, (0, virtualScreenSize.y * 0.8), DR_SCREEN_HCENTER | DR_TEXT_CENTER, a: alpha, monospace: false);
            }
        }

        // Take a few ticks to fade the interface in
        if(ticks < introTicks) {
            double tm = (FADEINTICKS + (ticks + e.fracTic - introTicks)) / double(FADEINTICKS);
            Screen.Dim(0xFF000000, 1.0 - tm, 0,0, Screen.GetWidth(), Screen.GetHeight());
        }
    }

    ui void notifyNewGame() {
        loadingNewGameUI = true;
        loadingNewGameTicks = 10;
    }

    ui void notifyLoadGame() {
        loadingNewGameUI = true;
        loadingSaveGameUI = uiTicks;
        loadingNewGameTicks = 10;
    }

    ui void notifyMusicBumped() {
        curMusVolume = 0;
    }
}