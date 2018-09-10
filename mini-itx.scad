// Base PCB dimensions
miniitx = [170, 170, 1.57];

// Motherboard mounting hold diameter and offsets (relative to hole c)
miniitx_hole = 3.96;
miniitx_hole_c = [10.16, 6.35];
miniitx_hole_f = [22.86, 157.48];
miniitx_hole_h = [154.94, 0];
miniitx_hole_j = [154.94, 157.48];
extra = 1.0;

// Keepouts on top and bottom of board
miniitx_bottom_keepout = 0.25 * 25.4;

// AM4 Socket specs
am4_holes = [80, 95, 54, 90]; // Center not measured
am4_socket = [40, 40, 7.35]; // Not measured

module motherboard(show_keepouts, socket_holes, socket) {
    area_a_keepout = [27, 15, 170-27-30, 170-15, 57];
    area_b_keepout = [0, 0, 170, 15, 16];
    area_c_keepout = [170-30, 15, 30, 170-15, 38];
    area_d_keepout = [0, 15, 27, 170-15, 39];
    
    difference() {
        union() {
            // The PCB
            color("Green", 1.0) {
                cube(miniitx);
            }
            translate([socket_holes[0]-socket[0]/2, socket_holes[1]-socket[1]/2, miniitx[2]]) {
                color("OldLace", 1.0) {
                    cube(socket);
                }
            }
        }
        
        // Mounting holes for the motherboard
        translate([miniitx_hole_c[0], miniitx_hole_c[1], -extra/2]) {
            cylinder(r = miniitx_hole/2, h = miniitx[2]+extra);
            for (hole = [miniitx_hole_f, miniitx_hole_h, miniitx_hole_j]) {
                translate([hole[0], hole[1], 0]) cylinder(r = miniitx_hole/2, h = miniitx[2]+extra);
            }
        }
        
        // Mounting holes for the CPU cooler
        translate([socket_holes[0], socket_holes[1], -extra/2]) {
            for (i = [-socket_holes[2]/2, socket_holes[2]/2]) {
                for (j = [-socket_holes[3]/2, socket_holes[3]/2]) {
                    translate([i, j, 0]) cylinder(r = miniitx_hole/2, h = miniitx[2]+extra);
                }
            }
        }
    }
        
    color("GreenYellow", 0.25) {
        if (show_keepouts == true) {
            translate([0, 0, -miniitx_bottom_keepout]) cube([miniitx[0], miniitx[1], miniitx_bottom_keepout]);
            
            for (keepout = [area_a_keepout, area_b_keepout, area_c_keepout, area_d_keepout]) {
                translate([keepout[0], keepout[1], miniitx[2]]) {
                    cube([keepout[2], keepout[3], keepout[4]]);
                }
            }
        }
    } 
}

module fan(size, thickness, blades) { 
    $fn = 50;
    
    fan_wall = 1;
    
    color("DarkSlateGray", 1.0) {
        difference() {
            translate([-size/2, -size/2, 0]) {
                
                    cube([size, size, thickness]);
                }
            translate([0, 0, -extra/2]) cylinder(r = size/2-fan_wall, h = thickness + extra);
        }
    }
    
    color("Snow", 1.0) {
        cylinder(r = size/5, h = thickness);
        intersection() {
            for (i = [0:blades]) {
                rotate([0, 0, i*360/blades]) translate([0, -thickness/2, thickness/4]) rotate([-60, 0, 0]) cube([size/2, 1, thickness]);
            }
            cylinder(r = size/2-fan_wall*2, h = thickness);
        }
    }
}

flexatx = [81.5, 40];
flexatx_hole = 3.3;
flexatx_hole_a = [81.5-75.9, 4.1];
flexatx_hole_b = [81.5-75.9, 4.1+31.5];
flexatx_hole_c = [81.5-15.2, 36.5];

module flexatx(length) {
    color("Silver", 1.0) {
        difference() {
            cube([length, flexatx[0], flexatx[1]]);
            
            // Cut out the standard mounting holes
            for (hole = [flexatx_hole_a, flexatx_hole_b, flexatx_hole_c]) {
                translate([-extra, hole[0], hole[1]]) {
                    rotate([0, 90, 0]) cylinder(r = flexatx_hole/2, h = 30);
                }
            }
            translate([-extra, flexatx[0]-52.4-40/2, -extra/2]) cube([15+extra, 40, 40+extra]);
        }
    }
    
    // Add a 40mm fan in the location used by Delta
    translate([0, flexatx[0]-52.4, flexatx[1]/2]) rotate([0, 90, 0]) fan(40, 15, 6);
    
    // IEC C14 placeholder
    color("DarkSlateGray", 1.0) {
        iec = [3, 24, 31];
        translate([-iec[0], flexatx[0]-iec[1]-4.4, 2]) {
            difference() {
                cube(iec);
                translate([-extra/2, 4, 3.5]) cube([2+extra/2, 16, 24]);
            }
        }
    }
}

zotac = [211, 40.41, 125];

pci_bracket_thickness = 0.86;
pci_bracket_hole = 4.42;

module pci_bracket() {
    color("DarkGray", 1.0) {
        // Using the center of the screw hole where it intersects the case as datum
        hole_overhang = 21.59-18.42;
        difference() {
            translate([-5.08, -hole_overhang, 0]) {
                cube([11.43, 18.42, pci_bracket_thickness]);
                translate([-pci_bracket_thickness, 0, -4.56]) cube([pci_bracket_thickness, 18.42, 4.56+pci_bracket_thickness]);
            }
            translate([0, 0, -extra/2]) {
                cylinder(r = pci_bracket_hole/2, h = pci_bracket_thickness+extra);
                translate([-pci_bracket_hole/2, -hole_overhang-extra, -extra]) {
                    cube([pci_bracket_hole, hole_overhang+extra, pci_bracket_thickness+extra*2]);
                }
            }
            translate([-5.08-pci_bracket_thickness-extra/2, -hole_overhang, -2.92]) rotate([225, 0, 0]) cube([pci_bracket_thickness+extra, 3, 3]);
        }
        
        translate([-5.08-pci_bracket_thickness, 0, -112.75]) {
            difference() {
                cube([pci_bracket_thickness, 18.42, 112.75+pci_bracket_thickness]);
                translate([-extra/2, 18.42-2.54, 112.75-3.94+pci_bracket_thickness]) {
                    cube([pci_bracket_thickness+extra, 2.54+extra, 3.94+extra]);
                    rotate([-45, 0, 0]) cube([pci_bracket_thickness+extra, 2.54+extra, 3.94+extra]);
                }
            }
        }
    }
}

module gpu() {
    color("DimGrey", 1.0) {
        cube(zotac);
    }
}

// Generic rectangular heatsink with fins
module heatsink(size, base, fins) {
    translate([-size[0]/2, -size[1]/2, 0]) {
        color("Gainsboro") {
            difference() {
                cube(size);
                for (i = [0:fins-1]) {
                    translate([-extra/2, i*(size[1]-size[1]/fins/3)/fins + size[1]/fins/3, base]) cube([size[0]+extra, 2*size[1]/fins/3, size[2]-base+extra]);
                }
            }
        }
    }
}

cryorig_c7_size = [97, 97, 47+15];

module cryorig_c7() {
    heatsink([cryorig_c7_size[0], cryorig_c7_size[1], cryorig_c7_size[2]-15], 5, 57);
    translate([0, 0, 47]) fan(92, 15, 11);
}

noctua_nh_l12s_size = [146, 128, 70];

module noctua_nh_l12s() {
    translate([0, 0, noctua_nh_l12s_size[2]-20]) heatsink([noctua_nh_l12s_size[0], noctua_nh_l12s_size[1], 20], 0, 80);
    translate([0, 0, noctua_nh_l12s_size[2]-15-20]) fan(120, 15, 9);
    color("Gainsboro") {
        translate([-20, -20, 0]) cube([40, 40, 15]);
    }
}

wall = 3;
cpu_fan_clearance = 10;

module back_to_back() {
    motherboard(false, am4_holes, am4_socket);
    
    translate([am4_holes[0], am4_holes[1], am4_socket[2]+miniitx[2]]) cryorig_c7();

    translate([0, miniitx[1]-flexatx[1], -miniitx_bottom_keepout-wall]) {
        rotate([-90, 0, 0]) flexatx(180);
    }

    translate([0, 0, -miniitx_bottom_keepout-wall]) {
        rotate([-90, 0, 0]) gpu();
    }
}

module traditional() {
    motherboard(false, am4_holes, am4_socket);
    
    translate([am4_holes[0], am4_holes[1], am4_socket[2]+miniitx[2]]) noctua_nh_l12s();

    translate([0, miniitx[1]-flexatx[0], noctua_nh_l12s_size[2]+cpu_fan_clearance+am4_socket[2]+miniitx[2]]) {
        flexatx(180);
    }

    translate([0, 0, 0]) {
        gpu();
    }
}

//traditional();

pci_bracket();