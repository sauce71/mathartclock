// Curve Clock
// Inspired by Structure Clock http://www.thingiverse.com/thing:557190
// CC BY-SA 3.0 Tom Øyvind Hogstad 2014-15

// Sources:
// Peano-Gosper Curve http://hiiragicompany.net/ls.html
// Hilbert Curve http://upload.wikimedia.org/wikipedia/en/a/a5/Hilbert_curve.svg
// Escher Lizard http://www.inkscapeforum.com/viewtopic.php?f=5&t=2856


use <utility.scad>
//use <hilbert.scad>
//use <escher_lizard.scad>
use <gosper.scad>

r1 = 80;
r2 = 85;
layer  = 0.3; 
solid_layers = 3;
nozzle = 0.4;
// Perimeters - slic3r tend to change this around between versions
e_perimeters_ew = nozzle;
//perimeter_ew = 0.67;    	// lh=0.2
perimeters_ew = 0.48; 		// lh=0.3
wall = 2*e_perimeters_ew+perimeters_ew; // Going for "3" perimeters width.
rim = wall*4;
mech = [56,56,17];
mech_padded = mech + [2,2,1];
mech_box = mech_padded + [2*wall,2*wall, layer*3];
center_r = 5;
center_h = 5;
h  = mech_padded[2]+center_h;
dr = r2-r1;
c  = hypotenuse(h,dr);
_t = asin(dr/c);
_a = 90-_t;
s = sin(_t) * r1;

sr = 60;
sl = hypotenuse(sr,sr);
ss = sagitta(r1,sl/2);
fl = round(hypotenuse(ss,ss));
//fl=24;
echo("wall: ", wall);
echo("dr: ", dr);
echo("c: ", c);
echo("_t: ", _t);
echo("_a: ", _a);
echo("s: ", s);

echo("sl: ", sl);
echo("ss: ", ss);
echo("fl: ", fl);


 
//assembled();
//print();
stand_print();


module stand_print() {
translateX(-20) mirror()
rotateX(90)
stand();

rotateX(90)
stand();

translateY(10) 
difference() {
	cube([20,20,5]);
	rotateZ(45) cube([30,30,5]);
	
}

}

module stand_cut() {
	difference() {
		rotateY(_t) cube([c,4*wall,sr+fl]);
		translateZ(-10) cube([c*2,4*wall,10]);
	}
}

module stand() {
	difference() {
		cube([c+s+5, 4*wall, sr+fl]);
		translate([0,0,fl+5]) cube([c,4*wall,sr+fl]);
		//translate([2*wall,0,fl]) cube([c,2*wall,sr+fl]);
		#translate([2*wall,0,fl]) stand_cut();
		rotateX(-45) cube([c+s+5, 10, 10]);
		translateZ(sr+fl) rotateX(-45) cube([c+s+5, 10, 10]);
		//translate([5,0,7.5]) cube([c+s-5,2*wall, fl-15]);
		#translate([-c-1,0,fl-1]) stand_cut();

	}


}


module assembled() {
	body();
} 

module print() {
	body(print=true);
}





module body(print=false) {
	difference() {
		union() {
			difference() {
				cylinder(r1=poly(r1, 240), r2=poly(r2,240), h=h, $fn=240);
				translateZ(-1) cylinder(r1=poly(r1-rim, 240), r2=poly(r2-rim,240), h=h+2, $fn=240);
			}
			intersection() {
				translateZ(-1) cylinder(r1=poly(r1-1, 240), r2=poly(r2-1,240), h=h+2, $fn=240);
				scale([wall,wall,1]) curve(h);
			}
			cube_centered(mech_box);
			cylinder(r=poly(center_r+wall,32), h=h, $fn=32);
		}
		body_holes(print);
	}
}

module body_holes(print=false) {
	translateZ(-layer) cube_centered(mech_padded);
	#translateZ(mech_padded[2]) cylinder(r=poly(center_r,32), h=h, $fn=32);

}








