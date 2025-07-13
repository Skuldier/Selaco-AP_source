class SpaceBroAlienShip : SpaceBroObj {
    Vector2 targetPos, lastHitNorm, evadeOffset;
    Vector2 laserPos;

    // When we have a target and we are within range, try to rotate around it
    double targetRot, targetOffset;
    double targetRotateDir;

    Shape2D laserShape;
    
    bool exploded;

    uint lastHitTime, lastCollision, explodedTicks, laserTicks;

    BroDeathSmokeEmitter deathSmokeEmitter;
    BroSplosionEmitter explodeEmitter;
    UITexture laserTex;

    const SHIP_SIZE = 35;
    const LASERDELAY = 18;
    const LASERRESET = 25;
    
    double maxSpeed;

    SpaceBroAlienShip init(Vector2 pos = (0,0)) {
        Super.init(pos, angle: 270, size: SHIP_SIZE, mass: 5000);
        
        drawTex = UITexture.Get("BROALIEN");
        laserTex = UITexture.Get("BROLASER");
        drawSize = 45;

        targetPos = pos + (10, 10);
        lastHitNorm = (0,1);

        health = 10;

        explodeEmitter = new("BroSplosionEmitter").init();
        deathSmokeEmitter = new("BroDeathSmokeEmitter").init();
        deathSmokeEmitter.anchorPos = (frandom(-15, 15), frandom(-15, 15));

        maxSpeed = 1.0 + (BroWorld.Find().hurt * 2);
        laserTicks = 60;//int(random[enlasr](150, 230) * MAX(0.25, (1.0 - BroWorld.Find().hurt)));
        targetOffset = frandom(150, 180);   // TODO: Modify offset by difficulty. Make them want to get closer when higher difficulty
        targetRotateDir = (frandom(0.8, 1.2) * (random[alienr](0, 100) > 50 ? -1.0 : 1.0)) * UIMath.Lerpd(0.5, 1.0, BroWorld.Find().hurt);

        return self;
    }


    double normo(double value, double start = 0, double end = 360) {
        double width       = end - start;
        double offsetValue = value - start;

        return ( offsetValue - ( floor( offsetValue / width ) * width ) ) + start;
    }


    override bool tick() {
        SpaceBroObj.tick();

        angle = 0;
        deltaAngle = 0;

        let world = BroWorld.Find();
        deathSmokeEmitter.tick();
        explodeEmitter.tick();

        if( isMaybeOnScreen() && !exploded &&
            (health < 4 && ticks % 3 == 0 ||
            health <= 1 && ticks % 2 == 0 )) {

            deathSmokeEmitter.angle = angle;
            deathSmokeEmitter.pos = pos;
            deathSmokeEmitter.emit(
                deathSmokeEmitter.anchorPos,  // pos
                (0,0),                   // vel
                frandom(0.01, 0.1),      // speed
                0,                       // emitangle
                lifetime: random[broe](12, 16),
                size: health <= 2 ? (15,15) : (11, 11),
                angle: frandom(0, 360),
                angVel: frandom(-10, 10)
            );
        }

        if(exploded) {
            if(ticks - explodedTicks == 16) {
                drawTex = null;
            }

            // Just spawn explosions for now
            if(ticks % 4 == 0 && ticks - explodedTicks <= 16) {
                let s = frandom(50, 70);
                explodeEmitter.pos = pos;
                explodeEmitter.angle = angle;
                explodeEmitter.vel = vel;
                explodeEmitter.emit(
                    (frandom(-5, 5), frandom(-15, 15)),  // pos
                    (0,0),                   // vel
                    -frandom(0.1, 0.3),      // speed
                    frandom(0, 360),         // emitangle
                    lifetime: random[broe](12, 16),
                    size: (s, s)
                );

                let cam = BroWorld.Find().camera;
                if(cam.shakeAmp < 2.0) {
                    cam.shakeAmp = MIN(4.0, cam.shakeAmp + frandom(1.0, 2.0));
                }
            }
            
            if(ticks - explodedTicks > 30 && explodeEmitter.particles.size() == 0) {
                return true;
            }

            return false;
        }

        // Move towards an offset from the player for now
        let p = BroWorld.Find().playerShip;
        if(p && !p.exploded && p.ticks > SpaceBroPlayerShip.IntroTicks && ticks - lastCollision > 10) {
            if(lastHitTime != 0 && !(evadeOffset ~== (0,0)) && ticks - lastHitTime < 30) {
                targetPos = pos + evadeOffset;
            } else {
                // We have a target, if we are in range rotate around it, otherwise try to get in range
                let dirToTarget = p.pos - pos;
                let distToTarget = dirToTarget.length();
                dirToTarget /= distToTarget;

                // Allow a 10% buffer for being "in range"
                if(distToTarget < targetOffset * 1.1) {
                    if(targetRot == 0) {
                        targetRot = atan2(-dirToTarget.y, -dirToTarget.x);
                    }

                    targetPos = p.pos + Actor.AngleToVector(targetRot, targetOffset);

                    // If we already reached the rotation point, keep rotating
                    // This is a pretty dumb way to do it but it's super easy to code!
                    if(distanceSquared(pos, targetPos) < (size * size)) {
                        targetRot += 2.0 * targetRotateDir;
                        targetPos = p.pos + Actor.AngleToVector(targetRot, targetOffset);
                    }
                } else {
                    targetRot = 0;
                    targetPos = p.pos - (dirToTarget * targetOffset);
                }

                targetRot = normo(targetRot, -135, -45);
            }
        } else {
            targetPos = pos + (lastHitNorm * 200.0);
        }

        // Attempt to avoid obstacles by rotating direction away from things that are in the way
        if(!(targetPos ~== pos)) {
            Vector2 checkPoss[30];
            int numChecks = 0;

            Vector2 checkPos;
            bool checked = false;

            // Check other aliens
            for(int x =0; x < world.aliens.size(); x++) {
                if(world.aliens[x] == self) continue;

                [checked, checkPos] = targetTest(world.aliens[x], size * 2);
                if(checked && numChecks < 15) {
                    checkPoss[numChecks++] = checkPos;
                }
            }

            // Check asteroids
            for(int x =0; x < world.roids.size(); x++) {
                [checked, checkPos] = targetTest(world.roids[x], size * 2, 50, true);

                // Add twice, cheaply increasing weight
                if(checked && numChecks < checkPoss.size()) checkPoss[numChecks++] = checkPos;
                if(checked && numChecks < checkPoss.size()) checkPoss[numChecks++] = checkPos;
            }

            // Lastly check earth
            [checked, checkPos] = targetTest(world.earth, size * 2, 200);
            if(checked && numChecks < checkPoss.size()) checkPoss[numChecks++] = checkPos;
            if(checked && numChecks < checkPoss.size()) checkPoss[numChecks++] = checkPos;
            if(checked && numChecks < checkPoss.size()) checkPoss[numChecks++] = checkPos;

            // Now average the check poss
            if(numChecks > 0) {
                checkPos = (0,0);
                for(int x =0; x < numChecks; x++) {
                    checkPos += checkPoss[x];
                }
                targetPos = checkPos / double(numChecks);
            }
            
        }

        // Move towards target pos, move faster if we are evading
        vel += (targetPos - pos).unit() * (!(evadeOffset ~== (0,0)) ? 0.35 : 0.2);
        double vlen = vel.length();
        if(vlen > maxSpeed) {
            vel *= maxSpeed / vlen;
        }
        

        deltaPos = pos;
        pos += vel;

        pos.x = clamp(pos.x, -192, 192);

        // Now attempt to target the player if we are in range
        if(intersects(p, 400)) {
            if(p.ticks > SpaceBroPlayerShip.IntroTicks && laserTicks <= 0) {
                laserTicks = int(random[enlasr](30, 90) * MAX(0.2, (1.25 - world.hurt)));
                fireAt(p);
            } else {
                laserTicks--;
            }
        }
        
        return false;
    }

    void fireAt(SpaceBroObj obj) {
        let world = BroWorld.Find();
        let projectileVel = 6.0 * (0.5 + clamp(world.hurt * 0.5, 0.0, 1.0));
        Vector2 objPos = obj.pos;
        objPos += (obj.vel * ((pos - obj.pos).length() / projectileVel)) * (world.hurt * world.hurt);

        let dir = (objPos - pos);
        let dirLen = dir.length();
        dir /= dirLen;

        double miss = 45.0 * clamp((1.0 - (world.hurt * world.hurt)), 0.0, 1.0);

        let ang = atan2(dir.y, dir.x);
        ang += frandom(-miss, miss);   // Add random missing chance
        let p = new("SpaceBroAlienProjectile").init(pos + (dir * (size * 0.6 + 5)), (0,0), ang);
        p.vel = Actor.AngleToVector(ang, projectileVel);
        p.deltaPos = p.pos - p.vel;

        // TODO: Use a different projectile anim for aliens
        //p.hitAnim = BroWorld.Find().playerShip.projectileImpactAnim;
        
        BroWorld.Find().addProjectile(p);

        S_StartSound("bro/alienfire", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);
    }


    bool, Vector2 targetTest(SpaceBroObj obj, double desiredDist, double checkDist = 100, bool guessVelocities = false) {
        if(intersects(obj, checkDist)) {
            let objPos = obj.pos;
            let targetDir = (targetPos - pos).unit();

            if(guessVelocities && !(vel ~== (0,0))) {
                objPos += obj.vel * ((pos - obj.pos).length() / vel.length());
            }

            Vector2 point, normal;
            bool hit;

            [hit, point, normal] = obj.checkAgainstRay(pos, targetDir, size * 2);

            if(hit) {
                //drawColor = 0xFF00FF00;
                
                // Take the shortest distance to the perpendicular of the current direction
                let perpa = (targetDir.y, -targetDir.x);
                let perpb = (-targetDir.y, targetDir.x);
                let perdist = ((obj.size * 0.5) + desiredDist);
                
                if(distanceSquared(pos, objPos + (perpa * perdist)) < distanceSquared(pos, objPos + (perpb * perdist))) {
                    return true, objPos + (perpa * perdist);
                } else {
                    return true, objPos + (perpb * perdist);
                }
            }
        }

        return false, (0,0);
    }


    override void draw(double tm, Vector2 camPos, double scale) {
        if(lastHitTime != 0 && ticks - lastHitTime < 7) {
            overlayColor = UIMath.LerpC(0xDDDD0000, 0x00DD2222, (double(ticks - lastHitTime) + tm) / 7.0);
        } else {
            overlayColor = 0;
        }
        
        Super.Draw(tm, camPos, scale);

        // Draw debug point
        /*if(drawTex) {
            transform.clear();
            transform.scale((scale, scale) * 10);
            transform.translate(((Screen.GetWidth(), Screen.GetHeight()) / 2.0) + ((targetPos - camPos) * scale));
            shape.setTransform(transform);
            Screen.DrawShape(drawTex.texID,
                true, shape,
                DTA_ColorOverlay, 0xFFFF0000
            );
        }*/
        

        /*if(!laserShape) {
            laserShape = BroWorld.Find().recycler.getShape();
            int vc = 0;
            Shape2DHelper.AddQuad(laserShape, (0, -0.5), (1, 1), (0,0), (1,1), vc);
        }*/

        // Draw the laser
        /*if(laserTicks > 0 && laserTicks < LASERDELAY + 5) {
            let laserDir = (laserPos - pos);
            let laserDist = (laserPos - pos).length();
            laserDir /= laserDist;
            let laserTM = double(laserTicks) / double(LASERDELAY);
            let laserColor = UIMath.LerpC(0xFF000033, 0xFF0000FF, laserTM);


            transform.clear();
            transform.scale((scale * laserDist, scale * (1 + laserTM * 2)));
            transform.rotate(atan2(laserDir.y, laserDir.x));
            transform.translate(((Screen.GetWidth(), Screen.GetHeight()) / 2.0) + ((pos - camPos) * scale));
            laserShape.setTransform(transform);
            

            Screen.DrawShape(laserTex.texID,
                true, laserShape,
                DTA_Color, laserColor
            );
        }*/
        

        explodeEmitter.draw(tm, campos, scale);
        deathSmokeEmitter.draw(tm, campos, scale);
    }


    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        if(ticks - lastCollision > 10 && other is 'SpaceBrosteroid' || other is 'SpaceBroEarth' && isMaybeOnScreen()) {
            lastCollision = ticks;
            lastHitTime = ticks;
            lastHitNorm = contactNormal;
            health -= 1;
            evadeOffset = (0,0);

            S_StartSound("bro/shiphit", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME * 0.6, pitch: frandom(0.9, 1.1));
        }

        if(other is 'SpaceBroProjectile') {
            if(ticks - lastHitTime > 5 && pos.y > -1000) {
                let contactAngle = atan2(contactNormal.y, contactNormal.x);
                contactAngle += random[pa](0, 100) > 50 ? -80 : 80;
                evadeOffset = Actor.AngleToVector(contactAngle, 100);
            }

            health -= SpaceBroProjectile(other).damage;
            lastHitTime = ticks;
        }

        if(!exploded && health <= 0) {
            // Assume death for now
            exploded = true;
            explodedTicks = ticks;

            // Randomly spawn a powerup
            if(random(0, 50) == 5) {
                BroWorld.Find().spawnPowerups(pos);
            }

            // Add some score points
            if(other is 'SpaceBroProjectile') {
                BroWorld world = BroWorld.Find();
                let pts = 1000;
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
        } else {
            if(other is 'SpaceBroProjectile') {
                BroWorld world = BroWorld.Find();
                world.score += 3;
            }
        }

        return false;
    }

    override void teardown(UIRecycler recycler) {
        Super.teardown(recycler);

        if(laserShape && recycler) {
            recycler.recycleShape(laserShape);
            laserShape = null;
        }
    }
}