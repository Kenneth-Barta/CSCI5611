
int fullLength = 300;
int NumNodes = 5;
int NumThreads = 3;

float NodeR = 10;
int segLength = fullLength / (NumNodes-1);

float K = 50; //changing this increases occilation speed
float kV = 50;  
float mass = 20;
float gravity = 20;
float time = millis();
float DT = 0;
ArrayList<Node> NodeLs = new ArrayList<Node>();

int ledgeY = 200;

void setup() {
  size(1080,720,P3D);
  
  for(int m = 0; m < NumThreads; m++) {
    for(int n = 0; n < NumNodes; n++) {
      NodeLs.add(new Node(m*100,5+ n*segLength, 0));
    }
  }
}


void draw() {
 DT = (millis() - time)/1500;
 time = millis();
 if(DT> 0.02){
   DT = .01;
 }
 background(150); 
 //println(DT);
 pushMatrix();
 translate(400,ledgeY,30);
 noStroke();
 fill(100,100,150);
 box(800,20,200);
 popMatrix(); 
 
 pushMatrix();
 
 translate(400,200,30);
 stroke(0);
 strokeWeight(3);
 for(int t = 0; t < NumThreads; t++){
   for(int l = 0; l < NumNodes-1; l++) {
     line(NodeLs.get((t*NumNodes)+l).xpos,NodeLs.get((t*NumNodes)+l).ypos, NodeLs.get((t*NumNodes)+l).zpos, NodeLs.get((t*NumNodes)+l+1).xpos, NodeLs.get((t*NumNodes)+l+1).ypos, NodeLs.get((t*NumNodes)+l+1).zpos);
   }
 }
    
 for(int i =0; i < 30; i++) {
    UpdateSim(DT);
 }
 noStroke();
 fill(150,50,50);
 
 for(int m = 0; m < NodeLs.size(); m++) {
   if(m%NumNodes == 0) {
     NodeLs.get(m).velocity = new Vector(0,0,0);
   }
 }
 
 for(int n = 0; n < NumNodes*NumThreads; n++){
   pushMatrix();
   translate(NodeLs.get(n).xpos, NodeLs.get(n).ypos, NodeLs.get(n).zpos);
   sphere(NodeR);
   popMatrix();
 } 
 popMatrix();

}

void UpdateSim(float dt_) {
  
   for(int n = 0; n < NumNodes*NumThreads-1; n++) {
     
     if(n%(NumNodes-1) != 0 || n==0){
    
      Vector unitlen = new Vector(NodeLs.get(n+1).xpos - NodeLs.get(n).xpos, NodeLs.get(n+1).ypos - NodeLs.get(n).ypos, NodeLs.get(n+1).zpos - NodeLs.get(n).zpos);
      float l = unitlen.length();
      unitlen.normalize();
      println("Segment " + (n) + ": " + l);
      float v1 = unitlen.Dot(NodeLs.get(n).velocity);
      float v2 = unitlen.Dot(NodeLs.get(n+1).velocity);
      float F1 = -K*(segLength - l) - kV*(v1 - v2);
      
      NodeLs.get(n).velocity = NodeLs.get(n).velocity.Add(unitlen.Mult(F1*dt_));
      NodeLs.get(n+1).velocity = NodeLs.get(n+1).velocity.Minus(unitlen.Mult(F1*dt_));
    
      if(NodeLs.get(n).ypos + NodeR > height-ledgeY) {
        NodeLs.get(n).velocity.vy *= -0.9;
        NodeLs.get(n).ypos = height - ledgeY - NodeR;
      }
     }
    
   }
   for(int n = 1; n < NumNodes*NumThreads; n++){
     if(n%NumNodes != 0){
      NodeLs.get(n).velocity.vy += gravity*dt_;
      NodeLs.get(n).ypos += NodeLs.get(n).velocity.vy * dt_;// + (0.5*accY*pow(dt_,2));
      NodeLs.get(n).xpos += NodeLs.get(n).velocity.vx * dt_;
     }
   }

}


int node = NumNodes-1;
void keyPressed() {
  if (keyCode == RIGHT) {
    NodeLs.get(node).velocity.vx += 10;
  }
  if (keyCode == LEFT) {
    NodeLs.get(node).velocity.vx -= 10;
  }
    if (keyCode == UP) {
      if(node-1 > -1)
         node--;
  }
  if (keyCode == DOWN) {
    if(node+1 < NumNodes)
    node++;
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
  float vx; 
  float vy;
  float vz;
  Vector (float x_, float y_, float z_) { 
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
  Vector Mult(float a){
    return new Vector(vx * a, vy * a, vz * a);
  }
  float Dot(Vector b){
    return vx*b.vx + vy*b.vy + vz*b.vz;
  }
  Vector Minus(Vector b)  {
   return new Vector(vx-b.vx, vy-b.vy, vz-b.vz); 
  }
  Vector Add(Vector b) {
   return new Vector(vx+b.vx, vy+b.vy, vz+b.vz); 
  }
}
