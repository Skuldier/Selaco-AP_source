class QuickloadGameMenu : PromptMenu {
    SavegameManager saveMan;

    override bool onBack() {
		return false;
	}

    override void init(Menu parent) {
        initFromNew = true;
        saveMan = SavegameManager.GetManager();
        saveMan.ReadSaveStrings();

        string saveTitle = "";

        if(saveMan && saveMan.quickSaveSlot) {
            saveTitle = saveMan.quickSaveSlot.SaveTitle;
        }

        self.title = StringTable.Localize("$QUICKLOAD_TITLE");
        self.text = saveTitle != "" ? String.Format(StringTable.Localize("$QUICKLOAD_TEXT"), saveTitle) : StringTable.Localize("$QUICKLOAD_NO_SLOT_TEXT");
        self.destructiveIndex = -1;
        self.defaultSelection = 1;

        buttTitles.push(StringTable.Localize("$CANCEL"));
        buttTitles.push(StringTable.Localize("$OK"));

        Super.init(parent);

        navigateTo(butts[1]);
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl.controlID == 0) {   // Cancel
                if(!parentMenu) menuActive = Menu.OnNoPause;
            }
            else {
                // Quickload
                // Find the slot
                if(saveMan && saveMan.quickSaveSlot) {
                    SaveGameNode node;
                    for(int x = 0; x < saveMan.SavegameCount(); x++) {
                        node = saveMan.GetSavegame(x);
                        if(node.Filename == saveMan.quickSaveSlot.Filename) {
                            close();
                            if(parentMenu) parentMenu.close();

                            saveMan.LoadSavegame(x);
                            break;
                        }
                    }
                } else {
                    close();
                    if(parentMenu) parentMenu.close();

                    EventHandler.SendNetworkEvent("quickload");
                }
            }
            close();
        }
    }
}