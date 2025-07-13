// Class for drawing lines connecting upgrade icons with the weapon image
// Draw line segments made up of rotated images
// This view respects no boundaries or clipping whatsoever, so positioning and sizing have no effect
class UpgradeLine : UIView {
    protected Vector2 pointA, pointB;       // Points to connect, in screen space
    Vector2 sourcePoint, destPoint;         // Points to connect in image space
    UIView sourceView, destView;
    double sourceOffset;    // Distance from center of source view, usually slightly larger than the icon will be
    Array<Shape2D> shapes;
    Array<Shape2DTransform> transforms;
    TextureID lineTex, selLineTex;
    bool selected;
    int numLines;

    UpgradeLine init(UIView sourceView, Vector2 sourcePoint, double sourceOffset, UIView destView, Vector2 destPoint, bool isDisabled = false) {
        Super.init((0,0), (100, 100));

        self.sourceView = sourceView;
        self.destView = destView;
        self.destPoint = destPoint;
        self.sourcePoint = sourcePoint;
        self.sourceOffset = sourceOffset;
        ignoresClipping = true;
        selected = false;

        lineTex = TexMan.CheckForTexture(WeaponStationGFXPath .. (isDisabled ? "line4.png" : "line2.png"));
        selLineTex = TexMan.CheckForTexture(WeaponStationGFXPath .. (isDisabled ? "line3.png" : "line.png"));
        numLines = 0;

        return self;
    }


    // TODO: Enforce a 45 degree angle on the offset distance!
    void calcLines() {
        numLines = 0;
        Vector2 lines[2];

        if(!sourceView || !destView) return;

        pointB = parent.screenToRel( destView.relToScreen( destView is 'UIImage' ? UIImage(destView).imageRelToLocal(destPoint) : destPoint ) );
        
        //Vector2 dir = pointB - sourceView.relToScreen(sourcePoint);
        //dir = dir.unit();
        //pointA = sourceView.relToScreen(sourcePoint + (dir * sourceOffset));
        pointA = parent.screenToRel( sourceView.relToScreen(sourcePoint) );

        //Console.Printf("From: %f - %f  to  %f - %f", pointA.x, pointA.y, pointB.x, pointB.y);

        if(abs(pointA.x - pointB.x) < 20) {
            // Do a single vertical line
            double mv = pointB.y - pointA.y;
            pointA.y += mv > 0 ? MIN(sourceOffset, mv) : MAX(-sourceOffset, mv);
            lines[numLines++] = (0, pointB.y - pointA.y);
        } else if(abs(pointA.y - pointB.y) < 20) {
            // Do a single horizontal line
            double mv = pointB.x - pointA.x;
            pointA.x += mv > 0 ? MIN(sourceOffset, mv) : MAX(-sourceOffset, mv);
            lines[numLines++] = (pointB.x - pointA.x, 0);
        } else {
            // Find a path using right angles when possible
            // Add diagonal first, then the straight line
            Vector2 diff = pointB - PointA;
            Vector2 m1, m2;
            if(abs(diff.x) > abs(diff.y)) {
                m1 = (abs(diff.y) * (diff.x > 0 ? 1 : -1), diff.y);

                // Add offset
                let offs = m1.unit() * MIN(sourceOffset, m1.length());
                PointA += offs;
                m1 = m1.unit() * (m1.length() - offs.length());
                diff = PointB - PointA;

                m2 = diff - m1;
            } else {
                m1 = (diff.x, abs(diff.x) * (diff.y > 0 ? 1 : -1));

                // Add offset
                let offs = m1.unit() * MIN(sourceOffset, m1.length());
                PointA += offs;
                m1 = m1.unit() * (m1.length() - offs.length());
                diff = PointB - PointA;

                m2 = diff - m1;
            }
            lines[numLines++] = m1;
            if(m2.length() >= 30) lines[numLines++] = m2;
        }

        // Now that we have some lines, construct a series of shapes and transforms
        Vector2 pos = pointA;
        for(int x = 0; x < numLines; x++) {
            if(shapes.size() <= x) shapes.push(new("Shape2D"));
            if(transforms.size() <= x) transforms.push(new("Shape2DTransform"));

            //Console.Printf("Line: %f - %f  Pos: %f - %f", lines[x].x, lines[x].y, pos.x, pos.y);
            double len = lines[x].length();
            Vector2 lineNorm = lines[x].unit();
            Shape2D shape = shapes[x];
            Shape2DTransform transform = transforms[x];
            shape.clear();

            // TODO: Use CScale to scale size to screen
            int vc = 0;
			Shape2DHelper.AddQuadRawUV(shape, (-14, -14), (15, 28), (0,0), (0.15, 1), vc);
            Shape2DHelper.AddQuadRawUV(shape, (1, -14), (len - 2, 28), (0.15, 0), (0.85, 1), vc);
            Shape2DHelper.AddQuadRawUV(shape, (len - 1, -14), (15, 28), (0.85, 0), (1, 1), vc);
            transform.clear();
            transform.scale(cScale);
            transform.rotate(atan2(lineNorm.y, lineNorm.x));
            transform.translate(relToScreen(pos));
            shape.SetTransform(transform);

            //Console.Printf("Angle: %f", atan2(lineNorm.y, lineNorm.x));

            pos += lines[x];
        }
    }

    override void layout(Vector2 parentScale, double parentAlpha) {
        Super.layout(parentScale, parentAlpha);
        calcLines();
    }

    override void draw() {
        if(hidden) { return; }
        Super.draw();

        // TODO: Use CScale to scale size to screen
        TextureID tex = selected ? selLineTex : lineTex;
        for(int x = 0; x < numLines; x++) {
            Screen.drawShape(
                tex,
                true,
                shapes[x],
                DTA_Alpha, cAlpha,
                DTA_Filtering, true
            );
        }
    }
}


class InstalledButton : UIButton {
    InstalledButton init(string title) {
        Super.init((0,0), (100, 26), title, 'SEL14FONT', 
            UIButtonState.CreateSlices(WeaponStationGFXPath .. "installBG.png", (13, 12), (24, 14)),
            disabled: UIButtonState.CreateSlices(WeaponStationGFXPath .. "installBG.png", (13, 12), (24, 14))
        );

        setDisabled();
        setTextPadding(12, 2, 12, 0);

        return self;
    }
}