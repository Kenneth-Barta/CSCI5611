import peasy.*;
PeasyCam camera;

double time = millis();
double DT = 0;

boolean paused = false;
boolean smooth = false;

int nx = 100;
double dx = 25;
float totLen = (nx-1)*(int)dx;
double gravity = 10;
double damp = 0.01;

double left = 900-totLen/2;
float sim_dt = 0.001;

double[] H = new double[nx];
double[] UH = new double[nx];
double[] HM = new double [nx-1];
double[] UHM = new double [nx-1];

void setup(){
  size(1720, 880, P3D);
  camera = new PeasyCam(this, width/2.0, height/2.0,(height/2.0) / tan(PI*30.0 / 180.0), 300);  
  
  for(int n = 0; n < nx-5; n++){
   H[n] = 10+ (2*n/totLen);
   UH[n] = 0;
  }
    for(int n = nx-5; n < nx; n++){
   H[n] = 100+ (1.5*n/totLen);
   UH[n] = 0;
  }
}


void draw(){
 DT = (millis() - time)/1000;
 background(120);
  
  pushMatrix();
  translate(900,600, 0);
  //fill(100,101,100);
  noFill();
  stroke(50);
  box(totLen, 400, 200);
  popMatrix();
  
  pushMatrix();
  translate(0,600,100);
  for(int i = 0; i < nx-1; i++) {
    println(i + " : " + H[i]);
   double x1 = left + i * dx;
   double x2 = left + (i+1) * dx;

   fill(0,50,150);
   noStroke();
   beginShape(QUADS);
   vertex((float)x1, 100- (float)H[i], 0);
   vertex((float)x2, 100- (float)H[i+1], 0);
   vertex((float)x2, 100- (float)H[i+1], -200);
   vertex((float)x1, 100- (float)H[i], -200);
   endShape();
    
   beginShape(QUADS);
    vertex((float)x1, 100-(float)H[i], 0);
    vertex((float)x2, 100-(float)H[i+1], 0);
    vertex((float)x2, 200, 0);
    vertex((float)x1, 200, 0);
    endShape();
    
    beginShape(QUADS);
    vertex((float)x1, 100-(float)H[i], -200);
    vertex((float)x2, 100-(float)H[i+1], -200);
    vertex((float)x2, 200, -200);
    vertex((float)x1, 200, -200);
    endShape();
   
  }
  println(nx-1 + ": " + H[nx-1]);
  popMatrix();
  Update(DT);
  time = millis();
}

void Update(double dt){
  if(paused){
    return;
  }
  //println(2*dt/sim_dt);
 //for(int sim = 0; sim < dt/sim_dt; sim++){
 for(int sim = 0; sim < 50; sim++) {
  Waves(sim_dt); 
 }
  if(smooth){
   for(int i = 1; i < nx-2; i++) {
    HM[i+1] = (H[i-1] + H[i+1])/2;
   }
   for(int i = 0; i < nx-2; i++) {
    H[i+1] = 0.99*H[i+1] + 0.01*HM[i+1]; 
   }
  }
}


void Waves(double dt){

 for(int i = 0; i < nx-1; i++) {
      HM[i] = (H[i] + H[i+1]) /2 - (dt/2) * (UH[i+1] - UH[i])/ dx;
   
      UHM[i] = (UH[i] + UH[i+1])/ 2 
                - (dt/2) * 
                ((sq((float)UH[i+1])/ H[i+1]) +  (0.5 * gravity*sq((float)H[i+1]))
                - (sq((float)UH[i]) / H[i]) - (0.5*gravity*sq((float)H[i]))) /dx;
 }

 for(int i = 0; i < nx-2; i++){
  H[i+1] -= dt*(UHM[i+1] - UHM[i])/dx;
  UH[i+1] -= dt*
          (damp*UH[i+1] + (sq((float)UHM[i+1])/ HM[i+1]) + (0.5*gravity*sq((float)HM[i+1]))
         - (sq((float)UHM[i])/ HM[i]) -( 0.5 * gravity * sq((float)HM[i])))/dx; 
 } 
   H[0] = H[1];
   H[nx-1] = H[nx-2];
   UH[0] = UH[1];
   UH[nx-1] = UH[nx-2];
}

void keyPressed(){
 if(keyPressed){
   if(key == 'p' || key == 'P'){
    paused = !paused; 
   }     
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
  Vector Div (double a){
   return new Vector(vx / a, vy / a, vz / a); 
  }
   Vector Div (Vector b){
   return new Vector(vx / b.vx, vy / b.vy, vz / b.vz); 
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
  Vector Sqr(){
   return new Vector(sq((float) vx), sq((float) vy), sq((float) vz));
  }
}
