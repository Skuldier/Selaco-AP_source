class ComingMenu : SelacoGamepadMenu {
    StandardBackgroundContainer background;
    UILabel titleLabel, titleLabel2;
    SoonCard cards[2];
    UIImage checkmark1;

    double dimStart;
    bool closing;

    const GLOBAL_CARD_SCALE = 0.9;
    const GLOBAL_CARD_SPACE = 5;

    override void init(Menu parent) {
		Super.init(parent);
       
        DontBlur = level.MapName == "TITLEMAP";
        dimStart = MSTime() / 1000.0;

        background = CommonUI.makeStandardBackgroundContainer();
        background.firstPin(UIPin.Pin_Top).offset = 180;
        mainView.add(background);

        titleLabel = new("UILabel").init((0,0), (0,0), StringTable.Localize("$TITLE_COMING_SOON"), 'SEL52FONT', textAlign: UIView.Align_Center);
        titleLabel.pin(UIPin.Pin_Right);
        titleLabel.pin(UIPin.Pin_Left);
        titleLabel.pin(UIPin.Pin_Bottom);
        titleLabel.pinHeight(UIView.Size_Min);
        //titleLabel.backgroundColor = 0xFF00FF00;
        background.headerLayout.add(titleLabel);

        titleLabel2 = new("UILabel").init((0,0), (0,0), StringTable.Localize("$TITLE_IN_DEVELOPMENT"), 'PDA35OFONT', textAlign: UIView.Align_Center, fontScale: (0.7, 0.7));
        titleLabel2.pin(UIPin.Pin_Right, offset: -100);
        titleLabel2.pin(UIPin.Pin_Left, offset: 100);
        titleLabel2.pin(UIPin.Pin_Top);
        titleLabel2.pinHeight(UIView.Size_Min);
        //titleLabel2.backgroundColor = 0xFFFF0000;
        titleLabel2.multiline = false;
        titleLabel2.autoScale = true;
        background.add(titleLabel2);

        double cardSize = 500, cardSizeY = 750;
        double cardScale = 1.0;

        {
            cardSizeY = mainView.frame.size.y - 90 - 60 - background.firstPin(UIPin.Pin_Top).offset;
            cardScale = cardSizeY / 750.0;
            cardSize = 500.0 * cardScale;
        }

        if(cardSize * cards.size() + 50 > mainView.frame.size.x) {
            cardSize = (mainView.frame.size.x - 50 - 80) / double(cards.size());
            cardScale = cardSize / 500.0;
        }

        cardScale *= GLOBAL_CARD_SCALE;   // I'm fuckin cheeeeeeating

        double startx = ((cards.size() * (cardSize + GLOBAL_CARD_SPACE)) * 0.5) - (cardsize * 0.5);
        for(int x = 0; x < cards.size(); x++) {
            cards[x] = new("SoonCard").init(StringTable.Localize(String.Format("$COOL_THING_%d", x + 1)), StringTable.Localize(String.Format("$COOL_THING_DESC_%d", x + 1)), String.Format("CLTHING%d", x + 1));
            cards[x].pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1.0, offset: -startx + (x * (cardSize + GLOBAL_CARD_SPACE)), isFactor: true);
            cards[x].pin(UIPin.Pin_VCenter, value: 1.0, offset: -15, isFactor: true);
            cards[x].alpha = 0;
            cards[x].scale = (cardScale, cardScale);
            background.add(cards[x]);
        }

        // If there is a joystick connected, add the gamepad footer
        if(JoystickConfig.NumJoysticks()) {
            background.addGamepadFooter(InputEvent.Key_Pad_B, "Back");
        }
    }

    override void layoutChange(int screenWidth, int screenHeight) {
        calcScale(screenWidth, screenHeight);

        double cardSize = 500, cardSizeY = 750;
        double cardScale = 1.0;

        {
            cardSizeY = mainView.frame.size.y - 90 - 60 - background.firstPin(UIPin.Pin_Top).offset;
            cardScale = cardSizeY / 750.0;
            cardSize = 500.0 * cardScale;
        }

        if(cardSize * cards.size() + 50 > mainView.frame.size.x) {
            cardSize = (mainView.frame.size.x - 50 - 80) / double(cards.size());
            cardScale = cardSize / 500.0;
        }

        cardScale *= GLOBAL_CARD_SCALE;   // I'm fuckin cheeeeeeating

        double startx = ((cards.size() * (cardSize + GLOBAL_CARD_SPACE)) * 0.5) - (cardsize * 0.5);
        for(int x = 0; x < cards.size(); x++) {
            if(cards[x]) {
                cards[x].clearPins();
                cards[x].pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1.0, offset: -startx + (x * (cardSize + GLOBAL_CARD_SPACE)), isFactor: true);
                cards[x].pin(UIPin.Pin_VCenter, value: 1.0, offset: -5, isFactor: true);
                cards[x].requiresLayout = true;
                cards[x].scale = (cardScale, cardScale);
            }
        }

        mainView.layout();
    }


    override void onFirstTick() {
        Super.onFirstTick();

        // Need to layout the entire view chain before we can animate
        mainView.layout();

        // animate everything in
        for(int x = 0; x < cards.size(); x++) {
            let anim = cards[x].animateFrame(
                0.18,
                fromPos: cards[x].frame.pos + (0, 40),
                toPos: cards[x].frame.pos,
                fromAlpha: 0,
                toAlpha: 1.0,
                ease: Ease_Out
            );
            
            double delay = x * 0.015;
            anim.startTime += delay;
            anim.endTime += delay;
        }

        // Create checkmark animation

    }


    override void drawer() {
        double time = MSTime() / 1000.0;
        if(time - dimStart > 0 && !closing) {
            Screen.dim(0xFF020202, MIN((time - dimStart) / 0.15, 1.0) * 0.75, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            BlurAmount =  MIN((time - dimStart) / 0.1, 1.0);
        } else if(closing) {
            Screen.dim(0xFF020202, (1.0 - MIN((time - dimStart) / 0.2, 1.0)) * 0.75, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            BlurAmount = 1.0 - MIN((time - dimStart) / 0.18, 1.0);
        }
        
        Super.drawer();
    }

    override void ticker() {
        if(closing && animator && !animator.isAnimating()) {
            Close();
        }

        Super.ticker();
    }

    override bool onBack() {
		if(!closing) {
            MenuSound("menu/backup");
            double time = MSTime() / 1000.0;
            dimStart = time;

            // animate everything out
            for(int x = cards.size() - 1; x >= 0; x--) {
                let anim = cards[x].animateFrame(
                    0.2,
                    fromPos: cards[x].frame.pos,
                    toPos: cards[x].frame.pos + (0, 40),
                    toAlpha: 0.0,
                    ease: Ease_In
                );
                
                double delay = (2 - x) * 0.025;
                anim.startTime += delay;
                anim.endTime += delay;
            }

            titleLabel.animateFrame(
                0.35,
                toAlpha: 0.0,
                ease: Ease_In
            );

            titleLabel2.animateFrame(
                0.34,
                toAlpha: 0.0,
                ease: Ease_In
            );
        }

        closing = true;
		return true;
	}
}


class SoonCard : UIView {
    UILabel title1, title2;
    UIImage image;

    SoonCard init(string title, string text, string img) {
        Super.init((0,0), (500,750));

        image = new("UIImage").init((0,0), (0,0), img == "" ? "DWNMOM" : img, imgStyle: UIImage.Image_Aspect_Fill);
        image.pinToParent(8.5, 8.5, -8.5, -8.5);
        add(image);

        let vignImage = new("UIImage").init((0,0), (0,0), "COOLVIGN");
        vignImage.pinToParent(8.5, 250, -8.5, -8.5);
        add(vignImage);

        let bgImage = new("UIImage").init((0,0), (0,0), "", NineSlice.Create("COMNGBG1", (16, 16), (45, 45)));
        bgImage.pinToParent(-1, -1, 1, 1);
        add(bgImage);

        title1 = new("UILabel").init((0,0), (0,0), title, 'SEL46FONT', textAlign: UIView.Align_Center | UIView.Align_Bottom);
        title1.pin(UIPin.Pin_Right, offset: -35);
        title1.pin(UIPin.Pin_Left, offset: 35);
        title1.pin(UIPin.Pin_Bottom, UIPin.Pin_Bottom, offset: -210);
        title1.pinHeight(UIView.Size_Min);
        title1.autoScale = true;
        title1.multiline = false;
        add(title1);

        title2 = new("UILabel").init((0,0), (0,0), text, 'PDA35OFONT', textAlign: UIView.Align_Center, fontScale: (0.57, 0.57));
        title2.pin(UIPin.Pin_Right, offset: -30);
        title2.pin(UIPin.Pin_Left, offset: 30);
        title2.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: -190);
        title2.pinHeight(UIView.Size_Min);
        add(title2);

        

        return self;
    }
}