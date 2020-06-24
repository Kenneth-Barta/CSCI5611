 //Kenneth Barta

import java.awt.*;
import java.util.*;
ArrayList obstacles = new ArrayList();
ArrayList targets = new ArrayList();
ArrayList robots = new ArrayList();
int RobotCount = 8;
float time = millis();
float DT = 0;
int wall = 900; // dimeniosn of space
int robotRepulse = -300;
int targetAttract = 300;
int sensorRange = 300;
boolean paused = true;


  void setup(){
    size(1800, 1000, P3D); 
    for(int j = 0; j < 10; j++){
      Random r1 = new Random();
      obstacles.add(new Obstacle(new Point(r1.nextInt(901), r1.nextInt(901)), -100, 30));
    }
    
    targets.add(new Obstacle(new Point(0,0), targetAttract, 30));
    targets.add(new Obstacle(new Point(0,wall), targetAttract, 30));
    targets.add(new Obstacle(new Point(wall,wall), targetAttract, 30));
    targets.add(new Obstacle(new Point(wall,0), targetAttract, 30));
  
    for(int t = 0; t < 4; t++){
      Obstacle target = (Obstacle)targets.get(t);
      int startX = wall - target.p.x;
      int startY = wall -target.p.y;
      robots.add(new Robot(new Point(startX, startY), obstacles, target, 40, 1000, 15, t));    
    }
    
    Obstacle topTarget = new Obstacle(new Point(wall/2, 0), targetAttract, 30);
    robots.add(new Robot(new Point(wall/2, wall), obstacles, topTarget, 40, 1000, 15, 4));
    Obstacle rightTarget = new Obstacle(new Point(wall, wall/2), targetAttract, 30);
    robots.add(new Robot(new Point(0, wall/2), obstacles, rightTarget, 40, 1000, 15, 5));    
    Obstacle botTarget = new Obstacle(new Point(wall/2, wall), targetAttract, 30);
    robots.add(new Robot(new Point(wall/2, 0), obstacles, botTarget, 40, 1000, 15, 6));   
    Obstacle leftTarget = new Obstacle(new Point(0, wall/2), targetAttract, 30);
    robots.add(new Robot(new Point(wall, wall/2), obstacles, leftTarget, 40, 1000, 15, 7));    
  }
  /*
  *
  * The user can use the the mouse to add obstacles within the working space.
  */
  
  void draw(){

    DT = (millis() - time)/100000;
    background(100);
    fill(255,255,255);
    stroke(0);
    pushMatrix();
    translate(400,100);
    rect(0, 0, wall, wall);
    
    for(int o = 0; o < obstacles.size(); o++){
      pushMatrix();
      Obstacle ob = (Obstacle) obstacles.get(o);
      translate(ob.p.x, ob.p.y);
      fill(200,200,200);
      circle(0,0, ob.diam);
      popMatrix();
    }
    
    for(int r = 0; r < robots.size(); r++){  
      pushMatrix();
      Robot currentRobot = (Robot)robots.get(r);
            
      fill(currentRobot.red, currentRobot.blue, currentRobot.green);
      stroke(currentRobot.red,currentRobot.blue, currentRobot.green);
      translate(currentRobot.x, currentRobot.y);
      circle(0,0,currentRobot.diam);
      popMatrix();
      
      noFill();
      circle(currentRobot.target.p.x, currentRobot.target.p.y, currentRobot.target.diam);
    }
    
    popMatrix();
    if(!paused){
      for(int i = 0; i < 10; i++){
        for(int r = 0; r < robots.size(); r++){
          Robot currentRobot = (Robot)robots.get(r);
          if(!arrivedAtTarget(currentRobot)){
            updatePosition(currentRobot, DT);
          }
        }
      }
    }
    
    textSize(32);
    fill(50,50,50);
    text("Press any key to pause and unpause.", 100, 50);
    text("Click anywhere in the space to add an obstacle", 900, 50);

  }
 
 boolean arrivedAtTarget(Robot r){
  float distance = sqrt(sq(r.target.p.x - r.x) + sq(r.target.p.y - r.y));
  if(distance < r.target.diam/4){
    return true;
  }
  return false; 
 }
 
 public void updatePosition(Robot r, float dt) {
  float dirX = 0;
  float dirY = 0;
  float minS = 200;
  Iterator iter = r.obstacles.iterator();
  
  while(iter.hasNext()){
    Obstacle ob = (Obstacle)iter.next();
    if(!range(ob, sensorRange, r)) {
     continue;
    }
    
    float distSq = ob.distanceSq(r);
    if(distSq < 1){
      Math.sin(1);
    }
    float dx = ob.charge * (ob.p.x - r.x) / distSq;
    float dy = ob.charge * (ob.p.y - r.y) / distSq;
    dirX += dx;
    dirY += dy;
  }
  
  float[] vals = RobotCollision(r);
  dirX += vals[0];
  dirY += vals[1];
  
  float targetDis = r.target.distanceSq(r);
  if(targetDis < 1){
    Math.sin(1);
  }
  float targetDX = r.target.charge * (r.target.p.x - r.x) /  targetDis;
  float targetDY = r.target.charge * (r.target.p.y - r.y) /  targetDis;
  dirX += targetDX;
  dirY += targetDY;
  
  float norm = (float)Math.sqrt(dirX * dirX + dirY * dirY);
  dirX = dirX / norm;
  dirY = dirY / norm;
  
  iter = r.obstacles.iterator();
  
  while(iter.hasNext()){
   Obstacle ob = (Obstacle)iter.next();
   
   if(!range(ob, sensorRange, r)) {
     continue;
   }
   float distSq = ob.distanceSq(r);
   float dx = (ob.p.x - r.x);
   float dy = (ob.p.y - r.y);
   dx = addNoise(dx, 0, 1);
   dy = addNoise(dy, 0, 1);
   float safety = distSq / (dx * dirX + dy *dirY);
   
   if((safety > 0) && (safety < minS)){
     minS = safety;
   }
  }
   if(minS < 5){
     r.target.charge += minS/5;
   }
   if(minS > 100){
    r.target.charge += minS/100;
   }
  
   float vtNorm = minS/2;
   float vtx = vtNorm * dirX;
   float vty = vtNorm * dirY;
   float fx = r.m * (vtx - r.vx);
   float fy = r.m * (vty - r.vy);
   float fNorm = (float)Math.sqrt(fx * fx + fy *fy);
   
   if(fNorm > r.fMax){
    fx *= r.fMax / fNorm;
    fy *= r.fMax/ fNorm;
   }
   r.vx += (fx * dt) / r.m;
   r.vy += (fy * dt) / r.m;

   correctVelocity(r);
   
   r.x += r.vx * dt;
   r.y += r.vy * dt;  
   
   correctPosition(r);
  }
  
  float[] RobotCollision(Robot r){
    float[] vals = new float[2];
    for(int index = 0; index!=r.ID; index++){
      Robot avoidRobot = (Robot)robots.get(index);

      float range = sqrt(sq(avoidRobot.x - r.x) + sq(avoidRobot.y - r.y)) - (avoidRobot.diam + r.diam) / 2;

      if(range > sensorRange) {
        continue;
      }

      if(range < 1){
        Math.sin(1);
      }
      float dx = robotRepulse * (avoidRobot.x - r.x) / range;
      float dy = robotRepulse * (avoidRobot.y - r.y) / range;
      vals[0] += dx;
      vals[1] += dy;
    }
    return vals;
  }
  
  void correctVelocity(Robot r){
    if(r.vx > r.maxVel){
      r.vx = r.maxVel;
    }
    if(r.vx < -r.maxVel){
      r.vx = -r.maxVel;
    }
    if(r.vy > r.maxVel){
      r.vy = r.maxVel;
    }
    if(r.vy < -r.maxVel){
      r.vy = -r.maxVel;
    }
  }
  
  void correctPosition(Robot r){
   if(r.x > wall){
     r.x = wall;
   }
   if(r.y > wall){
     r.y = wall;
   }
   if(r.x < 0){
     r.x = 0;
   }
   if(r.y <0){
     r.y = 0;
   }
  }
  
  boolean range(Obstacle ob, double range, Robot r){
    float dist = ob.distanceSq(r);
    if(dist < range){
     return true; 
    }
    else{
      return false;
    }
  }
  
  float addNoise(float x, float mean, float stddev){
   Random r = new Random();
   float noise = stddev*(float)r.nextGaussian() + mean;
   return x + noise;
  }
  
  void mouseClicked(){
    boolean inObstacle = false;
    
    for(int o = 0; o < obstacles.size(); o++){
     Obstacle ob = (Obstacle)obstacles.get(o);
     float dist = sqrt(sq((mouseX-400) - ob.p.x) + sq((mouseY-100) - ob.p.y));
     if(dist > ob.diam/2)
       continue;
     else
       inObstacle = true;
    }
    if(!inObstacle){
      if(mouseX < wall+400 && mouseX >400 && mouseY < wall+100 && mouseY > 100){
        obstacles.add(new Obstacle(new Point(mouseX -400, mouseY - 100), -100, 30)); 
      }
    }    
  }
  
  void mouseDragged(){    
    for(int o = 0; o < obstacles.size(); o++){
     Obstacle ob = (Obstacle)obstacles.get(o);
     float dist = sqrt(sq((mouseX-400) - ob.p.x) + sq((mouseY-100) - ob.p.y));
     if(dist > ob.diam/2)
       continue;
     else
       ob.p.x = mouseX-400;
       ob.p.y = mouseY-100;
    }
  }
  
  void keyPressed(){
    paused = !paused; 
  }

/**
*
*/
   class Obstacle { // Obstacle class. These are stationary but have a repuslive or attractive charge
  float diam;
  float mass;
  float charge;
  Point p;
  
  public Obstacle(Point p_, float charge_, float diam_) {
    diam = diam_;
    p = p_;
    charge = charge_;
  }
  public float distanceSq(Robot r){
    return distace(r);
  }
  public float distace(Robot r){
   float d = (float)p.distance(r.x, r.y) - (diam + r.diam) / 2;
   return d > 0? d: 0.0000001;
  }  
  Point getPoint(){
   return p; 
  }
}

 class Robot { //Robot class that are mobile and will seek out it's target (an obstacle with an attractive charge)
   float x, y, vx, vy;
   float m;
   float fMax;
   ArrayList obstacles;
   float diam;
   Obstacle target;
   float maxVel = 1;
   int ID;
   float red = random(255);
   float blue = random(255);
   float green = random(255);
   
   
   public Robot(Point p_, ArrayList obstacles_, Obstacle target_, float m_, float fMax_, float diam_, int id){
     x = p_.x;
     y = p_.y;
     obstacles = obstacles_;
     m = m_;
     fMax = fMax_;
     diam = diam_;
     target = target_;
     ID = id;
   }
    
 }
  
