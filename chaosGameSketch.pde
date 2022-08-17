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
void setup()
{
  size(725,725,P3D);
  vertices=new ArrayList<PVector>();
  angleVariation=new PVector(0,0);

  stroke(255);
  strokeWeight(3);
  translate(width/2,height/2);
  
  initFractal();
  currentPoint=new PVector(vertices.get(0).x,vertices.get(0).y);
  indexes=new int[]{0,0,0};
  n_tracing=0;
  background(bgColor);
}
void draw()
{
  rotationControl();
  translate(width/2,height/2);
  rotateX(angleVariation.x);
  rotateY(angleVariation.y);
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

}

void initFractal()
{
  n_vertices=3;
  background(bgColor);
  polygonRadius=0.9*(width/2);
  createRegularPolygon(n_vertices,polygonRadius);
  ratio=new PVector();

  // float goodVal=(float) n_vertices/(n_vertices+3);

  // ratio.x=goodVal;
  // ratio.y=goodVal;
  
  // ratio.x=(float)   1/1.618;  //1/golden ratio
  // ratio.y=(float)   1/1.618;

  ratio.x=(float)   1/2;
  ratio.y=(float)   1/2;
  
  // ratio.x=(float)   1/2.62205 ;  //1/Khinchin's constant
  // ratio.y=(float)   1/2.62205 ;
  
  // ratio.x=(float)   1/3;
  // ratio.y=(float)   1/3;
  




  rules=new boolean[9];
  rules[0]=false; //il vertice corrente non può essere uguale a quello precedente
  rules[1]=false; //il vertice corrente non può essere posizionato a una posizione antioraria di distanza dal precedente
  rules[2]=false; //il vertice corrente non può essere posizionato a una posizione oraria di distanza dal precedente (uguale a sopra ma specchiato orizzontalmente)
  rules[3]=false; //il vertice corrente non può essere posizionato 2 posizioni antiorarie dal precedente
  rules[4]=false; //il vertice corrente non può essere posizionato 2 posizioni orarie dal precedente (uguale a sopra ma specchiato orizzontalmente)
  rules[5]=false; //il vertice corrente non può essere un vicino del vertice precedente se i due vertici scelti precedentemente sono uguali 
  rules[6]=false; //il vertice corrente non può essere posizionato 2 posizioni distante dal precedente se i 2 vertici precedenti sono uguali
  rules[7]=false; //Il centro del poligono regolare diventa un punto selezionabile
  rules[8]=false; //I punti medi dei lati del poligono regolare diventano punti selezionabili

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
        r=0;
        g=0;
        b=0;
        break;
      
      case 1:
        bgColor=0;
        r=255;
        g=255;
        b=255;
        break;

      case 2:
        bgColor=255;
        magnitude=currentPoint.mag();
        r=200-(200.0*(currentPoint.mag()/(polygonRadius*0.8)));
        g=500.0*(magnitude/(polygonRadius*5));
        b=500.0*(currentPoint.mag()/(polygonRadius*5));
        break;

      case 3:
        bgColor=0;
        magnitude=currentPoint.mag();
        r=200-(200.0*(currentPoint.mag()/(polygonRadius*0.8)));
        g=500.0*(magnitude/(polygonRadius*5));
        b=500.0*(currentPoint.mag()/(polygonRadius*5));
        break;

      default:
        r=0;
        g=0;
        b=0;
        break;
    }
}

void rotationControl()
{
  if(keyPressed)
  {
      if (keyCode==RIGHT)
      {
         angleVariation.y-=angleVariationSpeed;
         background(bgColor);
         n_tracing=0;
      }
      else if(keyCode==LEFT)
      {
        angleVariation.y+=angleVariationSpeed;
         background(bgColor);
         n_tracing=0;
      }
      else if(keyCode==UP)
      {
        angleVariation.x-=angleVariationSpeed;
         background(bgColor);
         n_tracing=0;
      }
      else if(keyCode==DOWN)
      {
        angleVariation.x+=angleVariationSpeed;
         background(bgColor);
         n_tracing=0;
      }

  }
    
}
void mouseWheel(MouseEvent e)
{
  
  if (e.getCount()>0)
  {
    scaleFactor-=0.1;
  }
  else
  {
    scaleFactor+=0.1;
  }
  
  background(bgColor);
  n_tracing=0;
}
void keyReleased()
{
  if (key=='c')
  {
    colorMode+=1;
    if (colorMode>3)
    {colorMode=0;}
    colorLogic();
    background(bgColor);
    n_tracing=0;
  }
  else if(key=='+')
  {
    drawingSpeed+=10;
    if(drawingSpeed>2000)
    {
      drawingSpeed=2000;
    }
    println("drawing speed : "+drawingSpeed);
  }
  else if(key=='-')
  {
    drawingSpeed-=10;
    if(drawingSpeed<0)
    {
      drawingSpeed=1; 
    }
    println("drawing speed : "+drawingSpeed);
  }
}
