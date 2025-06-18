class GasMask : Inventory {
	int timeEquipped;

    default {
		Inventory.maxAmount 1; 
	}

	override void AttachToOwner(Actor other) {
		// Don't bother adding to the dead player
		if(other.health > 0) {
			timeEquipped = max(1, level.totalTime);	// Cannot be zero
			let d = Dawn(other);
			if(d) {
				d.gasmaskTicks = level.totalTime;	// Inform Dawn she has the gasmask on, used for effects etc
			}
		}

		Super.AttachToOwner(other);
	}

	override void DetachFromOwner() {
		let d = Dawn(owner);
		if(d) {
			d.gasmaskTicks = -level.totalTime;	// Inform Dawn she has the gasmask off, used for effects etc
		}

		Super.DetachFromOwner();
	}
}

// How much crack do you have?
class GasmaskCrackStage : Inventory {
	default {
		Inventory.maxAmount 4;
	}
}


// Specific to the gas mask HUD, has very different scaling properties
// Glitch temporarily removed to stop eye bleed
class GasHUDFrameDrawer : HUDFrameDrawer {
	int startTime;
	int numCracks;
	//bool glitching;

	Shape2D crackShape[4];
	TextureID crackTex[4];

	const maxRatio = 0.5714285714285714;
	const uwRatio = 0.490909;
	const sixtyNineRatio = 0.5625;

	const FIRST_SLIDE_TIME = 0.28;
	const SCALE_DOWN_TIME = 0.18;
	const SCALE_UP_TIME = 0.638;
    const SLIDE_TIME = 0.7;
    const TOTAL_TIME = 2.5;
	const TOTAL_TIME_REVERSE = 1.0;
    const IN_TIME = 1.2;
    const OUT_TIME = 1.4;
	
	override OverlayDrawer Init(string texture, Vector2 scale) {
		Super.init(texture, scale);

		startTime = level.totalTime;

		for(int x = 0; x < crackTex.size(); x++) {
			crackTex[x] = TexMan.CheckForTexture(String.Format("GASCRAK%d", x + 1));
		}

		return self;
	}


	void setStartTime(int time) {
		startTime = time;
		makeTexReady(tid);

		for(int x = 0; x < crackTex.size(); x++) {
			makeTexReady(crackTex[x]);
		}
	}
	
	override void Tick() { 
		Super.Tick();

		// Remove gasmask overlay after animation
		if(startTime < 0 && level.totalTime + startTime > ceil(TOTAL_TIME_REVERSE * TICRATE)) {
			startTime = 0; // Don't draw anymore
		}

		// Flash dawn
		let cticks = level.totalTime - startTime;
		if(cticks >= 40 && cticks <= 50 && cticks % 3 == 0) {
			let reflection = HUDElementReflection(HUD.FindElement('HUDElementReflection'));
			if(reflection) {
				reflection.flash(random(4, 8));
			}
		}

		// Calculate glitch level
		//glitching = random(0, numCracks) > 1 && (level.time / 15) % (5 - numCracks) == 0 && random(0,100) > 50;
	}

	override void Draw(int scWidth, int scHeight, double tm, Vector2 offset) {
		if(startTime == 0) return;
		if(!makeTexReady(tid)) return;
		
		double time = (level.totalTime + tm) * ITICKRATE;
        double ctime = startTime >= 0 ? time - (startTime * ITICKRATE) : TOTAL_TIME - (time - (-startTime * ITICKRATE));
		
		if(ctime > TOTAL_TIME) {
			drawScale = (1,1);
			colorOverlay = 0;
			subDraw(scWidth, scHeight, tm, offset);

			return;
		}

		if(startTime < 0) ctime -= (TOTAL_TIME - TOTAL_TIME_REVERSE);

		double colTM = clamp(UIMath.EaseOutCubicF(ctime / IN_TIME), 0, 1.0);
		double slideTM = 0;
        if(ctime < FIRST_SLIDE_TIME) {
            slideTM = clamp(UIMath.EaseOutCubicF(ctime / FIRST_SLIDE_TIME), 0, 1.0) * 0.2;
        } else {
            slideTM = 0.2 + ( clamp(UIMath.EaseOutCubicF((ctime - FIRST_SLIDE_TIME) / SLIDE_TIME), 0, 1.0) * 0.8 );
        }

		double scaleTM = clamp(UIMath.EaseInCubicF(ctime / SCALE_DOWN_TIME), 0, 1.0);
		double scaleTM2 = 1.0 - clamp(UIMath.EaseOutCubicF((ctime - SCALE_DOWN_TIME) / SCALE_UP_TIME), 0, 1.0);
		drawScale = (1,1) + ((0.15, 0.15) * scaleTM * scaleTM2);

		offset.x += -sin(ctime * 200.0) * (scHeight / 1080.0) * 20.0 * max(0.0, 1.0 - (ctime / SLIDE_TIME));

		ctime -= 1.25;

		if(ctime <= 0.25 && ctime >= 0) {
			double flickerTM = ctime / 0.3;
			if(frandom(0, 100) <= flickerTM * 100.0) {
				colorOverlay = 0;
			} else {
				colorOverlay = Color(int(colTm * 255.0), 0, 0, 0);
			}
		} else if(ctime > 0.25) {
			colorOverlay = 0;
		} else {
			colorOverlay = Color(int(colTm * 255.0), 0, 0, 0);
		}

		double totalSize = scaledSize.y + (scaledSize.y * 0.45);
		offset.y = -(totalSize) + (totalSize * slideTM);

		subDraw(scWidth, scHeight, tm, offset);
	}


	// I hate that this code is duplicated
	void subDraw(int scWidth, int scHeight, double tm, Vector2 offset) {
		double time = (double(level.TotalTime) + tm) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + tm) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        if(!zooming) zoomFactor = 1.0 - zoomFactor;
		
		zoomFactor = zoomFactor * zoomFactor * zoomFactor * zoomFactor * zoomFactor * zoomFactor;
		
		let scaleVec = self.drawScale * (1.0 + (zoomFactor * 0.025));
		let da = alpha * (1.0 - zoomFactor);

		/*if(glitching) {
			colorOverlay = Color(colorOverlay.a + random(0, 25), 0, 0, 0);
			let goof = sin(level.totalTime * 100.0);
			offset +=  goof * (2.0 * scale.x, 2.0 * scale.y);
		}*/

		transform.Clear();
		transform.Translate(offset + ((scaledSize - (scaleVec.x * scaledSize)) * 0.5));
		transform.Scale(scaleVec);
		shape.SetTransform(transform);
        Screen.drawShape(tid, true, shape, 
            DTA_Alpha, da,
			DTA_Filtering, true,
			DTA_ColorOverlay, colorOverlay
        );

		for(int x = 0; x < numCracks; x++) {
			if(numCracks >= 3 && x == 0) continue;
			crackShape[x].SetTransform(transform);
			Screen.drawShape(crackTex[x], true, crackShape[x], 
				DTA_Alpha, da * 0.18,
				DTA_Filtering, true,
				DTA_ColorOverlay, colorOverlay
			);
		}
	}

	
	override void ScreenSizeChanged(int scWidth, int scHeight, double scale) {
		Super.ScreenSizeChanged(scWidth, scHeight, scale);

		// We are setting a custom scale because we won't be using the screen or hud scaling
		Vector2 imageSize = TexMan.getScaledSize(tid);
		self.scale.y = 1.0;
		self.scale.x = double(scHeight) / 1080.0;//(imageSize.y - 40.0 - 500);

		CreateSlices(scWidth, scHeight);
    }


	const ONE_PIXEL = 1.0 / 1960.0;

	override void CreateSlices(int scWidth, int scHeight) {
		Vector2 imageSize = TexMan.getScaledSize(tid);
		Vector2 imageSizeInv = (1 / imageSize.x, 1 / imageSize.y);

		if(!shape) {
			shape = new("Shape2D");
			for(int x = 0; x < crackShape.size(); x++) crackShape[x] = new("Shape2D");
		}

		if(!transform) {
			transform = new("Shape2DTransform");
		}
		
		shape.clear();
		for(int x = 0; x < crackShape.size(); x++) crackShape[x].clear();

		// Abort if the image has an invalid resolution.
		if (imageSize.x < 0 || imageSize.x ~== 0 || imageSize.y < 0 || imageSize.y ~== 0) {
			Console.Printf("\c[RED]Could not create GasHUDFrameDrawer because image is missing or too small!");
			return;
		}

		scaledSize = (scWidth, scHeight);

		// Limit the amount we can shrink or expand, width wise
		scaledSize.x = ceil(MAX(scaledSize.x, scaledSize.y / maxRatio));
		if(!(scaledSize.x ~== scaledSize.y / maxRatio)) {
			scaledSize.x = ceil(MIN(scaledSize.x, scaledSize.y / uwRatio));
		}

		// Add borders for shake
		scaledSize += (40, 40);

        //Vector2 absPos = ((double(scWidth) / 2.0) - (scaledSize.x / 2.0), (double(scHeight) / 2.0) - (scaledSize.y / 2.0));
		Vector2 absPos = ((double(scWidth) / 2.0) - (scaledSize.x / 2.0), -(double(scHeight) / 1080.0) * 20);
		int vertCount = 0;

		// Three Quads
		double magicUV = 0.4913265306122449 - ONE_PIXEL;
		double magicX =	round(963.0 * scale.x);
		double midLeft = absPos.x + magicX;
		double midRight = (absPos.x + scaledSize.x) - magicX;

		Shape2DHelper.AddQuadRawUV(shape, absPos, 					(magicX, scaledSize.y),									(ONE_PIXEL, 0), 		(magicUV, 		1.0), 		vertCount);	// Left
		Shape2DHelper.AddQuadRawUV(shape, (midLeft, absPos.y), 		(midRight - midLeft, scaledSize.y),						(magicUV,  	0), 		(1.0 - magicUV, 1.0), 	vertCount);	// Mid
		Shape2DHelper.AddQuadRawUV(shape, (midRight, absPos.y), 	(magicX, scaledSize.y),									(magicUV,  	0), 		(ONE_PIXEL, 	1.0), 			vertCount);	// Right

		// If we are smaller than the screen we need to add some black borders
		// This will usually only happen in Ultrawide
		if(absPos.x > -40) {
			Shape2DHelper.AddQuadRawUV(shape,  (abspos.x, abspos.y),				(-(abspos.x + 200.0), scaledSize.y),		(0.005,0), 		(0.006, 1.0), 	vertCount);	// Left
			Shape2DHelper.AddQuadRawUV(shape,  (midRight + magicX, absPos.y), 		(absPos.x + 200, scaledSize.y),				(0.005,0), 		(0.006, 1.0), 	vertCount);	// Right
		}

		// Add the bottom of the mask, from the right half of the graphic
		double magicUV2 = 1440.0 / 1960.0;// 0.734693877551020;
		Shape2DHelper.AddQuadRawUV4(
				shape, 
				(-200, abspos.y + scaledSize.y),
				(scWidth + 400, scaledSize.y * 0.45),	
				(magicUV2, 1.0),
				(magicUV2, 0.0),
				(1.0, 1.0),
				(1.0, 0.0),
				vertCount
		);


		// Create the crack shapes, each is a single quad but they have to follow the same shape as the mask itself
		int v1 = 0;
		Shape2DHelper.AddQuadRawUV(
			crackShape[0],  
			(absPos.x + (23.0 * scale.x), absPos.y + (0.383035714285714 * scaledSize.y)),
			(472 * scale.x, (0.584821428571428 * scaledSize.y)),  
			(0,0), (1,1),  v1
		);

		v1 = 0;
		Shape2DHelper.AddQuadRawUV(
			crackShape[1],  
			(midRight + magicX - (630.0 * scale.x), absPos.y + (0.10892857142857 * scaledSize.y)),
			(470 * scale.x, (0.459821428571428 * scaledSize.y)),
			(0,0), (1,1),  v1
		);

		v1 = 0;
		Shape2DHelper.AddQuadRawUV(
			crackShape[2],  
			(absPos.x + (23.0 * scale.x), absPos.y + (0.280357142857142 * scaledSize.y)),
			(700 * scale.x, (0.686607142857142 * scaledSize.y)),  
			(0,0), (1,1),  v1
		);

		v1 = 0;
		Shape2DHelper.AddQuadRawUV(
			crackShape[3],  
			(absPos.x + (283.0 * scale.x), absPos.y + (0.0241071428571428 * scaledSize.y)),
			(611 * scale.x, (0.3258928571428571 * scaledSize.y)),  
			(0,0), (1,1),  v1
		);
    }
}