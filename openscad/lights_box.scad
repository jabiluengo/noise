/*
By Jabi Luengo (@jabiluengo)
Licence Creative commons atribution & share alike.
Bassed in https://github.com/gregmarra/project_box

The MIT License (MIT)

Copyright (c) 2014 Greg Marra

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
*/
enclosure_inner_length = 200;
enclosure_inner_width = 80;
enclosure_inner_depth = 20;
second_depth = 40;

enclosure_thickness = 3;
bass_thinkness = 0.50;

cover_thickness = 3;

strip_w = 8;
strip_d = 1.5;
strip_n = 3;

wire_hole_x = 8;
wire_hole_y = 6;
wire_hole_z = 2;


part = "cover"; // [enclosure:Enclosure, cover:Cover, leds_cover:Leds Cover]

print_part();

module print_part() {
	if (part == "enclosure") {
		box2(enclosure_inner_length,enclosure_inner_width,enclosure_inner_depth,enclosure_thickness,enclosure_thickness/2-0.10,cover_thickness,bass_thinkness,second_depth);
	} else if (part == "cover") {
		lid2(enclosure_inner_length,enclosure_inner_width,enclosure_inner_depth+second_depth,enclosure_thickness,enclosure_thickness/2+0.10,cover_thickness);
    } else if (part == "leds_cover") {
		lid(enclosure_inner_length,enclosure_inner_width,enclosure_inner_depth,enclosure_thickness,enclosure_thickness/2+0.10,cover_thickness,strip_w,strip_d,strip_n,wire_hole_x,wire_hole_y,wire_hole_z);
    } else if (part == "cover") {
		lid2(enclosure_inner_length,enclosure_inner_width,enclosure_inner_depth,enclosure_thickness,enclosure_thickness/2+0.10,cover_thickness);	
        }
}

module screws(in_x, in_y, in_z, shell) {

	sx = in_x/2 - 4;
	sy = in_y/2 - 4;
	sh = shell + in_z - 12;
	nh = shell + in_z - 4;

	translate([0,0,0]) {
		translate([sx , sy, sh]) cylinder(r=1.5, h = 15, $fn=32);
		translate([sx , -sy, sh ]) cylinder(r=1.5, h = 15, $fn=32);
		translate([-sx , sy, sh ]) cylinder(r=1.5, h = 15, $fn=32);
		translate([-sx , -sy, sh ]) cylinder(r=1.5, h = 15, $fn=32);
	
	
		translate([-sx , -sy, nh ]) rotate([0,0,-45]) 
			translate([-5.75/2, -5.6/2, -0.7]) cube ([5.75, 10, 2.8]);
		translate([sx , -sy, nh ]) rotate([0,0,45]) 
			translate([-5.75/2, -5.6/2, -0.7]) cube ([5.75, 10, 2.8]);
		translate([sx , sy, nh ]) rotate([0,0,90+45]) 
			translate([-5.75/2, -5.6/2, -0.7]) cube ([5.75, 10, 2.8]);
		translate([-sx , sy, nh ]) rotate([0,0,-90-45]) 
			translate([-5.75/2, -5.6/2, -0.7]) cube ([5.75, 10, 2.8]);
	}
}
module logo(height,size) {
    linear_extrude(height = height) {
        scale(size)
        import("noise.svg");
    }
}
module bottom(in_x, in_y, in_z, shell,thin) {
    translate([0,0,shell-thin])
	hull() {
   	 	translate([-in_x/2+shell, -in_y/2+shell, 0]) cylinder(r=shell*2,h=thin, $fn=32);
		translate([+in_x/2-shell, -in_y/2+shell, 0]) cylinder(r=shell*2,h=thin, $fn=32);
		translate([+in_x/2-shell, in_y/2-shell, 0]) cylinder(r=shell*2,h=thin, $fn=32);
		translate([-in_x/2+shell, in_y/2-shell, 0]) cylinder(r=shell*2,h=thin, $fn=32);
	}
    if (part == "enclosure") translate ([in_x/2-50,28,thin+shell]) rotate([0,0,-90]) logo(2,0.15);
}

module sides(in_x, in_y, in_z, shell) {
	translate([0,0,shell])
	difference() {
		hull() {
	   	 	translate([-in_x/2+shell, -in_y/2+shell, 0]) cylinder(r=shell*2,h=in_z, $fn=32);
			translate([+in_x/2-shell, -in_y/2+shell, 0]) cylinder(r=shell*2,h=in_z, $fn=32);
			translate([+in_x/2-shell, in_y/2-shell, 0]) cylinder(r=shell*2,h=in_z, $fn=32);
			translate([-in_x/2+shell, in_y/2-shell, 0]) cylinder(r=shell*2,h=in_z, $fn=32);
		}
	
		hull() {
	   	 	translate([-in_x/2+shell, -in_y/2+shell, 0]) cylinder(r=shell,h=in_z+1, $fn=32);
			translate([+in_x/2-shell, -in_y/2+shell, 0]) cylinder(r=shell,h=in_z+1, $fn=32);
			translate([+in_x/2-shell, in_y/2-shell, 0]) cylinder(r=shell,h=in_z+1, $fn=32);
			translate([-in_x/2+shell, in_y/2-shell, 0]) cylinder(r=shell,h=in_z+1, $fn=32);
		}
	}
	
	intersection() {
		translate([-in_x/2, -in_y/2, shell]) cube([in_x, in_y, in_z+2]);
		union() {
			translate([-in_x/2 , -in_y/2,shell + in_z -6]) cylinder(r=9, h = 6, $fn=64);
			translate([-in_x/2 , -in_y/2,shell + in_z -10]) cylinder(r1=3, r2=9, h = 4, $fn=64);
		
			translate([in_x/2 , -in_y/2, shell + in_z -6]) cylinder(r=9, h = 6, $fn=64);
			translate([in_x/2 , -in_y/2, shell + in_z -10]) cylinder(r1=3, r2=9, h = 4, $fn=64);
		
			translate([in_x/2 , in_y/2,  shell + in_z -6]) cylinder(r=9, h = 6, $fn=64);
			translate([in_x/2 , in_y/2,  shell + in_z -10]) cylinder(r1=3, r2=9, h = 4, $fn=64);
		
			translate([-in_x/2 , in_y/2, shell + in_z -6]) cylinder(r=9, h = 6, $fn=64);
			translate([-in_x/2 , in_y/2, shell + in_z -10]) cylinder(r1=3, r2=9, h = 4, $fn=64);
		}
	}
}

module lid_top_lip2(in_x, in_y, in_z, shell, top_lip, top_thickness) {

	cxm = -in_x/2 - (shell-top_lip);
	cxp = in_x/2 + (shell-top_lip);
	cym = -in_y/2 - (shell-top_lip);
	cyp = in_y/2 + (shell-top_lip);

	translate([0,0,shell+in_z])

	difference() {
	
		hull() {
	   	 	translate([-in_x/2+shell, -in_y/2+shell, 0]) cylinder(r=shell*2,h=top_thickness, $fn=32);
			translate([+in_x/2-shell, -in_y/2+shell, 0]) cylinder(r=shell*2,h=top_thickness, $fn=32);
			translate([+in_x/2-shell, in_y/2-shell, 0]) cylinder(r=shell*2,h=top_thickness, $fn=32);
			translate([-in_x/2+shell, in_y/2-shell, 0]) cylinder(r=shell*2,h=top_thickness, $fn=32);
		}
	
		
		translate([0, 0, -1]) linear_extrude(height = top_thickness + 2) polygon(points = [
			[cxm+5, cym],
			[cxm, cym+5],
			[cxm, cyp-5],
			[cxm+5, cyp],
			[cxp-5, cyp],
			[cxp, cyp-5],
			[cxp, cym+5],
			[cxp-5, cym]]);
	}
}
module uno_holes(height = 6, cil_rad = 2.5, hole_rad = 1.3, z = 0) {
    rotate([180,0,0]) difference() {
        union() {
		translate(v = [14, 2.5, z]) {
			cylinder(h = height, r = cil_rad, center = true, $fn=36);
        }
		translate(v = [15.3, 50.7, z]) {
			cylinder(h = height, r = cil_rad, center = true, $fn=36);
        }
        translate(v = [66.1, 7.6, z]) {
			cylinder(h = height, r = cil_rad, center = true, $fn=36);
        }
        translate(v = [66.1, 35.5, z]) {
			cylinder(h = height, r = cil_rad, center = true, $fn=36);
        }
        }
        union() {
		translate(v = [14, 2.5, z]) {
			cylinder(h = height, r = hole_rad, center = true, $fn=36);
        }
		translate(v = [15.3, 50.7, z]) {
			cylinder(h = height, r = hole_rad, center = true, $fn=36);
        }
        translate(v = [66.1, 7.6, z]) {
			cylinder(h = height, r = hole_rad, center = true, $fn=36);
        }
        translate(v = [66.1, 35.5, z]) {
			cylinder(h = height, r = hole_rad, center = true, $fn=36);
        }
        }
        }
}
module sensor_holes(height = 6, cil_rad = 2.5, hole_rad = 1.3, z = 0) {
    difference() {
        union() {
		translate(v = [-40, -5, z]) {
			cylinder(h = height, r = cil_rad, center = true, $fn=36);
        }
		translate(v = [-40, 33, z]) {
			cylinder(h = height, r = cil_rad, center = true, $fn=36);
        }
        }
        union() {
		translate(v = [-40, -5, z]) {
			cylinder(h = height, r = hole_rad, center = true, $fn=36);
        }
		translate(v = [-40, 33, z]) {
			cylinder(h = height, r = hole_rad, center = true, $fn=36);
        }
        }
        }
}


module lid(in_x, in_y, in_z, shell, top_lip, top_thickness, w, d, n, wire_x, wire_y, wire_z) {
    difference() {
		translate([0, 0, in_z+shell]) bottom(in_x-2*shell-1, in_y-2*shell-1, in_z, shell,       thin=shell);
        screws(in_x, in_y, in_z-2*shell, 3*shell);
        translate([in_x/2-(shell/2), -in_y/3+7, in_z+shell]) cube([3*d,w,10], center=true);
} 
}
module lid2(in_x, in_y, in_z, shell, top_lip, top_thickness) {

	cxm = -in_x/2 - (shell-top_lip);
	cxp = in_x/2 + (shell-top_lip);
	cym = -in_y/2 - (shell-top_lip);
	cyp = in_y/2 + (shell-top_lip);	
    translate([0,25,in_z]) uno_holes();
    translate([0,-25,in_z]) sensor_holes();
	difference() {
		translate([0, 0, in_z+shell]) linear_extrude(height = top_thickness ) polygon(points = [
			[cxm+5, cym],
			[cxm, cym+5],
			[cxm, cyp-5],
			[cxm+5, cyp],
			[cxp-5, cyp],
			[cxp, cyp-5],
			[cxp, cym+5],
			[cxp-5, cym]]);
	
			screws(in_x, in_y, in_z, shell);
        translate([in_x/2.3, 0, in_z+shell-1]) cylinder(h = top_thickness*2, r = 2, center = false, $fn=36);
        translate([in_x/2.3-8, 0, in_z+shell-1]) cylinder(h = top_thickness*2, r = 2, center = false, $fn=36);
        translate([in_x/2.3-4, 0, in_z+shell-1]) cube([8,4,top_thickness*3], center=true);
	}
       
}

module box2(in_x, in_y, in_z, shell, top_lip, top_thickness, thin, second, pw, ph) {
	bottom(in_x, in_y, in_z, shell, thin);
	difference() {
		sides(in_x, in_y, in_z, shell);
		screws(in_x, in_y, in_z, shell);
	}
    translate([0, 0, in_z])
    difference() {
		sides(in_x, in_y, second, shell);
		screws(in_x, in_y, second, shell);
        translate ([-in_x/2+35,in_y/2+(2*shell),thin+shell+(second/1.5)-in_z]) rotate([90,0,0]) logo(shell*3,0.080);
	translate([0, -in_y, 0]) hole("width_2", 6.2, [-in_x/2+20, 22]);
    translate([-in_x/2+35, -in_y/2-2*shell+1, 22-(7/2)]) cube([4,2*shell,7]);
    rotate([90,0,0]) translate([-in_x/2+35+2, 22-(7/2)-4,0]) cylinder(h = 42, r = 1.6, center = false, $fn=36);
    rotate([90,0,0]) translate([-in_x/2+35+2, 22-(7/2)-4+15,0]) cylinder(h = 42, r = 1.6, center = false, $fn=36);
	}
	lid_top_lip2(in_x, in_y, in_z+second, shell, top_lip, top_thickness);


}

module punch_hole(cylinder, rotate, translate_coords) {
	translate(translate_coords) rotate (rotate) cylinder (h = cylinder[1], r=cylinder[0], center = false, $fn=32);
}

module hole(side, radius, offset) {
	// side is "[length/width]_[1/2]"
	// radius is hole radius
	// offset is [horizontal, height] from the [center, bottom] of the side, or from the [center, center] of the lid.

	if (side == "length_1") {
		assign (
			rotate = [90,0,90], 
			translate_coords = [enclosure_thickness+1, offset[0], offset[1]], 
			length = enclosure_inner_length/2) {
				punch_hole([radius, length], rotate, translate_coords);
		}
	}
	if (side == "length_2") {
		assign (
			rotate = [90,0,270], 
			translate_coords = [-(enclosure_thickness+1), offset[0], offset[1]], 
			length = enclosure_inner_length/2) {
				punch_hole([radius, length], rotate, translate_coords);
		}
	}
	if (side == "width_1") {
		assign (
			rotate = [90,0,0], 
			translate_coords = [offset[0], -(enclosure_thickness+1), offset[1]], 
			length = enclosure_inner_width/2) {
				punch_hole([radius, length], rotate, translate_coords);
		}
	}
	if (side == "width_2") {
		assign (
			rotate = [90,0,180], 
			translate_coords = [offset[0], enclosure_thickness+1, offset[1]], 
			length = enclosure_inner_width/2) {
				punch_hole([radius, length], rotate, translate_coords);
		}
	}
	if (side == "lid") {
		assign (
			rotate = [0,0,0], 
			translate_coords = [offset[0], offset[1], enclosure_inner_depth-cover_thickness], 
			length = enclosure_inner_depth/2) {
				punch_hole([radius, length], rotate, translate_coords);
		}
	}
}
