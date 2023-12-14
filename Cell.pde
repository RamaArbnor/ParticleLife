class Cell {

    ArrayList<Particle> particles;

    //DNA OF THE CELL
    float internalForces[][];
    float externalForces[][];
    float internalMins[][];
    float externalMins[][];
    float internalRadii[][];
    float externalRadii[][];

    PVector positions[];
    int numParticles = 40;
    int energy = startingEnergy;
    int radius;
    PVector center = new PVector(0,0);

    Cell (float x, float y){

        internalForces = new float[numTypes][numTypes];
        externalForces = new float[numTypes][numTypes];
        internalMins = new float[numTypes][numTypes];
        externalMins = new float[numTypes][numTypes];
        internalRadii = new float[numTypes][numTypes];
        externalRadii = new float[numTypes][numTypes];

        positions = new PVector[numParticles];
        particles = new ArrayList<Particle>();
        generateNew(x,y);

    }

    void generateNew(float x, float y){
        for(int i = 0; i < numTypes; i++){
            for(int j= 0; j < numTypes; j++){
                internalForces[i][j] = random(0.1,1.0); // internal forces are initially attractive, but can mutate
                internalMins[i][j] = random(40,70);
                internalRadii[i][j] = random(internalMins[i][j]*2,300); // minimum 'primary' force range must be twice repulsive range
                externalForces[i][j] = random(-1.0,1.0); // external forces could be attractive or repulsive
                externalMins[i][j] = random(40,70);
                externalRadii[i][j] = random(externalMins[i][j]*2,300);
            }
        }
        for(int i = 0; i < numParticles; i++){
            positions[i] = new PVector(x+random(-50,50),y+random(-50,50));
            particles.add(new Particle(positions[i], 1+(int)random(numTypes-1))); // type 0 is food
        }
    }

    void mutateCell(){
        for(int i = 0; i < numTypes; i++){
            for(int j= 0; j < numTypes; j++){  
                internalForces[i][j] += random(-0.1,0.1);
                internalMins[i][j] += random(-5,5);
                internalRadii[i][j] += random(-10,10);
                externalForces[i][j] += random(-0.1,0.1);
                externalMins[i][j] += random(-5,5);
                externalRadii[i][j] += random(-10,10);
            }
        }

        // mutates the position of each particle and changes the type of some particles (10%)
        for(int  i = 0; i < numParticles; i++){
            positions[i] = new PVector(positions[i].x+random(-5,5),positions[i].y+random(-5,5));
            if(random(100)< 10){  // 10% of the time a particle changes type
                Particle p = particles.get(i);
                p.type = 1+(int)random(numTypes-1);
            }
        } 
    }

    // update a cell by appling each type of forces to each particle in the cell
    void update(){
        for(Particle p: particles){ // for each particle in this cell
            p.applyInternalForces(this);
            p.applyExternalForces(this);
            // p.applyFoodForces(this);
        }
        energy -= 1.0; // cells lose one energy/timestep - should be a variable. Or dependent on forces generated
    }

    void draw(){
        for(Particle p : particles){
            p.draw();
        }
    }

}