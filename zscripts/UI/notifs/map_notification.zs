class MapNotification : Notification {
    int titleColor;
    int vOffset, xOffset;
    int textOffset;

    bool isMicro;
    transient ui bool isReady;

    TextureID bgImg, bgImgMask, bg2, imageTex;
    TextureID microBG, microBGMask;

    const textLeft = 122;
    const slideOffset = 600;

    const slideTime = 0.4;
    const mainImgTime = 0.2;
    const textFadeInTime = 0.8;
    const textFadeOutTime = 0.2;
    const textFadeOutTimeOffset = 0.6;
    const showTime = double(3.5);
    const endTime1 = showTime - slideTime;
    const mainEndTime = showTime - mainImgTime;


    override void init(string title, string text, string image, int props) {
        if(!(props & PROP_NO_TEXT_FILTER)) {
            text = StringTable.Localize(text.filter()) .. String.Format("\c- %s\n\cu%s", StringTable.Localize("$AUTOMAP_ITEM_ADDED"), StringTable.Localize("$AUTOMAP_ITEM_ADDED_CONTROL"));
        }
        
        Super.init(title, UIHelper.FilterKeybinds(text, shortMode: true), image, props);

        if(hasGasMask) {
            self.text.replace("\c[HI]", "\c[HI3]");
            self.text.replace("\c[OMNIBLUE]", "\c[HI3]");
        }

        titleColor = hasGasMask ? Font.FindFontColor("HI3") : Font.FindFontColor("HI");

        if(image != "") {
            imageTex = TexMan.CheckForTexture(image, TexMan.Type_Any);
            if(imageTex.isValid()) {
                let texsize = TexMan.GetScaledSize(imageTex);
                textOffset = MAX(0, (texsize.x / 2.0) - 57);
                
            }
        }

        bgImgMask = TexMan.CheckForTexture("AUTGMABG");
        bgImg = TexMan.CheckForTexture("AUTPADBG");
        bg2 = TexMan.CheckForTexture("AUTPADIC");
        microBGMask = TexMan.CheckForTexture("AMGMABG2");
        microBG = TexMan.CheckForTexture("AMPADBG2");
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        if( CVar.GetCVar("g_automapupdates").getInt() <= 0) {
            return;
        }
        let evt = TutorialHandler.GetHandler();
        isMicro = evt && evt.isShowing();
        vOffset = isMicro ?  evt.getCurrentHeight() + 35 : 0;

        S_StartSound("ui/mapupdate", CHAN_VOICE, CHANF_UI, snd_menuvolume);

        Super.start(time);
    }

    override void tick(double time) {
        let evt = TutorialHandler.GetHandler();
        isMicro = evt && evt.isShowing() && evt.getCurrentHeight() > 1;     // Major tutorials don't have a height, so don't go micro for those
        vOffset = isMicro ?  evt.getCurrentHeight() + 35 : 0;

        ticks++;
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = (100 + xOffset, 80 + vOffset) + (offset * 0.2);;
        Font titleFnt = "SEL21FONT";
        Font textFnt = "SEL21FONT";

        double te = time - startTime;

        if(!isReady && 
            !(  
                makeTexReady(imageTex) &&
                makeTexReady(bgImgMask) &&
                makeTexReady(bgImg) &&
                makeTexReady(bg2) &&
                makeTexReady(microBGMask) &&
                makeTexReady(microBG) 
            )
        ) return;

        isReady = true;

        // Draw normal
        if(!isMicro) {
            // Clip slider so it doesn't draw behind the logo
            Clip(pos.x + 65, pos.y - 120, 1000, 240);

            let bgImg = hasGasMask ? bgImgMask : bgImg;
            // Draw background
            if(te < slideTime) {
                float tm = UIMath.EaseInCubicf(1.0 - (te / slideTime));
                DrawTex(bgImg, pos - (slideOffset * tm, 0), a: alpha);
            } else if(te > showTime - slideTime) {
                float tm = UIMath.EaseOutCubicf(abs(endTime1 - te) / slideTime);
                DrawTex(bgImg, pos - (slideOffset * tm, 0), a: alpha);
            } else {
                DrawTex(bgImg, pos, a: alpha);
            }

            double imga = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);

            ClearClip();

            // Draw images
            if(image == "" || (props & PROP_DRAW_BG)) { DrawTex(bg2, pos, a: alpha * imga); }
            if(image != "") { DrawTexAdvanced(imageTex, pos /*- (7,7)*/, flags: DR_NO_SPRITE_OFFSET | DR_SCALE_IS_SIZE, a: alpha * imga, scale: (114, 114)); }

            double textTm;
            if(te > showTime - (textFadeOutTime + textFadeOutTimeOffset)) {
                textTm = 1.0 - (abs(showTime - textFadeOutTime - textFadeOutTimeOffset - te) / textFadeOutTime);
            } else {
                textTm = te / textFadeInTime;
            }

            // Draw Text
            DrawStr(titleFnt, title, pos + (textLeft + textOffset, 12), translation: titleColor, a: alpha * textTm, monoSpace: false, scale: (0.85714, 0.85714));
            DrawStr(textFnt, text, pos + (textLeft + textOffset, 42), a: alpha * textTm, monoSpace: false, scale: (0.85714, 0.85714));

        } else {    // Draw micro version, because a tutorial is up
            Clip(pos.x + 32, pos.y - 120, 1000, 240);
            int tleft = textLeft / 2 + 3 + 5;
            int textWidth = textFnt.StringWidth(text);
            double textSlideOffset = 600 - (textWidth + tleft + 33);

            let bgImg = hasGasMask ? microBGMask : microBG;

            // Draw background
            if(te < slideTime) {
                float tm = UIMath.EaseInCubicf(1.0 - (te / slideTime));
                DrawTex(bgImg, pos - (textSlideOffset + (600 * tm), 0), a: alpha);
            } else if(te > showTime - slideTime) {
                float tm = UIMath.EaseOutCubicf(abs(endTime1 - te) / slideTime);
                DrawTex(bgImg, pos - (textSlideOffset + (600 * tm), 0), a: alpha);
            } else {
                DrawTex(bgImg, pos - (textSlideOffset, 0), a: alpha);
            }
            
            ClearClip();

            double imga = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);

            // Draw images
            if(image != "") { DrawTexAdvanced(imageTex, pos, flags: DR_NO_SPRITE_OFFSET | DR_SCALE_IS_SIZE, a: alpha * imga, scale: (64, 64)); }

            double textTm;
            if(te > showTime - (textFadeOutTime + textFadeOutTimeOffset)) {
                textTm = 1.0 - (abs(showTime - textFadeOutTime - textFadeOutTimeOffset - te) / textFadeOutTime);
            } else {
                textTm = te / textFadeInTime;
            }

            // Draw Text
            //DrawStr(titleFnt, title, pos + (textLeft + textOffset, 12), translation: titleColor, a: alpha * textTm, monoSpace: false);
            DrawStr(textFnt, text, pos + (tleft + textOffset, 8), a: alpha * textTm, monoSpace: false, scale: (0.85714, 0.85714));
        }
    }

}