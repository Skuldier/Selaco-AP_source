class SpaceBrosteroid : SpaceBroObj {
    UITexture tex;
    double rotSpd;
    int sizeClass, damage;
    uint lastHitTime;
    bool exploded, kamikaze;

    BroSplosionEmitter explodeEmitter;

    const INVUL_TICKS = 10;

    SpaceBrosteroid init(Vector2 pos = (0,0), int sizeClass = 2, double velo = -1) {
        int size = 56;
        int health = 5;
        double mass = 300000;
        switch(sizeClass) {
            case 0:
                tex = UITexture.Get("BROASS0" .. random[bass](1,4));
                rotSpd = frandom(-3.0, 3.0);
                size = 20;
                health = 1;
                mass = 80000;
                damage = 1;
                break;
            case 1:
                tex = UITexture.Get("BROASS1" .. random[bass](1,4));
                rotSpd = frandom(-1.0, 1.0);
                size = 36;
                health = 3;
                mass = 170000;
                damage = 3;
                break;
            case 99:
                tex = UITexture.Get("BROASZ24");
                rotSpd = frandom(-0.4, 0.4);
                size = 100;
                health = 150;
                mass = 25550000;
                damage = 99999;
                canDisplace = false;
                break;
            default:
                tex = UITexture.Get("BROASS2" .. random[bass](1,4));
                rotSpd = frandom(-0.5, 0.5);
                damage = 5;
                break;
        }

        Super.init(pos, angle: frandom(0, 360), size: size);
        self.health = health;
        self.sizeClass = sizeClass;
        self.mass = mass;
        
        // By default point the asteroid towards earth which is at 0,0
        // with a bit of a random angle offset
        let dir = (-pos).unit();
        vel =  Actor.AngleToVector(atan2(dir.y, dir.x) + frandom(-5, 5), velo == -1 ? frandom(0.06, 1.1) : velo);


        drawTex = tex;
        drawSize = tex ? tex.size.x : 64;
        if(sizeClass == 99) drawSize = 100;

        explodeEmitter = new("BroSplosionEmitter").init();

        return self;
    }

    override bool tick() {
        deltaPos = pos;
        deltaAngle = angle;
        angle += rotSpd;

        // Limit vel
        double spd = vel.length();
        vel = vel.unit() * min(spd, 5.0);

        double hsize = size / 2.0;

        // bounce off sides
        if( (pos.x - hsize < -192 && vel.x < 0) ||
            (pos.x + hsize > 192 && vel.x > 0) ) vel.x *= -1;

        pos += vel;
        explodeEmitter.pos = pos;
        explodeEmitter.tick();

        // Explode once we get out of range
        if(!exploded && (pos.y > 128 || (pos.y < -1024 && vel.y < 0) || (abs(vel.y) < 0.5 && sizeClass != 99))/*distanceSquared(pos, (0,0)) > 2250000*/) {
            // Check direction, are we headed away or towards the play field?
            /*let a = -pos.unit();
            let b = vel.unit();
            let dt = a.x*b.x + a.y*b.y;
            let det = a.x*b.y - a.y*b.x;
            
            if(abs(atan2(det, dt)) > 90) {*/
                exploded = true;
                ticks = 0;
                S_StartSound(sizeClass == 0 ? "bro/assexplode" : "bro/assexplode2", CHAN_AUTO, CHANF_UI, isMaybeOnScreen() ? SPACE_BRO_VOLUME : SPACE_BRO_VOLUME * 0.5, pitch: frandom(0.9, 1.1));
            //}
        } else if(pos.y > -640 && !exploded && !kamikaze) {
            // This asteroid passed SPACE BRO and will now hit earth
            pos.y = -192;
            
            // Find an position that doesn't overlap with other asteroids
            let world = BroWorld.Find();
            for(int tries = 0; tries < 20; tries++) {
                bool retry = false;

                for(int y = 0; y < world.roids.size(); y++) {
                    if(world.roids[y] != self && intersects(world.roids[y], 5)) {
                        retry = true;
                        break;
                    }
                }

                if(!retry) {
                    break;
                }

                pos.x = frandom(-164, 164);
            }

            // Head towards earth
            let dvel = vel.length();
            if(dvel < 4) dvel = 4;
            vel = (pos * -1.0).unit() * dvel;
            deltaPos = pos;

            kamikaze = true;
        }


        if(!kamikaze) {
            // Limit speed of big mfers
            if(sizeClass == 99 && vel.length() > 0.5)
                vel = vel.unit() * 0.5;
        }
    
        if(exploded) {
            let sc1 = sizeClass == 99 ? 3 : sizeClass + 1;

            if(ticks < sc1 * 5) {
                // TODO: Emit smoke
                for(int x = 0; x < sc1; x++) {
                    let s = frandom(50, 70);
                    explodeEmitter.emit(
                        (frandom(-sc1, sc1), frandom(-sc1, sc1)) * 15.0,  // pos
                        (0,0),                   // vel
                        -frandom(0.1, 0.3),      // speed
                        frandom(0, 360),         // emitangle
                        lifetime: random[broe](12, 16),
                        size: (s, s)
                    );
                }

                // Add hud shake when destroying
                let cam = BroWorld.Find().camera;
                let cdist = (cam.pos - pos).length();

                if(cdist < 150) {
                    cam.shakeAmp = MIN(3.0, cam.shakeAmp + ((sizeClass + 1) * 1.5) * (1.0 - (cdist / 150.0)));
                }
            }

            if(ticks > 5 && explodeEmitter.particles.size() == 0) return true;
            if(ticks > 4) drawTex = null;
        }
        

        return Super.tick();
    }

    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        if(!exploded && (other is 'SpaceBroProjectile' || other is 'SpaceBroPlayerShip' || other is 'SpaceBroEarth') ) {
            bool noChildren = false;
            let world = BroWorld.Find();

            lastHitTime = ticks;

            // Take damage
            if(other is 'SpaceBroProjectile') {
                if(ticks >= INVUL_TICKS) health -= SpaceBroProjectile(other).damage;
            } else if(other is 'SpaceBroPlayerShip') {
                let pship = SpaceBroPlayerShip(other);
                if(pship) {
                    // If the ship just came out of invul, destroy this asteroid and do not create children
                    if(pship.ticks == SpaceBroPlayerShip.IntroTicks) {
                        health -= 99999;
                        noChildren = true;
                    }
                } else {
                    health -= 1;
                }
                
            } else if(other is 'SpaceBroEarth') {
                S_StartSound("bro/asshitearth", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME, pitch: 1.0);
                health = 0;
                noChildren = true;
                vel = vel.unit() * 0.05;
            }
            

            // Explode if 0 health
            if(health <= 0) {
                if(other is 'SpaceBroNuke') {
                    noChildren = true;
                }

                if(sizeClass > 0 && !noChildren) {
                    // Create smaller chunks if we are large
                    int newSize = sizeClass == 99 ? 1 : sizeClass - 1;
                    int numChunks = ceil( double(random[broa](1, sizeClass == 99 ? 3 : sizeClass * 1.2)) * frandom(BroWorld.Find().hurt, 1) );
                    for(int x = 0; x < numChunks; x++) {
                        SpaceBrosteroid roid = new("SpaceBrosteroid").init(pos + (frandom(-20, 20), frandom(-20, 20)), newSize);
                        roid.vel.x += random(-1, 1) * frandom(0.1, 2.0);
                        roid.vel.y += frandom(0.1, 0.4);
                        world.roids.push(roid);
                    }
                }

                if(sizeClass > 0) {
                    // Randomly spawn a powerup
                    if(sizeClass == 99 || random(0, 105) == 7) {
                        world.spawnPowerups(pos, sizeClass == 99);
                    }
                }

                ticks = 0;
                lastHitTime = 1;

                exploded = true;

                // Only award points if we shot down the asteroid
                if(other is 'SpaceBroProjectile') {
                    let pts = 100 * (sizeClass + 1);
                    world.score += pts;
                    world.fontEmitter.pos = contactPoint;
                    world.fontEmitter.vel = (0,0);
                    let p = world.fontEmitter.emit(
                        (0,10),                 // pos
                        (0,-4),                 // vel
                        0,                      // speed
                        0,                      // emitangle
                        lifetime: random[broe](24, 30)
                    );
                    p.spec1 = pts;
                }

                S_StartSound(sizeClass == 0 ? "bro/assexplode" : "bro/assexplode2", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME, pitch: frandom(0.9, 1.1));
                
                //return true;
            } else {
                // If we didn't kill it, but we got a hit we award 2 points
                if(other is 'SpaceBroProjectile') {
                    world.score += 3;
                }
            }
        }
        
        return false;
    }


    override void draw(double tm, Vector2 camPos, double scale) {
        if(lastHitTime != 0 && ticks - lastHitTime < 7) {
            overlayColor = UIMath.LerpC(0xDDDD0000, 0x00DD2222, (double(ticks - lastHitTime) + tm) / 7.0);
        } else {
            overlayColor = 0;
        }

        Super.draw(tm, camPos, scale);
        explodeEmitter.draw(tm, campos, scale);
    }
}


class SpaceBroEarth : SpaceBroObj {
    UITexture tex[5];
    BroBigSmokeEmitter earthSmokeEmitter;
    BroScorchEmitter scorchEmitter;
    uint lastHitTime;


    SpaceBroEarth init(Vector2 pos = (0,0)) {
        Super.init(pos, angle: 0, size: 128, mass: 99999999);

        earthSmokeEmitter = new("BroBigSmokeEmitter").init();
        scorchEmitter = new("BroScorchEmitter").init();

        tex[4] = UITexture.Get("BROERTH");
        tex[3] = UITexture.Get("BROERTH2");
        tex[2] = UITexture.Get("BROERTH3");
        tex[1] = UITexture.Get("BROERTH4");
        tex[0] = UITexture.Get("BROERTH5");
        vel = (0, 0);

        drawTex = tex[4];
        drawSize = 128;

        health = 25;

        canDisplace = false;

        return self;
    }


    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        if(other is 'SpaceBrosteroid') {
            // TODO: Add scorch effect
            // Spawn some puffs
            let roid = SpaceBrosteroid(other);

            earthSmokeEmitter.pos = contactPoint;
            for(int x = 0; x < (roid.sizeClass + 1) * 2; x++) {
                earthSmokeEmitter.emit(
                    (frandom(-15, 15), frandom(-15, 15)) * roid.sizeClass,  // pos
                    (0,0),                  // vel
                    0,                      // speed
                    frandom(0,360),         // emitangle
                    lifetime: random[broe](18, 24),
                    size: (1,1) * frandom(45, 64)
                );
            }

            // Add an impact mark from the asteroid
            contactNormal = -contactNormal;
            let p = scorchEmitter.emit(
                (0,31),                 // pos
                (0,0),                  // vel
                0,                      // speed
                atan2(contactNormal.y, contactNormal.x),         // emitangle
                lifetime: random[broe](35 * 30, 35 * 60),
                size: (64, 64)
            );
            p.pos = (round(p.pos.x), round(p.pos.y));

            health = clamp(health - roid.damage, 0, 100);

            drawTex = tex[floor((health / 25.0) * 4)];


            lastHitTime = ticks;
        }
        
        return false;
    }

    override bool tick() {
        scorchEmitter.tick();
        earthSmokeEmitter.tick();

        earthSmokeEmitter.pos = (0,0);

        if(health <= 20 && ticks % 50 == 0) {
            earthSmokeEmitter.emit(
                (0, frandom(0, 62)),    // pos
                (0,0),                  // vel
                0,                      // speed
                frandom(0,360),         // emitangle
                lifetime: random[broe](18, 24),
                size: (1,1) * frandom(25, 30)
            );
        }

        if(health <= 15 && ticks % 40 == 0) {
            earthSmokeEmitter.emit(
                (0, frandom(0, 62)),    // pos
                (0,0),                  // vel
                0,                      // speed
                frandom(0,360),         // emitangle
                lifetime: random[broe](18, 24),
                size: (1,1) * frandom(30, 35)
            );
        }

        if(health <= 10 && ticks % 20 == 0) {
            earthSmokeEmitter.emit(
                (0, frandom(0, 62)),    // pos
                (0,0),                  // vel
                0,                      // speed
                frandom(0,360),         // emitangle
                lifetime: random[broe](18, 24),
                size: (1,1) * frandom(40, 45)
            );
        }

        if(health <= 5 && ticks % 10 == 0) {
            earthSmokeEmitter.emit(
                (0, frandom(0, 62)),    // pos
                (0,0),                  // vel
                0,                      // speed
                frandom(0,360),         // emitangle
                lifetime: random[broe](18, 24),
                size: (1,1) * frandom(30, 35)
            );
        }

        return Super.tick();
    }

    override void draw(double tm, Vector2 camPos, double scale) {
        if(lastHitTime != 0 && ticks - lastHitTime < 7) {
            overlayColor = UIMath.LerpC(0xDDDD0000, 0x00DD2222, (double(ticks - lastHitTime) + tm) / 7.0);
        } else {
            overlayColor = 0;
        }

        Super.draw(tm, camPos, scale);
        scorchEmitter.draw(tm, campos, scale);
        earthSmokeEmitter.draw(tm, campos, scale);
    }
}