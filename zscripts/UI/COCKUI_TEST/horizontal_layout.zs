// Provides horizontal layout of subviews and optionally sizes to fit contents
class UIHorizontalLayout : UIViewManager {
    UIHorizontalLayout init(Vector2 pos, Vector2 size) {
        Super.init(pos, size);
        return self;
    }

    // This should be used sparingly and not for extremely large layouts
    override Vector2 calcMinSize(Vector2 parentSize) {
        Vector2 size = minSize;
        Vector2 pad = (padding.left + padding.right, padding.top + padding.bottom);
        Vector2 pSize = (999899, MIN(parentSize.y - pad.y, maxSize.y));
        Vector2 totalSize = (0,0);

        for(int x = 0; x < managedViews.size(); x++) {
            Vector2 s = managedViews[x].calcMinSize(pSize);
            totalSize.x += s.y;
            totalSize.y = MAX(s.y, totalSize.y);
        }

        totalSize += pad;

        return (MIN(MAX(minSize.x, totalSize.x), maxSize.x), MIN(MAX(minSize.y, totalSize.y), maxSize.y));
    }

    override void layout(Vector2 parentScale, double parentAlpha) {
        cScale = (parentScale ~== (0,0) ? calcScale() : (parentScale.x * scale.x, parentScale.y * scale.y));
        cAlpha = (parentAlpha == -1 ? calcAlpha() : parentAlpha) * alpha;

        // Process anchor pins
        processPins();

        frame.size.y -= padding.top + padding.bottom;

        layingOutSubviews = true;

        if(layoutMode == Content_Stretch) {
            // Determine amount of space used for static sized objects
            // And the total proportional weight
            double staticSize = 0;
            double totalSpacing = 0;
            double propoTotal = 0;
            
            for(int i = 0; i < managedViews.size(); i++) {
                if(ignoreHiddenViews && managedViews[i].hidden) continue;

                let managed = managedViews[i];
                managed.layout(cScale, cAlpha, skipSubviews: true);
                managed.frame.pos.y += padding.top;

                double ls = managed.getLayoutWidthAbsolute();
                double lso, propo;
                [propo, lso] = managed.getProportionalWidth();
                
                if(ls == -1) ls = 0;
                if(propo > -1) propoTotal += propo;
                if(lso > -1) ls += lso;
                staticSize += clamp(ls, managed.minSize.x, managed.maxSize.x);

                if(i > 0) totalSpacing += itemSpacing;
            }
            
            double xSpaceAvail = max(0, frame.size.x - staticSize - totalSpacing - (padding.left + padding.right));

            // Layout each view, stretching/squashing proportional views to fit vertically
            for(int i = 0; i < managedViews.size(); i++) {
                if(ignoreHiddenViews && managedViews[i].hidden) continue;
                
                let managed = managedViews[i];
                
                double lso, propo;
                [propo, lso] = managed.getProportionalWidth();

                if(propo > 0) {
                    propo /= propoTotal;
                    managed.frame.size.x = propo * xSpaceAvail;
                    if(lso) managed.frame.size.x += lso;
                    managed.frame.size.x = clamp(managed.frame.size.x, managed.minSize.x, managed.maxSize.x);
                }

                // We skipped subviews before so lay them out now
                managed.layoutSubviews();

                if(developer > 1) managed.backgroundColor = Color(255, random(0, 255), random(127, 255), random(0, 255));
            }
        } else if(layoutMode == Content_SizeParent) {
            // Briefly fudge our height so auto sizing views work
            double oldWidth = frame.size.x;
            frame.size.x = 8888888;

            // Layout managed views
            for(int i = 0; i < managedViews.size(); i++) {
                managedViews[i].layout(cScale, cAlpha);
                managedViews[i].frame.pos.y += padding.top;
            }

            // Restore our fudge.
            frame.size.x = oldWidth;
        } else {
            // Layout managed views
            for(int i = 0; i < managedViews.size(); i++) {
                managedViews[i].layout(cScale, cAlpha);
                managedViews[i].frame.pos.y += padding.top;
            }
        }

        frame.size.y += padding.top + padding.bottom;

        // After laying out managed views we will rearrange them inside our container in order, adding spacing
        // One can only hope none of the subviews actually used horizontal pinning for sizing, otherwise the subviews could be the full height of this container at the time of layout
        double xpos = arrangeManagedViews();
        if(layoutMode == Content_SizeParent) {
            sizeToFitContents(xpos);
        }

        // Now layout subviews
        for(int i = 0; i < unmanagedViews.size(); i++) {
            unmanagedViews[i].layout(cScale, cAlpha);
        }

        requiresLayout = false;
        layingOutSubviews = false;
    }


    double arrangeManagedViews() {
        let xpos = padding.left;
        for(int x = 0; x < managedViews.size(); x++) {
            managedViews[x].frame.pos.x = xpos;
            if(!ignoreHiddenViews || !managedViews[x].hidden) {
                xpos += managedViews[x].frame.size.x + itemSpacing;
                managedViews[x].onAdjustedPostLayout(self);
            }
        }
        return xpos;
    }


    void sizeToFitContents(double contentRight) {
        frame.size.x = MIN(maxSize.x, MAX(contentRight - itemSpacing + padding.right, minSize.x));

        // Check for a HCenter Pin first
        let centerPin = firstPin(UIPin.Pin_HCenter);
        if(centerPin) {
            double center = centerPin.getParentPos(parent.frame.size) * centerPin.value + centerPin.offset;
            frame.pos.x = center - ((frame.size.x * scale.x) / 2.0);
        } else {
            // See if we have a right-pin that overrides the left pin
            let rightPin = firstPin(UIPin.Pin_Right);
            let leftPin = firstPin(UIPin.Pin_Left);
            if(rightPin && (!leftPin || leftPin.priority < rightPin.priority)) {
                // Process the bottom pin
                let right = rightPin.isFactor ? rightPin.getParentPos(parent.frame.size) * rightPin.value + rightPin.offset : rightPin.getParentPos(parent.frame.size) + rightPin.offset;
                frame.pos.x = right - frame.size.x;
            }
        }
    }


    override void layoutChildChanged(UIView subview) {
        if(layingOutSubviews) return;

        // For now just layout();
        layout();
        // TODO: Add more intelligent layout
    }
}