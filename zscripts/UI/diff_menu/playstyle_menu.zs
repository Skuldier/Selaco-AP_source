class PlaystyleMenuHandler : EventHandler {
    Actor mActivator;
    string success;

    static void ShowMenu(Actor activator, string successScript) {
        if(activator && activator.player) {
            let evt = PlaystyleMenuHandler(EventHandler.Find("PlaystyleMenuHandler"));
            if (evt) {
                evt.mActivator = activator;
                evt.success = successScript;
                Menu.SetMenu("PlaystyleMenu");
            }
        }
    }

    override void NetworkProcess(ConsoleEvent e) {
        Array<String> cmds;
        e.Name.Split(cmds, ":");

        if(cmds.Size() > 1) {
            if(cmds[0] == "playstyle") {
                int res = cmds[1].ToInt(10);

                if(res == 1) {
                    mActivator.giveInventory("HardcoreMode", 1);
                    //Turn on disableautosave
                }

                if(success != "") {
                    mActivator.ACS_NamedExecute(success, res);
                }

                // Self destruct, since we won't select playstyle again this session
                if (!bDESTROYED)
                    Destroy();
            }
        }
    }
}


class PlaystyleButtonHandler : UIHandler {
    PlaystyleMenu pm;

    override void handleEvent(int type, UIControl con, bool fromMouseEvent, bool fromcontrollerEvent) { 
        if(type == Event_Activated) {
            let cv = CVar.GetCVar("disableautosave");
            if(cv) cv.setInt(1);
            
            EventHandler.SendNetworkEvent(con == pm.btn2 ? "playstyle:1" : "playstyle:0");
            
            pm.cleanClose();
        }
    }
}

class PlaystyleMenu : UIMenu {
    PlaystyleButton btn1, btn2;
    PlaystyleButtonHandler handler;
    UIImage bgView;


    double startTime;

    const fadeTime = 0.6;

    override void init(Menu parent) {
		Super.init(parent);
        //calcScale(Screen.GetWidth(), Screen.GetHeight());

        handler = new("PlaystyleButtonHandler");
        handler.pm = self;

        menuActive = Menu.OnNoPause;    // This prevents the game from pausing when we open the menu

        bgView = new("UIImage").init((0, 0), (mainView.frame.size.x, mainView.frame.size.y), "HUDMENU",
            NineSlice.Create("HUDMENU", (53, 85), (1827, 945), drawCenter: false)
        );
        mainView.add(bgView);
        bgView.pinWidth(1.0, isFactor: true);
        bgView.pinHeight(1.0, isFactor: true);


        let mainLabel = new("UILabel").init((0, 60), (2056, 40), "SELECT A PLAYSTYLE", "SELACOFONT", Font.CR_WHITE, UIView.Align_Centered, (1.75, 1.75));
        mainView.add(mainLabel);
        mainLabel.pin(UIPin.Pin_Left, UIPin.Pin_Left, 1.0);
        mainLabel.pin(UIPin.Pin_Right, UIPin.Pin_Right, 1.0);
        mainLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_VCenter, 1.0, -340);

        btn1 = new("PlaystyleButton").init((535, 205), (650, 630),
            null,
            UIButtonState.CreateSlices("MODESELC", (8,8), (18, 18), sound: "ui/playhover"),
            UIButtonState.CreateSlices("MODESELD", (8,8), (18, 18))
        );
        btn1.handler = handler;
        mainView.add(btn1);
        btn1.pin(UIPin.Pin_Right, UIPin.Pin_HCenter, 1, -25);
        btn1.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, 1);

        btn2 = new("PlaystyleButton").init((1235, 205), (650, 630),
            null,
            UIButtonState.CreateSlices("MODESELC", (8,8), (18, 18), sound: "ui/playhover"),
            UIButtonState.CreateSlices("MODESELD", (8,8), (18, 18))
        );
        btn2.handler = handler;
        mainView.add(btn2);
        btn2.pin(UIPin.Pin_Left, UIPin.Pin_HCenter, 1, 25);
        btn2.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, 1);

        btn1.navRight = btn2;
        btn2.navLeft = btn1;

        // Subviews for button 1
        let label = new("UILabel").init((0, 60), (650, 40), "Traditional Mode", "SELACOFONT", 0xFFB0C6F7, UIView.Align_Centered, (1.78, 1.78));
        btn1.add(label);

        let textBG = new("UIImage").init((20, 100), (610, 182), "MODESELB");
        btn1.add(textBG);

        let label2 = new("UILabel").init((20, 0), (570, 182), UIHelper.FilterKeybinds(Stringtable.Localize("$PLAYSTYLE_TRAD")), "SELOFONT", Font.CR_WHITE, UIView.Align_Centered);
        textBG.add(label2);
        
        let img = new("UIImage").init((0, 310), (650, 225), "MODESEL3", imgStyle: UIImage.Image_Center);
        btn1.add(img);


        // Subviews for button 2
        label = new("UILabel").init((0, 60), (650, 40), "Hardcore Mode", "SELACOFONT", 0xFFB0C6F7, UIView.Align_Centered, (1.78, 1.78));
        btn2.add(label);

        textBG = new("UIImage").init((20, 100), (610, 182), "MODESELB");
        btn2.add(textBG);

        label2 = new("UILabel").init((20, 0), (570, 182), UIHelper.FilterKeybinds(Stringtable.Localize("$PLAYSTYLE_HARD")), "SELOFONT", Font.CR_WHITE, UIView.Align_Centered);
        textBG.add(label2);
        
        img = new("UIImage").init((0, 310), (650, 225), "MODESEL4", imgStyle: UIImage.Image_Center);
        btn2.add(img);

        startTime = getTime();
        mainView.alpha = 0;
	}

    override void ticker() {
        Super.ticker();

        double time = getTime();
        if(time - startTime <= fadeTime) {
            mainView.setAlpha((time - startTime) / fadeTime);
        } else if(mainView.alpha < 1.0) {
            mainView.setAlpha(1.0);
        }

        mainView.layout();
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
		if(!activeControl) {
            switch (mkey) {
                case MKEY_Left:
                    if(navigateTo(btn1)) return true;
                    break;
                case MKEY_Right:
                    if(navigateTo(btn2)) return true;
                    break;
                default:
                    break;
            }
        }
        

		return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool onBack() {
        return true;    // Cancel back/close commands
    }

    void cleanClose() {
        // TODO: Add animation on close
        close();
    }
}


class PlaystyleButton : UIButton {
    const fadeOutTick = 0.035;
    const fadeInTick = 0.15;

    PlaystyleButton init(Vector2 pos, Vector2 size,
                            UIButtonState normal,
                            UIButtonState hover = null,
                            UIButtonState pressed = null,
                            UIButtonState disabled = null,
                            UIButtonState selected = null,
                            UIButtonState selectedHover = null,
                            UIButtonState selectedPressed = null) {

        Super.init( pos, size, "", null,
                    normal,
                    hover,
                    pressed,
                    disabled,
                    selected,
                    selectedHover,
                    selectedPressed );
                    
        cancelsSubviewRaycast = true;

        return self;
    }

    override void tick() {
        Super.tick();

        if(mouseInside || activeSelection) {
            if(alpha < 1.0) {
                setAlpha(alpha + fadeInTick);
            }
        } else {
            if(alpha > 0.25) {
                setAlpha(MAX(0.25, alpha - fadeOutTick));
            }
        }
    }

    override void onMouseEnter(Vector2 pos) {
        Super.onMouseEnter(pos);
    }

    override void onMouseExit(Vector2 pos, UIView m) {
        Super.onMouseExit(pos, m);

        let m = getMenu();
        if(m) {
            m.clearNavigation();
        }
    }
}


