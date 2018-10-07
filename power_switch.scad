include <defaults.scad>;

power_switch_r = 16/2;
power_switch_h = 30;

module power_switch() {
    $fn = 50;
    
    // Body of the switch
    color("Silver", 1.0) {
        translate([0, 0, -power_switch_h]) cylinder(r = power_switch_r, h = power_switch_h);
        difference() {
            cylinder(r = 19/2, h = 1.6);
            cylinder(r = 12/2, h = 2);
        }
        cylinder(r = 10/2, h = 1.7);
    }
    
    // LED ring
    color("OrangeRed", 0.8) {
        difference() {
            cylinder(r = 12/2, h = 1.6);
            cylinder(r = 10/2, h = 2);
        }
    }
}

module power_switch_cutout() {
    $fn = 50;
    
    // Chassis cut-out
    translate([0, 0, -wall-extra/2]) cylinder(r = power_switch_r + 0.2, h = wall+extra);
}

//power_switch();
//% power_switch_cutout();