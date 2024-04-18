class particle { // or a cell of a colony or an organelle of a cell
  PVector position;
  PVector drawPos;
  PVector velocity;
  int type;
  boolean center;
  boolean selected = false;

  // Box2D
  Body body;

  // constructor
  particle(PVector start, int t) {
    position = new PVector(start.x, start.y);
    drawPos = new PVector(start.x, start.y);
    velocity = new PVector(0, 0);
    type = t;
    center = false;

    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(position.x, position.y));
    body = box2d.createBody(bd);

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(4);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1;
    fd.friction = friction;
    fd.restitution = 0.5;

    body.createFixture(fd);
    body.setUserData(this);


  }

  // void applyForce(Vec2 force) {
  //   body.applyForce(force, body.getWorldCenter());
  // }

  // applies forces based on this cell's particles
  void applyInternalForces(cell c) {
      for (particle p : c.swarm) {
          if (p != this) {
              Vec2 thisPos = body.getPosition();
              Vec2 pPos = p.body.getPosition();
              Vec2 direction = pPos.sub(thisPos);
              float distance = direction.length();
              direction.normalize();

              // Calculate force magnitude based on particle properties, distance, and cell properties
              float forceMagnitude = 0;

              if (distance < c.internalMins[type][p.type]) {
                  forceMagnitude = abs(c.internalForces[type][p.type]) * -3 * K * (1 - distance / c.internalMins[type][p.type]);
              } else if (distance < c.internalRadii[type][p.type]) {
                  forceMagnitude = c.internalForces[type][p.type] * K * (1 - distance / c.internalRadii[type][p.type]);
              }

              // Apply forces to the Box2D bodies
              body.applyForceToCenter(direction.mul(forceMagnitude));
              // p.body.applyForceToCenter(direction.mul(-forceMagnitude)); // Apply opposite force to the other particle
          }
      }
  }
  
  // applies forces based on other cell's particles 
  void applyExternalForces(cell c) {
      for (cell other : cells) {
          if (other != c) {
              for (particle p : other.swarm) {
                  Vec2 thisPos = body.getPosition();
                  Vec2 pPos = p.body.getPosition();
                  Vec2 direction = pPos.sub(thisPos);
                  float distance = direction.length();
                  direction.normalize();

                  // Calculate force magnitude based on particle properties, distance, and cell properties
                  float forceMagnitude = 0;

                  if (distance < c.externalMins[type][p.type]) {
                      forceMagnitude = abs(c.externalForces[type][p.type]) * -3 * K * (1 - distance / c.externalMins[type][p.type]);
                  } else if (distance < c.externalRadii[type][p.type]) {
                      forceMagnitude = c.externalForces[type][p.type] * K * (1 - distance / c.externalRadii[type][p.type]);
                  }

                  // Apply forces to the Box2D bodies
                  body.applyForceToCenter(direction.mul(forceMagnitude));
              }
          }
      }
  }

  // applies forces based on nearby food particles
void applyFoodForces(cell c) {
    for (particle p : food) {
        Vec2 thisPos = body.getPosition();
        Vec2 pPos = p.body.getPosition();
        Vec2 direction = pPos.sub(thisPos);
        float distance = direction.length();
        direction.normalize();

        // Calculate force magnitude based on particle properties, distance, and cell properties
        float forceMagnitude = 0;

        if (distance < c.externalRadii[type][p.type]) {
            forceMagnitude = c.externalForces[type][p.type] * K * (1 - distance / c.externalRadii[type][p.type]);
        }

        // Apply forces to the Box2D body
        body.applyForceToCenter(direction.mul(forceMagnitude));
    }
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
    Vec2 pos = body.getPosition(); // Get the position of the Box2D body
    fill(type * colorStep, 100, 100);
    
    float px = box2d.scalarWorldToPixels(pos.x); // Convert X coordinate from world to pixels
    float py = box2d.scalarWorldToPixels(pos.y); // Convert Y coordinate from world to pixels
    
    if (!center) {
        circle(px, py, 8); // Draw the particle
    } else {
        fill(120, 100, 100);
        triangle(px, py, px + 5, py + 10, px - 5, py + 10); // Draw the particle with center flag
    }
    
    if (selected && showSelected) {
        noFill();
        stroke(0, 255, 0);
        circle(px, py, 12); // Draw the selection circle
    }
}

}
