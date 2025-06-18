// Prototype class for drawing a pie shaped meter
class PieDrawer ui {
    double degreesStart, degreesEnd;
    double rotation;
    Shape2D shape;
    Shape2DTransform transform;
    TextureID tex;

    PieDrawer Init(string texture) {
        transform = new("Shape2DTransform");
        tex = TexMan.CheckForTexture(texture, TexMan.Type_Any);
        TexMan.MakeReady(tex);
        degreesStart = 15;
        degreesEnd = 340;
        return self;
    }

    static float NormAngle(float ang)  {
        return ( ang - ( floor( ang / 360.0 ) * 360.0 ) );
    }

    // Create a normalized point along a square with angle from center 0 degrees = (1.0, 0.5)
    static Vector2 RotV(float ang) {
		let v = (cos(ang), sin(ang));
        ang = NormAngle(ang);

        // Cheap "project" function, calc slope for each border
        float e;
		switch(int(ceil((ang - 45.0) / 90.0))) {
			case 1:
                e = v.x / v.y;
                v.x += (1.0 - v.y) * e;
                v.y = 1.0;
				break;
			case 2:
				e = v.y / v.x;
                v.y += (-1.0 - v.x) * e;
                v.x = -1.0;
				break;
			case 3:
                e = v.x / v.y;
                v.x += (-1.0 - v.y) * e;
                v.y = -1.0;
				break;
			default:
				e = v.y / v.x;
                v.y += (1.0 - v.x) * e;
                v.x = 1.0;
				break;
		}
		
		v.x = (v.x + 1.0) * 0.5;
		v.y = (v.y + 1.0) * 0.5;

		return v; 
	}

    void Build() {
        if(!shape) {
            shape = new("Shape2D");
        } else {
            shape.Clear();
        }

        // What section does the first point start?
        int pStart = ceil((degreesStart - 45.0) / 90.0);
        int pEnd = ceil((degreesEnd - 45.0) / 90.0);
        int numPts = (pEnd - pStart) + 2;
        
        // Push start vertex
        Vector2 p1 = RotV(degreesStart);
        shape.PushVertex(p1 - (0.5, 0.5));
        shape.PushCoord(p1);

        for(int x = pStart; x < pEnd; x++) {
            int a = (x % 4 + 4) % 4;

            Vector2 v;
            switch(a) {
                case 1:
                    v = (0, 1);
                    break;
                case 2:
                    v = (0, 0);
                    break;
                case 3:
                    v = (1, 0);
                    break;
                default:
                    v = (1,1);
                    break;
            }   // This is because arrays of Vectors are broken for some reason

            shape.PushVertex(v - (0.5, 0.5));
            shape.PushCoord(v);
        }
        

        // Push end vertex
        p1 = RotV(degreesEnd);
        shape.PushVertex(p1 - (0.5, 0.5));
        shape.PushCoord(p1);

        // Push center vertex
        shape.PushVertex((0, 0));
        shape.PushCoord((0.5, 0.5));

        // Add some triangles
        for(int x = 0; x < numPts - 1; x++) {
            shape.PushTriangle(numPts, x, x+1);
        }
    }

    bool makeReady() {
        return TexMan.MakeReady(tex);
    }

    void Draw(Vector2 pos, Vector2 size, double angle = 0, double alpha = 1.0, uint color = 0) {
        if(shape) {
            transform.Clear();
            transform.Rotate(angle);
            transform.Scale(size);
            transform.Translate(pos + (size / 2));
            shape.SetTransform(transform);

            if(color == 0) {
                Screen.DrawShape(tex,
                    true,
                    shape,
                    DTA_Alpha, alpha,
                    DTA_Filtering, true
                );
            } else {
                Screen.DrawShape(tex,
                    true,
                    shape,
                    DTA_Alpha, alpha,
                    DTA_Color, color,
                    DTA_Filtering, true
                );
            }
        }
    }
}