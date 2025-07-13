class SharewareMenu : UIMenu {
    UIImage thankyouGraphic;

    override void init(Menu parent) {
		Super.init(parent);
        animated = true;
        AnimatedTransition = false;

        let isWidescreen = double(Screen.GetWidth()) / double(Screen.GetHeight()) > 1.4;
        let swImage = isWidescreen ? "SHAREWAR" : "SHARWA43";
        thankyouGraphic = new("UIImage").init((0,0), (10,10), swImage, imgStyle: UIImage.Image_Aspect_Fit);
        thankyouGraphic.pinToParent();
        mainView.add(thankyouGraphic);
        thankyouGraphic.hidden = true;
        thankyouGraphic.backgroundColor = 0xFF000000;
    }

    override void onFirstTick() {
        hideCursor();
    }

    override void ticker() {
        Super.ticker();

        if(ticks == 2) {
            thankyouGraphic.hidden = false;
            thankyouGraphic.animateFrame(
                0.25,
                fromAlpha: 0.001,
                toAlpha: 1,
                ease: Ease_In
            );
        }
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_BACK) { return true; }
        
        if(ticks > 35) {
            Level.QuitGame();
            return true;
        }

		return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool onUIEvent(UIEvent ev) {
        // If we have continued and a button was pressed
        if((ev.type < UIEvent.Type_FirstMouseEvent || ev.Type == UIEvent.Type_LButtonDown) && ticks > 35) {
            Level.QuitGame();
            return true;
        }

		return Super.onUIEvent(ev);
	}
}