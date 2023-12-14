class Particle {
    PVector position;
    PVector velocity;
    int type;

    Particle (PVector pos, int type) {
        this.position = new PVector(pos.x, pos.y);
        this.velocity = new PVector(0, 0);
        this.type = type;
    }



    void applyInternalForces(Cell c){
        PVector totalForce = new PVector(0, 0);
        PVector acceleration = new PVector(0, 0);
        PVector vector = new PVector(0, 0);
        float dis;
        for(Particle p : c.particles){
            
            if(p != this){
                    vector.mult(0);
                    vector = p.position.copy();
                    vector.sub(position);
                    if (vector.x > width * 0.5) {
                    vector.x -= width;
                    }
                    if (vector.x < width * -0.5) {
                    vector.x += width;
                    }
                    if (vector.y > height * 0.5) {
                    vector.y -= height;
                    }
                    if (vector.y < height * -0.5) {
                    vector.y += height;
                    }
                    dis = vector.mag();
                    vector.normalize();
                if (dis < c.internalMins[this.type][p.type]){
                    PVector force = vector.copy();
                    force.mult(abs(c.internalMins[this.type][p.type] * -3*K));
                    force.mult(map(dis, 0, c.internalMins[type][p.type], 1, 0));
                    totalForce.add(force);
                }
                if (dis < c.internalRadii[this.type][p.type]) {
                    PVector force = vector.copy();
                    force = force.copy().mult(abs(c.internalForces[this.type][p.type] * -3 * K));
                    force = force.copy().mult(map(dis, 0, c.internalRadii[type][p.type], 1, 0));
                    totalForce.add(force);
                }
            }
        }
        acceleration.add(totalForce);
        this.velocity.add(acceleration);
        this.velocity.mult(friction);
        this.position.add(this.velocity);

    }

    void applyExternalForces(Cell c){
        PVector totalForce = new PVector(0, 0);
        PVector acceleration = new PVector(0, 0);
        PVector vector = new PVector(0, 0);
        
        float dis;
        for(Cell other : world){
            if(other != c){
                for(Particle p : other.particles){
                    vector.mult(0);
                    vector = p.position.copy();
                    vector.sub(position);
                    if (vector.x > width * 0.5) {
                        vector.x -= width;
                    }
                    if (vector.x < width * -0.5) {
                        vector.x += width;
                    }
                    if (vector.y > height * 0.5) {
                        vector.y -= height;
                    }
                    if (vector.y < height * -0.5) {
                        vector.y += height;
                    }
                    dis = vector.mag();
                    vector.normalize();        
                    if(p != this){
                        if (dis < c.externalMins[this.type][p.type]){
                             PVector force = vector.copy();
                            force = force.copy().mult(abs(c.internalMins[this.type][p.type] * -3*K));
                            force = force.copy().mult(map(dis, 0, c.internalMins[type][p.type], 1, 0));
                            totalForce.add(force);
                        }
                        if (dis < c.externalRadii[this.type][p.type]) {
                            PVector force = vector.copy();
                            force = force.copy().mult(c.externalForces[type][p.type]*K);
                            force = force.copy().mult(map(dis, 0, c.externalRadii[type][p.type], 1, 0));
                            totalForce.add(force);
                        }

                    }
                }                
            }
        }
        
        acceleration.add(totalForce);
        this.velocity.add(acceleration);
        this.velocity.mult(friction);
        this.position.add(this.velocity);
    }

    void draw(){
        fill(this.type*colorStep, 100, 100);
        circle(this.position.x, this.position.y, 10);
    }

}
