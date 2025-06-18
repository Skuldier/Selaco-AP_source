struct PDAEntrySortItem {
    int index;
    int group;
}

class PDAEntryGroup {
    int id;
    Array<int> items;
}

class PDAAreaButton : UIButton {
    UIImage unreadImage;
    bool hasUnread;
    int area;

    PDAAreaButton init(Vector2 pos, Vector2 size, int area, string title, bool hasUnread = false) {
        UIButtonState hovState = UIButtonState.CreateSlices("PDALFRA2", (11, 10), (151, 24), textColor: 0xFFFFFFFF, sound: "codex/areaHover");
        UIButtonState selState = UIButtonState.CreateSlices("PDALFRA1", (11, 10), (151, 24), textColor: 0xFFFFFFFF);
        UIButtonState selHovState = UIButtonState.CreateSlices("PDALFRA3", (11, 10), (151, 24), textColor: 0xFFFFFFFF);
        UIButtonState nstate = UIButtonState.CreateSlices("PDALFRA4", (11, 10), (151, 24), textColor: 0xFFB9C0D1);
        
        self.area =  area;

        Super.init(pos, size, title, "SEL21FONT",
            nstate,
            hover: hovState,
            pressed: selState,
            selected: selState,
            selectedHover: selHovState,
            selectedPressed: selState
        );

        label.scaleToHeight(24);

        setHasUnread(hasUnread);

        command = "area";
        controlID = area;

        return self;
    }

    void setHasUnread(bool unread = true) {
        hasUnread = unread;

        if(hasUnread) {
            if(!unreadImage) {
                unreadImage = new("UIImage").init((2,0), (20, 20), "PDAUNR");
                unreadImage.imgScale = (0.5, 0.5);
                unreadImage.pin(UIPin.Pin_VCenter, value: 1.0);
                add(unreadImage);
            }
            unreadImage.hidden = false;
        } else {
            if(unreadImage) {
                unreadImage.hidden = true;
            }
        }

        setTextPadding(hasUnread ? 22 : 15,0,15,0);
        requiresLayout = true;
    }

    /*override void onSelected(bool mouseSelection) {
        if(!disabled) {
            transitionToState(selected ? State_SelectedHover : State_Hover, mouseSelection);
        }

        UIControl.onSelected(mouseSelection);

        if(!mouseSelection) {
            // Set selected, callback
            sendEvent(UIHandler.Event_Activated, false);
        }
    }*/
}

class PDAReaderEntryButton : UIButton {
    bool isRead, hasAttachment;
    int area, item, ticks;

    UIView readStatusView;
    UIImage attachmentImage, replyImage;
    UILabel nameLabel, dateLabel, subjectLabel, tasteLabel;
    UIVerticalScroll scrollView;

    const normColor = 0xFFB9C0D1;
    const unreadColor = 0xFFFFBF00;
    const selectColor = 0xFFFFFFFF;

    PDAReaderEntryButton init(int area, int item, bool hasRead = true, bool hasAttachment = false) {
        Super.init((0,0), (100, 46 + 25), "", null,
            UIButtonState.Create(""),
            UIButtonState.CreateSlices("PDASELF3", (11,11), (22, 21), sound: "codex/emailHover"),
            UIButtonState.CreateSlices("PDASELF1", (11,11), (22, 21)),
            selected: UIButtonState.CreateSlices("PDASELF1", (11,11), (22, 21)),
            selectedHover: UIButtonState.CreateSlices("PDASELF2", (11,11), (22, 21))
        );

        self.area = area;
        self.item = item;

        string name, subject, date;
        int status;
        [name, subject, date, hasAttachment, status] = PDAReaderWindow.getEntryInfo(area, item);
        string taste = PDAReaderWindow.getEntryTaste(area, item);
        isRead = status > 1 || hasRead;

        nameLabel = new("UILabel").init((0,8), (100, 25), name, "SEL21FONT", fontScale: (0.9, 0.9));
        nameLabel.pin(UIPin.Pin_Left, offset: 28);
        nameLabel.pin(UIPin.Pin_Right, offset: -80);
        nameLabel.multiline = false;
        nameLabel.charLimit = 25;
        nameLabel.autoScale = true;
        add(nameLabel);

        subjectLabel = new("UILabel").init((0,0), (100, 25), subject, "SEL21FONT", fontScale: (0.9, 0.9));
        subjectLabel.alpha = 0.55;
        subjectLabel.pin(UIPin.Pin_Left, offset: 28);
        subjectLabel.pin(UIPin.Pin_Right, offset: -14);
        subjectLabel.pin(UIPin.Pin_Top, offset: 32);
        subjectLabel.pinHeight(UIView.Size_Min);
        subjectLabel.multiline = false;
        subjectLabel.charLimit = 25;
        subjectLabel.autoScale = true;
        add(subjectLabel);

        dateLabel = new("UILabel").init((0,9), (100, 25), date, "SEL16FONT", textAlign: Align_TopRight);
        dateLabel.pin(UIPin.Pin_Left, offset: 80);
        dateLabel.pin(UIPin.Pin_Right, offset: -14);
        add(dateLabel);

        tasteLabel = new("UILabel").init((0,0), (100, 25), taste, "PDA16FONT", fontScale: (0.8, 0.8));
        tasteLabel.pin(UIPin.Pin_Left, offset: 28);
        tasteLabel.pin(UIPin.Pin_Right, offset: -14);
        tasteLabel.pin(UIPin.Pin_Top, offset: 59);
        tasteLabel.pinHeight(UIView.Size_Min);
        tasteLabel.alpha = 0.6;
        tasteLabel.lineLimit = 2;
        add(tasteLabel);

        attachmentImage = new("UIImage").init((0, hasRead ? 8 : 30), (20,20), "PDAATT");
        attachmentImage.pin(UIPin.Pin_Left, offset: 6);
        add(attachmentImage);
        attachmentImage.hidden = !hasAttachment;

        readStatusView = new("UIImage").init((0,8), (20,20), "PDAUNR");
        readStatusView.pin(UIPin.Pin_Left, offset: 6);
        add(readStatusView);
        readStatusView.hidden = isRead;

        if(subject.MakeLower().IndexOf("re:") == 0) {
            replyImage = new("UIImage").init((0,21), (20,20), "PDARPLY");
            replyImage.pin(UIPin.Pin_Left, offset: 6);
            add(replyImage);
        }

        //transitionToState(State_Normal);
        applyTextColor();

        return self;
    }

    void setRead(bool isRead) {
        self.isRead = isRead;

        readStatusView.hidden = isRead;

        if(attachmentImage) {
            attachmentImage.blendColor = isRead ? 0xFF7A88A7 : 0xFFFFBF00;
            attachmentImage.frame.pos.y = isRead ? 8 : 30;
        }

        if(replyImage) {
            replyImage.blendColor = isRead ? 0xFF7A88A7 : 0xFFFFBF00;
        }

        applyTextColor();
    }

    override void transitionToState(int idx, bool sound) {
        Super.transitionToState(idx, sound);
        applyTextColor();
    }

    void applyTextColor() {
        if(attachmentImage) {
            attachmentImage.blendColor = isRead ? 0xFF7A88A7 : 0xFFFFBF00;
        }

        if(replyImage) {
            replyImage.blendColor = isRead ? 0xFF7A88A7 : 0xFFFFBF00;
        }

        if(!nameLabel) { return; }  // We are probably uninitialized here

        int tCol = isRead ? 0xFFB9C0D1 : 0xFFFFBF00;

        switch(currentState) {
            case State_Pressed:
            case State_Hover:
            case State_Normal:
                nameLabel.textColor = tCol;
                dateLabel.textColor = tCol;
                subjectLabel.textColor = tCol;
                tasteLabel.textColor = 0xFFCCCCCC;
                break;
            case State_Selected:
            case State_SelectedHover:
            case State_SelectedPressed:
                nameLabel.textColor = selectColor;
                dateLabel.textColor = selectColor;
                subjectLabel.textColor = selectColor;
                tasteLabel.textColor = selectColor;
                break;
            default:
                break;
        }
    }


    override void tick() {
        Super.tick();

        ticks++;
    }

    override void layout(Vector2 parentScale, double parentAlpha) {
        Super.layout(parentScale, parentAlpha);

        // Size to fit contents
        frame.size.y = tasteLabel.frame.pos.y + tasteLabel.frame.size.y + 10;

        buildShapes();
    }

    override void onSelected(bool mouseSelection, bool fromController) {
        /*if(!disabled) {
            transitionToState(selected ? State_SelectedHover : State_Hover, mouseSelection);
        }

        UIControl.onSelected(mouseSelection);*/
        Super.onSelected(mouseSelection);

        if(!mouseSelection && scrollView) {
            scrollView.scrollTo(self, ticks > 5);
        }

        if(!mouseSelection && !selected) {
            // Set selected, callback
            sendEvent(UIHandler.Event_Alternate_Activate, mouseSelection, fromController);
        }
    }
}


class PDAMailScroll : UIVerticalScroll {
    UIView gamepadScrollIcon;
    bool animatingOut;

    override void layout(Vector2 parentScale, double parentAlpha, bool skipSubviews) {
        super.layout(parentScale, parentAlpha, skipSubviews);
        checkIcon();
    }

    override void scrollBy(double offset, bool animated, bool sendEvt, bool fromMouse) {
        Super.scrollBy(offset, animated, sendEvt, fromMouse);
        checkIcon();
    }

    override void scrollNormalized(double val, bool animated, bool sendEvt, bool fromMouse) {
        Super.scrollNormalized(val, animated, sendEvt, fromMouse);
        checkIcon();
    }

    override void scrollByPixels(double offset, bool animated, bool sendEvt, bool fromMouse, int animateTicks) {
        Super.scrollByPixels(offset, animated, sendEvt, fromMouse, animateTicks);
        checkIcon();
    }

    void checkIcon() {
        if(gamepadScrollIcon) {
            if(!contentsCanScroll() && !animatingOut) {
                let anim = gamepadScrollIcon.getAnimator();
                if(anim) anim.clear(gamepadScrollIcon);
                // Animate in or out if there is scrolling available
                gamepadScrollIcon.alpha = 0;
                animatingOut = true;
            } else if(contentsCanScroll() && layoutTopPin.offset < -60 && !animatingOut) {
                let anim = gamepadScrollIcon.getAnimator();
                if(anim) {
                    anim.clear(gamepadScrollIcon);
                    gamepadScrollIcon.animateFrame(
                        0.25,
                        fromAlpha: gamepadScrollIcon.alpha,
                        toAlpha: 0,
                        ease: Ease_In
                    );
                }
                animatingOut = true;
            } else if(contentsCanScroll() && layoutTopPin.offset >= -60 && animatingOut) {
                let anim = gamepadScrollIcon.getAnimator();
                if(anim) {
                    anim.clear(gamepadScrollIcon);
                    gamepadScrollIcon.animateFrame(
                        0.25,
                        fromAlpha: gamepadScrollIcon.alpha,
                        toAlpha: 1.0,
                        ease: Ease_In
                    );
                }
                animatingOut = false;
            }
        }
    }
}


class PDAReaderWindow : PDAFullscreenAppWindow {
    UIVerticalScroll listScroll;
    PDAMailScroll mailScroll;
    UIView noDataView, noContentView, topSepView, mailContainer;
    UIAnimatedLabel mailLabel;
    UILabel pNameLabel, pFooterLabel, dataLabel;
    UIImage profileImage, profilePersonImage, attachmentImage, beforeAttachmentImage, vSepView, gamepadScrollIcon, shoulderIcons;
    UIVerticalLayout areaView;
    UIButton clearUnreadButton;

    int lastProfileImage;
    int currentArea, currentItem;
    int navSection;
    uint ticks, unreadTicks;

    bool isCompactMode, scrollToItem;

    Array<PDAReaderEntryButton> entryControls;
    Array<PDAAreaButton> areaButtons;

    const LIST_WIDTH = 400;

    int getCurrentArea() {
        return level.areaNum;
    }

    override PDAAppWindow vInit(Vector2 pos, Vector2 size) {
        return Init(pos, size);
    }

    PDAReaderWindow init(Vector2 pos, Vector2 size) {
        Super.init(pos, size);
        pinToParent();

        createStandardTitleBar(StringTable.Localize("$READER_TITLE"));

        isCompactMode = false;
        unreadTicks = 0;

        appID = PDA_APP_READER;
        minSize = (600, 450);
        rejectHoverSelection = true;

        // Create container for mail section
        mailContainer = new("UIView").init((0,0), (100, 100));
        mailContainer.pinToParent(290 + 20, 15, 0, 0);
        contentView.add(mailContainer);

        // Background for mail area
        let mailBG = new("UIImage").init((0,0), (0,0), "", NineSlice.Create("PDAMALBG", (20,43), (200, 210)));
        mailBG.pinToParent();
        mailContainer.add(mailBG);

        listScroll = new("UIVerticalScroll").init((0,0), (LIST_WIDTH, 100), 14, 14,
            NineSlice.Create("PDABAR1", (7,9), (8,21)), null,
            UIButtonState.CreateSlices("PDABAR2", (7,9), (8,21)),
            UIButtonState.CreateSlices("PDABAR3", (7,9), (8,21)),
            UIButtonState.CreateSlices("PDABAR4", (7,9), (8,21))
        );
        
        listScroll.pin(UIPin.Pin_Left, offset: 7);
        listScroll.pin(UIPin.Pin_Top, offset: 40);
        listScroll.pin(UIPin.Pin_Bottom, offset: -2);
        listScroll.autoHideScrollbar = false;
        listScroll.mLayout.padding.top = 10;
        listScroll.mLayout.padding.bottom = 10;
        listScroll.mLayout.itemSpacing = 5;
        listScroll.scrollbar.rejectHoverSelection = true;
        mailContainer.add(listScroll);


        mailScroll = PDAMailScroll(new("PDAMailScroll").init((0,0), (320,100), 14, 14,
            NineSlice.Create("PDABAR5", (10,10), (11,13)), null,
            UIButtonState.CreateSlices("PDABAR6", (10,10), (11,13)),
            UIButtonState.CreateSlices("PDABAR7", (10,10), (11,13)),
            UIButtonState.CreateSlices("PDABAR8", (10,10), (11,13)),
            null,
            UIButtonState.CreateSlices("PDABAR9", (5,5), (7,7), sound: "codex/emailHover"),
            UIButtonState.CreateSlices("PDABA10", (5,5), (7,7)),
            UIButtonState.CreateSlices("PDABA11", (5,5), (7,7)),

            insetA: 15, insetB: 15
        ));
        
        mailScroll.scrollbar.selectButtonOnFocus = true;
        mailScroll.pinToParent(LIST_WIDTH + 2 + 10, 40, -15, -2);
        //mailScroll.autoHideScrollbar = false;
        mailScroll.mLayout.padding.top = 5;
        mailScroll.mLayout.padding.bottom = 5;
        mailScroll.mLayout.firstPin(UIPin.Pin_Left).offset = 5;
        mailScroll.mLayout.firstPin(UIPin.Pin_Right).offset = -22;
        mailScroll.mLayout.itemSpacing = 20;
        mailScroll.mLayout.padding.top = 10;
        mailScroll.scrollbar.rejectHoverSelection = true;
        mailContainer.add(mailScroll);


        // Add the clear unread button
        clearUnreadButton = new("UIButton").init((0,0), (100, 36), StringTable.Localize("$READER_CLEAR_UNREAD"), "SEL16FONT",
            UIButtonState.CreateSlices("PDABBUT6", (10,10), (22,22), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("PDABBUT7", (10,10), (22,22), textColor: 0xFFFFFFFF, sound: "codex/emailHover"),
            UIButtonState.CreateSlices("PDABBUT8", (10,10), (22,22), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("PDABBUT9", (10,10), (22,22), textColor: 0xFF777777)
        );
        clearUnreadButton.pin(UIPin.Pin_Right, offset: -10);
        //clearUnreadButton.pinWidth(UIView.Size_Min, offset: 34);
        clearUnreadButton.pin(UIPin.Pin_Left, offset: 10);
        clearUnreadButton.onClick = ClearUnreadPressed;
        clearUnreadButton.onSelect = ClearUnreadSelected;
        clearUnreadButton.receiver = self;

        vSepView = new("UIImage").init((0,290 + 34), (1, 10), "PDAVSEP1");
        vSepView.pin(UIPin.Pin_Left, offset: 2);
        vSepView.pin(UIPin.Pin_Right, offset: -2);
        vSepView.hidden = true;
        mailContainer.add(vSepView);

        // Empty Data Labels
        noDataView = new("UILabel").init((0,40), (LIST_WIDTH, 40), StringTable.Localize("$READER_NO_LOGS"), "SELOFONT", textAlign: UIView.Align_Centered);
        noDataView.pinToParent();
        listScroll.add(noDataView);

        noContentView = new("UILabel").init((0,0), (40, 40), StringTable.Localize("$READER_NO_CONTENT"), "SELOFONT", textAlign: UIView.Align_Centered);
        noContentView.pinToParent(LIST_WIDTH + 5, 0, -5);
        mailContainer.add(noContentView);

        noContentView.hidden = true;
        noDataView.hidden = true;

        // Simple labels for sections
        let llabel = new("UILabel").init((20, -1), (320, 40), StringTable.Localize("$READER_LOGS"), "SEL21FONT", textColor: 0xFFB9C0D1, textAlign: UIView.Align_Middle);
        llabel.scaleToHeight(22);
        mailContainer.add(llabel);

        dataLabel = new("UILabel").init((LIST_WIDTH + 20, -1), (320, 40), StringTable.Localize("$READER_LOG_DATA"), "SEL21FONT", textColor: 0xFFB9C0D1, textAlign: UIView.Align_Middle);
        dataLabel.scaleToHeight(22);
        mailContainer.add(dataLabel);

        /*topSepView = new("UIView").init((60 + 334 + 192 - 17 - 5, 44), (2, 26));
        topSepView.backgroundColor = 0xFF657498;
        mailContainer.add(topSepView);*/

        // Sender profile data
        profileImage = new("UIImage").init((0, 0), (218, 93), "", NineSlice.Create("PDAPORT1", (208, 93), (218,93)));
        profileImage.minSize = (231, 93);
        mailScroll.mLayout.addManaged(profileImage);

        profilePersonImage = new("UIImage").init((6,6), (66,80), "PDAUNKNO");
        profileImage.add(profilePersonImage);

        pNameLabel = new("UILabel").init((77 + 4,9), (100, 20), "Name Label", "SEL16FONT");
        pNameLabel.multiline = false;
        pNameLabel.pinWidth(UIView.Size_Min);
        profileImage.add(pNameLabel);
        pFooterLabel = new("UILabel").init((77 + 4,33), (100, 20), "MED-SCI Officer", "SEL14FONT", textColor: 0xFFB8BFD1);
        pFooterLabel.multiline = false;
        pFooterLabel.pinWidth(UIView.Size_Min);
        profileImage.add(pFooterLabel);

        beforeAttachmentImage = new("UIImage").init((0,0), (300, 300), "", imgStyle: UIImage.Image_Aspect_Fit);
        beforeAttachmentImage.pinWidth(UIView.Size_Min);
        beforeAttachmentImage.pinHeight(UIView.Size_Min);
        mailScroll.mLayout.addManaged(beforeAttachmentImage);

        mailLabel = new("UIAnimatedLabel").init((10, 10), (300, 300), 
            "",//String.format("%s\n%s\n\n%s", StringTable.Localize("$PDA_N_0_2"), StringTable.Localize("$PDA_S_0_2"), StringTable.Localize("$PDA_E_0_2")), 
            "PDA18FONT",
            textColor: Font.CR_UNTRANSLATED,
            fontScale: (0.875, 0.875)
        );
        mailLabel.pin(UIPin.Pin_Left);
        mailLabel.pin(UIPin.Pin_Right, offset: -20);
        mailLabel.pinHeight(UIView.Size_Min);
        mailScroll.mLayout.addManaged(mailLabel);

        attachmentImage = new("UIImage").init((0,0), (300, 300), "", imgStyle: UIImage.Image_Aspect_Fit);
        attachmentImage.pinWidth(UIView.Size_Min);
        attachmentImage.pinHeight(UIView.Size_Min);
        mailScroll.mLayout.addManaged(attachmentImage);

        chooseFirstEmail(); // Choose the most appropriate message to select by default
        buildEmailList(currentArea);

        // Create area view to hold area selection
        areaView = new("UIVerticalLayout").init((0,0), (290, 100));
        areaView.pin(UIPin.Pin_Top, offset: 15);
        areaView.pinHeight(UIView.Size_Min);
        areaView.layoutMode = UIViewManager.Content_SizeParent;
        areaView.padding.top = 20;
        areaView.padding.bottom = 20;
        areaView.itemSpacing = 8;
        areaView.clipsSubviews = false;
        areaView.minSize.y = 176;
        contentView.add(areaView);

        // Background for area view
        let areaBG = new("UIImage").init((0,0), (0,0), "", NineSlice.Create("PDASECBG", (165,150), (260, 220)));
        areaBG.pinToParent(0,0,1);
        areaView.add(areaBG);
        
        // Create area list
        buildAreaList();

        // Add gamepad icon helpers
        gamepadScrollIcon = new("UIImage").init((0,0), (58, 78), "PDARTICO");
        gamepadScrollIcon.pin(UIPin.Pin_Top, offset: 3);
        gamepadScrollIcon.pin(UIPin.Pin_Right, offset: -25);
        mailScroll.add(gamepadScrollIcon);
        mailScroll.gamepadScrollIcon = gamepadScrollIcon;

        shoulderIcons = new("UIImage").init((0,0), (182, 18), "PDASHOLD");
        shoulderIcons.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: 20);
        shoulderIcons.pin(UIPin.Pin_HCenter, value: 1.0);
        shoulderIcons.ignoresClipping = true;
        areaView.add(shoulderIcons);

        //adjustLayoutToSize();

        // For now we clear unread status as soon as the reader is opened
        EventHandler.SendNetworkEvent("pdaUnreadClear");

        return self;
    }

    // Responsible for re-laying out the window when it gets too narrow
    // to a vertical layout. This will likely happen often in a 4:3 scenario
    void adjustLayoutToSize() {
        if(!parent) return;

        let shouldCompact = parent.frame.size.x - 342 < 800;

        if(shouldCompact && !isCompactMode) {
            isCompactMode = true;
            setRequiresLayout();

            // Layout in compact mode
            mailScroll.firstPin(UIPin.Pin_Left).offset = 5;
            mailScroll.firstPin(UIPin.Pin_Top).offset = 305 + 34;
            listScroll.pin(UIPin.Pin_Right, offset: -15);
            listScroll.removePins(UIPin.Pin_Bottom);
            listScroll.frame.size.y = 285;
            scrollToItem = true;
            dataLabel.hidden = true;
            //topSepView.hidden = true;
            vSepView.hidden = false;
        } else if(!shouldCompact && isCompactMode) {
            isCompactMode = false;
            setRequiresLayout();

            // Layout in normal mode
            mailScroll.firstPin(UIPin.Pin_Left).offset = 332;
            mailScroll.firstPin(UIPin.Pin_Top).offset = 40;
            listScroll.frame.size.x = 320;
            listScroll.removePins(UIPin.Pin_Right);
            listScroll.pin(UIPin.Pin_Bottom);
            scrollToItem = true;
            dataLabel.hidden = false;
            //topSepView.hidden = false;
            vSepView.hidden = true;
        }
    }

    /*override void onManualResize() {
        adjustLayoutToSize();
    }*/

    static bool ClearUnreadPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = PDAReaderWindow(self);
        self.clearCurrentAreaUnread();
        return true;
    }

    static bool ClearUnreadSelected(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = PDAReaderWindow(self);
        if(btn.isDisabled()) {
            return false;
        }

        // Deselect current entry button even though the entry stays visible
        for(int x = 0; x < self.entryControls.size(); x++) {
            if(self.entryControls[x].selected) {
                self.entryControls[x].setSelected(false);
                break;
            }
        }

        // If gamepad, scroll to the button
        if(!mouse) {
            self.listScroll.scrollTo(btn, self.ticks > 5);
        }

        return true;
    }

    override void onAddedToParent(UIView parentView) {
        Super.onAddedToParent(parentView);

        //adjustLayoutToSize();

        let m = PDAMenu3(getMenu());
        let isGamepad = m && m.isUsingGamepad();
        shoulderIcons.hidden = !isGamepad;
        gamepadScrollIcon.hidden = !isGamepad;
    }

    override void tick() {
        Super.tick();

        if(ticks % 15 == 0) {
            updateAreaList();

            let m = PDAMenu3(getMenu());
            let isGamepad = m && m.isUsingGamepad();
            shoulderIcons.hidden = !isGamepad;
            gamepadScrollIcon.hidden = !isGamepad;
        }

        if(unreadTicks > 0 && ticks - unreadTicks == 35) {
            // Find the entry button to set as read
            bool foundItem = false;
            for(int x = 0; x < entryControls.size(); x++) {
                if(entryControls[x].area == currentArea && entryControls[x].item == currentItem) {
                    entryControls[x].setRead(true);
                    foundItem = true;
                }
            }
            if(!foundItem) Console.Printf("Codex: Could not find item %d %d to mark as read!", currentArea, currentItem);

            // Send event to mark as open
            // Why am I not using the param fields? Doh.
            //EventHandler.SendNetworkEvent("pdaEntrySet:" .. currentArea .. ":" .. currentItem .. ":" .. PDAEntry.STATUS_LAST_OPEN);
            EventHandler.SendNetworkEvent("pdaEntrySet", currentArea, currentItem, PDAEntry.STATUS_LAST_OPEN);
        }

        if(!mailScroll.scrollbar.disabled && PDAMenu3(getMenu()).findActiveWindow() == self) {
            let v = SelacoGamepadMenu(getMenu()).getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                mailScroll.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }

        ticks++;
    }

    override void setDefaultPositionAndSize(int desktopWidth, int desktopHeight) {
        /*int sideWidth = 32 + 224 + 15;

        frame.pos = (sideWidth, 15);
        frame.size = (MIN(1400, desktopWidth - frame.pos.x - 20), MIN(850, desktopHeight - 45));

        // Now center it if we have more space than we need
        if(frame.size.x < desktopWidth - sideWidth) {
            frame.pos.x = sideWidth + ((desktopWidth - sideWidth) * 0.5) - (frame.size.x * 0.5);
            //MAX(sideWidth, round((desktopWidth * 0.5) - (frame.size.x * 0.5)));
        }

        if(frame.size.y < desktopHeight - 15) {
            frame.pos.y = round((desktopHeight * 0.5) - (frame.size.y * 0.5));
        }

        adjustLayoutToSize();*/
    }

    void chooseFirstEmail() {
        int lastOpenArea, lastOpenItem;
        [lastOpenArea, lastOpenItem] = getCurrentEntry();
        
        currentArea = getCurrentArea();
        if(lastOpenArea == currentArea) {
            currentItem = lastOpenItem;
        } else {
            int ur = getFirstUnread(currentArea);
            if(ur >= 0) {
                currentItem = ur;
            } else {    // Fall back if we have no items for this area
                currentArea = lastOpenArea;
                currentItem = lastOpenItem;
            }
        }        

        // Check for new entries first
        if(currentArea < 0 || currentItem < 0) {
            let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
            PDAEntry entry = evt ? PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true)) : null;

            if(evt && entry) {
                for(int x = 0; x < PDAEntry.NUM_AREA; x++) {
                    if(entry.entries[x][0].status > 0) {
                        int ur = getFirstUnread(x);
                        if(ur >= 0) {
                            currentArea = x;
                            currentItem = ur;
                            break;
                        }
                    }
                }

                // If we still don't have a selection, pick the first available entry and area
                if(currentArea < 0) {
                    for(int x = 0; x < PDAEntry.NUM_AREA; x++) {
                        if(entry.entries[x][0].status > 0) {
                            currentArea = x;
                            currentItem = 1;

                            for(int y = 1; y < PDAEntry.NUM_ENTRY; y++) {
                                if(entry.entries[x][y].status > 0) {
                                    currentItem = y;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
    }

    // I forget why I was getting the event manager here - Cockatrice
    // Why did you add an Event Manager here? - Nexxtic
    int getFirstUnread(int area) {
        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        PDAEntry entry = evt ? PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true)) : null;

        if(evt && entry && area < PDAEntry.NUM_AREA) {
            for(int y = 1; y < PDAEntry.NUM_ENTRY; y++) {
                if(entry.entries[area][y].status == PDAEntry.STATUS_NEW) {
                    return y;
                }
            }
        }

        return -1;
    }


    void buildEmailList(int area) {
        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        PDAEntry entry = evt ? PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true)) : null;

        clearUnreadButton.removeFromSuperview();

        listScroll.mLayout.clearManaged();
        entryControls.clear();

        if(evt && entry && area >= 0) {
            //int indexes[PDAEntry.NUM_ENTRY - 1];
            PDAEntrySortItem indexes[PDAEntry.NUM_ENTRY - 1];
            //Array<PDAEntryGroup> groups;

            int numEntries = 0;

            // Index all valid entries 
            for(int y = 1; y < PDAEntry.NUM_ENTRY; y++) {
                if(entry.entries[area][y].status > 0) {
                    // Try to find the group from LANGUAGE
                    let txtNum = Stringtable.Localize(String.format("$PDA_G_%d_%d", area, y));
                    int group = txtNum != "" ? txtNum.ToInt(10) : 0;

                    indexes[numEntries].index = y;
                    indexes[numEntries++].group = group;
                }
            }

            // Sort the entries by group
            for (int i = 1; i < numEntries; ++i) {
                int key = indexes[i].group;
                int val = indexes[i].index;
                int j = i - 1;

                while(j >= 0 && indexes[j].group > key) {
                    indexes[j + 1].group = indexes[j].group;
                    indexes[j + 1].index = indexes[j].index;
                    j--;
                }
                indexes[j + 1].index = val;
                indexes[j + 1].group = key;
            }

            // Create the list of buttons and area headers
            bool hasUnread = false;
            int lastGroup = 0;
            for(int x = 0; x < numEntries; x++) {
                int y = indexes[x].index;
                int group = indexes[x].group;
                
                // Create the header if necessary
                if(lastGroup != group) {
                    string groupName = Stringtable.Localize("$PDA_GROUP_NAME_" .. group);

                    if(groupName == "") { groupName = "Thread"; }

                    let b = new("UIButton").init((0,0), (100, 30), groupName, "SEL14FONT", null, 
                        disabled: UIButtonState.CreateSlices("PDABG2", (10,10), (16,16), textColor: 0xFF8E99B7),
                        textAlign: UIView.Align_Left | UIView.Align_Middle );
                    b.pin(UIPin.Pin_Left, offset: 10);
                    b.pin(UIPin.Pin_Right, offset: -10);
                    b.setDisabled(true);
                    b.setTextPadding(0, 5, 0, 0);
                    b.label.textColor = 0xFF8E99B7;
                    listScroll.mLayout.addManaged(b);

                    lastGroup = group;
                }

                let e = new("PDAReaderEntryButton").init(area, y, entry.entries[area][y].status != PDAEntry.STATUS_NEW);
                e.pin(UIPin.Pin_Left, offset: 5);
                e.pin(UIPin.Pin_Right, offset: -5);
                e.controlID = entryControls.size();
                e.scrollView = listScroll;

                if(entry.entries[area][y].status == PDAEntry.STATUS_NEW) {
                    hasUnread = true;
                }

                listScroll.mLayout.addManaged(e);

                entryControls.push(e);
                
                e.setSelected(area == currentArea && y == currentItem);
            }


            if(entryControls.size() == 0) {
                showNoEntries();
            } else {
                if(currentArea == area && currentItem >= 0) {
                    for(int x = 0; x < entryControls.size(); x++) {
                        if(entryControls[x].item == currentItem) {
                            entryControls[x].setSelected(true);
                            break;
                        }
                    }
                    openEntry(currentArea, currentItem);
                } else {
                    entryControls[0].setSelected(true);
                    openEntry(entryControls[0].area, entryControls[0].item);
                }
            }

            // Check if there are unread items, if so enable the clearUnread button
            if(hasUnread) {
                listScroll.mLayout.insertManaged(clearUnreadButton, 0);
                listScroll.mLayout.insertManaged(new("UIView").init((0,0), (100, 10)), 1);    // Add spacer
                clearUnreadButton.setDisabled(false);
            } else {
                clearUnreadButton.setDisabled(true);
            }
            clearUnreadButton.navDown = clearUnreadButton.navUp = null;

            // Create selection chain
            for(int x = 0; x < entryControls.size(); x++) {
                if(x == 0) clearUnreadButton.navDown = entryControls[x];
                if(x == entryControls.size() - 1) clearUnreadButton.navUp = entryControls[x];
                entryControls[x].navUp = x > 0 ? UIControl(entryControls[x - 1]) : UIControl(clearUnreadButton);
                entryControls[x].navDown = x < entryControls.size() - 1 ?  UIControl(entryControls[x + 1]) :  UIControl(clearUnreadButton);
            }
        } else {
            showNoEntries();
        }

        listScroll.requiresLayout = true;
        currentArea = area;
    }

    // This is no longer "areas" per se, but more senders. I haven't bothered to rename everything in code.
    void buildAreaList() {
        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        PDAEntry entry;

        if (evt && players[consolePlayer].mo) {
            entry = PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true));
        }

        areaButtons.clear();

        /*UIButtonState normState = UIButtonState.Create("", textColor: 0xFFB9C0D1);
        UIButtonState hovState = UIButtonState.CreateSlices("PDALFRA2", (11, 10), (151, 24), textColor: 0xFFFFFFFF);
        UIButtonState selState = UIButtonState.CreateSlices("PDALFRA1", (11, 10), (151, 24), textColor: 0xFFFFFFFF);
        UIButtonState selHovState = UIButtonState.CreateSlices("PDALFRA3", (11, 10), (151, 24), textColor: 0xFFFFFFFF);*/

        int cnt = 0;
        for(int x =0; x < PDAEntry.NUM_AREA; x++) {
            if((entry && entry.entries[x][0].status > 0)) {
                bool hasUnread = getFirstUnread(x) >= 0;

                let btn = new("PDAAreaButton").init((0,0), (100, 42), x, Stringtable.Localize("$AREA_NAME_" .. x), hasUnread);
                btn.pinWidth(UIView.Size_Min);
                btn.pin(UIPin.Pin_Right, offset: -2);
                btn.controlID = x;
                areaView.addManaged(btn);

                btn.setSelected(x == currentArea);

                areaButtons.push(btn);

                cnt++;
            }
        }

        if(areaView.numManaged() > 1) {
            for(int x = 0; x < areaView.numManaged(); x++) {
                UIButton btn = UIButton(areaView.getManaged(x));
                if(x > 0) btn.navUp = UIButton(areaView.getManaged(x - 1));
                btn.navDown = x < areaView.numManaged() - 1 ? UIButton(areaView.getManaged(x+1)) : UIButton(areaView.getManaged(0));
            }

            UIButton(areaView.getManaged(0)).navUp = UIButton(areaView.getManaged(areaView.numManaged() - 1));
        }
    }

    void updateAreaList() {
        for(int x =0; x < areaButtons.size(); x++) {
            areaButtons[x].setHasUnread(getFirstUnread(areaButtons[x].area) >= 0);
        }
    }

    void showNoEntries(bool hide = false) {
        noContentView.hidden = hide;
        noDataView.hidden = hide;

        mailScroll.hidden = !hide;
    }

    void setOpenEntry(int area, int item) {
        bool animate = ticks > 5;

        // Make sure we have the correct area selected
        if(currentArea != area) {
            // Select correct button for the area
            for(int x = 0; x < areaButtons.Size(); x++) {
                areaButtons[x].setSelected(areaButtons[x].controlID == area);
            }

            buildEmailList(area);
            animate = false;
        }

        openEntry(area, item);

        for(int x = 0; x < entryControls.size(); x++) {
            entryControls[x].setSelected(entryControls[x].item == item && entryControls[x].area == area);
        }

        currentArea = area;
        currentItem = item;
        navigateToActiveEmail(animate);
        
        unreadTicks = ticks > 0 ? ticks : 1;
    }

    private void openEntry(int area, int item, bool immediateRead = false) {
        currentArea = area;
        currentItem = item;

        noContentView.hidden = true;
        string content, attachment;
        string name, footer, subject, pImage;
        bool attachAfter = true;
        [name, footer, subject, pImage] = getFullEntryInfo(area, item);
        [content, attachment, attachAfter] = getEntryContent(area, item);

        // Determine read/unread status
        bool isUnread = getEntryStatus(area, item) < PDAEntry.STATUS_READ;

        // Set mail
        mailLabel.setText(content);

        // Add attachment
        if(attachAfter) {
            attachmentImage.setImage(attachment);
            attachmentImage.hidden = attachment == "";
            beforeAttachmentImage.setImage("");
            beforeAttachmentImage.hidden = true;
        } else {
            beforeAttachmentImage.setImage(attachment);
            beforeAttachmentImage.hidden = attachment == "";
            attachmentImage.setImage("");
            attachmentImage.hidden = true;
        }
        

        // Configure user panel
        if(pImage != "") {
            profilePersonImage.setImage(pImage);
        } else {
            profilePersonImage.setImage("PDAUNKNO");
        }

        pNameLabel.setText(name);
        pFooterLabel.setText(footer);

        profileImage.layout();

        // Adjust width of profileImage
        profileImage.frame.size.x = max(231, max(pNameLabel.frame.size.x + pNameLabel.frame.pos.x + 30, pFooterLabel.frame.size.x + pFooterLabel.frame.pos.x + 30));

        mailScroll.scrollbar.setNormalizedValue(0);
        mailScroll.scrollNormalized(0, animated: false, sendEvt: false);
        mailScroll.requiresLayout = true;

        // Temp, let's try an animation
        if(isUnread) {
            profileImage.animateFrame(
                0.2,
                fromPos: (90, 10), 
                toPos: (0, 10),
                fromAlpha: 0.0,
                toAlpha: 1.0
            );

            mailLabel.start(animSpeed: 800, startingCharacters: 20);
        } else {
            profileImage.requiresLayout = true;
            mailLabel.end();
        }
        

        // Find the button for this entry, set it to read if the email is already read
        if(!isUnread || immediateRead) {
            for(int x = 0; x < entryControls.size(); x++) {
                if(entryControls[x].area == currentArea && entryControls[x].item == currentItem) {
                    entryControls[x].setRead(true);
                }
            }
        }

        unreadTicks = ticks;

        // Notify manager that this item is open/read
        if(immediateRead) EventHandler.SendNetworkEvent("pdaEntrySet", area, item, PDAEntry.STATUS_LAST_OPEN);
        //EventHandler.SendNetworkEvent("pdaEntrySet:" .. area .. ":" .. item .. ":" .. PDAEntry.STATUS_LAST_OPEN);
    }


    void clearCurrentAreaUnread() {
        // Clear all unread status for this area
        EventHandler.SendNetworkEvent("pdaUnreadClear", currentArea, -1);
        
        getMenu().menuSound("codex/clearunread");

        // Visibly clear everything
        for(int x = 0; x < entryControls.size(); x++) {
            entryControls[x].setRead(true);
        }

        // Disable the clear button
        clearUnreadButton.setDisabled(true);

        // Navigate to the current entry if clear button is selected
        if(getMenu().activeControl == clearUnreadButton) {
            for(int x = 0; x < entryControls.size(); x++) {
                if(entryControls[x].area == currentArea && entryControls[x].item == currentItem) {
                    getMenu().navigateTo(entryControls[x]);

                    // Since we navigated we can now hide the clearUnread button
                    clearUnreadButton.removeFromSuperview();
                    listScroll.requiresLayout = true;
                    return;
                }
            }
        }
    }

    
    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(event == UIHandler.Event_Activated && ctrl is "PDAReaderEntryButton") {
            let ec = PDAReaderEntryButton(ctrl);
            if(fromMouse) ec.setRead(true);

            // Set correct control selected
            for(int x = 0; x < entryControls.size(); x++) {
                entryControls[x].setSelected(entryControls[x] == ec);
            }

            openEntry(ec.area, ec.item, true);
            playSound("codex/emailClick");
            return true;
        } else if(event == UIHandler.Event_Alternate_Activate && ctrl is "PDAReaderEntryButton") {
            let ec = PDAReaderEntryButton(ctrl);
            if(fromMouse) ec.setRead(true);

            // Set correct control selected
            for(int x = 0; x < entryControls.size(); x++) {
                entryControls[x].setSelected(entryControls[x] == ec);
            }

            openEntry(ec.area, ec.item, false);
            return true;
        } else if(event == UIHandler.Event_Activated && ctrl.command == "area") {
            // find the button
            UIButton btn;
            for(int x =0; x < areaButtons.Size(); x++) {
                if(areaButtons[x] == UIButton(ctrl)) {
                    areaButtons[x].setSelected(true);
                    btn = areaButtons[x];
                } else {
                    areaButtons[x].setSelected(false);
                }
            }

            if(btn) {
                int area = btn.controlID;
                if(area != currentArea) {
                    currentItem = -1;
                    buildEmailList(area);
                    unreadTicks = ticks;
                }

                //navigateToActiveEmail();
                if(fromMouse) playSound("codex/areaClick");
            } else {
                Console.Printf("Selected a ghost area.. ~~~Spooky~~~");
            }
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    void navigateToActiveEmail(bool animate = true) {
        UIMenu m = getMenu();
        if(m) {
            for(int x = 0; x < entryControls.size(); x++) {
                if(entryControls[x].item == currentItem && entryControls[x].area == currentArea) {
                    m.navigateTo(entryControls[x]);
                    if(x == 0) listScroll.scrollNormalized(0, animate);
                    else listScroll.scrollTo(entryControls[x], animate);

                    return;
                }
            }

            if(entryControls.size() > 0) {
                // Stop the selection sound from playing with a hack
                entryControls[0].setSelected(true);
                m.navigateTo(entryControls[0]);
                listScroll.scrollNormalized(0, animate);
            }
        }
    }

    override UIControl getActiveControl() {
        // Set navigation to the currently selected item
        if(currentArea >= 0 && currentItem >= 0) {
            for(int x = 0; x < entryControls.size(); x++) {
                if(entryControls[x].area == currentArea && entryControls[x].item == currentItem) {
                    return entryControls[x];
                }
            }
        }

        if(entryControls.size() > 0) {
            return entryControls[0];
        }

        if(areaButtons.size() > 0) {
            return areaButtons[currentArea >= 0 && currentArea < areaButtons.size() - 1 ? currentArea : 0];
        }

        return null;
    }

    override void layout(Vector2 parentScale, double parentAlpha) {
        adjustLayoutToSize();
        Super.layout(parentScale, parentAlpha);

        // If the scrollbar is selected and is disabled, move selection back to the active item in the email list
        UIMenu m = getMenu();
        if(m) {
            if(m.activeControl == UIControl(mailScroll.scrollbar)) {
                if(m.activeControl.isDisabled()) {
                    for(int x = 0; x < entryControls.size(); x++) {
                        if(entryControls[x].area == currentArea && entryControls[x].item == currentItem) {
                            m.navigateTo(entryControls[x]);
                            return;
                        }
                    }

                    if(entryControls.size() > 0) {
                        m.navigateTo(entryControls[0]);
                    }
                }
            }
        }

        if(scrollToItem) {
            scrollToItem = false;

            if(currentItem >= 0 && currentItem < entryControls.size()) {
                listScroll.scrollTo(entryControls[currentItem]);
            }
        }
    }
    
    // Getters for entries ==================================

    static int, int getCurrentEntry() {
        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        PDAEntry entry;

        if (evt && players[consolePlayer].mo) {
            entry = PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true));
        }

        int area = -1;
        int entryNum = -1;

        // Find the last selected, or first newest entry
        if(entry) {
            /*for(int x = 0; x < PDAEntry.NUM_AREA; x++) {
                if(entry.entries[x][0].status > 0) {
                    for(int y = 0; y < PDAEntry.NUM_ENTRY; y++) {
                        if(entry.entries[x][y].status == PDAEntry.STATUS_LAST_OPEN) {
                            area = x;
                            entryNum = y;
                            break;
                        }
                    }
                }
            }*/
            area = entry.lastOpenArea;
            entryNum = entry.lastOpenEntry;

            // Nothing was selected, but if we actually have an entry we want to select one by default
            /*if(entryNum <= 0) {
                for(int x = PDAEntry.NUM_AREA - 1; x >= 0; x--) {
                    if(entry.entries[x][0].status > 0) {
                        for(int y = 1; y < PDAEntry.NUM_ENTRY; y++) {
                            if(entry.entries[x][y].status > 0) {
                                area = x;
                                entryNum = y;
                                break;
                            }
                        }
                    }
                }
            }*/
        }

        return area, entryNum;
    }

    static string, string, string, bool, int getEntryInfo(int area, int item) {
        let name = Stringtable.Localize("$PDA_N_" .. area .. "_" .. item);
        let subject = Stringtable.Localize("$PDA_S_" .. area .. "_" .. item);
        let date = StringTable.Localize("$PDA_D_" .. area .. "_" .. item);
        bool hasAttachment = false;
        int status = 0;

        if(Stringtable.Localize("$PDA_E_" .. area .. "_" .. item).IndexOf("#_#") > -1 || Stringtable.Localize("$PDA_E_" .. area .. "_" .. item).IndexOf("#-#") > -1) {
            hasAttachment = true;
        }

        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        if (evt && players[consolePlayer].mo) {
            PDAEntry entry = PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true));
            
            if(entry) {
                status = entry.entries[area][item].status;
            }
        }

        // Sanitize date 
        if(date == String.Format("PDA_D_%d_%d", area, item)) {
            date = StringTable.Localize("$PDA_DATE_DEFAULT");
        }

        return name, subject, date, hasAttachment, status;
    }


    static string getEntryTaste(int area, int item) {
        let content = item > 0 ? StringTable.Localize("$PDA_E_" .. area .. "_" .. item) : "";
        Array<String> ss;
        content.split(ss, "#_#");
        if(ss.size() > 1) {
            content = ss[1];
        }
        ss.clear();
        content.split(ss, "#-#");
        if(ss.size() > 1) {
            content = ss[1];
        }

        // Remove any To/From/Subject
        int startPos = content.indexOf("Subject:");
        if(startPos < 0) startPos = content.indexOf("From:");
        if(startPos < 0) startPos = content.indexOf("To:");
        if(startPos < 0) startPos = content.indexOf("Transcript:");
        if(startPos >= 0) {
            startPos = content.indexOf("\n", startPos);

            if(startPos >= 0) {
                // Fast forward until we hit a character
                while(true) {
                    int ch;
                    int pos;
                    [ch, pos] = content.getNextCodePoint(startPos);
                    if(ch != " " && ch != "\n") break;
                    startPos = pos;
                }
                content = content.mid(startPos);
            }
        }

        if(content.length() > 75) {
            int endIndex = content.rightIndexOf(" ", 75);
            content = content.mid(0, endIndex) .. " ...";
        }

        content.stripRight();
        content.replace("\n", " ");
        content.replace("\t", " ");

        return content;
    }

    static string, string, string, string getFullEntryInfo(int area, int item) {
        let name = Stringtable.Localize("$PDA_N_" .. area .. "_" .. item);
        let nameFooter = Stringtable.Localize("$PDA_N2_" .. area .. "_" .. item);
        let subject = Stringtable.Localize("$PDA_S_" .. area .. "_" .. item);

        let profileImageText = "PDA_PI_" .. area .. "_" .. item;
        string profileImage = Stringtable.Localize("$" .. profileImageText);
        if(profileImage == profileImageText) { 
            profileImage = "";
        }

        return name, nameFooter, subject, profileImage;
    }

    static string, string, bool getEntryContent(int area, int item) {
        let content = item > 0 ? StringTable.Localize("$PDA_E_" .. area .. "_" .. item) : "";
        string attachment = "";
        bool attachAfter = true;

        // Check for attachment
        Array<String> ss;
        content.split(ss, "#_#");
        if(ss.size() > 1) {
            content = ss[1];
            attachment = ss[0];
        } else {
            // Try for attachment at start of entry
            ss.clear();
            content.split(ss, "#-#");
            if(ss.size() > 1) {
                content = ss[1];
                attachment = ss[0];
                attachAfter = false;
            }
        }

        return content, attachment, attachAfter;
    }

    static int getEntryStatus(int area, int item) {
        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        PDAEntry entry;

        if (evt && players[consolePlayer].mo) {
            entry = PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true));
        }

        return entry ? entry.entries[area][item].status : -1;
    }

    override bool menuEvent(int key, bool fromcontroller) {
        UIMenu m = getMenu();
        if(!m) { return false; }    // How the hell could this even happen?

        // Try to determine what section we are in right now
        int navSection = 1;
        if(m.activeControl == UIControl(mailScroll.scrollbar)) {
            navSection = 2;
        } else {
            // check the area buttons
            for(int x = 0; x < areaButtons.size(); x++) {
                if(UIControl(areaButtons[x]) == m.activeControl) {
                    navSection = 0;
                    break;
                }
            }
        }
        
        if(!fromController) {
            if(key == Menu.MKEY_Right) {
                // Only select the scrollbar if there is enough room to scroll
                if(navSection == 1) {
                    if(!mailScroll.scrollbar.disabled) {
                        m.navigateTo(mailScroll.scrollbar);
                        return true;
                    }
                } else if(navSection == 0) {
                    navigateToActiveEmail();
                    unreadTicks = ticks;
                    return true;
                }
            }

            if(key == Menu.MKEY_Left) {
                // Find the currently selected mail item and select that
                if(navSection == 2) {
                    navigateToActiveEmail();
                    unreadTicks = ticks;
                    return true;
                } else if(navSection == 1) {
                    for(int x = 0; x < areaButtons.size(); x++) {
                        if(areaButtons[x].controlID == currentArea) {
                            m.navigateTo(areaButtons[x]);
                            return true;
                        }
                    }

                    if(areaButtons.size() > 0) {
                        m.navigateTo(areaButtons[0]);
                        return true;
                    }
                }
            }
        } else if(key == Menu.MKEY_Right || key == Menu.MKEY_Left || key == Menu.MKEY_Up || key == Menu.MKEY_Down) {
            if(!(m.activeControl is 'PDAReaderEntryButton') && !(m.activeControl == clearUnreadButton)) {
                // Select the current email
                navigateToActiveEmail();
                unreadTicks = ticks;
            }
        }


        if(key == Menu.MKEY_PageUp) {
            cycleAreaList(-1);
            return true;
        } else if(key == Menu.MKEY_PageDown) {
            cycleAreaList(1);
            return true;
        }

        return Super.menuEvent(key, fromcontroller);
    }

    override bool onInputEvent(InputEvent ev) {
        if(ev.type == InputEvent.Type_KeyDown && ev.KeyScan == InputEvent.Key_Pad_LShoulder) {
            //return moveLeft();
            // Move up in the area list
            cycleAreaList(-1);
            return true;
        }

        if(ev.type == InputEvent.Type_KeyDown && ev.KeyScan == InputEvent.Key_Pad_RShoulder) {
            // Navigate to mail list
            //return moveRight();
            // Move down in the area list
            cycleAreaList(1);
            return true;
        }

        return false;
    }

    override void onClose() {
        Super.onClose();
    }

    bool moveLeft() {
        UIMenu m = getMenu();
        if(!m) { return false; }    // How the hell could this even happen?
        if(areaButtons.size() < 2) return false; // Why bother moving here if there is only one section

        // Navigate to area buttons
        for(int x = 0; x < areaButtons.size(); x++) {
            if(areaButtons[x].controlID == currentArea) {
                m.navigateTo(areaButtons[x]);
                return true;
            }
        }

        if(areaButtons.size() > 0) {
            m.navigateTo(areaButtons[0]);
            return true;
        }

        return false;
    }

    bool moveRight() {
        navigateToActiveEmail();
        unreadTicks = ticks;
        return true;
    }

    bool cycleAreaList(int dir) {
        UIMenu m = getMenu();
        if(!m) { return false; }    // How the hell could this even happen?
        if(areaButtons.size() < 2) return false; // Why bother moving here if there is only one section
        

        // Navigate to area buttons
        PDAAreaButton butt;

        for(int x = 0; x < areaButtons.size(); x++) {
            if(areaButtons[x].controlID == currentArea) {
                int i = x + dir;
                if(i >= areaButtons.size()) i = 0;
                if(i < 0) i = areaButtons.size() - 1;
                butt = areaButtons[i]; 
                break;
            }
        }

        if(butt && butt.controlID != currentArea) {
            for(int x = 0; x < areaButtons.size(); x++) {
                areaButtons[x].setSelected(butt == areaButtons[x]);
            }

            currentItem = -1;
            buildEmailList(butt.controlID);
            navigateToActiveEmail();
            unreadTicks = ticks;
            playSound("codex/areaClick");
        }

        return false;
    }
}