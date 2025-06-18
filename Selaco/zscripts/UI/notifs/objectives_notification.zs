class ObjectiveNotification : Notification {
    const showTime = 4.0;
    const fadeOutTime = 0.2;
    const fadeInTime = 0.13;
    const mainEndTime = showTime - fadeOutTime;

    override void init(string title, string text, string image, int props) {
        Super.init(title, UIHelper.FilterKeybinds(text), image, props);

        snd = 'ui/getObjective';
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        Vector2 pos = offset + (0, 150);
        double te = time - startTime;
        double imga = te < mainEndTime ? te / fadeInTime : 1.0 - ((te - mainEndTime) / fadeOutTime);

        DrawImgAdvanced(text.length() > 35 ? 'OBJPAD2' : 'OBJPAD', pos, DR_SCREEN_HCENTER | DR_IMG_HCENTER, a: alpha * imga);
        DrawStr('SEL16FONT', title, pos + (0, 12), DR_SCREEN_HCENTER | DR_TEXT_CENTER, a: alpha * imga, monoSpace: false);
        DrawStr('SEL21FONT', text, pos + (0, 43), DR_SCREEN_HCENTER | DR_TEXT_CENTER, a: alpha * imga, monoSpace: false);
    }
}

class ObjectiveCompleteNotification : ObjectiveNotification {
    override void init(string title, string text, string image, int props) {
        Super.init(title, UIHelper.FilterKeybinds(text), image, props);

        snd = 'ui/completeObjective';
    }
}

class SubObjectiveNotification : ObjectiveNotification {
    override void init(string title, string text, string image, int props) {
        Super.init(title, UIHelper.FilterKeybinds(text), image, props);

        snd = 'ui/getSubObjective';
    }
}

class SubObjectiveCompleteNotification : ObjectiveNotification {
    override void init(string title, string text, string image, int props) {
        Super.init(title, UIHelper.FilterKeybinds(text), image, props);

        snd = 'ui/completeSubObjective';
    }
}

// Responsible for drawing the full list of objectives
// TODO: May move this into a HUD element in the future
class ObjectivesNotification : Notification {
    Array<String> objList;

    const showTime = 8;
    const fadeOutTime = 0.2;
    const fadeInTime = 0.2;
    const mainEndTime = showTime - fadeOutTime;
    const objFadeTime = 0.3;
    const objWaitTime = 2.0;
    const objAppearTime = 0.15;
    const objTextAppearTime = 0.25;
    const objColorAppearTime = 2.0;
    const objWaitFadeTime = objFadeTime + objWaitTime;

    override void init(string title, string text, string image, int props) {
        Super.init(title, text, image, props);
    }

    override bool isComplete(double time) {
        return time - startTime > showTime;
    }

    override void start(double time) {
        Super.start(time);

        updateObjectives();
    }

    override void updateStartTime(double time) {
        Super.updateStartTime(time);

        updateObjectives();
    }

    void updateObjectives() {
        /*objList.clear();
        
        // Create the list of objectives
        let os = Objectives.FindObjectives();
        if(os) {
            // Create a list of objectives
            for(int x = 0; x < os.objs.size(); x++) {
                let o = os.objs[x];

                objList.Push(String.Format("%s%s", o.status != Objective.STATUS_ACTIVE ? "\c[DARKGRAY]" : "", o.title));

                // Add sub-objectives
                for(int y = 0; y < o.children.size(); y++) {
                    let child = o.children[y];
                    
                    objList.Push(String.Format("   %s%s", child.status != Objective.STATUS_ACTIVE ? "\c[DARKGRAY]" : "", child.title));
                }
            }
        } else {
            text = "[No Objectives]";
        }*/
    }

    override void draw(Vector2 offset, double time, double tm, double alpha, double scale) {
        double te = time - startTime;
        double globa = (te < mainEndTime ? min(1.0, te / fadeInTime) : 1.0 - ((te - mainEndTime) / fadeOutTime)) * alpha;
        //double posoff = te < mainEndTime ? 1.0 - min(1.0, te / fadeInTime) : (te - mainEndTime) / fadeOutTime;
        
        int totalWidth = MAX(380, ceil(virtualScreenSize.x * 0.2));
        Vector2 pos = offset - (totalWidth + 80, 200);
        //offset + (-380.0 /*+ (posoff * 75.0)*/, -200.0);

        let os = Objectives.FindObjectives();
        if(!os) return;

        Font subFnt = 'PDA18FONT';

        double v = 0;
        for(int x = 0; x < os.objs.size(); x++) {
            let o = os.objs[x];

            if(o.hideOutsideMap && o.mapNum != Level.levelnum) { continue; }

            let xte = o.ticsFinish > 0 && o.ticks > o.ticsFinish + (objWaitFadeTime * TICRATE) ?
                UIMath.EaseInQuadF(max(0, 1.0 - (((double(o.ticks - o.ticsFinish) + tm) * ITICKRATE - objWaitFadeTime) / objFadeTime))) :
                1.0;

            //Color o1color = UIMath.LerpC(0xFFFBC200, 0xFFFFFFFF, o.ticsFinish == 0 ? UIMath.EaseInCubicF(min(1.0, ((double(o.ticks) + tm) * ITICKRATE) / objColorAppearTime)) :  1.0);

            DrawImgAdvanced(o.icon .. (o.status + 1), pos + (-10, v), 
                DR_SCREEN_VCENTER | DR_SCREEN_RIGHT | DR_IMG_RIGHT | DR_IMG_VCENTER | DR_WAIT_READY, 
                a: globa * xte
                //color: o1color
            );
            
            //DrawStr('SEL21FONT', o.title, pos + (0, v - 1), DR_SCREEN_VCENTER | DR_SCREEN_RIGHT | DR_TEXT_VCENTER, a: globa * xte, monoSpace: false, scale: (0.8589, 0.8589));
            int stHeight = ceil( 
                DrawStrMultiline(
                    'SEL21FONT', 
                    o.title, 
                    pos + (0, v - 1), 
                    totalWidth - 55, 
                    flags: DR_SCREEN_VCENTER | DR_SCREEN_RIGHT | DR_TEXT_VCENTER_FIRSTLINE, 
                    //translation: o1color,
                    a: globa * xte, 
                    scale: (1, 1)
                ) 
            );
            
            int lastIconY = v + 19;

            v += (15 + stHeight) * xte;

            // Draw sub-tasks
            if(o.status < Objective.STATUS_COMPLETE || (o.ticks >= o.ticsFinish && o.ticks <= ceil(o.ticsFinish + (objFadeTime * TICRATE)))) {
                double objtm = o.ticsFinish > 0 ?
                    UIMath.EaseInQuadF(max(0, 1.0 - (((double(o.ticks - o.ticsFinish) + tm) * ITICKRATE) / objFadeTime))) :
                    1.0;

                // Premultiply alpha
                //double oa = objtm * globa;
                

                for(int y = 0; y < o.children.size(); y++) {
                    let o2 = o.children[y];
                    let started = o2.ticsFinish == 0;
                    
                    if(o2.hideOutsideMap && o2.mapNum != Level.levelnum) { continue; }
                    
                    double o2tm = o2.ticsFinish == 0 ? min(1.0, ((double(o2.ticks) + tm) * ITICKRATE) / objAppearTime) : clamp(((double(o2.ticks - o2.ticsFinish) + tm) * ITICKRATE) / objAppearTime, 0.0, 1.0);
                    double o2a = globa * UIMath.powd(objtm, y + 1);
                    bool cancelled = o2.status == Objective.STATUS_CANCELLED;

                    Color o2color = UIMath.LerpC(0xFFFBC200, 0xFFFFFFFF, o2.ticsFinish == 0 ? UIMath.EaseInCubicF(min(1.0, ((double(o2.ticks) + tm) * ITICKRATE) / objColorAppearTime)) :  1.0);

                    Clip(0, pos.y + lastIconY - 1, virtualScreenSize.x, virtualScreenSize.y, DR_SCREEN_VCENTER);
                    DrawImgAdvanced('OBJLINE2', pos + (-13, v + 2), 
                        DR_SCREEN_VCENTER | DR_SCREEN_RIGHT | DR_IMG_RIGHT | DR_IMG_BOTTOM | DR_WAIT_READY, 
                        a: o2a
                    );
                    ClearClip();

                    lastIconY = v;

                    DrawImgAdvanced(o2.icon .. (o2.status + 4), pos + (4, v), 
                        DR_SCREEN_VCENTER | DR_SCREEN_RIGHT | DR_IMG_CENTER | DR_WAIT_READY, 
                        a: o2a * o2tm, 
                        scale: UIMath.LerpV((2.5, 2.5), (1.0, 1.0), o2tm),
                        color: o2color
                    );

                    float strHeight = ceil( 
                        DrawStrMultiline(
                            subFnt, 
                            o2.status == Objective.STATUS_ACTIVE ? o2.title.mid(0, int(min(1.0, ((double(o2.ticks) + tm) * ITICKRATE) / objTextAppearTime) * o2.title.length())) : o2.title, 
                            pos + (23, v - 1), 
                            (totalWidth - 55),// * tScale.x, 
                            flags: DR_SCREEN_RIGHT | DR_SCREEN_VCENTER | DR_TEXT_VCENTER_FIRSTLINE, 
                            translation: o2color,
                            a: o2a * (cancelled ? 0.7 : 1) * (o2.ticsFinish == 0 ? o2tm : 1.0), 
                            //scale: UIMath.LerpV((1.8, 1.8), (0.9, 0.9), o2tm)
                            scale: (0.9, 0.9)
                        ) 
                    );
                    v += (strHeight + 15) * objtm;
                }
            }

            v += 10.0 * xte;
        }
    }
}