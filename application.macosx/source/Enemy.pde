
class Enemy
{

  float posX = 0;
  float posY = 0;
  float mySize = 20;
  float health = 1;
  float speed = 1;
  float damage = 1;
  float mySize1 = 0; //for hollow circle
  float color1 = 0;   //R
  float color2 = 127; //G
  float color3 = 255; //B
  
  float score = 120;

  int type = (int)random(1, 4);
  int direction = (int)random(1, 5);

  int expandTimer = 0;

  boolean mu;
  boolean md;
  boolean ml;
  boolean mr;
  
  boolean chargeDash = false;
  boolean dash = false;
  int chargeTimer = 0;
  int dashTimer = 0;
  
  float angleInDegrees = 0;
  float angleInRadians = 0;
  float vectorY = 0;
  float vectorX = 0;
  
  float rotationAngle = 0;
  
  boolean bossDead = false;

  Enemy(float tempPosX, float tempPosY, float tempHealth, float tempSpeed, float tempDamage)
  {
    //Chasers
    posX = tempPosX;
    posY = tempPosY;
    health = tempHealth;
    speed = tempSpeed;
    damage = tempDamage;
    

    //avoid spawning in the center
    while (posX > width/20 * 7 && posX < width/20 * 13 && posY > height/20 * 6 && posY < height/20 * 14)
    {
      posX = (int)random(1, width);
      posY = (int)random(1, height);
    }
   
    //Boss Enemy
    if (wave == 9 || wave == 19 || wave == 29)
    {
      type = 4;
      damage = damage * 2;
      speed = speed * 2;
      mySize = mySize * 4;
      score = score * 5;
      health = health * 10;
      mu = true;
      md = false;
      ml = true;
      mr = false;
    }

    //Expanders
    if (type == 3)
    {
      health = health * 4;
      mySize = mySize * 4;
      score = score - 40;
    }

    //Runners
    if (type == 2)
    {

      speed = speed * 1.5;
      mySize = mySize * 1.5;
      score = score - 20;
      if (direction == 1)
      {
        mu = true;
        md = false;
        ml = true;
        mr = false;
      } else if (direction == 2)
      {
        mu = false;
        md = true;
        ml = true;
        mr = false;
      } else if (direction == 3)
      {
        mu = true;
        md = false;
        ml = true;
        mr = false;
      } else if (direction == 4)
      {
        mu = false;
        md = true;
        ml = false;
        mr = true;
      }
    }
  }



  void Update()
  {
    
    //Boss enemy core
    if (type == 4)
    {
      
      
      fill(color1, color2, color3);
      ellipse(posX, posY, mySize, mySize);
      textAlign(CENTER, CENTER);
      fill(0);
      text(nf(health, 1, 1), posX, posY);
      
      
      if (mu)
        {
          posY -= speed;
        } else if (md)
        {
          posY += speed;
        }

        if (ml)
        {
          posX -= speed;
        } else if (mr)
        {
          posX += speed;
        }

        if (posY >= height - mySize/2)
        {
          mu = true;
          md = false;
        }

        if (posY <= 0 + mySize/2)
        {
          mu = false;
          md = true;
        }

        if (posX >= width - mySize/2)
        {
          ml = true;
          mr = false;
        }

        if (posX <= 0 + mySize/2)
        {
          ml = false;
          mr = true;
        }
      if (enemyList.size() == 1) type = 1;
    }
    
    //Fat Enemies
    if (type == 3)
    {
      //Change matrix to force translation and rotation to only affect fat enemies
      pushMatrix();
      translate(posX, posY);
      rotate(rotationAngle);
      rotationAngle += PI/10;
      fill(color1, color2, color3);
      ellipse(0, 0, mySize, mySize/4);
      textAlign(CENTER, CENTER);
      fill(0);
      popMatrix();
      
      text(nf(health, 1, 1), posX, posY);
     
      expandTimer++;
      
      if (expandTimer >= 3)
      {
        mySize += 3;
        expandTimer = 0;
      }
      
      color1 += .25;
      color2 -= .125;
      color3 -= .25;
      

      //expand within boundaries unless you're in the center
      if (posY != height/2 && posX != width/2)
      {
        if (posY >= height - mySize/2)
        {
          posY = height - mySize/2;
        }

        if (posY <= 0 + mySize/2)
        {
          posY = 0 + mySize/2;
        }

        if (posX >= width - mySize/2)
        {
          posX = width - mySize/2;
        }

        if (posX <= 0 + mySize/2)
        {
          posX = 0 + mySize/2;
        }
      }
    }

    //Chaser-Charger Enemies
    if (type == 1)
    {
      noFill();
      stroke(255, 0, 0);
      ellipse(posX, posY, mySize1, mySize1);
      mySize1++;
      
      if(mySize1 >= mySize * 5)
      {
        mySize1 = 0;
      }
      
      //If player is inside red circle start charging
      if (AreWeColliding(player1.positionX, player1.positionY, player1.mySize, posX, posY, mySize1) && !chargeDash)
      {
        
        chargeDash = true;
        
      }else{
        speed = enemySpeed;
        fill(255, 255, 0);
      } 
      
      // If charging stand still and vibrate for 1 second
      if (chargeDash && !dash)
      {
        if(chargeTimer % 2 == 1)
        {
          speed = enemySpeed * -3;
        }else{
          speed = enemySpeed * 3;
        }
        
        //angle in degrees between player and chaser enemy
        angleInDegrees = atan2(player1.positionY-posY, player1.positionX-posX) * 180 / PI;
    
        if (angleInDegrees<0) 
        { 
          angleInDegrees *= -1;
        } 
        else if (angleInDegrees > 0) 
        {
          angleInDegrees = 180 + (180-angleInDegrees);
        }
        
        //get angle in radians and get x and y vectors using tangent
        angleInRadians = -angleInDegrees*0.01747722222222222222222;
        vectorY = sin(angleInRadians);
        vectorX = cos(angleInRadians);
        
        fill(255, 0, 0);
        chargeTimer++;
      }
      //after charging dash for 1 second
      if (chargeTimer >= 60)
      {
        chargeDash = false;
        chargeTimer = 0;
        dash = true;
      }
      
      //while dashing 
      if (dash)
      {
        
        dashTimer++;
       
        //X and Y velocity
        posY += vectorY * enemySpeed * 5;
        posX += vectorX * enemySpeed * 5;
        
      }
      //stop dashing after 1 second
      if (dashTimer >= 60)
      {
        dash = false;
        dashTimer = 0;
               
      }
        
      
      noStroke();
      
      rect(posX - mySize/2, posY - mySize/2, mySize, mySize);
      textAlign(CENTER, CENTER);
      fill(0);
      text(nf(health, 1, 1), posX, posY);

      if (posX > player1.positionX && !dash)
      {
        posX-= speed;
      } else if (posX < player1.positionX && !dash)
      {
        posX+= speed;
      }

      if (posY > player1.positionY && !dash)
      {
        posY-= speed;
      } else if (posY < player1.positionY && !dash)
      {
        posY+= speed;
      }
    }

    //Runner Enemies
    if (type == 2)
    {

      trailList.add(new Trail(posX, posY, mySize, 127, 0, 255));
      
      fill(127, 0, 255);
      ellipse(posX, posY, mySize, mySize);
      textAlign(CENTER, CENTER);
      fill(0);
      text(nf(health, 1, 1), posX, posY);
            
      
      if (allPurple == false)
      {
        if (mu)
        {
          posY -= speed;
        } else if (md)
        {
          posY += speed;
        }

        if (ml)
        {
          posX -= speed;
        } else if (mr)
        {
          posX += speed;
        }

        if (posY >= height - mySize/2)
        {
          mu = true;
          md = false;
        }

        if (posY <= 0 + mySize/2)
        {
          mu = false;
          md = true;
        }

        if (posX >= width - mySize/2)
        {
          ml = true;
          mr = false;
        }

        if (posX <= 0 + mySize/2)
        {
          ml = false;
          mr = true;
        }
      } else {
        if (posX > player1.positionX)
        {
          posX-= speed;
        } else if (posX < player1.positionX)
        {
          posX+= speed;
        }

        if (posY > player1.positionY)
        {
          posY-= speed;
        } else if (posY < player1.positionY)
        {
          posY+= speed;
        }
      }
    }//end runner
    
  }//end update
}//end enemy class
