class EmailNotification : Notification {
    const goldColor = 0xFFFBC200;

    int titleColor;
    string statusText, statusText2;

    const textPad = 30;
    const textLeft = 115;
    const slideOffset = 500;

    const slideTime1 = 0.3;
    const slideTime2 = 0.5;
    const mainImgTime = 0.2;
    const textFadeInTime = 0.6;
    const textFadeOutTime = 0.2;
    const textFadeOutTimeOffset = 0.5;
    const showTime = double(5.0);
    const endTime1 = showTime - slideTime1;
    const endTime2 = showTime - slidetime2;
    const mainEndTime = showTime - mainImgTime;

    double imgAlphaCnt, imgAlpha, toff;
    //double statusPct;
    int numStatusHash, numStatusHashFill;

    override void init(string title, string text, string image, int props) {
        Super.init(title, UIHelper.FilterKeybinds(text, shortMode: true), image, props);

        toff = frandom(0, 100);
        titleColor = Font.FindFontColor("OMNIBLUE");

        // Determine status text
        let stat = Stats.GetTracker(STAT_DATAPADS_FOUND);
        if(stat && level.levelnum < StatTracker.MAX_LEVEL_NUM) {
            int found = stat.levelValues[level.levelnum];
            int total = stat.levelPossibleValues[level.levelnum];
            statusText = String.Format("\c%s%d/%d", found == total ? "[GOLD]" : "[WHITE]", found, total);
            //statusPct = double(found) / double(total);
            numStatusHashFill = found;
            numStatusHash = total;  // TODO: Limit this to some amount
            //statusText = String.Format("\c%s%d", found == total ? "[GOLD]" : "[HI]", found);
            //statusText2 = String.Format("\c%s/%d", found == total ? "[GOLD]" : "[HI]", total);
        } else {
            //statusPct = 0;
            statusText = "";
        }
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void tick(double time) {
        Super.tick(time);

        imgAlphaCnt = MIN(0.9, imgAlphaCnt + 0.1);
        imgAlpha = frandom(imgAlphaCnt, 1.0);
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = (hasGasMask ? (190, -387) : (110, -297)) + (offset * 0.7);
        Font titleFnt = "SEL16FONT";
        Font textFnt = "SEL14FONT";

        double te = time - startTime;

        //int titleSize = titleFnt.stringWidth(title) + textLeft + textPad;
        //int textSize = textFnt.stringWidth(text);

        // Clip sliders so they don't draw behind the logo
        double slide1x = 0;
        Clip(pos.x + 60, pos.y - 120, 1000, 240, DR_SCREEN_BOTTOM);
        if(te < slideTime1) {
            float tm = UIMath.EaseInCubicf(1.0 - (te / slideTime1));
            slide1x = slideOffset * tm;
        } else if(te > showTime - slideTime2) {
            float tm = UIMath.EaseOutCubicf(abs(endTime2 - te) / slideTime1);
            slide1x = slideOffset * tm;
        }
        DrawImg(hasGasMask ? "PADBG_N4" : "PADBG_N3", pos - (slide1x, 0), DR_SCREEN_BOTTOM | DR_WAIT_READY, a: alpha);

        // Draw Text
        double textTm;
        if(te > showTime - (textFadeOutTime + textFadeOutTimeOffset)) {
            textTm = 1.0 - (abs(showTime - textFadeOutTime - textFadeOutTimeOffset - te) / textFadeOutTime);
        } else {
            textTm = te / textFadeInTime;
        }


        Vector2 progPos = pos + (textLeft - slide1x + 10 + textFnt.stringWidth(statusText), 38);
        Vector2 progTLPos = pos + (textLeft - slide1x, 35);

        DrawStr(titleFnt, title, pos + (textLeft - slide1x, 12), DR_SCREEN_BOTTOM, titleColor, a: alpha * textTm, monoSpace: false);
        DrawStr(textFnt, text, pos + (textLeft - slide1x, 52), DR_SCREEN_BOTTOM, a: alpha * textTm, monoSpace: false);
        //DrawStr(textFnt, statusText, pos + (textLeft - slide2x + 300, 49), DR_SCREEN_BOTTOM | DR_TEXT_RIGHT, a: alpha * textTm, monoSpace: false, scale: (1, 1));

        // Draw portrait/image
        double imga = te < mainEndTime ? 1.0 : 1.0 - ((te - mainEndTime) / mainImgTime);

        if(numStatusHash > 0) {
            // Draw status text
            DrawStr('SEL14FONT', statusText,  progTLPos, DR_SCREEN_BOTTOM, a: alpha * textTm, monoSpace: false, scale: (1, 0.9));

            // Progress bar background
            bool smallWidth = numStatusHash <= 5;
            DrawImg(smallWidth ? "PADPROG5" : "PADPROG1", progPos, DR_SCREEN_BOTTOM | DR_WAIT_READY, a: alpha * textTm);


            // Draw progress bar and text
            int progWidth = smallWidth ? 80 : 155;
            float inc = float(progWidth) / float(numStatusHash);
            
            // Foreground, showing percentage
            // Clip to size
            int nClipX = MAX(pos.x + 60, progPos.x);
            Clip(nClipX, 0, MAX(0, (inc * numStatusHashFill) - (nClipX - progPos.x)), virtualScreenSize.y);
            
            if(numStatusHash == numStatusHashFill) {
                DrawImgCol(smallWidth ? "PADPROG6" : "PADPROG2", progPos, goldColor, DR_SCREEN_BOTTOM | DR_WAIT_READY, a: alpha * textTm);
            } else {
                DrawImg(smallWidth ? "PADPROG6" : "PADPROG2", progPos, DR_SCREEN_BOTTOM | DR_WAIT_READY, a: alpha * textTm);
            }
            
            

            // Foreground hash marks
            for(int x = 1; x < numStatusHashFill; x++) {
                DrawImg("PADPROG4", progPos + (inc * x, 0), DR_SCREEN_BOTTOM | DR_WAIT_READY, a: alpha * textTm);
            }
        }
        
        Screen.ClearClipRect();

        // Draw icon and scanline effect
        DrawImg(hasGasMask ? "PADICON2" : "PADICON1", pos, DR_SCREEN_BOTTOM | DR_WAIT_READY, a: alpha * imga);
        

        if(image != "") {
            DrawImg(image, pos + (23, 10), DR_SCREEN_BOTTOM | DR_WAIT_READY, a: alpha * imgAlpha * imga);

            // Draw scanlines
            Dim(0xFFFFFFFF, alpha * imgAlpha * 0.2 * imga, 
                pos.x + 23,
                pos.y + 12 + (UIMath.EaseInOutCubicF(abs(sin((time + toff) * 50))) * 76),
                66, 2,
                DR_SCREEN_BOTTOM
            );

            Dim(0xFFFFFFFF, alpha * imgAlpha * 0.1 * imga, 
                pos.x + 23,
                pos.y + 12 + (UIMath.EaseInOutCubicF(abs(sin((time + 20 + toff) * 30))) * 74),
                66, 4,
                DR_SCREEN_BOTTOM
            );
        }
    }
}