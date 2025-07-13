#include "ZScripts/UI/space_bro/world.zs"

const SPACE_BRO_VOLUME = 0.75;
const SPACE_BRO_MUSIC_VOLUME = 0.65;

class SpaceBroMenu : UIMenu {
    mixin CVARBuddy;
    mixin GamepadInput;

    int moneys, displayedMoneys;

    bool skipPause; // Latch to skip double catch of pause key

    BroWorld world;
    UIImage cabinetImg, youLostImage, costImage;
    UIView menuView, pauseMenuView, highScoresView;
    UILabel cashLabel, highScoreEndLabel;
    UILabel highScoreLabels[8];
    UIButton newGameButt, highScoresButt, resumeGameButt, endGameButt;

    Vector2 customOffset;

    uint gameStartDelay;
    int myLastHighScoreIndex;

    float targetMusicVolume, curMusicVolume, musicVolumeSteps;

    Array<int> keysUp, keysDown, keysLeft, keysRight;
    Array<int> keysFire, keysSpecial, keysBoost;
    Array<int> keysEscape;

    int keylog[10];
    int keylogPos;
    bool haskk;

    const BUTTONPRESS_VOLUME = 0.25;
    const JOYPRESS_VOLUME    = 0.45;

    static const Sound keySounds[] = { "bro/button1", "bro/button2", "bro/button3" };
    static const Sound joySounds[] = { "bro/joy1", "bro/joy2", "bro/joy3", "bro/joy4", "bro/joy5", "bro/joy6", "bro/joy7" };


    override void init(Menu parent) {
        Super.init(parent);
        BlurAmount = 1.0;
        DontDim = true;
        ReceiveAllInputEvents = true;
        menuActive = Menu.OnNoPause;

        // Tell HUD to shut up
        let h = HUD(StatusBar);
        if(h) {
            h.isMuted = true;
        }

        gameStartDelay = 0;
        myLastHighScoreIndex = -1;

        curMusicVolume = Level.MusicVolume;
        targetMusicVolume = Level.MusicVolume * 0.25;
        musicVolumeSteps = (Level.MusicVolume - targetMusicVolume) / 15.0;

        world = new("BroWorld");
        world.init();
        world.screenSize = (Screen.GetWidth(), Screen.GetHeight());

        menuView = new("UIView").init((0,0), (780, 775));
        menuView.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        menuView.pin(UIPin.Pin_VCenter, value: 1.0, offset: customOffset.y, isFactor: true);
        menuView.backgroundColor = 0xAA00FF00;
        mainView.add(menuView);

        let menuBG = new("UIImage").init((0,0), (1,1), "BRODRUGS");
        menuBG.pinToParent();
        menuBG.noFilter = true;
        menuView.add(menuBG);

        youLostImage = new("UIImage").init((0,0), (780, 780), "BROLOSER");
        youLostImage.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        youLostImage.pin(UIPin.Pin_VCenter, value: 1.0, offset: customOffset.y, isFactor: true);
        youLostImage.hidden = true;
        youLostImage.noFilter = true;
        mainView.add(youLostImage);

        let youSuckText = new("UILabel").init((0,0), (780, 30), "PRESS ANY KEY", "PDA7FONT", 0xFF7E78C7, textAlign: UIView.Align_Center, fontScale: (4,4));
        youSuckText.noFilter = true;
        youSuckText.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        youSuckText.pin(UIPin.Pin_VCenter, value: 1.6, isFactor: true);
        youLostImage.add(youSuckText);

        highScoreEndLabel = new("RainbowLabel").init((0,0), (780, 30), "HIGH SCORE TEXT", "PDA7FONT", 0xFF7E78C7, textAlign: UIView.Align_Center, fontScale: (4,4));
        highScoreEndLabel.noFilter = true;
        highScoreEndLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        highScoreEndLabel.pin(UIPin.Pin_VCenter, value: 1.0, offset: -200, isFactor: true);
        youLostImage.add(highScoreEndLabel);
        highScoreEndLabel.hidden = true;
        RainbowLabel(highScoreEndLabel).isAParty = true;

        pauseMenuView = new("UIView").init((0,0), (780, 775));
        pauseMenuView.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        pauseMenuView.pin(UIPin.Pin_VCenter, value: 1.0, offset: customOffset.y, isFactor: true);
        pauseMenuView.backgroundColor = 0xAA000000;
        pauseMenuView.hidden = true;
        mainView.add(pauseMenuView);

        newGameButt = new("UIButton").init(
            (0,0),
            (360, 80),
            "", null,//"New Game", "PDA13FONT",
            UIButtonState.Create("BROBUTT0"),
            UIButtonState.Create("BROBUTT1", sound: "bro/menu1"),
            UIButtonState.Create("BROBUTT2"),
            UIButtonState.Create("BROBUT99")
        );
        newGameButt.clipsSubviews = false;
        newGameButt.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        newGameButt.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value: 0.646, offset: 0, isFactor: true);
        newGameButt.imgStyle = UIImage.Image_Center;
        newGameButt.imgScale = (4,4);
        newGameButt.noFilter = true;
        menuView.add(newGameButt);

        costImage = new("UIImage").init(
            (0,0),
            (104,52),
            "BROCOST"
        );
        costImage.noFilter = true;
        costImage.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 1.0, offset: 10, isFactor: true);
        costImage.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        newGameButt.add(costImage);
        costImage.hidden = LevelEventHandler.Instance().spaceBroPaidFor;


        highScoresButt = new("UIButton").init(
            (0,0),
            (420, 80),
            "", null,//"High Scores", "PDA13FONT",
            UIButtonState.Create("BROBUTT3"),
            UIButtonState.Create("BROBUTT4", sound: "bro/menu1"),
            UIButtonState.Create("BROBUTT5", sound: "bro/menu2")
        );
        highScoresButt.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        highScoresButt.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value: 0.646, offset: 95, isFactor: true);
        highScoresButt.imgStyle = UIImage.Image_Center;
        highScoresButt.imgScale = (4,4);
        highScoresButt.noFilter = true;
        menuView.add(highScoresButt);

        cashLabel = new("UILabel").init(
            (0,0), (400, 60),
            String.Format("CREDITS: %d", players[consoleplayer].mo.countInv("CreditsCount")),
            "PDA7FONT",
            //textAlign: UIView.Align_Centered,
            fontScale: (2,2)
        );
        //cashLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        cashLabel.pin(UIPin.Pin_Left, value: 1.0, offset: 45, isFactor: true);
        cashLabel.pin(UIPin.Pin_Bottom, value: 1.0, offset: 0, isFactor: true);
        cashLabel.noFilter = true;
        cashLabel.multiline = false;
        menuView.add(cashLabel);

        moneys = players[consolePlayer].mo.countInv('CreditsCount');
        displayedMoneys = moneys;

        navigateTo(newGameButt);

        highScoresButt.navUp = newGameButt;
        newGameButt.navDown = highScoresButt;

        // Pause menu header
        let pMenuHeader = new("UIImage").init(
            (0,0),
            (95, 24) * 2,
            "BROPAUSE"
        );
        pMenuHeader.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        pMenuHeader.pin(UIPin.Pin_VCenter, value: 1.0, offset: -150, isFactor: true);
        pMenuHeader.imgScale = (2,2);
        pMenuHeader.noFilter = true;
        pauseMenuView.add(pMenuHeader);

        // Pause menu controls
        let pMenuCtrls = new("UIImage").init(
            (0,0),
            (1, 1),
            "BROCTRLS",
            imgStyle: UIImage.Image_Absolute,
            imgAnchor: UIImage.ImageAnchor_Top
        );
        //pMenuCtrls.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        pMenuCtrls.pin(UIPin.Pin_Top, UIPin.Pin_VCenter, value: 1.0, offset: 100, isFactor: true);
        //pMenuCtrls.pinWidth(UIView.Size_Min);
        pMenuCtrls.pinHeight(UIView.Size_Min);
        pMenuCtrls.pin(UIPin.Pin_Left);
        pMenuCtrls.pin(UIPin.Pin_Right);
        //pMenuCtrls.pin(UIPin.Pin_);
        pMenuCtrls.imgScale = (2,2);
        pMenuCtrls.noFilter = true;
        pauseMenuView.add(pMenuCtrls);

        // Now pause menu buttons
        resumeGameButt = new("UIButton").init(
            (0,0),
            (200, 40),
            "", null,//"New Game", "PDA13FONT",
            UIButtonState.Create("BROBUTT6"),
            UIButtonState.Create("BROBUTT7", sound: "bro/menu1"),
            UIButtonState.Create("BROBUTT8", sound: "bro/menu2")
        );
        resumeGameButt.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        resumeGameButt.pin(UIPin.Pin_VCenter, value: 1.0, offset: -50, isFactor: true);
        resumeGameButt.imgStyle = UIImage.Image_Center;
        resumeGameButt.imgScale = (2,2);
        resumeGameButt.noFilter = true;
        pauseMenuView.add(resumeGameButt);


        endGameButt = new("UIButton").init(
            (0,0),
            (200, 40),
            "", null,//"High Scores", "PDA13FONT",
            UIButtonState.Create("BROBUTT9"),
            UIButtonState.Create("BROBUT10", sound: "bro/menu1"),
            UIButtonState.Create("BROBUT11", sound: "bro/menu2")
        );
        endGameButt.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        endGameButt.pin(UIPin.Pin_VCenter, value: 1.0, offset: -50 + 60, isFactor: true);
        endGameButt.imgStyle = UIImage.Image_Center;
        endGameButt.imgScale = (2,2);
        endGameButt.noFilter = true;
        pauseMenuView.add(endGameButt);

        endGameButt.navUp = resumeGameButt;
        resumeGameButt.navDown = endGameButt;


        // High Scores view ====================================

        highScoresView = new("UIView").init((0,0), (780, 780));
        highScoresView.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        highScoresView.pin(UIPin.Pin_VCenter, value: 1.0, offset: customOffset.y, isFactor: true);
        highScoresView.hidden = true;
        mainView.add(highScoresView);

        let hsBG = new("UIImage").init((0,0), (1,1), "BRODRUG2");
        hsBG.pinToParent();
        hsBG.noFilter = true;
        highScoresView.add(hsBG);

        // Add title label
        let hsTitle = new("UIImage").init((0,100), (1,1), "BROBUTT3", imgScale: (2,2));
        hsTitle.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        hsTitle.pinWidth(UIView.Size_Min);
        hsTitle.pinHeight(UIView.Size_Min);
        hsTitle.noFilter = true;
        highScoresView.add(hsTitle);

        // Add each line of text
        for(int x =0; x < highScoreLabels.size(); x++) {
            let hsl = new("RainbowLabel").init(
                (0, (x * 60) + 200), (600, 60),
                String.Format("%d    %s  %s", x, BaseStatusBar.FormatNumber(3984 * x * x, 9, 9, 2), "DAWN"),
                "PDA7FONT",
                textAlign: UIView.Align_Centered,
                fontScale: (4,4)
            );
            hsl.monospace = true;
            hsl.noFilter = true;
            hsl.multiline = false;
            hsl.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
            highScoresView.add(hsl);

            highScoreLabels[x] = hsl;
        }

        updateHighScores();

        // =====================================================

        // Add Dawn's reflection above the menu
        let dview = new("BRODawnView");
        dview.init((0,0), (100, 100));
        dview.pinToParent();
        dview.raycastTarget = false;
        menuView.add(dview);

        // Cabinet image covers everything
        cabinetImg = new("UIImage").init((0,0), (1242, 1698), "BROCABNT");
        cabinetImg.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        cabinetImg.pin(UIPin.Pin_VCenter, value: 1.0, offset: customOffset.y, isFactor: true);
        cabinetImg.noFilter = true;
        mainView.add(cabinetImg);


        // Get keybinds, and manually enter some where necessary
        /*Bindings.GetAllKeysForCommand(keysUp,       "+forward");
        Bindings.GetAllKeysForCommand(keysDown,     "+back");
        Bindings.GetAllKeysForCommand(keysLeft,     "+moveleft");
        Bindings.GetAllKeysForCommand(keysRight,    "+moveright");
        Bindings.GetAllKeysForCommand(keysBoost,    "+run");
        Bindings.GetAllKeysForCommand(keysBoost,    "+DashMode");
        Bindings.GetAllKeysForCommand(keysSpecial,  "+jump");
        Bindings.GetAllKeysForCommand(keysFire,     "+attack");

        // Convert to UI keys
        uiConvert(keysUp);
        uiConvert(keysDown);
        uiConvert(keysLeft);
        uiConvert(keysRight);
        uiConvert(keysBoost);
        uiConvert(keysSpecial);
        uiConvert(keysFire);*/

        // Add artificial binds too
        keysUp.push(UIEvent.Key_Up);
        keysDown.push(UIEvent.Key_Down);
        keysLeft.push(UIEvent.Key_Left);
        keysRight.push(UIEvent.Key_Right);
        if(keysSpecial.find(32) == keysSpecial.size()) keysSpecial.push(32);
        keysBoost.push(UIEvent.Key_Shift);
        keysFire.push(UIEvent.Key_Ctrl);

        keysUp.push(InputEvent.Key_Pad_DPad_Up);
        //keysUp.push(InputEvent.Key_Pad_Y);
        keysDown.push(InputEvent.Key_Pad_DPad_Down);
        keysLeft.push(InputEvent.Key_Pad_DPad_Left);
        keysRight.push(InputEvent.Key_Pad_DPad_Right);
        keysFire.push(InputEvent.Key_Pad_A);
        keysFire.push(InputEvent.Key_Pad_RTrigger);
        keysSpecial.push(InputEvent.Key_Pad_LTrigger);
        keysSpecial.push(InputEvent.Key_Pad_Y);
        keysBoost.push(InputEvent.Key_Pad_X);
        keysBoost.push(InputEvent.Key_Pad_LShoulder);
        
        /*keysLeft.push(InputEvent.Key_LeftArrow);
        keysRight.push(InputEvent.Key_RightArrow);
        keysUp.push(InputEvent.Key_UpArrow);
        keysDown.push(InputEvent.Key_DownArrow);
        keysBoost.push(InputEvent.Key_RShift);
        keysFire.push(InputEvent.Key_RCtrl);*/
    }

    void uiConvert(out Array<int> binds) {
        for(int x = 0; x < binds.size(); x++) {
            binds[x] = UIHelper.GetUIKey(binds[x]);
        }
    }

    bool isKey(Array<int> binds, int key) {
        for(int x =0; x < binds.size(); x++) {
            if(binds[x] == key) return true;
        }

        return false;
    }

    void logKey(int k) {
        keylog[keylogPos++] = k;
        if(keylogPos > 9) keylogPos = 0;
    }

    int prevKey(int num) {
        num += 1;
        if(num > 10) { num = 10; }
        num = keylogPos - num;
        if(num < 0) num = 10 + num;

        return keylog[num];
    }

    void updateHighScores() {
        let hsitem = SpaceBroScores.Find();
        
        if(hsitem) {
            for(int x = 0; x < highScoreLabels.size(); x++) {
                let hsl = RainbowLabel(highScoreLabels[x]);
                hsl.setText(String.Format("%d   %s  %s", x + 1, BaseStatusBar.FormatNumber(hsItem.scores[x], 9, 9, 2), hsItem.names[x]));

                hsl.isAParty = x == myLastHighScoreIndex;
            }
        }
    }


    // Translate keypresses into controls
    override bool OnUIEvent(UIEvent ev) {
        //Console.Printf("UI Event: %d %d %s", ev.type, ev.KeyChar, ev.KeyString);
        if(world.running && ev.type != UIEvent.Type_Char) {
            //Console.Printf("UI Event: %d %d %s", ev.type, ev.keyChar, ev.KeyString);

            let keyScan = ev.KeyChar;

            if(ev.type == UIEvent.Type_KeyDown) logKey(keyScan);

            bool buttonPressed = false;
            bool joyPressed = false;

            if(joyPressed = isKey(keysLeft, keyScan))                         world.playerShip.input.dir[SB_LEFT]   = ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_KeyRepeat;
            else if(joyPressed = isKey(keysRight, keyScan))                   world.playerShip.input.dir[SB_RIGHT]  = ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_KeyRepeat;
            else if(joyPressed = isKey(keysUp, keyScan))                      world.playerShip.input.dir[SB_UP]     = ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_KeyRepeat;
            else if(joyPressed = isKey(keysDown, keyScan))                    world.playerShip.input.dir[SB_DOWN]   = ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_KeyRepeat;
            else if(buttonPressed = isKey(keysFire, keyScan))                 world.playerShip.input.btn[0]         = ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_KeyRepeat;
            else if(buttonPressed = isKey(keysBoost, keyScan))                world.playerShip.input.btn[1]         = ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_KeyRepeat;
            else if(buttonPressed = isKey(keysSpecial, keyScan))              world.playerShip.input.btn[2]         = ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_KeyRepeat;

            if(buttonPressed && ev.type != UIEvent.Type_KeyRepeat) {
                S_StartSound(keySounds[random[ksound](0, keySounds.size() - 1)], CHAN_AUTO, CHANF_UI, BUTTONPRESS_VOLUME, frandom(0.92, 1.08));
            }

            if(joyPressed && ev.type != UIEvent.Type_KeyRepeat) {
                S_StartSound(joySounds[random[jsound](0, joySounds.size() - 1)], CHAN_AUTO, CHANF_UI, JOYPRESS_VOLUME, frandom(0.92, 1.08));
            }

            // Todo: Capture more keys for pause menu, like gamepad
            if(!skipPause && ev.type == UIEvent.Type_KeyDown && keyScan == UIEvent.Key_Escape) {
                midGamePause();

                return true;
            }

            checkCheats();
        } else if(!youLostImage.hidden) {
            if(ev.type < UIEvent.Type_FirstMouseEvent || ev.type == UIEvent.Type_LButtonClick) {
                stopBeingALoser();
                return true;
            }
        }

		return Super.OnUIEvent(ev);
	}

    void pauseGame() {
        showCursor();
        world.pauseGame();
        pauseMenuView.hidden = false;
        navigateTo(resumeGameButt);
    }

    override bool OnInputEvent(InputEvent ev) {
        //Console.Printf("Input Event: %d %d %s", ev.type, ev.KeyScan, ev.KeyString);
        
        if(world.running) {
            //Console.Printf("Input Event: %d %d %s", ev.type, ev.KeyScan, ev.KeyString);

            let keyScan = ev.KeyScan;

            if(ev.type == UIEvent.Type_KeyDown) logKey(keyScan);

            bool buttonPressed = false;
            bool joyPressed = false;
            if(joyPressed = isKey(keysLeft, keyScan))                         world.playerShip.input.dir[SB_LEFT]   = ev.type == InputEvent.Type_KeyDown;
            else if(joyPressed = isKey(keysRight, keyScan))                   world.playerShip.input.dir[SB_RIGHT]  = ev.type == InputEvent.Type_KeyDown;
            else if(joyPressed = isKey(keysUp, keyScan))                      world.playerShip.input.dir[SB_UP]     = ev.type == InputEvent.Type_KeyDown;
            else if(joyPressed = isKey(keysDown, keyScan))                    world.playerShip.input.dir[SB_DOWN]   = ev.type == InputEvent.Type_KeyDown;
            else if(buttonPressed = isKey(keysFire, keyScan))                 world.playerShip.input.btn[0]         = ev.type == InputEvent.Type_KeyDown;
            else if(buttonPressed = isKey(keysBoost, keyScan))                world.playerShip.input.btn[1]         = ev.type == InputEvent.Type_KeyDown;
            else if(buttonPressed = isKey(keysSpecial, keyScan))              world.playerShip.input.btn[2]         = ev.type == InputEvent.Type_KeyDown;

            if(buttonPressed) {
                S_StartSound(keySounds[random[ksound](0, keySounds.size() - 1)], CHAN_AUTO, CHANF_UI, BUTTONPRESS_VOLUME, frandom(0.92, 1.08));
            }

            if(joyPressed) {
                S_StartSound(joySounds[random[jsound](0, joySounds.size() - 1)], CHAN_AUTO, CHANF_UI, JOYPRESS_VOLUME, frandom(0.92, 1.08));
            }

            if(ev.type == UIEvent.Type_KeyDown && keyScan == UIEvent.Key_Escape) {
                pauseGame();

                return true;
            }

            checkCheats();
        }

        return Super.OnInputEvent(ev);
    }

    override bool TranslateKeyboardEvents() {
		return !world.running; 
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(gameStartDelay > 0) {
            return;
        }

        if(event == UIHandler.Event_Activated) {
            if(ctrl == newGameButt) {
                haskk = false;
                
                if(LevelEventHandler.Instance().spaceBroPaidFor) {
                    EventHandler.SendNetworkEvent("spaceBroStartedGame");  // Kill the initial purchase
                    S_StartSound("bro/menu2", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);
                    gameStartDelay = 7;

                } else {
                    EventHandler.SendNetworkEvent("spaceBroPurchase");  // purchase a game
                    //S_StartSound("bro/menu2", CHAN_AUTO, CHANF_UI, 0.2);
                    S_StartSound("vendingmachine/pay", CHAN_AUTO, CHANF_UI, 1);

                    gameStartDelay = 29;
                }
                
            } else if(ctrl == highScoresButt) {
                showHighScores();
            } else if(ctrl == endGameButt) {
                world.endGame();
                pauseMenuView.hidden = true;
                menuView.hidden = false;
                updateMainMenu();
                navigateTo(newGameButt);
            } else if(ctrl == resumeGameButt) {
                world.resumeGame();
                pauseMenuView.hidden = true;
                clearNavigation();
                showCursor(false);
            }
        }
        Super.handleControl(ctrl, event, fromMouseEvent);
    }

    void checkCheats() {
        // Check for cheat codes
        // TODO: Move this into the input event instead of checking every frame
        if(world.running) {
            // Extra lives and shit
            if( !haskk &&
                isKey(keysFire, prevKey(0)) && 
                isKey(keysBoost, prevKey(1)) &&
                isKey(keysRight, prevKey(2)) &&
                isKey(keysLeft, prevKey(3)) &&
                isKey(keysRight, prevKey(4)) &&
                isKey(keysLeft, prevKey(5)) &&
                isKey(keysDown, prevKey(6)) &&
                isKey(keysDown, prevKey(7)) &&
                isKey(keysUp, prevKey(8)) &&
                isKey(keysUp, prevKey(9)) ) {
                
                haskk = true;
                world.lives = 10;
                world.earth.health = 25;
                world.nukes = 5;
                logKey(0);  // Prevent this from happening every frame
            }
        }
    }

    override void ticker() {
        Super.ticker();

        if(players[consolePlayer].mo.health <= 0) {
            cleanClose();
        }

        if(curMusicVolume > targetMusicVolume) {
            curMusicVolume = MAX(targetMusicVolume, curMusicVolume - musicVolumeSteps);
            SetMusicVolume (curMusicVolume);
        }

        // Get input from the playerInfo struct
        if(world.running) {
            if(!world.playerShip.input.btn[0]) world.playerShip.input.btn[0] = players[consolePlayer].cmd.buttons & BT_ATTACK;
            if(!world.playerShip.input.btn[2]) world.playerShip.input.btn[2] = players[consolePlayer].cmd.buttons & BT_ALTATTACK || players[consolePlayer].cmd.buttons & BT_JUMP;
            if(!world.playerShip.input.dir[SB_UP]) world.playerShip.input.dir[SB_UP] = players[consolePlayer].cmd.buttons & BT_FORWARD || players[consolePlayer].cmd.buttons & BT_USE;
            if(!world.playerShip.input.dir[SB_RIGHT]) world.playerShip.input.dir[SB_RIGHT] = players[consolePlayer].cmd.buttons & BT_RIGHT;
            if(!world.playerShip.input.dir[SB_LEFT]) world.playerShip.input.dir[SB_LEFT] = players[consolePlayer].cmd.buttons & BT_LEFT;
        }

        world.tick();

        // Check for loss condition and end the game
        if(world.running && world.endGameTicks != 0 && world.ticks >= world.endGameTicks /*(!world.camera.target || (world.camera.pos - world.camera.target.pos).length() < 50)*/) {
            ticks = 0;
            EventHandler.SendNetworkEvent("spaceBroScore", world.score);
            world.endGame();
            showLoss();
            clearNavigation();
            S_StopSound(CHAN_7);    // Stop exploding sound if it's playing
            S_StartSound("bro/gameover", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);
        }

        // Smooth me baby
        // Uncomment this line if you want silky smooth gameplay that looks strangely unnatural
        animated = iGetCVar("bruverclock") > 0;

        if(LevelEventHandler.Instance().spaceBroCabinet == null) {
            cleanClose();
            return;
        }

        if(gameStartDelay > 0) {
            gameStartDelay--;
            
            if(gameStartDelay == 0) {
                startGame();
            }
        }

        if(!menuView.hidden) {
            // Messy and lazy!
            moneys = players[consolePlayer].mo.countInv('CreditsCount');
            bool hasEnuffmuns = moneys >= 10;
            displayedMoneys += MAX(-2, moneys - displayedMoneys);
            cashLabel.text = String.Format("CREDITS: %d", displayedMoneys);
            cashLabel.textColor = hasEnuffmuns ? 0xFFC2B557 : 0xFFCC0000;
        }

        skipPause = false;
    }

    void startGame() {
        S_StartSound("bro/newgame", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);

        //world.startNewGame(iGetCVAR("skill") == 5 ? 2.2 : 0.2);
        world.startNewGame(0.2);
        menuView.hidden = true;
        pauseMenuView.hidden = true;
        youLostImage.hidden = true;
        highScoresView.hidden = true;

        clearNavigation();
        showCursor(false);
    }

    void updateMainMenu() {
        bool hasEnuffmuns = players[consolePlayer].mo.countInv("CreditsCount") >= 10;
        newGameButt.setDisabled(!hasEnuffmuns);

        if(newGameButt.isDisabled()) {
            navigateTo(highScoresButt);
        }

        costImage.hidden = LevelEventHandler.Instance().spaceBroPaidFor;
    }

    void showLoss() {
        youLostImage.setImage(world.earth.health <= 0 ? "BROLOSE2" : "BROLOSER");
        youLostImage.hidden = false;
        clearNavigation();

        // If we happen to have a high score, show that here
        let hsitem = SpaceBroScores.Find();
        if(hsItem) {
            int pos = hsItem.isHighScore(world.score);
            if(pos >= 0) {
                myLastHighScoreIndex = pos;

                // Show high score text!
                highScoreEndLabel.hidden = false;
                highScoreEndLabel.setText(String.Format("HIGH SCORE: %s!", BaseStatusBar.FormatNumber(world.score, 9, 9, 2)));
            }
        } else {
            myLastHighScoreIndex = -1;

            // Hide high score text
            highScoreEndLabel.hidden = true;
        }
    }

    void showHighScores() {
        updateHighScores();
        highScoresView.hidden = false;
        menuView.hidden = true;
        clearNavigation();
    }

    override void calcScale(int screenWidth, int screenHeight, Vector2 baselineResolution) {
        // Special case for 720p, we don't want to crunch the pixels too hard
        /*if(screenHeight >= 720 && screenHeight < 1080) {
            lastUIScale = uiScale;
            let newScale = 0.75;
            mainView.frame.size = (screenWidth / newScale, screenHeight / newScale);
            mainView.scale = (newScale, newScale);
            customOffset = (0, -20);

            if(cabinetImg) {
                cabinetImg.firstPin(UIPin.Pin_VCenter).offset = customOffset.y;
            }
            
            return;
        }*/

        let newScale = round(double(screenHeight / baselineResolution.y) * 4.0) / 4.0;
        lastUIScale = newScale;
        mainView.frame.size = (screenWidth / newScale, screenHeight / newScale);
        mainView.scale = (newScale, newScale);


        customOffset = (0, -50);

        //Super.calcScale(screenWidth, screenHeight, baselineResolution);

        if(cabinetImg) {
            cabinetImg.firstPin(UIPin.Pin_VCenter).offset = customOffset.y;
        }

        if(menuView) {
            menuView.firstPin(UIPin.Pin_VCenter).offset = customOffset.y;
        }
	}

    const dawnLen = 1.5;
    override void drawSubviews() {
        double tm = System.GetTimeFrac();

        mainView.clip(-389 + customOffset.x, -392 + customOffset.y, 778, 784, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER);

        if(world.running || pauseMenuView.hidden == false) {
            world.screensize = (Screen.GetWidth(), Screen.GetHeight());
            world.virtualScreenSize = mainView.frame.size;
            world.draw(pauseMenuView.hidden ? tm : 1, 2.0, mainView.scale.x, customOffset);
        }
        
        Super.drawSubviews();
    }

    void cleanClose() {
        // Tell the HUD to stop shutting up
        let h = HUD(StatusBar);
        if(h) {
            h.isMuted = false;
        }
        
        if(world && world.running) {
            world.endGame();
        }
        
        // Just in case music is somehow still playing
        S_StopSound(8);
        SetMusicVolume (Level.MusicVolume);

        EventHandler.SendNetworkEvent("spaceBroOver");

        Close();
    }


    bool midGamePause() {
        if(pauseMenuView.hidden == false) {
            pauseMenuView.hidden = true;
            clearNavigation();
            world.resumeGame();
            skipPause = true;
            return true;
        } else if(world.running) {
            pauseGame();
            return true;
        }

        return false;
    }


    override bool onBack() {
        if(!highScoresView.hidden) {
            highScoresView.hidden = true;
            menuView.hidden = false;
            updateMainMenu();
            navigateTo(newGameButt);
            return true;
        }

        if(!youLostImage.hidden) {
            stopBeingALoser();
            return true;
        }

        if(midGamePause())  {
            return true;
        }

        cleanClose();
		return true;
	}


    void stopBeingALoser() {
        if(ticks > 88) {
            if(myLastHighScoreIndex >= 0) {
                // Show high scores if we got one
                menuView.hidden = false;
                youLostImage.hidden = true;
                pauseMenuView.hidden = true;
                showHighScores();
            } else {
                // We suck, show main menu
                updateMainMenu();
                youLostImage.hidden = true;
                pauseMenuView.hidden = true;
                highScoresView.hidden = true;
                menuView.hidden = false;
                navigateTo(newGameButt);
            }
            
            Screen.SetCursor("MOUSE");
        }
    }
}


class BRODawnView : UIView {
    const dawnLen = 2;

    override void tick() {
        double time = getMenu().getRenderTime();

        if(time > dawnLen) {
            removeFromSuperview();
        }
    }

    override void draw() {
        double time = getMenu().getRenderTime();

        if(time < dawnLen) {
            UIBox clipRect;
            getScreenClip(clipRect);
            Screen.setClipRect(int(clipRect.pos.x), int(clipRect.pos.y), int(clipRect.size.x), int(clipRect.size.y));
                
            TextureID tid = TexMan.checkForTexture("BROGIRL", TexMan.Type_Any);
            Vector2 ts = TexMan.GetScaledSize(tid);
            
            double scWidth = Screen.GetWidth();
		    double scHeight = Screen.GetHeight();
            double tm = time / dawnLen;
            double sc = UIMath.EaseOutXYA(1.035, 1.0, tm);

            double x = (scWidth / 2.0) - ((scWidth * sc) / 2.0);
            double y = (scHeight / 2.0) - ((scHeight * sc) / 2.0) + 
                        (sin(MSTime() * 0.2) * UIMath.EaseOutXYA(3.0, 6.0, tm));

            // Draw
            Screen.DrawTexture(tid, false, x, y, 
                DTA_DestWidthF, scWidth * sc,
                DTA_DestHeightF, scHeight * sc,
                DTA_ALPHA, 0.65 * UIMath.EaseInCubicF(1.0 - (tm)));
        }
    }
}


class RainbowLabel : UILabel {
    bool isAParty;
    int originalColor;

    uint ticks;

    // Cheap hack to create a party!
    override void tick() {
        if(ticks == 0) originalColor = self.textColor;

        Super.tick();

        if(isAParty && ticks % 3 == 0) {
            self.textColor = Color(
                255,
                random[col](127, 255),
                random[col](127, 255),
                random[col](127, 255)
            );
        } else if(!isAParty) {
            textColor = originalColor;
        }

        ticks++;
    }
}