#include "ZScripts/UI/space_bro/projectile.zs"
#include "ZScripts/UI/space_bro/animation.zs"
#include "ZScripts/UI/space_bro/particle.zs"
#include "ZScripts/UI/space_bro/spacebro_obj.zs"
#include "ZScripts/UI/space_bro/player.zs"
#include "ZScripts/UI/space_bro/alien.zs"
#include "ZScripts/UI/space_bro/brosteroid.zs"
#include "ZScripts/UI/space_bro/starfield.zs"
#include "ZScripts/UI/space_bro/item.zs"

class BroCam : SpaceBroObj {
    double shakeAmp;
    double followDiv;

    SpaceBroObj target;

    BroCam init(Vector2 pos = (0,0), SpaceBroObj target = null) {
        Super.init(pos);
        self.target = target;

        followDiv = 6.0;
        
        return self;
    }

    override bool tick() {
        deltaPos = pos;
        shakeAmp = MIN(shakeAmp, 10);
        shakeAmp = MAX(0, shakeAmp - 0.17);

        // Move camera towards the ship or target
        if(target) {
            if(target is 'SpaceBroPlayerShip') {
                // Stay in the play field while gently following the player X
                let targetPos = target.pos;
                targetPos.y = -896;
                pos.y += (targetPos.y - pos.y) / followDiv;
                pos.x += (targetPos.x - pos.x) / 10.0;
                pos.x = clamp(pos.x, -50, 50);
                
            } else {
                pos += (target.pos - pos) / followDiv;
            }
        } else {
            pos += ((0, -896) - pos) / followDiv;
        }
        

        return Super.tick();
    }

    Vector2 getWorldRenderPos(double tm) {
        double ff = (double(ticks) / TICKRATE) + (tm * ITICKRATE);
		Vector2 shake = (PerlinNoise.noise3D(ff * 10.0, 1.0, 1.0), PerlinNoise.noise3D(1.0, ff * 10.0, 1.0)) * (shakeAmp * 4.0);

        return UIMath.LerpV(deltaPos, pos, tm) + shake;
    }
}


class BroWorld ui {
    mixin UIDrawer;

    SpaceBroPlayerShip playerShip;
    SpaceBroStars stars[4];
    SpaceBroEarth earth;
    BroCam camera;
    UITexture minimapBG, earthIcon, roidIcon, lifeIcon, nukeIcon;

    BroFontEmitter fontEmitter;

    Array<SpaceBrosteroid> roids;
    Array<SpaceBroProjectile> projectiles;
    Array<SpaceBroAlienShip> aliens;
    Array<SpaceBroObj> objs;

    UIRecycler recycler;

    bool running, hasGivenDangerWarning, freezeFrame;
    uint ticks, levelTicks, musicStartTicks, endGameTicks, lastRoidTick;
    int score, lives, nukes, level;
    int numRoids;   // How many have spawned this level
    int numRoidsPerLevel;
    int numAliens, numAliensPerLevel;
    int powerupsThisLevel;
    double scoreDisplay;
    double camScroll;

    // Center screen message images
    UITexture message1, message2;
    int message1time, message2time;

    float hurt;

    static const int STARFIELD_COLORS[] = {
        0xFFCCFFCC,
        0xFFFFCCCC,
        0xFFCCCCFF
    };

    static const class<SpaceBroPowerup> POWERUP_CLASSES[]  = {
        'SpaceBroPowerup',
        'SpreadPowerup',
        'MissilePowerup'
    };

    static BroWorld Find() {
        SpaceBroMenu ilikemenu = SpaceBroMenu(Menu.GetCurrentMenu());
        return ilikemenu ? ilikemenu.world : null;
    }

    void addProjectile(SpaceBroProjectile proj) {
        projectiles.push(proj);
    }

    void addSteroid(SpaceBrosteroid roid) {
        roids.push(roid);
    }

    void init() {
        recycler = new("UIRecycler");
        
        stars[0] = new("SpaceBroStars").init(0.05,  "BROSTAR1");
        stars[1] = new("SpaceBroStars").init(0.1,   "BROSTAR0");
        stars[2] = new("SpaceBroStars").init(0.3,   "BROSTAR2");
        stars[3] = new("SpaceBroStars").init(0.9,   "BROSTAR3");

        //startNewGame();

        minimapBG = UITexture.Get("BROMAP");
        earthIcon = UITexture.Get("BROICON1");
        roidIcon = UITexture.Get("BROICON2");
        lifeIcon = UITexture.Get("BROLIFE");
        nukeIcon = UITexture.Get("BRONUKE");

        fontEmitter = new("BroFontEmitter").init();
    }

    // Player died, reset position and camera so they can start over
    void resetPlayer() {
        if(playerShip) {
            playerShip.destroy();
        }

        // Position player ship a reasonable distance from earth
        playerShip = new("SpaceBroPlayerShip").init(
            pos: (0, -150)
        );
        playerShip.angle = -90;

        camera.followDiv = 99999999;
        camera.deltaPos = (0,0);
        camera.pos = (0,0);
        camera.shakeAmp = 0;
        camera.target = playerShip;

        rewind();
    }

    void endGame() {
        // TODO: Something else!
        S_StopSound(8);         // Stops music
        S_StopSound(CHAN_6);    // Stops thrusters
        running = false;
    }

    void pauseGame() {
        S_StopSound(8);
        running = false;
    }

    void resumeGame() {
        S_StopSound(8); // Just in case, don't want overlapping sound
        
        // Resume music roughly where it left off
        if(musicStartTicks <= ticks) {
            let len = S_GetLength("bro/music");
            let pos = SpaceBroObj.loopAngle(double(ticks - musicStartTicks) / double(TICRATE), 0.0, len);
            S_StartSound("bro/music", 8, CHANF_UI | CHANF_LOOPING, SPACE_BRO_VOLUME, pitch: hurt > 0.79 ? 1.1 : 1.0, startTime: pos);
        }
        
        running = true;
    }

    void startNewGame(float difficulty = 0.5) {
        hurt = difficulty;
        ticks = 0;
        levelTicks = 0;
        lastRoidTick = 0;
        running = true;
        score = 0;
        scoreDisplay = 0;
        lives = 3;
        nukes = 1;
        level = 1;
        numAliens = 0;
        numRoidsPerLevel = max(15, int(ceil(level * 5.0 * hurt)));
        numAliensPerLevel = max(4, int(ceil(level * 5.0 * hurt)));
        numRoids = 0;
        endGameTicks = 0;
        hasGivenDangerWarning = false;
        powerupsThisLevel = 0;
        freezeFrame = false;
        camScroll = 0;

        // Position player ship a reasonable distance from earth
        playerShip = new("SpaceBroPlayerShip").init(
            pos: (0, -150)
        );
        playerShip.angle = -90;

        earth = new("SpaceBroEarth").init();
        camera = new("BroCam").init(earth.pos, playerShip);
        camera.followDiv = 99999999;

        // Remove any existing roids
        for(int x = 0; x < roids.size(); x++) {
            roids[x].teardown(recycler);
        }
        roids.clear();

        // Remove projectiles
        for(int x = 0; x < projectiles.size(); x++) {
            projectiles[x].teardown(recycler);
        }
        projectiles.clear();

        // Remove Alien Ships
        for(int x = 0; x < aliens.size(); x++) {
            aliens[x].teardown(recycler);
        }
        aliens.clear();

        // Remove others
        for(int x = 0; x < objs.size(); x++) {
            objs[x].teardown(recycler);
        }
        objs.clear();

        //spawnRoids();

        // Set message
        message1 = UITexture.Get("BRONOTE4");
        message1time = 35 * 3;
    }


    void nextLevel() {
        level++;
        levelTicks = 0;
        lastRoidTick = 0;
        numRoids = 0;
        numAliens = 0;
        numRoidsPerLevel = level % 5 == 0 ? 0 : max(15, int(ceil(level * 5.0 * hurt)));
        numAliensPerLevel = level % 5 == 0 ? 10 : max(4, int(ceil(level * 5.0 * hurt)));
        hasGivenDangerWarning = false;
        hurt = MIN(1.0, hurt + 0.11);
        if(hurt > 0.79) S_SoundPitch(8, 1.1);
        powerupsThisLevel = 0;

        // Notify player of next level
        message2 = UITexture.Get("BRONOTE3");
        message2time = 35 * 3;

        // TODO: Spawn one or two powerups

        //spawnRoids(true);

        EventHandler.SendNetworkEvent("spaceBroLevel", level);
    }

    // After death, rewind level to start over
    void rewind() {
        lastRoidTick = 0;
        //numRoids -= roids.size();
        //roids.clear();
        //aliens.clear();
        
        // Find closest object
        double closest = -1024;
        double closestAlien = -1024;

        for(int x = 0; x < aliens.size(); x++) {
            if(aliens[x].pos.y > closestAlien) {
                closestAlien = aliens[x].pos.y;
            }
        }

        for(int x = 0; x < roids.size(); x++) {
            if(roids[x].pos.y > closest && roids[x].pos.y < -600) {
                closest = roids[x].pos.y;
            }
        }

        closest = -1200 - closest;
        closestAlien = -1200 - closestAlien;

        // Move all objects backwards
        for(int x = 0; x < aliens.size(); x++) {
            aliens[x].pos.y += closestAlien;
        }

        for(int x = 0; x < roids.size(); x++) {
            if(roids[x].sizeClass == 99) {
                // Large roids are too slow to rewind fully, bring them to the edge of the screen and make sure other asteroids are not inside of it
                roids[x].pos.y = min(roids[x].pos.y, -1100);
            } else {
                roids[x].pos.y += closest;
            }
        }

        // Now remove asteroids that overlap
        for(int x = 0; x < roids.size(); x++) {
            let roid = roids[x];
            if(roid.sizeClass == 99) continue;

            for(int y = 0; y < roids.size(); y++) {
                if(y == x) continue;

                if(roid.intersects(roids[y], 5)) {
                    roids.delete(x);
                    roid.destroy();
                    x--;
                    break;
                }
            }
        }
    }

    void setStarfieldColor() {
        stars[1].col = UIMath.LerpC(
            stars[1].col,
            STARFIELD_COLORS[level % STARFIELD_COLORS.size()],
            clamp(levelTicks / 35.0, 0, 1)
        );
    }

    void spawnPowerups(Vector2 pos = (0,0), bool force = false) {
        if(!force && pos == (0,0) && levelTicks % 10) return;
        
        // Always spawn one on the first tick of a new level, except level 1
        if((level > 1 && levelTicks == 0) || (powerupsThisLevel < level / 3 && random(0, 75 - min(level * 3, 40)) == 31) || !(pos ~== (0,0)) || force) {
            let pos = !(pos ~== (0,0)) ? pos : (random(-120, 120), -1100);
            class<SpaceBroPowerup> cls;

            // Pick a random powerup based on level
            cls = POWERUP_CLASSES[random(0,POWERUP_CLASSES.size() - 1)];
            
            // Massage chances a little
            if(cls is 'SpaceBroPowerup' && nukes >= 4) {
                cls = POWERUP_CLASSES[random(1,POWERUP_CLASSES.size() - 1)];
            }

            SpaceBroPowerup pup = SpaceBroPowerup(new(cls));
            pup.init(pos, (0, max(1, double(level) * 0.11)));
            objs.push(pup);

            powerupsThisLevel++;
        }
    }

    void spawnRoids(bool far = false, double pshipAngle = 0) {
        // Determine if we should spawn or not
        if(numRoids >= numRoidsPerLevel) return;

        int baseRoids = clamp(1 + (level / 5), 1, 4);
        if(roids.size() > baseRoids && (ticks % 5 || numRoids >= numRoidsPerLevel || ticks - lastRoidTick < 60)) return;
        if(roids.size() > baseRoids && !(random(0, 100) > (97.0 - (hurt * 4.0)))) return;

        lastRoidTick = ticks;

        // Create new roids, potentially in clusters
        int numRoidClusters = 1;
        //round(frandom(3.0, hurt > 0.499 ? 5.0 : 4.0));
        double earthDist = far ? 1300 : 1200;

        for(int cluster = 0; cluster < numRoidClusters; cluster++) {
            int numClusterRoids = min(numRoidsPerLevel - numRoids, ceil(ceil(hurt * 0.2) * frandom(0.5, 3.5)));
            double clusterAngle = frandom(0, 360);
            double clusterSpeed = 1.6 * UIMath.Lerpd(0.55, 1.75, hurt);

            for(int x = 0; x < numClusterRoids; x++) {
                Vector2 spawnSpot = (frandom(-148, 148), -earthDist);
                int sizeClass = level > 3 && random(0,15) == 2 ? 99 : random[bro](0,2);
                double speed = clusterSpeed;

                // Make sure there is only one huge asteroid
                if(sizeClass == 99) {
                    for(int i = 0; i < roids.size(); i++) {
                        if(roids[i].sizeClass == 99) {
                            sizeClass = random[bro](0,2);
                            break;
                        }
                    }
                } else {
                    speed = clusterSpeed + frandom(0.0, 0.15);
                }

                SpaceBrosteroid roid = new("SpaceBrosteroid").init(spawnSpot + (frandom(-70, 70), x == 0 ? 0 : frandom(-70, 0)), sizeClass, sizeClass == 99 ? 0.4 : speed);
                roid.health += playerShip.spreadUpgrades * 2;

                // Brute Force: Make sure we aren't intersecting with other asteroids, if so choose a new location
                bool success = true;
                for(int tries = 0; tries < 20; tries++) {
                    bool retry = false;

                    for(int y = 0; y < roids.size(); y++) {
                        if(roid.intersects(roids[y], 5)) {
                            retry = true;
                            break;
                        }
                    }

                    if(!retry) {
                        roids.push(roid);
                        numRoids++;
                        break;
                    }

                    roid.init(spawnSpot + (frandom(-70, 70), frandom(-90, 0)), roid.sizeClass, clusterSpeed);
                }
            }

            earthDist += frandom(200, 400);
        }
    }


    void spawnAliens() {
        if(level % 5 == 0 && level != 0) {
            if(ticks % 10 || numAliens >= numAliensPerLevel || (aliens.size() > 3 && !(random(0, 100) > (95.0 - (hurt * 2))))) return;  // Every 5 levels go nuts on aliens
        } else {
            double alienFactor = aliens.size();
            if(ticks % 15 || numAliens >= numAliensPerLevel || !(random(0, 100) > (95.0 - (hurt * 2) + alienFactor))) return;
        }

        let a = new("SpaceBroAlienShip").init((0, -frandom(1150, 1200)) + (frandom(-90, 0), 0));

        // Brute Force: Make sure we aren't intersecting with asteroids, if so choose a new location
        bool success = true;
        for(int tries = 0; tries < 20; tries++) {
            bool retry = false;

            for(int y = 0; y < roids.size(); y++) {
                if(a.intersects(roids[y], 10)) {
                    retry = true;
                    break;
                }
            }

            if(!retry) {
                aliens.push(a);
                numAliens++;
                break;
            }

            a.pos = (0, -frandom(1200, 1400)) + (frandom(-128, 0), 0);
        }
    }


    void tick() {
        if(!running) {
            return;
        }
        
        setStarfieldColor();

        // Run score up
        scoreDisplay += (score - scoreDisplay) / 15.0;
        if(abs(scoreDisplay - score) < 5) scoreDisplay = score; 

        message2time--;
        message1time--;

        // Startup music after player arrives on screen
        if(ticks == 85) {
            S_StopSound(8);
            S_StartSound("bro/music", 8, CHANF_UI | CHANF_LOOPING, SPACE_BRO_MUSIC_VOLUME, pitch: hurt > 0.79 ? 1.1 : 1.0);
            musicStartTicks = ticks;
        }

        // Start moving camera towards player after spawn
        if(playerShip.ticks == 30) {
            camera.followDiv = 300;
        } else if(playerShip.ticks == 70) {
            S_StartSound("bro/respawn", CHAN_AUTO, CHANF_UI, SPACE_BRO_MUSIC_VOLUME, pitch: 1.0);
            camera.followDiv = 6;
        } else if(playerShip.ticks > 80) {
            //camera.target = null;
            // Start scrolling starfield

        }

        // If the earth is dead, set endgame timer and camera position
        if(earth.health <= 0 && endGameTicks == 0) {
            endGameTicks = ticks + 200;
            camera.target = earth;
            camera.followDiv = 40;
            S_StopSound(8);
        } else if(playerShip.exploded && lives <= 0 && endGameTicks == 0) {
            endGameTicks = ticks + 80;
            S_StopSound(8);
        }

        freezeFrame = false;
        if(earth.health > 0) {
            spawnRoids();
            spawnAliens();
            spawnPowerups();

            // Check for asteroids that have passed us and show Earth's demise
            if(endGameTicks == 0) {
                for(int x = 0; x < roids.size(); x++) {
                    if(roids[x].sizeClass >= 1 && roids[x].pos.y >= -192) {
                        freezeFrame = true;
                        camera.target = earth;
                        camera.followDiv = 6;
                        break;
                    }
                }
            }
        }

        // Restore camera if we aren't freezeframing
        if(!freezeFrame && earth.health > 0 && !playerShip.exploded && camera.target != playerShip && playerShip.ticks > 80) {
            camera.target = playerShip;
            camera.followDiv = 6;
        }

        // Tick the cam
        camera.tick();

        // Tick the ship, returns true when it is dead
        if(!freezeframe && playerShip.tick()) {
            lives--;

            if(lives < 0) {
                // TODO: End game!
            } else {
                resetPlayer();
            }
        }

        if(!playerShip.exploded) {
            if(playerShip.ticks > 55) {
                // Tick the roids
                for(int x = 0; x < roids.size(); x++) {
                    if(freezeFrame && roids[x].pos.y < -200) continue;

                    if(roids[x].tick()) {
                        roids[x].teardown(recycler);
                        roids.delete(x);
                        x--;
                    }
                }
            }

            // Tick the projectiles
            if(!freezeFrame) {
                for(int x =0; x < projectiles.size(); x++) {
                    if(projectiles[x].tick()) {
                        projectiles[x].teardown(recycler);
                        projectiles.delete(x);
                        x--;
                    }
                }
            }
        }
        
       
        if(!freezeFrame && !playerShip.exploded && playerShip.ticks > 55) {
            // Tick aliens
            for(int x =0; x < aliens.size(); x++) {
                if(aliens[x].tick()) {
                    aliens[x].teardown(recycler);
                    aliens.delete(x);
                    x--;
                }
            }

            // Tick everything else
            for(int x = 0; x < objs.size(); x++) {
                if(objs[x].tick()) {
                    objs[x].teardown(recycler);
                    objs.delete(x);
                    x--;
                }
            }
        }


        // Tick the earth
        earth.tick();

        // Detect collisions on projectiles vs roids and aliens
        for(int x = 0; x < projectiles.size(); x++) {
            if(projectiles[x].exploded) continue;

            bool projectileDied = false;

            // Special case: Test the alien projectile against the player
            if(projectiles[x] is 'SpaceBroAlienProjectile' && !playerShip.exploded) {
                if(projectiles[x].intersects(playerShip)) {
                    Vector2 contactPos, contactNorm;
                    [contactPos, contactNorm] = SpaceBroObj.Separate(projectiles[x], playerShip, 0, 1);

                    bool pcol = projectiles[x].onCollide(playerShip, contactPos, contactNorm);
                    playerShip.onCollide(projectiles[x], contactPos, -contactNorm);

                    if(pcol) {
                        projectiles[x].teardown(recycler);
                        projectiles.delete(x);
                        x--;
                        projectileDied = true;
                        break;
                    }
                }
            }

            for(int y = 0; y < roids.size(); y++) {
                if(roids[y].exploded) continue;

                if(projectiles[x].intersects(roids[y])) {
                    Vector2 contactPos, contactNorm;
                    [contactPos, contactNorm] = SpaceBroObj.Separate(projectiles[x], roids[y], 0, 1);

                    bool pcol = projectiles[x].onCollide(roids[y], contactPos, contactNorm);
                    bool rcol = roids[y].onCollide(projectiles[x], contactPos, -contactNorm);

                    if(rcol) {
                        roids[y].teardown(recycler);
                        roids.delete(y);
                        y--;
                    }

                    if(pcol) {
                        projectiles[x].teardown(recycler);
                        projectiles.delete(x);
                        x--;
                        projectileDied = true;
                        break;
                    }
                }
            }

            if(projectileDied) { continue; }

            for(int y = 0; y < aliens.size(); y++) {
                if(aliens[y].exploded) continue;

                if(projectiles[x].intersects(aliens[y])) {
                    Vector2 contactPos, contactNorm;
                    [contactPos, contactNorm] = SpaceBroObj.Separate(projectiles[x], aliens[y], 0, 1);

                    bool pcol = projectiles[x].onCollide(aliens[y], contactPos, contactNorm);
                    bool acol = aliens[y].onCollide(projectiles[x], contactPos, -contactNorm);

                    if(acol) {
                        aliens[y].teardown(recycler);
                        aliens.delete(y);
                        y--;
                    }

                    if(pcol) {
                        projectiles[x].teardown(recycler);
                        projectiles.delete(x);
                        x--;
                        break;
                    }
                }
            }
        }

        // Detect collisions on ship vs roids
        // Do not check for collision until the ship intro is over
        if(playerShip.ticks >= SpaceBroPlayerShip.IntroTicks) {
            for(int y = 0; y < roids.size(); y++) {
                if(roids[y].exploded) continue;

                if(playerShip.intersects(roids[y])) {
                    bool pcol, rcol;
                    
                    [pcol, rcol] = solveCollision(playerShip, roids[y], 0.5);

                    if(rcol) {
                        roids[y].teardown(recycler);
                        roids.delete(y);
                        y--;
                    }

                    if(pcol) {
                        break;
                    }
                }
            }

            for(int y = 0; y < aliens.size(); y++) {
                if(aliens[y].exploded) continue;

                if(playerShip.intersects(aliens[y])) {
                    bool pcol, rcol;
                    
                    [pcol, rcol] = solveCollision(playerShip, aliens[y], 0.8);

                    if(rcol) {
                        aliens[y].teardown(recycler);
                        aliens.delete(y);
                        y--;
                    }

                    if(pcol) {
                        break;
                    }
                }
            }
        }
        

        // Now earth
        if(playerShip.intersects(earth)) {
            solveCollision(playerShip, earth, 0.5);

            // Make sure earth didn't move
            earth.pos = (0,0);
            earth.vel = (0,0);
        }

        // Aliens vs earth
        for(int x = 0; x < aliens.size(); x++) {
            if(aliens[x].exploded) continue;

            if(aliens[x].intersects(earth)) {
                solveCollision(aliens[x], earth, 0.5);
                
                // Make sure earth didn't move
                earth.pos = (0,0);
                earth.vel = (0,0);
            }
        }

        // Objs vs player
        for(int x = 0; x < objs.size(); x++) {
            if(objs[x].intersects(playerShip)) {
                bool pcol, ocol;
                [pcol, ocol] = solveCollision(playerShip, objs[x], 0.5);

                if(ocol) {
                    objs[x].teardown(recycler);
                    objs.delete(x);
                    x--;
                }
            }
        }
        
        bool earthInDanger = false;

        // Detect collisions of roids vs roids (and planet, and enemies)
        for(int x = 0; x < roids.size(); x++) {
            if(roids[x].exploded) continue;

            // Check distance to earth to pop up the warning
            if(!earthInDanger && roids[x].intersects(earth, 400)) {
                earthInDanger = true;
            }

            for(int y = 0; y < roids.size(); y++) {
                if(x == y) { continue; }
                if(roids[y].exploded) continue;

                if(roids[x].intersects(roids[y])) {
                    solveCollision(roids[x], roids[y]);

                    // Only play one collision sound and only if on screen
                    if(roids[x].isMaybeOnScreen() || roids[y].isMaybeOnScreen()) S_StartSound("bro/asshitass", CHAN_AUTO, CHANF_UI, SPACE_BRO_VOLUME, pitch: frandom(0.9, 1.1));
                }
            }

            if(roids[x].intersects(earth)) {
                solveCollision(roids[x], earth, dampy: 0);
                // Just in case
                earth.pos = (0,0);
            }

            /*for(int y = 0; y < aliens.size(); y++) {
                if(aliens[y].exploded) continue;

                if(roids[x].intersects(aliens[y])) {
                    solveCollision(aliens[y], roids[x], 0.5);
                }
            }*/
        }

        // Warn the player if they are too far from earth, that earth is in danger!
        if(!earthInDanger && hasGivenDangerWarning) {
            hasGivenDangerWarning = false;
        } else if(earthInDanger && !hasGivenDangerWarning && earth.health > 0 && !playerShip.intersects(earth, 1500)) {
            hasGivenDangerWarning = true;
            message2 = UITexture.Get("BRONOTE1");
            message2time = 35 * 3;
        }

        fontEmitter.tick();

        levelTicks++;
        ticks++;

        // Check for next level condition
        if(level % 5) {
            if(numRoids >= numRoidsPerLevel && roids.size() == 0 && !playerShip.exploded && earth.health > 0) {
                message1 = UITexture.Get("BRONOTE2");
                message1time = 35 * 3;
                nextLevel();
            }
        } else {
            if(numAliens >= numAliensPerLevel && aliens.size() == 0 && !playerShip.exploded && earth.health > 0) {
                message1 = UITexture.Get("BRONOTE2");
                message1time = 35 * 3;
                nextLevel();
            }
        }


        // Scroll starfield
        bool starfieldMoving = playerShip && playerShip.ticks >= 80 && !freezeFrame;
        if(starfieldMoving) {
            camScroll += playerShip.exploded ? 6.0 : 15.0;
        }
    }


    bool, bool solveCollision(SpaceBroObj objx, SpaceBroObj objy, double dampx = 1.0, double dampy = 1.0) {
        Vector2 contactPos, contactNorm;
        [contactPos, contactNorm] = SpaceBroObj.Separate(objx, objy, objx.mass, objy.mass);

        // Call on-collide funcs here
        bool xcol = objx.onCollide(objy, contactPos, contactNorm);
        bool ycol = objy.onCollide(objx, contactPos, -contactNorm);

        contactNorm = -contactNorm;
        Vector2 tang = (-contactNorm.y, contactNorm.x);
        double shipDotTang = objx.vel.x * tang.x + objx.vel.y * tang.y;
        double roidDotTang = objy.vel.x * tang.x + objy.vel.y * tang.y;
        double shipDotNorm = objx.vel.x * contactNorm.x + objx.vel.y * contactNorm.y;
        double roidDotNorm = objy.vel.x * contactNorm.x + objy.vel.y * contactNorm.y;
        
        double m1 = ((shipDotNorm * (objx.mass - objy.mass) + 2.0f * objx.mass * roidDotNorm) / (objx.mass + objy.mass)) * dampx;
        double m2 = ((roidDotNorm * (objy.mass - objx.mass) + 2.0f * objx.mass * shipDotNorm) / (objx.mass + objy.mass)) * dampy;

        objx.vel = (tang.x * shipDotTang + contactNorm.x * m1, tang.y * shipDotTang + contactNorm.y * m1);
        objy.vel = (tang.x * roidDotTang + contactNorm.x * m2, tang.y * roidDotTang + contactNorm.y * m2);

        return xcol, ycol;
    }

    // TODO: Raycast the entire world
    // Not finished yet because I don't actually need this functionality yet
    /*bool, Vector2, SpaceBroObj raycast(Vector2 origin, Vector2 direction, int flags = 0) {
        // For now just test earth
        

        return false, (0,0), null;
    }*/


    // Offset is in local units, not screen units
    void draw(double tm, double drawScale, double screenScale, Vector2 offset = (0,0)) {
        if(!camera) { return; }

        double ptt = double(playerShip.ticks - 80) + tm;
        bool starfieldMoving = playerShip && playerShip.ticks >= 80 && !freezeFrame;

        let scale = drawScale * screenScale;
        let camScroll = starfieldMoving ? camScroll + tm * (playerShip.exploded ? 6.0 : 15.0) : camScroll;
        Vector2 campos = camera.getWorldRenderPos(tm) - ((offset * screenScale) / scale);
        Vector2 campos2 = campos - (0, camScroll);

        //UIMath.Lerpv(playerShip.deltaPos, playerShip.pos, tm) + (offset / scale);

        // Set clipping for the game window
        double objTM = playerShip.exploded ? 1.0 : tm;

        // Draw the star field
        for(int x = 0; x < 4; x++) {
            stars[x].draw(tm, campos2, scale: scale);
        }

        earth.draw(tm, campos, scale: scale);

        // Draw roids 
        for(int x =0; x < roids.size(); x++) {
            roids[x].draw(objTM, campos, scale: scale);
        }

        // Draw Aliens 
        for(int x =0; x < aliens.size(); x++) {
            aliens[x].draw(objTM, campos, scale: scale);
        }

        // Draw objs
        for(int x =0; x < objs.size(); x++) {
            objs[x].draw(objTM, campos, scale: scale);
        }

        // Draw projectiles 
        for(int x =0; x < projectiles.size(); x++) {
            projectiles[x].draw(objTM, campos, scale: scale);
        }
        
        fontEmitter.draw(tm, campos, scale: scale);

        // Draw the player ship on top of everything
        playerShip.draw(tm, campos, scale: scale);

        

        // Draw the minimap
        // Nope not anymore, this is a different game now
        //if(running) drawMinimap(tm, offset, scale, screenScale);

        // Draw directional icons for nearby objects
        drawIcons(tm, offset * screenScale, scale);


        // Draw the score
        DrawStr('PDA7FONT', "SCORE: " .. BaseStatusBar.FormatNumber(int(scoreDisplay), 9, 9, 2), (-330, -335) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER, 0xFFC2B557, scale: (drawScale,drawScale), filter: false);

        // Draw lives
        for(int x = 0; x < lives; x++) {
            DrawTexAdvanced(lifeIcon.texID, (-330 + (x * 19 * 2), -315) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER, scale: (drawScale,drawScale), filter: false);
        }

        // Draw nukes
        for(int x = 0; x < nukes; x++) {
            DrawTexAdvanced(nukeIcon.texID, (-330 + (x * 19 * 2), -270) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER, scale: (drawScale,drawScale), filter: false);
        }

        // Draw earth health

        // Draw Level
        DrawStr('PDA7FONT', "STAGE " .. level, (330, -335) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_RIGHT, 0xFFC2B557, scale: (drawScale,drawScale), filter: false);

        // Draw messages
        if(message1time >= 0 && message1) {
            DrawTexAdvanced(message1.texID, (0, -140) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_IMG_HCENTER | DR_IMG_BOTTOM, scale: (drawScale,drawScale), filter: false);
        }

        if(message2time >= 0 && message2 && ceil(ticks / 10.0) % 2 == 0 ) {
            DrawTexAdvanced(message2.texID, (0, -100) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_IMG_HCENTER, scale: (drawScale,drawScale), filter: false);
        }

        // Draw Powerups
        int lpos = 0;
        if(playerShip.spreadTime > 0) {
            DrawStr('PDA13FONT', String.Format("%d", playerShip.spreadTime / 35), (330 - 55, 330) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_BOTTOM, 0xFFC2B557, scale: (drawScale,drawScale), filter: false);
            DrawImgAdvanced("BROPWRU2", (330 - 60, 335) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_IMG_RIGHT | DR_IMG_BOTTOM, scale: (drawScale,drawScale), filter: false);
            lpos -= 140;
        }
        
        if(playerShip.missileTime > 0) {
            DrawStr('PDA13FONT', String.Format("%d", playerShip.missileTime / 35), (330 - 55 + lpos, 330) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_BOTTOM, 0xFFC2B557, scale: (drawScale,drawScale), filter: false);
            DrawImgAdvanced("BROPWRU1", (330 - 60 + lpos, 335) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_IMG_RIGHT | DR_IMG_BOTTOM, scale: (drawScale,drawScale), filter: false);
        }
    }


    void drawMinimap(double tm, Vector2 offset, double totalScale, double screenScale) {
        int sizeCols[] = { 0xFFFFFF00, 0xFFFF8000, 0xFFFF0000 };
        let screenPos = (Screen.GetWidth(), Screen.GetHeight()) / 2.0;
        screenPos += (offset * screenScale) + ((-125, 130) * totalScale);
        let mapsizeSquared = 1500 * 1500;

        // 0.75
        Vector2 mapScale = (0.03, 0.0225);

        // Background
        let bgSize = (100, 75) * totalScale;
        screen.DrawTexture(minimapBG.texID, true, 
            screenPos.x - (bgSize.x * 0.5), 
            screenPos.y - (bgSize.y * 0.5),
            DTA_KeepRatio, true,
            DTA_DestWidthF, bgSize.x,
            DTA_DestHeightF, bgSize.y
        );

        // Earth
        Screen.Dim(
            0xFF66FF66,
            0.9,
            int((-2 * totalScale) + screenPos.x),
            int((-2 * totalScale) + screenPos.y),
            MAX(1, int(round(4.0 * totalScale))),
            MAX(1, int(round(4.0 * totalScale)))
        );

        // Roids
        for(int x =0; x < roids.size(); x++) {
            SpaceBrosteroid roid = roids[x];
            let rd = roid.pos.x*roid.pos.x  +  roid.pos.y*roid.pos.y;

            if(rd > mapsizeSquared) {
                continue;
            }
            
            Screen.Dim(
                sizeCols[clamp(roid.sizeClass, 0, 2)],
                0.9,
                int((roid.pos.x * mapScale.x * totalScale) + screenPos.x),
                int((roid.pos.y * mapScale.y * totalScale) + screenPos.y),
                MAX(1, int(round(2.0 * totalScale))),
                MAX(1, int(round(2.0 * totalScale)))
            );
        }

        // Aliens
        for(int x =0; x < aliens.size(); x++) {
            SpaceBroAlienShip a = aliens[x];
            let rd = a.pos.x*a.pos.x  +  a.pos.y*a.pos.y;

            if(rd > mapsizeSquared) {
                continue;
            }
            
            Screen.Dim(
                0xFFFF66FF,
                0.9,
                int((a.pos.x * mapScale.x * totalScale) + screenPos.x),
                int((a.pos.y * mapScale.y * totalScale) + screenPos.y),
                MAX(1, int(round(2.0 * totalScale))),
                MAX(1, int(round(2.0 * totalScale)))
            );
        }


        // Objs
        for(int x = 0; x < objs.size(); x++) {
            SpaceBroObj obj = objs[x];
            let rd = obj.pos.x*obj.pos.x  +  obj.pos.y*obj.pos.y;

            if(rd > mapsizeSquared) {
                continue;
            }
            
            Screen.Dim(
                0xFF66FFFF,
                0.9,
                int((obj.pos.x * mapScale.x * totalScale) + screenPos.x),
                int((obj.pos.y * mapScale.y * totalScale) + screenPos.y),
                MAX(1, int(round(2.0 * totalScale))),
                MAX(1, int(round(2.0 * totalScale)))
            );
        }


        // Player
        let pp = playerShip.pos.x*playerShip.pos.x  +  playerShip.pos.y*playerShip.pos.y;
        if(pp < mapsizeSquared) {
            Screen.Dim(
                0xFFCCCCFF,
                0.9,
                int((playerShip.pos.x * mapScale.x * totalScale) + screenPos.x),
                int((playerShip.pos.y * mapScale.y * totalScale) + screenPos.y),
                MAX(1, int(round(2.0 * totalScale))),
                MAX(1, int(round(2.0 * totalScale)))
            );
        }
        
        // Draw remaining asteroids
        DrawStr('PDA7FONT', "THREATS: " .. roids.size(), (-250, 180) + offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_HCENTER | DR_TEXT_BOTTOM, 0xFFC2B557, scale: (2,2), filter: false);
    }


    void drawIcons(double tm, Vector2 screenOffset, double scale) {
        int sizeCols[] = { 0xFFFFFF00, 0xFFFF8000, 0xFFFF0000 };

        let screenPos = (Screen.GetWidth(), Screen.GetHeight()) * 0.5;
        let cameraWorldPos = camera.getWorldRenderPos(tm);
        let dir = -(cameraWorldPos);
        let dirLen = dir.length();

        // Draw earth
        if(dirLen > 240) {
            dir /= dirLen;

            let eSize = (16, 16) * scale;
            let eOffset = (dir * dirLen);
            eOffset.x = clamp(eOffset.x, -175, 175);
            eOffset.y = clamp(eOffset.y, -175, 175);
            eOffset *= scale;

            let ePos = screenPos + screenOffset + eOffset;
            
            screen.DrawTexture(earthIcon.texID, true, 
                ePos.x - (eSize.x * 0.5), 
                ePos.y - (eSize.y * 0.5),
                DTA_KeepRatio, true,
                DTA_DestWidthF, eSize.x,
                DTA_DestHeightF, eSize.y,
                //DTA_Color, 0xFF6666FF,
                DTA_Alpha, 0.5
            );
        }
    }
}