
// TODO: Add interpolation between frames and values over time to smooth out movement
class HUDMeter ui {
    PieDrawer pie;
    UITexture baseTex, midTex;
    
    double fadeTime;
    double totalDegrees, degreesStart;
    int value;
    int renderDeltaValue, maxValue;
    Vector2 size;
    uint pieColor;
    bool hideMode;
    transient bool ready;

    const fadeTotalTime = 0.75;

    virtual HUDMeter init(string baseImg, string pieImg, uint pieColor = 0, int size = 86, int maxValue = 100) {
        pie = new("PieDrawer");
        pie.init(pieImg);
        self.size = (size, size);
        renderDeltaValue = -1;
        self.pieColor = pieColor;
        self.maxValue = maxValue;
        totalDegrees = 180;
        degreesStart = 90;

        baseTex = UITexture.Get(baseImg);

        return self;
    }

    virtual HUDMeter init2(string baseImg, string midImg, string pieImg, uint pieColor = 0, int size = 86, int maxValue = 100) {
        pie = new("PieDrawer");
        pie.init(pieImg);
        self.size = (size, size);
        renderDeltaValue = -1;
        self.pieColor = pieColor;
        self.maxValue = maxValue;

        totalDegrees = 360;
        degreesStart = 0;

        baseTex = UITexture.Get(baseImg);
        midTex = UITexture.Get(midImg);

        return self;
    }

    void setImage(string baseImg) {
        if(baseImg) {
            baseTex = UITexture.Get(baseImg);
            ready = false;
        }
    }

    virtual void draw(double time, Vector2 pos, Vector2 scale = (1,1), double alpha = 1) {
        if(!ready && (!TexMan.makeReady(baseTex.texID) || (midTex && !TexMan.makeReady(midTex.texID)) || !TexMan.makeReady(pie.tex))) return;
        ready = true;

        if(fadeTime != 0) {
            alpha *= 1.0 - ((time - fadeTime) / fadeTotalTime);
        }

        if(value != renderDeltaValue) {
            renderDeltaValue = value;
            pie.degreesStart = degreesStart;
            
            if(hideMode) pie.degreesEnd = ((double(maxValue) - double(value)) / double(maxValue)) * totalDegrees + degreesStart;
            else pie.degreesEnd = (double(value) / double(maxValue)) * totalDegrees + degreesStart;
            
            pie.build();
        }

        Vector2 ssize = (size.x * scale.x, size.y * scale.y);
        
        // Draw image
        if(baseTex.texID) {
            Screen.DrawTexture(
                baseTex.texID, 
                true,
                pos.x,
                pos.y,
                DTA_DestWidthF, ssize.x,
                DTA_DestHeightF, ssize.y,
                DTA_Alpha, alpha,
                DTA_Filtering, true
            );
        }

        if(midTex && midTex.texID) {
            Screen.DrawTexture(
                midTex.texID, 
                true,
                pos.x,
                pos.y,
                DTA_DestWidthF, ssize.x,
                DTA_DestHeightF, ssize.y,
                DTA_Alpha, alpha,
                DTA_Filtering, true
            );
        }

        if(value > 0) {
            // Draw Pie
            pie.draw(pos, ssize, 90, alpha, pieColor);
        }
    }
}