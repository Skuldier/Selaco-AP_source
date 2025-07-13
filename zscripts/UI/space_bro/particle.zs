class Broticle {
    Vector2 pos, size, vel;
    Vector2 deltaPos, deltaSize;
    double angle, deltaAngle, angVel;
    int ticks, lifetime, spec1, spec2;
    TextureID tex;

    bool tick() {
        deltaPos = pos;
        deltaAngle = angle;
        pos += vel;
        angle += angVel;
        ticks++;

        return ticks > lifetime;
    }
}


class SpaceBroEmitter : SpaceBroObj {
    Array<Broticle> particles;
    TextureID ptex;

    SpaceBroEmitter init(Vector2 pos = (0,0)) {
        Super.init(pos, angle: 0, size: 0);

        //ptex = TexMan.CheckForTexture("BROASTR0");

        return self;
    }

    Broticle emit(Vector2 pos, Vector2 vel, double speed, double emitAngle, int lifetime = 30, Vector2 size = (16, 16), double angle = -999, double angVel = 0) {
        // TODO: Recycle broticle!
        let p = new("Broticle");
        p.pos = self.pos;
        p.size = size;
        p.angle = angle == -999 ? emitAngle + self.angle : angle + self.angle;
        p.deltaAngle = p.angle;
        p.lifetime = lifetime;
        p.angVel = angVel;

        emitAngle += self.angle;

        p.pos += rot(pos, emitAngle);
        p.vel = (Actor.AngleToVector(emitAngle) * speed) + vel + self.vel;
        p.deltaPos = p.pos - p.vel;
        p.tex = ptex;

        particles.push(p);

        return p;
    }

    override bool tick() {
        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];
            if(tickParticle(p)) {
                // TODO: Recycle particle
                particles.delete(x);
                p.destroy();
            }
        }

        ticks++;
        return false;
    }

    static clearscope Vector2 rot(Vector2 p, double angle) {
        angle -= 90;
        let cosa = cos(angle);
        let sina = sin(angle);

        return ( p.x * cosa - p.y * sina, 
                 p.x * sina + p.y * cosa );
    }

    virtual bool tickParticle(Broticle p) {
        return p.tick();
    }

    override void draw(double tm, Vector2 camPos, double scale) {
        if(!shape) {
            shape = BroWorld.Find().recycler.getShape();
            int vc = 0;
            Shape2DHelper.AddQuad(shape, (-0.5, -0.5), (1, 1), (0,0), (1,1), vc);
        }

        if(!transform) {
            transform = new("Shape2DTransform");
        }

        drawParticles(tm, camPos, scale);
    }


    virtual void drawParticles(double tm, Vector2 camPos, double scale) {
        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];
            if(p.ticks < 1) continue;
            let langle = UIMath.Lerpd(p.deltaAngle, p.angle, tm);
            let lpos = UIMath.Lerpv(p.deltaPos, p.pos, tm);

            transform.clear();
            transform.scale((scale * p.size.x, scale * p.size.y));
            transform.rotate(langle);
            transform.translate(((Screen.GetWidth(), Screen.GetHeight()) / 2.0) + ((lpos - camPos) * scale));
            shape.setTransform(transform);

            Screen.DrawShape(p.tex,
                true, shape,
                DTA_Alpha, alpha
            );
        }
    }
}


// Fire/Smoke emitter for engine trails
class BroSmokeEmitter : SpaceBroEmitter {
    TextureID frames[6];

    BroSmokeEmitter init(Vector2 pos = (0,0)) {
        Super.init(pos);

        frames[0] = TexMan.CheckForTexture("BROFIRE0");
        frames[1] = TexMan.CheckForTexture("BROFIRE1");
        frames[2] = TexMan.CheckForTexture("BROFIRE2");
        frames[3] = TexMan.CheckForTexture("BROFIRE3");
        frames[4] = TexMan.CheckForTexture("BROFIRE4");
        frames[5] = TexMan.CheckForTexture("BROFIRE5");

        return self;
    }

    override bool tickParticle(Broticle p) {
        let a = p.tick();
        
        p.vel *= 0.95;

        return a;
    }

    override void drawParticles(double tm, Vector2 camPos, double scale) {
        let screenSize2 = (Screen.GetWidth(), Screen.GetHeight()) / 2.0;

        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];
            //if(p.ticks < 1) continue;
            let langle = UIMath.Lerpd(p.deltaAngle, p.angle, tm);
            let lpos = UIMath.Lerpv(p.deltaPos, p.pos, tm);

            transform.clear();
            transform.scale((scale * p.size.x, scale * p.size.y));
            transform.rotate(langle);
            transform.translate(screenSize2 + ((lpos - camPos) * scale));
            shape.setTransform(transform);

            double ftm = double(p.ticks) / double(p.lifetime);
            let tex = frames[ round( ftm * (frames.size() - 1)) ];
            let col = UIMath.LerpC(p.spec1 == 0 ? 0xFFFFFFFF : p.spec1, 0xFF000000, ftm);

            Screen.DrawShape(tex,
                true, shape,
                DTA_Alpha, alpha,
                DTA_Color, col,
                DTA_Desaturate, int(floor(ftm * 0.75 * 255))
            );
        }
    }
}


// Particle emitter for projectile trails
class BroProjectileEmitter : SpaceBroEmitter {
    BroProjectileEmitter init(Vector2 pos = (0,0)) {
        Super.init(pos);

        return self;
    }

    override bool tickParticle(Broticle p) {
        let a = p.tick();
        
        //p.vel *= 0.90;

        return a;
    }

    override void drawParticles(double tm, Vector2 camPos, double scale) {
        // We only need to clip the right-bottom edge for some reason
        int cx, cy, cw, ch;
        [cx, cy, cw, ch] = Screen.GetClipRect();
        let screenSize2 = (Screen.GetWidth(), Screen.GetHeight()) / 2.0;

        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];

            //let langle = UIMath.Lerpd(p.deltaAngle, p.angle, tm);
            if(p.ticks < 1) continue;
            let lpos = UIMath.Lerpv(p.deltaPos, p.pos, tm);
            double ftm = double(p.ticks) / double(p.lifetime);
            Vector2 pos = screenSize2 + ((lpos - camPos) * scale);
            Vector2 size = p.size * scale;

            if(pos.x > cx + cw || pos.y > cy + ch || pos.x + size.x < cx || pos.y + size.y < cy) { continue; }
            
            let col = UIMath.LerpC(p.spec1 == 0 ? 0xFF5EAACA : p.spec1, 0xFF4A4550, ftm);
            
            Screen.Dim(
                col,
                1.0,
                int(round(pos.x - (size.x / 2.0))),
                int(round(pos.y - (size.y / 2.0))),
                MAX(1, int(round(size.x))),
                MAX(1, int(round(size.y)))
            );
        }
    }
}


// Emitter for explosions!
class BroSplosionEmitter : SpaceBroEmitter {
    TextureID frames[9];

    BroSplosionEmitter init(Vector2 pos = (0,0)) {
        Super.init(pos);

        frames[0] = TexMan.CheckForTexture("BROEXPL1");
        frames[1] = TexMan.CheckForTexture("BROEXPL2");
        frames[2] = TexMan.CheckForTexture("BROEXPL3");
        frames[3] = TexMan.CheckForTexture("BROEXPL4");
        frames[4] = TexMan.CheckForTexture("BROEXPL5");
        frames[5] = TexMan.CheckForTexture("BROEXPL6");
        frames[6] = TexMan.CheckForTexture("BROEXPL7");
        frames[7] = TexMan.CheckForTexture("BROEXPL8");
        frames[8] = TexMan.CheckForTexture("BROEXPL9");

        return self;
    }

    override bool tickParticle(Broticle p) {
        let a = p.tick();
        
        p.vel *= 0.8;

        return a;
    }

    override void drawParticles(double tm, Vector2 camPos, double scale) {
        let screenSize2 = (Screen.GetWidth(), Screen.GetHeight()) / 2.0;

        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];
            //if(p.ticks < 1) continue;
            let langle = UIMath.Lerpd(p.deltaAngle, p.angle, tm);
            let lpos = UIMath.Lerpv(p.deltaPos, p.pos, tm);

            transform.clear();
            transform.scale((scale * p.size.x, scale * p.size.y));
            transform.rotate(langle);
            transform.translate(screenSize2 + ((lpos - camPos) * scale));
            shape.setTransform(transform);

            double ftm = double(p.ticks) / double(p.lifetime);
            let tex = frames[ round( ftm * (frames.size() - 1)) ];
            

            Screen.DrawShape(tex,
                true, shape,
                DTA_Alpha, alpha
            );
        }
    }
}


// Smoke that trails the player ship
class BroDeathSmokeEmitter : SpaceBroEmitter {
    TextureID frames[4];
    Vector2 anchorPos;

    BroDeathSmokeEmitter init(Vector2 pos = (0,0), Vector2 anchor = (0,0)) {
        Super.init(pos);

        frames[0] = TexMan.CheckForTexture("BROSMOK1");
        frames[1] = TexMan.CheckForTexture("BROSMOK1");
        frames[2] = TexMan.CheckForTexture("BROSMOK2");
        frames[3] = TexMan.CheckForTexture("BROSMOK3");

        return self;
    }

    override bool tickParticle(Broticle p) {
        let a = p.tick();
        
        p.vel *= 0.8;

        return a;
    }

    override void drawParticles(double tm, Vector2 camPos, double scale) {
        let screenSize2 = (Screen.GetWidth(), Screen.GetHeight()) / 2.0;

        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];

            let langle = UIMath.Lerpd(p.deltaAngle, p.angle, tm);
            let lpos = UIMath.Lerpv(p.deltaPos, p.pos, tm);

            transform.clear();
            transform.scale((scale * p.size.x, scale * p.size.y));
            transform.rotate(langle);
            transform.translate(screenSize2 + ((lpos - camPos) * scale));
            shape.setTransform(transform);

            double ftm = double(p.ticks) / double(p.lifetime);
            let tex = frames[ round( ftm * (frames.size() - 1)) ];
            let col = UIMath.LerpC(0xFFFFFFFF, 0xFF000000, ftm);
            
            Screen.DrawShape(tex,
                true, shape,
                DTA_Alpha, alpha,
                DTA_Color, col
            );
        }
    }
}



class BroBigSmokeEmitter : SpaceBroEmitter {
    TextureID frames[9];

    BroBigSmokeEmitter init(Vector2 pos = (0,0)) {
        Super.init(pos);

        frames[0] = TexMan.CheckForTexture("BROPUF01");
        frames[1] = TexMan.CheckForTexture("BROPUF02");
        frames[2] = TexMan.CheckForTexture("BROPUF03");
        frames[3] = TexMan.CheckForTexture("BROPUF04");
        frames[4] = TexMan.CheckForTexture("BROPUF05");
        frames[5] = TexMan.CheckForTexture("BROPUF06");
        frames[6] = TexMan.CheckForTexture("BROPUF07");
        frames[7] = TexMan.CheckForTexture("BROPUF08");
        frames[8] = TexMan.CheckForTexture("BROPUF09");

        return self;
    }

    override bool tickParticle(Broticle p) {
        let a = p.tick();
        
        p.vel *= 0.8;

        return a;
    }

    override void drawParticles(double tm, Vector2 camPos, double scale) {
        let screenSize2 = (Screen.GetWidth(), Screen.GetHeight()) / 2.0;

        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];

            let langle = UIMath.Lerpd(p.deltaAngle, p.angle, tm);
            let lpos = UIMath.Lerpv(p.deltaPos, p.pos, tm);

            transform.clear();
            transform.scale((scale * p.size.x, scale * p.size.y));
            transform.rotate(langle);
            transform.translate(screenSize2 + ((lpos - camPos) * scale));
            shape.setTransform(transform);

            double ftm = double(p.ticks) / double(p.lifetime);
            let tex = frames[ round( ftm * (frames.size() - 1)) ];
            //let col = UIMath.LerpC(0xFFFFFFFF, 0xFF000000, ftm);
            
            Screen.DrawShape(tex,
                true, shape,
                DTA_Alpha, alpha
                //DTA_Color, col
            );
        }
    }
}


// For adding scorch marks to the earth
class BroScorchEmitter : SpaceBroEmitter {
    TextureID img;

    BroScorchEmitter init(Vector2 pos = (0,0)) {
        Super.init(pos);

        img = TexMan.CheckForTexture("BROSCRCH");

        return self;
    }


    override void drawParticles(double tm, Vector2 camPos, double scale) {
        let screenSize2 = (Screen.GetWidth(), Screen.GetHeight()) / 2.0;

        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];

            //let langle = UIMath.Lerpd(p.deltaAngle, p.angle, tm);
            //let lpos = UIMath.Lerpv(p.deltaPos, p.pos, tm);

            transform.clear();
            transform.scale((scale * p.size.x, scale * p.size.y));
            transform.rotate(p.angle);
            transform.translate(screenSize2 + ((p.pos - camPos) * scale));
            shape.setTransform(transform);

            double ftm = double(p.ticks) / double(p.lifetime);
            
            Screen.DrawShape(img,
                true, shape,
                DTA_Alpha, alpha * (1.0 - ftm),
                DTA_Filtering, true
                //DTA_Color, col
            );
        }
    }
}


// Number emitter, emits points counter basically
class BroFontEmitter : SpaceBroEmitter {
    TextureID img;
    Font fnt;
    String suffix;

    BroFontEmitter init(Vector2 pos = (0,0)) {
        Super.init(pos);

        fnt = 'PDA7FONT';
        suffix = "PTS";

        return self;
    }

    override bool tickParticle(Broticle p) {
        let a = p.tick();
        
        p.vel *= 0.8;

        return a;
    }

    override void drawParticles(double tm, Vector2 camPos, double scale) {
        let screenSize = (Screen.GetWidth(), Screen.GetHeight());
        let screenSize2 = screenSize / 2.0;
        let virtualScreenSize = screenSize / scale;
        int zerowidth = fnt.GetCharWidth("0");

        for(int x = particles.size() - 1; x >= 0; x--) {
            let p = particles[x];
            let lpos = UIMath.Lerpv(p.deltaPos, p.pos, tm);
            Vector2 pos = (virtualScreenSize * 0.5) + (lpos - camPos);
            let str = String.Format("%d%s", p.spec1, suffix);
            //double ftm = double(p.ticks) / double(p.lifetime);
            pos.x -= (fnt.stringWidth(str)) / 2.0;
            
            Screen.DrawText(fnt, Font.CR_WHITE, pos.x, pos.y, str,
                    DTA_VirtualWidthF, virtualScreenSize.x, DTA_VirtualHeightF, virtualScreenSize.y,
                    DTA_KeepRatio, true,
                    //DTA_Alpha, a,
                    DTA_Color, 0xFF34CCDD,
                    DTA_Monospace,
                    MONO_CellCenter,
                    DTA_Spacing, zerowidth
            );
        }
    }
}