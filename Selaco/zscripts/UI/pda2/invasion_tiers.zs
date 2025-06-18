class PDAInvasionWindow : PDAFullscreenAppWindow {
    UIHorizontalScroll listScroll;
    UIVerticalScroll vScroll;
    UILabel descriptionLabel, descriptionTitleLabel;
    UIImage descriptionImage, hDivider, vDivider;
    Array<InvasionTierButton> buttons;
    bool hasScrolled;
    int lastSelectedInvasionTier;

    override PDAAppWindow vInit(Vector2 pos, Vector2 size) {
        return Init(pos, size);
    }


    PDAInvasionWindow init(Vector2 pos, Vector2 size) {
        Super.init(pos, size);
        pinToParent();

        createStandardTitleBar("Invasion Tiers");

        appID = PDA_APP_INVASION;
        minSize = (600, 500);
        rejectHoverSelection = true;

        lastSelectedInvasionTier = PDAManager.GetLastSelectedInvasionTier(consolePlayer);

        listScroll = new("UIHorizontalScroll").init((0,0), (320,100), 14, 14,
            NineSlice.Create("PDAHBAR1", (6,6), (26,8)), null,
            UIButtonState.CreateSlices("PDAHBAR2", (6,6), (26,8)),
            UIButtonState.CreateSlices("PDAHBAR3", (6,6), (26,8)),
            UIButtonState.CreateSlices("PDAHBAR4", (6,6), (26,8)),
            insetA: 20,
            insetB: 20
        );
        
        listScroll.pin(UIPin.Pin_Left);
        listScroll.pin(UIPin.Pin_Right);
        listScroll.pin(UIPin.Pin_Top, offset: 20);
        listScroll.pinHeight(430);
        listScroll.autoHideScrollbar = true;
        //listScroll.mLayout.padding.left = 20;
        //listScroll.mLayout.padding.right = 20;
        listScroll.mLayout.itemSpacing = 0;
        listScroll.rejectHoverSelection = true;
        listScroll.scrollbar.rejectHoverSelection = true;
        listScroll.scrollbar.firstPin(UIPin.Pin_Bottom).offset = -12;
        contentView.add(listScroll);

        InvasionTierButton lastC = null;
        int numInvasionTiers = 0;
        let inv = players[consoleplayer].mo.FindInventory('dummyItem');
        if(inv) numInvasionTiers = inv.amount;
        else numInvasionTiers = level.invasiontier;

        let tierItem = InvasionTierSystem.Instance().getInvasionTierItem();

        for(int x = 1; x < INVTIER_COUNT; x++) {
            if(tierItem.tiers[x].unlocked && !tierItem.tiers[x].bypassed) {
                let newC = new("InvasionTierButton").init(tierItem, x, false);
                if(lastC) lastC.navRight = newC;
                newC.navLeft = lastC;
                lastC = newC;
                listScroll.mLayout.addManaged( newC );
                buttons.push(newC);
            }
        }

        // Add question block for Mario to smash
        let itb = new("InvasionTierButton").init(tierItem, 0, true);
        itb.navLeft = lastC;
        listScroll.mLayout.addManaged( itb );
        buttons.push(itb);

        let bottomBG = new("UIImage").init((0,0), (0,0), "", NineSlice.Create("PDAMALBG", (20,43), (200, 210)));
        bottomBG.pinToParent(0, 440);
        contentView.add(bottomBG);

        let bottomBGLabel = new("UILabel").init((15, -2), (1, 21), "DETAILS", 'SEL21FONT',  0xFFB9C0D1, textAlign: UIView.Align_Middle);
        bottomBGLabel.pinWidth(1.0, isFactor: true);
        bottomBGLabel.pinHeight(40);
        bottomBG.add(bottomBGLabel);

        vScroll = new("UIVerticalScroll").init((0,0), (320,100), 14, 14,
            NineSlice.Create("PDAVBAR1", (6,6), (8,26)), null,
            UIButtonState.CreateSlices("PDAVBAR2", (6,6), (8,26)),
            UIButtonState.CreateSlices("PDAVBAR3", (6,6), (8,26)),
            UIButtonState.CreateSlices("PDAVBAR4", (6,6), (8,26)),
            insetA: 0,
            insetB: 0
        );
        
        vScroll.pin(UIPin.Pin_Left, offset: 0);
        vScroll.pin(UIPin.Pin_Top, offset: 480 - 430);
        vScroll.pin(UIPin.Pin_Bottom, offset: -20);
        vScroll.pin(UIPin.Pin_Right, offset: -550);
        vScroll.autoHideScrollbar = true;
        vScroll.mLayout.padding.left = 30;
        vScroll.mLayout.padding.right = 20;
        vScroll.mLayout.padding.top = 10;
        vScroll.mLayout.itemSpacing = 10;
        vScroll.scrollbar.rejectHoverSelection = true;
        vScroll.rejectHoverSelection = true;
        bottomBG.add(vScroll);

        String dTitle = "No Invasion Tiers";
        String dDescription = "There is no invasion going on, is there?";
        String dImage = "";

        if(lastC) {
            dTitle = lastC.header;
            dDescription = lastC.text;
            dImage = lastC.invasionImage;
        }

        descriptionTitleLabel = new("UILabel").init((0,0), (1, 21), dTitle, 'SEL46FONT', textColor: Font.FindFontColor("HI"));
        descriptionTitleLabel.scaleToHeight(30);
        descriptionTitleLabel.pin(UIPin.Pin_Left);
        descriptionTitleLabel.pin(UIPin.Pin_Right);
        descriptionTitleLabel.pinHeight(UIView.Size_Min);

        descriptionLabel = new("UILabel").init((0,0), (1, 21), dDescription, 'PDA18FONT');
        descriptionLabel.pin(UIPin.Pin_Left);
        descriptionLabel.pin(UIPin.Pin_Right);
        descriptionLabel.pinHeight(UIView.Size_Min);

        descriptionImage = new("UIImage").init((0,0), (500, 500), dImage, imgStyle: UIImage.Image_Aspect_Scale, imgAnchor: UIImage.ImageAnchor_Top);
        descriptionImage.pin(UIPin.Pin_Right, offset: -20);
        descriptionImage.pin(UIPin.Pin_Top, offset: 480 - 430);
        descriptionImage.pin(UIPin.Pin_Bottom, offset: -20);
        //descriptionImage.maxSize.x = 500;
        descriptionImage.pinWidth(500);
        //descriptionImage.pinHeight(300);

        vScroll.mLayout.addManaged(descriptionTitleLabel);
        UIVerticalLayout(vScroll.mLayout).addSpacer(5);
        vScroll.mLayout.addManaged(descriptionLabel);
        bottomBG.add(descriptionImage);

        vScroll.mLayout.hidden = true; // Hide scroll view until configured at least once

        // Add dividers
        hDivider = new("UIImage").init((0,0), (4, 100), "PDAVDIV1");
        hDivider.pin(UIPin.Pin_Right, offset: 10);
        hDivider.pin(UIPin.Pin_Top);
        hDivider.pin(UIPin.Pin_Bottom);
        hDivider.ignoresClipping = true;
        vScroll.add(hDivider);
        vScroll.moveToBack(hDivider);

        contentView.requiresLayout = true;

        /*vDivider = new("UIImage").init((0,0), (100, 4), "PDAHDIV1");
        vDivider.pin(UIPin.Pin_Right);
        vDivider.pin(UIPin.Pin_Left);
        vDivider.pin(UIPin.Pin_Bottom, offset: 10);
        vDivider.ignoresClipping = true;
        listScroll.add(vDivider);
        listScroll.moveToBack(vDivider);*/

        EventHandler.SendNetworkEvent("seenTiers");

        return self;
    }


    // Handle small/large screens
    void adjustSizes() {
        bool isSmall = contentView.frame.size.x < 1200;

        descriptionImage.firstPin(UIPin.Pin_Right).offset = -20;
        descriptionImage.widthPin.value = min(600, descriptionImage.frame.size.y * 1.47);
        vScroll.firstPin(UIPin.Pin_Right).offset = -(descriptionImage.widthPin.value + 40); //-530 : -550;
    }


    override void layout(Vector2 parentScale, double parentAlpha) {
        Super.layout(parentScale, parentAlpha);

        adjustSizes();

        vScroll.layout();
        descriptionImage.layout();
    }


    override void tick() {
        Super.tick();

        // Select 
        if(!hasScrolled) {
            let c = getActiveControl();
            if(c) {
                if(PDAMenu3(getMenu()).findActiveWindow() == self) getMenu().navigateTo(c);
                listScroll.scrollTo(c);
            }

            hasScrolled = true;
        }

        if(!vScroll.scrollbar.disabled && PDAMenu3(getMenu()).findActiveWindow() == self) {
            let v = SelacoGamepadMenu(getMenu()).getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                vScroll.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }

        if(!listScroll.scrollbar.disabled && PDAMenu3(getMenu()).findActiveWindow() == self) {
            let v = SelacoGamepadMenu(getMenu()).getGamepadRawLook();
            if(abs(v.x) > 0.2) {
                listScroll.scrollByPixels((v.x * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }
    }


    override UIControl getActiveControl() {
        if(lastSelectedInvasionTier >= 0 && lastSelectedInvasionTier < listScroll.mLayout.numManaged()) {
            return UIControl(listScroll.mLayout.getManaged(lastSelectedInvasionTier));
        }

        for(int x = listScroll.mLayout.numManaged() - 1; x >= 0; x--) {
            let c = UIControl(listScroll.mLayout.getManaged(x));
            if(c && !c.isDisabled()) {
                return c;
            }
        }
        return null;
    }


    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if( (ctrl is 'InvasionTierButton' && event == UIHandler.Event_Selected && !fromMouse) || 
            (ctrl is 'InvasionTierButton' && event == UIHandler.Event_Activated)) {
            if(hasScrolled) playSound("ui/ugmhover2");

            if(!fromMouse) listScroll.scrollTo(ctrl, true);

            int buttonIndex = -1;

            for(int x = 0; x < buttons.size(); x++) {
                buttons[x].setSelected(buttons[x] == ctrl);
                if(buttons[x] == ctrl) buttonIndex = x;
            }

            if(event == UIHandler.Event_Activated || !fromMouse) {
                InvasionTierButton btn = InvasionTierButton(ctrl);

                // Use parsed image
                if(btn.invasionImage != "") descriptionImage.setImage(btn.invasionImage);

                // Set text
                vScroll.mLayout.hidden = false;
                descriptionTitleLabel.setText(btn.header);
                descriptionLabel.setText(btn.text);

                EventHandler.SendNetworkEvent("lInvTier", buttonIndex);
            }

            return true;
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    
}


class InvasionTierButton : UIButton {
    UIImage halo, exampleImage;
    UILabel numLabel, nameLabel;
    int invasionTier;
    bool isUnknown;

    String invasionImage, header, text;

    InvasionTierButton init(InvasiontierItem tierItem, int tierIndex, bool unknown = false) {
        UIButtonState normState = UIButtonState.Create("INVTERF1");
        UIButtonState hovState = UIButtonState.Create("INVTERF1");
        UIButtonState selState = UIButtonState.Create("INVTERF2");
        UIButtonState selHovState = UIButtonState.Create("INVTERF2");

        isUnknown = unknown;
        self.invasionTier = tierIndex;

        Super.init((0,0), (192, 400), "", null,
            normState,
            hover: hovState,
            pressed: selState,
            disabled: normState,
            selected: selState,
            selectedHover: selHovState,
            selectedPressed: selState
        );

        pinWidth(192);
        pinHeight(400);

        // Add selected halo/outline
        halo = new("UIImage").init((0,0), (100, 100), "", NineSlice.Create("INVTRFHL", (28, 28), (220, 427)));
        halo.pinToParent(-28, -28, 28, 28);
        add(halo);
        halo.hidden = true;

        // Number Text
        numLabel = new("UILabel").init((0,0), (1, 50), unknown ? "?" : String.Format("%d", tierIndex), 'K32FONT', textAlign: UIView.Align_Centered);
        numLabel.pin(UIPin.Pin_Left);
        numLabel.pin(UIPin.Pin_Right);
        numLabel.pin(UIPin.Pin_VCenter, UIPin.Pin_Top, offset: 56);
        add(numLabel);

        if(isUnknown) {
            header = StringTable.Localize("$INVTIER_UNKNOWN");
            text = "";
            invasionImage = "";
        } else {
            header = tierItem.tiers[tierIndex].name;
            text = tierItem.tiers[tierIndex].description;
            invasionImage = tierItem.tiers[tierIndex].icon;
            //[header, text, invasionImage] = getTutInfo();
        }

        // Image
        exampleImage = new("UIImage").init((0,0), (100, 100), isUnknown ? "ATIINVAQ" : "ATINVA" .. invasionTier, imgStyle: UIImage.Image_Aspect_Fill);
        exampleImage.pin(UIPin.Pin_Left, offset: 20);
        exampleImage.pin(UIPin.Pin_Right, offset: -20);
        exampleImage.pin(UIPin.Pin_Top, offset: 110);
        exampleImage.pin(UIPin.Pin_Bottom, offset: -90);
        //exampleImage.desaturation = 0.9;
        //exampleImage.backgroundColor = 0xFFFF0000;
        add(exampleImage);

        let frameImage = new("UIImage").init((0,0), (100, 100), "", NineSlice.Create("ATIINVFR", (40, 40), (117, 164)));
        frameImage.pinToParent();
        exampleImage.add(frameImage);

        // Title Text
        nameLabel = new("UILabel").init((0,0), (1, 50), header, 'SEL21FONT', textAlign: UIView.Align_Centered);
        nameLabel.pinToParent(20, 305, -20, -10);
        add(nameLabel);

        clipsSubviews = false;

        if(isUnknown) setDisabled();

        return self;
    }


    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        Super.transitionToState(idx, sound, mouseSelection);

        if(halo) halo.hidden = !(currentState == State_Selected || currentState == State_SelectedHover || currentState == State_SelectedPressed);

        /*switch(currentState) {
            case State_Selected:
            case State_SelectedHover:
            case State_SelectedPressed:
                if(exampleImage) exampleImage.desaturation = 0;
                break;
            default:
                if(exampleImage) exampleImage.desaturation = 0.9;
                break;
        }*/

        if(currentState == State_Disabled) {
            setAlpha(0.5);
        }
    }


    private String, String, String getTutInfo() {
        Array<string> p;
        String image, header, text;

        // Parse text and check for an image
        text = StringTable.Localize("$ENEMYUPGRADE_" .. invasionTier);
        text.split(p, "|||");
        if(p.size() > 2) image = p[0];
        if(p.size() > 1) header = p[p.size() - 2];
        if(p.size() > 0) text = p[p.size() - 1];

        return header, text, image;
    }
}