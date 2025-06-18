class ObjectivesWindow : PDAFullscreenAppWindow {
    UIVerticalScroll listScroll;
    UIView noDataView;

    const STATWIDTH = 80;

    override PDAAppWindow vInit(Vector2 pos, Vector2 size) {
        return Init(pos, size);
    }
    
    ObjectivesWindow init(Vector2 pos, Vector2 size) {
        Super.init(pos, size);
        pinToParent();

        createStandardTitleBar("$OBJECTIVES_HEADER");

        appID = PDA_APP_OBJECTIVES;
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
        listScroll.mLayout.padding.top = 20;
        listScroll.mLayout.padding.bottom = 20;
        listScroll.mLayout.itemSpacing = 12;
        listScroll.scrollbar.rejectHoverSelection = true;
        contentView.add(listScroll);

        noDataView = new("UILabel").init((0,0), (0,0), "NO OBJECTIVES", "SEL27OFONT", textAlign: UIView.Align_Centered);
        noDataView.pinToParent();
        noDataView.hidden = true;
        contentView.add(noDataView);

        buildList();
        
        return self;
    }


    override void setDefaultPositionAndSize(int desktopWidth, int desktopHeight) {
        
    }



    void buildList() {
        let os = Objectives.FindObjectives();

        if(os) {
            noDataView.hidden = true;

            bool hasObjectives = buildCurrentObjectives(os);
            addSeparator("Completed Objectives");
            hasObjectives = buildCompletedObjectives(os) || hasObjectives;

            if(!hasObjectives) {
                listScroll.mLayout.clearManaged();
                noDataView.hidden = false;
            }

        } else {
            // Show noDataView
            noDataView.hidden = false;
        }
    }

    void addSeparator(string title) {
        UIView container = new("UIView").init(size: (0, 70));
        container.pin(UIPin.Pin_Left);
        container.pin(UIPin.Pin_Right);

        // Create title label
        let titleLabel = new("UILabel").init((0, 20), (300, 40), title, "SEL46FONT", 0xFFB9C0D1);
        titleLabel.scaleToHeight(30);
        titleLabel.pin(UIPin.Pin_Left, offset: 10);
        titleLabel.pin(UIPin.Pin_Right);
        container.add(titleLabel);

        // Create separator
        let sep = new("UIView").init((0,60), (100, 2));
        sep.pin(UIPin.Pin_Left);
        sep.pin(UIPin.Pin_Right, offset: -50);
        sep.backgroundColor = 0xFF586685;
        container.add(sep);
        
        listScroll.mLayout.addManaged(container);
    }


    bool buildCurrentObjectives(Objectives os) {
        // First pass: Get objectives only for the current map
        for(int x = 0; x < os.objs.size(); x++) {
            let o = os.objs[x];

            if(o.mapNum != Level.levelnum || o.status != Objective.STATUS_ACTIVE) { continue; }

            // Add spacer between main objectives
            if(listScroll.mLayout.numManaged() > 0) {
                UIVerticalLayout(listScroll.mLayout).addSpacer(15);
            }

            listScroll.mLayout.addManaged(makeLine(o.icon .. (o.status + 1), o.title, o.description, 0));

            for(int y = 0; y < o.children.size(); y++) {
                let o2 = o.children[y];
                let title = o2.title;
                
                if(o2.hideOutsideMap && o2.mapNum != Level.levelnum && o2.status != Objective.STATUS_COMPLETE) { 
                    // Append the name of the map to the title since it belongs to another map
                    let info = LevelInfo.FindLevelByNum(o2.mapNum);
                    if(info) {
                        title = String.Format("%s [%s]", title, StringTable.Localize(info.LevelName));
                    }
                }

                if(o2.status == Objective.STATUS_COMPLETE) {
                    title = String.Format("%s [%s]", title, "COMPLETED");
                }

                listScroll.mLayout.addManaged(makeLine(o2.icon .. (o2.status + 4), title, o2.description, 1, y == o.children.size() - 1, y == 0 && o.description == ""));
            }
        }

        // Second pass: Get objectives for other maps that are not yet complete
        for(int x = 0; x < os.objs.size(); x++) {
            let o = os.objs[x];
            if(o.mapNum == Level.levelnum  || o.status != Objective.STATUS_ACTIVE) { continue; }
            
            // Add spacer between main objectives
            if(listScroll.mLayout.numManaged() > 0) {
                UIVerticalLayout(listScroll.mLayout).addSpacer(15);
            }

            string mainTitle = o.title;

            // Add map name
            let info = LevelInfo.FindLevelByNum(o.mapNum);
            if(info) mainTitle = String.Format("%s [%s]", mainTitle, StringTable.Localize(info.LevelName));

            listScroll.mLayout.addManaged(makeLine(o.icon .. (o.status + 1), mainTitle, o.description, 0));

            for(int y = 0; y < o.children.size(); y++) {
                let o2 = o.children[y];
                let title = o2.title;
                
                if(o2.hideOutsideMap && o2.mapNum != o.mapNum && o2.status != Objective.STATUS_COMPLETE) { 
                    // Append the name of the map to the title since it belongs to another map
                    let info = LevelInfo.FindLevelByNum(o2.mapNum);
                    if(info) {
                        title = String.Format("%s [%s]", title, StringTable.Localize(info.LevelName));
                    }
                }

                if(o2.status == Objective.STATUS_COMPLETE) {
                    title = String.Format("%s [%s]", title, "COMPLETED");
                }

                listScroll.mLayout.addManaged(makeLine(o2.icon .. (o2.status + 4), title, o2.description, 1, y == o.children.size() - 1, y == 0 && o.description == ""));
            }
        }

        return listScroll.mLayout.numManaged() > 0;
    }


    bool buildOldObjective(Objectives os, int usedMapID, out int count, Objective o) {
        // Skip non-completed main objectives
        if(o.mapNum != usedMapID || o.status == Objective.STATUS_ACTIVE) {
            return false;
        }

        // Add spacer between main objectives
        if(count > 0) {
            UIVerticalLayout(listScroll.mLayout).addSpacer(15);
        }
        
        let mainTitle = o.title;

        // Add map name
        let info = LevelInfo.FindLevelByNum(o.mapNum);
        if(info) mainTitle = String.Format("%s [%s]", mainTitle, StringTable.Localize(info.LevelName));

        listScroll.mLayout.addManaged(makeLine(o.icon .. (o.status + 1), mainTitle, o.description, 0));

        for(int y = 0; y < o.children.size(); y++) {
            let o2 = o.children[y];
            let title = o2.title;
            
            if(o2.hideOutsideMap && o2.mapNum != usedMapID && o2.status != Objective.STATUS_COMPLETE) { 
                // Append the name of the map to the title since it belongs to another map
                let info = LevelInfo.FindLevelByNum(o2.mapNum);
                if(info) {
                    title = String.Format("%s [%s]", title, StringTable.Localize(info.LevelName));
                }
            }

            if(o2.status == Objective.STATUS_COMPLETE) {
                title = String.Format("%s [%s]", title, "COMPLETED");
            }
            
            listScroll.mLayout.addManaged(makeLine(o2.icon .. (o2.status + 4), o2.title, o2.description, 1, y == o.children.size() - 1, y == 0 && o.description == ""));
        }

        count++;

        return true;
    }


    bool buildCompletedObjectives(Objectives os, int mapID = int.max, int count = 0) {
        int viewCnt = listScroll.mLayout.numManaged();

        // Sort objectives by inverse map ID
        // Find next highest map ID
        int usedMapID = -1;
        for(int x = 0; x < os.objs.size(); x++) {
            if(os.objs[x].mapNum < mapID && os.objs[x].mapNum > usedMapID) {
                usedMapID = os.objs[x].mapNum;
            }
        }

        if(usedMapID == -1) {
            for(int x = 0; x < os.history.size(); x++) {
                if(os.history[x].mapNum < mapID && os.history[x].mapNum > usedMapID) {
                    usedMapID = os.history[x].mapNum;
                }
            }
        }
        
        if(usedMapID > -1) {
            for(int x = 0; x < os.objs.size(); x++) {
                let o = os.objs[x];
                buildOldObjective(os, usedMapID, count, o);
            }

            for(int x = 0; x < os.history.size(); x++) {
                let o = os.history[x];
                buildOldObjective(os, usedMapID, count, o);
            }
            buildCompletedObjectives(os, usedMapID, count);
        }

        return listScroll.mLayout.numManaged() > viewCnt;
    }


    UIView makeLine(string img, string txt, string description, int indent, bool last = true, bool shortParent = false) {
        UIVerticalLayout container = new("UIVerticalLayout").init((0,0), (300, 120));
        container.layoutMode = UIViewManager.Content_SizeParent;
        container.pin(UIPin.Pin_Left);
        container.pin(UIPin.Pin_Right);
        container.clipsSubviews = false;
        container.itemSpacing = 15;

        Font fnt = Font.FindFont(indent == 0 ? "PDA18FONT": "PDA16FONT");
        int left = 50 + (40 * indent);

        let txtA = new("UILabel").init((0, 0), (100, 22), txt, fnt, 0xFFB8BFD1, fontScale: (1,1));
        txtA.multiline = true;
        txtA.pin(UIPin.Pin_Left, offset: left);
        txtA.pin(UIPin.Pin_Right, offset: -25);
        txtA.pinHeight(UIView.Size_Min);
        txtA.clipsSubviews = false;

        // Add image directly to the label
        UIImage imgA;
        if(img != "") {
            imgA = new("UIImage").init((indent > 0 ? -45 : -50, indent > 0 ? -9 : -6), (40, 40), img, imgStyle: UIImage.Image_Aspect_Fit, imgAnchor: UIImage.ImageAnchor_Middle);
            imgA.blendColor = 0xFFB8BFD1;
            txtA.add(imgA);
            imgA.clipsSubviews = false;
        }

        container.addManaged(txtA);

        if(description != "") {
            let txtB = new("UILabel").init((0, 0), (100, 22), description, "PDA16FONT", 0xFF9DA7BF, fontScale: indent == 0 ? (1,1) : (0.8, 0.8));
            txtB.alpha = 0.8;
            txtB.multiline = true;
            txtB.pin(UIPin.Pin_Left, offset: left + 20);
            txtB.pin(UIPin.Pin_Right, offset: -25);
            txtB.maxSize.x = 1100;
            txtB.pinHeight(UIView.Size_Min);
            container.addManaged(txtB);
            container.addSpacer(0);
        }


        // Add objective line
        if(indent > 0) {
            let objLine = new("UIImage").init((-71,0), (15, 10), "OBJLINE2", imgStyle: UIImage.Image_Absolute, imgAnchor: UIImage.ImageAnchor_BottomLeft);
            if(!shortParent) objLine.pin(UIPin.Pin_Top, offset: -(listScroll.mLayout.itemSpacing + 1));
            else objLine.pin(UIPin.Pin_Top, offset: 0);
            objLine.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: 14);
            objLine.blendColor = 0xFFB8BFD1;
            txtA.add(objLine);

            // Add bottom part of the line
            if(!last) {
                objLine = new("UIImage").init((-71,0), (15, 10), "OBJLINE2", imgStyle: UIImage.Image_Absolute, imgAnchor: UIImage.ImageAnchor_TopLeft);
                objLine.pin(UIPin.Pin_Top, offset: 11);
                objLine.pin(UIPin.Pin_Bottom, offset: 1);
                objLine.blendColor = 0xFFB8BFD1;
                
                txtA.add(objLine);
            }
        } else if(description != "" && imgA) {
            let objLine = new("UIImage").init((19,0), (15, 10), "OBJLINE2", imgStyle: UIImage.Image_Absolute, imgAnchor: UIImage.ImageAnchor_TopLeft);
            objLine.pin(UIPin.Pin_Top, offset: imgA.frame.size.y + imgA.frame.pos.y + 10);
            objLine.pin(UIPin.Pin_Bottom, offset: 1);
            objLine.blendColor = 0xFFB8BFD1;
            
            container.add(objLine);
        }
        

        return container;
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

        if(!listScroll.scrollbar.disabled  && PDAMenu3(getMenu()).findActiveWindow() == self) {
            let v = SelacoGamepadMenu(getMenu()).getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                listScroll.scrollByPixels(v.y * CommonUI.STANDARD_SCROLL_AMOUNT, true, false, false);
            }
        }
    }
}