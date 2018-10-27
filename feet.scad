// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2018, Nirav Patel, http://eclecti.cc
//
// Anti-vibration feet, should be printed in TPU or other flexible material

feet_r = 15;
feet_h = 10;
wall = 2;
    
color("Black", 1.0) difference() {
    minkowski() {
        difference() {
            $fn = 40;
            
            cylinder(r1 = feet_r, r2 = feet_r-wall, h = feet_h);
            translate([0, 0, wall]) cylinder(r1 = feet_r-wall, r2 = feet_r-wall*2, h = feet_h);
            
        }
        sphere(r = 1, $fn = 10);
    }
    translate([-feet_r*2, -feet_r*2, -10]) cube([feet_r*4, feet_r*4, 10]);
}
