class UpgradeAltFireButton : UIButton {
    WeaponAltFire altFire;

    UpgradeAltFireButton init(WeaponAltFire altFire) {
        self.altFire = altFire;

        UIButtonState normState     = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background2.png", (16, 16), (36, 36));
        UIButtonState hovState      = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background3.png", (16, 16), (38, 116));
        UIButtonState pressState    = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background4.png", (16, 16), (38, 116));
        UIButtonState disableState  = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background2.png", (16, 16), (36, 36));
        UIButtonState selectedState         = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background6.png", (50, 52), (75, 54));
        UIButtonState selectedHovState      = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background7.png", (50, 52), (75, 54));
        UIButtonState selectedPressState    = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background7.png", (50, 52), (75, 54));

        normState.blendColor = 0;
        hovState.blendColor = 0;
        pressState.blendColor = 0x6622262E;
        disableState.blendColor = 0;
        selectedState.blendColor = 0;
        selectedHovState.blendColor = 0;
        selectedPressState.blendColor = 0x6622262E;

        Super.init(
            (0,0), (200, 48), 
            StringTable.Localize(altFire.upgradeNameShort), 'SEL46FONT',
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        label.scaleToHeight(27);
        label.textAlign = Align_Left | Align_Middle;
        pinHeight(68);
        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);

        setSelected(altFire.isEnabled());
        
        return self;
    }

    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        Super.transitionToState(idx, sound, mouseSelection);

        if(currentState == State_Selected || currentState == State_SelectedHover || currentState == State_SelectedPressed) {
            setTextPadding(55 + 10, 10, 20, 10);
        } else {
            setTextPadding(20 + 10, 10, 20, 10);
        }
    }
}


class UpgradeFakeAltFireButton : UIButton {
    UpgradeFakeAltFireButton init(class<WeaponAltFire> altFire) {
        UIButtonState normState     = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background2.png", (16, 16), (36, 36));
        UIButtonState hovState      = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background3.png", (16, 16), (38, 116));
        UIButtonState pressState    = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background4.png", (16, 16), (38, 116));
        UIButtonState disableState  = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background2.png", (16, 16), (36, 36));
        UIButtonState selectedState         = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background6.png", (50, 52), (75, 54));
        UIButtonState selectedHovState      = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background7.png", (50, 52), (75, 54));
        UIButtonState selectedPressState    = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background7.png", (50, 52), (75, 54));

        normState.blendColor = 0;
        hovState.blendColor = 0;
        pressState.blendColor = 0x6622262E;
        disableState.blendColor = 0;
        selectedState.blendColor = 0;
        selectedHovState.blendColor = 0;
        selectedPressState.blendColor = 0x6622262E;

        Super.init(
            (0,0), (200, 48), 
            StringTable.Localize("$ALT_FIRE_MISSING"), 'SEL46FONT',
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        label.scaleToHeight(27);
        label.textAlign = Align_Left | Align_Middle;
        label.alpha = 0.5;
        pinHeight(68);
        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);
        
        return self;
    }

    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        Super.transitionToState(idx, sound, mouseSelection);

        if(currentState == State_Selected || currentState == State_SelectedHover || currentState == State_SelectedPressed) {
            setTextPadding(55 + 10, 10, 20, 10);
        } else {
            setTextPadding(20 + 10, 10, 20, 10);
        }
    }
}


class UpgradeAmmoButton : UIButton {
    class<SelacoAmmo> ammo1;
    UILabel priceLabel;
    UIImage coinImage;
    int type;
    int needsUpdate;
    int ammoAmount;      // How much ammo we are buying, cached for use with Upgrade screen. Not used internally
    bool gamepadEnabled;

    UpgradeAmmoButton init(class<SelacoAmmo> amo, int type = 0, bool gamepadEnabled = false) {
        ammo1 = amo;
        self.type = type;
        self.gamepadEnabled = gamepadEnabled;

        UIButtonState normState     = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background2.png", (16, 16), (36, 36), textColor: 0xFFFFFFFF);
        UIButtonState hovState      = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background3.png", (14, 14), (38, 116), textColor: 0xFFFFFFFF);
        UIButtonState pressState    = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background4.png", (14, 14), (38, 116), textColor: 0xFFFFFFFF);
        UIButtonState disableState  = UIButtonState.Create("", textColor: 0xFF999999);
        UIButtonState selectedState         = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background4.png", (14, 14), (38, 116), textColor: 0xFFFFFFFF);
        UIButtonState selectedHovState      = hovState;
        UIButtonState selectedPressState    = hovState;

        normState.blendColor = 0;
        hovState.blendColor = 0;
        pressState.blendColor = 0x6622262E;
        disableState.blendColor = 0;
        selectedState.blendColor = 0;
        selectedHovState.blendColor = 0;
        selectedPressState.blendColor = 0x6622262E;

        let ammo1def = GetDefaultByType(ammo1);
        
        let coinInv = players[consolePlayer].mo.FindInventory('creditscount');
        let inv = players[consolePlayer].mo.FindInventory(ammo1);
        int amountOfAmmo = ammo1def.ShopAmount;
        int maxAmmo = inv ? inv.maxAmount : ammo1def.MaxAmount;
        bool canBuy = true, canBuyAll = true;

        if(type == 1 && inv) amountOfAmmo = maxAmmo - (inv ? inv.Amount : 0);
        int price = type == 0 ? ammo1def.shopPrice : ammo1def.shopPrice * (amountOfAmmo / ammo1def.shopAmount);

        canBuy = (!inv || maxAmmo - inv.Amount > 0) && coinInv && coinInv.amount >= price;
        if(type != 0 && maxAmmo - (inv ? inv.Amount : 0) < ammo1def.shopAmount) canBuy = false;   // Don't allow full refill when we are less than one purchase away 
        
        let title = String.Format("Full Refill %c", gamepadEnabled && canBuy ? 0x89 : 32);
        if(type == 0) {
            title = String.Format("%dx %s %c", amountOfAmmo, StringTable.Localize(ammo1def.AmmoName != "" ? ammo1def.AmmoName : String.Format("%s", ammo1.getClassName())), gamepadEnabled && canBuy ? 0x88 : 32);
        }

        Super.init(
            (0,0), (200, 48), 
            title, 
            'SEL46FONT',
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        label.scaleToHeight(25);
        label.textAlign = Align_Left | Align_Middle;
        pinHeight(68);
        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);

        // Set price label
        if(price > 0) {
            priceLabel = new("UILabel").init((0,0),(100, 10), String.Format("%d", price), "SEL46FONT", textColor: 0xFFFAD364);
            priceLabel.scaleToHeight(27);
            priceLabel.pin(UIPin.Pin_Right, offset: -10 - 29 - 5);
            priceLabel.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
            priceLabel.pinWidth(UIView.Size_Min);
            priceLabel.pinHeight(UIView.Size_Min);
            add(priceLabel);

            coinImage = new("UIImage").init((0,0), (29, 29), WeaponStationGFXPath .. "resourceSelver.png");
            coinImage.pin(UIPin.Pin_Right, offset: -10);
            coinImage.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
            add(coinImage);
        }

        if(!canBuy) setDisabled();

        self.ammoAmount = amountOfAmmo;
        
        return self;
    }

    void update() {
        let ammo1def = GetDefaultByType(ammo1);

        let coinInv = players[consolePlayer].mo.FindInventory('creditscount');
        let inv = players[consolePlayer].mo.FindInventory(ammo1);
        int amountOfAmmo = ammo1def.ShopAmount;
        int maxAmmo = inv ? inv.maxAmount : ammo1def.MaxAmount;
        bool canBuy = true, canBuyAll = true;

        if(type == 1 && inv) amountOfAmmo = maxAmmo - (inv ? inv.Amount : 0);
        int price = type == 0 ? ammo1def.shopPrice : ammo1def.shopPrice * (amountOfAmmo / ammo1def.shopAmount);

        canBuy = (!inv || maxAmmo - inv.Amount > 0) && coinInv && coinInv.amount > price;
        if(type != 0 && maxAmmo - (inv ? inv.Amount : 0) < ammo1def.shopAmount) canBuy = false;   // Don't allow full refill when we are less than one purchase away 
        
        let title = String.Format("Full Refill  %c", gamepadEnabled && canBuy ? 0x89 : 32);
        if(type == 0) {
            title = String.Format("%dx %s  %c", amountOfAmmo, StringTable.Localize(ammo1def.AmmoName != "" ? ammo1def.AmmoName : String.Format("%s", ammo1.getClassName())), gamepadEnabled && canBuy ? 0x88 : 32);
        }

        label.setText(title);
        if(priceLabel) priceLabel.setText(String.Format("%d", price));

        self.ammoAmount = amountOfAmmo;

        setDisabled(!canBuy);
    }

    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        Super.transitionToState(idx, sound, mouseSelection);

        setTextPadding(20, 10, 20, 10);

        if(priceLabel) priceLabel.textColor = currentState == State_Disabled ? 0xFF999999 : 0xFFFAD364;
    }

    override void tick() {
        Super.tick();

        if(--needsUpdate == 0) {
            update();
        }
    }
}