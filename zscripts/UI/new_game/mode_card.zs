class ModeCard : UIButton {
    int mode;           // Which shop item we are buying

    UILabel headerLabel, descriptionLabel;
    UIImage upperStripe[3];
    //UIImage lowerStripe[3];
    UIImage selectFrame;
    UIImage glowImage, glowImage2;

    double glowAlpha;
    double lastRenderTime;
    double darken;

    bool hasTicked;

    static const Color modeColors[] = {
        0xFF28FF88,
        0xFFFF2849,
        0xFF8428FF
    };

    ModeCard init(int mode, string header, string description, double offsetX) {
        let targetSize = (342, 534);
        self.mode = mode;

        let bg = UIButtonState.Create(String.Format("MODMEN%d", mode));

        Super.init(
            (0,0), targetSize, "", null,
            bg,
            hover: UIButtonState.Create(String.Format("MODMEN%dA", mode), sound: "ui/playstyle/hover"),
            pressed: UIButtonState.Create(String.Format("MODMEN%dB", mode)),
            disabled: bg,
            selected: bg,
            selectedHover: UIButtonState.Create(String.Format("MODMEN%dA", mode), sound: "ui/playstyle/hover"),
            selectedPressed: UIButtonState.Create(String.Format("MODMEN%dA", mode))
        );

        //rejectHoverSelection = true;
        clipsSubviews = false;

        Color stripeColor = modeColors[mode];

        // Note: glowImage has special handling during draw and layout
        glowImage = new("UIImage").init((0,0), (420, 614), "MODMEN3");
        glowImage.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        glowImage.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        glowImage.blendColor = stripeColor;
        glowImage.alpha = 0;
        add(glowImage);

        glowImage2 = new("UIImage").init((0,0), (1, 1), "MODMEN5");
        glowImage2.pinToParent();
        glowImage2.blendColor = stripeColor;
        glowImage2.alpha = 0;
        add(glowImage2);

        selectFrame = new("UIImage").init((0,0), (430, 573), "",
            slices: NineSlice.Create("MODMEN4", (34, 27), (40, 35), drawCenter: false)
        );
        selectFrame.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        selectFrame.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        selectFrame.alpha = 0;
        add(selectFrame);

        headerLabel = new("UILabel").init((38, 160), (targetSize.x - 38, 100), header, "K32FONT", textAlign: Align_TopLeft, fontScale: (0.72, 1));
        add(headerLabel);

        descriptionLabel = new("UILabel").init((38, 280), (targetSize.x - 38 - 38, 100), description, "K22FONT", textAlign: Align_TopLeft, fontScale: (0.87, 1) * 0.65);
        add(descriptionLabel);

        // Upper Stripe
        upperStripe[0] = new("UIImage").init((20, 75), (165, 37), "",
            slices: NineSlice.Create("MODMENU1", (15, 18), (123, 18), drawCenter: false)
        );
        upperStripe[0].blendColor = stripeColor;
        add(upperStripe[0]);

        upperStripe[1] = new("UIImage").init((160, 75), (49, 37), "MODMENU2");
        upperStripe[1].blendColor = stripeColor;
        add(upperStripe[1]);

        upperStripe[2] = new("UIImage").init((187, 75), (49, 37), "MODMENU2");
        upperStripe[2].blendColor = stripeColor;
        add(upperStripe[2]);

        // Lower Stripe
        /*lowerStripe[0] = new("UIImage").init((87, 488), (239, 21), "",
            slices: NineSlice.Create("MODMENL1", (25, 10), (232, 10), drawCenter: false)
        );
        lowerStripe[0].pin(UIPin.Pin_Left, offset: 87);
        lowerStripe[0].pin(UIPin.Pin_Right, offset: -16);
        lowerStripe[0].blendColor = stripeColor;
        add(lowerStripe[0]);

        lowerStripe[1] = new("UIImage").init((35, 488), (33, 21), "MODMENL2");
        lowerStripe[1].blendColor = stripeColor;
        add(lowerStripe[1]);

        lowerStripe[2] = new("UIImage").init((61, 488), (33, 21), "MODMENL2");
        lowerStripe[2].blendColor = stripeColor;
        add(lowerStripe[2]);*/

        pin(UIPin.Pin_VCenter, value: 1.0, offset: -40, isFactor: true);
        pin(UIPin.Pin_HCenter, value: offsetX, offset: 0, isFactor: true);

        return self;
    }

    override void tick() {
        Super.tick();
        hasTicked = true;
    }

    override void onSelected(bool mouseSelection) {
        Super.onSelected(mouseSelection);

        if(disabled) {
            return;
        }
        
        let animator = getAnimator();
        
        for(int x =0; x < 3; x++) {
            animator.clear(upperStripe[x]);
            //animator.clear(lowerStripe[x]);
        }

        // Animate
        upperStripe[0].animateFrame(0.1, toSize: (165, 37), ease: Ease_Out);
        upperStripe[1].animateFrame(0.1, toPos: (160, 75), ease: Ease_Out );
        upperStripe[2].animateFrame(0.1, toPos: (187, 75), ease: Ease_Out);

        //lowerStripe[0].animateFrame(0.1, toSize: (239, 21), ease: Ease_Out);
        /*lowerStripe[1].animateFrame(0.1, toPos: (35, 488), ease: Ease_Out);
        lowerStripe[2].animateFrame(0.1, toPos: (61, 488), ease: Ease_Out);

        let a = new("UIViewPinAnimation").initComponents(lowerStripe[0], 0.1, ease: Ease_Out);
        a.addValues(UIPin.Pin_Left, endOffset: 87);
        animator.add(a);*/
    }

    override void onDeselected() {
        Super.onDeselected();

        let animator = getAnimator();

        for(int x =0; x < 3; x++) {
            animator.clear(upperStripe[x]);
            //animator.clear(lowerStripe[x]);
        }

        // Animate
        upperStripe[0].animateFrame(0.1, toSize: (134, 37), ease: Ease_In);
        upperStripe[1].animateFrame(0.1, toPos: (121, 75), ease: Ease_In );
        upperStripe[2].animateFrame(0.1, toPos: (138, 75), ease: Ease_In);

        //lowerStripe[0].animateFrame(0.1, toSize: (176, 21), ease: Ease_In);
        /*lowerStripe[1].animateFrame(0.1, toPos: (117, 488), ease: Ease_In);
        lowerStripe[2].animateFrame(0.1, toPos: (134, 488), ease: Ease_In);

        let a = new("UIViewPinAnimation").initComponents(lowerStripe[0], 0.1, ease: Ease_In);
        a.addValues(UIPin.Pin_Left, endOffset: 150);
        animator.add(a);*/
    }

    void animateSelect() {
        let animator = getAnimator();
        if(animator) animator.clear(selectFrame);

        let ab = selectFrame.animateFrame(0.15, 
            toSize: (385, 573),
            toAlpha: 1.0,
            ease: Ease_Out
        );
        ab.layoutEveryFrame = true;
    }

    void selectWithoutAnimation() {
        let animator = getAnimator();
        if(animator) animator.clear(selectFrame);
        selectFrame.setAlpha(1.0);
        selectFrame.frame.size = (385, 573);
        selectFrame.requiresLayout = true;
    }

    void animateDeselect() {
        let animator = getAnimator();
        animator.clear(selectFrame);

        let ab = selectFrame.animateFrame(0.15,
            toSize: (430, 573),
            toAlpha: 0,
            ease: Ease_In
        );
        ab.layoutEveryFrame = true;
    }

    override void transitionToState(int idx, bool sound) {
        let oldState = currentState;

        Super.transitionToState(idx, sound);

        if(oldState != currentState) {
            if(isSelected(oldState) && !isSelected(currentState)) {
                animateDeselect();
            } else if(isSelected(currentState) && !isSelected(oldState)) {
                if(hasTicked) animateSelect();
                else selectWithoutAnimation();
            }
        }
    }

    override void onMouseExit(Vector2 screenPos, UIView newView) {
        Super.onMouseExit(screenPos, newView);

        // Remove navigation
        let m = getMenu();
        if(m && m.activeControl == self) {
            m.clearNavigation();
        }
    }

    override void draw() {
        if(hidden) { return; }
        
        let rt = getMenu().getRenderTime();
        let te = lastRenderTime == 0 ? 0 : rt - lastRenderTime;
        lastRenderTime = rt;

        Screen.ClearClipRect();
        glowAlpha = CLAMP(glowAlpha + (activeSelection ? te * 6.0 : -te * 6.0), 0.0, 1.0);

        let ga = UIMath.EaseOutCubicf(glowAlpha);
        let sinrt = SIN(rt * 100);
        
        glowImage.setAlpha(ga * (0.7 - (sinrt * 0.3)));
        glowImage2.setAlpha(ga * (0.5 - (sinrt * 0.5)));

        // Determine darkness based on state
        darken = CLAMP(darken + (activeSelection || isSelected() ? -te * 8.0 : te * 8.0), 0.0, 1.0);
        if(isDisabled()) {
            darken = 1.15;
        }

        Color dCol = Color(uint(darken * 0.5 * 255.0), 0, 0, 0);

        desaturation = darken * 0.5;
        blendColor = dCol;

        headerLabel.desaturation = desaturation;
        headerLabel.blendColor = dCol;
        descriptionLabel.desaturation = desaturation;
        descriptionLabel.blendColor = Color(uint(50 + (darken * 0.5 * 255.0)), 0, 0, 0);

        if(isDisabled()) {
            desaturation = 0.6;
        }

        Color mCol = modeColors[mode];
        mCol = UIMath.darken( UIMath.desaturate(mCol, desaturation), desaturation );

        for(int x = 0; x < 3 ; x++) {
            upperStripe[x].desaturation = desaturation;
            upperStripe[x].blendColor = mCol;      // Have to manually desaturate and darken the color
            //lowerStripe[x].desaturation = desaturation;
            //lowerStripe[x].blendColor = mCol;      // Have to manually desaturate and darken the color
        }

        // Draw background glow manually before the main view
        glowImage.draw();

        Super.draw();
    }

    // Don't draw the glowimage in here
    override void drawSubviews() {
        if(hidden) { return; }

        for(int x = 0; x < subviews.size(); x++) {
            if(subviews[x] != glowImage) {
                subviews[x].draw();
                subviews[x].drawSubviews();
            }
        }
    }
}