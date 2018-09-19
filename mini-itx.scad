// Default PCB thickness for motherboard and GPU
pcb_thickness = 1.57;
// Base PCB dimensions
miniitx = [170, 170, pcb_thickness];

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

// Offset from origin corner of motherboard to the base of the PCI-e card
pci_e_offset = [46.94+10.16, 47.29-45.72+6.35, 114.55-111.15];

// Thickness of case walls
wall = 3;

module motherboard(show_keepouts, socket_holes, socket) {
    area_a_keepout = [27, 15, 170-27-30, 170-15, 57];
    area_b_keepout = [0, 0, 170, 15, 16];
    area_c_keepout = [170-30, 15, 30, 170-15, 38];
    area_d_keepout = [0, 15, 27, 170-15, 39];
    $fn = 20;
    
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
    
    // PCI-e slot
    color("DarkSlateGray", 1.0) {
        translate([pci_e_offset[0]-14.5, pci_e_offset[1]-7.5/2, miniitx[2]]) cube([89.0, 7.5, 11.25]);
    }
    
    // Keepouts for visualization purposes
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

// Uxcell M3 threaded inserts from Amazon
insert_r = 5.3/2;
insert_h = 5.0;

module motherboard_standoff() {
    difference() {
        cylinder(r = (0.4*25.4)/2, h = miniitx_bottom_keepout);
        translate([0, 0, miniitx_bottom_keepout-insert_h]) cylinder(r = insert_r - 0.1, h = insert_h+extra);
    }
}

module motherboard_standoffs() {
    $fn = 50;
    
    // Mounting holes for the motherboard
    translate([miniitx_hole_c[0], miniitx_hole_c[1], 0]) {
        motherboard_standoff();
        for (hole = [miniitx_hole_f, miniitx_hole_h, miniitx_hole_j]) {
            translate([hole[0], hole[1], 0]) motherboard_standoff();
        }
    }
}

motherboard_back_edge = miniitx_hole_c[0]-12.27;
motherboard_back_panel_overhang = 158.75+7.52+6.35-miniitx[1];
motherboard_back_panel_lip = 2.54;
motherboard_back_panel_size = [158.75, 44.45];

module motherboard_back_panel() {
    // Cut-out for the back panel i/o
    translate([-extra/2+motherboard_back_edge-wall, miniitx_hole_c[1]+7.52, -2.24]) {
        cube([extra/2+wall+motherboard_back_edge+39, motherboard_back_panel_size[0], motherboard_back_panel_size[1]]);
        // Thin a 2.54mm area around the i/o down to a typical sheet metal thickness
        translate([0, -motherboard_back_panel_lip, -motherboard_back_panel_lip]) cube([extra/2+wall-1.2, 158.75+motherboard_back_panel_lip*2, 44.45+motherboard_back_panel_lip*2]);
    }
}   

module vent_rectangular(size, pitch, wall) {
    // Adjust the pitch to fit the total size
    fixed_pitch = size[0]/floor(size[0]/pitch);
    
    // Holes for ventilation
    // TODO: Taper the holes to reduce turbulance
    for (x = [-size[0]/2:fixed_pitch:size[0]/2-fixed_pitch]) {
        for (y = [-size[1]/2:fixed_pitch:size[1]/2-fixed_pitch]) {
            translate([x+wall/2, y+wall/2, -15]) cube([fixed_pitch-wall, fixed_pitch-wall, 30]);
        }
    }
}

module vent_circular(r, pitch, wall) {
    $fn = 100;
    
    intersection() {
        vent_rectangular([r*2, r*2], pitch, wall);
        cylinder(r = r, h = 30, center = true);
    }
}

module vent_rounded_rect(r, size, pitch, wall) {
    $fn = 100;
    
    intersection() {
        vent_rectangular(size, pitch, wall);
        cylinder(r = r, h = 30, center = true);
    }
}   

module fan(size, thickness, blades) {
    // Center at base of exhaust side is datum
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

module fan_cutout(size) {
    $fn = 20;
    hole_spacing = size*0.9;
    
    // Hole spacing for standard PC fan sizes
    if (size == 220) {hole_spacing = 170;}
    else if (size == 200) {hole_spacing = 154;}
    else if (size == 140) {hole_spacing = 124.5;}
    else if (size == 120) {hole_spacing = 105;}
    else if (size == 92) {hole_spacing = 83;}
    else if (size == 80) {hole_spacing = 72;}
    else if (size == 70) {hole_spacing = 60;}
    else if (size == 60) {hole_spacing = 50;}
    else if (size == 50) {hole_spacing = 40;}
    else if (size == 40) {hole_spacing = 32;}
    
    vent_rounded_rect(size/2*1.1, [size, size], 10, 2.0);
    
    // Countersunk holes for the fan screws
    for (x = [-hole_spacing/2, hole_spacing/2]) {
        for (y = [-hole_spacing/2, hole_spacing/2]) {
            translate([x, y, 0]) {
                // TODO: verify this dimensions
                cylinder(r = 6.2/2, h = 15);
                translate([0, 0, -1]) cylinder(r1 = 4.0/2, r2 = 6.2/2, h = 1);
                translate([0, 0, -15]) cylinder(r = 4.0/2, h = 15);
            }
        }
    }
}

iec_size = [3, 24, 31];

module iec() {
    // IEC C14 placeholder
    color("DarkSlateGray", 1.0) {
        difference() {
            cube(iec_size);
            translate([-extra/2, 4, 3.5]) cube([2+extra/2, 16, 24]);
        }
    }
}

sfx_size = [100, 125, 63.5];
sfx_hole = 3.3;
sfx_holes = [[6.0, 6.0+113.0], [6.0, 6.0+25.7, 6.0+51.5]];

module sfx() {
    color("Silver", 1.0) {
        difference() {
            $fn = 20;
            
            cube(sfx_size);
            
            // Cut out for the fan
            translate([(sfx_size[0]-92)/2, (sfx_size[1]-92)/2, -extra/2]) cube([92, 92, extra]);
            // Cut out the standard mounting holes
            for (y = sfx_holes[0]) {
                for (z = sfx_holes[1]) {
                    translate([-extra, y, z]) {
                        rotate([0, 90, 0]) cylinder(r = sfx_hole/2, h = 30);
                    }
                }
            }
        }
    }
    
    // Add a 92mm fan in the location used by Silverstone
    translate([sfx_size[0]/2, sfx_size[1]/2, 0]) fan(92, 15, 8);
    
    // IEC C14 placeholder
    translate([-iec_size[0], sfx_size[1]-30+iec_size[2]/2, sfx_size[2]/2-iec_size[1]/2]) {
        rotate([90, 0, 0]) iec();
    }
}

sfx_l_size = [130, 125, 63.5];

module sfx_l() {
    color("Silver", 1.0) {
        difference() {
            $fn = 20;
            
            cube(sfx_l_size);
            
            // Cut out for the fan
            translate([(sfx_l_size[0]-92)/2, (sfx_l_size[1]-92)/2, -extra/2]) cube([92, 92, extra]);
            // Cut out the standard mounting holes
            for (y = sfx_holes[0]) {
                for (z = sfx_holes[1]) {
                    translate([-extra, y, z]) {
                        rotate([0, 90, 0]) cylinder(r = sfx_hole/2, h = 30);
                    }
                }
            }
        }
    }
    
    // Add a 92mm fan in the location used by Silverstone
    translate([sfx_l_size[0]/2, sfx_l_size[1]/2, 0]) fan(92, 15, 8);
    
    // IEC C14 placeholder
    translate([-iec_size[0], sfx_l_size[1]-30+iec_size[2]/2, sfx_l_size[2]/2-iec_size[1]/2]) {
        rotate([90, 0, 0]) iec();
    }
}

module sfx_cutout() {
    // Cut out the standard mounting holes
    for (y = sfx_holes[0]) {
        for (z = sfx_holes[1]) {
            translate([-15, y, z]) {
                rotate([0, 90, 0]) cylinder(r = sfx_hole/2, h = 30);
            }
        }
    }
    
    // Exhaust cutout
    translate([-15, sfx_holes[0][0]+wall+sfx_hole/2, wall]) cube([30, sfx_size[1]-wall*2-sfx_hole-sfx_holes[0][0]*2, sfx_size[2]-wall*2]);
}

flexatx = [81.5, 40];
flexatx_hole = 3.3;
flexatx_hole_a = [81.5-75.9, 4.1];
flexatx_hole_b = [81.5-75.9, 4.1+31.5];
flexatx_hole_c = [81.5-15.2, 36.5];

module flexatx(length) {
    color("Silver", 1.0) {
        difference() {
            $fn = 20;
            
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
    translate([-iec_size[0], flexatx[0]-iec_size[1]-4.4, 2]) {
        iec();
    }
}

module flexatx_cutout(fan) {
    $fn = 20;
    cutout_extra = 0.5;
    
    // Mounting holes
    for (hole = [flexatx_hole_a, flexatx_hole_b, flexatx_hole_c]) {
        translate([-15, hole[0], hole[1]]) {
            rotate([0, 90, 0]) cylinder(r = flexatx_hole/2, h = 30);
        }
    }
    
    // IEC power plug hole
    translate([-15, flexatx[0]-iec_size[1]-4.4-cutout_extra, 2-cutout_extra]) {
        cube([30, iec_size[1]+cutout_extra*2, iec_size[2]+cutout_extra*2]);
    }
    
    // Fan hole
    if (fan == true) {
        $fn = 50;
        
        translate([-15, flexatx[0]-52.4, flexatx[1]/2]) rotate([0, 90, 0]) cylinder(r = 20, h = 30);
    }
}

// Just a little wedge to provide support for the PSU
module psu_ledge() {
    cube_size = 15;
    translate([0, extra, 0]) difference() {
        translate([-cube_size/2, 0, 0]) rotate([-45, 0, 0]) cube([cube_size, cube_size, cube_size], true);
        translate([-cube_size*1.5, -cube_size*1.5, 0]) cube([cube_size*2, cube_size*2, cube_size*2]);
        translate([-cube_size*1.5, 0, -cube_size*1.5]) cube([cube_size*2, cube_size*2, cube_size*2]);
    }
}

// Dimensions including stock fan
corsair_h60_size = [27+25, 152, 120];
corsair_h60_fan = [120, 25];
corsair_h60_fan_offset = 4; // TODO: Need to measure actual offset

// Corsair Hydro H60 all in one CPU cooler
module corsair_h60() {
    fan_thickness = 25;
    color("DarkSlateGray", 1.0) {
        translate([fan_thickness, 0, 0]) {
            cube([corsair_h60_size[0]-fan_thickness, corsair_h60_size[1], corsair_h60_size[2]]);
            
            // Add placeholders for the tubes
            tube_r = 6; // TODO: measure this
            translate([0, corsair_h60_size[1]-tube_r, corsair_h60_size[2]/4]) {
                rotate([0, -90, 0]) cylinder(r = tube_r, h = 50);
                translate([0, 0, corsair_h60_size[2]/2]) rotate([0, -90, 0]) cylinder(r = tube_r, h = 50);
            }
        }
    }
    
    translate([0, corsair_h60_size[1]/2-corsair_h60_fan_offset, corsair_h60_fan[0]/2]) rotate([0, 90, 0]) fan(corsair_h60_fan[0], fan_thickness, 7);
}

pci_bracket_thickness = 0.86;
pci_bracket_hole = 4.42;
pci_bracket_width = 18.42;
pci_bracket_tab_offset = 4.11;
pci_bracket_tab_width = 14.30-pci_bracket_tab_offset;

module pci_bracket() {
    $fn = 20;
    
    color("DarkGray", 1.0) rotate([0, 0, 180]) {
        // Using the center of the screw hole where it intersects the case as datum
        hole_overhang = 21.59-pci_bracket_width;
        difference() {
            translate([-5.08, -hole_overhang, 0]) {
                cube([11.43, pci_bracket_width, pci_bracket_thickness]);
                translate([-pci_bracket_thickness, 0, -4.56]) cube([pci_bracket_thickness, pci_bracket_width, 4.56+pci_bracket_thickness]);
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
                cube([pci_bracket_thickness, pci_bracket_width, 112.75+pci_bracket_thickness]);
                translate([-extra/2, pci_bracket_width-2.54, 112.75-3.94+pci_bracket_thickness]) {
                    cube([pci_bracket_thickness+extra, 2.54+extra, 3.94+extra]);
                    rotate([-45, 0, 0]) cube([pci_bracket_thickness+extra, 2.54+extra, 3.94+extra]);
                }
                
                translate([-extra/2, pci_bracket_tab_offset, 0]) rotate([135, 0, 0]) cube([pci_bracket_thickness+extra, 10, 10]);
                translate([-extra/2, pci_bracket_width-pci_bracket_tab_offset, 0]) rotate([-45, 0, 0]) cube([pci_bracket_thickness+extra, 10, 10]);
            }
        }
        
        translate([-5.08-pci_bracket_thickness, pci_bracket_tab_offset, -120.02]) {
            cube([pci_bracket_thickness, pci_bracket_tab_width, 120.02+pci_bracket_thickness]);
        }
    }
}

pci_bracket_back_edge = -(11.43-5.08);
pci_bracket_right_edge = -pci_bracket_width+2.54;
pci_bracket_slot_extra = 0.1;
pci_bracket_total_width = 21.59;

module pci_bracket_cutout() {
    io_cutout = [12.06, 89.90];
    
    minkowski() {
        pci_bracket();
        cube([pci_bracket_slot_extra*2, pci_bracket_slot_extra*2, pci_bracket_slot_extra*2], true);
    }

    // I/O Cutout
    translate([-15, -2.84-0.35-io_cutout[0], -10.16-io_cutout[1]]) {
        cube([30, io_cutout[0], io_cutout[1]]);
    }
    
    // Slot above the bracket to allow vertical insertion of card
    translate([pci_bracket_back_edge, pci_bracket_right_edge-pci_bracket_slot_extra, 0]) cube([11.43, pci_bracket_total_width+pci_bracket_slot_extra*2-2.54, 50]);
}

pci_e_front_edge = -57.15;
pci_e_cutout_height = 8.25+(111.15-106.65);
pci_e_spacing = 47.29-26.97;
// Transform from pci e card datum to bracket datum
pci_e_to_bracket = [-64.13, 2.84-pcb_thickness, 100.36];

// The tab that the pci bracket screws into
module pci_bracket_holder() {
    $fn = 20;
    
    bottom_wall = 1.0;
    
    translate(pci_e_to_bracket) {
        difference() {
            translate([pci_bracket_back_edge, -pci_e_spacing+pci_bracket_right_edge-pci_bracket_slot_extra, -insert_h-bottom_wall]) cube([11.43, pci_e_spacing+pci_bracket_total_width+pci_bracket_slot_extra*2-2.54, insert_h+bottom_wall]);
            translate([0, 0, -insert_h]) {
                cylinder(r = insert_r - 0.1, h = insert_h+extra);
                translate([0, 0, -bottom_wall-extra/2]) cylinder(r = 1.5, h = bottom_wall+extra);
            }
            translate([0, -pci_e_spacing, -insert_h]) {
                cylinder(r = insert_r - 0.1, h = insert_h+extra);
                translate([0, 0, -bottom_wall-extra/2]) cylinder(r = 1.5, h = bottom_wall+extra);
            }
        }
    }
}


module dual_gpu(length) {
    // Using the bottom center of the notch as the datum
    color("Green", 1.0) {
        difference() {
            translate([pci_e_front_edge, -pcb_thickness/2, 0]) cube([length, pcb_thickness, 111.15]);
            translate([pci_e_front_edge-extra, -pcb_thickness/2-extra/2, 0-extra]) cube([-pci_e_front_edge+extra-12.15, pcb_thickness+extra, pci_e_cutout_height]);
            translate([72.15, -pcb_thickness/2-extra/2, 0-extra]) cube([length-72.15+extra, pcb_thickness+extra, pci_e_cutout_height]);
        }
    }
    
    translate(pci_e_to_bracket) {
        pci_bracket();
        translate([0, -pci_e_spacing, 0]) pci_bracket();
    }
}

module dual_gpu_cutout() {
    slot_extra = 0.1;
    
    translate(pci_e_to_bracket) {
        pci_bracket_cutout();
        translate([0, -pci_e_spacing, 0]) pci_bracket_cutout();
        // Handle the gap between the two brackets, typically one piece on dual slot GPUs
        translate([-(11.43-5.08), -pci_e_spacing, 0]) cube([11.43, pci_e_spacing, 50]);
    }
}

zotac_1080_mini_pcb = [172.48, 110];
zotac_1080_thickness = 40.41;
zotac_1080_mini_length = 35.32+zotac_1080_mini_pcb[0]; // TODO: Needs measurement
zotac_1080_front_fan = 100;
zotac_1080_back_fan = 90;

module zotac_1080_mini() {
    // Brackets and PCB
    dual_gpu(zotac_1080_mini_pcb[0]);
    
    fan_thickness = 15;
    
    // Body
    color("DimGray", 1.0) {
        translate([pci_e_front_edge, -(zotac_1080_thickness-3)+fan_thickness, pci_e_cutout_height]) {
            cube([zotac_1080_mini_length, zotac_1080_thickness-fan_thickness, zotac_1080_mini_pcb[1]]);
        }
    }
    
    // Add the fans
    translate([pci_e_front_edge, -(zotac_1080_thickness-3), pci_e_cutout_height+zotac_1080_mini_pcb[1]/2]) {
        
        translate([zotac_1080_back_fan/2, 0, 0]) rotate([-90, 0, 0]) fan(zotac_1080_back_fan, fan_thickness, 9);
        translate([zotac_1080_back_fan+zotac_1080_front_fan/2, 0, 0]) rotate([-90, 0, 0]) fan(zotac_1080_front_fan, fan_thickness, 8);
    }
}

module zotac_1080_mini_cutout() {
    dual_gpu_cutout();
    
    // Side panel fan cutouts
    translate([pci_e_front_edge+(zotac_1080_back_fan+zotac_1080_front_fan)/2, -(zotac_1080_thickness-3), pci_e_cutout_height+zotac_1080_mini_pcb[1]/2]) {
        rotate([90, 0, 0]) {
            vent_rectangular([zotac_1080_back_fan+zotac_1080_front_fan, zotac_1080_front_fan], 10, 2.0);
        }
    }
    
    translate([pci_e_front_edge+zotac_1080_mini_length, -(zotac_1080_thickness-3)/2+wall, pci_e_cutout_height+zotac_1080_mini_pcb[1]/2]) {
        rotate([0, 90, 0]) {
            vent_rectangular([zotac_1080_front_fan, zotac_1080_thickness-3], 10, 2.0);
        }
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
    translate([noctua_nh_l12s_size[0]/2-66, 0, noctua_nh_l12s_size[2]-20]) heatsink([noctua_nh_l12s_size[0], noctua_nh_l12s_size[1], 20], 0, 80);
    translate([noctua_nh_l12s_size[0]/2-66, 0, noctua_nh_l12s_size[2]-15-20]) fan(120, 15, 9);
    color("Gainsboro") {
        translate([-20, -20, 0]) cube([40, 40, 15]);
    }
}

module noctua_nh_u9s() {
    color("Gainsboro") {
        translate([-47.5, -47.5, 0]) cube([95, 95, 125]);
    }
}

module back_to_back() {
    motherboard(false, am4_holes, am4_socket);
    
    translate([am4_holes[0], am4_holes[1], am4_socket[2]+miniitx[2]]) cryorig_c7();

    translate([0, miniitx[1]-flexatx[1], -miniitx_bottom_keepout-wall]) {
        rotate([-90, 0, 0]) flexatx(180);
    }

    translate([pci_e_offset[0], pci_e_offset[1]+100, -40]) {
        rotate([90, 0, 0]) zotac_1080_mini();
    }
}

module traditional(show_internals, use_sfx) {
    // Airflow clearance for CPU fan
    cpu_fan_clearance = 10;
    heatsink_height = noctua_nh_l12s_size[2];
    gpu_location = [pci_e_offset[0], pci_e_offset[1], pci_e_offset[2]+miniitx[2]];
    
    case_origin = [motherboard_back_edge-wall, -pci_e_spacing*1.5, -miniitx_bottom_keepout-wall];
    case_size = [zotac_1080_mini_length+wall*3, miniitx[1]-case_origin[1]+motherboard_back_panel_overhang+motherboard_back_panel_lip, heatsink_height+cpu_fan_clearance+am4_socket[2]+miniitx[2]+flexatx[1]-case_origin[2]+wall];
    
    sfx_location = [motherboard_back_edge, case_origin[1]+case_size[1]-sfx_size[1]-wall, case_origin[2]+case_size[2]-sfx_size[2]];
    flexatx_location = [motherboard_back_edge, case_origin[1]+case_size[1]-flexatx[0]-wall, heatsink_height+cpu_fan_clearance+am4_socket[2]+miniitx[2]];
    
    // Calculate the case size in liters
    case_volume = case_size[0]*case_size[1]*case_size[2]/1000000.0;
    echo("Case dimensions X:", case_size[0], " Y:", case_size[1], " Z:", case_size[2], " L:", case_volume);
    
    corsair_h60_location = [case_size[0]-wall-corsair_h60_size[0], case_size[1]-wall*2-corsair_h60_size[1], case_size[2]-wall*2-corsair_h60_size[2]];
    case_fan_size = 92;
    case_fan_thickness = 25;
    case_fan_location = [case_size[0]-wall-case_fan_thickness, case_size[1]/2, case_fan_size/2+wall*2];
    case_exhaust_fan_size = 80;
    case_exhaust_fan_thickness = 15;
    case_exhaust_fan_location = [wall, wall+40+case_exhaust_fan_size/2, case_exhaust_fan_size+20];
    
    // Using the bottom corner of the motherboard near the GPU as the origin
    if (show_internals == true) {
        motherboard(false, am4_holes, am4_socket);
        
        translate([am4_holes[0], am4_holes[1], am4_socket[2]+miniitx[2]]) {
            if (!use_sfx) {
                noctua_nh_l12s();
            }
        }

        if (use_sfx) {
            translate(sfx_location) {
                sfx();
            }
        } else {
            translate(flexatx_location) {
                flexatx(150);
            }
            
            // The exhaust fan only fits (sort of) with flexatx
            translate(case_origin)  {
                translate(case_exhaust_fan_location) {
                    rotate([0, 90, 0]) fan(case_exhaust_fan_size, case_exhaust_fan_thickness, 10);
                }
            }
        }

        translate(gpu_location) {
            zotac_1080_mini();
        }
        
        translate(case_origin)  {
            // Currently SFX PSU is tied to needing an AIO cooler
            if (!use_sfx) {
                translate(case_fan_location) {
                    rotate([0, 90, 0]) fan(case_fan_size, case_fan_thickness, 10);
                }
            } else {
                translate(corsair_h60_location) {
                    corsair_h60();
                }
            }
        }
    }
    
    // The actual case
    color("WhiteSmoke", 0.3) {
        // Motherboard standoffs taking threaded inserts
        translate([0, 0, -miniitx_bottom_keepout]) {
            motherboard_standoffs();  
        }
        
        // Part that the GPU screws into
        translate(gpu_location) {
            pci_bracket_holder();
        }
        
        if (use_sfx) {
            translate(sfx_location) {
                translate([sfx_size[0], sfx_size[1], 0]) psu_ledge();
            }
        } else {
            translate(flexatx_location) {
                translate([150, flexatx[0], 0]) psu_ledge();
            }
        }
        
        difference() {
            translate(case_origin) {
                 // Back wall
                cube([wall, case_size[1], case_size[2]]);
                
                // Bottom wall
                cube([case_size[0], case_size[1], wall]);
                
                // Right wall
                translate([0, case_size[1]-wall, 0]) cube([case_size[0], wall, case_size[2]]);
                
                // Left wall
                cube([case_size[0], wall, case_size[2]]);
                
                // Top wall
                translate([0, 0, case_size[2]-wall]) cube([case_size[0], case_size[1], wall]);
                
                // Front wall
                translate([case_size[0]-wall, 0, 0]) cube([wall, case_size[1], case_size[2]]);
            }
            
            translate(case_origin) {
                translate([8, 0.2, 8]) {
                    rotate([90, 0, 0]) linear_extrude(wall) {
                        text(str(case_volume), font = "Helvetica:style=Normal", size = 20);
                    }
                }
            }
                      
            motherboard_back_panel();
            
            if (use_sfx) {
                translate(sfx_location) {
                    sfx_cutout();
                }
                
                back_panel_vent = [case_size[2]-motherboard_back_panel_size[1]-wall*2, case_size[1]-zotac_1080_thickness-sfx_size[1]-wall*2];
                translate(sfx_location) translate([0, -back_panel_vent[1]/2+wall, sfx_size[2]-back_panel_vent[0]/2-wall]) {
                    rotate([0, 90, 0]) vent_rectangular(back_panel_vent, 10, 2.0);
                }
                
                translate(case_origin) translate(corsair_h60_location) translate([corsair_h60_size[0]+wall, corsair_h60_size[1]/2-corsair_h60_fan_offset, corsair_h60_fan[0]/2]) {
                    rotate([0, 90, 0]) {
                        fan_cutout(corsair_h60_fan[0]);
                    }
                }
            } else {
                translate(flexatx_location) {
                    flexatx_cutout();
                }
                
                translate(case_origin) translate([case_exhaust_fan_location[0]-wall, case_exhaust_fan_location[1], case_exhaust_fan_location[2]]) {
                    rotate([0, -90, 0]) {
                        fan_cutout(case_exhaust_fan_size);
                    }
                }
                
                translate(case_origin) translate([case_fan_location[0]+case_fan_thickness+wall, case_fan_location[1], case_fan_location[2]]) {
                    rotate([0, 90, 0]) {
                        fan_cutout(case_fan_size);
                    }
                }
            }
            
            translate(gpu_location) {
                zotac_1080_mini_cutout();
            }
        }
    }
}

module traditional_tower_cooler() {
    motherboard(false, am4_holes, am4_socket);
    
    translate([am4_holes[0], am4_holes[1], am4_socket[2]+miniitx[2]]) noctua_nh_u9s();

    translate([0, miniitx[1]-flexatx[1], flexatx[0]+miniitx[2]+45]) rotate([-90, 0, 0]) {
        flexatx(180);
    }

    translate([pci_e_offset[0], pci_e_offset[1], pci_e_offset[2]+miniitx[2]]) {
        zotac_1080_mini();
    }
}

traditional(show_internals = true, use_sfx = true);
