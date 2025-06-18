enum SpaceBroDirection {
    SB_LEFT    = 0,
    SB_UP      = 1,
    SB_RIGHT   = 2,
    SB_DOWN    = 3
}

struct SpaceBroInput {
    bool dir[4];    // Directional keys
    bool btn[3];    // Fire/Boost/Special
}

class SpaceBroObj ui {
    Vector2 pos, deltaPos;
    Vector2 vel;

    Shape2D shape;
    Shape2DTransform transform;

    UITexture drawTex;
    double drawSize;
    int drawColor, overlayColor;

    int ticks;
    int health;
    double mass;

    double angle, deltaAngle;
    double size, alpha;       // Diameter
    bool canDisplace;

    const ITICKRATE = 1.0/double(TICKRATE);

    SpaceBroObj init(Vector2 pos = (0,0), Vector2 vel = (0,0), double angle = 0, double size = 10, double mass = 1) {
        self.pos = pos;
        self.deltaPos = pos;
        self.vel = vel;
        self.angle = angle;
        self.deltaAngle = angle;
        self.size = size;
        self.ticks = 0;
        self.health = 1;
        self.mass = mass;
        alpha = 1.0;
        drawColor = 0xFFFFFFFF;
        canDisplace = true;

        return self;
    }

    // Scale is the absolute scale vs screen size, not the window scale
    // Camera screen pos is always considered to be center, so we can ignore window coordinates
    // Drawing should be clipped by the window though
    virtual void draw(double tm, Vector2 camPos = (0,0), double scale = 4.0) {
        if(!drawTex) { return; }

        if(!shape) {
            shape = BroWorld.Find().recycler.getShape();
            int vc = 0;
            Shape2DHelper.AddQuad(shape, (-0.5, -0.5), (1, 1), (0,0), (1,1), vc);
        }

        if(!transform) {
            transform = new("Shape2DTransform");
        }

        let langle = UIMath.Lerpd(deltaAngle, angle, tm);
        let lpos = UIMath.Lerpv(deltaPos, pos, tm);

        transform.clear();
        transform.scale((scale, scale) * drawSize);
        transform.rotate(langle);
        transform.translate(((Screen.GetWidth(), Screen.GetHeight()) / 2.0) + ((lpos - camPos) * scale));
        shape.setTransform(transform);

        Screen.DrawShape(drawTex.texID,
            true, shape,
            DTA_Alpha, alpha,
            DTA_Color, drawColor,
            DTA_ColorOverlay, overlayColor
        );
    }

    virtual bool tick() {
        ticks++;

        return false;
    }

    virtual bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        return false;
    }

    bool intersects(SpaceBroObj other, double inflate = 0.0) {
        let sz2 = (size / 2.0) + ((other.size + inflate) / 2.0);
        return distanceSquared(pos, other.pos) < (sz2 * sz2);
    }

    virtual void teardown(UIRecycler recycler) {
        if(shape && recycler) {
            recycler.recycleShape(shape);
            shape = null;
        }
    }

    // This is mostly just a guess, and is not perfectly accurate
    bool isMaybeOnScreen() {
        let rp = BroWorld.Find().camera.pos - pos;
        let rad = size * 0.5;

        return  rp.x + rad < 200 && rp.x - rad > -200 &&
                rp.y + rad < 200 && rp.y - rad > -200;
    }
    
    // Thanks to Gabe for the help with this math!
    // Returns: hit, pos, normal
    // TODO: Does not return the correct pos when inflating collision size, but is correct at detecting the collision
    bool, Vector2, Vector2 checkAgainstRay(Vector2 origin, Vector2 direction, double extraSize = 0) {
        Vector2 originToPos = pos - origin;
        double rSquared = ((size + extraSize) * 0.5) * ((size + extraSize) * 0.5);
        double originToPosLSquared = lengthSquared(originToPos);
        double a = originToPos dot direction;
        double bSquared = originToPosLSquared - (a * a);
        double esQuared = (extraSize * 0.5) * (extraSize * 0.5);

        if(rSquared - bSquared < 0.0) {
            return false, (0,0), (0,0);
        }

        double f = sqrt(((size * 0.5) * (size * 0.5)) - bSquared);
        double t = a - f;
        if(originToPosLSquared < rSquared) {
            t = a + f;
        }

        if (t < 0) return false, (0,0), (0,0);

        Vector2 resPoint = origin + (direction * t);

        return true, resPoint, (resPoint - pos).unit();
    }


    static double distanceSquared(Vector2 a, Vector2 b) {
        double dx = a.x - b.x;
        double dy = a.y - b.y;
        return dx*dx + dy*dy;
    }

    static double lengthSquared(Vector2 a) {
        return a.x*a.x + a.y*a.y;
    }

    static Vector2 reflect(Vector2 v, Vector2 normal) {
        return -2*(v dot normal)*normal + v;
    }

    static double loopAngle(double ang, double start = 0.0, double end = 360.0) {
        double width       = end - start;
        double offsetValue = ang - start;
        return ( offsetValue - ( floor( offsetValue / width ) * width ) ) + start;
    }

    static Vector2 rot(Vector2 p, double angle) {
        angle -= 90;
        let cosa = cos(angle);
        let sina = sin(angle);

        return ( p.x * cosa - p.y * sina, 
                 p.x * sina + p.y * cosa );
    }

    static Vector2 VecFromAngle(double angle, double length = 1.0) {
        Vector2 r;

        r.x = cos(angle);
        r.y = sin(angle);

        return r * length;
    }

    // Moves two objects outside of each other
    // Returns contact point and normal
    static Vector2, Vector2 Separate(SpaceBroObj a, SpaceBroObj b, double aWeight = 0.5, double bWeight = 0.5) {
        if(!a.canDisplace && !b.canDisplace) { 
            aWeight = 0;
            bWeight = 0;
        } else if(!a.canDisplace) {
            aWeight = 1;
            bWeight = 0;
        } else if(!b.canDisplace) {
            aWeight = 0;
            bWeight = 1;
        } else {
            // Normalize weights
            if(aWeight ~== bWeight) {
                aWeight = bWeight = 0.5;
            } else {
                if(aWeight <= bWeight) {
                    aWeight = (aWeight / bWeight) * 0.5;
                    bWeight = 1.0 - aweight;
                } else {
                    bWeight = (bWeight / aWeight) * 0.5;
                    aWeight = 1.0 - bweight;
                }
            }
        }

        double dist = (a.pos - b.pos).length();
        Vector2 dir = (a.pos - b.pos) / dist;
        let sdiff = (b.size * 0.5) + (a.size * 0.5) + 2.0;
        sdiff -= dist;

        // Seperate
        a.pos += dir * (sdiff * bWeight);
        b.pos -= dir * (sdiff * aWeight);

        //a.pos = b.pos + (dir * (sdiff));

        return ( a.pos - (dir * (a.size * 0.5)) ), dir;
    }
}


class SpaceBroPowerup : SpaceBroObj {
    bool dead;


    virtual SpaceBroPowerup init(Vector2 pos = (0,0), Vector2 vel = (0,0), double size = 10) {
        Super.init(pos, vel, size: size);

        drawTex = UITexture.Get("BROPWRUP");
        drawSize = drawTex.size.x;

        return self;
    }


    override bool tick() {
        ticks++;

        deltaPos = pos;
        pos += vel;

        // Disappear if we get too far
        if(pos.y > -708) return true;

        return false;
    }


    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        if(!dead && other is 'SpaceBroPlayerShip') {
            SpaceBroPlayerShip p = SpaceBroPlayerShip(other);

            // Give player this powerup
            givePowerup();

            return true;
        }
        
        return false;
    }

    virtual void givePowerup() {
        BroWorld.Find().nukes++;
    }
}


class SpreadPowerup : SpaceBroPowerup {
    override SpaceBroPowerup init(Vector2 pos, Vector2 vel, double size) {
        Super.init(pos, vel, size: size);

        drawTex = UITexture.Get("BROPWRU2");
        drawSize = drawTex.size.x;

        return self;
    }

    override void givePowerup() {
        let world = BroWorld.Find();

        if(world.playerShip) {
            world.playerShip.spreadUpgrades = min(world.playerShip.spreadUpgrades + 1, 2);
            world.playerShip.spreadTime = 15 * 35;
        }
    }
}


class MissilePowerup : SpaceBroPowerup {
    override SpaceBroPowerup init(Vector2 pos, Vector2 vel, double size) {
        Super.init(pos, vel, size: size);

        drawTex = UITexture.Get("BROPWRU1");
        drawSize = drawTex.size.x;

        return self;
    }

    override void givePowerup() {
        let world = BroWorld.Find();

        if(world.playerShip) {
            world.playerShip.missileUpgrades = min(world.playerShip.missileUpgrades + 1, 2);
            world.playerShip.missileTime = 15 * 35;
        }
    }
}