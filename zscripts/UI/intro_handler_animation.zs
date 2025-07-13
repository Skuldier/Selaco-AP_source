class BGFog {
    double life;
    UITexture img;
    Vector2 bSize;
}

class BGEmber {
    double life, startX, startY, freq, wiggleSeed;
}

class BGImpact {
    double life, speed, freq, scale;
    Vector2 startPos, dir;
}


extend class IntroHandler {
    ui Array<BGImpact> impacts;
    ui Array<BGFog> fogs;
    ui Array<BGFog> smokes;
    ui Array<BGEmber> embers;

    const IMPACT_TIME = 4.0;
    const SMOKE_ALPHA = 0.72;

    ui void drawImpactsAndSmoke(double time, double te, double fadeAlpha) {
        if(smokes.size() == 0) {
            // Create smokes
            for(int x = 0; x < 15; x++) {
                let fog = new("BGFog");
                fog.img = UITexture.Get("MODEFOG5");
                fog.bSize = (frandom(0, 1.3), frandom(0.0, 0.6));
                fog.life = x * fogFragTime;
                smokes.push(fog);
            }
        }
        
        for(int x = 0; x < smokes.size(); x++) {
            let fog = smokes[x];

            fog.life += te;

            let tm = fog.life / fogTime;
            if(tm > 1.0) {
                fog.life = fog.life - fogTime;
                fog.bSize = (frandom(0, 1.6), frandom(0.0, 0.62));
                tm = 0;
            }

            double alpha;
            if(tm * 2.0 > 1.0) {
                alpha = UIMath.EaseOutCubicf(1.0 - tm);
            } else {
                alpha = UIMath.EaseOutCubicf(tm);
            }
            alpha = alpha * SMOKE_ALPHA * fadeAlpha;

            Vector2 imgScale = ( (1,1) * (1.0 + (0.2 / (1.0 - tm))) ) + fog.bSize;

            // Draw the fog layer
            // Order doesn't really matter much, it's hard to see that the order is off
            double aspect = fog.img.size.x / fog.img.size.y;
            Vector2 size = screenSize.x > screenSize.y ? (screenSize.x * imgScale.x, (screenSize.x / aspect) * imgScale.y) : (screenSize.y * aspect * imgScale.x, screenSize.y * imgScale.y);
            Vector2 pos = (screenSize / 2.0) - (size / 2.0);
            // test
            pos.y = MIN(0.0, (screenSize.y / 2.0) - (size.y / 2.2));

            Screen.DrawTexture(
                fog.img.texID, 
                true,
                pos.x,
                pos.y,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Alpha, alpha,
                DTA_Filtering, true
            );
        }

        /*double mScale = MAX(screenSize.x / 1920.0, screenSize.y / 1080.0);
        Vector2 size = (10, 10) * mScale;

        // Make initial impacts
        if(impacts.size() == 0) {
            Vector2 origin = (1114.0 / 1920.0, 150.0 / 1080.0);
            
            for(int x = 0; x < 10; x++) {
                makeImpact(frandom(0, IMPACT_TIME), origin, 180.0 + frandom(-80, 80));
            }
        }


        for(int x = 0; x < impacts.size(); x++) {
            let imp = impacts[x];

            if(imp.life >= IMPACT_TIME) {
                makeImpact(frandom(0, IMPACT_TIME * 0.15), (1114.0 / 1920.0, 150.0 / 1080.0), 180.0 + frandom(-80, 80), imp);
            }

            double impTM = imp.life / IMPACT_TIME;
            double alpha = UIMath.EaseOutCubicf(1.0 - impTM);

            Vector2 pos = imp.startPos;
            pos += imp.speed * imp.life * imp.dir;
            pos = (pos.x * bgImage2.tex.size.x, pos.y * bgImage2.tex.size.y);
            pos = bgImage2.relToScreen(bgImage2.imageRelToLocal(pos));

            Screen.DrawTexture(
                TexMan.CheckForTexture("IMPEMBER"), 
                false,
                pos.x,
                pos.y,
                DTA_DestWidthF, size.x * imp.scale,
                DTA_DestHeightF, size.y * imp.scale,
                DTA_Alpha, alpha * 0.5,
                DTA_LegacyRenderStyle, STYLE_Add,
                DTA_Filtering, true
            );

            imp.life += te;

            // If we faded out, kill this particle for the next loop
            if(alpha < 0) imp.life = IMPACT_TIME;
        }*/
    }


    ui BGImpact makeImpact(double life, Vector2 startPos, double angle, BGImpact o = null) {
        if(!o) {
            o = new("BGImpact");
            impacts.push(o);
        }

        o.life = life;
        o.startPos = startPos;
        o.speed = frandom(0, 1) * 0.028;
        o.dir = Actor.AngleToVector(angle);
        o.scale = frandom(0.5, 1.25);

        return o;
    }


    ui void drawFog(double time, double te, double fogFadeAlpha) {
        double mScale = MAX(screenSize.x / 1920.0, screenSize.y / 1080.0);

        // Draw and update embers
        for(int x = 0; x < embers.size(); x++) {
            let mber = embers[x];

            if(mber.life >= emberTime) {
                makeEmber(mber.life - emberTime, mber);
            }

            double mberTM = mber.life / emberTime;
            double alpha = 1.0;

            if(mberTM * 2.0 > 1.0) {
                alpha = UIMath.EaseOutCubicf(1.0 - mberTM);
            } else {
                alpha = UIMath.EaseOutCubicf(mberTM);
            }

            alpha *= sin((mber.wiggleSeed + mber.life) * mber.freq * 60.0);

            double speedYMod = (mber.startY - 0.5) * 0.5;
            Vector2 speed = ( emberSpeed * screenSize.x, emberVertSpeed * screenSize.y * speedYMod );

            Vector2 pos = ( 
                (mber.startX * screenSize.x) + ((mber.startX - 0.5) * (mber.life * speed.x * mber.freq)), 
                (mber.startY * screenSize.y) + (mber.life * speed.y * mber.freq) + (sin((mber.wiggleSeed + mber.life) * mber.freq * 40) * (0.1 * screenSize.y))
            );  // TODO: Add sin(freq * time) to vertical 
            Vector2 size = (4, 4) * (1.0 + (mberTM * 4.0)) * mScale;   // TODO: Scale based on screen res

            mber.life += te;

            Screen.DrawTexture(
                emberTex.texID, 
                false,
                pos.x - (size.x * 0.5),
                pos.y - (size.y * 0.5),
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Alpha, alpha * fogFadeAlpha * 0.7,
                DTA_Filtering, true,
                DTA_Desaturate, int(floor((1.0 - alpha) * 255))
            );

            // If we faded out, kill this particle for the next loop
            if(alpha < 0) mber.life = emberTime;
        }

        
        // Draw and update fog
        for(int x = 0; x < fogs.size(); x++) {
            let fog = fogs[x];

            fog.life += te;

            let tm = fog.life / fogTime;
            if(tm > 1.0) {
                fog.life = fog.life - fogTime;
                fog.bSize = (frandom(0, 1.6), frandom(0.0, 0.62));
                tm = 0;
                fog.img = UITexture.Get("MODEFOG" .. random(1,4));
            }

            double alpha;
            if(tm * 2.0 > 1.0) {
                alpha = UIMath.EaseOutCubicf(1.0 - tm);
            } else {
                alpha = UIMath.EaseOutCubicf(tm);
            }
            alpha = alpha * fogAlpha * fogFadeAlpha;

            Vector2 imgScale = ( (1,1) * (1.0 + (0.2 / (1.0 - tm))) ) + fog.bSize;

            // Draw the fog layer
            // Order doesn't really matter much, it's hard to see that the order is off
            double aspect = fog.img.size.x / fog.img.size.y;
            Vector2 size = screenSize.x > screenSize.y ? (screenSize.x * imgScale.x, (screenSize.x / aspect) * imgScale.y) : (screenSize.y * aspect * imgScale.x, screenSize.y * imgScale.y);
            Vector2 pos = (screenSize / 2.0) - (size / 2.0);
            // test
            pos.y = MIN(0.0, (screenSize.y / 2.0) - (size.y / 2.2));

            Screen.DrawTexture(
                fog.img.texID, 
                true,
                pos.x,
                pos.y,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Alpha, alpha * fogFadeAlpha,
                DTA_Filtering, true
            );
        }
    }


    ui BGEmber makeEmber(double life, BGEmber o = null) {
        if(!o) {
            o = new("BGEmber");
            embers.push(o);
        }

        o.life = life;
        o.startX = frandom(0.1, 0.9);
        o.startY = frandom(0.6, 0.95);
        o.freq = frandom(0.8, 2.0);
        o.wiggleSeed = frandom(0.0, 100.0);

        return o;
    }
}