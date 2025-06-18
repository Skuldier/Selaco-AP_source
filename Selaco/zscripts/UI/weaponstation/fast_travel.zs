class FastTravelView : WorkshopView {
    UIViewAnimation lastAnimation;  // last finishing animation in the current animation, controls status
    WVAnimation curAnimType;

    UIImage mapImage;

    FastTravelView init() {
        Super.init((0,0), (100, 100));
        pinToParent();

        clipsSubviews = false;

        mapImage = new("UIImage").init((0,0), (100, 100), "graphics/upgrade_menu/tempmap.png", imgStyle: UIImage.Image_Center);
        mapImage.pinToParent(140);
        mapImage.alpha = 0;
        add(mapImage);


        return self;
    }

    override bool hasCompletedAnimation(WVAnimation anim) {
        if(lastAnimation && lastAnimation.checkValid(lastAnimation.getTime())) {
            return false;
        }
        return true;
    }

    override double animate(WVAnimation anim, double delay) {
        let animator = getAnimator();
        if(!animator) {
            return 0;
        }
        animator.clear(mapImage);

        switch(anim) {
            case Anim_In: {
                let anim = mapImage.animateFrame(
                    0.3,
                    fromAlpha: 0,
                    toAlpha: 1,
                    ease: Ease_Out
                );
                anim.startTime += delay + 0.1;
                anim.endTime += delay + 0.1;

                let anim2 = mapImage.animateImage(
                    0.3,
                    fromScale: (1.3, 1.3),
                    toScale: (1.0, 1.0),
                    ease: Ease_Out
                );
                anim2.startTime += delay + 0.1;
                anim2.endTime += delay + 0.1;
                lastAnimation = anim2;

                return 0.3;
            }
            case Anim_Out: {
                let anim = mapImage.animateFrame(
                    0.18,
                    toAlpha: 0,
                    ease: Ease_In
                );
                anim.startTime += delay;
                anim.endTime += delay;

                let anim2 = mapImage.animateImage(
                    0.18,
                    toScale: (0.9, 0.9),
                    ease: Ease_In
                );
                anim2.startTime += delay;
                anim2.endTime += delay;
                lastAnimation = anim;

                return 0.25;
            }
            default:
                lastAnimation = null;
                break;
        }

        return 0;
    }
}