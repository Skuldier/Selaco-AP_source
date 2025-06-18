class StatReaderWindow : PDAFullscreenAppWindow {
    UIVerticalScroll listScroll;
    UIView noDataView;

    const STATWIDTH = 80;

    override PDAAppWindow vInit(Vector2 pos, Vector2 size) {
        return Init(pos, size);
    }
    
    StatReaderWindow init(Vector2 pos, Vector2 size) {
        Super.init(pos, size);
        pinToParent();

        createStandardTitleBar("$STAT_HEADER");

        appID = PDA_APP_STATS;
        //minSize = (500, 450);
        rejectHoverSelection = true;

        listScroll = new("UIVerticalScroll").init((0,0), (320,100), 14, 14,
            NineSlice.Create("PDABAR5", (10,10), (11,13)), null,
            UIButtonState.CreateSlices("PDABAR6", (10,10), (11,13)),
            UIButtonState.CreateSlices("PDABAR7", (10,10), (11,13)),
            UIButtonState.CreateSlices("PDABAR8", (10,10), (11,13)),
            insetA: 15, insetB: 15
        );
        listScroll.pinToParent();
        listScroll.autoHideScrollbar = false;
        listScroll.mLayout.padding.top = 10;
        listScroll.mLayout.padding.bottom = 10;
        listScroll.mLayout.itemSpacing = 13;
        listScroll.scrollbar.rejectHoverSelection = true;
        contentView.add(listScroll);

        // Needs menu, so do this before first draw
        //buildList();
        
        return self;
    }

    override void onAddedToParent(UIView parentView) {
        Super.onAddedToParent(parentView);
        
        if(listScroll.mLayout.numManaged() == 0) buildList();
    }

    override void setDefaultPositionAndSize(int desktopWidth, int desktopHeight) {
        int sideWidth = 32 + 224 + 15;

        
        frame.size = (MIN(600, desktopWidth - sideWidth - 40), MIN(800, desktopHeight - 45));
        frame.pos = (desktopWidth - frame.size.x - 50, desktopHeight - frame.size.y - 20);
    }

    bool checkTrackerForSpecialCaseThisIsALongFunctionName(StatTracker tracker, int index) {
        return index == STAT_KILLS; // There used to be more I swear
    }


    const HIGHLIGHT_COLOR = 0xFFFBC200;
    CONST NORM_COLOR = 0xFFB8BFD1;

    void buildList() {
        Stats allStats = Stats.FindStats();

        bool useTwoRows = getMenu().mainView.frame.size.x > 1700;

        listScroll.mLayout.clearManaged();
        if(allStats) {
            int gcnt = 0;
            for(int group = 0; group < allStats.groups.size(); group++) {
                let header = new("UIView").init((0,0), (1,60));
                header.pin(UIPin.Pin_Left);
                header.pin(UIPin.Pin_Right, offset: -15);

                // Don't bother setting up the header yet, we'll do that if there were actually any values to show under the header
                listScroll.mLayout.addManaged(header);

                int vcnt = 0;
                UIView rowView = NULL;
                for(int x = 0; x < allStats.groups[group].indices.size(); x++) {
                    int col = vcnt % 2;
                    int row = (useTwoRows ? (vcnt / 2) : vcnt) % 2;
                    let tracker = allStats.trackers[allStats.groups[group].indices[x]];

                    // Skip empty stat trackers
                    if(!tracker || (tracker.value == 0 && tracker.possibleValue == 0 && !tracker.alwaysShow)) continue;

                    if(!rowView) {
                        rowView = new("UIView").init((0,0), (1,42));
                        rowView.pin(UIPin.Pin_Left);
                        rowView.pin(UIPin.Pin_Right, offset: -15);
                    }

                    let v = new("UIImage").init((0,0), (1,42), "", NineSlice.Create(row == 0 ? "PDASTLN2" : "PDASTLN1", (17,14), (43,23)));
                    if(!useTwoRows) {
                        v.pin(UIPin.Pin_Left);
                        v.pin(UIPin.Pin_Right);
                    } else if(col == 0) {
                        v.pin(UIPin.Pin_Left);
                        v.pin(UIPin.Pin_Right, UIPin.Pin_HCenter, value: 1.0, offset: -15, isFactor: true);
                    } else {
                        v.pin(UIPin.Pin_Left, UIPin.Pin_HCenter, value: 1.0, offset: 15, isFactor: true);
                        v.pin(UIPin.Pin_Right);
                    }
                    v.clipsSubviews = false;
                    v.pinHeight(42);

                    bool isOneHundo = tracker.value != 0 && tracker.value ~== tracker.possibleValue && !checkTrackerForSpecialCaseThisIsALongFunctionName(tracker, allStats.groups[group].indices[x]);

                    // Name/Title
                    let titleLabel = new("UILabel").init((0,0), (100, 40), StringTable.Localize(tracker.displayName), "PDA18FONT", textColor: isOneHundo ? HIGHLIGHT_COLOR : NORM_COLOR, textAlign: UIView.Align_Middle);
                    titleLabel.multiline = false;
                    titleLabel.pin(UIPin.Pin_Left, offset: 17);
                    titleLabel.pin(UIPin.Pin_Top);
                    titleLabel.pin(UIPin.Pin_Bottom);
                    titleLabel.pin(UIPin.Pin_Right, offset: tracker.possibleValue > 0 ? -255 : -90);
                    titleLabel.clipText = true;
                    titleLabel.autoScale = true;
                    v.add(titleLabel);
                    
                    

                    // Don't show anything but the value if the possible value is pegged at 0
                    // This can be true for some stat counters that don't track the possible total
                    if(tracker.possibleValue > 0 && !checkTrackerForSpecialCaseThisIsALongFunctionName(tracker, allStats.groups[group].indices[x])) {
                        // Value
                        let valLabel = new("UILabel").init((0,0), (100, 40), String.Format("%.0f", tracker.value), "PDA18FONT", textColor: isOneHundo ? HIGHLIGHT_COLOR : NORM_COLOR, textAlign: UIView.Align_Middle | UIView.Align_Right);
                        valLabel.multiline = false;
                        valLabel.pin(UIPin.Pin_Top, offset: -1);
                        valLabel.pin(UIPin.Pin_Bottom);
                        valLabel.pin(UIPin.Pin_Right, offset: -210);
                        valLabel.pinWidth(100);
                        v.add(valLabel);

                        // Possible Value
                        valLabel = new("UILabel").init((0,0), (100, 40), String.Format(" / %.0f", tracker.possibleValue), "PDA18FONT", textColor: isOneHundo ? HIGHLIGHT_COLOR : NORM_COLOR, textAlign: UIView.Align_Middle);
                        valLabel.multiline = false;
                        valLabel.pin(UIPin.Pin_Top, offset: -1);
                        valLabel.pin(UIPin.Pin_Bottom);
                        valLabel.pin(UIPin.Pin_Left, UIPin.Pin_Right, offset: -210);
                        v.add(valLabel);

                        // Percentage
                        valLabel = new("UILabel").init((0,0), (100, 40), String.Format("%.0f%%", tracker.possibleValue > 0 ? (tracker.value / tracker.possibleValue) * 100.0 : 0), "PDA18FONT", textColor: isOneHundo ? HIGHLIGHT_COLOR : NORM_COLOR, textAlign: UIView.Align_middle | UIView.Align_Right);
                        valLabel.multiline = false;
                        valLabel.pin(UIPin.Pin_Top, offset: -1);
                        valLabel.pin(UIPin.Pin_Bottom);
                        valLabel.pin(UIPin.Pin_Right, offset: -23);
                        v.add(valLabel);
                    } else {
                        // Value
                        let valLabel = new("UILabel").init((0,0), (100, 40), String.Format("%.0f", tracker.value), "PDA18FONT", textColor: isOneHundo ? HIGHLIGHT_COLOR : NORM_COLOR, textAlign: UIView.Align_middle | UIView.Align_Right);
                        valLabel.multiline = false;
                        valLabel.pin(UIPin.Pin_Top, offset: -1);
                        valLabel.pin(UIPin.Pin_Bottom);
                        valLabel.pin(UIPin.Pin_Right, offset: -23);
                        valLabel.pinWidth(100);
                        v.add(valLabel);
                    }
                    
                    rowView.add(v);

                    if(col == 1 || !useTwoRows) {
                        listScroll.mLayout.addManaged(rowView);
                        rowView = NULL;
                    }
                    
                    vcnt++;
                }

                if(rowView) {
                    listScroll.mLayout.addManaged(rowView);
                }

                // Now set up the header if necessary
                // No header for the first section, just to fit the design more tightly
                if(vcnt > 0 && gcnt != 0) {
                    let titleLabel = new("UILabel").init((0,0), (100, 40), StringTable.Localize(allStats.groups[group].name), "SEL21FONT", textColor: 0xFF91959B, textAlign: UIView.Align_Centered);
                    titleLabel.alpha = 0.5;
                    titleLabel.pinToParent(0, 20);
                    header.add(titleLabel);
                } else {
                    listScroll.mLayout.removeManaged(header);
                }

                if(vcnt > 0) gcnt++;
            }
        }
    }

    
    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    override UIControl getActiveControl() {
        return listScroll.scrollbar;
    }

    override void onClose() {
        Super.onClose();
    }

    override void tick() {
        Super.tick();

        if(!listScroll.scrollbar.disabled && PDAMenu3(getMenu()).findActiveWindow() == self) {
            let v = SelacoGamepadMenu(getMenu()).getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                listScroll.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }
    }
}