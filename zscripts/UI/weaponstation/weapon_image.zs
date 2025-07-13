class UIWeaponImage : UIImage {
    UITexture backTex;
    NineSlice lineTex;
    Shape2D lineShape;
    Shape2DTransform lineTransform;
    UIImage lineImage;
    double startReveal;

    const REVEAL_TIME = 0.31;

    UIWeaponImage init(Vector2 pos, Vector2 size, string imageBase, ImageStyle imgStyle = Image_Scale, Vector2 imgScale = (1,1), ImageAnchor imgAnchor = ImageAnchor_Middle) {
        Super.init(pos, size, "", null, imgStyle, imgScale, imgAnchor);
        tex = UITexture.Get(imageBase .. "Large.png");
        backTex = UITexture.Get(imageBase .. "BG.png");
        raycastTarget = false;

        lineTex = NineSlice.Create(WeaponStationGFXPath .. "scanLine.png", (26, 26), (26, 32));
        lineShape = new("Shape2D");
        lineTransform = new("Shape2DTransform");
        let texMid = tex.size.y + (36 * 2);
        lineTex.buildShape(lineShape, (-26, -(texMid / 2.0)), (26 * 2, texMid));

        return self;
    }

    void setImage(string newImageBase) {
        tex = UITexture.Get(newImageBase .. "Large.png");
        backTex = UITexture.Get(newImageBase .. "BG.png");
        requiresLayout = true;
        startReveal = double.MAX;
    }

    void startAnim(double delay) {
        startReveal = getTime() + delay;
    }

    double revealValue() {
        return CLAMP((getTime() - startReveal) / REVEAL_TIME, 0, 1);
    }

    override void draw() {
        if(hidden) { return; }
        
        double reveal = UIMath.EaseInQuadF( CLAMP((getTime() - startReveal) / REVEAL_TIME, 0, 1) );
        
        UIView.draw();

        UIBox b;
        boundingBoxToScreen(b);
        Vector2 pos, size;
        [pos, size] = getImgPos(b);

        if(backTex) {
            // Draw background texture
            Screen.DrawTexture(
                backTex.texID, 
                true, 
                floor(pos.x),
                floor(pos.y),
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Alpha, cAlpha,
                DTA_ColorOverlay, blendColor,
                DTA_Filtering, !noFilter,
                DTA_Desaturate, int(255.0 * desaturation)
            );
        }

        if(reveal > 0 && tex) {
            UIBox clipRect;
            UIBox revealRect;
            revealRect.pos = pos;
            revealRect.size.y = size.y;
            revealRect.size.x = size.x * reveal;
            getScreenClip(clipRect);
            revealRect.intersect(revealRect, clipRect);

            Screen.setClipRect(int(revealRect.pos.x), int(revealRect.pos.y), int(revealRect.size.x), int(revealRect.size.y));

            Screen.DrawTexture(
                tex.texID, 
                true, 
                floor(pos.x),
                floor(pos.y),
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Alpha, cAlpha,
                DTA_ColorOverlay, blendColor,
                DTA_Filtering, !noFilter,
                DTA_Desaturate, int(255.0 * desaturation)
            );

            Screen.ClearClipRect();

            // Now draw the line
            double revealFade = 1.0 - CLAMP((reveal - 0.85) * 6.66666, 0, 1);
            double extraScale = ((1.0 - revealFade) * 0.2);
            lineTransform.Clear();
            lineTransform.Scale((size.x / tex.size.x, size.y / tex.size.y) + (extraScale, extraScale));
            lineTransform.Translate((MIN(pos.x + size.x, pos.x + (size.x * reveal)), pos.y + (size.y / 2.0)));
            lineShape.SetTransform(lineTransform);

            Screen.drawShape(lineTex.texture.texID, true, lineShape, 
                DTA_Alpha, cAlpha * revealFade
            );
        }
        
    }
}