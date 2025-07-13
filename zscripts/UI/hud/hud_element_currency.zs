class HUDElementCurrency : HUDElementStartup {
    int deltaCreditsCount, deltaPartsCount;
    int creditsCount, credits, partsCount, parts;
    int showTime;

    int bigMoney, bigParts;
    bool alwaysShow;
    LookAt look;

    TextureID partIcon, moneyIcon;

    const BIGMONEYTICKS = 10;		// Time to en-biggen resources after they are picked up
	const BIGMONEYSCALE = 0.5;		// Max 'enbiggening' (+1)
    const SHOWING_TICKS = 100;
    const FADING_TICKS = 75;

    override HUDElement init() {
        alwaysShow = iGetCVar("g_always_show_currency") > 0;
        look = LookAt.Instance();

        return Super.init();
    }

    override bool tick() {
        // Process big money! $$$$$$$$$ DING DING DING $$$$$$$$$
		bigMoney = MAX(bigMoney - 1, 0);
		bigParts = MAX(bigParts - 1, 0);
		
        if(level.totalTime % 75 == 0) {
            alwaysShow = iGetCVar("g_always_show_currency") > 0;
        }

        // Move towards real values for credits and parts
		deltaCreditsCount = creditsCount;
		deltaPartsCount = partsCount;
		creditsCount = InvCount("creditscount");
		partsCount = InvCount("weaponparts");
		int cc = ceil((creditsCount - credits) / 3);
		int pp = ceil((partsCount - parts) / 3);
		credits = cc == 0 ? creditsCount : credits + cc;
		parts = pp == 0 ? partsCount : parts + pp;

		// Create big money if necessary
		if(deltaCreditsCount < creditsCount) {
            bigMoney = BIGMONEYTICKS;
            showTime = level.totalTime;
        }
		if(deltaPartsCount < partsCount) { 
            bigParts = BIGMONEYTICKS;
            showTime = level.totalTime;
        }

        // Determine show/hide time
        if(alwaysShow || (look && look.isLookingAtPurchase)) {
            showTime = level.totalTime;
        }

        return Super.tick();
    }

    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);
        credits = player ? InvCount("creditscount") : 0;
		parts = player ? InvCount("weaponparts") : 0;
        if(!look) look = LookAt.Instance();
        
        partIcon = TexMan.CheckForTexture("HPART");
        moneyIcon = TexMan.CheckForTexture("HMON");
        makeTexReady(partIcon);
		makeTexReady(moneyIcon);
    }

    const textOpacity = 0.8;
    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        //bool hideCredits = Screen.GetWidth() / owner.hudScale < 1475;
        
        if(owner.hasGasMask <= 0 && showTime > 0 && level.totalTime - showTime <= SHOWING_TICKS + FADING_TICKS) {
            double showAlpha = 1.0;
            if(level.totalTime - showTime >= SHOWING_TICKS) {
                showAlpha = 1.0 - UIMath.EaseInCubicF((double(level.totalTime - SHOWING_TICKS - 1 - showTime) - fracTic) / double(FADING_TICKS));
            }
			double atm = 1.0 - fracTic;
            Vector2 shtm = (
                clamp(momentum.x * 1.05, momentum.x - 2.0, momentum.x + 2.0), 
                clamp(momentum.y * 1.05, momentum.y - 2.0, momentum.y + 2.0)
            );
            shtm = shtm + shake;
            Vector2 shfm = momentum + shake;
            
            // Draw weapon parts
			if(parts > 0) {
                DrawTex(partIcon, (60, 85) + shfm, DR_SCREEN_HCENTER,  a: showAlpha);
				float sc = bigParts > 0 ? 1.0 + (((bigParts + atm) / BIGMONEYTICKS) * BIGMONEYSCALE) : 1.0;
				float soff = (owner.numFontHeight - (owner.numFontHeight * sc)) / 2.0;
				DrawStr(owner.numFont, "" .. parts, (60 + 121, 93 + soff) + shtm, DR_SCREEN_HCENTER|DR_TEXT_RIGHT, Font.CR_WHITE, textOpacity * showAlpha, scale: (sc, sc));
			}

			// Draw credits
			if(credits > 0) {
                float sc = bigMoney > 0 ? 1.0 + (((bigMoney + atm) / BIGMONEYTICKS) * BIGMONEYSCALE) : 1.0;
				float soff = (owner.numFontHeight - (owner.numFontHeight * sc)) / 2.0;

                if(parts <= 0 && !alwaysShow) {
                    DrawTex(moneyIcon, (-60, 85) + shfm, DR_SCREEN_HCENTER, a: showAlpha);
				    DrawStr(owner.numFont, "" .. credits, (-60 + 40, 93 + soff) + shtm, DR_SCREEN_HCENTER, Font.CR_WHITE, textOpacity * showAlpha, scale: (sc, sc));
                } else {
                    DrawTex(moneyIcon, (-163 - 60, 85) + shfm, DR_SCREEN_HCENTER, a: showAlpha);
				    DrawStr(owner.numFont, "" .. credits, (-163 - 60 + 40, 93 + soff) + shtm, DR_SCREEN_HCENTER, Font.CR_WHITE, textOpacity * showAlpha, scale: (sc, sc));
                }
				
			}
		}
    }
}