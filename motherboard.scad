// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2018, Nirav Patel, http://eclecti.cc
//
// Motherboard modules

include <defaults.scad>;

// Base PCB dimensions
miniitx = [170, 170, pcb_thickness];

// Motherboard mounting hold diameter and offsets (relative to hole c)
mounting_hole = 3.96;
miniitx_hole_c = [10.16, 6.35];
miniitx_hole_f = [22.86, 157.48];
miniitx_hole_h = [154.94, 0];
miniitx_hole_j = [154.94, 157.48];

// Keepouts on top and bottom of board
miniitx_bottom_keepout = 0.25 * 25.4;

// AM4 Socket specs
am4_holes = [80, 95, 54, 90]; // Center not measured
am4_socket = [40, 40, 7.35]; // Not measured

// Offset from origin corner of motherboard to the base of the PCI-e card
miniitx_pci_e_offset = [46.94+10.16, 47.29-45.72+6.35, 114.55-111.15];

module motherboard_miniitx(show_keepouts, socket_holes, socket) {
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
        #translate([miniitx_hole_c[0], miniitx_hole_c[1], -extra/2]) {
            cylinder(r = mounting_hole/2, h = miniitx[2]+extra);
            for (hole = [miniitx_hole_f, miniitx_hole_h, miniitx_hole_j]) {
                translate([hole[0], hole[1], 0]) cylinder(r = mounting_hole/2, h = miniitx[2]+extra);
            }
        }

        // Mounting holes for the CPU cooler
        translate([socket_holes[0], socket_holes[1], -extra/2]) {
            for (i = [-socket_holes[2]/2, socket_holes[2]/2]) {
                for (j = [-socket_holes[3]/2, socket_holes[3]/2]) {
                    translate([i, j, 0]) cylinder(r = mounting_hole/2, h = miniitx[2]+extra);
                }
            }
        }
    }

    // PCI-e slot
    color("DarkSlateGray", 1.0) {
        translate([miniitx_pci_e_offset[0]-14.5, miniitx_pci_e_offset[1]-7.5/2, miniitx[2]]) cube([89.0, 7.5, 11.25]);
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

miniitx_motherboard_back_edge = miniitx_hole_c[0]-12.27;
// value for the conncetor I/O, sticking over the edge of the board
miniitx_motherboard_back_panel_overhang = 158.75+7.52+6.35-miniitx[1];
motherboard_back_panel_lip = 2.54;
motherboard_back_panel_size = [158.75, 44.45];

module motherboard_back_panel_cutout() {
    // Cut-out for the back panel i/o
    translate([-extra/2+miniitx_motherboard_back_edge-wall, miniitx_hole_c[1]+7.52, -2.24]) {
        cube([extra/2+wall+miniitx_motherboard_back_edge+39, motherboard_back_panel_size[0], motherboard_back_panel_size[1]]);
        // Thin a 2.54mm area around the i/o down to a typical sheet metal thickness
        translate([0, -motherboard_back_panel_lip, -motherboard_back_panel_lip]) cube([extra/2+wall-1.2, 158.75+motherboard_back_panel_lip*2, 44.45+motherboard_back_panel_lip*2]);
    }
}

// ---------------
// micro ATX stuff
// ---------------
microatx = [244, 244, pcb_thickness];

//microatx_pci_e_offset = [46.94+10.16, 34.29+45.72, 114.55-111.15];
microatx_pci_e_offset = [46.94+10.16, 80, 114.55-111.15];

// AM4 Socket specs
microatx_am4_holes = [80+20, 95+70, 54, 90]; // Center not measured
//microatx_am4_socket = [40, 40, 7.35]; // Not measured

// Motherboard mounting hold diameter and offsets (relative to hole a)
microatx_hole_b = [10.16, 34.29];
microatx_hole_c = [0, 45.72];
microatx_hole_d = [22.86, 203.3];
microatx_hole_e = [154.94, -20.32];
microatx_hole_f = [154.94, 0];
microatx_hole_g = [154.94, 45.72];
microatx_hole_h = [154.94, 203.3];
microatx_hole_i = [227.33, 45.72 ];
microatx_hole_j = [227.33, 203.3];

// Keepouts on top and bottom of board
microatx_bottom_keepout = 0.25 * 25.4;

module motherboard_microatx(show_keepouts, socket_holes, socket) {
    // @todo: rework these --psy
    area_a_keepout = [33, 84, 170-33, 244-84, 80];
    area_b_keepout = [0, 0, 244, 84, 16];
    area_c_keepout = [170, 84, 237.49-165.10,237.49 -80.49, 38.1];
    area_d_keepout = [0, 84, 45, 244-84, 39];
    $fn = 20;

    difference() {
        union() {
            // The PCB
            color("Green", 1.0) {
                cube(microatx);
            }
            // @todo: verify socket positon --psy
            // @todo: needs to be more positiv x
            translate([socket_holes[0]-socket[0]/2, socket_holes[1]-socket[1]/2, microatx[2]]) {
                color("OldLace", 1.0) {
                    cube(socket);
                }
            }
        }

        // Mounting holes for the motherboard
        translate([microatx_hole_b[0], microatx_hole_b[1], -extra/2]) {
            cylinder(r = mounting_hole/2, h = microatx[2]+extra);
            for (hole = [microatx_hole_c, microatx_hole_d, microatx_hole_e, microatx_hole_f, microatx_hole_g, microatx_hole_h, microatx_hole_i, microatx_hole_j]) {
                translate([hole[0], hole[1], 0]) cylinder(r = mounting_hole/2, h = miniitx[2]+extra);
           }
        }

        //Mounting holes for the CPU cooler
        translate([socket_holes[0], socket_holes[1]+70, -extra/2]) {
        for (i = [-socket_holes[2]/2, socket_holes[2]/2]) {
                for (j = [-socket_holes[3]/2, socket_holes[3]/2]) {
                    translate([i, j, 0]) cylinder(r = mounting_hole/2, h = microatx[2]+extra);
                }
           }
        }
    }

    // PCI-e slot
    union() {
        color("DarkSlateGray", 1.0) {
            translate([microatx_pci_e_offset[0]-14.5, microatx_pci_e_offset[1]-7.5/2, microatx[2]]) cube([89.0, 7.5, 11.25]);
            translate([microatx_pci_e_offset[0]-14.5, microatx_pci_e_offset[1]-7.5/2-20.32, microatx[2]]) cube([39.0, 7.5, 11.25]);
            translate([microatx_pci_e_offset[0]-14.5, microatx_pci_e_offset[1]-7.5/2-20.32*2, microatx[2]]) cube([39.0, 7.5, 11.25]);
            translate([microatx_pci_e_offset[0]-14.5, microatx_pci_e_offset[1]-7.5/2-20.32*3, microatx[2]]) cube([89.0, 7.5, 11.25]);
        }
    }

    // Keepouts for visualization purposes
    /* color("GreenYellow", 0.25) { */
    /*     if (show_keepouts == true) { */
    /*         translate([0, 0, -microatx_bottom_keepout]) cube([microatx[0], microatx[1], microatx_bottom_keepout]); */

    /*         for (keepout = [area_a_keepout, area_b_keepout, area_c_keepout, area_d_keepout]) { */
    /*             translate([keepout[0], keepout[1], miniitx[2]]) { */
    /*                 cube([keepout[2], keepout[3], keepout[4]]); */
    /*             } */
    /*         } */
    /*     } */
    /* } */
}

microatx_motherboard_back_edge = microatx_hole_b[0]-12.27;
microatx_motherboard_back_panel_overhang = 34.29+53.24+158.75-microatx[1]; // 172.62-170

module motherboard_microatx_back_panel_cutout() {
    // Cut-out for the back panel i/o
    translate([-extra/2+microatx_motherboard_back_edge-wall, microatx_hole_b[1] + 53.5, -2.24]) {
        cube([extra/2+wall+microatx_motherboard_back_edge+39, motherboard_back_panel_size[0], motherboard_back_panel_size[1]]);
        // Thin a 2.54mm area around the i/o down to a typical sheet metal thickness
        translate([0, -motherboard_back_panel_lip, -motherboard_back_panel_lip]) cube([extra/2+wall-1.2, 158.75+motherboard_back_panel_lip*2, 44.45+motherboard_back_panel_lip*2]);
    }
}

//---------------

/* union() { */
/*     motherboard_miniitx(true, am4_holes, am4_socket); */
/*     //motherboard_back_panel_cutout(); */
/* } */

/* union() { */
/*     translate([0, -250, 0]) { */
/*         motherboard_microatx(true, microatx_am4_holes, am4_socket); */
/*         //motherboard_microatx_back_panel_cutout(); */
/*     } */
/* } */
