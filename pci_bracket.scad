// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2018, Nirav Patel, http://eclecti.cc
//
// PCI card bracket modules

include <defaults.scad>

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
        cube([pci_bracket_slot_extra*2, pci_bracket_slot_extra*4, pci_bracket_slot_extra*2], true);
    }

    // I/O Cutout
    translate([-15, -2.84-0.35-io_cutout[0], -10.16-io_cutout[1]]) {
        cube([30, io_cutout[0], io_cutout[1]]);
    }
    
    // Slot above the bracket to allow vertical insertion of card
    translate([pci_bracket_back_edge, pci_bracket_right_edge-pci_bracket_slot_extra, 0]) cube([11.43, pci_bracket_total_width+pci_bracket_slot_extra*2-2.54, 50]);
}

//pci_bracket();
//% pci_bracket_cutout();