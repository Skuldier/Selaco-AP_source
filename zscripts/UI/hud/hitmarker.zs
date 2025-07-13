enum HitMarkerType {
	HIT_MARK_DAMAGE 	    = 0,
	HIT_MARK_KILL 		    = 1,
	HIT_MARK_HEADSHOT 	    = 2,
    HIT_MARK_KILL_HEADSHOT  = 3,
	HIT_MARK_CUSTOM		    = 10
}

enum HitMarkerAnim {
	HIT_ANIM_STATIC = 0,
	HIT_ANIM_GROW 	= 1,
	HIT_ANIM_SPLIT	= 2
}

struct HitMarkerInfo {
    uint time;          // Level time
    double length;      // How long to last
    Color col;          // Blend color
	TextureID tex;      // Texture (should be grayscale)
    ui Shape2D shape;
    ui Shape2DTransform transform;
    HitMarkerAnim animation;
}


extend class Dawn {
    HitMarkerInfo hitMarker;

    const RED_NORM = 0xFFE90702;
    const RED_SHAPE = 0xFF0207E9;
    const YELLO_NORM = 0xFFFFFFFF;
    const YELLO_SHAPE = 0xFF12B5FF;

    static void ShowHitmarker(Actor activator, HitMarkerType type) {
        if(activator && activator.player) {
			Dawn d = Dawn(activator);
			if(d) {
				d.hitMarker.time = Level.time;
                
                switch(type) {
                    case HIT_MARK_HEADSHOT:
                        d.hitMarker.col = YELLO_SHAPE;
                        d.hitMarker.tex = TexMan.CheckForTexture("HITMH", TexMan.TYPE_Any);
                        d.hitMarker.animation = HIT_ANIM_SPLIT;
                        d.hitMarker.length = 0.6;
                        break;
                    case HIT_MARK_KILL:
                        d.hitMarker.col = RED_SHAPE;
                        d.hitMarker.tex = TexMan.CheckForTexture("HITMK2", TexMan.TYPE_Any);
                        d.hitMarker.animation = HIT_ANIM_SPLIT;
                        d.hitMarker.length = 0.9;
                        break;
                    case HIT_MARK_KILL_HEADSHOT:
                        d.hitMarker.col = RED_SHAPE;
                        d.hitMarker.tex = TexMan.CheckForTexture("HITMK3", TexMan.TYPE_Any);
                        d.hitMarker.animation = HIT_ANIM_SPLIT;
                        d.hitMarker.length = 0.9;
                        break;
                    default:
                        d.hitMarker.col = YELLO_NORM;
                        d.hitMarker.tex = TexMan.CheckForTexture("HITMD", TexMan.TYPE_Any);
                        d.hitMarker.animation = HIT_ANIM_GROW;
                        d.hitMarker.length = 0.4;
                        break;
                }
			}
		}
	}

    static void ShowCustomHitmarker(Actor activator, string texture, Color col = 0xFFFF0000, HitMarkerAnim anim = HIT_ANIM_GROW, double time = 0.385) {
		if(activator && activator.player) {
			Dawn d = Dawn(activator);
			if(d) {
				d.hitMarker.time = Level.time;
                d.hitMarker.col = Color(col.a, col.b, col.g, col.r);    // GZDoom is a dick and for some reason reverses R and B in DrawShape() :dawn_shrugging:
                d.hitMarker.tex = TexMan.CheckForTexture(texture, TexMan.TYPE_Any);
                d.hitMarker.animation = anim;
                d.hitMarker.length = time;
			}
		}
	}


    ui void drawHitmarker(double screenScale = 1.0, double scale = 1.0) {
        double time = (System.GetTimeFrac() + double(level.time - hitMarker.time)) * ITICKRATE;

        if(!hitMarker.tex.IsValid() || time > hitMarker.length || !TexMan.MakeReady(hitMarker.tex)) return;

        if(!hitMarker.shape) {
            hitMarker.shape = new('Shape2D');
        }

        if(!hitMarker.transform) {
            hitMarker.transform = new('Shape2DTransform');
        }

        double overallScale = screenScale * scale;
        double alphaHold = hitmarker.length * 0.25;
        double alpha = CLAMP(1.0 - UIMath.EaseOutCubicf((time - alphaHold) / (hitmarker.length - alphaHold)), 0.0, 1.0);

        if(hitMarker.animation == HIT_ANIM_GROW || hitMarker.animation == HIT_ANIM_STATIC) {
            let size = TexMan.getScaledSize(hitMarker.tex) * overallScale;
            if(hitMarker.animation == HIT_ANIM_GROW) {
                size *= 0.6 + (UIMath.EaseOutCubicf(time / hitmarker.length) * 0.4);
            }

            let pos = ((Screen.GetWidth(), Screen.GetHeight()) * 0.5) - (size * 0.5);

            Screen.DrawTexture(hitMarker.tex, true, pos.x, pos.y,
                DTA_Alpha, alpha,
                DTA_Color, hitmarker.col,
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Filtering, true
            );
        } else {
            let size = TexMan.getScaledSize(hitMarker.tex);
            let qsize = size * 0.5;
            size *= 1.0 + (UIMath.EaseOutCubicf(time / hitmarker.length) * 0.5);

            hitMarker.shape.clear();
            int vc = 0;
            
            // No reason to cache this since it changes every frame
            Shape2DHelper.AddQuad(hitMarker.shape, (size.x * -0.5, size.y * -0.5),                      qsize, (0,0),       (0.5, 0.5), vc);   // Top Left
            Shape2DHelper.AddQuad(hitMarker.shape, ((size.x * 0.5) - qsize.x, size.y * -0.5),           qsize, (0.5, 0),    (0.5, 0.5), vc);   // Top Right
            Shape2DHelper.AddQuad(hitMarker.shape, (size.x * -0.5, (size.y * 0.5) - qsize.y),           qsize, (0, 0.5),    (0.5, 0.5), vc);   // Bottom Left
            Shape2DHelper.AddQuad(hitMarker.shape, ((size.x * 0.5) - qsize.x, (size.y * 0.5) - qsize.y),qsize, (0.5, 0.5),  (0.5, 0.5), vc);   // Bottom Right

            hitMarker.transform.clear();
            hitMarker.transform.scale((overallScale, overallScale));
            hitMarker.transform.translate((Screen.GetWidth(), Screen.GetHeight()) / 2.0);
            hitMarker.shape.setTransform(hitMarker.transform);
            
            Screen.drawShape(hitMarker.tex, true, hitMarker.shape, 
                DTA_Alpha, alpha,
                DTA_Color, hitMarker.col,
                DTA_Filtering, true
            );
        }
    }
}