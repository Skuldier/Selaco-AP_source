class SpaceBroPlayerShip : SpaceBroObj {
    mixin GamepadInput;

    enum ShipTextures {
        ST_Base = 0,
        ST_Thrust,
        ST_Fire,
        ST_MAX
    }

    double thrust, velCap, thrustCap;
    int fireTime, nukeFireTime;
    bool fireLatch, fireNukeLatch;
    bool exploded;
    int explodedTicks;
    double deathSpin;

    int spreadUpgrades, laserUpgrades, damageUpgrades, missileUpgrades;
    int missileCount;
    int spreadTime, missileTime;

    //Vector2 debugPoint; // render this for debugging

    int playingThrust, hitSoundTime;

    SpaceBroInput input;
    UITexture shipTex[ST_MAX];
    SpaceBroEmitter smokeEmitter;
    BroSplosionEmitter explodeEmitter;
    BroDeathSmokeEmitter deathSmokeEmitter;

    Array<SpaceBroProjectile> shots;

    const SBPLR_SIZE    = 24;
    
    const TurnSpeed     = 5.0;
    const ThrustAmount  = 0.05;
    const MaxThrust     = 0.1;
    const MaxBoostThrust = 0.3;
    const MaxVel        = 4.0;
    const MaxBoostVel   = 6.5;
    const BoostDecay    = 0.25;

    const FireTimeout       = 5;
    const FireTimeoutSpread = 8;
    const FireTimeoutAuto   = 6;
    const FireTimeoutSpreadAuto = 9;
    const NukeFireTimeout   = 15;
    const IntroTicks        = 80;

    Bronimation idleAnim, thrustAnim, projectileAnim, projectileImpactAnim;


    SpaceBroPlayerShip init(Vector2 pos = (0,0)) {
        Super.init(pos, angle: 270, size: SBPLR_SIZE, mass: 20000);

        velCap = MaxVel;
        thrustCap = MaxThrust;

        drawSize = 32;

        smokeEmitter = new("BroSmokeEmitter").init();

        idleAnim = new("Bronimation").init(5);
        idleAnim.addFrame("BROSHIP3");
        idleAnim.addFrame("BROSHIP4");

        thrustAnim = new("Bronimation").init(2);
        thrustAnim.addFrame("BROSHIP0");
        thrustAnim.addFrame("BROSHIP1");
        thrustAnim.addFrame("BROSHIP2");

        projectileAnim = new("Bronimation").init(1);
        projectileAnim.addFrame("BROLAZ1");
        projectileAnim.addFrame("BROLAZ2");
        projectileAnim.addFrame("BROLAZ3");
        projectileAnim.addFrame("BROLAZ4");

        
        projectileImpactAnim = new("Bronimation").init(2);
        projectileImpactAnim.addFrame("BROSPLT1");
        projectileImpactAnim.addFrame("BROSPLT2");
        projectileImpactAnim.addFrame("BROSPLT3");
        projectileImpactAnim.addFrame("BROSPLT4");
        projectileImpactAnim.addFrame("BROSPLT5");
        projectileImpactAnim.addFrame("BROSPLT6");
        projectileImpactAnim.addFrame("BROSPLT7");

        explodeEmitter = new("BroSplosionEmitter").init();
        deathSmokeEmitter = new("BroDeathSmokeEmitter").init();

        drawTex = idleAnim.frames[0];

        //spreadUpgrades = 2;
        //missileUpgrades = 1;

        return self;
    }

    override bool tick() {
        deltaPos = pos;
        deltaAngle = angle;

        // Apply a tiny amount of damping
        vel *= 0.989;
        
        bool boosting = false;
        bool thrusting = false;

        if(!exploded) {
            if(ticks <= IntroTicks) {
                fireLatch = false;
            } else {
                boosting = input.btn[1];
                let move = getGamepadRawMove();

                // add deadzone
                if(abs(move.x) < 0.07) move.x = 0;
                else {
                    move.x -= move.x > 0 ? 0.07 : -0.07;
                    move.x /= 1.0 - 0.07;
                }

                if(abs(move.y) < 0.07) move.y = 0;
                else {
                    move.y -= move.y > 0 ? 0.07 : -0.07;
                    move.y /= 1.0 - 0.07;
                }

                // Damp vel
                vel *= 0.75;

                // Turning 
                // Turning no longer exists, moving right and left now! People suck at turning anyways.
                vel.x -= int(input.dir[SB_LEFT]) * 2.5;
                vel.x += int(input.dir[SB_RIGHT]) * 2.5;
                vel.x += clamp(move.x, -1.0, 1.0) * 4.0;
                vel.x = clamp(vel.x, -8.0, 8.0);

                // Moving forward/backward
                if(boosting) {
                    vel.y -= 6.0;
                    vel.y = clamp(vel.y, -10.0, 8.0);
                } else {
                    vel.y += int(input.dir[SB_DOWN]) * 2.5;
                    vel.y -= int(input.dir[SB_UP]) * 1.5;
                    vel.y += clamp(move.y, -1.0, 1.0) * 3.5;
                    vel.y = clamp(vel.y, -6.0, 6.0);
                }
                

                // Thrust
                /*if(input.dir[SB_UP] || (players[consolePlayer].cmd.pitch  * (360./65536.)) > 0.2) {
                    thrust = MIN(thrustCap, thrust + ThrustAmount * (boosting ? 1.6 : 1.0));
                    thrusting = true;
                } else {
                    thrust = MAX(0.0, thrust - ThrustAmount);
                }*/

                thrusting = vel.y < -2.0;

                int fTimeout = spreadUpgrades ? FireTimeoutSpread : FireTimeout;
                int fTimeoutAuto = spreadUpgrades ? FireTimeoutSpreadAuto : FireTimeoutAuto;

                // Fire all of your guns at once
                if(input.btn[0]) {
                    if(!fireLatch && ticks - fireTime >= fTimeout) {
                        fireLatch = true;
                        fire();
                    } else if(fireLatch && (ticks - fireTime) % fTimeoutAuto == 0) {
                        fire(); // Autofire, not as fast but easier
                    }
                } else {
                    fireLatch = false;  // And explode into space
                }

                // Fire nuke if we have one
                if(input.btn[2]) {
                    if(!fireNukeLatch && ticks - nukeFireTime >= NukeFireTimeout) {
                        fireNukeLatch = true;

                        if(BroWorld.Find().nukes > 0) {
                            fireNuke();
                        }
                        
                    }
                } else {
                    fireNukeLatch = false;  // And explode into space
                }


                // Reduce powerups
                if(missileTime > 0 && --missileTime <= 0) {
                    missileUpgrades = 0;
                }

                if(spreadTime > 0 && --spreadTime <= 0) {
                    spreadUpgrades = 0;
                }
            }
        } else {
            deathSmokeEmitter.tick();

            thrust = MAX(0.0, thrust - ThrustAmount);
            fireLatch = false;
            angle += deathSpin;

            let exptm = double(ticks - explodedTicks) / double(TICKRATE * 3);
            exptm = UIMath.Lerpd(1.0, 0.7, exptm);
            drawSize = 32.0 * exptm;

            if(ticks % 8 == 0) {
                let s = frandom(40, 50);
                explodeEmitter.emit(
                    (frandom(-5, 5), frandom(-15, 15)) * exptm,  // pos
                    (0,0),                   // vel
                    -frandom(0.1, 0.3),      // speed
                    frandom(0, 360),         // emitangle
                    lifetime: random[broe](12, 16),
                    size: (s, s) * exptm
                );

                let cam = BroWorld.Find().camera;
                if(cam.shakeAmp < 2.0) {
                    cam.shakeAmp = MIN(4.0, cam.shakeAmp + frandom(1.0, 2.0));
                }
            }

            if(ticks % 2 == 0) {
                deathSmokeEmitter.angle = angle;
                deathSmokeEmitter.pos = pos;
                deathSmokeEmitter.emit(
                    deathSmokeEmitter.anchorPos * exptm,  // pos
                    (0,0),                   // vel
                    frandom(0.01, 0.1),      // speed
                    0,                       // emitangle
                    lifetime: random[broe](12, 16),
                    size: (11, 11) * exptm,
                    angle: frandom(0, 360),
                    angVel: frandom(-10, 10)
                );
            }
        }


        /*if(boosting) {
            velCap = MaxBoostVel;
        } else {
            velCap = MAX(MaxVel, velCap - BoostDecay);
        }
        thrustCap = boosting ? MaxBoostThrust : MaxThrust;

        vel += Actor.AngleToVector(angle) * thrust;

        // Limit vel, this has the added bonus of correcting direction over time when moving at full velocity
        double vlen = vel.length();
        if(vlen > velCap) {
            vel *= velCap / vlen;
        }*/

        pos += vel;

        smokeEmitter.pos = pos;
        smokeEmitter.angle = angle;
        smokeEmitter.vel = vel * 0.15;
        smokeEmitter.tick();
        explodeEmitter.pos = pos;
        explodeEmitter.vel = vel;
        explodeEmitter.tick();

        // Limit pos to the play field
        /*if(distanceSquared((0,0), pos) > (1700 * 1700)) {
            pos = pos.unit() * 1700;
            // TODO: Subtract projected velocity against the "collision normal"

            smokeEmitter.vel = (0,0);   // Just to stop smoke from looking stupid
        }*/

        // Bounce off edges or limit vel
        if(abs(pos.x) > 192) {
            if(exploded) vel.x *= -1;
            else vel.x = 0;
        }

        if(pos.y > -748 || pos.y < -1024) {
            if(exploded) vel.y *= -1;
            else vel.y = 0;
        }

        // Clamp to edges
        pos.x = clamp(pos.x, -192, 192);
        pos.y = clamp(pos.y, -1024, -748);


        if(thrusting){//} && ticks % 2 == 0) {
            // Generate thrust particles
            let pa = smokeEmitter.emit((-2.5, 12), (0,0), frandom(0.65, 1.0) * 2, 180 + frandom(-4, 4), lifetime: 10, size: boosting ? (15, 15) : (10, 10));
            let pb = smokeEmitter.emit(( 2.5, 12), (0,0), frandom(0.65, 1.0) * 2, 180 + frandom(-4, 4), lifetime: 10, size: boosting ? (15, 15) : (10, -10));

            if(boosting) {
                pa.spec1 = 0xFF9999FF;
                pb.spec1 = 0xFF9999FF;
            }
        }

        // Set current render frame
        if(thrusting) {
            drawTex = thrustAnim.getFrame(ticks);
            
            if(playingThrust != (boosting ? 2 : 1)) {
                S_StopSound(CHAN_6);
                S_StartSound(boosting ? "bro/boost" : "bro/thrust", CHAN_6, CHANF_LOOPING | CHANF_UI, SPACE_BRO_VOLUME * 0.25);
                playingThrust = boosting ? 2 : 1;
            }
            
        } else {
            drawTex = idleAnim.getFrame(ticks);
            S_StopSound(CHAN_6);
            playingThrust = 0;
        }

        Super.tick();


        if(exploded && ticks - explodedTicks > (TICKRATE * 3)) {
            S_StopSound(CHAN_7);
            S_StopSound(CHAN_6);
            return true;
        }

        // Debug test
        /*Vector2 normal;
        bool hit;

        [hit, debugPoint, normal] = BroWorld.Find().earth.checkAgainstRay(pos, Actor.AngleToVector(angle), size);
        if(hit) {
            drawColor = 0xFF00FF00;
        } else {
            drawColor = 0xFFFFFFFF;
        }*/
        
        return false;
    }

    void fire() {
        let world = BroWorld.Find();

        if( (missileUpgrades == 2 && missileCount % 3 == 0) || 
            (missileUpgrades == 1 && missileCount % 6 == 0)
        ) {
            for(int x = 0; x < missileUpgrades; x++)
                fireMissile(missileCount + x);
        }
        missileCount++;

        // Basic shot fire
        let p = new("SpaceBroProjectile").init(pos, (0,0), angle, speed: spreadUpgrades ? 7 : 5);
        p.anim = projectileAnim;
        p.hitAnim = projectileImpactAnim;
        p.damage = spreadUpgrades ? 1 : 2;
        
        world.addProjectile(p);
        fireTime = ticks;

        S_StartSound("bro/laser", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);

        // Fire first spread
        if(spreadUpgrades > 0) {
            let p = new("SpaceBroProjectile").init(pos + SpaceBroEmitter.rot((2, 1), angle), (0,0), angle + 10, speed: 7);
            p.anim = projectileAnim;
            p.hitAnim = projectileImpactAnim;
            p.damage = 1;
            world.addProjectile(p);

            p = new("SpaceBroProjectile").init(pos + SpaceBroEmitter.rot((-2, 1), angle), (0,0), angle - 10, speed: 7);
            p.anim = projectileAnim;
            p.hitAnim = projectileImpactAnim;
            p.damage = 1;
            world.addProjectile(p);

            if(spreadUpgrades > 1) {
                p = new("SpaceBroProjectile").init(pos + SpaceBroEmitter.rot((2, 1), angle), (0,0), angle + 20, speed: 7);
                p.anim = projectileAnim;
                p.hitAnim = projectileImpactAnim;
                p.damage = 1;
                world.addProjectile(p);

                p = new("SpaceBroProjectile").init(pos + SpaceBroEmitter.rot((-2, 1), angle), (0,0), angle - 20, speed: 7);
                p.anim = projectileAnim;
                p.hitAnim = projectileImpactAnim;
                p.damage = 1;
                world.addProjectile(p);
            }
        }
    }


    void fireMissile(int ss) {
        let world = BroWorld.Find();

        let offset = ss % 2 ? (-13, 3) : (13, 3);
        let ang = 0;//angle;//ss % 2 ? -25 : 25;

        let p = new("SpaceBroMissile").init(pos + SpaceBroEmitter.rot(offset, angle), (0,0), angle + ang, speed: 5);
        p.anim = projectileAnim;
        p.hitAnim = projectileImpactAnim;
        p.damage = 5;
        world.addProjectile(p);
    }


    void fireNuke() {
        let p = new("SpaceBroNuke").init(pos, vel, angle);
        p.anim = projectileAnim;
        p.hitAnim = projectileImpactAnim;
        
        BroWorld.Find().addProjectile(p);
        fireTime = ticks;

        S_StartSound("bro/nuke", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);

        BroWorld.Find().nukes--;
    }

    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        // Add camera shake when we bonk
        if(other is 'SpaceBrosteroid' || other is 'SpaceBroEarth' || other is 'SpaceBroAlienProjectile') {
            let cam = BroWorld.Find().camera;

            if(cam.shakeAmp < 2.0) {
                cam.shakeAmp = MIN(5.0, cam.shakeAmp + MAX( 0, ((vel - other.vel).length() * 0.4) ) );
            }

            // If we got hit before our last intro frame, we are invulnerable
            if(ticks <= IntroTicks) { return false; }

            deathSpin = random[oa](0,1) > 0 ? frandom(5.0, 8.0) : frandom(-8.0, -5.0);

            // Limit death velocity since it doesn't have damping
            if(vel.length() > 3) {
                vel = vel.unit() * 3.0;
            }

            if(exploded && ticks - hitSoundTime > 10 && !(other is 'SpaceBroAlienProjectile')) S_StartSound("bro/shiphit", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME * 0.38, pitch: frandom(0.9, 1.1));

            if(!exploded) {
                // Assume death for now
                exploded = true;
                explodedTicks = ticks;

                deathSmokeEmitter.anchorPos = (frandom(4, 12) * (random[dp](0,1) > 0 ? 1.0 : -1.0), frandom(-8, 2));
                S_StartSound("bro/shipexplode", CHAN_7, CHANF_UI, SPACE_BRO_VOLUME, pitch: 1.0);

                hitSoundTime = ticks;
            }
        }

        return false;
    }

    override void draw(double tm, Vector2 camPos, double scale) {
        if(explodedTicks != 0 && ticks - explodedTicks < 7) {
            overlayColor = UIMath.LerpC(0xDDDD0000, 0x00DD2222, (double(ticks - explodedTicks) + tm) / 7.0);
        } else {
            overlayColor = 0;
        }

        if(exploded) {
            drawColor = UIMath.LerpC(0xFFFFFFFF, 0xFF000000, (double(ticks) + tm - explodedTicks) / double(TICKRATE * 3));
        } else {
            drawColor = 0xFFFFFFFF;
        }

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
        
        if(ticks < IntroTicks && !exploded) {
            let ltm = (double(ticks) + tm) / double(IntroTicks);
            let dir = Actor.AngleToVector(angle, 1);
            //lpos = UIMath.Lerpv(Actor.AngleToVector(angle, -2400), pos, ltm);
            drawColor = 0xFFFFFF26;

            for(int x = 0; x < 4; x++) {
                let lpos = UIMath.Lerpv(dir * -2400, pos, ltm) + (-dir * (x * 20));

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
        } else {
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

        // Draw debug point
        /*transform.clear();
        transform.scale((scale, scale) * 2);
        transform.translate(((Screen.GetWidth(), Screen.GetHeight()) / 2.0) + ((debugPoint - camPos) * scale));
        shape.setTransform(transform);
        Screen.DrawShape(drawTex.texID,
            true, shape,
            DTA_ColorOverlay, 0xFFFF0000
        );*/

        smokeEmitter.draw(tm, campos, scale);
        explodeEmitter.draw(tm, campos, scale);
        deathSmokeEmitter.draw(tm, campos, scale);
    }
}