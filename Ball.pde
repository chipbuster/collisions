class Ball{
  color c;
  float mass;
  float r;
  PVector pos, vel, acc;
  
  static final float density = 2.0;
  static final float grav = 100.0;
  
  Ball(float x, float y, float mass){
    this.pos = new PVector(x,y);
    this.vel = new PVector();
    this.acc = new PVector();
    this.mass = mass;
    this.c = color((int)random(255), (int)random(255), (int)random(255));
    float area = this.mass / density;
    this.r = sqrt(area);
  }
  
  void draw(){
    fill(this.c);
    ellipseMode(RADIUS);
    ellipse(this.pos.x, this.pos.y, r, r);
  }
  
  void setForce(PVector f){
    this.acc = f.copy();
    this.acc.div(this.mass);
    this.acc.y += this.grav;
  }
  
  void addForce(PVector f){
    this.acc.add(f.copy().div(this.mass));
  }
  
  boolean collidesWithBall(Ball other){
    float dist = this.pos.copy().sub(other.pos).mag();
    float sumR = this.r + other.r;
    return dist < sumR;
  }
  
  boolean collidesWithFloor(float y){
    return this.pos.y + this.r > y;
  }
  
  boolean collidesWithWall(float x){
    return this.pos.x + this.r > x || this.pos.x - this.r < 0;
  }
  
  void resolveFloorCollision(float y){
    if(this.pos.y + this.r > y){
      this.vel.y = -this.vel.y;
      // Prevent immediate recollision
      this.pos.y = y - r - 0.01; 
    }
    else if(this.pos.y - r < 0){
      this.vel.y = -this.vel.y;
      this.pos.y = r + 0.01; 
    }
  }
  
  void resolveWallCollision(float x){
    if(this.pos.x + this.r > x){
      this.vel.x = -this.vel.x;
      this.pos.x = x - r - 0.01; 
    } else if (this.pos.x - this.r < 0){
      this.vel.x = -this.vel.x;
      this.pos.x = r + 0.01; 
    }
  }
  
  void advanceTime(float dt){
    this.vel.add(this.acc.copy().mult(dt));
    //println("With acc of", this.acc, " moving ", this.vel.copy().mult(dt));
    this.pos.add(this.vel.copy().mult(dt));
  }
}
