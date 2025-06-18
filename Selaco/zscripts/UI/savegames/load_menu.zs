#include "ZScripts/UI/savegames/save_menu.zs"

// Modifies clip rect for animation
class LoadSelacoScroll : UIVerticalScroll {
    override void getScreenClip(out UIBox ret) {
        UIBox b;
        b.pos = (-5000, 0);
        b.size = frame.size + (10000, 0);
        boxToScreenClipped(ret, b);
    }

    override void clipToScreen(out UIBox ret) {
		ret.pos = relToScreen((-5000,0));
		ret.size = ((frame.size.x + 10000) * cScale.x, frame.size.y * cScale.y);
	}
}

class LoadSelacoMenu : SelacoGamepadMenu {
    SavegameManager manager;
    Array<SavegameSlotControl> controls;
    UIVerticalScroll scrollView, descriptionScroll;
    StandardBackgroundContainer background;
    UIImage saveBackground;
    UIButton loadButton, deleteButton;
    SaveGameImage saveImage;
    UILabel titleLabel, noSaves;
    UILabel gameTitleLabel, gameDescriptionLabel, gameFilenameLabel;
    UIVerticalLayout gameLayout;
    UIButton gamepadDeleteIcon;
    int saveIndex, loadCnt;

    double dimStart;
    bool closing;   // Used by saveMenu after saving

    const LOAD_FADE_TICKS = 20;

    override void init(Menu parent) {
		Super.init(parent);
       
        //AnimatedTransition = true;
        DontBlur = level.MapName == "TITLEMAP";
        dimStart = MSTime() / 1000.0;
        saveIndex = -1;
        loadCnt = -1;     // Setting this will make the game load a savegame after a countdown

        manager = SavegameManager.GetManager();
        manager.ReadSaveStrings();
        if(manager.SavegameCount()) manager.RemoveNewSaveNode();


        [background, titleLabel] = CommonUI.makeStandardBackgroundContainer(title: StringTable.Localize("$TITLE_LOAD_GAME"));
        mainView.add(background);

        // If there is a joystick connected, add the gamepad footer
        if(JoystickConfig.NumJoysticks()) {
            background.addGamepadFooter(InputEvent.Key_Pad_B, "Back");
        }

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
        //scrollView.pinToParent(0, 0, -935, 0);
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

        noSaves = new('UILabel').init((0,0), (1,1), "No Save Games!", 'PDA16FONT');
        noSaves.pin(UIPin.Pin_Left, offset: 0);
        noSaves.pin(UIPin.Pin_Right, offset: -40);
        noSaves.pinHeight(UIView.Size_Min);
        noSaves.hidden = true;
        scrollView.add(noSaves);

        saveBackground = new("UIImage").init((0,0), (1,1), "SAVEBG03");
        saveBackground.pinWidth(0.5, offset: 13, isFactor: true);
        saveBackground.pin(UIPin.Pin_Right);
        saveBackground.pin(UIPin.Pin_Top, offset: 0);
        saveBackground.pin(UIPin.Pin_Bottom);
        background.add(saveBackground);

        gameLayout = new("UIVerticalLayout").init((0,0), (1,1));
        gameLayout.pinToParent(0, 0, 0, 0);
        gameLayout.itemSpacing = 5;
        gameLayout.layoutMode = UIViewManager.Content_Stretch;
        saveBackground.add(gameLayout);

        saveImage = new("SaveGameImage").init((0,0), (1,384), manager);
        saveImage.maxSize = (99999, 512);
        saveImage.pinHeight(0.6, isFactor: true);
        saveImage.pin(UIPin.Pin_Left);
        saveImage.pin(UIPin.Pin_Right);
        saveImage.pin(UIPin.Pin_Top);
        gameLayout.addManaged(saveImage);

        descriptionScroll = new("UIVerticalScroll").init((0,0), (0,0), 30, 24,
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
        descriptionScroll.autoHideScrollbar = true;
        descriptionScroll.pinHeight(0.5, isFactor: true);
        descriptionScroll.pin(UIPin.Pin_Left);
        descriptionScroll.pin(UIPin.Pin_Right);
        descriptionScroll.mLayout.setPadding(right: 20);
        gameLayout.addManaged(descriptionScroll);

        let spacer = new("UIView").init((0,0), (1, 20));
        descriptionScroll.mLayout.addManaged(spacer);
        
        gameTitleLabel = new("UILabel").init((0,0), (1, 1), "Game Title", 'K32FONT', fontScale: (1,1) * (mainView.frame.size.x < 1800 ? 0.6 : 0.81));
        gameTitleLabel.pinHeight(UIView.Size_Min);
        if(mainView.frame.size.x < 1800) {
            gameTitleLabel.lineLimit = 1;
        }
        gameTitleLabel.pin(UIPin.Pin_Left, offset: 20);
        gameTitleLabel.pin(UIPin.Pin_Right, offset: -20);
        descriptionScroll.mLayout.addManaged(gameTitleLabel);

        gameFilenameLabel = new("UILabel").init((0,0), (1, 1), "Filename", 'PDA13FONT', fontScale: (1,1));
        gameFilenameLabel.alpha = 0.5;
        gameFilenameLabel.multiline = true;
        gameFilenameLabel.pinHeight(UIView.Size_Min);
        gameFilenameLabel.pin(UIPin.Pin_Left, offset: 20);
        gameFilenameLabel.pin(UIPin.Pin_Right, offset: -20);
        descriptionScroll.mLayout.addManaged(gameFilenameLabel);

        gameDescriptionLabel = new("UILabel").init((0,0), (1,1), "Game Description", 'PDA16FONT');
        gameDescriptionLabel.pin(UIPin.Pin_Left, offset: 20);
        gameDescriptionLabel.pin(UIPin.Pin_Right, offset: -20);
        gameDescriptionLabel.pinHeight(UIView.Size_Min);
        descriptionScroll.mLayout.addManaged(gameDescriptionLabel);

        let loadSaveView = new("UIView").init((0,0), (120, 60));
        loadSaveView.pin(UIPin.Pin_Left);
        loadSaveView.pin(UIPin.Pin_Right);
        loadSaveView.clipsSubviews = false;

        loadButton = new("UIButton").init((20,20), (200, 40), StringTable.Localize("$LOAD_GAME_BUTTON"), "PDA16FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "menu/cursor", mouseSound: "ui/cursor2", mouseSoundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
        );
        loadSaveView.add(loadButton);

        deleteButton = new("UIButton").init((240,20), (200, 40), StringTable.Localize("$DELETE_GAME_BUTTON"), "PDA16FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: UIHelper.DestructiveColor),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), textColor: 0xFFFFFFFF, sound: "menu/cursor", mouseSound: "ui/cursor2", mouseSoundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF)
        );
        deleteButton.blendColor = UIHelper.DestructiveColor;
        deleteButton.desaturation = 1.0;
        loadSaveView.add(deleteButton);
        
        loadButton.navRight = deleteButton;
        deleteButton.navLeft = loadButton;
        gameLayout.addManaged(loadSaveView);

        refreshList();

        for(int x = 0; x < controls.size(); x++) {
            controls[x].alpha = 0;
        }

        // Select first control
        if(controls.size() > 0) {
            controls[0].setSelected();
            selectSave(0);
        }

        navigateTo(loadButton);
    }

    virtual void refreshList() {
        if(manager.SavegameCount() == 0) {
            gameLayout.hidden = true;
            noSaves.hidden = false;
        } else {
            for(int x = 0; x < manager.SavegameCount(); x++) {
                SavegameSlotControl control;

                if(controls.size() > x) {
                    control = controls[x];
                    control.setup(x, manager);
                } else {
                    control = new("SavegameSlotControl").init(x, manager);
                    scrollView.mLayout.addManaged(control);
                    controls.push(control);
                }

                control.navUp = x > 0 ? controls[x - 1] : null;
                
                if(x > 0) {
                    controls[x - 1].navDown = control;
                }

                control.alpha = 1;
            }
        }

        // Remove old controls
        for(int x = controls.size() - 1; x >= manager.SavegameCount(); x--) {
            SavegameSlotControl control = controls[x];
            scrollView.mLayout.removeManaged(controls[x]);
            controls.delete(x);
            control.destroy();
        }
    }

    override void onFirstTick() {
        Super.onFirstTick();

        // Need to layout the entire view chain before we can animate
        mainView.layout();

        // If this is the first tick, animate everything in
        int cnt = 0;
        for(int x = 0; x < controls.size(); x++) {
            let con = controls[x];
            if(con.isDisabled()) continue;
            let anim = con.animateFrame(
                0.12,
                fromPos: con.frame.pos - (80, 0),
                toPos: con.frame.pos,
                fromAlpha: 0,
                toAlpha: 1.0,
                ease: Ease_Out
            );
            
            double delay = min(0.011 * UIMath.EaseOutCubicF(min(1.0, cnt / 40.0)) * 40.0,  0.32);
            anim.startTime += delay;
            anim.endTime += delay;
            cnt++;
        }
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(loadCnt >= 0) return;

        if(event == UIHandler.Event_Activated) {
            if(ctrl is 'SavegameSlotControl') {
                SavegameSlotControl sControl = SavegameSlotControl(ctrl);
                for(int x = 0; x < controls.size(); x++) {
                    controls[x].setSelected(controls[x] == sControl);
                }

                selectSave(sControl.saveGameIndex);
                return;
            } else if(ctrl == loadButton && saveIndex >= 0) {
                MenuSound("click");
                loadGame();

			    return;
            } else if(ctrl == deleteButton) {
                if(saveIndex >= 0) {
                    let m = new("PromptMenu").initNew(self, "$TITLE_DELETE_SAVE_PROMPT", "$DELETE_SAVE_PROMPT", "$CANCEL_BUTTON", "$DELETE_BUTTON", destructiveIndex: 1, defaultSelection: 0);
                    m.ActivateMenu();
                }
                return;
            }
        } 
        
        if(event == UIHandler.Event_Alternate_Activate && getClass() == 'LoadSelacoMenu') {
            if(ctrl is 'SavegameSlotControl') {
                SavegameSlotControl sControl = SavegameSlotControl(ctrl);
                for(int x = 0; x < controls.size(); x++) {
                    controls[x].setSelected(controls[x] == sControl);
                }

                selectSave(sControl.saveGameIndex);
                
                MenuSound("click");
                loadGame();
                
                return;
            }
        }

        Super.handleControl(ctrl, event, fromMouseEvent);
    }


    void loadGame() {
        loadCnt = 0;
        MenuSound("ui/loadfade");
    }
    

    virtual void selectSave(int index) {
        // Setup right panel
        manager.UnloadSaveData();

        if(index >= 0 && index < manager.SavegameCount()) {
		    manager.ExtractSaveData(index);
            gameTitleLabel.setText(manager.GetSavegame(index).SaveTitle);

            // Sanitize filename, since we suck at getting slashes correct
            string filename = manager.GetSavegame(index).Filename;
            if(UIHelper.TestForWindows()) {
                filename.replace("/", String.Format("%c", 92));
            } else {
                filename.replace(String.Format("%c", 92), "/");
            }

            gameFilenameLabel.setText(filename);
            gameDescriptionLabel.setText(manager.SaveCommentString);
            descriptionScroll.scrollNormalized(0);
            gameLayout.requiresLayout = true;

            if(!gamepadDeleteIcon && JoystickConfig.NumJoysticks()) {
                gamepadDeleteIcon = background.addGamepadFooter(InputEvent.Key_Pad_X, "Delete Save", 0);
            }
        } else {
            if(gamepadDeleteIcon) {
                background.removeGamepadFooter(gamepadDeleteIcon);
                gamepadDeleteIcon = null;
            }
        }

        saveIndex = index;
    }

    void deleteSave() {
        if(saveIndex < 0) return;
        saveIndex = manager.RemoveSaveSlot(saveIndex);

        refreshList();

        int index = saveIndex;
        
        // Find the first available index
        if(controls.size() > 0) {
            for(int x = index, cnt = 0; cnt < controls.size(); x++) {
                let idx = x % controls.size();
                cnt++;
                if(controls[idx].isDisabled() || controls[idx].hidden) continue;
                index = idx;
                break;
            }

            selectSave(index);

            for(int x = 0; x < controls.size(); x++) {
                controls[x].setSelected(x == saveIndex);
                //scrollView.scrollTo(controls[x], true, 50);
            }
        } else {
            if(gamepadDeleteIcon) {
                background.removeGamepadFooter(gamepadDeleteIcon);
                gamepadDeleteIcon = null;
            }
        }

        scrollView.requiresLayout = true;
    }

    override void ticker() {
        Super.ticker();

        animated = true;

        if(loadCnt >= LOAD_FADE_TICKS) {
            let handler = IntroHandler(StaticEventHandler.Find("IntroHandler"));
            if(handler) {
                handler.notifyLoadGame();
            }

            manager.LoadSavegame(saveIndex);
        } else if(loadCnt >= 0) {
            loadCnt++;
        }

        // Scroll with gamepad
        if(descriptionScroll.contentsCanScroll()) {
            let v = getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                descriptionScroll.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }
    }

    // Only provide 1 or -1
    void moveSaveIndex(int dir) {
        if(controls.size() == 0) return;

        int startingIndex = saveIndex;
        
        saveIndex += dir;
        while(saveIndex != startingIndex) {
            if(saveIndex < 0) saveIndex = controls.size() - 1;
            if(saveIndex >= controls.size()) saveIndex = MIN(controls.size() - 1, 0);
            if(!controls[saveIndex].isDisabled()) break;
            saveIndex += dir;
        }

        selectSave(saveIndex);
        for(int x = 0; x < controls.size(); x++) controls[x].setSelected(x == saveIndex);
        if(saveIndex >= 0) scrollView.scrollTo(controls[saveIndex], true, 50);
    }


    void promptDelete() {
        if(saveIndex < 0) return;
        let node = manager.GetSavegame(saveIndex);
        if(node && !node.bNoDelete) {
            let m = new("PromptMenu").initNew(self, "$TITLE_DELETE_SAVE_PROMPT", "$DELETE_SAVE_PROMPT", "$CANCEL_BUTTON", "$DELETE_BUTTON", destructiveIndex: 1, defaultSelection: 0);
            m.ActivateMenu();
        }
    }

    override bool OnUIEvent(UIEvent ev) {
		int ch = ev.KeyChar;

		if(ch == UIEvent.Key_Del && (ev.Type == UIEvent.Type_KeyDown || ev.Type == UIEvent.Type_KeyRepeat)) {
            promptDelete();
            return true;
        }

        return Super.OnUIEvent(ev);
    }

    // Up and down keys exclusively navigate the list view, but does not use actual navigation
    // Only the load/save/delete buttons use normal navigation
    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(loadCnt >= 0) return true;

		switch (mkey) {
			case MKEY_Up:
				{
					moveSaveIndex(-1);
                    MenuSound("menu/cursor");
                    return true;
				}
			case MKEY_Down:
				{
					moveSaveIndex(+1);
                    MenuSound("menu/cursor");
                    return true;
				}
            case MKEY_Left:
                if(!activeControl) {
                    navigateTo(loadButton);
                    return true;
                }
                break;
            case MKEY_Right:
                if(!activeControl) {
                    navigateTo(deleteButton);
                    return true;
                }
                break;
            case MKEY_Clear:
                promptDelete();
                return true;
			default:
                if(mkey >= MKEY_MBYes) {
                    // We received a response from a prompt
                    int res = mkey - MKEY_MBYes;
                    if(res == 1) {
                        deleteSave();

                        // Unselect the save button
                        navigateTo(loadButton);
                    }
                    return true;
                }
				break;
		}

		return Super.MenuEvent(mkey, fromcontroller);
	}

    const LOAD_TEXT = "Loading...";

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

        if(loadCnt >= 0) {
            Screen.ClearClipRect();

            Font fnt = 'SELACOFONT';
            double ticks = loadCnt + System.GetTimeFrac();
            double tm = UIMath.EaseInCubicF( clamp(ticks / double(LOAD_FADE_TICKS), 0, 1) );
            Screen.Dim(0xFF000000, tm, 0,0, Screen.GetWidth(), Screen.GetHeight());
            
            if(loadCnt > LOAD_FADE_TICKS - 2) {
                int left = Screen.GetWidth() - 40 - fnt.StringWidth(LOAD_TEXT);
                int top = Screen.GetHeight() - 40 - fnt.GetHeight();
                Screen.DrawText(fnt, Font.CR_WHITE, left, top, LOAD_TEXT,
                                DTA_KeepRatio, true,
                                DTA_Alpha, 1);
            }
        }
    }
}


class SavegameSlotControl : UIButton {
    int saveGameIndex;
    bool isQuicksave;
    SavegameManager manager;

    SavegameSlotControl init(int saveIndex, SavegameManager manager) {
        saveGameIndex = saveIndex;

        let bgSlice2 = NineSlice.Create("graphics/options_menu/op_bg2.png", (11,11), (19,19));
        let bgSlice = NineSlice.Create("graphics/options_menu/op_bg.png", (11,11), (19,19));

        Super.init(
            (0,0), (1, 46),
            "No Save Info", "SEL21FONT",
            UIButtonState.CreateSlices("SAVBGNRM", (11,11), (19,19), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("SAVBGHOV", (11,11), (19,19), mouseSound: "ui/cursor2", mouseSoundVolume: 0.45),
            UIButtonState.CreateSlices("SAVBGSEL", (11,11), (19,19)),
            UIButtonState.CreateSlices("SAVBGNRM", (11,11), (19,19), textColor: 0xFF999999),
            UIButtonState.CreateSlices("SAVBGSEL", (11,11), (19,19)),
            UIButtonState.CreateSlices("SAVBGSEL", (11,11), (19,19)),
            UIButtonState.CreateSlices("SAVBGSEL", (11,11), (19,19))
        );
        
        doubleClickEnabled = true;
        label.textAlign = UIView.Align_Left | UIView.Align_Middle;
        label.fontScale = (0.9, 0.9);
        setTextPadding(left: 20);
        
        rejectHoverSelection = true;

        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);

        setup(saveIndex, manager);

        return self;
    }

    void setup(int saveIndex, SavegameManager manager) {
        self.manager = manager;

        SaveGameNode node = manager.GetSavegame(saveIndex);
        label.setText(node.SaveTitle);

        if(node.bOldVersion || node.bMissingWads) {
            label.blendColor = 0xFFFF4C4C;
        } else {
            label.blendColor = 0xFFFFFFFF;
        }
    }
}


class SaveGameImage : UIImage {
    SavegameManager manager;

    SaveGameImage init(Vector2 pos, Vector2 size, SavegameManager manager) {
        self.manager = manager;
        Super.init(pos, size, "");
        return self;
    }

    override void draw() {
        UIBox clipRect;
        getScreenClip(clipRect);
        Vector2 tl = relToScreen((0,0));
        UIBox b;
        boundingBoxToScreen(b);

        Vector2 size;
        [tl, size] = calcPos(b);

        // Determine actual draw size
        //double height = ceil(frame.size.x * (9.0 / 16.0));
        //double vOffset = ((frame.size.y * 0.5) - (height * 0.5)) * cScale.y;

        if(!ignoresClipping) Screen.setClipRect(int(clipRect.pos.x), int(clipRect.pos.y), int(clipRect.size.x), int(clipRect.size.y));
        if(manager && manager.SavegameCount()) {
            //manager.DrawSavePic(int(tl.x), int(tl.y + vOffset), int(frame.size.x * cScale.x), int(height * cScale.y));

            manager.DrawSavePic(int(tl.x), int(tl.y), int(size.x), int(size.y));
        }
    }

    Vector2, Vector2 calcPos(UIBox b) {
        double aspect = 16.0 / 9.0;
        double target_aspect = b.size.x / b.size.y;

        Vector2 size = aspect > target_aspect ? (b.size.y * aspect, b.size.y) : (b.size.x, b.size.x / aspect);
        //size = (size.x * imgScale.x, size.y * imgScale.y);
        Vector2 pos = b.pos + (b.size / 2.0) - (size / 2.0);

        return pos, size;
    }
}