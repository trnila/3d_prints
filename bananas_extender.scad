include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/vitamins/screws.scad>
use <NopSCADlib/vitamins/jack.scad>
use <NopSCADlib/printed/printed_box.scad>
use <NopSCADlib/printed/foot.scad>


outputs = 6;

input_banana_d = 4;
// measured distance from the bottom to the top edge of the inner screw
input_banana_h = 27 - input_banana_d/2;
// measured distance between outer edges of the first and second screws
input_banana_spacing = 22.5 - input_banana_d;
side_offset = 14;

output_banana_offset=7;
output_banana_d = 9;

w = 36;
h = 34;
l = 2*side_offset + output_banana_offset * 2 * outputs;
wall = 2;


box1 = pbox(name = "box1", wall = wall, top_t = wall, base_t = 1, radius = 0, size = [l-2*wall, w-2*wall, h-4*wall], screw = M3_cap_screw);

module output_positions() {
    translate([-l/2+output_banana_offset+side_offset, 0, 0]) {
        for(i = [0:outputs-1]) {
            translate([i * output_banana_offset*2, 0, 0]) {
                children();
            }
        }
    }
}

difference() {    
    rotate([180, 0, 0]) translate([0, 0, -h/2]) pbox(box1) {}
        
    // hole for input banana
    for(i = [-1, 1]) {
        translate([l/2-wall, i*input_banana_spacing/2, -h/2 + input_banana_h])
        rotate([0, 90, 0])
        cylinder(d=input_banana_d, h=wall);
    }
    
    // side output
    for(i = [-1, 1]) {
        translate([-l/2, i*input_banana_spacing/2, -h/2 + input_banana_h])
        rotate([0, 90, 0])
        cylinder(d=output_banana_d, h=wall);
    }
    
    
    // top outputs
    output_positions() {
        for(i = [-1, 1]) {
            translate([0, i*output_banana_offset, h/2-wall])
                cylinder(d=output_banana_d, h=wall);
        }
    }
}


if($preview) {
    translate([0, 0, h/2])
    output_positions() {
        translate([0, output_banana_offset, 0])
            jack_4mm("red", 3, "red");
        translate([0, -output_banana_offset, 0])
            jack_4mm("black", 3, "black");
    }
    
    translate([-l/2, 0, -h/2 + input_banana_h])
    rotate([0, -90, 0]) {
        for(item = [[1, "red"], [-1, "black"]]) {
            translate([0, item[0] * input_banana_spacing/2, 0]) {
                jack_4mm(item[1], 3, item[1]);
                
                color([1, 0, 0])
                translate([0, 0, -wall-1.5])
                    nut(M6_half_nut);
            }
        }
    }
}

 //pbox_base(box1);
    
