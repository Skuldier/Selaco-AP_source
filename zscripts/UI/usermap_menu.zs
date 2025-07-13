class UsermapInfo {
    string name, mapname, path;
    int lump, wadnum;
    LevelInfo info;
}


class UsermapMenu : SelacoGamepadMenu {
    StandardBackgroundContainer background;
    UILabel titleLabel, noMaps, authorLabel, levelTitleLabel, mapInternalNameLabel, pathLabel, descriptionLabel;
    UIVerticalScroll scrollView;
    UIVerticalLayout detailLayout;
    UIImage mapImage, detailBackground;
    bool closing;
    double dimStart;
    int lastIndex;

    Array<UsermapInfo> maps;
    Array<UIButton> mapButts;
    
    override void init(Menu parent) {
		Super.init(parent);

        DontBlur = level.MapName == "TITLEMAP";
        dimStart = MSTime() / 1000.0;

        [background, titleLabel] = CommonUI.makeStandardBackgroundContainer(title: "User Maps");
        mainView.add(background);

        // If there is a joystick connected, add the gamepad footer
        if(JoystickConfig.NumJoysticks()) {
            background.addGamepadFooter(InputEvent.Key_Pad_B, "Back");
        }
        
        // Reset new game settings
        UIHelper.ResetNewGameOptions();
        

        scrollView = new("LoadSelacoScroll").init((0,0), (0,0), 30, 24,
            NineSlice.Create("graphics/options_menu/slider_bg_vertical.png", (14, 6), (16, 24)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_selected.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_selected.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down_selected.png", (8,8), (13,13))
        );

        scrollView.pin(UIPin.Pin_Left);
        scrollView.pin(UIPin.Pin_Top);
        scrollView.pin(UIPin.Pin_Right, UIPin.Pin_HCenter, value: 1.0, offset: -13, isFactor: true);
        scrollView.pin(UIPin.Pin_Bottom);
        scrollView.mLayout.itemSpacing = 5;
        scrollView.mLayout.clipsSubviews = false;
        scrollView.autoHideScrollbar = true;
        scrollView.rejectHoverSelection = true;
        scrollView.mLayout.ignoreHiddenViews = true;
        background.add(scrollView);

        noMaps = new('UILabel').init((0,0), (1,1), "No User Maps present!", 'PDA16FONT');
        noMaps.pin(UIPin.Pin_Left, offset: 0);
        noMaps.pin(UIPin.Pin_Right, offset: -40);
        noMaps.pinHeight(UIView.Size_Min);
        noMaps.hidden = true;
        scrollView.add(noMaps);


        detailBackground = new("UIImage").init((0,0), (1,1), "SAVEBG03");
        detailBackground.pinWidth(0.5, offset: 13, isFactor: true);
        detailBackground.pin(UIPin.Pin_Right);
        detailBackground.pin(UIPin.Pin_Top, offset: 0);
        detailBackground.pin(UIPin.Pin_Bottom);
        background.add(detailBackground);

        detailLayout = new("UIVerticalLayout").init((0,0), (1,1));
        detailLayout.pinToParent(0, 0, 0, 0);
        detailLayout.itemSpacing = 5;
        detailBackground.add(detailLayout);

        mapImage = new("UIImage").init((0,0), (1,1), "", imgStyle: UIImage.Image_Aspect_Fill);
        mapImage.maxSize = (99999, 512);
        mapImage.pinHeight(0.5, isFactor: true);
        mapImage.pin(UIPin.Pin_Left);
        mapImage.pin(UIPin.Pin_Right);
        mapImage.pin(UIPin.Pin_Top);
        detailLayout.addManaged(mapImage);

        detailLayout.addSpacer(20);

        levelTitleLabel = new("UILabel").init((0,0), (1, 1), "Map Name", 'K32FONT', fontScale: (1,1) * 0.78);
        levelTitleLabel.pinHeight(UIView.Size_Min);
        levelTitleLabel.pin(UIPin.Pin_Left, offset: 20);
        levelTitleLabel.pin(UIPin.Pin_Right, offset: -20);
        detailLayout.addManaged(levelTitleLabel);

        mapInternalNameLabel = new("UILabel").init((0,0), (1,1), "ID: ", 'PDA16FONT');
        mapInternalNameLabel.pin(UIPin.Pin_Left, offset: 20);
        mapInternalNameLabel.pin(UIPin.Pin_Right, offset: -20);
        mapInternalNameLabel.pinHeight(UIView.Size_Min);
        detailLayout.addManaged(mapInternalNameLabel);

        authorLabel = new("UILabel").init((0,0), (1,1), "Author: ", 'PDA16FONT');
        authorLabel.pin(UIPin.Pin_Left, offset: 20);
        authorLabel.pin(UIPin.Pin_Right, offset: -20);
        authorLabel.pinHeight(UIView.Size_Min);
        detailLayout.addManaged(authorLabel);

        pathLabel = new("UILabel").init((0,0), (1,1), "Author: ", 'PDA16FONT', fontScale: (0.7, 0.7));
        pathLabel.pin(UIPin.Pin_Left, offset: 20);
        pathLabel.pin(UIPin.Pin_Right, offset: -20);
        pathLabel.pinHeight(UIView.Size_Min);
        detailLayout.addManaged(pathLabel);

        detailLayout.addSpacer(20);

        descriptionLabel = new("UILabel").init((0,0), (1,1), "Description...", 'PDA16FONT');
        descriptionLabel.pin(UIPin.Pin_Left, offset: 20);
        descriptionLabel.pin(UIPin.Pin_Right, offset: -20);
        descriptionLabel.pinHeight(UIView.Size_Min);
        descriptionLabel.multiline = true;
        detailLayout.addManaged(descriptionLabel);

        

        // Get a list of usermaps
        // To be listed here a mod (PK3) must have a MAPINFO definition for the playable maps
        // Each map must be in a non-basecampaign cluster. Either 0 or 4+
        let wi = Wads.GetLumpWadNum(Z_CONTAINER);

        for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
			let info = LevelInfo.GetLevelInfo(y);
			int lump = Wads.CheckNumForFullName("maps/" .. info.MapName .. ".wad");
			int wadnum = Wads.GetLumpWadNum(lump);

			if(lump > 0 && (info.cluster < 1 || info.cluster > 3) && wadnum > wi) {
                UsermapInfo mi = new("UsermapInfo");
                mi.name = info.levelname;
                mi.mapname = info.mapname;
                mi.wadnum = wadnum;
                mi.lump = lump;
                mi.path = Wads.GetWadName(wadnum);
                mi.info = info;

                // Insert in order of levelnum
                if(maps.size() > 0) {
                    for(int x = 0; x < maps.size(); x++) {
                        if(maps[x].info.levelnum > info.levelnum) {
                            maps.Insert(x, mi);
                            break;
                        } else if(x + 1 == maps.size()) {
                            maps.Push(mi);
                            break;
                        }
                    }
                } else {
                    maps.Push(mi);
                }
            }
		}

        if(maps.size() == 0) {
            noMaps.hidden = false;
        } else {
            let hiState = CommonUI.barBackgroundState();
            hiState.textColor = 0xFFB4B4FF;
            TitleButton lastButt;

            // Create buttons for each map
            for(int x = 0; x < maps.size(); x++) {
                TitleButton butt = TitleButton(new("TitleButton").init(
                    (0,0), (350, 40),
                    StringTable.Localize(maps[x].name), "SEL27OFONT",
                    UIButtonState.Create("", 0xFFFFFFFF),
                    hiState,
                    UIButtonState.Create("", 0xFFB4B4FF),
                    textAlign: UIView.Align_Left | UIView.Align_Middle
                ));

                butt.navUp = lastButt;
                butt.setTextPadding(0, 5, 0, 5);
                butt.label.fontScale = (0.87, 0.87);
                butt.originalFontScale = (0.87, 0.87);
                butt.pinHeight(42);
                butt.pinWidth(1.0, isFactor: true);
                butt.buttonIndex = x;
                butt.controlID = x;
                scrollView.mLayout.addManaged(butt);

                if(lastButt) {
                    lastButt.navDown = butt;
                }

                mapButts.push(butt);
                lastButt = butt;
            }

            navigateTo(mapButts[0]);
        }
    }
    

    override void ticker() {
        Super.ticker();
        animated = true;

        // Scroll with gamepad
        if(scrollView && scrollView.contentsCanScroll()) {
            let v = getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                scrollView.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }
    }


    override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;
        let cc = Super.navigateTo(con, mouseSelection);
        if(cc) {
            if(!mouseSelection && con.parent == scrollView.mLayout && ticks > 1) {
                scrollView.scrollTo(con, true, 40);
            }

            if(ac != activeControl && !mouseSelection && ticks > 1) {
                MenuSound("menu/cursor");
            }

            if(con is 'TitleButton') {
                mapImage.setImage(maps[con.controlID].info.F1Pic);
                levelTitleLabel.setText(maps[con.controlID].name);
                mapInternalNameLabel.setText(String.Format("\c[HI]ID:\c- %s", maps[con.controlID].mapname));
                authorLabel.setText(String.Format("\c[HI]Author:\c- %s", maps[con.controlID].info.AuthorName));
                descriptionLabel.setText(maps[con.controlID].info.description);

                // Create a source without the full path when possible
                let path = maps[con.controlID].path;
                int f = path.rightIndexOf("/");
                if(f >= 0) {
                    path = path.mid(f + 1);
                }

                pathLabel.setText(String.Format("Source: %s", path));
            }
                
            return true;
        }

        return false;
	}


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl is 'TitleButton') {
                // Open prompt
                let prompt = new("NewGameSettingsPrompt");
                //prompt.resetOnClose = true;
                prompt.init(self);
                prompt.ActivateMenu();
                lastIndex = ctrl.controlID;
                //startGame(ctrl.controlID);
            }
        }
    }


    override bool MenuEvent(int mkey, bool fromcontroller) {
		switch (mkey) {
            case Menu.MKEY_MBYes:
                int chosenSkill = skill;
                NewGameSettingsPrompt prompt = NewGameSettingsPrompt(Menu.GetCurrentMenu());
                if(prompt) chosenSkill = prompt.chosenSkill;

                startGame(lastIndex, chosenSkill);
                return true;
            case Menu.MKEY_Abort:
                // Reset all options to default
                UIHelper.ResetNewGameOptions();
                return true;
			default:
                
				break;
		}

		return Super.MenuEvent(mkey, fromcontroller);
	}


    override void drawer() {
        double time = MSTime() / 1000.0;
        if(time - dimStart > 0 && !closing) {
            Screen.dim(0xFF020202, MIN((time - dimStart) / 0.15, 1.0) * 0.75, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            BlurAmount =  MIN((time - dimStart) / 0.1, 1.0);
        } else if(time - dimStart > 0 && closing) {
            Screen.dim(0xFF020202, (1.0 - MIN((time - dimStart) / 0.2, 1.0)) * 0.75, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            BlurAmount = 1.0 - MIN((time - dimStart) / 0.18, 1.0);
        }
        
        Super.drawer();
    }


    void startGame(int mapIndex, int theSkill = 2) {
        // Tell the intro-handler that a new game is starting
        let handler = IntroHandler(StaticEventHandler.Find("IntroHandler"));
        if(handler) {
            handler.notifyNewGame();
        }
        
        Level.StartNewGame(0, theSkill, "Dawn", maps[mapIndex].mapname);
    }
}