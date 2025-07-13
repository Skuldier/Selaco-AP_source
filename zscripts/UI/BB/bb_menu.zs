#include "ZScripts/UI/BB/bb_item.zs"
#include "ZScripts/UI/BB/bb_window.zs"
#include "ZScripts/UI/BB/bb_shopview.zs"
#include "ZScripts/UI/BB/bb_progress_view.zs"
#include "ZScripts/UI/BB/bb_achievements_view.zs"
#include "ZScripts/UI/BB/bb_inventory_view.zs"
#include "ZScripts/UI/BB/bb_settings.zs"

class BBPremiumItem : Inventory {
    default {
        Inventory.MaxAmount 1;
    }

    static clearscope bool HasPremium() {
        return players[consolePlayer].mo.countInv("BBPremiumItem") > 0;
    }
}

/*class BBGemItem : Inventory {
    default {
        Inventory.MaxAmount 0;
    }

    // Get gems from inventory and add gems that are in global storage
    static clearscope bool CountGems() {
        return BBItem.Find().gems;
    }
}*/

class BBButton : UIButton {
    Array<BBGoldSparkle> sparkles;
    int skin;

    BBButton init(Vector2 size, int skin) {
        string skinFile = String.Format("CCPIC%d", skin);
        self.skin = skin;
        UIButtonState normState     = UIButtonState.Create(skinFile);
        UIButtonState hovState      = UIButtonState.Create(skinFile);
        UIButtonState pressState    = UIButtonState.Create(skinFile);
        pressState.blendColor = 0x66FFFFFF;
        hovState.blendColor = 0x11FFFFFF;
        normState.blendColor = 0;

        Super.init(
            (0,0), size,
            "", null,
            normState,
            hovState,
            pressState,
            null,
            null,
            null,
            null
        );

        pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);

        clipsSubviews = false;

        if(skin == BB_SKIN_GOLD) {
            addSparkles();
        }

        return self;
    }

    void changeSkin(int skin) {
        self.skin = skin;
        buttStates[State_Normal].tex = UITexture.Get(String.Format("CCPIC%d", skin));
        buttStates[State_Hover].tex = UITexture.Get(String.Format("CCPIC%d", skin));
        buttStates[State_Pressed].tex = UITexture.Get(String.Format("CCPIC%d", skin));

        // TODO: Start/Remove sparkle animations if we are changing to or from a gold burger
        if(skin != BB_SKIN_GOLD) {
            removeSparkles();
        } else {
            addSparkles();
        }
    }

    // Merky Sparkles!
    void removeSparkles() {
        for(int x = 0; x < sparkles.size(); x++) {
            sparkles[x].removeFromSuperview();
        }
    }

    void addSparkles() {
        if(sparkles.size() < 10) {
            for(int x = sparkles.size(); x < 10; x++) {
                let sparkle = new("BBGoldSparkle").init();
                sparkle.alpha = 0;
                sparkles.push(sparkle);
            }
        }

        foreach(s : sparkles) {
            if(!s.parent) {
                add(s);
            }
        }
    }

    // Override raycast with a circular version
    override bool raycastTest(Vector2 screenPos) {
        UIBox f;
        getScreenClipActual(f);

		if(f.pointInside(screenPos)) {
            let pos = screenToRel(screenPos);
            return (((frame.size.x, frame.size.y) * 0.5) - pos).length() < 188;
        }

        return false;
	}
}


class BBGoldSparkle : UIImage {
    int ticks;

    BBGoldSparkle init() {
        Super.init((0,0), (1, 1) * frandom(16, 24), "BBSTAR");
        alpha = 0;
        ticks = random(0, 34);

        return self;
    }

    override void tick() {
        Super.tick();

        if(ticks % 35 == 0) {
            let a = getAnimator();
            angle = frandom(0, 360);

            if(a) {
                double pWidth = parent.frame.size.x * 0.5;
                double pHeight = parent.frame.size.y * 0.5;
                frame.pos = (frandom(-pWidth, pWidth), frandom(-pHeight, pHeight * 0.25)) + (parent.frame.size * 0.5);
                a.clear(self);
                double time = frandom(0.45, 0.8);
                animateFrame(
                    time,
                    toPos: (frame.pos.x, frame.pos.y - frandom(15, 32)),
                    ease: Ease_Out
                );

                animateFrame(
                    time * 0.2,
                    toAlpha: 1.0,
                    ease: Ease_In
                );

                let anim = animateFrame(
                    time * 0.7,
                    fromAlpha: 1,
                    toAlpha: 0,
                    ease: Ease_In_Out
                );
                anim.startTime += time * 0.3;
                anim.endTime += time * 0.3;
            }
        }

        ticks++;
    }
}


class BBGoldButton : BBButton {
    int index;
    double value;
    int startTime, endTime;
    float startAngle;
    double startRenderTime, leaving;


    BBGoldButton init(int index, double value, int startTime, int endTime, double scaler = 1.0) {
        Super.init((64, 64) * scaler, 0);

        let bbitem = BBItem.Find();

        self.startTime = startTime;
        self.endTime = endTime;
        self.index = index;
        self.value = value;
        self.alpha = 0;
        startAngle = frandom(-24, 24);
        rejectHoverSelection = true;
        clipsSubviews = false;

        buttStates[State_Normal].tex = UITexture.Get("CCPICM");
        buttStates[State_Hover].tex = UITexture.Get("CCPICM");
        buttStates[State_Pressed].tex = UITexture.Get("CCPICM");

        firstPin(UIPin.Pin_HCenter).value = frandom(0.15, 1.85);
        firstPin(UIPin.Pin_VCenter).value = frandom(0.15, 1.85);

        /*for(int x = 0; x < 10; x++) {
            let sparkle = new("BBGoldSparkle").init();
            sparkle.alpha = 0;
            add(sparkle);
            sparkles.push(sparkle);
        }*/
        addSparkles();

        return self;
    }

    void animateIn() {
        startRenderTime = getMenu().getRenderTime();

        let anim = animateFrame(
            2.0,
            fromSize: frame.size * 0.8,
            toSize: frame.size,
            toAlpha: 1,
            ease: Ease_In
        );
        anim.layoutEveryFrame = true;
        
        anim = animateFrame(
            5.0,
            fromAlpha: 1.0,
            toAlpha: 0,
            ease: Ease_In
        );

        anim.startTime += ((endTime - startTime) * ITICKRATE) - 5.0;
        anim.endTime = anim.startTime + 5.0;
    }

    void animateClickOut() {
        let a = getAnimator();
        if(!a) return;

        leaving = getMenu().getRenderTime();
        a.clear(self, cancelEach: false);

        animateFrame(
            0.15,
            fromSize: frame.size,
            toSize: frame.size * 1.2,
            ease: Ease_Out
        );

        let anim = animateFrame(
            0.15,
            toAlpha: 0,
            ease: Ease_In
        );
        anim.selfDestruct = true;
    }

    override void draw() {
        angle =  UIMath.EaseInCubicF( sin( (getMenu().getRenderTime() + startRenderTime) * 20.0) ) * 45.0 + startAngle;
        Super.draw();
    }
}


class BBShopButton : UIButton {
    int buildingID;
    int prestigeRequired;
    BBItem burgerItem;
    UILabel countLabel, priceLabel;
    UIImage iconImage;
    bool canAfford;

    BBShopButton init(int building, BBItem burgerItem) {
        UIButtonState normState     = UIButtonState.CreateSlices("BBBUTT01", (32,24), (385, 84), scaleCenter: true);
        UIButtonState hovState      = UIButtonState.CreateSlices("BBBUTT03", (32,24), (385, 84), scaleCenter: true);
        UIButtonState pressState    = UIButtonState.CreateSlices("BBBUTT02", (32,24), (385, 84), scaleCenter: true);
        UIButtonState disabledState = UIButtonState.CreateSlices("BBBUTT01", (32,24), (385, 84), scaleCenter: true);
        normState.desaturation = 0.0;
        hovState.desaturation = 0.0;
        pressState.desaturation = 0.0;
        disabledState.desaturation = 1.0;

        buildingID = building;
        self.burgerItem = burgerItem;

        let tt = StringTable.Localize(burgerItem.buildings[building].name);
        
        Super.init(
            (0,0), (320, 90),
            burgerItem.buildings[building].mirrored ? flipWords(tt) : tt, "PDA18FONT",
            normState,
            hovState,
            pressState,
            disabledState,
            null,
            null,
            null
        );

        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);
        pinHeight(90);
        
        iconImage = new("UIImage").init(
            (0,0), (100,100),
            String.Format("BBICO%03d", burgerItem.buildings[building].mirrored ? buildingID - BBItem.Build_MirrorUniverse : buildingID)
        );
        iconImage.pin(UIPin.Pin_Left, offset: 5);
        iconImage.pin(UIPin.Pin_Top, offset: 5);
        iconImage.pin(UIPin.Pin_Bottom);
        iconImage.pinWidth(90);
        iconImage.flipX = burgerItem.buildings[buildingID].mirrored;
        iconImage.blendColor = burgerItem.buildings[buildingID].mirrored ? 0x66CA3DD4 : 0;

        add(iconImage);

        label.textAlign = UIView.Align_TopLeft;
        label.drawShadow = true;
        setTextPadding(100, 8 + 5, 8, 8);

        priceLabel = new("UILabel").init((128,0), (800, 20), "100000", "PDA16FONT", textAlign: UIView.Align_BottomLeft, fontScale: (0.85, 0.85));
        //priceLabel.monospace = true;
        priceLabel.pin(UIPin.Pin_Bottom, offset: -(8 + 5));
        priceLabel.shadowOffset = (1,1);
        priceLabel.drawShadow = true;
        priceLabel.clipsSubviews = false;
        add(priceLabel);

        let burgerBullet = new("UIImage").init((-28, -4), (23,23), "BBBULLE2");
        priceLabel.add(burgerBullet);

        
        countLabel = new("UILabel").init((0,0), (80, 80), String.Format("%d", burgerItem.buildings[building].count), "SEL46FONT", 0XFFFFFFFF, textAlign: UIView.Align_Bottom | UIView.Align_Right);
        countLabel.scaleToHeight(40);
        countLabel.alpha = 0.75;
        countLabel.pin(UIPin.Pin_Right, offset: -20);
        countLabel.pin(UIPin.Pin_Top);
        countLabel.pin(UIPin.Pin_Bottom, offset: -10);
        add(countLabel);

        prestigeRequired = max(0, buildingID - BBItem.Build_MirrorUniverse);

        update();

        return self;
    }

    override bool isDisabled() {
        return disabled || (!canAfford && hidden) || (burgerItem && burgerItem.prestige < prestigeRequired);
    }

    // This is going to hurt
    static clearscope string flipWords(string source) {
        // I was going to flip words but just reverse all letters
        string dest = "";

        for (int x = 0; x < int(source.Length());) {
            int chr, next;
            [chr, next] = source.GetNextCodePoint(x);
            dest = String.Format("%c%s", chr, dest);
            x = next;
        }

        return dest;
    }


    bool update() {
        bool wasHidden = hidden;
        hidden = burgerItem.maxBurgers < (burgerItem.buildings[buildingID].cost * 0.5) && buildingID > 1 && !(burgerItem.buildings[buildingID].count > 0);
        
        // Additional check to make sure we have a previous building
        if(!hidden && buildingID > 2 && burgerItem.buildings[buildingID - 1].count == 0 && burgerItem.buildings[buildingID - 2].count == 0) {
            hidden = true;
        }

        double cost = burgerItem.getBuildingCost(buildingID);

        priceLabel.setText(String.Format("\c[%s]%s", cost > burgerItem.burgers ? "red" : "green", BBWindow.formatTextNumber(cost, true)));
        countLabel.setText(String.Format("%d", burgerItem.buildings[buildingID].count));

        if(!hidden) {
            if(cost > burgerItem.burgers || (burgerItem && burgerItem.prestige < prestigeRequired)) setDisabled();
            else if(!canAfford) setDisabled(false);
        }

        if(wasHidden && !hidden) {
            return true;
        } else if(hidden && !wasHidden) {
            setDisabled(true);
            return true;
        }

        return false;
    }

    override void setDisabled(bool disable) {
        // Don't actually disable anymore, just make it look like we are disabled
        canAfford = !disable;
        let m = getMenu();
        
        if(!disable) {
            bool isActiveControl = (m && m.activeControl == UIControl(self)) || menuSelected;
            if(selected) {
                if(mouseInside) {
                    if(currentState != State_SelectedHover) { transitionToState(State_SelectedHover, mouseSelection: mouseInside); }
                } else {
                    if(currentState != State_Selected) { transitionToState(State_Selected); }
                }
            } else {
                if(mouseInside || isActiveControl) {
                    if(currentState != State_Hover) { transitionToState(State_Hover, mouseSelection: mouseInside); }
                } else {
                    if(currentState != State_Normal) { transitionToState(State_Normal); }
                }
            }

            desaturation = 0;
            if(iconImage) iconImage.desaturation = 0;
            return;
        }

        UIButtonState state = buttStates[State_Disabled];
    
        if(state && iconImage) {
            if(state.desaturation != -1) {
                iconImage.desaturation = state.desaturation;
            }

            if(state.blendColor != -1) {
                iconImage.blendColor = state.blendColor;
            }

            if(label && state.textColor != 0) {
                label.textColor = state.textColor;
            }

            if(state.backgroundColor != 0 && !state.tex.isValid() && state.slices == null) {
                backgroundColor = state.backgroundColor;
            } else if(state.tex.isValid() || state.slices != null) {
                backgroundColor = 0;
            }

            if(state.desaturation != -1) {
                desaturation = state.desaturation;
            }

            if(state.blendColor != -1) {
                blendColor = state.blendColor;
            }
        }

        desaturation = 1.0;
        if(iconImage) iconImage.desaturation = 1.0;
    }

    override void onMouseEnter(Vector2 screenPos) {
        Super.onMouseEnter(screenPos);

        sendEvent(UIHandler.Event_Alternate_Activate, true, false);
    }

    override void onMouseExit(Vector2 screenPos, UIView newView) {
        Super.onMouseExit(screenPos, newView);

        sendEvent(UIHandler.Event_Deselected, true, false);
    }

    override bool raycastTest(Vector2 screenPos) {
        return UIView.raycastTest(screenPos);
	}

    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        Super.transitionToState(idx, sound, mouseSelection);

        UIButtonState state = buttStates[idx];

        if(state && iconImage) {
            if(state.desaturation != -1) {
                iconImage.desaturation = state.desaturation;
            }

            if(state.blendColor != -1) {
                iconImage.blendColor = state.blendColor;
            }
        }

        // Make sure to set desaturation always when cannot afford
        // This undoes a lot of the state stuff but I'm too lazy to make it all cohesive
        // All because of gamepad users. ~~sigh~~
        desaturation = canAfford ? 0 : 1.0;
        if(iconImage) iconImage.desaturation = canAfford ? 0 : 1.0;
    }
}



class BBStorePopup : UIView {
    int buildingID;
    BBItem burgerItem;
    bool mouseMode;

    UILabel nameLabel, descriptionLabel, eachLabel, totalLabel, warningLabel;
    UIVerticalLayout lineLayout;
    UIImage iconImage, bgImg;


    BBStorePopup init(int buildingID, BBItem burgerItem) {
        Super.init((0,0), (500, 100));

        self.pinHeight(UIView.Size_Min);
        self.pinWidth(500);

        self.burgerItem = burgerItem;
        self.buildingID = buildingID;

        bgimg = new("UIImage").init((0,0), (10, 10), "", NineSlice.Create("BBBACK01", (20,20), (380, 380), scaleCenter: true));
        bgimg.pinToParent();
        add(bgimg);

        mouseMode = true;

        lineLayout = new("UIVerticalLayout").init((0,0), (100,100));
        lineLayout.pin(UIPin.Pin_Left, offset: 24);
        lineLayout.pin(UIPin.Pin_Right, offset: -24);
        lineLayout.pin(UIPin.Pin_Top, offset: 48);
        //lineLayout.pinHeight(UIView.Size_Min);
        lineLayout.layoutMode = UIViewManager.Content_SizeParent;
        lineLayout.itemSpacing = 5;
        lineLayout.ignoreHiddenViews = true;
        add(lineLayout);

        nameLabel = new("UILabel").init((8,16), (100, 20), "Name", "PDA16FONT");
        nameLabel.pin(UIPin.Pin_Left, offset: 88);
        nameLabel.pin(UIPin.Pin_Right, offset: -8);
        nameLabel.drawShadow = true;
        add(nameLabel);

        descriptionLabel = new("UILabel").init((8,8), (100, 20), "Description", "PDA16FONT", 0xDDBBBBBB, textAlign: UIView.Align_Right, fontScale: (0.8, 0.8));
        descriptionLabel.pin(UIPin.Pin_Left, offset: 88);
        descriptionLabel.pin(UIPin.Pin_Right);
        descriptionLabel.pinHeight(UIView.Size_Min);
        lineLayout.addManaged(descriptionLabel);

        lineLayout.addSpacer(5);

        let spacer = new("UIView").init((0,0), (100, 2));
        spacer.backgroundColor = 0xCCBBBBBB;
        spacer.pin(UIPin.Pin_Left, offset: 40);
        spacer.pin(UIPin.Pin_Right, offset: -40);
        lineLayout.addManaged(spacer);

        lineLayout.addSpacer(5);

        eachLabel = new("UILabel").init((8,8), (100, 20), "Each produces...", "PDA16FONT", fontScale: (0.8, 0.8));
        eachLabel.pin(UIPin.Pin_Left, offset: 24);
        eachLabel.pin(UIPin.Pin_Right);
        eachLabel.pinHeight(UIView.Size_Min);
        eachLabel.clipsSubviews = false;
        eachLabel.add(new("UIImage").init((-17, 4), (11,11), "BBBULLET"));
        lineLayout.addManaged(eachLabel);

        totalLabel = new("UILabel").init((8,8), (100, 20), "Total production...", "PDA16FONT", fontScale: (0.8, 0.8));
        totalLabel.pin(UIPin.Pin_Left, offset: 24);
        totalLabel.pin(UIPin.Pin_Right);
        totalLabel.pinHeight(UIView.Size_Min);
        totalLabel.clipsSubviews = false;
        totalLabel.add(new("UIImage").init((-17, 4), (11,11), "BBBULLET"));
        lineLayout.addManaged(totalLabel);

        warningLabel = new("UILabel").init((8,8), (100, 20), "Warning", "PDA16FONT", textAlign: UIView.Align_Middle, fontScale: (1, 1));
        warningLabel.pin(UIPin.Pin_Left, offset: 11);
        warningLabel.pin(UIPin.Pin_Right);
        warningLabel.pinHeight(UIView.Size_Min, offset: 20);
        warningLabel.clipsSubviews = false;
        lineLayout.addManaged(warningLabel);

        iconImage = new("UIImage").init((12, 16), (75, 75), "");
        add(iconImage);

        configure();

        return self;
    }

    void configure() {
        // Set up labels for current building
        string buildingName = StringTable.Localize(burgerItem.buildings[buildingID].name);
        if(burgerItem.buildings[buildingID].mirrored) {
            buildingName = BBShopButton.flipWords(buildingName);
        }
        nameLabel.setText(buildingName);

        string description = StringTable.Localize(burgerItem.buildings[buildingID].description);
        if(burgerItem.buildings[buildingID].mirrored) 
            description = BBShopButton.flipWords(description);
        descriptionLabel.setText(description);
        

        let eachBPS = burgerItem.buildings[buildingID].getEachBPS();
        let bps = burgerItem.buildings[buildingID].getBPS();
        eachLabel.setText(String.Format("each %s produces %s burgers per second", buildingName.makeLower(), BBWindow.formatTextNumber(eachBPS, eachBPS > 1)));
        iconImage.setImage(String.Format("BBICO%03d", burgerItem.buildings[buildingID].mirrored ? buildingID - BBItem.Build_MirrorUniverse : buildingID));
        iconImage.flipX = burgerItem.buildings[buildingID].mirrored;
        iconImage.blendColor = burgerItem.buildings[buildingID].mirrored ? 0x66CA3DD4 : 0;
        
        if(burgerItem.buildings[buildingID].count == 0) totalLabel.hidden = true;
        else {
            totalLabel.hidden = false;
            totalLabel.setText(String.Format("%d %ss producing %s burgers per second making %.2f%% of total", burgerItem.buildings[buildingID].count, buildingName.makeLower(), BBWindow.formatTextNumber(bps), burgerItem.bpsc == 0 ? 0 : ((bps / burgerItem.bpscRaw) * 100.0)));
        }

        let prestigeRequired = max(0, buildingID - BBItem.Build_MirrorUniverse);
        if(burgerItem.prestige < prestigeRequired) {
            warningLabel.setText( String.Format(StringTable.Localize("$BBPRESTIGE_REQUIRED"), prestigeRequired) );
            warningLabel.hidden = false;
            bgImg.slices.texture = UITexture.Get("BBBACK08");
        } else {
            warningLabel.setText("");
            warningLabel.hidden = true;
            bgImg.slices.texture = UITexture.Get("BBBACK01");
        }
    }

    override Vector2 calcMinSize(Vector2 parentSize) {
        let lw = lineLayout.calcPinnedWidth((frame.size.x, 9999999));
        let layoutSize = lineLayout.calcMinSize((lw, 9999999));
        return layoutSize + (32, 48 + 32);
    }

    override void layout(Vector2 parentScale, double parentAlpha, bool skipSubviews) {
        Super.layout(parentScale, parentAlpha, skipSubviews);

        let m = getMenu();
        if(m && mouseMode) {
            // Always follow mouse
            let scpy = parent.screenToRel((0,m.mouseY));
            frame.pos.y = clamp(scpy.y - 30, 0, parent.frame.size.y - frame.size.y);
        } else {
            frame.pos.y = parent.frame.size.y - frame.size.y;
        }
    }

    override void Draw() {
        let m = getMenu();
        if(m && mouseMode) {
            // Always follow mouse
            let scpy = parent.screenToRel((0,m.mouseY));
            frame.pos.y = clamp(scpy.y - 30, 0, parent.frame.size.y - frame.size.y);
        } else {
            frame.pos.y = parent.frame.size.y - frame.size.y;
        }
        Super.Draw();
    }
}


class FlippersGFX : UIView {
    int numFlippers;
    UITexture spatTex, glowTex;
    Shape2D segShape, segShape2;
    Shape2DTransform segShapeTransform;

    const FLIPPERS_PER_ROW = 40;
    const FLIPPER_ANGLE_INCREMENT = 360.0 / double(FLIPPERS_PER_ROW);
    const HALF_FLIPPER_ANGLE_INCREMENT = FLIPPER_ANGLE_INCREMENT * 0.5;

    FlippersGFX init() {
        Super.init((0,0), (10, 10));

        spatTex = UITexture.get("BBSPAT01");
        glowTex = UITexture.get("BBGLOWBG");
        buildGlowEffect();

        return self;
    }

    const NUM_INNER_VERTS = 25;
    const N_NUM_INNER_VERTS = (1.0 / double(NUM_INNER_VERTS));
    const CIRCLE_SIZE = 50.0;
    const OUTER_CIRCLE_SIZE = 450.0 + 7.0;

    void buildGlowEffect() {
        if(!segShape) segShape = new("Shape2D");
        else segShape.clear();
        if(!segShape2) segShape2 = new("Shape2D");
        else segShape2.clear();
        if(!segShapeTransform) segShapeTransform = new("Shape2DTransform");

        double segSize = 40.0 / double(NUM_INNER_VERTS);
        for(int x = 0; x <= NUM_INNER_VERTS; x++) {
            double ds = -90.0 + (x * segSize) - (40.0 * 0.5);
            double c = cos(ds), s = sin(ds);
            segShape.pushVertex((CIRCLE_SIZE * c, CIRCLE_SIZE * s));
            segShape.pushCoord((double(x) * N_NUM_INNER_VERTS, 0.999));
            segShape.pushVertex((OUTER_CIRCLE_SIZE * c, OUTER_CIRCLE_SIZE * s));
            segShape.pushCoord((double(x) * N_NUM_INNER_VERTS, 0.001));
        }

        // Inners
        segSize = 55.0 / double(NUM_INNER_VERTS);
        for(int x = 0; x <= NUM_INNER_VERTS; x++) {
            double ds = -90.0 + (x * segSize) - (55.0 * 0.5);
            double c = cos(ds), s = sin(ds);
            segShape2.pushVertex((CIRCLE_SIZE * c, CIRCLE_SIZE * s));
            segShape2.pushCoord((double(x) * N_NUM_INNER_VERTS, 0.999));
            segShape2.pushVertex((OUTER_CIRCLE_SIZE * c, OUTER_CIRCLE_SIZE * s));
            segShape2.pushCoord((double(x) * N_NUM_INNER_VERTS, 0.001));
        }

        int tcount = (NUM_INNER_VERTS * 2);
        for(int x = 0; x < tcount; x += 2) {
            segShape.pushTriangle(x, x + 1, x + 2);
            segShape.pushTriangle(x + 2, x + 1, x + 3);
            segShape2.pushTriangle(x, x + 1, x + 2);
            segShape2.pushTriangle(x + 2, x + 1, x + 3);
        }
    }

    
    override void draw() {
        Super.draw();

        //Screen.ClearClipRect();
        Vector2 center = (frame.size.x / 2.0, frame.size.y / 2.0);

        double time = (double(getMenu().ticks) + System.GetTimeFrac()) * ITICKRATE;
        double totRot = time * 15.0;
        double nc = min(FLIPPERS_PER_ROW / 2.0, double(numFlippers));

        // Draw flippers
        for(int x = 0; x < numFlippers; x++) {
            int index = x % FLIPPERS_PER_ROW;

            int row = int(floor(x / double(FLIPPERS_PER_ROW)));
            double rot = (FLIPPER_ANGLE_INCREMENT * x) + totRot + (row * HALF_FLIPPER_ANGLE_INCREMENT);
            double dist = clamp(norm( (time + (x / nc) + (row * 0.2)) / 10.0, 0, 1 ), 0, 0.035) / 0.035;
            dist = dist >= 0.5 ? 1.0 - UIMath.EaseOutCubicf((dist - 0.5) / 0.5) : UIMath.EaseInCubicF(dist / 0.5);
            dist *= -45.0;

            //double dist = min( 0, sin( (time + (x / 60.0)) * 360 ) ) * 30;
            Vector2 pos = center + Actor.RotateVector((0, -(dist + 240.0 + row * (spatTex.size.y + 5))), rot);
            pos = relToScreen(pos);

            screen.DrawTexture(spatTex.texID, false, 
                pos.x, 
                pos.y,
                DTA_DestWidthF, spatTex.size.x * cScale.x,
                DTA_DestHeightF, spatTex.size.y * cScale.y,
                DTA_KeepRatio, true,
                //DTA_Alpha, a,
                DTA_Filtering, true,
                //DTA_Color, color,
                DTA_Rotate, -rot,
                DTA_LeftOffsetF, 0.5 * spatTex.size.x,
                DTA_TopOffsetF, spatTex.size.y
            );
        }


        // Draw glow effect
        let pxScreenCenter = relToScreen(center);
        for(int x = 0; x < 5; x++) {
            segShapeTransform.clear();
            segShapeTransform.scale(cScale);
            segShapeTransform.rotate((x * (360.0 / 5.0)) + (time * 20.0));
            segShapeTransform.translate(pxScreenCenter);
            segShape.setTransform(segShapeTransform);

            Screen.drawShape(
                glowTex.texID, 
                false,
                segShape,
                DTA_Alpha, alpha,
                DTA_Filtering, true
                //DTA_Color, 0xFF000000
            );
        }


        for(int x = 0; x < 5; x++) {
            segShapeTransform.clear();
            segShapeTransform.scale(cScale * 0.85 * (1.0 - (sin(time * 45) * 0.15)));
            segShapeTransform.rotate((x * (360.0 / 5.0)) - (time * 13.0) + 45.0);
            segShapeTransform.translate(pxScreenCenter);
            segShape2.setTransform(segShapeTransform);

            Screen.drawShape(
                glowTex.texID, 
                false,
                segShape2,
                DTA_Alpha, alpha * 0.38,
                DTA_Filtering, true
                //DTA_Color, 0xFF000000
            );
        }
    }


    double norm(double value, double start = 0, double end = 360) {
        double width       = end - start;
        double offsetValue = value - start;

        return ( offsetValue - ( floor( offsetValue / width ) * width ) ) + start;
    }
}



class FlipNumber : UILabel {
    UIViewAnimation anim;

    FlipNumber init(Vector2 pos, double num) {
        let size = (400, 25);
        Super.init(pos - (size.x / 2.0, 0), size, "+" .. BBWindow.formatTextNumber(num, true, true, true), "PDA16FONT", textAlign: UIView.Align_Center);
        drawShadow = true;

        return self;
    }

    override void onAddedToParent(UIView parentView) {
        Super.onAddedToParent(parentView);

        anim = animateFrame(
            2.5,
            fromPos: frame.pos,
            toPos: frame.pos - (0, 300),
            fromAlpha: 1,
            toAlpha: 0,
            ease: Ease_Out
        );
    }

    override void tick() {
        Super.tick();

        if(!anim.checkValid(anim.getTime())) {
            let animator = getAnimator();
            if(animator) animator.clear(self);
            removeFromSuperview();
            destroy();
            return;
        }
    }
}