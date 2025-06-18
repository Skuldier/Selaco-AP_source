// Draws segments of the HUD in 8 slices
class HUDFrameDrawer : OverlayDrawer {
    Shape2D shape;
	Shape2DTransform transform;
	Vector2 scaledSize, drawScale;

	uint zoomTick, magZoomTick;
	int awayTick;
	Color colorOverlay;
    bool zooming, enabled, magnifiedZoom;

	const ZOOM_TIME = 0.23;
	const ZOOM_TICKS = int(ZOOM_TIME * TICRATE);
    //const MAG_ZOOM_TIME = 0.14;

    Vector2 scaleVec(Vector2 vec, Vector2 scale) {
		return (vec.x * scale.x, vec.y * scale.y);
	}

    protected virtual void CreateSlices(int scWidth, int scHeight) {
		Vector2 imageSize = TexMan.getScaledSize(tid);
		Vector2 imageSizeInv = (1 / imageSize.x, 1 / imageSize.y);

		// Abort if the image has an invalid resolution.
		if (imageSize.x < 0 || imageSize.x ~== 0 || imageSize.y < 0 || imageSize.y ~== 0) {
			return;
		}

        Vector2 absPos = (-20 * scale.x, -20 * scale.y);
        scaledSize = (scWidth + (40 * scale.x), scHeight + (40 * scale.y));
   
        if(!shape) {
			shape = new("Shape2D");
		}

		if(!transform) {
			transform = new("Shape2DTransform");
		}
		
		shape.clear();

		int vertCount = 0;

		// Corners
		Vector2 cornerSize = (90, 95);// + (20, 20);
		Vector2 uvCornerOffset = (0,0);
		Vector2 scaledCornerSize = scaleVec(cornerSize, scale);
		Vector2 cornerSizeUV = scaleVec(cornerSize, imageSizeInv);
		Shape2DHelper.AddQuad(shape, absPos, 											scaledCornerSize, 	(0,0),						 								cornerSizeUV, vertCount);	// Top Left
		Shape2DHelper.AddQuad(shape, absPos + (scaledSize.x - scaledCornerSize.x, 0), 	scaledCornerSize, 	scaleVec((imageSize.x - cornerSize.x, 0), imageSizeInv), 	cornerSizeUV, vertCount);	// Top Right
		Shape2DHelper.AddQuad(shape, absPos + (0, scaledSize.y - scaledCornerSize.y), 	scaledCornerSize, 	scaleVec((0, imageSize.y - cornerSize.y), imageSizeInv), 	cornerSizeUV, vertCount);	// Bot Left
		Shape2DHelper.AddQuad(shape, absPos + scaledSize - scaledCornerSize, 			scaledCornerSize, 	scaleVec(imageSize - cornerSize, imageSizeInv), 			cornerSizeUV, vertCount);	// Bottom Right

		// Sides
		Vector2 midSize = (scaledSize.x - (scaledCornerSize.x * 2.0), scaledCornerSize.y);
		Vector2 sideSize = (scaledCornerSize.x, scaledSize.y - (scaledCornerSize.y * 2.0));
		Vector2 midSizeUV = scaleVec((imageSize.x - (cornerSize.x * 2), cornerSize.y), imageSizeInv);
		Vector2 sideSizeUV = scaleVec((cornerSize.x, imageSize.y - (cornerSize.y * 2)), imageSizeInv);
		Shape2DHelper.AddQuad(shape, absPos + (scaledCornerSize.x, 0), 									midSize, scaleVec((cornerSize.x, 0), imageSizeInv), 							midSizeUV, vertCount);	// Top
		Shape2DHelper.AddQuad(shape, absPos + (scaledCornerSize.x, scaledSize.y - scaledCornerSize.y), 	midSize, scaleVec((cornerSize.x, imageSize.y - cornerSize.y), imageSizeInv), 	midSizeUV, vertCount);	// Bottom
		Shape2DHelper.AddQuad(shape, absPos + (0, scaledCornerSize.y), 									sideSize, scaleVec((0, cornerSize.y), imageSizeInv), 							sideSizeUV, vertCount);	// Left
		Shape2DHelper.AddQuad(shape, absPos + (scaledSize.x - scaledCornerSize.x, scaledCornerSize.y), 	sideSize, scaleVec((imageSize.x - cornerSize.x, cornerSize.y), imageSizeInv), 	sideSizeUV, vertCount);	// Right
    }

    override OverlayDrawer Init(string texture, Vector2 scale) {
        Super.Init(texture, scale);
		ScreenSizeChanged(Screen.GetWidth(), Screen.GetHeight(), scale.x);

		self.drawScale = (1,1);

		makeTexReady(tid);

        return self;
    }

    override void Tick() { 
		Super.Tick();

        // Create slices if it has not yet been created
        if(!shape) {
            CreateSlices(Screen.GetWidth(), Screen.GetHeight());
        }

		// Special zoom code for the DMR, zoom and fade the frame when the DMR zooms in
		// TODO: Make this code generic, since future weapons or mods might want to do a scope style zoom too
		let weapon = SelacoWeapon(players[consolePlayer].ReadyWeapon);
        if(weapon) {
            let deemr = DMR(weapon);
			
			if(deemr) {
				if(weapon.isZooming != zooming) {
					zoomTick = level.TotalTime;
					zooming = weapon.isZooming;

					magnifiedZoom = deemr.magnifiedZoom;
					magZoomTick = magnifiedZoom ? level.TotalTime : 0;
				} else if(deemr.magnifiedZoom != magnifiedZoom) {
					magnifiedZoom = deemr.magnifiedZoom;
					magZoomTick = level.TotalTime;
				}
			} else {
				zoomTick = 0;
				zooming = false;
				magnifiedZoom = false;
			}
        }

		// Override the zoom stuff with transitioning away/in the HUD frame when it's not needed
		if(awayTick != 0) {
			zooming = awayTick > 0;
			zoomTick = abs(awayTick);
		}
    }

    override void Draw(int scWidth, int scHeight, double tm, Vector2 offset) {
        if(disabled) return;
		if(!makeTexReady(tid)) return;

		// Fully zoomed? Don't draw
		if(awayTick > 0 && level.totalTime - awayTick > ZOOM_TICKS) return;

		double time = (double(level.TotalTime) + tm) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + tm) * ITICKRATE;
        //double magZoomTime = (double(level.TotalTime - magZoomTick) + tm) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        //double magZoomFactor = CLAMP(magZoomTime / MAG_ZOOM_TIME, 0.0, 1.0);
        if(!zooming) zoomFactor = 1.0 - zoomFactor;
        //if(!magnifiedZoom) magZoomFactor = 1.0 - magZoomFactor;
		
		zoomFactor = zoomFactor * zoomFactor * zoomFactor * zoomFactor * zoomFactor * zoomFactor;
		
		let scaleVec = self.drawScale * (1.0 + (zoomFactor * 0.025));
		
		transform.Clear();
		transform.Translate(offset + ((scaledSize - (scaleVec.x * scaledSize)) * 0.5));
		transform.Scale(scaleVec);
		shape.SetTransform(transform);
        Screen.drawShape(tid, true, shape, 
            DTA_Alpha, alpha * (1.0 - zoomFactor),
			DTA_Filtering, true,
			DTA_ColorOverlay, colorOverlay
        );
    }


	override void ScreenSizeChanged(int scWidth, int scHeight, double scale) {
		Super.ScreenSizeChanged(scWidth, scHeight, scale);
		CreateSlices(scWidth, scHeight);
    }
}
