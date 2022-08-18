//by Fraiolefano
float mainRatio=1;
PVector mainSize;
String title="Chaos Game";
String author="Fraiolefano";
WindowSection options;
WindowSection mainWindow;
int heightPos=0;

Slider nVertices_o;
Slider scaleFactor_o;
Radio colorMode_o;
TextBox segmentation_o;
CheckBox rules_o;
Button download_o;
TextElem rulesManual_o;

PVector currentPoint;
PVector previousVertex[];
int currentIndex,previousIndex;
int indexes[];    // current, previous, previous previous
ArrayList<PVector> vertices;
float canvasRotation=0;
float angleVariationSpeed=0.05;
float scaleFactor=1;
PVector angleVariation,ratio;
int dice=0;
boolean rules[];
int colorMode=0;
float n_tracing;
float polygonRadius=0;
int bgColor=255;

boolean ignore=false;


float r=0;
float g=0;
float b=0;
float magnitude=0;

int n_vertices=0;
int drawingSpeed=200;

PImage imgToSave;

String imgName;


PImage appIcon;
void setup()
{
  appIcon=loadImage("./data/ChaosGame.png");
  surface.setIcon(appIcon);
  fullScreen();
  textAlign(CENTER);
  mainSize=new PVector(mainRatio*height,height);
  mainWindow=new WindowSection(new PVector(0,0),mainSize);
  mainWindow.bgColor=255;
  options=new WindowSection(new PVector(mainWindow.size.x,0),new PVector(width-mainWindow.size.x,height));
  options.bgColor=0;
  options.stepSize=height/20.0;
  setOptions();
  
  imgToSave=createImage((int)mainWindow.size.x,(int)mainWindow.size.y,RGB);
  
  background(0);
  mainWindow.draw();
  
  
  colorMode=(int)colorMode_o.values.y;

  colorMode=(int)colorMode_o.values.y;


  currentPoint=new PVector(0,0);
  setupFractal();



}

void draw()
{
  //mainWindow.draw();
  
  drawFractal();
  
  if(options.onChange().value)
  {
    if (options.changed.el==download_o)
    {
      saveFractal();
    }
    else
    {
      initFractal();
    }
  }
  

  resetMatrix();
  options.draw();
  

}

void setOptions()
{
  options.scrollRange.x=-5800;
  float centerX=options.size.x/2.0;
  float barW=options.size.x-options.stepSize;
  TextElem title_o=new TextElem(title,new PVector(centerX,options.stepSize));
  title_o.fontSize=30;
  
  TextElem author_o=new TextElem("By "+author,new PVector(centerX,options.stepSize*1.5));
  author_o.fontSize=15;
  
  nVertices_o=new Slider("N. vertices",new PVector(centerX,options.stepSize*3),new PVector(3,10,3),1,barW);
  scaleFactor_o=new Slider("Scale factor",new PVector(centerX,options.stepSize*5),new PVector(0.1,5,1),0.1,barW);
  colorMode_o=new Radio("Color mode",new PVector(centerX,options.stepSize*7),new PVector(7,6));
  colorMode_o.boxDist=options.size.x/colorMode_o.values.x;
  segmentation_o=new TextBox("Segmentation ratio",new PVector(centerX,options.stepSize*10),new PVector(125,50),"0.5");
  segmentation_o.maxLength=5;
  segmentation_o.type="numeric";
  
  rules_o=new CheckBox("Rules",new PVector(centerX,options.stepSize*13),9);
  rules_o.boxDist=options.size.x/rules_o.nBoxes;
  
  download_o=new Button("Save",new PVector(centerX,options.stepSize*15),new PVector(100,50));
  download_o.fontSize=40;



  String text_manual="";
  
  text_manual+="Rule 1 : il vertice corrente non può essere uguale a quello precedente\n";
  text_manual+="----------------------------------------------------------------------\n";
  text_manual+="Rule 2 : il vertice corrente non può essere posizionato a una posizione\n antioraria di distanza dal precedente\n";
  text_manual+="----------------------------------------------------------------------\n";
  text_manual+="Rule 3 : il vertice corrente non può essere posizionato a una posizione\noraria di distanza dal precedente (uguale a sopra ma specchiato \norizzontalmente)\n";
  text_manual+="----------------------------------------------------------------------\n";
  text_manual+="Rule 4 : il vertice corrente non può essere posizionato 2 posizioni\n antiorarie dal precedente\n";
  text_manual+="----------------------------------------------------------------------\n";
  text_manual+="Rule 5 : il vertice corrente non può essere posizionato 2 posizioni \norarie dal precedente (uguale a sopra ma specchiato orizzontalmente)\n";
  text_manual+="----------------------------------------------------------------------\n";
  text_manual+="Rule 6 : il vertice corrente non può essere un vicino del vertice \nprecedente se i due vertici scelti precedentemente sono uguali\n";
  text_manual+="----------------------------------------------------------------------\n";
  text_manual+="Rule 7 : il vertice corrente non può essere posizionato 2 posizioni\n distante dal precedente se i 2 vertici precedenti sono uguali\n";
  text_manual+="----------------------------------------------------------------------\n";
  text_manual+="Rule 8 : Il centro del poligono regolare diventa un punto selezionabile\n";
  text_manual+="----------------------------------------------------------------------\n";
  text_manual+="Rule 9 : I punti medi dei lati del poligono regolare diventano punti \nselezionabili"; 
  rulesManual_o=new TextElem(text_manual,new PVector(centerX,options.stepSize*18));
  rulesManual_o.fontSize=18;

  options.windowElements.add(title_o);
  options.windowElements.add(author_o);
  options.windowElements.add(nVertices_o);
  options.windowElements.add(scaleFactor_o);
  options.windowElements.add(colorMode_o);
  options.windowElements.add(segmentation_o);
  options.windowElements.add(rules_o);
  options.windowElements.add(download_o);
  options.windowElements.add(rulesManual_o);
  
  options.initElements();

  download_o.textPos.y-=3;

}

void mousePressed()
{
for (int c=0;c<options.windowElements.size();c++)
  {
    WindowElem currentEl=options.windowElements.get(c);
    currentEl.mousePressed();
  }
}

void mouseReleased()
{
for (int c=0;c<options.windowElements.size();c++)
  {
    WindowElem currentEl=options.windowElements.get(c);
    currentEl.mouseReleased();
  }
  
}

void keyPressed()
{
for (int c=0;c<options.windowElements.size();c++)
  {
    WindowElem currentEl=options.windowElements.get(c);
    currentEl.keyPressed();
  }
}
void mouseWheel(MouseEvent e)
{
  float delta=-e.getCount()*15;
  options.mouseWheel(delta); 
}

void setupFractal()
{
  vertices=new ArrayList<PVector>();
  angleVariation=new PVector(0,0);
  scaleFactor=scaleFactor_o.range.z;
  
  
  initFractal();
  currentPoint=new PVector(vertices.get(0).x,vertices.get(0).y);
  
  colorLogic();
  mainWindow.draw();
  stroke(r,g,b);
  strokeWeight(3);
  translate(mainWindow.size.x/2,mainWindow.size.y/2);
  
  indexes=new int[]{0,0,0};
  n_tracing=0;
}

void initFractal()
{
  n_vertices=(int) nVertices_o.range.z;
  scaleFactor=scaleFactor_o.range.z;
  colorMode=(int)colorMode_o.values.y;
  colorLogic();
  mainWindow.draw();
  options.draw();
  
  polygonRadius=0.9*(mainWindow.size.x/2);
  createRegularPolygon(n_vertices,polygonRadius);

  float ratioVal=float(segmentation_o.returnValue);
  ratio=new PVector();

  ratio.x=(float)   ratioVal;
  ratio.y=(float)   ratioVal;

  rules=rules_o.values;

  if (rules[7])
  {
    vertices.add(new PVector(0,0));
  }

  if(rules[8])
  {
    for(int n=0;n<n_vertices-1;n++)
    {
      vertices.add( new PVector((vertices.get(n+1).x+vertices.get(n).x)/2.0,(vertices.get(n+1).y+vertices.get(n).y)/2.0) );//vertices[n+1]);
    }
    vertices.add(new PVector((vertices.get(n_vertices-1).x+vertices.get(0).x)/2.0,(vertices.get(n_vertices-1).y+vertices.get(0).y)/2.0));
  }
  n_tracing=0;
}

void createRegularPolygon(int nPoints,float radius)
{
  vertices=new ArrayList<PVector>();
  float angle=(360.0/nPoints)*2*PI /360.0;
  canvasRotation=PI/nPoints;
  if(nPoints%2!=0)
  {
    if (nPoints==3)
    {canvasRotation/=2;}
    else
    {canvasRotation/=-2;}
  }
  rotate(canvasRotation);
  float centerX=0;//width/2.0;
  float centerY=0;//height/2.0;
  for(int p=0;p<nPoints;p++)
  {
    PVector vertex=new PVector(centerX+(radius*cos(angle*p)),centerY+(radius*sin(angle*p)));
    vertices.add(vertex);
  }
}

void drawFractal()
{
  translate(mainWindow.size.x/2,mainWindow.size.y/2);
  rotate(canvasRotation);
  scale(scaleFactor);
  strokeWeight(1/scaleFactor);
  if (n_tracing<2000*500)
  {
    for(int count=0;count < drawingSpeed;count++)
    {
      pointLogic();
      drawPoint();
      n_tracing++;
    }
  }
  else
  {
    println("enough tracing");
  }
  resetMatrix();
}

void pointLogic()
{
  ignore=false;
  dice=floor(random(vertices.size()));
  indexes[0]=dice;
  if(rules[0])  //vertice corrente non può essere uguale a quello precedente
  {
    if(indexes[0]!=indexes[1])
    {
      ignore=false;
    }
    else
    {
      ignore=true;
    }
  }

  if (!ignore)
  {
    if (rules[1]) //vertice corrente non può essere posizionato una posizione antioraria dal precedente
    {
      if (indexes[1]==0)
      {
        if (indexes[0]!=vertices.size()-1)
        {ignore=false;}
        else
        {ignore=true;}
      }
      else
      {
        if(indexes[0]!=indexes[1]-1)
        {ignore=false;}
        else
        {ignore=true;}
      }
    }
  }
  if (!ignore)
  {
    if (rules[2]) //vertice corrente non può essere posizionato una posizione oraria dal precedente
    {
      if (indexes[1]==vertices.size()-1)
      {
        if (indexes[0]!=0)
        {ignore=false;}
        else
        {ignore=true;}
      }
      else
      {
        if(indexes[0]!=indexes[1]+1)
        {ignore=false;}
        else
        {ignore=true;}
      }
    }
  }

  if (!ignore)
  {
    if (rules[3]) //vertice corrente non può essere posizionato 2 posizioni antiorarie dal precedente
    {
      if (indexes[1]<=1)
      {
        if (indexes[0]!=(vertices.size()-2)+indexes[1])
        {ignore=false;}
        else
        {ignore=true;}
      }
      else
      {
        if(indexes[0]!=indexes[1]-2)
        {ignore=false;}
        else
        {ignore=true;}
      }
    }
  }
  if (!ignore)
  {
    if (rules[4]) //vertice corrente non può essere posizionato 2 posizioni orarie dal precedente
    {
      if (indexes[1]>=vertices.size()-2)
      {
        if (indexes[0]!=2-(vertices.size()-indexes[1]))
        {ignore=false;}
        else
        {ignore=true;}
      }
      else
      {
        if(indexes[0]!=indexes[1]+2)
        {ignore=false;}
        else
        {ignore=true;}
      }
    }
  }

  if(!ignore) //vertice corrente non può essere posizionato vicino al precedente se i 2 vertici precedenti sono uguali
  {
    if(rules[5])
    {
      if (indexes[1]==indexes[2])
      {
        int neighbors[]=new int[]{0,0};
        neighbors[0]=indexes[1]-1;
        neighbors[1]=indexes[1]+1;
        if (indexes[1]==0)
        {
          neighbors[0]=vertices.size()-1;
        }
        else if(indexes[1]==vertices.size()-1)
        {
          neighbors[1]=0;
        }

        if(indexes[0]!=neighbors[0] && indexes[0]!=neighbors[1])
        {
          ignore=false;
        }
        else
        {
          ignore=true;
        }
      }
    }
  }

  if(!ignore) //vertice corrente non può essere posizionato 2 posizioni distante dal precedente se i 2 vertici precedenti sono uguali
  {
    if(rules[6])
    {
      if (indexes[1]==indexes[2])
      {
        int neighbors[]=new int[]{0,0};
        neighbors[0]=indexes[1]-2;
        neighbors[1]=indexes[1]+2;
        
        if(indexes[1]<2)
        {
          neighbors[0]=(vertices.size()-2)+indexes[1];
        }
        else if(indexes[1]>=vertices.size()-2)
        {
          neighbors[1]=2-(vertices.size()-indexes[1]);
        }

        if(indexes[0]!=neighbors[0] && indexes[0]!=neighbors[1])
        {
          ignore=false;
        }
        else
        {
          ignore=true;
        }
      }
    }
  }
  setPoint();
}

void setPoint()
{
  if (!ignore)
  {
    currentPoint.x=(currentPoint.x+vertices.get(indexes[0]).x)*ratio.x;
    currentPoint.y=(currentPoint.y+vertices.get(indexes[0]).y)*ratio.y;
    indexes[2]=indexes[1];
    indexes[1]=indexes[0];
  }
}

void drawPoint()
{
  if (!ignore && n_tracing>15)
  {
    colorLogic();
    stroke(r,g,b);
    point(currentPoint.x,currentPoint.y);
  }
}

void colorLogic()
{
  switch(colorMode)
    {
      case 0:
        bgColor=255;
        mainWindow.bgColor=bgColor;
        r=0;
        g=0;
        b=0;
        break;
      
      case 1:
        bgColor=0;
        mainWindow.bgColor=bgColor;
        r=255;
        g=255;
        b=255;
        break;

      case 2:
        bgColor=255;
        mainWindow.bgColor=bgColor;
        magnitude=currentPoint.mag();
        r=200-(200.0*(currentPoint.mag()/(polygonRadius*0.8)));
        g=500.0*(magnitude/(polygonRadius*5));
        b=500.0*(currentPoint.mag()/(polygonRadius*5));
        break;

      case 3:
        bgColor=0;
        mainWindow.bgColor=bgColor;
        magnitude=currentPoint.mag();
        r=200-(200.0*(currentPoint.mag()/(polygonRadius*0.8)));
        g=500.0*(magnitude/(polygonRadius*5));
        b=500.0*(currentPoint.mag()/(polygonRadius*5));
        break;
      case 4:
        bgColor=0;
        mainWindow.bgColor=bgColor;
        r=0;
        g=255;
        b=127;
        break;
      case 5:
        bgColor=0;
        mainWindow.bgColor=bgColor;
        magnitude=currentPoint.mag();
        r=0;
        g= 200-(255*(currentPoint.mag()/((polygonRadius))));
        b=255-(127*(currentPoint.mag()/((polygonRadius))));//255-(g/2);//b=(255*(currentPoint.mag()/(polygonRadius)));
        break;
      case 6:
        bgColor=0;
        mainWindow.bgColor=bgColor;
        magnitude=currentPoint.mag();
        r=0;
        g=200+ (255*(currentPoint.mag()/(polygonRadius)));

        b=100+(127*(currentPoint.mag()/(polygonRadius)));
        
        break;
      default:
        r=0;
        g=0;
        b=0;
        break;
    }
}

void saveFractal()
{
  println("Salvataggio immagine in corso");
  loadPixels();
  
  String rulesName="";
  for(int c=0;c<rules.length;c++)
  {
    rulesName+=int(rules[c]);
  }

  imgName="ChaosGame_"+n_vertices+"_"+segmentation_o.returnValue+"_"+scaleFactor+"_"+colorMode+"_"+rulesName;
  imgToSave=get(0,0,imgToSave.width,imgToSave.height);
  imgToSave.save("./saved/"+imgName+".png");
  
  updatePixels();
  
}
