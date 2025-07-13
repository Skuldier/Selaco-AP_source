class ModeStartButton : UIButton {
    UIImage trail[3];
    double lastRenderTime, sinTime;
    double trailAlpha;
    double trailTransition;

    double sindelay;

    ModeStartButton init(string txt) {
        let targetSize = (308, 100);

        Super.init(
            (0,0), targetSize, txt, "K22FONT",
            UIButtonState.Create("MODEBTN1"),
            hover: UIButtonState.Create("MODEBTN3"/*, sound: "menu/cursor"*/),
            pressed: UIButtonState.Create("MODEBTN3")
        );

        label.fontScale = (0.9, 1);
        
        clipsSubviews = false;

        // Add trails
        for(int x =0; x < 3; x++) {
            trail[x] = new("UIImage").init(((-25 * x) - 18, 0), (63, 100), "MODEBTN2");
            add(trail[x]);
        }

        trailAlpha = 0.5;
        sindelay = 60;

        return self;
    }

    override void draw() {
        let time = getMenu().getRenderTime();
        let te = lastRenderTime != 0 ? time - lastRenderTime : 0;
        lastRenderTime = time;

        if(currentState == State_Hover) {
            // Increase overall alpha
            trailAlpha = MIN(1, trailAlpha + (te * 2));
            trailTransition = MIN(1, trailTransition + (te * 3.5));
        } else {
            // Reduce overall alpha
            trailAlpha = MAX(0.85, trailAlpha - (te * 0.5));
            trailTransition = MAX(0, trailTransition - (te * 1.2));
        }

        sinTime += te * 350;

        // Cycle alphas for trails
        for(int x = 0; x < 3; x++) {
            let da = 0.8 - (x * 0.25);  // Passive alpha
            //let ba = (0.4 + (SIN( sinTime + (x * sindelay) ) + 1)) * 0.5 * 0.6;
            let ba = 0.2 + (MAX(0, SIN( sinTime + (x * sindelay) )) * 0.8) ;
            trail[x].setAlpha( UIMath.Lerpd(da, ba, trailTransition) );
        }

        setAlpha(trailAlpha);

        Super.draw();   
    }

    override void transitionToState(int idx, bool sound) {
        //let oldState = currentState;

        Super.transitionToState(idx, sound);
        
        // State transition can happen before setup
        if(!trail[0]) return;

        switch(idx) {
            case State_Hover:
                for(int x =0; x < 3; x++) {
                    trail[x].setImage("MODEBTN4");
                }
                break;
            case State_Normal:
            case State_Disabled:
                for(int x =0; x < 3; x++) {
                    trail[x].setImage("MODEBTN2");
                }
                break;
            default:
                break;
        }
    }
}