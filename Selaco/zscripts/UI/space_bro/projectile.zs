class SpaceBroProjectile : SpaceBroObj {
    //UITexture tex;
    int life;
    int damage;
    bool exploded;

    SpaceBroEmitter pEmitter;
    Bronimation anim, hitAnim;

    SpaceBroProjectile init(Vector2 pos = (0,0), Vector2 vel = (0,0), double angle = 0, double size = 6, int damage = 1, double speed = 5) {
        Super.init(pos, vel, angle, size);
        pEmitter = new("BroProjectileEmitter").init();

        //drawTex = tex;
        drawSize = 29;
        life = 70;
        self.damage = damage;
        self.vel = VecFromAngle(angle, speed) + vel;
        
        return self;
    }

    override bool tick() {
        Super.tick();

        if(ticks > life && !exploded) {
            return true;
        } else if(exploded && (!hitAnim || hitAnim.frames.size() <= ticks / hitAnim.frameTime)) {
            return true;
        }

        deltaPos = pos;
        //deltaAngle = angle;
        pos += vel;

        pEmitter.tick();

        if(!exploded) {
            if(pEmitter && ticks % 3 == 0) {
                Vector2 dir = vel.unit();
                pEmitter.pos = pos;
                pEmitter.angle = angle;
                pEmitter.vel = vel;
                pEmitter.emit(
                    (frandom(-1, 1), -10),  // pos
                    (0,0),                  // vel
                    -frandom(1.9, 2),     // speed
                    frandom(-2, 2),         // emitangle
                    lifetime: random[brop](15, 20),
                    size: (1, 1)
                );
            }

            drawTex = anim ? anim.getFrame(ticks) : null;
        } else {
            drawTex = hitAnim ? hitAnim.getFrame(ticks) : null;
        }

        drawSize = drawTex ? drawTex.size.x : 29;
        
        return false;
    }

    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        exploded = true;
        ticks = 0;
        //pos = contactPoint;
        angle = atan2(contactNormal.y, contactNormal.x);
        deltaAngle = angle;
        vel = other.vel;
        drawTex = hitAnim ? hitAnim.getFrame(ticks) : null;

        S_StartSound("bro/laserhit", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);

        return hitAnim == null;
    }

    override void draw(double tm, Vector2 camPos, double scale) {
        pEmitter.draw(tm, campos, scale);
        Super.draw(tm, camPos, scale);
    }
}


class SpaceBroNuke : SpaceBroProjectile {
    bool nukeStarted;
    UITexture pTexture, nTexture;

    SpaceBroNuke init(Vector2 pos = (0,0), Vector2 vel = (0,0), double angle = 0, double size = 6, int damage = 1, double speed = 3) {
        Super.init(pos, vel, angle, size);
        pEmitter = new("BroDeathSmokeEmitter").init();

        drawSize = 29;
        life = 35;
        self.damage = 100;
        self.vel = VecFromAngle(angle, 3);// + vel;
        mass = 9999999999;

        canDisplace = false;

        pTexture = UITexture.Get("BROBOMB1");
        nTexture = UITexture.Get("BRONUKEB");
        
        return self;
    }


    override bool tick() {
        SpaceBroObj.tick();

        if(ticks > life && !nukeStarted) {
            nukeStarted = true;
            ticks = 0;
            vel = (0,0);
        }

        deltaPos = pos;
        pos += vel;

        pEmitter.tick();

        if(!nukeStarted) {
            if(pEmitter && ticks % 3 == 0) {
                Vector2 dir = vel.unit();
                pEmitter.pos = pos;
                pEmitter.angle = angle;
                pEmitter.vel = vel;
                pEmitter.emit(
                    (frandom(-1, 1), -10),  // pos
                    (0,0),                  // vel
                    -frandom(1.9, 2),       // speed
                    frandom(-2, 2),         // emitangle
                    lifetime: random[brop](15, 20),
                    size: (15,15)
                );
            }

            drawTex = pTexture;
            drawSize = drawTex ? drawTex.size.x : 29;
        } else {
            angle = deltaAngle = 0;
            drawTex = nTexture;
            drawSize = MIN(ticks * 32, 600);
            size = MIN(ticks * 32, 600);

            if(ticks > 35) {
                return true;
            }
        }
        
        return false;
    }


    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        if(!nukeStarted) {
            nukeStarted = true;
            ticks = 0;
            angle = atan2(contactNormal.y, contactNormal.x);
            deltaAngle = angle;
            drawTex = hitAnim ? hitAnim.getFrame(0) : null;

            S_StartSound("bro/laserhit", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);
        }

        vel = (0,0);

        return false;
    }


    override void draw(double tm, Vector2 camPos, double scale) {
        pEmitter.draw(tm, campos, scale);
        Super.draw(tm, camPos, scale);
    }
}


class SpaceBroAlienProjectile : SpaceBroProjectile {
    SpaceBroAlienProjectile init(Vector2 pos = (0,0), Vector2 vel = (0,0), double angle = 0, double size = 10, int damage = 1) {
        Super.init(pos, vel, angle, size);

        drawSize = 10;
        life = 55;
        self.damage = 1;
        self.vel = VecFromAngle(angle, 5) + vel;
        mass = 9999999999;

        canDisplace = false;

        drawTex = UITexture.Get("BROALLAS");
        
        return self;
    }


    override bool tick() {
        SpaceBroObj.tick();

        if(ticks > life && !exploded) {
            return true;
        } else if(exploded && (!hitAnim || hitAnim.frames.size() <= ticks / hitAnim.frameTime)) {
            return true;
        }

        if(exploded) {
            drawTex = hitAnim ? hitAnim.getFrame(ticks) : null;
        }

        deltaPos = pos;
        pos += vel;


        return false;
    }


    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        if(!exploded) {
            ticks = 0;
            angle = atan2(contactNormal.y, contactNormal.x);
            deltaAngle = angle;
            exploded = true;
            deltaPos = pos = (0,0);
            vel = other.vel;

            drawTex = hitAnim ? hitAnim.getFrame(0) : null;

            S_StartSound("bro/laserhit", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);
        }

        return false;
    }


    override void draw(double tm, Vector2 camPos, double scale) {
        if(exploded) {
            overlayColor = 0;
        } else {
            overlayColor = UIMath.LerpC(0x00000000, 0xFF000000, MAX(0, (ticks - 20) / double(life - 20)));
        }

        Super.draw(tm, camPos, scale);
    }
}



class SpaceBroMissile : SpaceBroProjectile {
    UITexture pTexture;
    double speed;
    Vector2 targetPos;

    SpaceBroMissile init(Vector2 pos = (0,0), Vector2 vel = (0,0), double angle = 0, double size = 6, int damage = 1, double speed = 3) {
        Super.init(pos, vel, angle, size);
        pEmitter = new("BroDeathSmokeEmitter").init();

        drawSize = 16;
        life = 120;
        self.damage = 5;
        self.vel = VecFromAngle(angle, speed);
        self.speed = speed;
        mass = 10;

        canDisplace = false;

        pTexture = UITexture.Get("BROBOMB2");
        
        return self;
    }

    SpaceBroObj findTarget() {
        let world = BroWorld.Find();

        // Look for aliens first
        SpaceBroObj closest;
        double closestDist;
        for(int x = 0; x < world.aliens.size(); x++) {
            if(world.aliens[x].pos.y < -1080) continue;
            double dist = lengthSquared(world.aliens[x].pos - pos);

            if(!closest) {
                closest = world.aliens[x];
                closestDist = dist;
                continue;
            }
            
            if(closestDist > dist) {
                closest = world.aliens[x];
                closestDist = dist;
            }
        }

        // Find roids if no alien
        if(!closest) {
            for(int x = 0; x < world.roids.size(); x++) {
                if(world.roids[x].pos.y < -1080) continue;
                double dist = lengthSquared(world.roids[x].pos - pos);

                if(!closest) {
                    closest = world.roids[x];
                    closestDist = dist;
                    continue;
                }
                
                if(closestDist > dist) {
                    closest = world.roids[x];
                    closestDist = dist;
                }
            }
        }

        return closest;
    }


    void turnToTarget() {
        let dirToTarget = (targetPos - pos).unit();
        let angleToTarget = atan2(dirToTarget.y, dirToTarget.x);
        let tang = Actor.Normalize180(angleToTarget);
        let mang = Actor.Normalize180(angle);

        mang += clamp(tang - mang, -5.0, 5.0);
        vel = VecFromAngle(mang, speed);
        deltaAngle = angle;
        angle = mang;
    }


    override bool tick() {
        SpaceBroObj.tick();

        if(ticks > life && !exploded) {
            return true;
        } else if(exploded && (!hitAnim || hitAnim.frames.size() <= ticks / hitAnim.frameTime)) {
            return true;
        }

        if(exploded) {
            drawTex = hitAnim ? hitAnim.getFrame(ticks) : null;
            return false;
        }

        if(ticks % 3 == 0) {
            SpaceBroObj target = findTarget();
            if(target) targetPos = target.pos;
        }

        if(!(targetPos ~== (0,0)) && ticks > 12) {
            turnToTarget();
        }

        deltaPos = pos;
        pos += vel;
        /*let dir = vel.unit();
        deltaAngle = angle;
        angle = atan2(dir.y, dir.x) - 90.0;*/
        
        pEmitter.tick();

        if(pEmitter && ticks % 2 == 0) {
            Vector2 dir = vel.unit();
            pEmitter.pos = pos;
            pEmitter.angle = angle;
            pEmitter.vel = vel * 0.75;
            pEmitter.emit(
                (frandom(-1, 1), -10),  // pos
                (0,0),                  // vel
                -frandom(1.9, 2),       // speed
                frandom(-2, 2),         // emitangle
                lifetime: random[brop](15, 20),
                size: (8,8)
            );
        }

        drawTex = pTexture;
        drawSize = 16;//drawTex ? drawTex.size.x : 16;
        
        return false;
    }


    override bool onCollide(SpaceBroObj other, Vector2 contactPoint, Vector2 contactNormal) {
        if(!exploded) {
            ticks = 0;
            angle = atan2(contactNormal.y, contactNormal.x);
            deltaAngle = angle;
            exploded = true;
            deltaPos = pos = (0,0);
            vel = other.vel;

            drawTex = hitAnim ? hitAnim.getFrame(0) : null;

            S_StartSound("bro/laserhit", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME);
        }

        vel = (0,0);

        return false;
    }


    override void draw(double tm, Vector2 camPos, double scale) {
        pEmitter.draw(tm, campos, scale);
        Super.draw(tm, camPos, scale);
    }
}