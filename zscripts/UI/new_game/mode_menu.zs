#include "ZScripts/UI/new_game/mode_card.zs"
#include "ZScripts/UI/new_game/start_button.zs"

class NewGameHandler : StaticEventHandler {
    mixin CVARBuddy;

    bool isNewGame;
    int workshopCountdown;

    override void PlayerEntered(PlayerEvent e) {
        // Only apply settings on the first level (new mission), and Backrooms for demo purposes. We may not want to keep this for when we add a Level Selection screen.
        if(isNewGame && level.levelnum != 9999) { 
            // Assign hardcore mode
            if(iGetCVar("g_hardcoremode", 0)) {
                players[e.playerNumber].mo.giveInventory("HardcoreMode", 1);
            }

            // Assign rifle start
            if(iGetCVar("g_riflestart", 0)) {
                players[e.playerNumber].mo.giveInventory("RifleStart", 1);
            }

            if(iGetCVar("g_playtestStart", 0)) {
                Dawn(players[e.playerNumber].mo).givePlaytestItems();
                workshopCountdown = 35 * 3;
            }
        }

        isNewGame = false;
    }

    override void NewGame() {
        // The player has not spawned at this point, so wait until they enter to assign details
        isNewGame = true;
        /*if(skill == SKILL_SMF) {
            StatDatabase.SetAchievement("GAME_TRIEDSMF", 1);
        }*/
    }

    override void WorldUnloaded(WorldEvent e) {
        if(Level.MapName != "TITLEMAP") {
            isNewGame = false;
        }
    }

    override void WorldTick() {
        if(workshopCountdown > 0) {
            workshopCountdown--;
            if(workshopCountdown == 0) {
                LevelEventHandler.ShowWorkshop();
            }
        }
    }
}


class ModeMenu : SelacoGamepadMenu {
    mixin CVARBuddy;

    UILabel headerLabel;
    UIImage backgroundImage;
    UITexture bgTex;
    Array<ModeCard> cards;
    int skill, mode;

    ModeStartButton startButton;
    UIButton RifleStartButton;

    double startGameTime, lastRenderTime;
    bool shouldFade, newGameReady;

    const startGameDelay = 0.5;


    override void init(Menu parent) {
        Super.init(parent);
        skill = !skill ? 2 : skill;
        AnimatedTransition = false;
        Animated = true;

        mode = -1;
        shouldFade = true;//Level.MapName != "TITLEMAP";

        bgTex = UITexture.Get("PLYSTLBK");

        headerLabel = new("UILabel").init((0,0), (600, 40), StringTable.Localize("$PLAYSTYLE_HEADER").makeUpper(), "K32FONT", textAlign: UIView.Align_Centered);
        headerLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_VCenter, value: 1.0, offset: -(484 / 2) - 120, isFactor: true);
        headerLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        //headerLabel.pinWidth(UIView.Size_Min); // Why bother?
        mainView.add(headerLabel);

        // Create Cards
        let c = new("ModeCard").init(0, 
            StringTable.Localize("$PLAYSTYLE_TRAD_CARD"),
            UIHelper.FilterKeybinds(StringTable.Localize("$PLAYSTYLE_TRAD")),
            0.5//-(342 + 60)
        );
        cards.push(c);
        mainView.add(c);

        c = new("ModeCard").init(1, 
            StringTable.Localize("$PLAYSTYLE_HARD_CARD"),
            UIHelper.FilterKeybinds(StringTable.Localize("$PLAYSTYLE_HARD")),
            1.0
        );
        cards.push(c);
        mainView.add(c);

        c = new("ModeCard").init(2, 
            StringTable.Localize("$PLAYSTYLE_RANDO_CARD"),
            UIHelper.FilterKeybinds(StringTable.Localize("$PLAYSTYLE_RANDO")),
            1.5//342 + 60
        );
        cards.push(c);
        c.setDisabled(true);
        c.setAlpha(0.75);
        mainView.add(c);

        startButton = new("ModeStartButton").init(StringTable.Localize("$PROCEED"));
        startButton.pin(UIPin.Pin_Top, UIPin.Pin_VCenter, value: 1.0, offset: (484 / 2) + 65);
        startButton.pin(UIPin.Pin_Right, UIPin.Pin_HCenter, value: 1.5, offset: 342 / 2, isFactor: true);
        mainView.add(startButton);

        let psButtonTop = (484 / 2) + 65;
        let psButtonLeft = -(342 / 2);
        RifleStartButton = new("UIButton").init((0,0), (40, 40), "", null, 
            UIButtonState.CreateSlices("graphics/options_menu/checkbox.png", (9, 9), (21, 21)),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_high.png", (9, 9), (21, 21), sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_down.png", (9, 9), (21, 21)),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_disabled.png", (9, 9), (21, 21)),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_filled.png", (9, 9), (21, 21)),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_filled_high.png", (9, 9), (21, 21), sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_filled_down.png", (9, 9), (21, 21))
        );
        RifleStartButton.pin(UIPin.Pin_Top, UIPin.Pin_VCenter, value: 1.0, offset: psButtonTop);
        RifleStartButton.pin(UIPin.Pin_Left, UIPin.Pin_HCenter, value: 0.5, offset: psButtonLeft, isFactor: true);
        let rfcv = CVar.FindCVar("g_rifleStart");
        RifleStartButton.setSelected(rfcv && rfcv.getInt() > 0, false);
        //RifleStartButton.setDisabled();
        //RifleStartButton.setAlpha(0.5);
        mainView.add(RifleStartButton);

        // Add pistol start text
        let psText = new("UILabel").init((0,0), (600, 40), StringTable.Localize("$RIFLE_START"), 'PDA18FONT', textAlign: UIView.Align_Middle);
        psText.pin(UIPin.Pin_Top, UIPin.Pin_VCenter, value: 1.0, offset: psButtonTop);
        psText.pin(UIPin.Pin_Left, UIPin.Pin_HCenter, value: 0.5, offset: psButtonLeft + 40 + 10, isFactor: true);
        mainView.add(psText);
        //psText.setAlpha(0.5);

        let psDesc = new("UILabel").init((0,0), (600, 40), StringTable.Localize("$RIFLE_START_TEXT"), 'PDA16FONT');
        psDesc.alpha = 0.7;
        psDesc.pin(UIPin.Pin_Top, UIPin.Pin_VCenter, value: 1.0, offset: psButtonTop + 40 + 10);
        psDesc.pin(UIPin.Pin_Left, UIPin.Pin_HCenter, value: 0.5, offset: psButtonLeft, isFactor: true);
        psDesc.multiline = true;
        mainView.add(psDesc);
        //psDesc.setAlpha(0.5);

        // Configure selection chain
        for(int x = 0; x < cards.size(); x++) {
            cards[x].navLeft = x > 0 ? cards[x - 1] : cards[cards.size() - 1];
            cards[x].navRight = x < cards.size() - 1 ? cards[x + 1] : cards[0];
            cards[x].navDown = startButton;
        }

        cards[0].navDown = RifleStartButton;
        startButton.navUp = cards[1];
        startButton.navLeft = RifleStartButton;
        RifleStartButton.navRight = startButton;
        RifleStartButton.navDown = startButton;
        RifleStartButton.navUp = cards[0];
        
        // Set default button selection
        cards[0].setSelected();
        navigateTo(cards[0]);
    }

    void setSkillLevel(int skill = 2) {
        self.skill = skill;
    }

    override bool menuEvent(int key, bool fromcontroller) {
        switch (key) {
            case MKEY_Right:
                if(activeControl == null && lastActiveControl != null) {
                    navigateTo(lastActiveControl);
                    return logController(key, fromController);
                } else if(activeControl == null) {
                    navigateTo(cards[0]);
                    return logController(key, fromController);
                }
                break;
            case MKEY_Left:
                if(activeControl == null && lastActiveControl != null) {
                    navigateTo(lastActiveControl);
                    return logController(key, fromController);
                } else if(activeControl == null) {
                    navigateTo(cards[cards.size() - 1]);
                    return logController(key, fromController);
                }
                break;
            case MKEY_BACK:
                if(activeControl == startButton && fromcontroller) {
                    for(int x = 0; x < cards.size(); x++) {
                        if(cards[x].selected) {
                            navigateTo(cards[x]);
                            return true;
                        }
                    }
                }
                break;
            default:
                break;
        }

        return Super.MenuEvent(key, fromcontroller);
    }

    override bool onUIEvent(UIEvent ev) {
        

        return Super.OnUIEvent(ev);
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            let c = ModeCard(ctrl);

            if(c && (!c.selected || !fromMouseEvent)) {
                // TODO: Configure game
                mode = c.mode;
                
                // Set selected card
                int selectedCard = 0;
                for(int x =0; x < cards.size(); x++) {
                    cards[x].setSelected(cards[x] == c);
                    if(cards[x] == c) selectedCard = x;
                }

                MenuSound("ui/playstyle/select");

                // Set the start button to navigate upwards towards the selected card
                startButton.navUp = cards[selectedCard];
                RifleStartButton.navUp = cards[selectedCard];

                if(!fromMouseEvent) {
                    navigateTo(startButton);
                }

                //fadeOutOrStartGame();
            } else if(ctrl == startButton) {
                fadeOutOrStartGame();
            } else if(ctrl == RifleStartButton) {
                RifleStartButton.setSelected(!RifleStartButton.selected, false);

/*                 if(!iGetCVar("g_promptXMAS", 0)) {
                    MenuSound("ui/message");
                    let m = new("PromptMenu").initNew(self, "Christmas Challenge", "The Christmas Challenge provides a heavily altered experience. \n\nThis challenge is not recommended for players who have not completed the demo before.", "Understood");
                    m.ActivateMenu();
                    
                    let cv = CVar.FindCVar("g_promptXMAS");
                    if(cv) { cv.setInt(1); }
                } else { */
                    MenuSound("ui/playstyle/PSCHECK");
               // }
            }
        }
    }
    
    override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;

        let ff = Super.navigateTo(con, mouseSelection);

        // If we KB or Gamepad selected, just choose the card right away
        if(!mouseSelection && con is "ModeCard") {
            for(int x = 0; x < cards.size(); x++) {
                cards[x].setSelected(con == cards[x]);

                if(con == cards[x]) {
                    // Set the start button to navigate upwards towards the selected card
                    startButton.navUp = cards[x];
                    RifleStartButton.navUp = cards[x];

                    mode = cards[x].mode;
                }
            }
        }
        
        
        return ff;
	}

    override void ticker() {
        Super.ticker();
        animated = true;

        /*if(startGameTime > 0.1) {
            SetMusicVolume(MAX(0.0, Level.MusicVolume - ((getRenderTime() - startGameTime) / startGameDelay)));
        }*/

        if(newGameReady && getRenderTime() - startGameTime >= startGameDelay) {
            startGame();
        }
    }

    const fadeInTime = 1.0;
    override void drawSubviews() {
        double rt = getRenderTime();
        double te = rt - lastRenderTime;
        lastRenderTime = rt;
        double gAlpha = startGameTime > 0.1 ? MAX(0.0, 1.0 - ((rt - startGameTime) / (startGameDelay * 0.3))) : 1.0;

        Screen.dim(0xFF020202, 1, 0, 0, lastScreenSize.x, lastScreenSize.y);

        if(bgTex.texID.isValid()) {
            let bgAspect = bgTex.size.x / bgTex.size.y;
            let scAspect = lastScreenSize.x / lastScreenSize.y;
            Vector2 size;

            if(scAspect >= bgAspect) {
                size = (lastScreenSize.x, lastScreenSize.x / bgAspect);
            } else {
                size = (lastScreenSize.y * bgAspect, lastScreenSize.y);
            }

            size *= 1.0 + ((1.0 + (sin(rt * 4) * 0.5)) * .15);

            // Draw bg
            Screen.DrawTexture(
                bgTex.texID, true, 
                (lastScreenSize.x - size.x) / 2.0,
                (lastScreenSize.y - size.y) / 2.0,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Filtering, true,
                DTA_Alpha, (0.4 + (sin(rt * 15) * 0.1)) * gAlpha
            );
        }

        if(startGameTime > 0.1) {
            // Fade out main view before new game starts
            mainView.setAlpha(gAlpha);
        }

        Super.drawSubviews();

        // Fade in too
        if(rt < fadeInTime) {
            Screen.dim(0xFF020202, 1.0 - (rt / fadeInTime), 0, 0, lastScreenSize.x, lastScreenSize.y);
        }
    }

    void fadeOutOrStartGame() {
        let modeCV = CVar.FindCVar("new_game_mode");
        // Replaced with XMAS event for now!
        let rifleCV = CVar.FindCVar("g_rifleStart"); //CVar.FindCVar("new_game_pistol");  

        modeCV.setInt(mode);    // No checking, we want to crash if the CV is missing
        rifleCV.setBool(RifleStartButton.selected);

        // Temporary disabling of autosave
        let nosave = CVar.GetCVar("disableautosave");
        nosave.setInt(mode == 1);

        //if(Level.MapName == "TITLEMAP") {
            // Config new game for when it starts
            startGameTime = getRenderTime();
            lockInterface();
            newGameReady = true;

            
        // } else {
        //     startGame();
        // }

        MenuSound("ui/playstyle/click");
    }

    void startGame() {
        // Tell the intro-handler that a new game is starting
        let handler = IntroHandler(StaticEventHandler.Find("IntroHandler"));
        if(handler) {
            handler.notifyNewGame();
        }
        
        Level.StartNewGame(0, skill, "Dawn");
    }

    private void lockInterface(bool lock = true) {
        for(int x = 0; x < cards.size(); x++) {
            cards[x].setDisabled(lock);
        }

        startButton.setDisabled(lock);
    }
}



