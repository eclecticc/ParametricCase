include <defaults.scad>;

port_cutout = [15.1, 7.7];
port = [14.45, 7.00];
port_spacing = (11.84+42.08)/2;
screw_spacing = (56.71+62.80)/2;
screw_r = 3.1/2;
dual_usb_size = [67.5, 40.0, 11.0];

module dual_usb() {
    $fn = 20;
    
    color(c = [0.2, 0.2, 0.2]) {
        difference() {
            translate([-dual_usb_size[0]/2, 0, 0]) cube(dual_usb_size);
            translate([-screw_spacing/2, -1, dual_usb_size[2]/2]) rotate([-90, 0, 0]) cylinder(r = screw_r, h = 10);
            translate([screw_spacing/2, -1, dual_usb_size[2]/2]) rotate([-90, 0, 0]) cylinder(r = screw_r, h = 10);
        }
    }
    color("Silver", 1.0) {
        translate([port_spacing/2, -1, dual_usb_size[2]/2]) {
            translate([-port[0]/2, 0, -port[1]/2]) cube([port[0], 2, port[1]]);
            translate([-port[0]/2-port_spacing, 0, -port[1]/2]) cube([port[0], 2, port[1]]);
        }
    }
}

module dual_usb_cutout() {
    $fn = 20;
    translate([-screw_spacing/2, -wall-extra/2, dual_usb_size[2]/2]) rotate([-90, 0, 0]) cylinder(r = screw_r, h = wall+extra);
    translate([screw_spacing/2, -wall-extra/2, dual_usb_size[2]/2]) rotate([-90, 0, 0]) cylinder(r = screw_r, h = wall+extra);
    translate([port_spacing/2, -wall-extra/2, dual_usb_size[2]/2]) {
        translate([-port[0]/2, 0, -port[1]/2]) cube([port[0], wall+extra, port[1]]);
        translate([-port[0]/2-port_spacing, 0, -port[1]/2]) cube([port[0], wall+extra, port[1]]);
    }
}

//dual_usb();
//% dual_usb_cutout();