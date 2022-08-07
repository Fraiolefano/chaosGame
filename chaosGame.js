//By Fraiolefano

var currentPoint;
var indexes=[0,0,0];    // current, previous, previous previous
var vertices=[];
var canvasRotation=0;
var scaleFactor;
var rules=[];
var n_tracing=0;
var bgColor=255;

var ignore=false;


var colorModee=0;
var r=0;
var g=0;
var b=0;
var magnitude=0;

var n_vertices=3;
var ratio,lastValidRatio;
var angleVariation;
var bgColor;
var sliderScale;

var drawingSpeed;
var preSlidersValue=[3,1,0];
var pointWeight=1;
var enough=false;
var max_tracing=2000*5000;
function setup()
{
  pixelDensity(1);
  createCanvas(window_size,window_size,WEBGL);
  angleVariation=new p5.Vector(0,0);
  ratio=new p5.Vector(0.5,0.5);
  background(bgColor);
  pointWeight=1;
  scaleFactor=1;
  strokeWeight(0.5);
  initFractal();
}
function draw()
{
  rotate(canvasRotation);

  if (n_tracing<max_tracing*scaleFactor)
  {
    for(let count=0;count < 200;count++) //2000
    {
      pointLogic();
      drawPoint();
      n_tracing++;
    }
  }
  else
  {
    enough=true;
  }
  manageSliders();
}
function createRegularPolygon()
{
  polygonRadius=(0.9*(width/2))*scaleFactor;
  let angle=(360.0/n_vertices)*2*PI /360.0;
  canvasRotation=PI/n_vertices;
  if(n_vertices%2!=0)
  {
    if (n_vertices==3)
    {canvasRotation/=2;}
    else
    {canvasRotation/=-2;}
  }

  for (let n=0;n<n_vertices;n++)
  {
    let vX=polygonRadius*cos(angle*n);
    let vY=polygonRadius*sin(angle*n);
    vertices[n]=new p5.Vector(vX,vY);
  }
}

function initFractal()
{
  enough=false;
  n_tracing=0;
  vertices=[];
  indexes=[0,0,0];

  manageInput();
  colorLogic();
  createRegularPolygon();

  
  pointWeight=3*scaleFactor;
  if (pointWeight<=3)
  {
    pointWeight=1;
  }
  else
  {
    pointWeight=3;
  }
  strokeWeight(0.5);

  drawingSpeed=2000;
  // rules[0]=false; //il vertice corrente non può essere uguale a quello precedente
  // rules[1]=false; //il vertice corrente non può essere posizionato a una posizione antioraria di distanza dal precedente
  // rules[2]=false; //il vertice corrente non può essere posizionato a una posizione oraria di distanza dal precedente (uguale a sopra ma specchiato orizzontalmente)
  // rules[3]=false; //il vertice corrente non può essere posizionato 2 posizioni antiorarie dal precedente
  // rules[4]=false; //il vertice corrente non può essere posizionato 2 posizioni orarie dal precedente (uguale a sopra ma specchiato orizzontalmente)
  // rules[5]=false; //il vertice corrente non può essere un vicino del vertice precedente se i due vertici scelti precedentemente sono uguali 
  // rules[6]=false; //il vertice corrente non può essere posizionato 2 posizioni distante dal precedente se i 2 vertici precedenti sono uguali
  // rules[7]=false; //Il centro del poligono regolare diventa un punto selezionabile
  // rules[8]=false; //I punti medi dei lati del poligono regolare diventano punti selezionabili
  if (rules[7])
  {
      vertices.push(new p5.Vector(0,0));
  }
  if(rules[8])
  {
    for(let n=0;n<n_vertices-1;n++)
    {
      vertices.push(new p5.Vector((vertices[n+1].x+vertices[n].x)/2.0,(vertices[n+1].y+vertices[n].y)/2.0) );
    }
    vertices.push(new p5.Vector((vertices[n_vertices-1].x+vertices[0].x)/2.0,(vertices[n_vertices-1].y+vertices[0].y)/2.0));
  }

  currentPoint=new p5.Vector(vertices[0].x,vertices[0].y);

  background(bgColor);
}
function pointLogic()
{
  ignore=false;
  let dice=floor(random(vertices.length));
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
        if (indexes[0]!=vertices.length-1)
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
      if (indexes[1]==vertices.length-1)
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
        if (indexes[0]!=(vertices.length-2)+indexes[1])
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
      if (indexes[1]>=vertices.length-2)
      {
        if (indexes[0]!=2-(vertices.length-indexes[1]))
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
        let neighbors=[0,0];
        neighbors[0]=indexes[1]-1;
        neighbors[1]=indexes[1]+1;
        if (indexes[1]==0)
        {
          neighbors[0]=vertices.length-1;
        }
        else if(indexes[1]==vertices.length-1)
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
        let neighbors=[0,0];
        neighbors[0]=indexes[1]-2;
        neighbors[1]=indexes[1]+2;
        
        if(indexes[1]<2)
        {
          neighbors[0]=(vertices.length-2)+indexes[1];
        }
        else if(indexes[1]>=vertices.length-2)
        {
          neighbors[1]=2-(vertices.length-indexes[1]);
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

function setPoint()
{
  if (!ignore)
  {
    currentPoint.x=(currentPoint.x+vertices[indexes[0]].x)*ratio.x;
    currentPoint.y=(currentPoint.y+vertices[indexes[0]].y)*ratio.y;
    indexes[2]=indexes[1];
    indexes[1]=indexes[0];
  }
}

function drawPoint()
{
  if (!ignore && n_tracing>15)
  {
    colorLogic();
    stroke(r,g,b);
    point(currentPoint.x,currentPoint.y);
  }
}

function colorLogic()
{
  
  switch(colorModee)
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
        r/=scaleFactor;
        g/=scaleFactor;
        b/=scaleFactor;
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
function manageInput()
{
  // n_vertices=document.getElementById("sliderVertices").value;
  // colorModee=parseInt(document.getElementById("sliderColors").value);
  ratio.x=parseFloat(document.getElementById("ratioInput").value);
  ratio.y=ratio.x;

  if (isNaN(ratio.x))
  {
    document.getElementById("ratioInput").value=lastValidRatio;
    manageInput();
  }
  else
  {
    lastValidRatio=ratio.x;
  }
  var ruleCheckboxes=document.getElementsByClassName("rule");
  
  for(let r=0;r<ruleCheckboxes.length;r++)
  {
    rules[r]=ruleCheckboxes[r].checked;
    ruleCheckboxes[r].onchange=function(){initFractal();};
  }
}

function manageSliders()
{
  n_vertices=document.getElementById("sliderVertices").value;
  colorModee=parseInt(document.getElementById("sliderColors").value);
  scaleFactor=parseFloat(document.getElementById("sliderScale").value);

  document.getElementById("text1").innerHTML="Numero di vertici : "+n_vertices.toString();
  document.getElementById("text2").innerHTML="Scala: "+scaleFactor.toString();
  document.getElementById("text3").innerHTML="Modalità di colorazione : "+colorModee.toString();
  if(n_vertices!=preSlidersValue[0])
  {
    preSlidersValue[0]=n_vertices;
    initFractal();
  }

  else if(colorModee!=preSlidersValue[2])
  {
    preSlidersValue[2]=colorModee;
    initFractal();
  }

    else if(scaleFactor!=preSlidersValue[1])
  {
    preSlidersValue[1]=scaleFactor;
    initFractal();
  }
}

function saveFractal()
{
  enough=true;
  let fileName="";
  fractalParams=n_vertices+"-";
  for (let r=0;r<rules.length;r++)
  {
    if (rules[r]==false)
    {
      fractalParams+="0";
    }
    else
    {
      fractalParams+="1";
    }
  }
  fileName+=fractalParams+"-"+scaleFactor+"-"+colorModee+".png";
  console.log(fileName);

  let fractalImage=document.getElementsByTagName("canvas")[0];
  fractalImage.toBlob(function(blob)
  {
    let downloadButton=document.createElement("a");
    let linkToDownload=URL.createObjectURL(blob);
    downloadButton.href=linkToDownload;
    downloadButton.setAttribute("download",fileName)
    downloadButton.click();
    URL.revokeObjectURL(linkToDownload);
  },"image/png");
  enough=false;
}
