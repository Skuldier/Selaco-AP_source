#include "ZScripts/UI/savegames/save_poppup.zs"
#include "ZScripts/UI/savegames/quickload_menu.zs"

class SaveSelacoMenu : LoadSelacoMenu {
    string saveGameName;        // If set, the next tick will save the game with this string
    string incomingSaveName;    // Set by the save text menu
    SaveTextPop popup;
    int saveGameCountdown;

    bool increaseSave;
    bool hasNewSave;

    override void init(Menu parent) {
		Super.init(parent);

        titleLabel.setText(StringTable.Localize("$TITLE_SAVE_GAME"));
        loadButton.label.setText(StringTable.Localize("$SAVE_GAME_BUTTON"));

        saveGameCountdown = -1;
    }

    override void selectSave(int index) {
        Super.selectSave(index);

        deleteButton.hidden = index == 0 && hasNewSave;
        deleteButton.setDisabled(deleteButton.hidden);

        if(index == 0 && hasNewSave && gamepadDeleteIcon) {
            background.removeGamepadFooter(gamepadDeleteIcon);
            gamepadDeleteIcon = null;
        }
    }

    override void refreshList() {
        if(!hasNewSave) {
            manager.InsertNewSaveNode();
            hasNewSave = true;
        }

        Super.refreshList();

        for(int x = 0; x < controls.size(); x++) {
            SaveGameNode node = manager.GetSavegame(x);
            int qpos = node.filename.makeLower().rightIndexOf("quick");
            int qpos2 = node.filename.makeLower().rightIndexOf("quicksave");
            if( (qpos >= 0 && node.filename.codePointCount() - qpos <= 11) || 
                (qpos2 >= 0 && node.filename.codePointCount() - qpos2 <= 16)
            ) {
                // Expected format: quickXX.zds or quicksaveXX.zds
                controls[x].setDisabled();  // Assume this is a quicksave, and prevent saving over it
                controls[x].hidden = true;
            } else {
                qpos = node.filename.makeLower().rightIndexOf("auto");
                qpos2 = node.filename.makeLower().rightIndexOf("autosave");
                if( (qpos >= 0 && node.filename.codePointCount() - qpos <= 10) || 
                    (qpos2 >= 0 && node.filename.codePointCount() - qpos2 <= 15)
                ) {
                    // Expected format: autoXX.zds or autosaveXX.zds
                    controls[x].setDisabled();  // Assume this is an autosave, and prevent saving over it
                    controls[x].hidden = true;
                } else {
                    controls[x].hidden = false;
                    controls[x].setDisabled(false);
                }
            }
        }

        scrollView.requiresLayout = true;
    }

    override void OnDestroy() {
		manager.RemoveNewSaveNode();
        hasNewSave = false;
		Super.OnDestroy();
	}

    override bool onBack() {
        if(!Super.onBack()) {
            manager.RemoveNewSaveNode();
            return false;
        }

        return true;
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(saveGameCountdown > 0) return;

        if(event == UIHandler.Event_Activated) {
            if(ctrl == loadButton && saveIndex >= 0 && !popup) {
                MenuSound("click");
                
                saveGame(fromController);

			    return;
            }
        }

        if(event == UIHandler.Event_Alternate_Activate && !popup) {
            if(ctrl is 'SavegameSlotControl') {
                SavegameSlotControl sControl = SavegameSlotControl(ctrl);
                for(int x = 0; x < controls.size(); x++) {
                    controls[x].setSelected(controls[x] == sControl);
                }

                selectSave(sControl.saveGameIndex);
                
                saveGame(fromController);
                
                return;
            }
        }

        Super.handleControl(ctrl, event, fromMouseEvent);
    }


    void saveGame(bool fromController) {
        increaseSave = false;
                
        // Generate a save name if this is a new save
        string saveName = "";
        if(saveIndex == 0) {
            if(fromController) {
                let cv = CVar.FindCVar("g_saveindex");
                int num = cv.GetInt() + 1;
                increaseSave = true;

                saveName = String.Format("Save #%d [%s]", num, level.LevelName);
            } else {
                saveName = "";
            }
        } else {
            SaveGameNode node = manager.GetSavegame(saveIndex);
            saveName = node.SaveTitle;

            // If this is an automatic save name, try to increment it
            // Also try to save any text that may have been added after the level name
            if(saveName.mid(0, 6) == "Save #") {
                let cv = CVar.FindCVar("g_saveindex");
                int num = cv.GetInt() + 1;
                increaseSave = true;

                String extra = "";
                int nameEnd = saveName.rightIndexOf("]");
                if(nameEnd >= 0 && saveName.length() > uint(nameEnd + 1)) {
                    extra = saveName.mid(nameEnd + 1, saveName.length() - nameEnd - 1);
                }

                saveName = String.Format("Save #%d [%s]%s", num, level.LevelName, extra);
            }
        }

        // Show text editor
        popup = SaveTextPop.present(saveName, fromController);
    }


    override void ticker() {
        Super.ticker();

        if(saveGameCountdown) saveGameCountdown--;
        if(saveGameName != "" && saveGameCountdown == 0) {
            manager.DoSave(saveIndex, saveGameName);
            manager.RemoveNewSaveNode();
            saveGameName = "";

            if(increaseSave) {
                let cv = CVar.FindCVar("g_saveindex");
                if(cv) cv.SetInt(cv.GetInt() + 1);
            }

            increaseSave = false;

            HUD.SavedFromMenu();    // Show "GAME SAVED" animation without logo
        }
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(saveGameCountdown > 0) return true;

		if(mkey == MKEY_Input) {
            // Proceed with save
            saveGameName = incomingSaveName;
            popup = null;
            saveGameCountdown = 6;
            closing = true;
            dimStart = MSTime() / 1000.0;
            return true;
        } else if(mkey == MKEY_Abort) {
            if(popup) {
                popup = null;
            }
            saveGameCountdown = -1;
            incomingSaveName = "";
            saveGameName = "";
            increaseSave = false;
        }

        return Super.MenuEvent(mkey, fromcontroller);
	}
}