class DeathMenu : SelacoGamepadMenu {
    TitleButton loadButton, continueButton, quitButton;
    UILabel hintLabel;
    UIView divider;

    static const string GENERAL_TIPS[] = {
        "$DEATH_TUTORIAL_GENERAL_01",
        "$DEATH_TUTORIAL_GENERAL_02",
        "$DEATH_TUTORIAL_GENERAL_03",
        "$DEATH_TUTORIAL_GENERAL_04",
        "$DEATH_TUTORIAL_GENERAL_05",
        "$DEATH_TUTORIAL_GENERAL_06",
        "$DEATH_TUTORIAL_GENERAL_07",
        "$DEATH_TUTORIAL_GENERAL_08",
        "$DEATH_TUTORIAL_GENERAL_09",
        "$DEATH_TUTORIAL_GENERAL_10",
        "$DEATH_TUTORIAL_GENERAL_11",
        "$DEATH_TUTORIAL_GENERAL_12",
        "$DEATH_TUTORIAL_GENERAL_13",
        "$DEATH_TUTORIAL_GENERAL_14",
        "$DEATH_TUTORIAL_GENERAL_15",
        "$DEATH_TUTORIAL_GENERAL_16",
        "$DEATH_TUTORIAL_GENERAL_17",
        "$DEATH_TUTORIAL_GENERAL_18",
        "$DEATH_TUTORIAL_GENERAL_19",
        "$DEATH_TUTORIAL_GENERAL_20",
        "$DEATH_TUTORIAL_GENERAL_21",
        "$DEATH_TUTORIAL_GENERAL_22",
        "$DEATH_TUTORIAL_GENERAL_23",
        "$DEATH_TUTORIAL_GENERAL_24",
        "$DEATH_TUTORIAL_GENERAL_25",
        "$DEATH_TUTORIAL_GENERAL_26",
        "$DEATH_TUTORIAL_GENERAL_27",
        "$DEATH_TUTORIAL_GENERAL_28",
        "$DEATH_TUTORIAL_GENERAL_29",
        "$DEATH_TUTORIAL_GENERAL_30",
        "$DEATH_TUTORIAL_GENERAL_31",
        "$DEATH_TUTORIAL_GENERAL_32",
        "$DEATH_TUTORIAL_GENERAL_33",
        "$DEATH_TUTORIAL_GENERAL_34",
        "$DEATH_TUTORIAL_GENERAL_35",
        "$DEATH_TUTORIAL_GENERAL_36",
        "$DEATH_TUTORIAL_GENERAL_37",
        "$DEATH_TUTORIAL_GENERAL_38",
        "$DEATH_TUTORIAL_GENERAL_39",
        "$DEATH_TUTORIAL_GENERAL_40",
        "$DEATH_TUTORIAL_GENERAL_41",
        "$DEATH_TUTORIAL_GENERAL_42",
        "$DEATH_TUTORIAL_GENERAL_43",
        "$DEATH_TUTORIAL_GENERAL_44"
    };


    static const string PLASMATROOPER_TIPS[] =
    {
        "$DEATH_TUTORIAL_PLASMATROOPER_01",
        "$DEATH_TUTORIAL_PLASMATROOPER_02",
        "$DEATH_TUTORIAL_PLASMATROOPER_03",
        "$DEATH_TUTORIAL_PLASMATROOPER_04",
        "$DEATH_TUTORIAL_PLASMATROOPER_05",
        "$DEATH_TUTORIAL_PLASMATROOPER_06"
    };

    static const string CRAWLERMINE_TIPS[] =
    {
        "$DEATH_TUTORIAL_CRAWLERMINE_01",
        "$DEATH_TUTORIAL_CRAWLERMINE_02",
        "$DEATH_TUTORIAL_CRAWLERMINE_03",
        "$DEATH_TUTORIAL_CRAWLERMINE_04",
        "$DEATH_TUTORIAL_CRAWLERMINE_05",
        "$DEATH_TUTORIAL_CRAWLERMINE_06"
    };

    static const string ENFORCER_TIPS[] =
    {
        "$DEATH_TUTORIAL_ENFORCER_01",
        "$DEATH_TUTORIAL_ENFORCER_02",
        "$DEATH_TUTORIAL_ENFORCER_03",
        "$DEATH_TUTORIAL_ENFORCER_04"
    };

    static const string SAWDRONE_TIPS[] =
    {
        "$DEATH_TUTORIAL_SAWDRONE_01",
        "$DEATH_TUTORIAL_SAWDRONE_02",
        "$DEATH_TUTORIAL_SAWDRONE_03",
        "$DEATH_TUTORIAL_SAWDRONE_04",
        "$DEATH_TUTORIAL_SAWDRONE_05"
    };

    static const string  ENGINEER_TIPS[] = {
        "$DEATH_TUTORIAL_ENGINEER_01",
        "$DEATH_TUTORIAL_ENGINEER_02",
        "$DEATH_TUTORIAL_ENGINEER_03",
        "$DEATH_TUTORIAL_ENGINEER_04",
        "$DEATH_TUTORIAL_ENGINEER_05"
    };

    static const string  SENTRY_TIPS[] = {
        "$DEATH_TUTORIAL_SENTRYGUN_01",
        "$DEATH_TUTORIAL_SENTRYGUN_02",
        "$DEATH_TUTORIAL_SENTRYGUN_03",
        "$DEATH_TUTORIAL_SENTRYGUN_04",
        "$DEATH_TUTORIAL_SENTRYGUN_05",
        "$DEATH_TUTORIAL_SENTRYGUN_06"
    };

    static const string  JUGGERNAUT_TIPS[] = {
        "$DEATH_TUTORIAL_JUGGERNAUT_01",
        "$DEATH_TUTORIAL_JUGGERNAUT_02",
        "$DEATH_TUTORIAL_JUGGERNAUT_03",
        "$DEATH_TUTORIAL_JUGGERNAUT_04",
        "$DEATH_TUTORIAL_JUGGERNAUT_05",
        "$DEATH_TUTORIAL_JUGGERNAUT_06",
        "$DEATH_TUTORIAL_JUGGERNAUT_07",
        "$DEATH_TUTORIAL_JUGGERNAUT_08",
        "$DEATH_TUTORIAL_JUGGERNAUT_09",
        "$DEATH_TUTORIAL_JUGGERNAUT_10"
    };

    static const string  SIEGER_TIPS[] = {
        "$DEATH_TUTORIAL_SIEGER_01",
        "$DEATH_TUTORIAL_SIEGER_02",
        "$DEATH_TUTORIAL_SIEGER_03",
        "$DEATH_TUTORIAL_SIEGER_04",
        "$DEATH_TUTORIAL_SIEGER_05"
    };



    override void init(Menu parent) {
		Super.init(parent);
        DontDim = true;
        DontBlur = true;
        Animated = true;

        let layout = new("UIVerticalLayout").init((0,0), (500, 100));
        layout.layoutMode = UIViewManager.Content_SizeParent;
        layout.clipsSubviews = false;
        layout.pin(UIPin.Pin_Left, offset: 140);
        layout.pinWidth(800);
        layout.pin(UIPin.Pin_Bottom, offset: -180);
        mainView.add(layout);

        let descLabel = new("UILabel").init(
            (0,0), (500, 45),
            StringTable.Localize("$PLAYER_DEAD"),
            "SEL21FONT"
        );
        descLabel.multiline = false;
        descLabel.pin(UIPin.Pin_Left, offset: 10);
        descLabel.pin(UIPin.Pin_Right);
        descLabel.pinHeight(UIView.Size_Min);
        layout.addManaged(descLabel);

        layout.addSpacer(15);
        
        let hiState = CommonUI.barBackgroundState();
        hiState.textColor = 0xFFB4B4FF;

        continueButton = TitleButton(new("TitleButton").init(
            (0,0), (350, 40),
            "$PLAYER_CONTINUE", "SEL27OFONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            UIButtonState.Create("", 0xFFB4B4FF),
            textAlign: UIView.Align_Left | UIView.Align_Middle
        ));
        continueButton.setTextPadding(10, 5, 0, 5);
        continueButton.label.fontScale = (0.87, 0.87);
        continueButton.originalFontScale = (0.87, 0.87);
        continueButton.maxSize.x = 500;
        continueButton.pinHeight(UIView.Size_Min);
        continueButton.pinWidth(1.0, isFactor: true);
        continueButton.buttonIndex = 0;

        loadButton = TitleButton(new("TitleButton").init(
            (0,0), (350, 40),
            "$PLAYER_LOADGAME", "SEL27OFONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            UIButtonState.Create("", 0xFFB4B4FF),
            textAlign: UIView.Align_Left | UIView.Align_Middle
        ));
        loadButton.setTextPadding(10, 5, 0, 5);
        loadButton.label.fontScale = (0.87, 0.87);
        loadButton.originalFontScale = (0.87, 0.87);
        loadButton.maxSize.x = 500;
        loadButton.pinHeight(UIView.Size_Min);
        loadButton.pinWidth(1.0, isFactor: true);
        loadButton.buttonIndex = 1;

        quitButton = TitleButton(new("TitleButton").init(
            (0,0), (350, 40),
            "$PLAYER_QUITTOMENU", "SEL27OFONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            UIButtonState.Create("", 0xFFB4B4FF),
            textAlign: UIView.Align_Left | UIView.Align_Middle
        ));
        quitButton.setTextPadding(10, 5, 0, 5);
        quitButton.label.fontScale = (0.87, 0.87);
        quitButton.originalFontScale = (0.87, 0.87);
        quitButton.maxSize.x = 500;
        quitButton.pinHeight(UIView.Size_Min);
        quitButton.pinWidth(1.0, isFactor: true);
        quitButton.buttonIndex = 2;

        layout.addManaged(continueButton);
        layout.addManaged(loadButton);
        layout.addManaged(quitButton);
        layout.addSpacer(40);

        // Add a divider line
        divider = new("UIView").init((0,0), (10, 2));
        divider.pin(UIPin.Pin_Left, offset: 10);
        divider.pinWidth(1.0, isFactor: true);
        divider.maxSize.x = 490;
        divider.backgroundColor = 0x33666666;
        divider.alpha = 0;
        layout.addManaged(divider);

        layout.addSpacer(10);

        hintLabel = new("UILabel").init(
            (0,0), (500, 45),
            StringTable.Localize("This is a hint of how you could have maybe not sucked at the game before dying."),
            "PDA16FONT"
        );
        hintLabel.multiline = true;
        hintLabel.pin(UIPin.Pin_Left, offset: 10);
        hintLabel.pinHeight(UIView.Size_Min);
        hintLabel.pinWidth(UIView.Size_Min);
        hintLabel.clipsSubviews = false;
        hintLabel.alpha = 0;
        if(iGetCvar("g_showDeathTips") > 0) layout.addManaged(hintLabel);

        continueButton.navDown = loadButton;
        loadButton.navUp = continueButton;
        loadButton.navDown = quitButton;
        quitButton.navUp = loadButton;

        navigateTo(continueButton);


        // Set the tips message
        Dawn girlCaptainDown = Dawn(players[consolePlayer].mo);
		switch(girlCaptainDown && girlCaptainDown.deathSource ? girlCaptainDown.deathSource.getClassName() : 'none') 
        {
			case 'Engineer':
				hintLabel.setText(StringTable.Localize(ENGINEER_TIPS[random(0,ENGINEER_TIPS.size() - 1)]));
				break;
			case 'SentryGunTurret':
				hintLabel.setText(StringTable.Localize(SENTRY_TIPS[random(0,SENTRY_TIPS.size() - 1)]));
				break;
			case 'Juggernaut':
				hintLabel.setText(StringTable.Localize(JUGGERNAUT_TIPS[random(0,JUGGERNAUT_TIPS.size() - 1)]));
				break;
			case 'Sieger':
				hintLabel.setText(StringTable.Localize(SIEGER_TIPS[random(0,SIEGER_TIPS.size() - 1)]));
				break;
			default:
                hintLabel.setText(StringTable.Localize(GENERAL_TIPS[random(0,GENERAL_TIPS.size() - 1)]));
				break;
		}

        // Crawler Mines cease to exist, so we cant reference their Object.
        if(girlCaptainDown && girlCaptainDown.deathSourceName == "CrawlerMine")
        {
            hintLabel.setText(StringTable.Localize(CRAWLERMINE_TIPS[random(0,CRAWLERMINE_TIPS.size() - 1)]));
        }

        if(girlCaptainDown && girlCaptainDown.deathSource && girlCaptainDown.deathSource is "Enforcer")
        {
            hintLabel.setText(StringTable.Localize(ENFORCER_TIPS[random(0,ENFORCER_TIPS.size() - 1)]));
        }

        if(girlCaptainDown && girlCaptainDown.deathSource && girlCaptainDown.deathSource is "SAWDRONE")
        {
            hintLabel.setText(StringTable.Localize(SAWDRONE_TIPS[random(0,SAWDRONE_TIPS.size() - 1)]));
        }

        if(girlCaptainDown && girlCaptainDown.deathSource is "PlasmaTrooper")
        {
            hintLabel.setText(StringTable.Localize(PLASMATROOPER_TIPS[random(0,PLASMATROOPER_TIPS.size() - 1)]));
        }

        // Fall Damage Death Tip
        if(girlCaptainDown && girlCaptainDown.deathMeans == "FALLDAMAGE")
        {
            hintLabel.setText(StringTable.Localize("$DEATH_TUTORIAL_FALLDAMAGE_01"));
        }

    }


    override void onFirstTick() {
        Super.onFirstTick();

        hintLabel.animateFrame(
            0.5,
            fromAlpha: 0.0,
            toAlpha: 0.7,
            ease: Ease_Out
        );

        divider.animateFrame(
            0.5,
            fromAlpha: 0.0,
            toAlpha: 1,
            ease: Ease_Out
        );
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl == quitButton) {
                Level.ReturnToTitle();
            } else if(ctrl == loadButton) {
                Menu.SetMenu("LoadSelacoMenu");
            } else if(ctrl == continueButton) {
                menuActive = Menu.OnNoPause;
                Close();
                EventHandler.SendNetworkEvent("continue");
            }
        }
    }

    override bool onBack() {
        return true;
    }
}