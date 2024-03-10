class particle { // or a cell of a colony or an organelle of a cell
  PVector position;
  PVector drawPos;
  PVector velocity;
  int type;
  boolean center;
  boolean selected = false;

  // constructor
  particle(PVector start, int t) {
    position = new PVector(start.x, start.y);
    drawPos = new PVector(start.x, start.y);
    velocity = new PVector(0, 0);
    type = t;
    center = false;
  }

  // applies forces based on this cell's particles
  void applyInternalForces(cell c) {
    PVector totalForce = new PVector(0, 0);
    PVector acceleration = new PVector(0, 0);
    PVector vector = new PVector(0, 0);
    float dis;
    for (particle p : c.swarm) {
      if (p != this) {
        vector.mult(0);
        vector = p.position.copy();
        vector.sub(position);
        // if (vector.x > width * 0.5) {
        //   vector.x -= width;
        // }
        // if (vector.x < width * -0.5) {
        //   vector.x += width;
        // }
        // if (vector.y > height * 0.5) {
        //   vector.y -= height;
        // }
        // if (vector.y < height * -0.5) {
        //   vector.y += height;
        // }
        dis = vector.mag();
        vector.normalize();
        if (dis < c.internalMins[type][p.type]) {
          PVector force = vector.copy();
          force.mult(abs(c.internalForces[type][p.type])*-3*K);
          force.mult(map(dis, 0, c.internalMins[type][p.type], 1, 0));
          totalForce.add(force);
        }
        if (dis < c.internalRadii[type][p.type]) {
          PVector force = vector.copy();
          force.mult(c.internalForces[type][p.type]*K);
          force.mult(map(dis, 0, c.internalRadii[type][p.type], 1, 0));
          totalForce.add(force);
        }
      }
    }
    acceleration = totalForce.copy();
    velocity.add(acceleration);

    position.add(velocity);
    // position.x = (position.x + width)%width;
    // position.y = (position.y + height)%height;
    velocity.mult(friction);
    calcualteDrawPos();

  }
  
  // applies forces based on other cell's particles 
  void applyExternalForces(cell c) {
    PVector totalForce = new PVector(0, 0);
    PVector acceleration = new PVector(0, 0);
    PVector vector = new PVector(0, 0);
    float dis;
    for (cell other : cells) { // for each other cell in the swarm
      if (other != c) {  // don't apply external forces within this cell
        for (particle p : other.swarm) { // for each particle in the other cell
          vector.mult(0);
          vector = p.position.copy();
          vector.sub(position);
          // if (vector.x > width * 0.5) {
          //   vector.x -= width;
          // }
          // if (vector.x < width * -0.5) {
          //   vector.x += width;
          // }
          // if (vector.y > height * 0.5) {
          //   vector.y -= height;
          // }
          // if (vector.y < height * -0.5) {
          //   vector.y += height;
          // }
          dis = vector.mag();
          vector.normalize();
          if (dis < c.externalMins[type][p.type]) {
            PVector force = vector.copy();
            force.mult(abs(c.externalForces[type][p.type])*-3*K);
            force.mult(map(dis, 0, c.externalMins[type][p.type], 1, 0));
            totalForce.add(force);
          }
          if (dis < c.externalRadii[type][p.type]) {
            PVector force = vector.copy();
            force.mult(c.externalForces[type][p.type]*K);
            force.mult(map(dis, 0, c.externalRadii[type][p.type], 1, 0));
            totalForce.add(force);
          }
        }
      }
    }
    acceleration = totalForce.copy();
    velocity.add(acceleration);
    position.add(velocity);
    // position.x = (position.x + width)%width;
    // position.y = (position.y + height)%height;
    velocity.mult(friction);
    calcualteDrawPos();

  }

  // applies forces based on nearby food particles
  void applyFoodForces(cell c) {
    PVector totalForce = new PVector(0, 0);
    PVector acceleration = new PVector(0, 0);
    PVector vector = new PVector(0, 0);
    float dis;
    for (particle p : food) {  // for all food particles
      vector.mult(0);
      vector = p.position.copy();
      vector.sub(position);
      // if (vector.x > width * 0.5) {
      //   vector.x -= width;
      // }
      // if (vector.x < width * -0.5) {
      //   vector.x += width;
      // }
      // if (vector.y > height * 0.5) {
      //   vector.y -= height;
      // }
      // if (vector.y < height * -0.5) {
      //   vector.y += height;
      // }
      dis = vector.mag();
      vector.normalize();
      // no repulsive force for food
      if (dis < c.externalRadii[type][p.type]) {
        PVector force = vector.copy();
        force.mult(c.externalForces[type][p.type]*K);
        force.mult(map(dis, 0, c.externalRadii[type][p.type], 1, 0));
        totalForce.add(force);
      }
    }
    acceleration = totalForce.copy();
    velocity.add(acceleration);
    position.add(velocity);
    // position.x = (position.x + width)%width;
    // position.y = (position.y + height)%height;
    velocity.mult(friction);
    calcualteDrawPos();
  }

  void calcualteDrawPos(){
    float x = this.position.x;
    float y = this.position.y;
    float tempX;
    float tempY;
    
    if (x < 0) {
      tempX = width - (abs(x) % width);
      this.drawPos.x = tempX;

    } 
    else  {
      tempX = x % width;
      this.drawPos.x = tempX;
    }

    if (y < 0) {
      tempY = height - (abs(y) % height);
      this.drawPos.y = tempY;
    } 
    else {
      tempY = y % height;
      this.drawPos.y = tempY;
    }

  }

  void applyForce(PVector force){
    this.velocity.add(force);
    
  }

  void printStats(){
    println("Position: " + this.position);
    println("Draw Position: " + this.drawPos);
    println("Velocity: " + this.velocity);
    println("Type: " + this.type);
    println("Center: " + this.center);
    println(" ");
    println("====================================");
    println(" ");
  }

  // display the particles
  void display() {
    fill(type*colorStep, 100, 100);
    if(!this.center){
      circle(this.drawPos.x, this.drawPos.y, 8);
    }
    else{
      fill(120, 100, 100);
      triangle(this.drawPos.x, this.drawPos.y, this.drawPos.x+5, this.drawPos.y+10, this.drawPos.x-5, this.drawPos.y+10);
    }
    if(this.selected && showSelected){
      noFill();
      stroke(0, 255, 0);
      circle(this.drawPos.x, this.drawPos.y, 12);
    }
  }
}
