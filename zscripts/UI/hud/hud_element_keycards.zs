
class HUDKeycards : HUDElementStartup {
    TextureID purpleCardImage, blueCardImage, yellowCardImage, goldKeyImage, gasmaskImage;
    int purpleKeyStart, blueKeyStart, yellowKeyStart, goldKeyStart, gasStart;
    double baseline, lOffset;

    enum KeycardIndex {
		PurpleKeycard = 0,
		BlueKeycard,
		YellowKeycard,
		GoldKey,
		GasMaskKey
	}
    
    override HUDElement init() {
        purpleCardImage = TexMan.checkForTexture("KEYPURP");
        blueCardImage = TexMan.checkForTexture("KEYBLUE");
        yellowCardImage = TexMan.checkForTexture("KEYYELLO");
		goldKeyImage = TexMan.checkForTexture("KEYGOLD");
		gasmaskImage = TexMan.checkForTexture("KEYGAS");

		makeTexReady(purpleCardImage);
        makeTexReady(blueCardImage);
		makeTexReady(yellowCardImage);
		makeTexReady(goldKeyImage);
		makeTexReady(gasmaskImage);

        return Super.init();
    }

    override bool tick() {
        // Check for keycards every 5 ticks
		if((ticks + 3) % 5 == 0) {
			let ipurple = Inv("OMNI_PURPLECARD");
			let iblue = Inv("OMNI_BLUECARD");
			let iyellow = Inv("OMNI_YELLOWCARD");
			let igold = Inv("GoldenKey");
			let igasmask = Inv("HasGasmask");

			if(purpleKeyStart <= 0 && ipurple) {
				purpleKeyStart = ticks;
			} else if(purpleKeyStart > 0 && !ipurple) {
				purpleKeyStart = -ticks;
			}

			if(blueKeyStart <= 0 && iblue) {
				blueKeyStart = ticks;
			} else if(blueKeyStart > 0 && !iblue) {
				blueKeyStart = -ticks;
			}

			if(yellowKeyStart <= 0 && iyellow) {
				yellowKeyStart = ticks;
			} else if(yellowKeyStart > 0 && !iyellow) {
				yellowKeyStart = -ticks;
			}

			if(goldKeyStart <= 0 && igold) {
				goldKeyStart = ticks;
			} else if(goldKeyStart > 0 && !igold) {
				goldKeyStart = -ticks;
			}

			if(gasStart <= 0 && igasmask) {
				gasStart = ticks;
			} else if(gasStart > 0 && !igasmask) {
				gasStart = -ticks;
			}
		}

        if(owner.hasGasMask > 0) {
            baseline = -(340.0 / owner.hudScale);
            lOffset = -owner.screenPadding.right - 5 + 99;
        } else {
            baseline = -(owner.screenPadding.bottom + 145.0);
            lOffset = -owner.screenPadding.right - 85 + 99;
        }

        return Super.tick();
    }

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        Vector2 offset = (shake + momentum) * 0.65;
        drawCard(purpleCardImage,   fracTic, (lOffset, baseline - 18) + offset, purpleKeyStart, alpha);
        drawCard(blueCardImage,     fracTic, (lOffset, baseline - 52) + offset, blueKeyStart,   alpha);
        drawCard(yellowCardImage,   fracTic, (lOffset, baseline - 87) + offset, yellowKeyStart, alpha);
		drawCard(goldKeyImage,   	fracTic, (lOffset, baseline - 122) + offset, goldKeyStart, 	alpha);
		drawCard(gasmaskImage,   	fracTic, (lOffset, baseline - 122) + offset, gasStart, 		alpha);	// Gasmask and Gold Key occupy the same spot on purpose
    }

    private void drawCard(TextureID tex, double tm, Vector2 pos, int timeStart, double alpha) {
        if(timeStart > 0) {
			float ute = ticks - timeStart + tm;
			float a = ute > 6 ? 1 : ute / 6.0;
			float x = (ute > 6 ? 0 : UIMath.EaseInCubicF(1.0 - a) * 100);

			DrawTexAdvanced(tex, (pos.x + x, pos.y), DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_IMG_RIGHT, a * alpha);
		} else if(timeStart < 0 && ticks + timeStart < 6.0) {
			float ute = ticks + timeStart + tm;
			float a = 1.0 - (ute / 6.0);
			float x = (UIMath.EaseInCubicF(1.0 - a) * 100);

			DrawTexAdvanced(tex, (pos.x + x, pos.y), DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_IMG_RIGHT, a * alpha);
		}
    }
}