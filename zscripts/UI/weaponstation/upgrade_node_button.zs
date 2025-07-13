class UpgradeNodeButton : UIButton {
    mixin CVARBuddy;

    UIImage iconImage;
    class<WeaponUpgrade> upgrade;
    UIImage weaponView, fx, outline, installedImage;
    UIImage tierImage;
    UILabel tierText;
    UILabel coordLabel, installedLabel;
    UpgradeLine line;
    Vector2 relativePos;
    int buttonIndex;
    bool iHaveIt, upgradeEnabled, canBuy;
    bool dragging, rotating, locked;
    double rotateSpeed, lastDrawTime;
    Vector2 dragOffset, deltaMouse;
    UpgradeNodeDragButton dragButton;

    UIButtonState normState, normActiveState;
    UIButtonState hovState, hovActiveState;
    

    UpgradeNodeButton init(readonly<WeaponUpgrade> upgrade, UIImage weaponView, int index) {
        normState                   = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground.png");
        normActiveState             = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground4.png");
        hovState                    = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground2.png");
        hovActiveState              = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground5.png");
        UIButtonState pressState    = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground2.png");
        UIButtonState disableState  = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground3.png");
        UIButtonState selectedState         = normState;
        UIButtonState selectedHovState      = hovState;
        UIButtonState selectedPressState    = pressState;

        Super.init(
            (0,0), (136, 136), 
            "", null,
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        self.upgrade = upgrade.getClass();
        self.weaponView = weaponView;
        if(upgrade.locked) {
            locked = true;
            self.disabled = true;
        }

        buttonIndex = index;

        clipsSubviews = false;

        pinWidth(136);
        pinHeight(136);

        let plr = players[consolePlayer].mo;
        canBuy = plr.countInv("WorkshopTierItem") >= upgrade.requiredSaferooms && plr.countInv("CreditsCount") >= upgrade.creditsCost && plr.countInv("WeaponParts") >= upgrade.cost;

        WeaponUpgrade ug = WeaponUpgrade(players[consolePlayer].mo.FindInventory(upgrade.getClassName()));
        iHaveIt = ug && ug.Amount > 0;
        upgradeEnabled = ug && ug.isEnabled();

        string outlinePic = String.Format("%s%s%d.png", WeaponStationGFXPath, "UPGTIER", upgrade.requiredSaferooms);
        outline = new("UIImage").init((0,0), (136, 136), outlinePic, imgStyle: UIImage.Image_Center);
        outline.pinToParent();
        add(outline);

        iconImage = new("UIImage").init((0,0), (136, 136), upgrade.upgradeImage, imgStyle: UIImage.Image_Center);
        iconImage.pinToParent();
        add(iconImage);

        if(upgrade.workshopPointerPosX < 999998 || iGetCVar("devmode") > 0) {
            Vector2 pointerPos = (upgrade.workshopPointerPosX < 999998 ? upgrade.workshopPointerPosX : 0, upgrade.workshopPointerPosY < 999998 ? upgrade.workshopPointerPosY : 0);
            line = new("UpgradeLine").init(self, (68, 68), 80, weaponView, pointerPos, !canBuy);
            add(line);
        }
        

        if(upgrade.workshopPosX < 999998) {
            relativePos = (upgrade.workshopPosX, upgrade.workshopPosY);
        } else {
            relativePos = ((index / 5.0) * weaponView.tex.size.x - 160, -100);
        }

        if(iGetCVar("devmode") > 0) {
            coordLabel = new("UILabel").init((0,0), (150, 30), String.Format("[ x: %.0f, y: %.0f ]", relativePos.x, relativePos.y), 'SEL16FONT', textAlign: UIView.Align_Center);
            coordLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
            coordLabel.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 1.0, offset: 5, isFactor: true);
            add(coordLabel);

            dragButton = new("UpgradeNodeDragButton").init(self);
        }

        installedImage = new("UIImage").init((0,0), (107, 33), WeaponStationGFXPath .. "installBG2.png");
        installedImage.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        installedImage.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 1.0, offset: -15, isFactor: true);
        add(installedImage);
        installedImage.hidden = !(iHaveIt || upgradeEnabled);

        installedLabel = new("UILabel").init((0,0), (150, 30), iHaveIt ? "INSTALLED" : "OWNED", 'SEL16FONT', textAlign: UIView.Align_Centered);
        installedLabel.pinToParent();
        installedImage.add(installedLabel);

        if(!iHaveIt) {
            installedImage.setImage(WeaponStationGFXPath .. "installBG3.png");
        }

        transitionToState(self.disabled ? State_Disabled : (self.selected ? State_Selected : State_Normal), false);

        setUpgradeEnabled(iHaveIt && ug && ug.isEnabled(), iHaveIt);

        return self;
    }

    override void tick() {
        Super.tick();

        rotateSpeed = rotating ? MIN(30, MAX(5, rotateSpeed) * 1.15) : MAX(0, rotateSpeed * 0.9);
    }

    override void onAddedToParent(UIView parentView) {
        Super.onAddedToParent(parentView);

        if(parent && dragButton) {
            parent.add(dragButton);
        }
    }

    override void onRemoved(UIView oldSuperview) {
        Super.onRemoved(oldSuperview);
        if(dragButton) oldSuperview.removeView(dragButton);
    }

    void refresh() {
        let upgrade = GetDefaultByType(upgrade);

        let plr = players[consolePlayer].mo;
        canBuy = plr.countInv("WorkshopTierItem") >= upgrade.requiredSaferooms && plr.countInv("CreditsCount") >= upgrade.creditsCost && plr.countInv("WeaponParts") >= upgrade.cost;

        WeaponUpgrade ug = WeaponUpgrade(players[consolePlayer].mo.FindInventory(upgrade.getClassName()));
        iHaveIt = ug && ug.Amount > 0;
        setUpgradeEnabled(iHaveIt && ug && ug.isEnabled(), iHaveIt);
    }

    void setUpgradeEnabled(bool enabled, bool owned) {
        upgradeEnabled = enabled;

        // TODO: Replace with graphics
        installedImage.hidden = !enabled && !owned;
        installedLabel.setText(enabled ? "INSTALLED" : "OWNED");
        installedLabel.textColor = enabled ? 0xFFFFFFFF : 0xFF505C76;
        installedImage.setImage(WeaponStationGFXPath .. "installBG" .. (enabled ? "2" : "3") .. ".png");
        buttStates[State_Normal] = enabled ? normActiveState : normState;
        buttStates[State_Hover] = enabled ? hovActiveState : hovState;
        buttStates[State_SelectedHover] = buttStates[State_Hover];
        //outline.hidden = enabled;

        let animator = getAnimator();
        if(animator) {
            animator.clear(outline);
            if(!enabled && outline.alpha == 0) {
                outline.animateFrame(
                    0.1,
                    toAlpha: 1,
                    ease: Ease_In
                );

                outline.animateImage(
                    0.1,
                    fromScale: (1.55, 1.55),
                    toScale: (1, 1),
                    ease: Ease_In
                );
            } else if(enabled) {
                outline.animateFrame(
                    0.1,
                    toAlpha: 0,
                    ease: Ease_In
                );

                outline.animateImage(
                    0.1,
                    toScale: (1.55, 1.55),
                    ease: Ease_In
                );
            }
        } else {
            outline.alpha = enabled ? 0 : 1;
        }

        transitionToState(currentState, false, false);
    }

    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        Super.transitionToState(idx, sound, mouseSelection);

        if(!iconImage) return;  // We haven't fully inited yet

        if(!locked && (canBuy || iHaveIt)) {
            if(tierImage) {
                tierText.alpha = 1;
                tierImage.alpha = 1;
            }
            iconImage.alpha = 1;
            if(currentState == State_Pressed) {
                iconImage.blendColor = 0x6622262E;
                iconImage.desaturation = 0;
                blendColor = 0x6622262E;
                outline.blendColor = 0x6622262E;
                outline.desaturation = 0;
            } else {
                iconImage.blendColor = 0;
                iconImage.desaturation = 0;
                blendColor = 0;
                
                outline.blendColor = currentState == State_Hover ? 0xFF53C5FB : 0;
                outline.desaturation = currentState == State_Hover ? 1 : 0;
            }

            rotating = currentState == State_Hover;
        } else {
            let plr = players[consolePlayer].mo;
            let upgrade = GetDefaultByType(upgrade);
            if(plr.countInv("WorkshopTierItem") < upgrade.requiredSaferooms) {
                iconImage.alpha = 0.1;

                if(!tierImage) {
                    tierImage = new("UIImage").init((0,0), (120, 120), "UPGRDLCK");
                    tierImage.pin(UIPin.Pin_VCenter, value: 1.0, offset: 0, isFactor: true);
                    tierImage.pin(UIPin.Pin_HCenter, value: 1.0, offset: 0, isFactor: true);
                    add(tierImage);

                    tierText = new("UILabel").init((0,0), (100, 50), String.Format("%d", upgrade.requiredSaferooms), 'SEL46FONT', textAlign: UIView.Align_Centered, fontScale: (0.85, 0.85));
                    tierText.multiline = false;
                    tierText.pin(UIPin.Pin_VCenter, value: 1.0, offset: 4, isFactor: true);
                    tierText.pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1.0, offset: upgrade.requiredSaferooms == 1 ? -3 : 0, isFactor: true);
                    add(tierText);
                } else {
                    tierText.setText(String.Format("%d", upgrade.requiredSaferooms));
                    tierText.alpha = 1;
                    tierImage.alpha = 1;
                    tierText.firstPin(UIPin.Pin_HCenter).offset = upgrade.requiredSaferooms == 1 ? -3 : 0;
                }
            } else {
                iconImage.alpha = 1;
            }
            
            if(currentState == State_Pressed) {
                iconImage.blendColor = 0xFFDDDDDD;
                iconImage.desaturation = 1;
                blendColor = 0x6622262E;
                desaturation = 1;
                outline.blendColor = 0x6622262E;
                outline.desaturation = 1;
            } else {
                iconImage.blendColor = 0xFFFFFFFF;
                iconImage.desaturation = 1;
                blendColor = currentState == State_Hover ? 0xFFFFFFFF : 0xFF777777;
                desaturation = 1;
                outline.blendColor = currentState == State_Hover ? 0xFFFFFFFF : 0xFF777777;
                outline.desaturation = 1;
            }

            rotating = false;
        }
        

        if(line) {
            line.selected = currentState == State_Hover || currentState == State_Pressed;
        }
    }

    override void layout(Vector2 parentScale, double parentAlpha, bool skipSubviews) {
        cScale = (parentScale ~== (0,0) ? calcScale() : (parentScale.x * scale.x, parentScale.y * scale.y));
        cAlpha = (parentAlpha == -1 ? calcAlpha() : parentAlpha) * alpha;

        // Process anchor pins
        processPins();
        
        // Set position relative to the image view
        frame.pos = parent.screenToRel(weaponView.relToScreen(weaponView.imageRelToLocal(relativePos))) - (frame.size / 2.0);

        // Layout subviews
        if(!skipSubviews) layoutSubviews();

        buildShapes();

        requiresLayout = false;
    }

    override void drawSubviews() {
        double time = getTime();
        if(lastDrawTime == 0) {
            lastDrawTime = time;
        }

        outline.rotation += rotateSpeed * (time - lastDrawTime);
        lastDrawTime = time;

        Super.drawSubviews();
    }

    void animateIn(double delay = 0) {
        if(!fx) { 
            fx = new("UIImage").init((0,0), frame.size, WeaponStationGFXPath .. "upgradeBackgroundFX.png");
            fx.ignoresClipping = true;
            fx.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
            fx.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        }
        add(fx);

        let anim = animateFrame(
            0.13,
            fromAlpha: 0,
            toAlpha: 1,
            ease: Ease_In
        );
        anim.startTime += delay;
        anim.endTime += delay;
        anim.layoutEveryFrame = true;

        anim = fx.animateFrame(
            0.13,
            fromSize: frame.size,
            toSize: frame.size * 3,
            fromAlpha: 1,
            toAlpha: 0,
            ease: Ease_Out
        );
        anim.layoutEveryFrame = true;
        anim.scaleStart = (1,1);
        anim.scaleEnd = (3.0, 3.0);
        anim.startTime += delay + 0.12;
        anim.endTime += delay + 0.12;
    }

    void animateOut() {

    }

    override void onMouseDown(Vector2 screenPos) {
        if(iGetCVar("devmode") > 0) {
            mouseInside = true;
            dragging = true;
            deltaMouse = screenPos;
            dragOffset = parent.screenToRel(screenPos) - frame.pos;
        } else {
            Super.onMouseDown(screenPos);
        }
    }


    override void onMouseUp(Vector2 screenPos) {
        if(iGetCVar("devmode") > 0) {
            if(dragging) {
                dragging = false;
                return;
            }
        }

        Super.onMouseUp(screenPos);
    }

    override void onMouseExit(Vector2 screenPos, UIView newView) {
        mouseInside = false;

        if(!dragging) {
            Super.onMouseExit(screenPos, newView);
        }
    }

    override bool event(ViewEvent ev) {
        if(ev.type == UIEvent.Type_MouseMove && dragging) {
            let screenPos = (ev.MouseX, ev.MouseY);
            frame.pos = parent.screenToRel(screenPos) - dragOffset;
            deltaMouse = screenPos;
            if(coordLabel) {
                Vector2 lpos = frame.pos + (frame.size / 2.0);
                Vector2 relativePos = weaponView.localToImageRel(weaponView.screenToRel(parent.relToScreen(lpos)));
                coordLabel.setText(String.Format("[ x: %.0f, y: %.0f ]", relativePos.x, relativePos.y));
            }
            layoutSubviews();
        }

        return Super.event(ev);
    }
}


class UpgradeNodeDragButton : UIButton {
    UpgradeNodeButton nodeButt;
    UILabel coordLabel;
    bool dragging;
    Vector2 dragOffset, deltaMouse;

    UpgradeNodeDragButton init(UpgradeNodeButton butt) {
        UIButtonState normState     = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground.png");
        UIButtonState hovState      = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground2.png");
        UIButtonState pressState    = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground2.png");
        UIButtonState disableState  = UIButtonState.Create(WeaponStationGFXPath .. "upgradeBackground3.png");
        UIButtonState selectedState         = normState;
        UIButtonState selectedHovState      = hovState;
        UIButtonState selectedPressState    = pressState;

        Super.init(
            (0,0), (32, 32), 
            "", null,
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        nodeButt = butt;
        clipsSubviews = false;

        pinWidth(32);
        pinHeight(32);

        readonly< WeaponUpgrade > ug = GetDefaultByType(nodeButt.upgrade);
        Vector2 relativePos = (ug.workshopPointerPosX, ug.workshopPointerPosY);
        coordLabel = new("UILabel").init((0,0), (150, 30), String.Format("[ x: %.0f, y: %.0f ]", relativePos.x, relativePos.y), 'SEL16FONT', textAlign: UIView.Align_Center);
        coordLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        coordLabel.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 1.0, offset: 5, isFactor: true);
        add(coordLabel);

        return self;
    }


    override void layout(Vector2 parentScale, double parentAlpha, bool skipSubviews) {
        cScale = (parentScale ~== (0,0) ? calcScale() : (parentScale.x * scale.x, parentScale.y * scale.y));
        cAlpha = (parentAlpha == -1 ? calcAlpha() : parentAlpha) * alpha;

        // Process anchor pins
        processPins();
        
        // Set position relative to node point pos
        frame.pos = parent.screenToRel(nodeButt.weaponView.relToScreen(nodeButt.weaponView.imageRelToLocal(nodeButt.line.destPoint))) - (frame.size / 2.0);

        // Layout subviews
        if(!skipSubviews) layoutSubviews();

        buildShapes();

        requiresLayout = false;
    }


    override bool event(ViewEvent ev) {
        if(ev.type == UIEvent.Type_MouseMove && dragging) {
            let screenPos = (ev.MouseX, ev.MouseY);
            frame.pos = parent.screenToRel(screenPos) - dragOffset;
            deltaMouse = screenPos;
            if(coordLabel) {
                Vector2 lpos = frame.pos + (frame.size / 2.0);
                Vector2 relativePos = nodeButt.weaponView.localToImageRel(nodeButt.weaponView.screenToRel(parent.relToScreen(lpos)));
                nodeButt.line.destPoint = relativePos;
                coordLabel.setText(String.Format("[ x: %.0f, y: %.0f ]", relativePos.x, relativePos.y));
            }
            nodeButt.line.layout();
        }

        return Super.event(ev);
    }

    override void onMouseDown(Vector2 screenPos) {
        mouseInside = true;
        dragging = true;
        deltaMouse = screenPos;
        dragOffset = parent.screenToRel(screenPos) - frame.pos;
    }


    override void onMouseUp(Vector2 screenPos) {
        if(dragging) {
            dragging = false;
            return;
        }
    }

    override void onMouseExit(Vector2 screenPos, UIView newView) {
        mouseInside = false;

        if(!dragging) {
            Super.onMouseExit(screenPos, newView);
        }
    }
}