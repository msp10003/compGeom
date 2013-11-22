ConvexHull convexHull = new ConvexHull();
int edgeCounter = 0;

void setup() {
  size(700, 700, P3D);
  strokeWeight(1);
  ////Temporary input solution////
  vertexPoint v1 = new vertexPoint(10,20,30);
  vertexPoint v2 = new vertexPoint(30,20,60);
  vertexPoint v3 = new vertexPoint(70,10,50);
  vertexPoint v4 = new vertexPoint(-30,-40,20);
  //////
  ///initialize the tetrahedron////
  Face f1 = makeFace(v1, v3, v4);
  f1.name = "Face 1";
  convexHull.addFace(f1);
  Face f2 = makeFace(v1, v2, v3);
  f2.name = "Face 2";
  convexHull.addFace(f2);
  Face f3 = makeFace(v3, v4, v2);
  convexHull.addFace(f3);
  f3.name = "Face 3";
  Face f4 = makeFace(v1, v2, v4);
  convexHull.addFace(f4);
  f4.name = "Face 4";
  //now do the real work, this will eventually be done through a UI rather than hardcoding it///
  //addPoint(v5);
  //display the convex hull//
  convexHull.hullChart();
}

void draw() {

}

void drawNextHull(){
  pushMatrix();
  stroke(10);
  translate(200, height/2, 140);
  rotateY(1.00);
  rotateX(-0.2);
  noFill();
  convexHull.drawHull();
  popMatrix();
}

void keyPressed(){
  vertexPoint v5 = new vertexPoint(100,100,100);
  addPoint(v5);
  
}

void mousePressed(){
  drawNextHull();
}

/*DATA STRUCTURES*/
//represents a 3d point
class vertexPoint{
  int x,y,z;
  vertexPoint(int x1, int y1, int z1){
    this.x = x1;
    this.y = y1;
    this.z = z1;
  }  
}
//a face. maintains references to its vertices and edges
class Face{
  vertexPoint v1,v2,v3;
  Edge e1,e2,e3;
  String name;
  boolean deleted;//update this value when face needs to be removed from convex hull
  boolean newFace;
  public void setDeleted(boolean b){
    this.deleted = b;
  }
  public void setNew(boolean b){
    this.newFace = b;
  }
}
class Edge{
  vertexPoint v1,v2;
  String name;
  Face f1,f2;
  boolean deleted;//update this value when edge needs to be removed from convex hull
  public void setF2(Face f){
    this.f2 = f;
  }
  public void setDeleted(boolean b){
    this.deleted = b;
  }
}
//stores the convex hull. essentially 2 linked lists, one for edges and one for faces
class ConvexHull{
  LinkedList<Face> faceList = new LinkedList<Face>();
  LinkedList<Edge> edgeList = new LinkedList<Edge>();
  public void addFace(Face f){
    this.faceList.add(f);
    Edge[] edgeArray = new Edge[3];
    edgeArray[0]=f.e1;
    edgeArray[1]=f.e2;
    edgeArray[2]=f.e3;
    boolean inList = false;
    for(int j = 0; j<3;j++){
      //check edges first
      for(int i =0; i<edgeList.size();i++){
          if(edgeArray[j].v1 == edgeList.get(i).v1 && edgeArray[j].v2==edgeList.get(i).v2){
            edgeList.get(i).setF2(f); 
            inList = true;
          }
          else if(edgeArray[j].v1 == edgeList.get(i).v2 && edgeArray[j].v2 == edgeList.get(i).v1){
            edgeList.get(i).setF2(f);
            inList = true;
          }
        }
        if(inList==false){
          convexHull.edgeList.add(edgeArray[j]);
        }
        inList = false;
        }
  }
  //draws the hull
  public void drawHull(){
    for(int i =0; i<faceList.size(); i++){
      Face f = faceList.get(i);
      PShape face = createShape();
      beginShape();
        //fill(255,0,100);
        vertex(f.v1.x, f.v1.y, f.v1.z);
        vertex(f.v2.x, f.v2.y, f.v2.z);
        vertex(f.v3.x, f.v3.y, f.v3.z);
      endShape();
      line(f.v1.x, f.v1.y, f.v1.z, f.v3.x, f.v3.y, f.v3.z);
      if(f.newFace == true){
        fill(255,0,150);
        f.setNew(false);
      }
    }
  }
  //prints chart of edges, faces, and vertices
  public void hullChart(){
    System.out.println("EDGE LIST\n");
    for(int i = 0; i<convexHull.edgeList.size();i++){
       System.out.println("Edge: "+edgeList.get(i).name+"  Endpoints: ("+edgeList.get(i).v1.x+","+edgeList.get(i).v1.y+","+edgeList.get(i).v1.z+"),("+
       edgeList.get(i).v2.x+","+edgeList.get(i).v2.y+","+edgeList.get(i).v2.z+")   AdjacentFaces: "+edgeList.get(i).f1.name+" "+edgeList.get(i).f2.name);
    }
  }
}

/*GLOBAL FUNCTIONS*/

public Face makeFace(vertexPoint v1,vertexPoint v2, vertexPoint v3){
    Face f = new Face();
    f.v1 = v1;
    f.v2 = v2;
    f.v3 = v3;
    Edge e1 = makeEdge(v1,v2);
    Edge e2 = makeEdge(v2,v3);
    Edge e3 = makeEdge(v3,v1);
    f.e1 = e1;
    f.e2 = e2;
    f.e3 = e3;
    f.e1.f1 = f;
    f.e2.f1 = f;
    f.e3.f1 = f;
    return f;
}

public Edge makeEdge(vertexPoint v1,vertexPoint v2){
    Edge e = new Edge();
    e.v1 = v1;
    e.v2 = v2;
    e.name = "e"+edgeCounter;
    edgeCounter++;
    return e;
}

/*gets the signed volume, used to determine face visibility*/
int volumeSign(Face f, vertexPoint p){
  double vol;
  double ax, ay, az, bx, by, bz, cx, cy, cz;
  
  ax = f.v1.x - p.x;
  ay = f.v1.y - p.y;
  az = f.v1.z - p.z;
  bx = f.v2.x - p.x;
  by = f.v2.y - p.y;
  bz = f.v2.z - p.z;
  cx = f.v3.x - p.x;
  cy = f.v3.y - p.y;
  cz = f.v3.z - p.z;
  
  vol = ax*(by*cz - bz*cy)
       +ay*(bz*cz - bx*cz)
       +az*(bx*cy - by*cx);
  if(vol>0.5){
    return 1;
  }else if(vol<0.5){
    return -1;
  }else{
    return 0;
  }
}

/*function to be called every time we add a point to the hull*/
public void addPoint(vertexPoint p){
   for(int i =0; i<convexHull.edgeList.size();i++){
     int visibleEdges = 0;
     Edge currentEdge = convexHull.edgeList.get(i);
     if(currentEdge.f1!=null){
       if(volumeSign(currentEdge.f1,p)<0){
         currentEdge.f1.setDeleted(true);
         System.out.println("Face "+currentEdge.f1.name+" will be deleted");
       }else{
         visibleEdges++;
       }
     }
     if(currentEdge.f2!=null){
       if(volumeSign(currentEdge.f2,p)<0){
         currentEdge.f2.setDeleted(true);
         System.out.println("Face "+currentEdge.f2.name+" will be deleted");
       }else{
         visibleEdges++;
     }
     if(visibleEdges==1){
       Face f = makeFace(currentEdge.v1, currentEdge.v2, p);
       f.setNew(true);
       convexHull.addFace(f);
     }else if(visibleEdges == 2){
       currentEdge.setDeleted(true);
     }
  }
}
}
//removes old edges and faces. Incomplete function, does not work yet
public void updateHull(){
  LinkedList<Edge> edges = convexHull.edgeList;
  LinkedList<Face> faces = convexHull.faceList;
  for(int i = 0;i<edges.size(); i++){
    if(edges.get(i).deleted==true){
      edges.remove(edges.get(i));
    }
  }for(int i = 0; i<faces.size();i++){
    faces.remove(faces.get(i));
  }
}
/*LINKED LIST STUFF*/

class Node<E>{
   E elem;
   Node<E> next;
   Node<E> previous;
}
class LinkedList<E>{
  Node<E> head = null;
  Node<E> tail = null;
  Node<E> temp = null; 

  int counter = 0;
  LinkedList(){}
  int size(){return counter;}
  
  public void add(E elem){
     //if we don't have any elems in our LinkedList
     if(head == null){ 
       head = tail = new Node<E>();
       head.elem = elem;
       head.next = tail;
       tail = head;
       }
     else{
      tail.next = new Node<E>(); //add a new node to the end of the list
      tail = tail.next; //set the tail pointer to that node
      tail.elem = elem; //set elem to be stored to the end node
      }  
     counter++;
  }
  public E get(int index){
     //forces the index to be valid
    assert (index >= 0 && index < size());
  
    temp = head; //start at the head of the list
    
    //iterate to the correct node
    for(int i = 0; i < index; i++) temp = temp.next; 
    return temp.elem; //and return the corresponding element
  }
      //returns first index of the given elem
    //returns -1 if elem not found
    public int get(E elem){ 
       return indexOf(elem);
    }

    public int indexOf(E elem){
       temp = head; //start at the beginning of the list
       int i = 0; //create a counter field that isn't local to a loop
    
      //while we haven't found the elem we are looking for, keep looking
       for(; !(temp.elem).equals(elem) && temp != null; i++)
        temp = temp.next;
       if(i == size()) return -1; //if the elem wasn't found, return -1
       return i;   //otherwise, return the index  
    }
        public E remove(E elem){
       temp = head; //start at the beginning of the list
       Node<E> two = null;
    
       if(head.elem.equals(elem)){
           head = head.next;
           head.previous = null;
           counter--;
           return elem;
       }
    
       else if(tail.elem.equals(elem)){
           tail = tail.previous;
           tail.next = null; 
           counter--;
           return elem;
       }
    
      //while the elem hasn't been found but there is another node
       while(temp != null && !temp.elem.equals(elem)){
        two = temp; //have a reference to the element before the one to remove
        temp = temp.next; //in this method, temp will be the elem to remove
       }
    
    //if the element wasn't found, return null
       if(temp == null) return null;
    
       two.next = temp.next;
       E spare = temp.elem; //return element
       temp = null;
       counter--; //decrement size
       return spare;  
    }
}
