struct CircleShape32 {
    Shape2D shape;
    Shape2DTransform transform;
    UISTexture tex;
    double radius, thickness;
    double innerCoordXS, outerCoordXS;
    bool dirty;

    const NUM_VERTEX = 32;
    const VA = 360. / double(NUM_VERTEX);
    static const double cosCache[] = { cos(0), cos(VA * 1), cos(VA * 2), cos(VA * 3), cos(VA * 4), cos(VA * 5), cos(VA * 6), cos(VA * 7), cos(VA * 8), cos(VA * 9), cos(VA * 10), cos(VA * 11), cos(VA * 12), cos(VA * 13), cos(VA * 14), cos(VA * 15), cos(VA * 16), cos(VA * 17), cos(VA * 18), cos(VA * 19), cos(VA * 20), cos(VA * 21), cos(VA * 22), cos(VA * 23), cos(VA * 24), cos(VA * 25), cos(VA * 26), cos(VA * 27), cos(VA * 28), cos(VA * 29), cos(VA * 30), cos(VA * 31) };
    static const double sinCache[] = { sin(0), sin(VA * 1), sin(VA * 2), sin(VA * 3), sin(VA * 4), sin(VA * 5), sin(VA * 6), sin(VA * 7), sin(VA * 8), sin(VA * 9), sin(VA * 10), sin(VA * 11), sin(VA * 12), sin(VA * 13), sin(VA * 14), sin(VA * 15), sin(VA * 16), sin(VA * 17), sin(VA * 18), sin(VA * 19), sin(VA * 20), sin(VA * 21), sin(VA * 22), sin(VA * 23), sin(VA * 24), sin(VA * 25), sin(VA * 26), sin(VA * 27), sin(VA * 28), sin(VA * 29), sin(VA * 30), sin(VA * 31) };

    void init(String texName, double radius, double thickness, double uvInner, double uvOuter) {
        setTexture(texName, uvInner, uvOuter);
        self.radius = radius;
        self.thickness = thickness;
        dirty = true;
    }

    void setTexture(String texName, double uvInner, double uvOuter) {
        tex.get(texName);

        // cache math
        innerCoordXS = uvInner - 0.5;
        outerCoordXS = uvOuter - 0.5;
        dirty = true;

        if(!tex.isValid()) {
            Console.Printf("\c[GOLD]Could not create circle texture: %s", texName);
        }
    }

    void setRadius(double radius, double thickness = 12) {
        if(radius ~== self.radius || thickness ~== self.thickness) dirty = true;
        self.radius = radius;
        self.thickness = thickness;
    }

    void build() {
        if(shape && !dirty) return;

        if(!shape) shape = new("Shape2D");
        else shape.clear();
        if(!transform) transform = new("Shape2DTransform");

        double innerRad = radius - (thickness * 0.5);
        double outerRad = radius + (thickness * 0.5);

        for(int x = 0; x < NUM_VERTEX; x++) {
            shape.pushVertex((innerRad * cosCache[x], innerRad * sinCache[x]));
            shape.pushCoord((innerCoordXS * cosCache[x] + 0.5, innerCoordXS * sinCache[x] + 0.5));
            shape.pushVertex((outerRad * cosCache[x], outerRad * sinCache[x]));
            shape.pushCoord((outerCoordXS * cosCache[x] + 0.5, outerCoordXS * sinCache[x] + 0.5));
        }

        int tcount = (NUM_VERTEX * 2) - 2;
        for(int x = 0; x < tcount; x += 2) {
            shape.pushTriangle(x, x + 1, x + 2);
            shape.pushTriangle(x + 2, x + 1, x + 3);
        }
        shape.pushTriangle(tcount, tcount + 1, 0);
        shape.pushTriangle(0, tcount + 1, 1);
    }

    void draw(Vector2 pos, Vector2 scale = (1,1), Color col = 0xFFFFFFFF, double alpha = 1.0, double rotation = 0) {
        build();

        transform.clear();
        transform.scale(scale);
        transform.rotate(rotation);
        transform.translate(pos);
        shape.setTransform(transform);

        Screen.drawShape(
            tex.texID, 
            false,
            shape,
            DTA_Alpha, alpha,
            DTA_Filtering, true,
            DTA_Color, col
        );
    }
}


struct CircleShape16 {
    Shape2D shape;
    Shape2DTransform transform;
    UISTexture tex;
    double radius, thickness;
    double innerCoordXS, outerCoordXS;
    bool dirty;

    const NUM_VERTEX = 16;
    const VA = 360. / double(NUM_VERTEX);
    static const double cosCache[] = { cos(0), cos(VA * 1), cos(VA * 2), cos(VA * 3), cos(VA * 4), cos(VA * 5), cos(VA * 6), cos(VA * 7), cos(VA * 8), cos(VA * 9), cos(VA * 10), cos(VA * 11), cos(VA * 12), cos(VA * 13), cos(VA * 14), cos(VA * 15) };
    static const double sinCache[] = { sin(0), sin(VA * 1), sin(VA * 2), sin(VA * 3), sin(VA * 4), sin(VA * 5), sin(VA * 6), sin(VA * 7), sin(VA * 8), sin(VA * 9), sin(VA * 10), sin(VA * 11), sin(VA * 12), sin(VA * 13), sin(VA * 14), sin(VA * 15) };

    void init(String texName, double radius, double thickness, double uvInner, double uvOuter) {
        setTexture(texName, uvInner, uvOuter);
        self.radius = radius;
        self.thickness = thickness;
        dirty = true;
    }

    void setTexture(String texName, double uvInner, double uvOuter) {
        tex.get(texName);

        // cache math
        innerCoordXS = uvInner - 0.5;
        outerCoordXS = uvOuter - 0.5;
        dirty = true;

        if(!tex.isValid()) {
            Console.Printf("\c[GOLD]Could not create circle texture: %s", texName);
        }
    }

    void setRadius(double radius, double thickness = 12) {
        if(radius ~== self.radius || thickness ~== self.thickness) dirty = true;
        self.radius = radius;
        self.thickness = thickness;
    }

    void build() {
        if(shape && !dirty) return;

        if(!shape) shape = new("Shape2D");
        else shape.clear();
        if(!transform) transform = new("Shape2DTransform");

        double innerRad = radius - (thickness * 0.5);
        double outerRad = radius + (thickness * 0.5);

        for(int x = 0; x < NUM_VERTEX; x++) {
            shape.pushVertex((innerRad * cosCache[x], innerRad * sinCache[x]));
            shape.pushCoord((innerCoordXS * cosCache[x] + 0.5, innerCoordXS * sinCache[x] + 0.5));
            shape.pushVertex((outerRad * cosCache[x], outerRad * sinCache[x]));
            shape.pushCoord((outerCoordXS * cosCache[x] + 0.5, outerCoordXS * sinCache[x] + 0.5));
        }

        int tcount = (NUM_VERTEX * 2) - 2;
        for(int x = 0; x < tcount; x += 2) {
            shape.pushTriangle(x, x + 1, x + 2);
            shape.pushTriangle(x + 2, x + 1, x + 3);
        }
        shape.pushTriangle(tcount, tcount + 1, 0);
        shape.pushTriangle(0, tcount + 1, 1);
    }

    void draw(Vector2 pos, Vector2 scale = (1,1), Color col = 0xFFFFFFFF, double alpha = 1.0, double rotation = 0) {
        build();

        transform.clear();
        transform.scale(scale);
        transform.rotate(rotation);
        transform.translate(pos);
        shape.setTransform(transform);

        Screen.drawShape(
            tex.texID, 
            false,
            shape,
            DTA_Alpha, alpha,
            DTA_Filtering, true,
            DTA_Color, col
        );
    }
}