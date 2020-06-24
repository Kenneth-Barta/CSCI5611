// Kenneth Barta Assignment 1
// barta051
import peasy.*;
PeasyCam camera;

ArrayList<Point> PositionLs = new ArrayList<Point>(); // List of positions of all particles
ArrayList<Velocity> VelocityLs = new ArrayList<Velocity>(); //List of velocities of all particles
color c = color(255,222,173); // color of tea
FloatList LifeLs = new FloatList(); // Life span of particles

float time_ = millis();
float dt_ = 0;
float GenRate_ = 2000; // 
float gravity = 98;
float lifeSpan = 5; // Can adjust how long the particles will here

float XV = 30; // The velocity range in x direction
float YV = 0; // The velocity range in y direction
float ZV = 30; // The velocity range in x direction

float cupR = 100;                    
float cupH = 300;
float drinkH = 0;  // Increments the "filling" aspect of the cup
float cupXTranslate = 540;    
float cupZTranslate = 540;
float cupYTranslate = 715;

float spoutX = 500;
float spoutZ = 540;
float spoutY = 300;

void setup(){
 size(1080, 720, P3D);
 camera = new PeasyCam(this, width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), 700);      

}

void draw(){

  dt_ = (millis() - time_)/1000;
  time_ = millis();
  
  background(100,100,100);
  line(0, 0, width, height);
  println(frameRate);

  for(int i = 0; i < GenRate_ * dt_; i++){
     GenerateParticle();
  }     
  drinkH += 0.05;
  
  stroke(c);
  pushMatrix();
  translate(spoutX,spoutY,spoutZ);
  for(int i = 0; i < PositionLs.size(); i++) {
    if(LifeLs.get(i) > lifeSpan){
     LifeLs.remove(i);
     PositionLs.remove(i);
     VelocityLs.remove(i);
    } 
    
    MoveParticle(PositionLs.get(i), VelocityLs.get(i));
    point(PositionLs.get(i).x, PositionLs.get(i).y, PositionLs.get(i).z);
    LifeLs.add(i, dt_);
  }

  pushMatrix();
  noStroke();
  fill(160,82,45);
  translate(cupXTranslate- spoutX, 715 - spoutY, cupZTranslate - spoutZ);
  box(600, 10,600);
    
  pushMatrix();
  rotateX(PI/2);

  fill(255,222,173, 200);
  translate(0,0,drinkH/2);
  drawCylinder(40, cupR - 1, drinkH);
  translate(0,0,-drinkH/2);
  
  fill(152,152,152, 100);
  translate(0,0,cupH/2);
  drawCup(40, cupR, cupH);
  
  popMatrix();  
  
  popMatrix();
  
  popMatrix();   
  
  pushMatrix();
  noStroke();
  fill(100,40,50);
  translate(spoutX - cupH/4 + 5, spoutY - 5, spoutZ-30);
  rotateY(-PI/6);
  rotateZ(3*PI/8);
  rotateX(PI/2);
  drawCup(40, cupR/2, cupH/2);
  
  popMatrix();
  
}

void GenerateParticle(){
  PositionLs.add(new Point(random(5), random(5), random(-5, 5)));
  VelocityLs.add(new Velocity(random(XV,1.5* XV), random(YV), random(ZV, 1.5*ZV)));
  LifeLs.append(0.0); 
}


void MoveParticle(Point pos_, Velocity vel_){ // Main function that controls the motion and physics of the particles
    
  pos_.x += vel_.vx * dt_;
  pos_.y += vel_.vy * dt_;
  pos_.z += vel_.vz * dt_;
  
  vel_.vy += gravity * dt_;
  
  // Deals with staying inside the cup
  float diffX = spoutX - cupXTranslate;
  float diffZ = spoutZ - cupZTranslate;
  float theta = asin(pos_.z / (cupR));
  float drag = random(1,1.5);
  
  
 if(pos_.y > cupYTranslate - cupH - spoutY) {
   
  if((pos_.x + diffX)/ cos(theta)  > cupR-1 || pos_.z +diffZ > cupR-1){
    pos_.x = cupR * cos(theta)  -diffX- 1;

    Velocity norm = new Velocity(-pos_.x, 0, -pos_.z);
    norm.normalize();
    float velDotN = (vel_.vx * norm.vx) + ( vel_.vy * norm.vy) + ( vel_.vz * norm.vz);
    Velocity B = norm.mult(velDotN);

    vel_.vx -= drag*B.vx;
    vel_.vz -= drag*B.vz;
  }
  
  if((pos_.x + diffX)/ cos(theta)  < -cupR+1 || pos_.z +diffZ  < -cupR){
    pos_.x = -cupR * cos(theta)  -diffX+ 1;
    
    Velocity norm = new Velocity(-pos_.x, 0, -pos_.z);
    norm.normalize();
    float velDotN = (vel_.vx * norm.vx) + ( vel_.vy * norm.vy) + ( vel_.vz * norm.vz);
    Velocity B = norm.mult(velDotN);
   
    vel_.vx -= drag*B.vx;
    vel_.vz -= drag*B.vz;

  }
 }
  
  if(pos_.y > (411)) {
    pos_.y = 409;
    vel_.vy *= -.2 ;
  }
                                       
}


void drawCylinder(int sides, float r, float h)
{
    float angle = 360 / sides;
    float halfHeight = h / 2;
    // draw top shape
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, -halfHeight );    
    }
    endShape(CLOSE);
    // draw bottom shape
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight );    
    }
    endShape(CLOSE);
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < sides + 3; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight);
        vertex( x, y, -halfHeight);    
    }
    endShape(CLOSE); 
} 

void drawCup(int sides, float r, float h)
{
    float angle = 360 / sides;
    float halfHeight = h / 2;
    // draw top shape
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, -halfHeight );    
    }
    endShape(CLOSE);

    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < sides + 3; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight);
        vertex( x, y, -halfHeight);    
    }
    endShape(CLOSE); 
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
