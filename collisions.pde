Ball[] bs;
double dt = 0.005;

void setup(){
  size(600, 600);
  bs = new Ball[30];
 
  for(int i = 0; i < bs.length; i++){
    bs[i] = new Ball(random(400)+100, random(400)+100, random(800)+100);
  }
 
  // While we could trust our collision resolution to get rid of overlapping
  // balls, it seems easier to make sure we don't start with any in the first
  // place
  for(int i = 0; i < bs.length; i++){
    while(overlaps_with_any(bs, bs[i])){
      bs[i] = new Ball(random(400)+100, random(400)+100, random(800)+100);
    }
  }
  
  // Randomize velocities.
  for(Ball b : bs){
    b.vel = PVector.random2D().mult(200);
  }
  frameRate(60);
}


void draw(){
  background(255);
  PVector z = new PVector();
  for(int i = 0; i < bs.length; i++){
    Ball b = bs[i]; 
    // Check collisions with any balls after ourselves
    // to avoid duplicate collision handling
    for(int j = i+1; j < bs.length; j++){
      if(b.collidesWithBall(bs[j])){
        resolveCollision(b, bs[j], dt);
      }
    }
    b.resolveFloorCollision(600);
    b.resolveWallCollision(600);
    b.advanceTime((float)dt);
  }


  // At the end of the iteration, reset forces to zero except
  // for gravity to make sure collision forces don't bleed through
  // between iterations
  for(Ball b: bs){
    b.draw(); 
    b.setForce(z); 
  }
}

boolean overlaps_with_any(Ball[] bs, Ball b){
  for(Ball other: bs){
    if(b == other){
      continue;
    }
    if (b.collidesWithBall(other)){
      return true;
    }
  }
  return false;
}

/* Given two balls that are definitely colliding, modifies
   the two balls such that they will move apart
   by the next timestep of dt. This function assumes that
   this is the only collision these two entities are involved
   in: if this is not true, the colliions may look funky for
   a while, but will hopefully resolve within a few frames. 
*/
   
void resolveCollision(Ball b1, Ball b2, double dt){
  PVector b1_b2 = b2.pos.copy().sub(b1.pos);
  // The distance that we need to move these things by.
  float badness = b1.r + b2.r - b1_b2.mag();
  
  // This isn't bad enough to justify action yet, and if we try,
  // we're going to be stabbed by the sharp, sharp point of
  // floating point accuracy.
  if (badness < 1e-2){
    return;    
  }

  // Project down onto a 1D system along the axis of collision to
  // simplify the mathematics.

  PVector moveDir = b1_b2.normalize();
  double v1 = moveDir.dot(b1.vel);
  double v2 = moveDir.dot(b2.vel);
  
  println(frameCount, badness);
  println(v1, v2);
  
  // Computation of the force needed to separate the objects
  // in a single step of size dt.
  double num = (badness/dt + v1 - v2) * b1.mass * b2.mass;
  double den = (b1.mass + b2.mass) * dt;
  double fc = num / den;
  
  b1.addForce(moveDir.copy().mult(-(float)fc));
  b2.addForce(moveDir.copy().mult((float)fc));
}
