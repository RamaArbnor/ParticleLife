class cell{  // or colony of cells
  ArrayList<particle> swarm; // shouldn't have used the name swarm again
  float internalForces[][];
  float externalForces[][];
  float internalMins[][];
  float externalMins[][];
  float internalRadii[][];
  float externalRadii[][];
  PVector positions[];  // probably better as an arraylist
  int numParticles = 40;
  int energy = startingEnergy;
  int radius; // avg distance from center
  PVector center = new PVector(0,0); // center of the cell
  particle centerParticle; 
  
  boolean selected = false;
  float livingCost;

  String DNA = "";

  cell(float x, float y){
    numParticles = 40;
    internalForces = new float[numTypes][numTypes];
    externalForces = new float[numTypes][numTypes];
    internalMins = new float[numTypes][numTypes];
    externalMins = new float[numTypes][numTypes];
    internalRadii = new float[numTypes][numTypes];
    externalRadii = new float[numTypes][numTypes];
    // Positions are the inital relative positions of all of the particles.
    // This is critcal to cells starting in a 'good' configuration.
    positions = new PVector[numParticles];
    swarm = new ArrayList<particle>();

    for(int i = 0; i < numParticles; i++){
      //add a random letter (A,B,C,D,E) to the DNA string\
      // DNA += (char)(65+(int)random(5));
      DNA += "A";
    }

    // print("DNA: " + DNA + "\n");

    generateNew(x,y);
  }
  
  // generate the parameters for a new cell
  // note: all of the random ranges could be tweaked
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
    for(int  i = 0; i < numParticles; i++){
      positions[i] = new PVector(x+random(-50,50),y+random(-50,50));
      // get the i type from the DNA string and map it to a type
      // swarm.add(new particle(positions[i], 1+(int)random(numTypes-1))); // type 0 is food

      switch (DNA.charAt(i)) {
        case 'A':
          swarm.add(new particle(positions[i], 1));
          break;
        case 'B':
          swarm.add(new particle(positions[i], 2));
          break;
        case 'C':
          swarm.add(new particle(positions[i], 3));
          break;
        case 'D':
          swarm.add(new particle(positions[i], 4));
          break;
        case 'E':
          swarm.add(new particle(positions[i], 5));
          break;
        default:
          swarm.add(new particle(positions[i], 1));
          break;
        
      }

      // println("Type: " + type);
      // swarm.add(new particle(positions[i], 1+(int)random(numTypes-1))); 
    
    }

    centerParticle = swarm.get(0);
    center = centerParticle.position;
    swarm.get(0).center = true;

  }
  
  // Used to copy the values from a parent cell to a daughter cell.
  // (I don't trust deep copy when data structures get complex :)
  void copyCell(cell c){
    for(int i = 0; i < numTypes; i++){
      for(int j= 0; j < numTypes; j++){
        internalForces[i][j] = c.internalForces[i][j];
        internalMins[i][j] = c.internalMins[i][j];
        internalRadii[i][j] = c.internalRadii[i][j];
        externalForces[i][j] = c.externalForces[i][j];
        externalMins[i][j] = c.externalMins[i][j];
        externalRadii[i][j] = c.externalRadii[i][j];
      }
    }
    float x = random(width);
    float y = random(height);
    for(int  i = 0; i < c.numParticles; i++){
      positions[i] = new PVector(x+c.positions[i].x,y+c.positions[i].y);
      //swarm[i] = new particle(positions[i], c.swarm[i].type);
      particle p = swarm.get(i);
      particle temp = new particle(p.position,p.type); // create a new particle from the parent
      swarm.add(temp); // add to the new cell
    }
  }
  
  // When a new cell is created from a 'parent' cell the new cell's values are mutated
  // This mutates all values a 'little' bit. Mutating a few values by a larger amount could work better
  void mutateCell(){
    // Mutate the DNA string by changing a few letters and changing the number of particles
    
    for(int i = 0; i < numParticles; i++){
      if(random(100) < 25){
        DNA = DNA.substring(0,i) + (char)(65+(int)random(5)) + DNA.substring(i+1);
        // println("Mutated DNA: " + DNA);
      }
    }

    //change the type of particles to the new DNA
    for(int  i = 0; i < numParticles; i++){
      particle p = swarm.get(i);

      switch (DNA.charAt(i)) {
        case 'A':
          p.type = 1;
          break;
        case 'B':
          p.type = 2;
          break;
        case 'C':
          p.type = 3;
          break;
        case 'D':
          p.type = 4;
          break;
        case 'E':
          p.type = 5;
          break;
        default:
          p.type = 1;
          break;
        
      }
    }

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
    
    // for(int  i = 0; i < numParticles; i++){
    //   positions[i] = new PVector(positions[i].x+random(-5,5),positions[i].y+random(-5,5));
    //   if(random(100)< 10){  // 10% of the time a particle changes type
    //     particle p = swarm.get(i);
    //     p.type = 1+(int)random(numTypes-1);
    //   }
    // } 
    



  }

  void applyForce(PVector dir){
    for(particle p: swarm){
      p.applyForce(dir);
    }
  }
  
  void printDNA(){
    println(DNA);
    println();
    // println("Internal Forces");
    // for(int i = 0; i < numTypes; i++){
    //   for(int j= 0; j < numTypes; j++){
    //     print(internalForces[i][j] + " ");
    //   }
    //   println();
    // }
    // println("Internal Mins");
    // for(int i = 0; i < numTypes; i++){
    //   for(int j= 0; j < numTypes; j++){
    //     print(internalMins[i][j] + " ");
    //   }
    //   println();
    // }
    // println("Internal Radii");
    // for(int i = 0; i < numTypes; i++){
    //   for(int j= 0; j < numTypes; j++){
    //     print(internalRadii[i][j] + " ");
    //   }
    //   println();
    // }
    // println("External Forces");
    // for(int i = 0; i < numTypes; i++){
    //   for(int j= 0; j < numTypes; j++){
    //     print(externalForces[i][j] + " ");
    //   }
    //   println();
    // }
    // println("External Mins");
    // for(int i = 0; i < numTypes; i++){
    //   for(int j= 0; j < numTypes; j++){
    //     print(externalMins[i][j] + " ");
    //   }
    //   println();
    // }
    // println("External Radii");
    // for(int i = 0; i < numTypes; i++){
    //   for(int j= 0; j < numTypes; j++){
    //     print(externalRadii[i][j] + " ");
    //   }
    //   println();
    // }
  }

  // update a cell by appling each type of forces to each particle in the cell
  void update(){
    
    float cost = 1.0; 
    float sumDist = 0.0;
    for(particle p: swarm){ 
      p.applyInternalForces(this);
      p.applyExternalForces(this);
      p.applyFoodForces(this);
      sumDist += p.position.dist(center);
    }
    cost += map(sumDist,0,1500,0,0.1); 
    energy -= cost/2; 
    livingCost = cost;

    for(particle p: swarm){
      p.selected = selected;
    }
    
  }
  
  void display(){
    // Code to draw lines between the particles in a cell
    if(drawLines){
      particle p1, p2;
     stroke(0,0,30);
     for(int  i = 0; i < numParticles-1; i++){
       p1 = swarm.get(i);
       p2 = swarm.get(i+1);
       line(p1.drawPos.x,p1.drawPos.y,p2.drawPos.x,p2.drawPos.y);
     }
    }
    noStroke();
    for(particle p: swarm){
      p.display();
    }
  }
}
