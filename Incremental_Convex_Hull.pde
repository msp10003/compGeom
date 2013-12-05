import controlP5.*;
import peasy.*;
PeasyCam cam;
PGraphics3D g3;
PMatrix3D currCameraMatrix;
ControlP5 cp5;
int sequenceNum = 0;
ConvexHull convexHull = new ConvexHull();
int faceCounter=1;
int edgeCounter=1;
int initX =0;
int initY =0;
int initZ =0;
Vertex centroid = new Vertex(0,0,0);
Vertex currentPoint;
boolean highlightFaces = false;
boolean nextActive = false;
float angleX, angleY, angleZ, eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ, orbitRadius, horizRotation;
ListBox hullChart, faceChart;
Textfield textX,textY, textZ, x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4;
Button addPointButton,initializeHullButton;
Group mainControls, initialControls;
Textlabel guideText;
boolean lockVisual = true;
/////////////
// camera position and focus variables
PVector camP = new PVector(0, 1200, 700); // camera position
PVector camF_abs = new PVector();     // camera focus (absolute position)
PVector camF_rel = new PVector();     // camera focus (relative vector)
float camDir, camElev;                // last camera bearing/elevation angles
float mx, my;                         // last mouse X/Y
float MouseX, MouseY;                 // replicate inbuilt mouse variables
float scaleY;                         // scale mouseY inputs to vertical movement
float scaleX;                         // scale mouseX inputs to horizontal movement
int direction = 0;                    // code for controling movement
float moveSpeed = 10;
///////////////////////
public void setup(){
  size(1200,700,P3D);
  angleX = 0;
  angleY = -0.1;
  angleZ = -0.8;
  strokeWeight(1);
  hint(ENABLE_NATIVE_FONTS);
  //////////////////////
  scaleY = PI/height;
  scaleX = 2*PI/width;
  camDir = PI/3;
  camElev = PI/2;
  MouseX = width/2;
  MouseY = height/3;
  turnCamera();
  camF_rel = setVector(camDir, camElev);
  /////////////////////
  cp5 = new ControlP5(this);
  mainControls = cp5.addGroup("Controls");
  initialControls = cp5.addGroup("initialControls");
  cp5.addButton("NEXT").setSize(200,19).setPosition(25,675).setGroup(mainControls);
  addPointButton = cp5.addButton("ADD_POINT").setSize(200,19).setPosition(25,655).setGroup(mainControls);
  cp5.addButton("RotatePositiveY").setSize(98,38).setPosition(550,615).setGroup(mainControls);
  cp5.addButton("RotatePositiveX").setSize(98,38).setPosition(450,615).setGroup(mainControls);
  cp5.addButton("RotateNegativeY").setSize(98,38).setPosition(550,655).setGroup(mainControls);
  cp5.addButton("RotateNegativeX").setSize(98,38).setPosition(450,655).setGroup(mainControls);
  cp5.addButton("RotatePositiveZ").setSize(98,38).setPosition(650,615).setGroup(mainControls);
  cp5.addButton("RotateNegativeZ").setSize(98,38).setPosition(650,655).setGroup(mainControls);
  cp5.addButton("PanRight").setSize(98,38).setPosition(850,615).setGroup(mainControls);
  cp5.addButton("PanLeft").setSize(98,38).setPosition(750,615).setGroup(mainControls);
  cp5.addButton("ClearHull").setSize(150,38).setPosition(250,655).setGroup(mainControls).setColorBackground(color(255,0,0));
  textX = cp5.addTextfield("X").setSize(30,20).setPosition(50,600).setGroup(mainControls);
  textY = cp5.addTextfield("Y").setSize(30,20).setPosition(100,600).setGroup(mainControls);
  textZ = cp5.addTextfield("Z").setSize(30,20).setPosition(150,600).setGroup(mainControls);
  textX.captionLabel().setColor(color(0,155));
  textY.captionLabel().setColor(color(0,155));
  textZ.captionLabel().setColor(color(0,155));
  hullChart = cp5.addListBox("edges").setPosition(770,50).setSize(390,250).setItemHeight(20).setBarHeight(15).setGroup(mainControls);
  faceChart = cp5.addListBox("faces").setPosition(770,325).setSize(390,250).setItemHeight(20).setBarHeight(15).setGroup(mainControls);
  mainControls.setVisible(false);
  x1 = cp5.addTextfield("X1").setSize(30,20).setPosition(450,300).setGroup(initialControls);
  x2 = cp5.addTextfield("X2").setSize(30,20).setPosition(450,335).setGroup(initialControls);
  x3 = cp5.addTextfield("X3").setSize(30,20).setPosition(450,370).setGroup(initialControls);
  x4 = cp5.addTextfield("X4").setSize(30,20).setPosition(450,405).setGroup(initialControls);
  y1 = cp5.addTextfield("Y1").setSize(30,20).setPosition(480,300).setGroup(initialControls);
  y2 = cp5.addTextfield("Y2").setSize(30,20).setPosition(480,335).setGroup(initialControls);
  y3 = cp5.addTextfield("Y3").setSize(30,20).setPosition(480,370).setGroup(initialControls);
  y4 = cp5.addTextfield("Y4").setSize(30,20).setPosition(480,405).setGroup(initialControls);
  z1 = cp5.addTextfield("Z1").setSize(30,20).setPosition(510,300).setGroup(initialControls);
  z2 = cp5.addTextfield("Z2").setSize(30,20).setPosition(510,335).setGroup(initialControls);
  z3 = cp5.addTextfield("Z3").setSize(30,20).setPosition(510,370).setGroup(initialControls);
  z4 = cp5.addTextfield("Z4").setSize(30,20).setPosition(510,405).setGroup(initialControls);
  initializeHullButton = cp5.addButton("initialize").setSize(100,20).setPosition(445,460).setGroup(initialControls);
  x1.captionLabel().setColor(color(0,155));
  x2.captionLabel().setColor(color(0,155));
  x3.captionLabel().setColor(color(0,155));
  x4.captionLabel().setColor(color(0,155));
  y1.captionLabel().setColor(color(0,155));
  y2.captionLabel().setColor(color(0,155));
  y3.captionLabel().setColor(color(0,155));
  y4.captionLabel().setColor(color(0,155));
  z1.captionLabel().setColor(color(0,155));
  z2.captionLabel().setColor(color(0,155));
  z3.captionLabel().setColor(color(0,155));
  z4.captionLabel().setColor(color(0,155));
  guideText = cp5.addTextlabel("guideText").setPosition(300,220).setColor(color(0,155)).setFont(createFont("Verdana",18));
  guideText.setText("           INCREMENTAL CONVEX HULL\n\nSelect 4 Points to initialize the tetrahedron");
  convexHull.outputHull();
}
public void drawNewHull(){
  pushMatrix();
  //camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
  stroke(10);
  background(206,206,206);
  MouseX = constrain(mouseX, 0, width);
  MouseY = constrain(mouseY, 0, height);
  setCamera();
  camera(camP.x, camP.y, camP.z, camF_abs.x, camF_abs.y, camF_abs.z, 0, 0, -1);
  //translate(200, height/2, 140);
  rotateY(angleY);
  rotateX(angleX);
  rotateZ(angleZ);
  //noFill();
  for(int i =0;i<convexHull.updateList.size();i++){
    Edge e =convexHull.updateList.get(i);
    stroke(157,57,153);
    strokeWeight(3);
    line(e.v1.x,e.v1.y,e.v1.z,currentPoint.x,currentPoint.y,currentPoint.z);
    line(e.v2.x,e.v2.y,e.v2.z,currentPoint.x,currentPoint.y,currentPoint.z);
    stroke(10);
    strokeWeight(1);
  }
  for(int i = 0; i<convexHull.faceList.size();i++){
    fill(255,255,255);
    Face f = convexHull.faceList.get(i);
    if(highlightFaces==true){
      if(f.visible==true){
        fill(200,200,100);
      }
    }
    if(f.newFace==true){
      fill(54,234,5);
      //f.newFace = false;
    }
    if(f.selected==true){
      fill(25,25,200);
      f.selected = false;
    }
    beginShape();
        vertex(f.v1.x, f.v1.y, f.v1.z);
        vertex(f.v2.x, f.v2.y, f.v2.z);
        vertex(f.v3.x, f.v3.y, f.v3.z);
    endShape();
    line(f.v1.x, f.v1.y, f.v1.z, f.v3.x, f.v3.y, f.v3.z);
  }
  for(int i =0; i<convexHull.edgeList.size();i++){
      Edge e = convexHull.edgeList.get(i);
      if(e.selected==true){
        strokeWeight(4);
        stroke(204,204,0);
        line(e.v1.x,e.v1.y,e.v1.z,e.v2.x,e.v2.y,e.v2.z);
        e.selected = false;
        strokeWeight(1);
        stroke(10);
      }
    }
    //draw axes
  strokeWeight(2);
  stroke(0,0,255);
  line(999999,0,0,0,0,0);
  stroke(255,0,0);
  line(-999999,0,0,0,0,0);
  stroke(0,0,255);
  line(0,0,0,0,999999,0);
  stroke(255,0,0);
  line(0,0,0,0,-9999999,0);
  stroke(0,0,255);
  line(0,0,0,0,0,999999);
  stroke(255,0,0);
  line(0,0,0,0,0,-999999);
  strokeWeight(1);
  stroke(10);
  popMatrix();
}

/*structs and stuff*/
public class Vertex{
  int x, y, z;
  String identifier;
  public Vertex(int xC, int yC, int zC){
    this.x = xC;
    this.y = yC;
    this.z = zC;
    identifier = x+"."+y+"."+z;
  }
}
public class Edge{
  Vertex v1, v2;
  Face f1,f2;
  String name;
  boolean selected;
  boolean update=true;
  boolean deleted = false;
  String identifier = "";
  public Edge(Vertex ver1,Vertex ver2){
    this.v1 = ver1;
    this.v2 = ver2;
    identifier = ver1.identifier+"."+ver2.identifier;
    name = "";
    selected = false;
  }
  public boolean equalz(Edge e){
    boolean b = false;
    //System.out.println(identifier+"  "+e.identifier);
    if(identifier.equals(e.identifier)){
      //System.out.println("edge already exists");
      b = true;
    }else if(identifier.equals(e.v2.identifier+"."+e.v1.identifier)){
      //System.out.println("edge is already here");
      b = true;
    }
    return b;
  }
}
public class Face{
  String name;
  Vertex v1,v2,v3;
  Edge e1,e2,e3;
  boolean visible,newFace,selected;
  public Face(Vertex ver1,Vertex ver2,Vertex ver3){
    this.v1 = ver1;
    this.v2 = ver2;
    this.v3 = ver3;
  }
  public Face(Vertex ver1, Vertex ver2, Vertex ver3, boolean b){
    this.v1 = ver1;
    this.v2 = ver2;
    this.v3 = ver3;
    Edge edge1 = new Edge(v1,v2);
    Edge edge2 = new Edge(v2,v3);
    Edge edge3 = new Edge(v3,v1);
    this.e1 = edge1;
    this.e2 = edge2;
    this.e3 = edge3;
    e1.f1 = this;
    e2.f1 = this;
    e3.f1 = this;
    newFace = false;
    selected = false;
  }
}
public class ConvexHull{
  ArrayList<Edge> updateList;
  ArrayList<Face> visibleFacesList;
  ArrayList<Edge> deletedEdgesList;
  ArrayList<Vertex> vertexList;
  ArrayList<Edge> edgeList;
  ArrayList<Face> faceList;
  public ConvexHull(){
    updateList = new ArrayList<Edge>();
    visibleFacesList = new ArrayList<Face>();
    deletedEdgesList = new ArrayList<Edge>();
    vertexList = new ArrayList<Vertex>();
    edgeList = new ArrayList<Edge>();
    faceList = new ArrayList<Face>();
  }
  public void initializeHull(Vertex v1, Vertex v2, Vertex v3, Vertex v4){
    int cx = (v1.x+v2.x+v3.x+v4.x)/4;
    int cy = (v1.y+v2.y+v3.y+v4.y)/4;
    int cz = (v1.z+v2.z+v3.z+v4.z)/4;
    System.out.println(cx+"  "+cy+"  "+cz);
    centroid.x = cx;
    centroid.y = cy;
    centroid.z = cz;
    Face f1 = new Face(v1,v2,v3,true);
    faceList.add(f1);
    edgeList.add(f1.e1);
    f1.e1.name = "edge1";
    f1.e1.selected = false;
    edgeList.add(f1.e2);
    f1.e2.name = "edge2";
    f1.e2.selected = false;
    edgeList.add(f1.e3);
    f1.e3.name = "edge3";
    f1.e3.selected =false;
    edgeCounter = 4 ;
    f1.name = "face1";
    faceCounter++;
    addNewFace(v1,v4,v2);
    addNewFace(v1,v4,v3);
    addNewFace(v2,v4,v3);
    centerX = centroid.x-225;
    centerY = centroid.y;
    centerZ = centroid.z;
    System.out.println("Cetroid: "+centroid.x+","+centroid.y+","+centroid.z);
      for (int i=0;i<convexHull.edgeList.size();i++) {
        Edge e = convexHull.edgeList.get(i);
        ListBoxItem lbi = hullChart.addItem(e.name+
                                       "     v1: ("+e.v1.x+","+e.v1.y+","+e.v1.z+")"+
                                       "  v2: ("+e.v2.x+","+e.v2.y+","+e.v2.z+")"+
                                       " Face:   "+e.f1.name+
                                       " AdjFace:   "+e.f2.name, i);
        lbi.setColorBackground(0xffff0000);
      }
      for (int i=0;i<convexHull.faceList.size();i++){
        Face f = convexHull.faceList.get(i);
        ListBoxItem lbi = faceChart.addItem(f.name+
                                      "   v1: ("+f.v1.x+","+f.v1.y+","+f.v1.z+")"+
                                      "   v2: ("+f.v2.x+","+f.v2.y+","+f.v2.z+")"+
                                      "   v3: ("+f.v3.x+","+f.v3.y+","+f.v3.z+")"+
                                      "    Edges: ["+f.e1.name+","+f.e2.name+","+f.e3.name+"]",i);
        lbi.setColorBackground(color(164,220,7));
      }
      convexHull.outputHull();
  }
  public Face addNewFace(Vertex v1, Vertex v2, Vertex v3){
    Face f2 = new Face(v1,v2,v3,true);
    for(int i =0; i<edgeList.size();i++){
      if(edgeList.get(i).equalz(f2.e1)){
        f2.e1 = edgeList.get(i);
        f2.e1.update = false;
        f2.e1.f2 = edgeList.get(i).f1;  
        edgeList.get(i).f2 = f2;
      }if(edgeList.get(i).equalz(f2.e2)){
        f2.e2 = edgeList.get(i);
        f2.e2.update = false;
        f2.e2.f2 = edgeList.get(i).f1;
        edgeList.get(i).f2 = f2;
      }if(edgeList.get(i).equalz(f2.e3)){
        f2.e3 = edgeList.get(i);
        f2.e3.update = false;
        f2.e3.f2 = edgeList.get(i).f1;
        edgeList.get(i).f2 = f2;
      }
    }
    if(f2.e1.update==true){
        edgeList.add(f2.e1);
        f2.e1.name = "edge"+edgeCounter;
        edgeCounter++;
        f2.e1.update = false;
      }
      if(f2.e2.update==true){
        edgeList.add(f2.e2);
        f2.e2.name = "edge"+edgeCounter;
        edgeCounter++;
        f2.e2.update = false;
      }
      if(f2.e3.update==true){
        edgeList.add(f2.e3);
        f2.e3.name = "edge"+edgeCounter;
        edgeCounter++;
        f2.e3.update = false;
      }
      f2.name = "face"+faceCounter;
      faceList.add(f2);
      faceCounter++;
      return f2;
  }
  public void outputHull(){
    for(int i =0;i<edgeList.size();i++){
      System.out.println("Edge: "+edgeList.get(i).identifier+" Face: "+edgeList.get(i).f1.name+" AdjFace: "+edgeList.get(i).f2.name);
    }
  }
  public boolean addNewPoint(Vertex v1){
    int numVisibleFaces=0;
    System.out.println("size of the face list: "+faceList.size());
    for(int i =0;i<faceList.size();i++){
      System.out.println("======="+faceList.get(i).name+"============");
      if(volumeSign(faceList.get(i),v1)<0){
        System.out.println(faceList.get(i).name+" is visible");
        faceList.get(i).visible = true;
        visibleFacesList.add(faceList.get(i));
        numVisibleFaces++;
      }else{
        System.out.println(faceList.get(i).name+" is not visible");
        faceList.get(i).visible = false;
      }
    }
    System.out.println("print out the faces volumes");
    if(numVisibleFaces==0){
      System.out.println("Point is inside the hull");
      return false;
    }else{
      updateHull(v1);
    }
    return true;
  }
  public void updateHull(Vertex v1){
    System.out.println("current edge list size: "+edgeList.size());
    for(int i = 0;i<edgeList.size();i++){
      System.out.println("Next edge "+edgeList.get(i).f1.name);
      System.out.println("Next edge "+edgeList.get(i).f2.name);
      boolean a = edgeList.get(i).f1.visible;
      boolean b = edgeList.get(i).f2.visible;
      if(a==true && b==true){
        System.out.println("throw out this edge");
        edgeList.get(i).deleted = true;
        deletedEdgesList.add(edgeList.get(i));
      }else if(a==true && b==false){
        System.out.println("this edge should stay as part of a new face");
        edgeList.get(i).f1 = edgeList.get(i).f2;
        updateList.add(edgeList.get(i));
      }else if(a==false && b == true){
        System.out.println("this edge should stay as part of a new face");
        edgeList.get(i).f2 = edgeList.get(i).f1;
        updateList.add(edgeList.get(i));
      }
      else{
        System.out.println("edge is totally invisible");
      }
    }
    System.out.println("current update list size " +updateList.size());
    //deleteOldStuff();
    //makeConeFaces(v1);
  }
  public void deleteOldStuff(){
    for(int i =0;i<visibleFacesList.size();i++){
      System.out.println("visible faces: "+visibleFacesList.get(i).name);
    }
    for(int i =0;i<visibleFacesList.size();i++){
      System.out.println("get RID OF "+visibleFacesList.get(i).name);
      faceList.remove(visibleFacesList.get(i));
    }
    visibleFacesList.clear();
    for(int j=0;j<deletedEdgesList.size();j++){
      System.out.println("Get RID OF EDGE with "+deletedEdgesList.get(j).f1.name+" and "+deletedEdgesList.get(j).f2.name);
      edgeList.remove(deletedEdgesList.get(j));
    }
    deletedEdgesList.clear();
  }
  public void makeConeFaces(Vertex v1){
    for(int i = 0;i<updateList.size();i++){
      Face f =addNewFace(updateList.get(i).v1,updateList.get(i).v2, v1);
      f.newFace = true;
    }
    updateList.clear();
  }
  public void clearHull(){
    edgeList.clear();
    faceList.clear();
    visibleFacesList.clear();
    updateList.clear();
    deletedEdgesList.clear();
    vertexList.clear();
    centroid = new Vertex(0,0,0);
     guideText = cp5.addTextlabel("guideText").setPosition(300,250).setColor(color(0,155)).setFont(createFont("Verdana",18));
  guideText.setText("Select 4 Points to initialize the tetrahedron");
 
  }
}

public void clearAll(){
  convexHull.clearHull();
  faceCounter = 1;
  edgeCounter = 1;
}

public Face orientCCW(Face f){
  System.out.println("centroid x: "+centroid.x+" centroid y: "+centroid.y+" centroid z: "+centroid.z);
  Face newFace = new Face(f.v1,f.v2,f.v3,true);
  float vol;
  float a, b, c, d, e, f1, g, h, i;
  
  a = f.v1.x - centroid.x;
  b = f.v1.y - centroid.y;
  c = f.v1.z - centroid.z;
  d = f.v2.x - centroid.x;
  e = f.v2.y - centroid.y;
  f1 = f.v2.z - centroid.z;
  g = f.v3.x - centroid.x;
  h = f.v3.y - centroid.y;
  i = f.v3.z - centroid.z;

  vol = a*(e*i - f1*h)
       -b*(d*i - f1*g)
       +c*(d*h - e*g);
  System.out.println(vol);
  if(vol>0.5){
    return newFace;
  }else if(vol<-0.5){
    System.out.println("reorient the vertices");
    Vertex tempVert = newFace.v1;
    newFace.v1 = newFace.v3;
    newFace.v3 = tempVert;
    return newFace;
  }else{
    return newFace;
  }
}

/*gets the signed volume, used to determine face visibility*/
int volumeSign(Face f, Vertex p){
  System.out.println(f.v1.identifier+"   "+f.v2.identifier+"    "+f.v3.identifier);
  f = orientCCW(f);
  System.out.println(f.v1.identifier+"   "+f.v2.identifier+"    "+f.v3.identifier);
  float vol;
  float ax, ay, az, bx, by, bz, cx, cy, cz;
  
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
       +ay*(bz*cx - bx*cz)
       +az*(bx*cy - by*cx);
    System.out.println(vol);
  if(vol>0.5){
    return 1;
  }else if(vol<-0.5){
    return -1;
  }else{
    return 0;
  }
}
public void draw(){
}
/*public void keyPressed(){
  if(key == CODED){
    if(keyCode==RIGHT){
      RotateRight();
    }else if(keyCode==LEFT){
      RotateLeft();
    }else if(keyCode==UP){
      RotateUp(); 
    }else if(keyCode==DOWN){
      RotateDown();
    }
  } 
}*/
/*GUI STUFF*/
public void NEXT(){
  if(nextActive == true){
    System.out.println("you clicked the button!");
    if(sequenceNum==0){
      System.out.println("highlight the faces");
      highlightFaces=true;
      drawNewHull();
      String s="";
      for(int i=0;i<convexHull.visibleFacesList.size();i++){
        s = s+convexHull.visibleFacesList.get(i).name+",  ";
      }
      guideText.setText("We perform a signed volume test on each face to find which faces are visible:\n"+
                  "The following faces give a negative signed volume and are visible to the point:\n"+s);
      sequenceNum++;
    }else if(sequenceNum==1){
      highlightFaces=false;
      System.out.println("draw the cone faces");
      convexHull.deleteOldStuff();
      convexHull.makeConeFaces(currentPoint);
      drawNewHull();
      guideText.setText("We delete the visible faces and add new faces connecting the old hull to the new point");
      sequenceNum++;
    }else if(sequenceNum==2){
      System.out.println("draw the final hull");
      for(int i=0;i<convexHull.faceList.size();i++){
        convexHull.faceList.get(i).newFace = false;
      }
      hullChart.clear();
      faceChart.clear();
      for (int i=0;i<convexHull.edgeList.size();i++) {
        Edge e = convexHull.edgeList.get(i);
        ListBoxItem lbi = hullChart.addItem(e.name+
                                       "     v1: ("+e.v1.x+","+e.v1.y+","+e.v1.z+")"+
                                       "  v2: ("+e.v2.x+","+e.v2.y+","+e.v2.z+")"+
                                       "     Face:   "+e.f1.name+
                                       "  AdjFace:   "+e.f2.name, i);
        lbi.setColorBackground(0xffff0000);
      }
      for (int i=0;i<convexHull.faceList.size();i++){
        Face f = convexHull.faceList.get(i);
        ListBoxItem lbi = faceChart.addItem(f.name+
                                      "   v1: ("+f.v1.x+","+f.v1.y+","+f.v1.z+")"+
                                      "   v2: ("+f.v2.x+","+f.v2.y+","+f.v2.z+")"+
                                      "   v3: ("+f.v3.x+","+f.v3.y+","+f.v3.z+")"+
                                      "    Edges: ["+f.e1.name+","+f.e2.name+","+f.e3.name+"]",i);
        lbi.setColorBackground(color(163,220,7));
      }
      drawNewHull();
      sequenceNum=0;
      nextActive = false;
      guideText.setText("The new convex hull");
      textZ.setVisible(true);
      textX.setVisible(true);
      textY.setVisible(true);
      addPointButton.setVisible(true);
    }
  }
}
public void ADD_POINT(){
  String xStr = cp5.get(Textfield.class,"X").getText();
  String yStr = cp5.get(Textfield.class,"Y").getText();
  String zStr = cp5.get(Textfield.class,"Z").getText();
  int xC = Integer.parseInt(xStr);
  int yC = Integer.parseInt(yStr);
  int zC = Integer.parseInt(zStr);
  System.out.println("adding point");
  Vertex v = new Vertex(xC,yC,zC);
  currentPoint = v;
  boolean outOfHull = convexHull.addNewPoint(v);
  if(outOfHull==false){
    guideText.setPosition(100,100);
    guideText.setText("Point is already inside the hull");
    return;
  }
  drawNewHull();
  nextActive = true;
  textX.clear();
  textY.clear();
  textZ.clear();
  textZ.setVisible(false);
  textX.setVisible(false);
  textY.setVisible(false);
  addPointButton.setVisible(false);
  guideText.setPosition(50,50);
  guideText.setText("We draw lines to show which faces are visible to the new point");
}
public void RotatePositiveY(){
  angleY = angleY+0.15;
  drawNewHull();
}
public void RotateNegativeY(){
  angleY = angleY-0.15;
  drawNewHull();
}
public void RotatePositiveX(){
  angleX = angleX + 0.15;
  drawNewHull();
}
public void RotateNegativeX(){
  angleX = angleX - 0.15;
  drawNewHull();
}
public void RotatePositiveZ(){
  angleZ = angleZ + 0.15;
  drawNewHull();
}
public void RotateNegativeZ(){
  angleZ = angleZ - 0.15;
  drawNewHull();
}
public void PanRight(){
  centerX = centerX+10;
  drawNewHull();
}
public void PanLeft(){
  centerX = centerX-10;
  drawNewHull();
}
public void ClearHull(){
  clearAll();
  hullChart.clear();
  faceChart.clear();
  mainControls.setVisible(false);
  initialControls.setVisible(true);
  sequenceNum = 0;
  nextActive = false;
  drawNewHull();
  guideText.setPosition(300,250);
}
public void initialize(){
  System.out.println("initialize the hull");
  int xC = Integer.parseInt(x1.getText());
  int yC = Integer.parseInt(y1.getText());
  int zC = Integer.parseInt(z1.getText());  
  Vertex v1 = new Vertex(xC,yC,zC);
  xC = Integer.parseInt(x2.getText());
  yC = Integer.parseInt(y2.getText());
  zC = Integer.parseInt(z2.getText());  
  Vertex v2 = new Vertex(xC,yC,zC);
  xC = Integer.parseInt(x3.getText());
  yC = Integer.parseInt(y3.getText());
  zC = Integer.parseInt(z3.getText());  
  Vertex v3 = new Vertex(xC,yC,zC);
  xC = Integer.parseInt(x4.getText());
  yC = Integer.parseInt(y4.getText());
  zC = Integer.parseInt(z4.getText());  
  Vertex v4 = new Vertex(xC,yC,zC);
  convexHull.initializeHull(v1,v2,v3,v4);
  x1.clear(); x2.clear(); x3.clear(); x4.clear();
  y1.clear(); y2.clear(); y3.clear(); y4.clear();
  z1.clear(); z2.clear(); z3.clear(); z4.clear();
  mainControls.setVisible(true);
  initialControls.setVisible(false);
  guideText.setPosition(25,25).setFont(createFont("Verdana",12));
  guideText.setText("Add a new point to grow the hull");
  drawNewHull();
}
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup() && theEvent.name().equals("faces")) {
    // an event from a group e.g. scrollList
    println(theEvent.group().value()+" from "+theEvent.group());
    int a = (int) theEvent.group().value();
    System.out.println(convexHull.faceList.get(a).name);
    convexHull.faceList.get(a).selected = true;
    drawNewHull();
  }
  if(theEvent.isGroup() && theEvent.name().equals("edges")){
    println(theEvent.group().value()+" from"+theEvent.group());
    int a = (int) theEvent.group().value();
    System.out.println(convexHull.edgeList.get(a).name);
    convexHull.edgeList.get(a).selected = true;
      for(int i =0;i<convexHull.edgeList.size();i++){
    System.out.println(convexHull.edgeList.get(i).name+"  "+convexHull.edgeList.get(i).selected);
  }
    drawNewHull();
  }
}
/*Camera*/
void setCamera() {
  camF_rel = setVector(camDir, camElev);
  if (direction >= 1 & direction <= 4) moveCamera(moveSpeed);
  if (direction >= 5 & direction <= 6) elevCamera(moveSpeed);
 
  camF_abs = camF_rel.get();
  camF_abs.add(camP);
}
 
 
PVector setVector(float dir, float elev){
  //generic function to calculate the PVector based on radial coordinates
  PVector v = new PVector(cos(dir), sin(dir), 0);
  float fz = -sin(elev);
  float fy = sqrt(1-pow(fz, 2));
  v.mult(fy);
  v.z = fz;
  return(v);
}
 
 
void moveCamera (float speed) {
  PVector moveto = new PVector();
 
  // left / right movement
  if (direction%2 == 0) {
    float dir = 0;
    if (direction == 2) dir = camDir + PI/2;  // right
    else                dir = camDir - PI/2;  // left
    PVector v = setVector(dir, 0);
    v.mult(speed);
    camP.add(v);
  }
 
  // forward / backward movement
  else {
    moveto = camF_rel.get();
    if (direction == 1) moveto.mult(-1); // forward
  }
 
  moveto.normalize();
  moveto.mult(speed);
  camP.sub(moveto);
}
void turnCamera(){
  float x = MouseX - mx;
  float x_scaled = x * scaleX;
  float y = MouseY - my;
  float y_scaled = y * scaleY;
  camDir += x_scaled;
  camElev += y_scaled;
  mx = MouseX;
  my = MouseY;
}
void elevCamera (float speed) {
  if (direction == 5) {  // lower camera
    camP.z -= speed;               
    camF_abs.z -= speed;
  }
  else {                 // raise camera
    camP.z += speed;               
    camF_abs.z += speed;
  }
}
 
 
void keyPressed() {
  if(keyCode == 38 | key == 'w'){ direction = 1;
    drawNewHull();  
  }  // move forward
  else if (keyCode == 39 | key == 'd'){
    direction = 2;  // move right
    drawNewHull();
  }else if (keyCode == 40 | key == 's'){
    direction = 3;  // move backward
    drawNewHull();
  }else if (keyCode == 37 | key == 'a'){
    direction = 4;  // move left
    drawNewHull();    
  }else if (key == 'z'){
    direction = 5;  // lower camera
    drawNewHull();
  }else if (key == 'x'){
    direction = 6;  // raise camera
    drawNewHull();
  }else if (key =='y'){
    if(lockVisual==true){
      lockVisual = false;
    }else{
      lockVisual = true;
    }
    drawNewHull();
  }else if(key=='q'){
    RotatePositiveX();
  }else if(key=='e'){
    RotateNegativeX();
  }else if(key=='r'){
    RotatePositiveY();
  }else if(key=='t'){
    RotateNegativeY();
  }else if(key=='c'){
    RotatePositiveZ();
  }else if(key=='v'){
    RotateNegativeZ();
  }
  
}
void keyReleased() {
  direction = 0;
} 
void mouseMoved() {
  if(lockVisual==false){  // turns the camera
    //System.out.println("turn the camera");
    turnCamera();
    drawNewHull();
  }
}
