class ErrorMenu : UIMenu {
    UIVerticalLayout mainLayout;

	ErrorMenu init(Menu parent, int type, string consoleMessage) {
		Super.init(parent);
        System.StopMusic();

        mainLayout = new("UIVerticalLayout").init((0,0), (800, 200));
        mainView.add(mainLayout);
        mainLayout.pinWidth(0.8, isFactor: true);
        mainLayout.pinHeight(UIView.Size_Min);
        mainLayout.maxSize.x = 1600;
        mainLayout.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        mainLayout.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        mainLayout.setPadding(50, 85, 50, 60);
        mainLayout.itemSpacing = 20;
        mainLayout.alpha = 0;

        // Determine error type
        string title = "Unknown Error!";
        string message = "An unknown error has occured and execution could not continue.";
        int mapWad = -1;
        string modFileName = "";

        if(level.mapName != "TITLEMAP") {
            // Check if the file is in a mod and blame the mod
            let wi = Wads.GetLumpWadNum(Z_CONTAINER);
            for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
                let info = LevelInfo.GetLevelInfo(y);
                int c2 = Wads.CheckNumForFullName("maps/" .. info.MapName .. ".wad");
                int wadnum = Wads.GetLumpWadNum(c2);

                if(wadnum > wi) {
                    mapWad = wadnum;
                    modFileName = Wads.GetWadName(wadnum);
                }
            }
        }

        switch(type) {
            case ERR_UNKNOWN_ABORT:
                title = StringTable.Localize("$ERROR_TITLE_UNKNOWN_ABORT");
                message = StringTable.Localize("$ERROR_UNKNOWN_ABORT");
                break;
            case ERR_LOADGAME:
                title = StringTable.Localize("$ERROR_TITLE_LOADGAME");
                message = StringTable.Localize("$ERROR_LOADGAME");
                break;
            case ERR_MISSINGMAP:
                title = StringTable.Localize("$ERROR_TITLE_MISSINGMAP");
                message = StringTable.Localize("$ERROR_MISSINGMAP");
                break;
            case ERR_LOADOBJECTS:
                title = StringTable.Localize("$ERROR_TITLE_LOADOBJECTS");
                message = StringTable.Localize("$ERROR_LOADOBJECTS");
                break;
            case ERR_SAVEGAMEVERSION: {
                title = StringTable.Localize("$ERROR_TITLE_SAVEGAMEVERSION");
                message = StringTable.Localize("$ERROR_SAVEGAMEVERSION");
                break;
            }
        }


        // Add BG to the layout
        let bg = new("UIImage").init((0,0), (1,1), "", NineSlice.Create("errorBG", (30, 30), (40, 54)));
        mainLayout.add(bg);
        bg.pinToParent();

        // Set title
        let titleLabel = new("UILabel").init((0, 34), (100, 60), title, "K22FONT", textAlign: UIView.Align_Centered);
        titleLabel.pin(UIPin.Pin_Left);
        titleLabel.pin(UIPin.Pin_Right);
        titleLabel.pinHeight(UIView.Size_Min);
        mainLayout.add(titleLabel);

        // Add the message
        let messageLabel = new("UILabel").init((0, 34), (100, 60), message, "TITLEA");
        messageLabel.verticalSpacing = 5;
        messageLabel.pin(UIPin.Pin_Left);
        messageLabel.pin(UIPin.Pin_Right);
        messageLabel.pinHeight(UIView.Size_Min);
        mainLayout.addManaged(messageLabel);

        let midScroll = new("UIVerticalScroll").init((0,0), (380,100), 14, 14,
            NineSlice.Create("PDAVBAR5", (6,6), (8,26)), null,
            UIButtonState.CreateSlices("PDAVBAR6", (6,6), (8,26)),
            UIButtonState.CreateSlices("PDAVBAR7", (6,6), (8,26)),
            UIButtonState.CreateSlices("PDAVBAR8", (6,6), (8,26)),
            insetA: 10,
            insetB: 10
        );
        midScroll.pin(UIPin.Pin_Right);
        midScroll.pin(UIPin.Pin_Left);
        midScroll.pinHeight(UIView.Size_Min);
        midScroll.autoHideAdjustsSize = true;
        midScroll.autoHideScrollbar = true;
        midScroll.raycastTarget = false;
        midScroll.scrollbar.rejectHoverSelection = true;
        midScroll.rejectHoverSelection = true;
        midScroll.mLayout.itemSpacing = 5;
        midScroll.maxSize.y = 500;
        midScroll.minSize.y = 120;
        midScroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -8;
        mainLayout.addManaged(midScroll);
        midScroll.scrollbar.clipsSubviews = true;   // Something is broken and the scrollbar renders twice. No idea how, but this is a hack to prevent that

        // Add console dump in a container
        UIVerticalLayout midLayout = UIVerticalLayout(midScroll.mLayout);
        midLayout.setPadding(17, 17, 17, 17);

        let bg2 = new("UIImage").init((0,0), (1,1), "", NineSlice.Create("errorBG2", (8, 8), (25, 25)));
        midScroll.add(bg2);
        midScroll.moveToBack(bg2);
        bg2.pinToParent();

        UILabel outputLabel = new("UILabel").init((40, 40), (100, 100), "", "TITLEA", fontScale: (0.75, 0.75) );
        outputLabel.pin(UIPin.Pin_Left);
        outputLabel.pin(UIPin.Pin_Right);
        outputLabel.pinHeight(UIView.Size_Min);
        midLayout.addManaged(outputLabel);

        outputLabel.text.AppendFormat("%s\c-\n\nDebug Info:\n", consoleMessage);
        
        // Add engine version
        outputLabel.text.AppendFormat("Engine Version: %d.%d\n", Engine.GetMajorVersion(), Engine.GetMinorVersion());
        outputLabel.text.AppendFormat("Game Version: %s\n", StringTable.Localize("$GAME_VERSION"));

        // Show current map info
        if(!(level.mapName ~== "TITLEMAP")) {
            let mo = players[consolePlayer].mo;
            if(mo) {
                outputLabel.text.AppendFormat("Player Pos: (X: %.2f, Y: %.2f, Z: %.2f)  Angle: %.2f\n", mo.pos.x, mo.pos.y, mo.pos.z, mo.angle);
            }

            if(modFileName != "") {
                outputLabel.text.AppendFormat("Map Source: %s\n", modFileName);
            }

            outputLabel.text.AppendFormat("Map: [%s] %s : %s\c-\n\n", level.mapName, level.levelName, level.TimeFormatted());
        }
        
        // Add mod listing
		Array<string> modList, modListPaths;
        if( UIHelper.GetModList(modList, true, true) ) {
            UIHelper.GetModList(modListPaths, false, true);

            outputLabel.text.AppendFormat("Mod List:\n");
            
            for(int x = 0; x < modList.size(); x++) {
                if(modListPaths.size() > x && modListPaths[x] == modList[x]) {
                    outputLabel.text.AppendFormat("\t%s\c-\n", modList[x]);
                } else {
                    outputLabel.text.AppendFormat("\t%s : %s\c-\n", modList[x], modListPaths.size() > x ? modListPaths[x] : "(Unknown Path)");
                }
            }
        } else {
            outputLabel.text.AppendFormat("No Mods currently detected\n");
        }
        

        return self;
	}

    override void OnFirstTick() {
        Super.OnFirstTick();

        mainLayout.layout();
        mainLayout.animateFrame(
            0.17,
            fromPos: mainLayout.frame.pos - (0, 50),
            toPos: mainLayout.frame.pos,
            fromAlpha: 0,
            toAlpha: 1.0,
            ease: Ease_Out
        );
    }

	override void Ticker() {
		Super.ticker();
	}

	override bool onBack() {
		Level.ReturnToTitle();
		return false;
	}
}