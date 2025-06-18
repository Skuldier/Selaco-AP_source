// Simple view for showing stat increases
class UpgradeStatView : UIVerticalLayout {
    enum StatLine {
        Stat_Magsize = 0,
        Stat_FireRate,
        Stat_Pellets,
        Stat_Damage,
        Stat_HeadshotDamage,
        Stat_Recoil,
        Stat_Spread,
        Stat_Stabilization,
        Stat_AreaOfEffect,
        Stat_ProjectileSpeed,
        Num_Stats
    }

    UpgradeStatLine lines[Num_Stats];

    UpgradeStatView init() {
        Super.init((0,0), (125, 400));

        setPadding(10, 10, 10, 10);
        
        let bg = new("UIImage").init((0,0), (100, 100), "", NineSlice.Create(WeaponStationGFXPath .. "panel_background5.png", (16,16), (36, 36)));
        bg.pinToParent(-10, -10, 10, 10);
        bg.ignoresClipping = true;
        add(bg);

        for(int x = 0; x < lines.size(); x++) {
            lines[x] = new("UpgradeStatLine").init();
            addManaged(lines[x]);
        }

        ignoreHiddenViews = true;
        layoutMode = UIViewManager.Content_SizeParent;
        pinWidth(130);
        pinHeight(UIView.Size_Min);
        minSize.y = 20 + 20;

        return self;
    }

    void configure(readonly< WeaponUpgrade > upgrade, SelacoWeapon weapon) {
        for(int x = 0; x < lines.size(); x++) {
            lines[x].setValues(upgrade, weapon, x);
        }

        // Nexxtic: Blah blah blah Cockatrice you need to sort these by positive or negative effect, I'm a big butthole ¯\_(ツ)_/¯
        clearManaged(destroy: false);
        for(int x = 0; x < lines.size(); x++) {
            if(!lines[x].valueIsNegative) {
                addManaged(lines[x]);
            }
        }

        for(int x = 0; x < lines.size(); x++) {
            if(lines[x].valueIsNegative) {
                addManaged(lines[x]);
            }
        }


        requiresLayout = true;
        
        // Hide the entire view if there are no lines visible
        for(int x = 0; x < lines.size(); x++) {
            if(!lines[x].hidden) return;
        }
        hidden = true;
    }
}


class WeaponStatLine : UIView {
    UILabel nameLabel, valueLabel, changeLabel;
    int type;
    bool valueIsNegative;

    WeaponStatLine init() {
        Super.init((0,0), (100, 27));
        pinHeight(27);
        minSize.y = 27;
        minSize.x = 80;
        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);

        nameLabel = new("UILabel").init((0,0), (100, 27), "Upgrade Name", "SEL46FONT");
        nameLabel.scaleToHeight(27);
        nameLabel.pinToParent(0,0,-120,0);
        nameLabel.multiline = false;
        add(nameLabel);

        valueLabel = new("UILabel").init((0,0), (100, 27), "100", "SEL46FONT", textAlign: UIView.Align_Right);
        valueLabel.scaleToHeight(27);
        valueLabel.pin(UIPin.Pin_Left, UIPin.Pin_Right, offset: -60);
        valueLabel.pin(UIPin.Pin_Right);
        valueLabel.pin(UIPin.Pin_Top);
        valueLabel.multiline = false;
        add(valueLabel);

        changeLabel = new("UILabel").init((0,0), (100, 27), "", "SEL46FONT", textAlign: UIView.Align_Right);
        changeLabel.scaleToHeight(27);
        changeLabel.pin(UIPin.Pin_Left);
        changeLabel.pin(UIPin.Pin_Right, UIPin.Pin_Right, offset: -60);
        changeLabel.pin(UIPin.Pin_Top);
        changeLabel.multiline = false;
        add(changeLabel);

        return self;
    }

    int multi5(double val) {
        return int(round(val / 5.0)) * 5;
    }

    void setValues(SelacoWeapon weapon, WeaponUpgrade upgrade = null, int type = 0) {
        self.type = type;
        hidden = false;
        readonly< SelacoWeapon > def = GetDefaultByType(weapon.getClass());
        
        switch(type) {
            case UpgradeStatView.Stat_Damage: {
                let diff = weapon.weaponDamage - def.weaponDamage;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_DAMAGE"));
                valueLabel.setText(String.Format("%d", weapon.weaponDamage));
                if(diff != 0) changeLabel.setText(String.Format("\c%s%s%d", diff > 0 ? "d" : "g", diff > 0 ? "+" : "", diff));
                else changeLabel.setText("");
                valueIsNegative = diff < 0;
                break;
            }

            case UpgradeStatView.Stat_HeadshotDamage: {
                if(weapon.weaponHeadshotMultiplier ~== 0 && def.weaponHeadshotMultiplier ~== 0) {
                    hidden = true;
                    return;
                }
                let diff = weapon.weaponHeadshotMultiplier - def.weaponHeadshotMultiplier;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_HEADSHOT"));
                valueLabel.setText(
                    weapon.weaponHeadshotMultiplier > 0 ? 
                        String.Format("\cd+%.0f%%", weapon.weaponHeadshotMultiplier * 100.0) :
                        String.Format("\cg%.0f%%", weapon.weaponHeadshotMultiplier * 100.0)
                );
                valueIsNegative = diff < 0;
                break;
            }
            case UpgradeStatView.Stat_FireRate: {
                if(weapon.weaponFireRate <= 0 && def.weaponFireRate <= 0) {
                    hidden = true;
                    return;
                }
                let diff = weapon.weaponFireRate - def.weaponFireRate;
                let rate = (double(TICKRATE) / double(weapon.weaponFireRate)) * 60.0;
                let diffRate = rate - ((double(TICKRATE) / double(def.weaponFireRate)) * 60.0);
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_FIRERATE"));
                valueLabel.setText(String.Format("%d", multi5(rate)));
                if(diff != 0) changeLabel.setText(String.Format("\c%s%s%d", diff < 0 ? "d" : "g", diff < 0 ? "+" : "", multi5(diffRate)));
                else changeLabel.setText("");
                valueIsNegative = diff > 0;
                break;
            }
            case UpgradeStatView.Stat_Magsize: {
                readonly<Inventory> defAmmo = weapon.ammo2 ? GetDefaultByType(weapon.ammo2.getClass()) : null;
                if(!defAmmo) {
                    hidden = true;
                    return;
                }
                let diff = weapon.ammo2.maxAmount - defAmmo.maxAmount;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_MAGAZINE"));
                valueLabel.setText(String.Format("%d", weapon.ammo2.maxAmount));
                if(diff != 0) changeLabel.setText(String.Format("\c%s%s%d", diff > 0 ? "d" : "g", diff > 0 ? "+" : "", diff));
                else changeLabel.setText("");
                valueIsNegative = diff < 0;
                break;
            }
            case UpgradeStatView.Stat_Pellets: {
                let diff = weapon.weaponPelletAmount - def.weaponPelletAmount;
                if(weapon.weaponPelletAmount <= 0 && def.weaponPelletAmount <= 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_PELLETS"));
                valueLabel.setText(String.Format("%d", weapon.weaponPelletAmount));
                if(diff != 0) changeLabel.setText(String.Format("\c%s%s%d", diff > 0 ? "d" : "g", diff > 0 ? "+" : "", diff));
                else changeLabel.setText("");
                valueIsNegative = diff < 0;
                break;
            }
            case UpgradeStatView.Stat_Recoil: {
                if(def.weaponRecoil <= 0 && weapon.weaponRecoil <= 0) {
                    hidden = true;
                    return;
                }
                let diff = weapon.weaponRecoil - def.weaponRecoil;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_RECOIL"));
                valueLabel.setText(String.Format("%.0f", weapon.weaponRecoil * 1000));
                if(!(diff ~== 0)) changeLabel.setText(String.Format("\c%s%s%.0f", diff > 0 ? "g" : "d", diff > 0 ? "+" : "", diff * 1000));
                else changeLabel.setText("");
                valueIsNegative = diff > 0;
                break;
            }
            case UpgradeStatView.Stat_Spread: {
                if(def.weaponSpread <= 0 && weapon.weaponSpread <= 0) {
                    hidden = true;
                    return;
                }
                let diff = weapon.weaponSpread - def.weaponSpread;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_SPREAD"));
                valueLabel.setText(String.Format("%.0f", weapon.weaponSpread * 100));
                if(!(diff ~== 0)) changeLabel.setText(String.Format("\c%s%s%.0f", diff >= 0.0001 ? "g" : "d", diff > 0 ? "+" : "", diff * 100));
                else changeLabel.setText("");
                valueIsNegative = diff > 0;
                Console.Printf("Weapon spread: %f  Default: %f  Negative: %d", weapon.weaponSpread, def.weaponSpread, valueIsNegative);
                break;
            }
            case UpgradeStatView.Stat_Stabilization: {
                if(def.weaponStabilizationSpeed <= 0 && def.weaponStabilizationSpeed <= 0) {
                    hidden = true;
                    return;
                }
                let diff = weapon.weaponStabilizationSpeed - def.weaponStabilizationSpeed;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_STABILIZATION"));
                valueLabel.setText(String.Format("%.0f", weapon.weaponStabilizationSpeed * 100));
                if(!(diff ~== 0)) changeLabel.setText(String.Format("\c%s%s%.0f", diff >= 1 ? "g" : "d", diff > 0 ? "+" : "", diff * 100));
                else changeLabel.setText("");
                valueIsNegative = diff > 0;
                break;
            }
            case UpgradeStatView.Stat_AreaOfEffect: {
                if(def.weaponAreaOfEffect <= 0 && weapon.weaponAreaOfEffect <= 0) {
                    hidden = true;
                    return;
                }
                let diff = weapon.weaponAreaOfEffect - def.weaponAreaOfEffect;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_AREAOFEFFECT"));
                valueLabel.setText(String.Format("%.0f", weapon.weaponAreaOfEffect));
                if(diff != 0) changeLabel.setText(String.Format("\c%s%s%d", diff > 0 ? "d" : "g", diff > 0 ? "+" : "", diff));
                else changeLabel.setText("");
                valueIsNegative = diff < 0;
                break;
            }

            case UpgradeStatView.Stat_ProjectileSpeed: {
                if(def.weaponProjectileSpeed <= 0 && def.weaponProjectileSpeed <= 0) {
                    hidden = true;
                    return;
                }
                let diff = weapon.weaponProjectileSpeed - def.weaponProjectileSpeed;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_SPEED"));
                valueLabel.setText(String.Format("%d", weapon.weaponProjectileSpeed));
                if(diff != 0) changeLabel.setText(String.Format("\c%s%s%d", diff > 0 ? "d" : "g", diff > 0 ? "+" : "", diff));
                else changeLabel.setText("");
                valueIsNegative = diff < 0;
                break;
            }

            default:
                break;
        }
    }


    void setDefaultValues(readonly<SelacoWeapon> def, int type = 0) {
        hidden = false;

        changeLabel.setText("");
        valueIsNegative = false;

        switch(type) {
            case UpgradeStatView.Stat_Damage: {
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_DAMAGE"));
                valueLabel.setText(String.Format("%d", def.weaponDamage));
                break;
            }
            case UpgradeStatView.Stat_HeadshotDamage: {
                if(def.weaponHeadshotMultiplier <= 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_HEADSHOT"));
                valueLabel.setText(String.Format("+%.0f%%", def.weaponHeadshotMultiplier * 100.0));
                break;
            }
            case UpgradeStatView.Stat_FireRate: {
                if(def.weaponFireRate <= 0) {
                    hidden = true;
                    return;
                }
                let rate = (double(TICKRATE) / double(def.weaponFireRate)) * 60.0;
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_FIRERATE"));
                valueLabel.setText(String.Format("%d", multi5(rate)));
                break;
            }
            case UpgradeStatView.Stat_Magsize: {
                readonly<Inventory> defAmmo = def.ammo2 ? GetDefaultByType(def.ammo2.getClass()) : null;
                if(!defAmmo) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_MAGAZINE"));
                valueLabel.setText(String.Format("%d", defAmmo.maxAmount));
                break;
            }
            case UpgradeStatView.Stat_Pellets: {
                if(def.weaponPelletAmount <= 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_PELLETS"));
                valueLabel.setText(String.Format("%d", def.weaponPelletAmount));
                break;
            }
            case UpgradeStatView.Stat_Recoil: {
                if(def.weaponRecoil <= 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_RECOIL"));
                valueLabel.setText(String.Format("%.0f", def.weaponRecoil * 1000));
                break;
            }
            case UpgradeStatView.Stat_Spread: {
                if(def.weaponSpread <= 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_SPREAD"));
                valueLabel.setText(String.Format("%.0f", def.weaponSpread * 1000));
                break;
            }
            case UpgradeStatView.Stat_Stabilization: {
                if(def.weaponStabilizationSpeed <= 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_STABILIZATION"));
                valueLabel.setText(String.Format("%.0f", def.weaponStabilizationSpeed * 100));
                break;
            }
            case UpgradeStatView.Stat_AreaOfEffect: {
                if(def.weaponAreaOfEffect <= 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_AREAOFEFFECT"));
                valueLabel.setText(String.Format("%.0f", def.weaponAreaOfEffect));
                break;
            }
            case UpgradeStatView.Stat_ProjectileSpeed: {
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_SPEED"));
                valueLabel.setText(String.Format("%d", def.weaponProjectileSpeed));
                break;
            }
            default:
                break;
        }
    }
}


class UpgradeStatLine : UIView {
    UILabel nameLabel, valueLabel;
    int type;
    bool valueIsNegative;

    UpgradeStatLine init() {
        Super.init((0,0), (100, 20));
        pinHeight(20);
        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);

        nameLabel = new("UILabel").init((0,0), (100, 22), "Upgrade Name", "SEL21FONT");
        nameLabel.scaleToHeight(19);
        nameLabel.fontScale.x *= 0.9;
        nameLabel.pinToParent(0,0,-40,0);
        add(nameLabel);

        valueLabel = new("UILabel").init((0,0), (100, 22), "100", "SEL21FONT", textAlign: UIView.Align_Right);
        valueLabel.scaleToHeight(19);
        valueLabel.pin(UIPin.Pin_Left);
        valueLabel.pin(UIPin.Pin_Right);
        valueLabel.pin(UIPin.Pin_Top);
        add(valueLabel);

        return self;
    }

    int multi5(double val) {
        return int(round(val / 5.0)) * 5;
    }

    void setValues(readonly< WeaponUpgrade > upgrade = null, SelacoWeapon weapon = null, int type = 0) {
        hidden = false;
        self.type = type;

        switch(type) {
            case UpgradeStatView.Stat_Damage: {
                if(upgrade.damageMod == 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_DAMAGE"));
                valueLabel.setText(String.Format("\c%s%s%d", 
                    upgrade.damageMod > 0 ? "d" : "g", 
                    upgrade.damageMod > 0 ? "+" : "",
                    upgrade.damageMod
                ));
                valueIsNegative = upgrade.damageMod < 0;
                break;
            }
            case UpgradeStatView.Stat_HeadshotDamage: {
                if(upgrade.headshotMultiplierMod ~== 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_HEADSHOT"));
                valueLabel.setText(String.Format("\c%s%s%.0f%%", 
                    upgrade.headshotMultiplierMod > 0 ? "d" : "g", 
                    upgrade.headshotMultiplierMod > 0 ? "+" : "",
                    upgrade.headshotMultiplierMod * 100.0
                ));
                valueIsNegative = upgrade.headshotMultiplierMod < 0;
                break;
            }
            case UpgradeStatView.Stat_FireRate: {
                if(upgrade.fireRateMod == 0) {
                    hidden = true;
                    return;
                }
                double rate;
                if(weapon) {
                    let newRate = ((double(TICKRATE) / double(weapon.Default.weaponFireRate + upgrade.fireRateMod)) * 60.0);
                    let oldRate = ((double(TICKRATE) / double(weapon.Default.weaponFireRate)) * 60.0);
                    let diff = newRate - oldRate;
                    //let avg = (newRate + oldRate) * 0.5;
                    rate = diff;
                } else {
                    rate = 0;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_FIRERATE"));
                int irate = multi5(rate);
                valueLabel.setText(String.Format("\c%s%s%d%", 
                    irate > 0 ? "d" : "g", 
                    irate < 0 ? "" : "+",
                    irate
                ));

                valueIsNegative = irate < 0;
                break;
            }
            case UpgradeStatView.Stat_Magsize: {
                if(upgrade.magazineSizeMod == 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_MAGAZINE"));
                valueLabel.setText(String.Format("\c%s%s%d", 
                    upgrade.magazineSizeMod > 0 ? "d" : "g", 
                    upgrade.magazineSizeMod > 0 ? "+" : "",
                    upgrade.magazineSizeMod
                ));
                valueIsNegative = upgrade.magazineSizeMod < 0;
                break;
            }
            case UpgradeStatView.Stat_Pellets: {
                if(upgrade.pelletsMod == 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_PELLETS"));
                valueLabel.setText(String.Format("\c%s%s%d", 
                    upgrade.pelletsMod > 0 ? "d" : "g", 
                    upgrade.pelletsMod > 0 ? "+" : "",
                    upgrade.pelletsMod
                ));
                valueIsNegative = upgrade.pelletsMod < 0;
                break;
            }
            case UpgradeStatView.Stat_Recoil: {
                if(upgrade.recoilMod == 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_RECOIL"));
                valueLabel.setText(String.Format("\c%s%s%.0f", 
                    upgrade.recoilMod > 0 ? "g" : "d", 
                    upgrade.recoilMod > 0 ? "+" : "",
                    upgrade.recoilMod * 1000
                ));
                valueIsNegative = upgrade.recoilMod > 0;
                break;
            }
            case UpgradeStatView.Stat_Spread: {
                if(upgrade.spreadMod == 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_SPREAD"));
                valueLabel.setText(String.Format("\c%s%s%.0f", 
                    upgrade.spreadMod > 0 ? "g" : "d", 
                    upgrade.spreadMod > 0 ? "+" : "",
                    upgrade.spreadMod * 100
                ));
                valueIsNegative = upgrade.spreadMod > 0;
                break;
            }
            case UpgradeStatView.Stat_Stabilization: {
                if(upgrade.stabilizationMod == 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_STABILIZATION"));
                valueLabel.setText(String.Format("\c%s%s%.0f", 
                    upgrade.stabilizationMod > 0 ? "d" : "g", 
                    upgrade.stabilizationMod > 0 ? "+" : "",
                    upgrade.stabilizationMod * 100
                ));
                valueIsNegative = upgrade.stabilizationMod < 0;
                break;
            }
            case UpgradeStatView.Stat_AreaOfEffect: {
                if(upgrade.areaOfEffectMod == 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_AREAOFEFFECT"));
                valueLabel.setText(String.Format("\c%s%s%.0f", 
                    upgrade.areaOfEffectMod > 0 ? "d" : "g", 
                    upgrade.areaOfEffectMod > 0 ? "+" : "",
                    upgrade.areaOfEffectMod
                ));
                valueIsNegative = upgrade.areaOfEffectMod < 0;
                break;
            }
            case UpgradeStatView.Stat_ProjectileSpeed: {
                if(upgrade.projectileSpeedMod == 0) {
                    hidden = true;
                    return;
                }
                nameLabel.setText(StringTable.Localize("$UPGRADE_LABEL_SPEED"));
                valueLabel.setText(String.Format("\c%s%s%d", 
                    upgrade.projectileSpeedMod > 0 ? "d" : "g", 
                    upgrade.projectileSpeedMod > 0 ? "+" : "",
                    upgrade.projectileSpeedMod
                ));
                valueIsNegative = upgrade.projectileSpeedMod < 0;
                break;
            }
            default:
                break;
        }
    }
}