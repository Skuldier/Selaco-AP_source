class LevelSelectMenu : SelacoGamepadMenu {
    Array<UIButton> butts;
    UIVerticalLayout buttLayout;
    StandardBackgroundContainer background;
    int startGameSkill;

    LevelSelectMenu init(Menu parent, int skill) {
        Super.init(parent);
        
        allowDimInGameOnly();
        Animated = true;

        startGameSkill = skill;

        calcScale(Screen.GetWidth(), Screen.GetHeight());

        background = CommonUI.makeStandardBackgroundContainer(title: "Level Select");
        mainView.add(background);

        if(JoystickConfig.NumJoysticks()) {
            background.addGamepadFooter(InputEvent.Key_Pad_B, "Back");
        }

        // Create containers
        buttLayout = new("UIVerticalLayout").init((0,0), (500, 100));
        buttLayout.pinToParent();
        background.add(buttLayout);

        // List of skills
        // Since we don't have access to GZs skill settings yet, let's just create the skills manually here
        UIControl lastCon;
        for(int x = 1; x < 9; x++) {
            string levName = String.Format("SE_0%dA", x);
            let info = LevelInfo.FindLevelInfo(levName);
            if(!info) continue;
            let con = new("SkillMenuButton").init(String.Format("LEVEL %d - %s", x, info.LevelName), "", x);
            if(lastCon) {
                con.navUp = lastCon;
                lastCon.navDown = con;
            }
            lastCon = con;
            buttLayout.addManaged(con);
        }

        // Select Commander skill by default 
        navigateTo(UIControl(buttLayout.getManaged(0)));

        mainView.requiresLayout = true;

        return self;
    }


    void startGame(int lev) {
        // Tell the intro-handler that a new game is starting
        let handler = IntroHandler(StaticEventHandler.Find("IntroHandler"));
        if(handler) {
            handler.notifyNewGame();
        }
        
        Level.StartNewGame(0, startGameSkill, "Dawn", String.Format("SE_0%dA", lev));
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(event == UIHandler.Event_Activated) {
            let b = SkillMenuButton(ctrl);

            if(b) {
                StartGame(b.skill);
            }
        }
    }
}