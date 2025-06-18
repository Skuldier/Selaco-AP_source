class HUDAol : HUDElementStartup {
    TextureID unreadImage, tiersImage;
    int hasUnreadMail;
	bool hasNewInvasionTiers;
    bool firstDatapadPickup;
	string codexKeybind;
    double baseline, lOffset;

    override HUDElement init() {
        unreadImage = TexMan.checkForTexture("NEWMAIL3");
		tiersImage = TexMan.checkForTexture("NEWTIERS");
        firstDatapadPickup = true;
		calcKeybinds();

		makeReady("NewMail5");
		makeReady("NewMail4");

        return Super.init();
    }

    override bool tick() {
        if((ticks + 8) % 15 == 0) {
			// Check for new mail
			let entry = PDAEntry(Inv("PDAEntry"));
			hasUnreadMail = entry ? entry.hasUnreadMail : 0;

			let tierItem = InvasionTierSystem.Instance().getInvasionTierItem();
			hasNewInvasionTiers = tierItem && tierItem.hasNewTiers;

            if(hasUnreadMail || hasNewInvasionTiers) {
                calcKeybinds();
            }
        }

        
        if(owner.hasGasMask > 0) {
            baseline = -(240.0 / owner.hudScale);
            lOffset = owner.screenPadding.left + 5;
        } else {
            baseline = -(owner.screenPadding.bottom + 105.0);   // TODO: Store baseline in OWNER
            lOffset = owner.screenPadding.left + 40;
        }

        return Super.tick();
    }

    void calcKeybinds() {
		if(!firstDatapadPickup)	return;	// We don't show the codex keybind except the first time

		array<int> keys;
        let ih = InputHandler.Instance();
		Bindings.GetAllKeysForCommand(keys, "codex");
		
		string txt;
		bool isGamepadOnly;
		[txt, isGamepadOnly] = UIHelper.NamesForKeysColor(keys, colorCode: "f", usingGamepad: ih ? ih.isUsingGamepad : false);
		codexKeybind = isGamepadOnly ? txt : ("\cf[\c-" .. txt .. "\cf]");
		firstDatapadPickup = Stats.GetTrackerValue(STAT_DATAPADS_FOUND) <= 1;
	}

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(!makeTexReady(hasUnreadMail ? unreadImage : tiersImage)) return;
		
		// Draw mail indicator
		if(hasUnreadMail > 0 || hasNewInvasionTiers) {
            let pos = (lOffset - (firstDatapadPickup ? 10 : 0), baseline + 23) + ((shake + momentum) * 0.8);
			DrawTexAdvanced(hasUnreadMail ? unreadImage : tiersImage,
				pos,
				//col,
				DR_SCREEN_BOTTOM,
				0.8,
                color: owner.hasGasMask > 0 ? 0xFF00D786 : 0xFFFFFFFF
			);

			if(hasUnreadMail) {
				let urm = hasUnreadMail > 9 ? "9+" : "" .. hasUnreadMail;
				DrawStr('SEL14FONT', urm, pos + (30, 17), DR_SCREEN_BOTTOM | DR_TEXT_HCENTER | DR_TEXT_BOTTOM, Font.CR_WHITE, 0.9, scale: (0.87, 0.9));
			}

			// Only draw the keybind on the first datapad pickup
			if(firstDatapadPickup && !(owner && owner.hasGasMask > 0)) {
				let st = sin((MSTime() - owner.pulseStart) * 0.25);

				DrawStr('SEL21FONT', 
					codexKeybind, 
					pos + (17, 48 + 25),
					DR_SCREEN_BOTTOM | DR_TEXT_HCENTER, 
					Font.CR_UNTRANSLATED, 
					0.9,// - textPulse,
					monoSpace: false,
					scale: (0.85, 0.88)// * 0.6
				);

				DrawImgAdvanced("NEWMAIL5",
					pos + (17, 48 + 10 - (MAX(0.0, st * 5.0))),
					DR_SCREEN_BOTTOM | DR_IMG_HCENTER,
					0.9
				);
			} else {
				DrawImg("NEWMAIL4",
					pos + (5, 52),
					DR_SCREEN_BOTTOM,
					1.0 - (owner.globalPulse * 0.5)
				);
			}
		}
    }
}