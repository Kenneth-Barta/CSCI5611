import peasy.*;
PeasyCam camera;
int fullLength = 600;
int NumNodes = 30;
int NumThreads = 30;

int segLength = fullLength / (NumNodes-1);
int segWidth = 1000/( NumThreads-1);

float K = 30; 
float kV = 20;  
float mass = 0.1;
float gravity = 10;

double time = millis();

ArrayList<Node> NodeLs = new ArrayList<Node>();
ArrayList<Sphere> objects = new ArrayList<Sphere>();
PImage blueCloth;
PImage hempCloth;

int ledgeY = -200;
int sphereR = 100;
int  sphereZ ;

float DT = 0.02;
void setup() {
  size(1820,980,P3D);

  sphereZ = 50;
  camera = new PeasyCam(this, width/2.0, height/3.0,(height/2.0) / tan(PI*30.0 / 180.0), 500);  
  blueCloth = loadImage("blue coth.jpg");
  hempCloth = loadImage("hemp cloth.jpg");
  objects.add(new Sphere (-300, 0, sphereZ, sphereR));

  for(int m = 0; m < NumThreads; m++) {
    for(int n = 0; n < NumNodes; n++) {
      NodeLs.add(new Node(-300 + (m*segWidth),0, n*segLength));
    }
  }
  LeapFrogIntegration(DT/2);
}

void draw() {
 println(frameRate);
 
 DT = (float)(millis() - time)/1500;
 time = millis();
 if(DT> 0.02){
 DT = .01;
 }
 background(150);

 objects.get(0).xpos = mouseX-300;
 objects.get(0).ypos = mouseY;
 
 pushMatrix();
 translate(400,ledgeY,30);
 noStroke();
 fill(100,100,150);
 box(width,20,200);
 popMatrix(); 
 
 pushMatrix();
 translate(0,height,0);
 fill(100);
 box(2*width, 20, width);
 popMatrix();
 

 
 pushMatrix();
 translate(300,ledgeY,30);
   
   pushMatrix();
   translate(objects.get(0).xpos , objects.get(0).ypos, objects.get(0).zpos);
   fill(30,200,30);
   sphere(objects.get(0).R);
   popMatrix();
 
 int tSelect = 0;
 for(int t = 0; t < NumThreads-1; t++){
   for(int l = 0; l < NumNodes-1; l++) {

     if(tSelect%2 == 0) {
       beginShape();
       texture(blueCloth);
       vertex(NodeLs.get(t*(NumNodes) + l).xpos, NodeLs.get(t*(NumNodes) + l).ypos, NodeLs.get(t*(NumNodes) + l).zpos, 0,0);
       vertex(NodeLs.get((t+1)*(NumNodes) + l).xpos, NodeLs.get((t+1)*(NumNodes) + l).ypos, NodeLs.get((t+1)*(NumNodes) + l).zpos, blueCloth.width,0);
       vertex(NodeLs.get((t+1)*(NumNodes) + l +1).xpos, NodeLs.get((t+1)*(NumNodes) + l+1).ypos, NodeLs.get((t+1)*(NumNodes) + l+1).zpos, blueCloth.width, blueCloth.height);
       vertex(NodeLs.get((t)*(NumNodes) + l +1).xpos, NodeLs.get((t)*(NumNodes) + l+1).ypos, NodeLs.get((t)*(NumNodes) + l+1).zpos, 0, blueCloth.height);
       endShape();
     }
     else{
       beginShape();
       texture(hempCloth);
       vertex(NodeLs.get(t*(NumNodes) + l).xpos, NodeLs.get(t*(NumNodes) + l).ypos, NodeLs.get(t*(NumNodes) + l).zpos, 0,0);
       vertex(NodeLs.get((t+1)*(NumNodes) + l).xpos, NodeLs.get((t+1)*(NumNodes) + l).ypos, NodeLs.get((t+1)*(NumNodes) + l).zpos, hempCloth.width,0);
       vertex(NodeLs.get((t+1)*(NumNodes) + l +1).xpos, NodeLs.get((t+1)*(NumNodes) + l+1).ypos, NodeLs.get((t+1)*(NumNodes) + l+1).zpos, hempCloth.width, hempCloth.height);
       vertex(NodeLs.get((t)*(NumNodes) + l +1).xpos, NodeLs.get((t)*(NumNodes) + l+1).ypos, NodeLs.get((t)*(NumNodes) + l+1).zpos, 0, hempCloth.height);
       endShape();
     }
     tSelect++;
   }
   tSelect+=2;
 }
  
 for(int i =0; i < 25; i++) {
    UpdateSim(DT);
 }
 
 for(int m = 0; m < NodeLs.size(); m++) {
   if(m%NumNodes == 0) {
     NodeLs.get(m).velocity = new Vector(0,0,0);
   }
 }

 popMatrix();
}

void UpdateSim(double dt_) { // Update velocities and positions for nodes. Using Euler-Cromer 
   for(int n = 0; n < NumNodes*NumThreads-1; n++) {
     if(n < NumNodes*(NumThreads-1)){
      computeDrag(n); 
     }
      if((n+1)%(NumNodes) != 0 ){ // Compute forces in vertical
        Vector unitlen = new Vector(NodeLs.get(n+1).xpos - NodeLs.get(n).xpos, NodeLs.get(n+1).ypos - NodeLs.get(n).ypos, NodeLs.get(n+1).zpos - NodeLs.get(n).zpos);
        float l = unitlen.length();
        unitlen.normalize();
        double v1 = unitlen.Dot(NodeLs.get(n).velocity);
        double v2 = unitlen.Dot(NodeLs.get(n+1).velocity);
        double F1 = -K*(segLength - l) - kV*(v1 - v2);
        
        NodeLs.get(n).velocity = NodeLs.get(n).velocity.Add(unitlen.Mult(F1*dt_));
        NodeLs.get(n+1).velocity = NodeLs.get(n+1).velocity.Minus(unitlen.Mult(F1*dt_));
       }
     
     if(n < NumNodes*(NumThreads-1)) {   // Compute forces in horizontal
      Vector unitlen = new Vector(NodeLs.get(n+NumNodes).xpos - NodeLs.get(n).xpos, NodeLs.get(n+NumNodes).ypos - NodeLs.get(n).ypos, NodeLs.get(n+NumNodes).zpos - NodeLs.get(n).zpos);
      float l = unitlen.length();
      unitlen.normalize();
      double v1 = unitlen.Dot(NodeLs.get(n).velocity);
      double v2 = unitlen.Dot(NodeLs.get(n+NumNodes).velocity);
      double F1 = -K*(segLength - l) - kV*(v1 - v2);
      
      NodeLs.get(n).velocity = NodeLs.get(n).velocity.Add(unitlen.Mult(F1*dt_));
      NodeLs.get(n+NumNodes).velocity = NodeLs.get(n+NumNodes).velocity.Minus(unitlen.Mult(F1*dt_));   
     }
     
     if(NodeLs.get(n).ypos > height-ledgeY) {
        NodeLs.get(n).velocity.vy *= -0.9;
        NodeLs.get(n).ypos = height - ledgeY;
      }
      
      if(n%NumNodes != 0){
        
        NodeLs.get(n).velocity.vy += gravity*dt_;
        NodeLs.get(n).ypos += NodeLs.get(n).velocity.vy * dt_;
        NodeLs.get(n).xpos += NodeLs.get(n).velocity.vx * dt_;
        NodeLs.get(n).zpos += NodeLs.get(n).velocity.vz * dt_;
        
        if(n == NumNodes*NumThreads-2){
          NodeLs.get(n+1).velocity.vy += gravity*dt_;
          NodeLs.get(n+1).ypos += NodeLs.get(n+1).velocity.vy * dt_;
          NodeLs.get(n+1).xpos += NodeLs.get(n+1).velocity.vx * dt_;
          NodeLs.get(n+1).zpos += NodeLs.get(n+1).velocity.vz * dt_;   
          
          float dist = objects.get(0).distTo(NodeLs.get(n+1).xpos, NodeLs.get(n+1).ypos, NodeLs.get(n+1).zpos);
          
          if( dist < objects.get(0).R +10){             
           collisionFix(n+1, dist);
          }
        }      
          float dist = objects.get(0).distTo(NodeLs.get(n).xpos, NodeLs.get(n).ypos, NodeLs.get(n).zpos);
          
          if( dist < objects.get(0).R +10){
           collisionFix(n, dist);
          } 
      } // End all non anchor node updates
   }

}

void LeapFrogIntegration(float dt_){ // leap fron integration. Starts the simulation's velocities at 1/2 time step, then continues with using Euler-Cromer
  for(int n = 0; n < NumNodes*NumThreads-1; n++) {
     if(n < NumNodes*(NumThreads-1)){
      computeDrag(n); 
     }
      if((n+1)%(NumNodes) != 0 ){ // Compute forces in vertical
        Vector unitlen = new Vector(NodeLs.get(n+1).xpos - NodeLs.get(n).xpos, NodeLs.get(n+1).ypos - NodeLs.get(n).ypos, NodeLs.get(n+1).zpos - NodeLs.get(n).zpos);
        float l = unitlen.length();
        unitlen.normalize();
        double v1 = unitlen.Dot(NodeLs.get(n).velocity);
        double v2 = unitlen.Dot(NodeLs.get(n+1).velocity);
        double F1 = -K*(segLength - l) - kV*(v1 - v2);
        
        NodeLs.get(n).velocity = NodeLs.get(n).velocity.Add(unitlen.Mult(F1*dt_));
        NodeLs.get(n+1).velocity = NodeLs.get(n+1).velocity.Minus(unitlen.Mult(F1*dt_));
       }
     
     if(n < NumNodes*(NumThreads-1)) {   // Compute forces in horizontal
      Vector unitlen = new Vector(NodeLs.get(n+NumNodes).xpos - NodeLs.get(n).xpos, NodeLs.get(n+NumNodes).ypos - NodeLs.get(n).ypos, NodeLs.get(n+NumNodes).zpos - NodeLs.get(n).zpos);
      float l = unitlen.length();
      unitlen.normalize();
      double v1 = unitlen.Dot(NodeLs.get(n).velocity);
      double v2 = unitlen.Dot(NodeLs.get(n+NumNodes).velocity);
      double F1 = -K*(segLength - l) - kV*(v1 - v2);
      
      NodeLs.get(n).velocity = NodeLs.get(n).velocity.Add(unitlen.Mult(F1*dt_));
      NodeLs.get(n+NumNodes).velocity = NodeLs.get(n+NumNodes).velocity.Minus(unitlen.Mult(F1*dt_));   
     }
      
      if(n%NumNodes != 0){        
        NodeLs.get(n).velocity.vy += gravity*dt_;
      } // End all non anchor node updates
   }
  
}

void collisionFix(int node, float dist) { // Deals with collision WITH THE BALL
  Vector norm = objects.get(0).norm(NodeLs.get(node).xpos, NodeLs.get(node).ypos, NodeLs.get(node).zpos);
           norm = norm.Mult(-1);
           norm.normalize();
           
           float dot = (float)NodeLs.get(node).velocity.Dot(norm);
           Vector bounce = norm.Mult(dot);
           
           NodeLs.get(node).velocity = NodeLs.get(node).velocity.Minus(bounce.Mult(1.5));
           norm = norm.Mult(10 + objects.get(0).R   - dist);
           NodeLs.get(node).xpos += norm.vx;
           NodeLs.get(node).ypos += norm.vy;
           NodeLs.get(node).zpos += norm.vz;
}

void computeDrag(int m){ // Attempt to add drag the moving cloth
  float p = 1.255;
  float cd = 1.5;
 
    if((m+1)%(NumNodes) != 0 ){
      Node n1 = NodeLs.get(m);
      Node n2 = NodeLs.get(m+NumNodes);
      Node n3 = NodeLs.get(m+1);
      Node n4 = NodeLs.get(m+1+NumNodes);
           
     Vector R21 = new Vector(n2.xpos-n1.xpos, n2.ypos-n1.ypos,n2.zpos-n1.zpos);//(n2.velocity).Minus(n1.velocity)).Cross(n4.velocity.Minus(n1));
     Vector R31 = new Vector(n3.xpos-n1.xpos, n3.ypos-n1.ypos,n2.zpos-n1.zpos);
     Vector R41 = new Vector(n4.xpos-n1.xpos, n4.ypos-n1.ypos,n4.zpos-n1.zpos);
     
     Vector totalV1 = n1.velocity.Add(n2.velocity.Add(n4.velocity));
     totalV1 = totalV1.Mult(0.33);
     Vector NS1 = R41.Cross(R21);
     float top1 = (float)totalV1.length() * (float)(totalV1.Dot(NS1));
     float bot1 = 2*NS1.length();
     Vector drag1 = NS1.Mult(top1/bot1);
     drag1 = drag1.Mult(-0.5 * p * cd);
     drag1 = drag1.Mult(0.33); //Divide by 3 for drag at each point
     
     Vector totalV2 = n1.velocity.Add(n3.velocity.Add(n4.velocity));
     totalV2 = totalV2.Mult(0.33);
     Vector NS2 = R31.Cross(R41);
     float top2 = (float)totalV2.length() * (float)(totalV2.Dot(NS2));
     float bot2 = 2*NS2.length();
     Vector drag2 = NS2.Mult(top2/bot2);
     drag2 = drag2.Mult(-0.5 * p * cd);
     drag2 = drag2.Mult(0.33); //Divide by 3 for drag at each point
     
     
     NodeLs.get(m).velocity.Add(drag1.Add(drag2)); //1
     NodeLs.get(m+NumNodes).velocity.Add(drag1); //2
     NodeLs.get(m+1).velocity.Add(drag2); //3
     NodeLs.get(m+1+NumNodes).velocity.Add(drag1.Add(drag2)); //4
    }
}

int node = NumNodes-1;
void keyPressed() {
  if (keyCode == RIGHT) {
  }
  if (keyCode == LEFT) {
  }
    if (keyCode == UP) {
      objects.get(0).zpos += 10;
  }
  if (keyCode == DOWN) {
    objects.get(0).zpos -= 10;
  }
}

 class Node {
  float xpos;
  float ypos;
  float zpos;

  Vector velocity = new Vector(0,0,0);
  float partialYF;
  
  Node(float x, float y, float z){
    xpos = x;
    ypos = y;
    zpos = z; 
  }  
   
 }
 class Vector { 
  double vx; 
  double vy;
  double vz;
  Vector (double x_, double y_, double z_) { 
    vx = x_; 
    vy = y_;
    vz = z_;
  }
  float length(){
    float len = sqrt(sq((float)vx) + sq((float)vy) + sq((float)vz));
    return len;
  }
  void normalize(){
    float len = length();
   vx /= len;
   vy /= len;
   vz /= len;
  }
  Vector Mult(double a){
    return new Vector(vx * a, vy * a, vz * a);
  }
  double Dot(Vector b){
    return vx*b.vx + vy*b.vy + vz*b.vz;
  }
  Vector Cross(Vector b){
   return new Vector((vy*b.vz - vz*b.vy),(vz*b.vx - vx*b.vz),(vx*b.vy - vy*b.vx)); 
  }
  Vector Minus(Vector b)  {
   return new Vector(vx-b.vx, vy-b.vy, vz-b.vz); 
  }
  Vector Add(Vector b) {
   return new Vector(vx+b.vx, vy+b.vy, vz+b.vz); 
  }
}

class Sphere {
 float xpos;
 float ypos;
 float zpos;
 float R;
 Sphere(float x_ ,float y_,float z_,float R_){
   xpos = x_;
   ypos = y_;
   zpos = z_;
   R = R_;
 }
  float distTo(float Nodex, float NodeY, float NodeZ){
    return sqrt(sq(Nodex-xpos) + sq(NodeY-ypos) + sq(NodeZ-zpos));
  }
  Vector norm(float NodeX, float NodeY, float NodeZ) {
   return new Vector(xpos- NodeX, ypos - NodeY, zpos - NodeZ);
  }
  
}
