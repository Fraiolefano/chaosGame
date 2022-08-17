public class WindowSection
{
  PVector pos; //upper left corner
  PVector size;
  color bgColor;
  boolean toDraw;
  PVector scrollRange;
  private PVector centerPos; //centerPosition
  public float stepSize=0;
  ArrayList<WindowElem> windowElements;
  ChangedData changed;
  
  public WindowSection(PVector upperLeftCorner,PVector size)  // Una sezione di finestra definibile come un rettangolo
  {
    this.pos=upperLeftCorner;
    this.size=size;
    toDraw=true;
    
    this.centerPos=new PVector(this.pos.x+(this.size.x/2),this.pos.y+(this.size.y/2));
    this.windowElements=new ArrayList<WindowElem>();
    
    this.changed=new ChangedData();
    
    scrollRange=new PVector(-1000,0);
  }
  
  public void draw()
  {
    if (!toDraw) return;
    
    fill(this.bgColor);
    strokeWeight(1);
    stroke(this.bgColor);
    rect(this.pos.x,this.pos.y,this.size.x,this.size.y);
    
    for (int c=0;c<windowElements.size();c++)
    {
      windowElements.get(c).draw();
    }
  }
  
  public void background()
  {
    if (!toDraw) return;
    
    fill(bgColor);
    strokeWeight(1);
    rect(this.pos.x,this.pos.y,this.size.x,this.size.y);
  }
  public void initElements()
  {
    for (int c=0;c<windowElements.size();c++)
    {
      WindowElem currentEl=windowElements.get(c);
      if (currentEl instanceof TextElem)
      {
        currentEl.pos.x+=pos.x;
        currentEl.pos.y+=pos.y;
      }
      else if (currentEl instanceof Slider)
      {
        ((Slider)currentEl).textPos.x+=pos.x;
        ((Slider)currentEl).textPos.y+=pos.y;
        
        currentEl.pos.x+=pos.x-(((Slider)currentEl).barWidth/2.0);
        currentEl.pos.y+=pos.y+stepSize;
        ((Slider)currentEl).pointerPos=currentEl.pos.x+ ( ((Slider)currentEl).barStep* ((Slider)currentEl).range.z/((Slider)currentEl).stepSize)-( ((Slider)currentEl).barStep* ((Slider)currentEl).range.x/((Slider)currentEl).stepSize);
      }
      else if (currentEl instanceof Radio)
      {
        currentEl.pos.x+=pos.x;
        currentEl.pos.y+=pos.y;
        ((Radio)currentEl).barLength=((Radio)currentEl).boxDist*(((Radio)currentEl).values.x-1);
        ((Radio)currentEl).barPos=new PVector(currentEl.pos.x-(((Radio)currentEl).barLength/2.0),currentEl.pos.y+stepSize);
      }
      else if (currentEl instanceof CheckBox)
      {
        currentEl.pos.x+=pos.x;
        currentEl.pos.y+=pos.y;
        ((CheckBox)currentEl).barLength=((CheckBox)currentEl).boxDist*(((CheckBox)currentEl).nBoxes-1);
        ((CheckBox)currentEl).barPos=new PVector(currentEl.pos.x-(((CheckBox)currentEl).barLength/2.0),currentEl.pos.y+stepSize);
      }
      else if (currentEl instanceof TextBox)
      {
        currentEl.pos.x+=pos.x;
        currentEl.pos.y+=pos.y;
        ((TextBox)currentEl).boxPos=new PVector(currentEl.pos.x-((TextBox)currentEl).size.x/2.0,currentEl.pos.y+stepSize*0.5);
        ((TextBox)currentEl).textPos=new PVector(currentEl.pos.x,((TextBox)currentEl).boxPos.y + ((TextBox)currentEl).size.y/1.25);
      }
      else if (currentEl instanceof Button)
      {
        currentEl.pos.x+=pos.x;
        currentEl.pos.y+=pos.y;
        ((Button)currentEl).boxPos=new PVector(currentEl.pos.x-((Button)currentEl).size.x/2.0,currentEl.pos.y+stepSize*0.5);
        ((Button)currentEl).textPos=new PVector(currentEl.pos.x,((Button)currentEl).boxPos.y + ((Button)currentEl).size.y/1.25);
      }
      
    }
  }
  
  public void mouseWheel(float delta)
  { 
    for (int c=0;c<windowElements.size();c++)
    {
      heightPos+=delta;
      if (heightPos<scrollRange.x)
      {
        heightPos=int(scrollRange.x);
        delta=0;
      }
      else if(heightPos>scrollRange.y)
      {
        heightPos=int(scrollRange.y);
        delta=0;
      }
      WindowElem currentEl=windowElements.get(c);
      currentEl.pos.y+=delta;
      
      if (currentEl instanceof Slider)
      {
        ((Slider)currentEl).textPos.y+=delta;
      }
      else if (currentEl instanceof Radio)
      {
        ((Radio)currentEl).barPos.y+=delta;
      }
      else if (currentEl instanceof TextBox)
      {
        ((TextBox)currentEl).boxPos.y+=delta;
        ((TextBox)currentEl).textPos.y+=delta;
      }
      else if (currentEl instanceof CheckBox)
      {
        ((CheckBox)currentEl).barPos.y+=delta;
      }
      else if (currentEl instanceof Button)
      {
        ((Button)currentEl).boxPos.y+=delta;
        ((Button)currentEl).textPos.y+=delta;
      }
    }
  }
  
  public ChangedData onChange()
  {
    for (int c=0;c<windowElements.size();c++)
    {
      WindowElem currentEl=windowElements.get(c);
      if (currentEl instanceof TextElem)
      {
        continue;
      }
      else if (currentEl instanceof Slider)
      {
        if (((Slider)currentEl).preVal!=((Slider)currentEl).range.z)
        {
          println("Cambiato il valore dello slider");
          ((Slider)currentEl).preVal=((Slider)currentEl).range.z;

          changed.value=true;
          changed.el=currentEl;
          return changed;
        }
      }
      else if (currentEl instanceof Radio)
      {
        if ( ((Radio)currentEl).preVal!=((Radio)currentEl).values.y)
        {
          ((Radio)currentEl).preVal=((Radio)currentEl).values.y;
          println("Cambiato il valore dei radio buttons");

          changed.value=true;
          changed.el=currentEl;
          return changed;
        }
      }
      else if (currentEl instanceof TextBox)
      {
        if ( ((TextBox)currentEl).returnValue!=((TextBox)currentEl).preVal)
        {
          ((TextBox)currentEl).preVal=((TextBox)currentEl).returnValue;
          println("Cambiato il valore della textBox");

          changed.value=true;
          changed.el=currentEl;
          return changed;
        }
      }
      else if (currentEl instanceof CheckBox)
      {
        for(int i=0;i<((CheckBox)currentEl).values.length;i++)
        {
          if (((CheckBox)currentEl).values[i]!=((CheckBox)currentEl).preVal[i])
          {
            println("checkbox differenti");
            ((CheckBox)currentEl).preVal=((CheckBox)currentEl).values.clone();

            changed.value=true;
            changed.el=currentEl;
            return changed;
          }
        }
      }
      else if (currentEl instanceof Button)
      {
        if (((Button)currentEl).pressed)
        {
          println("Pulsante premuto");
          ((Button)currentEl).pressed=false;
          
          changed.value=true;
          changed.el=currentEl;
          return changed;
        }
        
      }
    }
    
    changed.value=false;
    changed.el=null;
    return changed;
    
  }
  
}


public class WindowElem
{
  PVector pos;
  color elemColor=255;
  public WindowElem()
  {
    this.pos=new PVector(0,0); 
  }
  public void draw(){}
  public void mousePressed(){}
  public void mouseReleased(){}
  public void keyPressed(){}
}
public class TextElem extends WindowElem
{
  String text="";
  color textColor;
  int fontSize=12;
  public TextElem(String text,PVector pos)
  {
    super.pos=pos;
    this.text=text;
    this.textColor=super.elemColor;
  }
  
  public void draw()
  {
    fill(textColor);
    textSize(fontSize);
    text(this.text,super.pos.x,super.pos.y);
  }
}

public class Slider extends WindowElem
{
  String textName;
  PVector textPos;
  PVector range;
  float preVal;
  float stepSize;
  float barWidth;
  float barStep;
  color barColor=color(0,127,255);
  color pointerColor=color(0,255,127);
  int fontSize=20;
  float pointerPos=0;
  float values[];
  public Slider(String textName,PVector pos,PVector range,float stepSize,float barWidth) //range (min,max,defValue)
  {
    super.pos=pos;
    textPos=new PVector(pos.x,pos.y);
    this.textName=textName;
    this.range=range;
    this.stepSize=stepSize;
    this.barWidth=barWidth;
    values=new float[int((range.y-range.x)/stepSize)+1];
    for (int c=0;c<values.length;c++)
    {
      values[c]=(range.x+(c*stepSize));
    }
    barStep=barWidth/(values.length-1);
    preVal=range.z;
  }
  
  public void draw()
  {
    stroke(barColor);
    strokeWeight(2);
    textSize(fontSize);
    text(this.textName,textPos.x,textPos.y);
    line(pos.x,pos.y,pos.x+barWidth,pos.y);
    strokeWeight(1);
    for (int c=0;c<values.length;c++)
    {
      line(pos.x+barStep*c,pos.y-10,pos.x+barStep*c,pos.y+10);
    }
    noFill();
    stroke(pointerColor);
    rect(pointerPos-5,pos.y-10,10,20);
    text(nf(range.z,0,0),pointerPos,pos.y-15);
    
    logic();
  }
  
  private void logic()
  {
    if (mousePressed && mouseX>pos.x && mouseX<pos.x+barWidth && mouseY>pos.y-20 && mouseY<pos.y+20)
    {
      pointerPos=mouseX;
      for (int c=0;c<=values.length;c++)
      {
        if (Math.abs(pointerPos-(pos.x+(c*barStep)))<(barStep/2.0))
         {
            pointerPos=pos.x+(c*barStep);
            preVal=range.z;
            range.z=values[c];
            break;
         }
      } 
    }    
  }
  public void mouseReleased()
  {

  }
   
}

public class Radio extends WindowElem
{
  String textName="";
  PVector values;
  float preVal;
  private float boxDist=100;
  private float barLength;
  public PVector barPos;
  public color uncheckedColor;
  public color checkedColor;
  public float radius;
  private float size;
  int fontSize=20;
  public Radio(String name,PVector pos,PVector values) //values = nValues,default value
  {
    super.pos=pos;
    textName=name;
    this.values=values;
    preVal=values.y;
    barLength=boxDist*(this.values.x-1);
    uncheckedColor=color(0,127,255);
    checkedColor=color(0,255,127);
    radius=20;
    size=radius*2;
  }
  
  public void draw()
  {
    textSize(fontSize);
    text(textName,pos.x,pos.y);
    strokeWeight(1);
    for(int c=0;c<values.x;c++)
    {
      if (c==values.y)
      {
        //fill(checkedColor);
        stroke(checkedColor);
        circle(barPos.x+(boxDist*c)+0.5,barPos.y,size/1.5);
      }
      //noFill();
      stroke(uncheckedColor);
      circle(barPos.x+(boxDist*c),barPos.y,size);
    }
    noFill();
    strokeWeight(1);
    
  }
  
  public void mousePressed()
  {
    if(mouseX>barPos.x-radius && mouseX<barPos.x+(barLength+radius) && mouseY<barPos.y+radius && mouseY>barPos.y-radius)
    {
      
      for(int c=0;c<values.x;c++)
      {
        if (Math.abs(mouseX-(barPos.x+(c*boxDist)))<radius)
        {
          preVal=values.y;
          values.y=c;
          break;
        }
      }

    }
  }
}

public class TextBox extends WindowElem
{
  String textName="";
  String value="";
  String returnValue="";
  String preVal="";
  public PVector boxPos;
  public PVector size;
  public PVector textPos;
  int fontSize=20;
  boolean focus=false;
  int maxLength=100;
  color unfocusedC=color(0,127,255);
  color focusedC=color(0,255,127);
  String type="text"; //text or numeric
  String lastCorrect="";
  
  public TextBox(String textName,PVector pos,PVector size,String defaultValue)
  {
    this.textName=textName;
    super.pos=pos;
    this.size=size;
    value=defaultValue;
    returnValue=value;
    lastCorrect=defaultValue;
    
    preVal=returnValue;
    boxPos=pos;
    
  }
  
  public void draw()
  {
    textSize(fontSize);
    text(textName,pos.x,pos.y);
    
    if (focus)
    {
      stroke(focusedC);
    }
    else
    {
      stroke(unfocusedC);
    }
    rect(boxPos.x,boxPos.y,size.x,size.y);
    
    textSize(size.y);
    text(value,textPos.x,textPos.y);
  }
  
  public void mousePressed()
  {
    if (mouseX>boxPos.x && mouseX<boxPos.x+size.x && mouseY<boxPos.y+size.y &&mouseY>boxPos.y)
    {
      focus=true;
    }
    else
    {
     focus=false;
     preVal=returnValue;
     if (type=="numeric")
     {
      getNumeric();
     }
     returnValue=value;
    }
  }
  
  public void keyPressed()
  {
    if (focus)
    {
      if (key==BACKSPACE)
      {
        if (value.length()>0)
          {value=value.substring(0,value.length()-1);}
      }
      else if (keyCode==ENTER)
      {
        preVal=returnValue;
        if (type=="numeric")
        {
          getNumeric();
        }
        returnValue=value;
      }
      else
      {
        if (value.length()<maxLength)
        {
          value+=key;
        }
      }
      
    }
    
  }

  public int getNumeric()
  {
    if (value.length()==0){value=lastCorrect;returnValue=lastCorrect;return 1;}
    for(int c=0;c<value.length();c++)
    {
      if(!((value.charAt(c)>='0' && value.charAt(c)<='9') || value.charAt(c)=='.'))
      {
        println("erroe di codifica numerica");
        value=lastCorrect;
        returnValue=lastCorrect; 
        return 1;
      }
    }
    
    lastCorrect=value;
    return 0;
    
    
    
  }
  
}

public class CheckBox extends WindowElem
{
  String textName="";
  int nBoxes;
  private float boxDist=100;
  private float barLength;
  public PVector barPos;
  public color uncheckedColor;
  public color checkedColor;
  public float radius;
  private float size;
  boolean[] values;
  boolean[] preVal;
  String[] labels;
  int fontSize=20;
  
  public CheckBox(String name,PVector pos,int nBoxes)
  {
    super.pos=pos;
    textName=name;
    this.nBoxes=nBoxes;
    barLength=boxDist*(this.nBoxes-1);
    uncheckedColor=color(0,127,255);
    checkedColor=color(0,255,127);
    radius=20;
    size=radius*2;
    
    values=new boolean[nBoxes];
    preVal=new boolean[nBoxes];
    labels=new String[nBoxes];
    
    for(int c=0;c<nBoxes;c++)
    {
      values[c]=false;
      preVal[c]=false;
      labels[c]=""+(c+1);
    }
  }
  
  public void draw()
  {
    textSize(fontSize);
    text(textName,pos.x,pos.y);
    strokeWeight(1);
    for(int c=0;c<nBoxes;c++)
    {
      text(labels[c],barPos.x+(boxDist*c),barPos.y+6);
      if (values[c])
      {
        stroke(checkedColor);
        square(barPos.x+(boxDist*c - radius/1.5),barPos.y-(radius/1.5),size/1.5);
      }
      stroke(uncheckedColor);
      square(barPos.x+(boxDist*c - radius),barPos.y-radius,size);
    }
    noFill();
    strokeWeight(1);
    
    //mousePressed();
  }
  
  public void mousePressed()
  {
    if(mouseX>barPos.x-radius && mouseX<barPos.x+(barLength+radius) && mouseY<barPos.y+radius && mouseY>barPos.y-radius)
    {
      for(int c=0;c<nBoxes;c++)
      {
        if (Math.abs(mouseX-(barPos.x+(c*boxDist)))<radius)
        {
          preVal[c]=values[c];
          values[c]=!values[c];
          break;
        }
      }

    }
  }
}

public class Button extends WindowElem
{
  String labelText="";
  PVector size;
  PVector boxPos;
  PVector textPos;
  int fontSize;
  boolean pressed=false;
  boolean pressedAnimation=false;
  float lastPress=0;
  color unpressedC=color(0,127,255);
  color pressedC=color(0,255,127);
  
  public Button(String labelText,PVector pos,PVector size)
  {
    super.pos=pos;
    this.labelText=labelText;
    this.size=size;
    boxPos=pos;
    textPos=pos;
    fontSize=25;
  }
  public void draw()
  {
    if (!pressedAnimation)
    {
      strokeWeight(1);
      stroke(unpressedC);
    }
    else
    {
      strokeWeight(2);
      stroke(pressedC);
      if (millis()-lastPress>100)
      {
        
       pressedAnimation=false; 
      }
    }
    rect(boxPos.x,boxPos.y,size.x,size.y);
    textSize(fontSize);
    text(labelText,textPos.x,textPos.y);
  }
  
  public void mousePressed()
  {
    if(mouseX>boxPos.x && mouseX<boxPos.x+size.x && mouseY<boxPos.y+size.y && mouseY>boxPos.y)
    {
      if(millis()-lastPress>100)
      {
        pressed=true;
        pressedAnimation=true;
        lastPress=millis();
      }
    }
  }
}

public class ChangedData
{
  boolean value=false;
  WindowElem el;
}
