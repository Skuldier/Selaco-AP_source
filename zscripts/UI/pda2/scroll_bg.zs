class UIScrollBG : UIImage {
    Vector2 move, deltaMove;
	Vector2 force;
	Vector2 mousePos;
    Vector2 edgeOffset, scrollScale;
    Shape2D bgShape;
    Shape2DTransform bgShapeTransform;
    bool freeze, ignoreMouse, filter;
    double deltaTime, wobbleAmount, wobbleSpeed;
    UITexture scrollTex;

    UIScrollBG init(string image, NineSlice borderSlices = null) {
		Super.init((0,0), (100,100), "", borderSlices);
        pinToParent();

        scrollTex = UITexture.Get(image);
        edgeOffset = (3,3);
        scrollScale = (1,1);
        deltaTime = getTime();


		return self;
	}

    override void tick() {
        Super.tick();

		//move += force * 3;
	}

    override void layout(Vector2 parentScale, double parentAlpha) {
        Super.layout(parentScale, parentAlpha);
    }

    double wobble(double time) {
        return cos(time * wobbleSpeed) * wobbleAmount;
    }

    override void draw() {
        if(hidden) { return; }
        
        Super.draw();

        double time = getTime();
        double te = time - deltaTime;
        deltaTime = time;

        move += force * 3.0 * te * 35.0 + (force * wobble(time) * 3.0 * te * 35.0);
        
        UIBox b;
        boundingBoxToScreen(b);

        // TODO: Check if bb is zero before bothering to draw

        // Draw background
        if(scrollTex && scrollTex.isValid()) {
            if(!bgShape) {
                UIMenu m = getMenu();
                bgShape = m ? m.recycler.getShape() : new("Shape2D");
            }

            if(!bgShapeTransform) {
                bgShapeTransform = new("Shape2DTransform");
            }

            // Build tiled texture
            bgShape.clear();
            int vc;
            Vector2 containerSize = b.size - (edgeOffset * 2);
            containerSize.x /= cScale.x;
            containerSize.y /= cScale.y;
            Vector2 size = (containerSize.x / scrollTex.size.x / scrollScale.x, containerSize.y / scrollTex.size.y / scrollScale.y);
            Shape2DHelper.AddQuad(bgShape, b.pos + edgeOffset, b.size - (edgeOffset * 2), freeze ? (0,0) : (move.x * cScale.x, move.y * cScale.y) * 0.01, size, vc);
            
            // Draw tiled texture
            Screen.drawShape(
                scrollTex.texID, 
                false,
                bgShape,
                DTA_Filtering, filter,
                DTA_Alpha, cAlpha
            );
        }
	}

	override bool event(ViewEvent ev) {
		if (!ignoreMouse && ev.type == UIEvent.Type_MouseMove) {
            mousePos = (ev.mouseX, ev.mouseY);
			Vector2 size = (Screen.GetWidth(), Screen.GetHeight());
			Vector2 center = size / 2;
			force = (mousePos - center);
			force.x /= center.x;
			force.y /= center.y;
		}

		return Super.event(ev);
	}

	override void teardown(UIRecycler recycler) {
        Super.teardown(recycler);

        // Recycle the shape
        if(bgShape && recycler) {
            recycler.recycleShape(bgShape);
            bgShape = null;
        }
    }
}