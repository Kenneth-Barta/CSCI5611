//Kenneth Barta
import java.io.*;
import java.util.*;
import peasy.*;
PeasyCam camera;

float time = millis();
float DT = 0;

float carR = 40; // Radius of the car
int wall = 800; // dimeniosn of space
float circleD = 100; // Radius of obstacles
int numPoints = 12;// amount of points that will be generated. 
Point[] points = new Point[numPoints]; // Array of points
LinkedList<Point> list[] = new LinkedList[numPoints]; // Linked list of connected points

List<Point> path; // Path that will be created from start to goal
int currentP = 0; // The current point that will help iterate through the path
Agent car = new Agent(0, wall); // Our car agent
Agent object = new Agent(wall/2, wall/2); // I counted the obstacle as an agent, since they use similar features, just one will move.

void setup() {
 size(1800, 1000, P3D); 
 camera = new PeasyCam(this, width/2.0, height/2.0,(height/2.0) / tan(PI*40.0 / 180.0), 100); 
 
 SelectPoints(); // Select our random points
 for(int i = 0; i < list.length; i++) {
   list[i] = new LinkedList();
   for(int j = i; j < points.length; j++){
     if(!Interference(points[i], points[j])){      
       list[i].add(points[j]); // creating connected graph     
      }
    }
 }
 //path = BreadthFirstSearch(0, points[points.length-1]); 
 path = UniformCostSearch(0, points[points.length-1]);
}

void draw() {
  DT = (millis() - time)/1000;
  background(150);
  fill(255,255,255);
  stroke(0);
  pushMatrix();
  translate(400,100);
  rect(0, 0, wall, wall);
  
  pushMatrix();
  translate(object.x, object.y);
  fill(150,150,150);
  circle(0,0, circleD);
  popMatrix();
  
  pushMatrix();
  translate(car.x, car.y);
  fill (200,100,50);
  drawCylinder(20, carR/2, 10);
  popMatrix();
  
  for(int i = 0; i < points.length; i++) {
    if(points[i].valid){
        fill(0,100,250);
    }
    else{
        fill(250,100,0);
    }
    circle(points[i].x, points[i].y, 5);
    
  }
   for(int j = 0; j < list.length; j++){
     for(int k = 0; k < list[j].size(); k++){
       line(points[j].x, points[j].y, list[j].get(k).x, list[j].get(k).y);// drawing connection lines
     }
   } 

  if(path != null){ // Visualize a path if one exists
    stroke(255, 150, 150);
    for(int p = 0; p < path.size()-1; p++){
      line(path.get(p).x, path.get(p).y, path.get(p+1).x, path.get(p+1).y);
    }
  }
  popMatrix();
  if(path != null){
  if(currentP < path.size()){
    if(car.distanceTo(path.get(currentP)) > carR/4){
      moveToGoal(path, currentP);
    }
    else{
      currentP++;
    }
  }
  }
}

/*
// moves the car from to the goal starting from some point P, usually the starting point
*/
void moveToGoal(List<Point> L, int p) {
      float VecX = L.get(p).x - car.x;
      float VecY = L.get(p).y - car.y;
      float len = sqrt(sq(VecX) + sq(VecY));
      VecX /= len;
      VecY /= len;
      car.x += VecX*DT;
      car.y += VecY*DT;
}

/*
// Implement Uniform Cost Search
*/
List<Point> UniformCostSearch(int start_i, Point goal){
 PriorityQueue<Point> queue = new PriorityQueue<Point>(points.length, new Comparator<Point>(){ 
     public int compare(Point i, Point j){
       if(i.pathCost > j.pathCost){
         return 1;
       }
       else if(i.pathCost < j.pathCost) {
         return -1;
       }
       else{
         return 0;
       }
     }
 }
);
 Set<Point> visited = new HashSet<Point>();
 Map<Point,Point> parentMap = new HashMap<Point, Point>();
 queue.add(points[start_i]);
 points[start_i].pathCost = 0;
 
 while(!queue.isEmpty()){
  Point p = queue.poll();
  visited.add(p);
  
  if(p.Equals(goal)){
   println("Found Path");
   return reconstructPath(points[start_i], goal, parentMap);
  }
  
  for(int i = 0; i < points.length; i++) {
    
   if(!Interference(p, points[i])){
     Point child = points[i];
     float cost = sqrt(sq(p.x-child.x) + sq(p.y - child.y));
     
     if(!visited.contains(child) && !queue.contains(child)){
      child.pathCost = p.pathCost + cost;
      parentMap.put(child, p);
      queue.add(child);
     }
     else if((queue.contains(child)) && (child.pathCost >(p.pathCost + cost))){
       parentMap.put(child, p);
       child.pathCost = p.pathCost + cost;
       queue.remove(child);
       queue.add(child);
     }     
   }
  }
   
 }
 
  return null;
}

/*
// Implent BFS
*/

List<Point> BreadthFirstSearch(int start_i, Point goal){
 Queue<Point> queue = new LinkedList<Point>();
 boolean visited[] = new boolean[12]; 
 visited[start_i] = true;
 Map<Point, Point> parentMap = new HashMap<Point, Point>();
 queue.add(points[start_i]);
 
 while(!queue.isEmpty()){
  Point p = queue.poll(); 

  if(p.Equals(goal)){
    println("found path");
    return reconstructPath(points[start_i], goal, parentMap);
  }
  
  if(list[start_i] == null){
    println("broke");
    break;
  }
  Iterator<Point> iter = list[p.index].listIterator();

  while(iter.hasNext()){
   Point n = iter.next();

   if(!visited[n.index]){
    visited[n.index] = true;
    queue.add(n);
    parentMap.put(n, p);
   }  
  }   
 }
 return null;
}
/*
// Reconstructs the path from the start to the goal by using the created map parent points from the goal back to the start
*/

List<Point> reconstructPath(Point start, Point goal, Map<Point, Point> parentMap){ // Recreates the path to the goal my backtracking through the parent points
  LinkedList<Point> path = new LinkedList<Point>();
  Point currentPoint = goal;
  while(!currentPoint.Equals(start)){
   path.addFirst(currentPoint);
   currentPoint = parentMap.get(currentPoint);
  }
  path.addFirst(start);
 return path; 
}

/*
// Randomly samples points within the given space
*/
void SelectPoints(){ // Randomly select the points within the space
  points[0] = new Point(0, wall, 0); // put the starting position as the first point
 
  for(int i = 1; i < points.length-1; i++) {
    points[i] = new Point((int)random(wall),(int) random(wall), i);
    if(!isValidPoint(points[i])){
      points[i].valid = false;
    }
  }
  points[points.length-1] = new Point(wall, 0, points.length-1); // put end position as last point
}

/*
// A point is valid if it is not within the obstacle.
*/
boolean isValidPoint(Point p){
  float range = pow((p.x - wall/2),2) + pow(p.y - wall/2,2);
  if(range <= pow(circleD/2 + carR/2, 2)){
    return false;
  }  
 return true; 
}

/* 
// Interference checks if there is an obstacles between two points. More specifically, if the agent would run into the obstacle if 
// it were to travel from point a to point b
*/
boolean Interference(Point a, Point b) {
  
  boolean inside1 = pointCircle(a);
  boolean inside2 = pointCircle(b);
  if (inside1 || inside2){
    return true;
  }
  
 float distX = a.x - b.x;
 float distY = a.y - b.y;
 float len = sqrt(sq(distX) + sq(distY));
 
 float dot = (((object.x - a.x) * (b.x - a.x)) + ((object.y - a.y ) * ( b.y - a.y))) / sq(len);
 float closestX = a.x + (dot * (b.x - a.x));
 float closestY = a.y + (dot * (b.y - a.y));
 
 boolean onSegment = linePoint(a, b, closestX,closestY);
  if (!onSegment) return false;
 
 distX = closestX - object.x;
 distY = closestY - object.y;
 float distance = sqrt(sq(distX) + sq(distY));
 if(distance <= (circleD/2 + carR/4)){
  return true; 
 }
 return false;
 
}
/*
// Helper function for interference
*/
boolean pointCircle(Point p) {

  float distX = p.x - (object.x + carR/4);
  float distY = p.y - (object.y + carR/4);
  float distance = sqrt(sq(distX) + sq(distY));

  if (distance <= (circleD/2 + carR/2)) {
    return true;
  }
  return false;
}
/*
// Helper function for interference
*/
boolean linePoint(Point a, Point b, float px, float py) {
  float d1 = dist(px,py, a.x, a.y);
  float d2 = dist(px,py, b.x, b.y);
  float lineLen = dist(a.x, a.y, b.x, b.y);
  float buffer = 0.1;    

  if (d1+d2 >= lineLen-buffer && d1+d2 <= lineLen+buffer) {
    return true;
  }
  return false;
}

/*
// Draws the agent as a cylinder as stated in the checkin requirements
*/
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
for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
    vertex( x, y, -halfHeight);    
}
endShape(CLOSE); 
}

// Set of classes used in program

class Agent{
 float x;
 float y;
 
 Agent(float x_, float y_){
   x= x_;
   y=y_;
 }
 
 void setX(float x_){
   x = x_;
 }
 
 void setY(float y_){
   y = y_;
 }
 
 float distanceTo(Point p){
   
  return sqrt(sq(x - p.x) + sq(y - p.y)); 
 }
}

class Point { 
 
  int x; 
  int y;
  boolean valid = true;
  int index;
  float pathCost;
 
  Point (int x_, int y_, int index_) { 
    x = x_; 
    y = y_;
    index = index_;
  }
  boolean Equals(Point p){
   if(x == p.x && y == p.y){
     return true;
   }
    return false;
  }
}
 
