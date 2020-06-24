// Kenneth Barta Assignment 1
// barta051
import peasy.*;
PeasyCam camera;

ArrayList<Point> PositionLs = new ArrayList<Point>(); // List of positions of all particles
ArrayList<Velocity> VelocityLs = new ArrayList<Velocity>(); //List of velocities of all particles
FloatList LifeLs = new FloatList(); // Life span of particles

ArrayList<Point> ShootingLs = new ArrayList<Point>(); // List of positions of all particles
ArrayList<Velocity> ShootingVl = new ArrayList<Velocity>(); //List of velocities of all particles
FloatList ShootingLf = new FloatList(); // Life span of particles
FloatList MaxLife = new FloatList();

ArrayList<Point> ExplodingLs = new ArrayList<Point>(); // List of positions of all particles
ArrayList<Velocity> ExplodingVl = new ArrayList<Velocity>(); //List of velocities of all particles
FloatList ExplodingLf = new FloatList(); // Life span of particles
IntList ExplodingColor = new IntList();

color c = color(255,200,200,0); 
color c2 = color(100,255,200);


float time_ = millis();
float dt_ = 0;
float GenRate_ = 500; // 
float gravity = 98;
float lifeSpan = 3; // Can adjust how long the particles will here

float XV = 30; // The velocity range in x direction
float fountain_YV = -200; // The velocity range in y direction
float shooting_YV = -350;
float ZV = 30; // The velocity range in x direction
PImage img;

ArrayList<PImage> Images = new ArrayList<PImage>();
PImage fountain_tex_;
PImage fountain_tex_2;
PImage shooting_tex;
PImage explosion_tex;
PImage light_blue;
PImage orange;
PImage pink;
PImage blue_star;
PImage light_green;
PImage sparkle;
PImage swirl;
PImage ring;
PImage shooting_blue;


float texture_crop = 150;
float tex_offset = 3;
 

void setup(){
 size(1080, 720, P3D);
 camera = new PeasyCam(this, width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), 50);      
 img = loadImage("sun mmon lake.jpg");
 light_blue = loadImage("Light_blue.jpg");
 Images.add(light_blue);
 orange = loadImage("orange.jpg"); 
 Images.add(orange);
 pink = loadImage("pink.jpg");
 Images.add(pink);
 blue_star = loadImage("blue_star.jpg");
 Images.add(blue_star);
 light_green = loadImage("light_green.jpg");
 Images.add(light_green);
 sparkle = loadImage("sparkle.jpg");
 Images.add(sparkle);
 swirl = loadImage("swirl.jpg");
 Images.add(swirl);
 ring = loadImage("ring.jpg");
 Images.add(ring);
 shooting_blue = loadImage("shooting_blue.png");
 Images.add(shooting_blue);
 noStroke();

}

void draw() {
 dt_ = (millis() - time_) /1000;
 time_ = millis();
 background(100);
 noStroke();
 drawBackground();

 if(keyPressed && keyCode == UP){
   for(int f = 0; f < (GenRate_ * dt_); f++) {
     GenerateFountainFirework(); 
   } 
     if(ShootingLs.size() < 5)
     GenerateShootingFirework();   
  }
 
   animateFountain();
   animateShooting();
   animateExplosion();
  
}


void animateFountain() {
 stroke(c);
 for(int fount = 0; fount < PositionLs.size(); fount++){
  if(fount%2 == 0) {
    if(LifeLs.get(fount) > 1.6) {
     fountain_tex_ = orange; 
    }
    else if (LifeLs.get(fount) > 0.8){
      fountain_tex_ = pink;
    }
    else {
    fountain_tex_ = light_blue;
    }
    pushMatrix();

   translate(50, height, -20);
   point(PositionLs.get(fount).x, PositionLs.get(fount).y, PositionLs.get(fount).z);
   beginShape();
   texture(fountain_tex_);
   vertex(PositionLs.get(fount).x-tex_offset,PositionLs.get(fount).y-tex_offset,3,0.0);
   vertex(PositionLs.get(fount).x+tex_offset,PositionLs.get(fount).y-tex_offset,3,fountain_tex_.width,0);
   vertex(PositionLs.get(fount).x+tex_offset,PositionLs.get(fount).y+tex_offset,3,fountain_tex_.width,fountain_tex_.height);
   vertex(PositionLs.get(fount).x-tex_offset,PositionLs.get(fount).y+tex_offset,3,0,fountain_tex_.height);
   endShape();
   MoveFountain(PositionLs.get(fount), VelocityLs.get(fount));
   popMatrix();

  }
  else {
    if(LifeLs.get(fount) > 1.5) {
     fountain_tex_ = swirl; 
    }
    else if (LifeLs.get(fount) > 1){
      fountain_tex_ = sparkle;
    }
    else if (LifeLs.get(fount) > 0.5){
      fountain_tex_ = ring;
    }
    else {
    fountain_tex_ = light_green;
    }
   pushMatrix();
   translate(width - 50, height, -20);
  
   point(PositionLs.get(fount).x, PositionLs.get(fount).y, PositionLs.get(fount).z);
   beginShape();
   texture(fountain_tex_);
   vertex(PositionLs.get(fount).x-tex_offset,PositionLs.get(fount).y-tex_offset,3,0,0);
   vertex(PositionLs.get(fount).x+tex_offset,PositionLs.get(fount).y-tex_offset,3,fountain_tex_.width,0);
   vertex(PositionLs.get(fount).x+tex_offset,PositionLs.get(fount).y+tex_offset,3,fountain_tex_.width,fountain_tex_.height);
   vertex(PositionLs.get(fount).x-tex_offset,PositionLs.get(fount).y+tex_offset,3,0,fountain_tex_.height);
   endShape();
   MoveFountain(PositionLs.get(fount), VelocityLs.get(fount));
   popMatrix();
  }
  
  if(LifeLs.get(fount) > lifeSpan) {
     LifeLs.remove(fount);
     PositionLs.remove(fount);
     VelocityLs.remove(fount);
  }
  else {
   LifeLs.add(fount, dt_); 
  }
 }
}


void animateShooting() {
  stroke(c);
    for(int shot = 0; shot < ShootingLs.size(); shot++) {
      
      pushMatrix();
      translate(width/2, height, -20);
       point(ShootingLs.get(shot).x, ShootingLs.get(shot).y, ShootingLs.get(shot).z);
       MoveShooting(ShootingLs.get(shot), ShootingVl.get(shot));
       beginShape();
       shooting_tex = Images.get(int(random(0,Images.size())));
       texture(shooting_tex);
       vertex(ShootingLs.get(shot).x-tex_offset,ShootingLs.get(shot).y-tex_offset,3,0,0);
       vertex(ShootingLs.get(shot).x+tex_offset,ShootingLs.get(shot).y-tex_offset,3,shooting_tex.width,0);
       vertex(ShootingLs.get(shot).x+tex_offset,ShootingLs.get(shot).y+tex_offset+5,3,shooting_tex.width,shooting_tex.height);
       vertex(ShootingLs.get(shot).x-tex_offset,ShootingLs.get(shot).y+tex_offset+5,3,0,shooting_tex.height);
       endShape();
      popMatrix();
      
      if(ShootingLf.get(shot) > MaxLife.get(shot)) {
        int tex_color = int(random(0,Images.size()));
        for(int explode = 0; explode < 15; explode++){
          ExplodingLs.add(new Point(ShootingLs.get(shot).x, ShootingLs.get(shot).y, ShootingLs.get(shot).z));
          GenerateExplodingFirework();      
          ExplodingColor.append(tex_color);
        }
        
        ShootingLs.remove(shot);
        ShootingVl.remove(shot);
        ShootingLf.remove(shot);
      }
      else {
        ShootingLf.add(shot, dt_);
      }
    }

}

void animateExplosion(){ 
  stroke(c);
    for(int boom = 0; boom < ExplodingLs.size(); boom++) {
      
      pushMatrix();
      translate(width/2, height, -20);
      
       point(ExplodingLs.get(boom).x, ExplodingLs.get(boom).y, ExplodingLs.get(boom).z);
       MoveExplosion(ExplodingLs.get(boom), ExplodingVl.get(boom));
       
       beginShape();
       explosion_tex = Images.get(ExplodingColor.get(boom));
       texture(explosion_tex);
       vertex(ExplodingLs.get(boom).x-tex_offset,ExplodingLs.get(boom).y-tex_offset,3,0,0);
       vertex(ExplodingLs.get(boom).x+tex_offset,ExplodingLs.get(boom).y-tex_offset,3,explosion_tex.width,0);
       vertex(ExplodingLs.get(boom).x+tex_offset,ExplodingLs.get(boom).y+tex_offset+2,3,explosion_tex.width,explosion_tex.height);
       vertex(ExplodingLs.get(boom).x-tex_offset,ExplodingLs.get(boom).y+tex_offset+2,3,0,explosion_tex.height);
       endShape();
      popMatrix();
      
      if(ExplodingLf.get(boom) > 2) {
        ExplodingLs.remove(boom);
        ExplodingVl.remove(boom);
        ExplodingLf.remove(boom);
      }
      else {
        ExplodingLf.add(boom, dt_);
      }
    }
}

void drawBackground(){
  pushMatrix();
 translate(width / 2, height / 2, -100);
 beginShape();
 texture(img);
 
 vertex(-600,-400,0,0,0);
 vertex(600,-400,0,img.width,0);
 vertex(600,400,0,img.width, img.height-texture_crop);
 vertex(-600,400,0,0,img.height-texture_crop);
 endShape();
 
 beginShape();
 texture(img);
 vertex(-600,400,0,0,img.height-texture_crop);
 vertex(600,400,0,img.width,img.height-texture_crop);
 vertex(600,400,texture_crop,img.width,img.height);
 vertex(-600,400,texture_crop,0,img.height);

 endShape();
 popMatrix();
}


void GenerateFountainFirework(){
  PositionLs.add(new Point(random(5), random(1), random(-5, 5)));
  VelocityLs.add(new Velocity(random(-XV/2,XV/2),fountain_YV, random(-ZV/3,ZV/3 )));
  LifeLs.append(0.0);
}

void GenerateShootingFirework() {
  ShootingLs.add(new Point(random(-300,300), random(5), random(-5, 5)));
  ShootingVl.add(new Velocity(random(-XV/4,XV/4), shooting_YV, random(-ZV/3,ZV/3 )));
  ShootingLf.append(0.0);
  MaxLife.append(random(2,3));
}

void GenerateExplodingFirework() {
    float r = 150;
    float theta = 2 * PI * random(1);
    float phi = acos(1 - 2 * random(1));
    float x = r * ( sin(phi) * cos(theta));
    float y = r * (sin(phi) * sin(theta));
    float z = cos(phi) * r;
    ExplodingVl.add(new Velocity(x,y,z));
    ExplodingLf.append(0.0);
}


void MoveFountain(Point pos_, Velocity vel_){ // Main function that controls the motion and physics of the particles
    
  pos_.x += vel_.vx * dt_;
  pos_.y += vel_.vy * dt_;
  pos_.z += vel_.vz * dt_;
  
  vel_.vy += gravity * dt_;
                                       
}

void MoveShooting(Point pos_, Velocity vel_) {
  pos_.x += vel_.vx * dt_;
  pos_.y += vel_.vy * dt_;
  pos_.z += vel_.vz * dt_;
  
  vel_.vy += gravity * dt_;
  vel_.vx *= vel_.vx * dt_;
  vel_.vz *= -vel_.vz * dt_;
  
}
void MoveExplosion(Point pos_, Velocity vel_) {
  pos_.x += vel_.vx * dt_;
  pos_.y += vel_.vy * dt_;
  pos_.z += vel_.vz * dt_;
  
  vel_.vy += gravity * dt_;  
}


class Point { 
  float x; 
  float y;
  float z; 
  Point (float x_, float y_, float z_) { 
    x = x_; 
    y = y_;
    z = z_;
  }
}

class Velocity { 
  float vx; 
  float vy;
  float vz;
  Velocity (float x_, float y_, float z_) { 
    vx = x_; 
    vy = y_;
    vz = z_;
  }
  float length(){
    float len = sqrt(sq(vx) + sq(vy) + sq(vz));
    return len;
  }
  void normalize(){
    float len = length();
   vx /= len;
   vy /= len;
   vz /= len;
  }
  Velocity mult(float a){
    return new Velocity(vx * a, vy * a, vz * a);
  }
}
