// An evolutionary version of Particle Life.
// By Terence Soule of Programming Chaos https://www.youtube.com/channel/UC2rO9hEjJkjqzktvtj0ggNQ
// Sets of particles (cells) share forces and share food.
// They can die of starvation or collect enough food to reproduce/
int numTypes = 6;  // 0 is food, plus 5 more, type 1 'eats' food the others just generate forces
int colorStep = 360/numTypes;
float friction = 0.85;
int minPopulation = 15;
int numFood = 100; // starting amount of food
int foodRange = 5; // distance to collect food
int foodEnergy = 100; // energy from food
int reproductionEnergy = 1000; 
int startingEnergy = 400;
float K = 0.1;
ArrayList<cell> swarm;
ArrayList<particle> food;
boolean display = true; // whether or not to display, d toggles, used to evolve faster
boolean drawLines = false; // whether or not to draw lines connecting a cell's particles, l to toggle

void setup() {
  size(1800, 1000);
  // fullScreen();
  colorMode(HSB, 360, 100, 100);
  noStroke();
  swarm = new ArrayList<cell>();
  for (int i = 0; i < minPopulation; i++) {
    swarm.add(new cell(random(width), random(height)));
  }
  food = new ArrayList<particle>();
  for (int i = 0; i < numFood; i++) {
    food.add(new particle(new PVector(random(width), random(height)), 0));
  }
  noStroke();
}

void draw() {
  background(0);
  for (cell c : swarm) { // update and display each cell
    c.update();
    if(display){
      c.display();
    }
  }
  for (int i = swarm.size()-1; i >= 0; i--) { // remove dead (energyless cells)
    cell c = swarm.get(i);
    if (c.energy <= 0) {
      //convertToFood(c);
      swarm.remove(i);  // could convert to food instead
    }
  }
  eat();  // cells collect nearby food
  replace();  // if the pop is below minPop add cells
  reproduce();  // cells with lots of energy reproduce
  
  if(display){
    for (particle p : food) {
       p.display();
    }
  }

  // statistics top left
  fill(255);
  text("Population: " + swarm.size(), 10, 20);
  text("Food: " + food.size(), 10, 40);
  text("Frame Rate: " + floor(frameRate), 10, 60);
  text("Display: " + display, 10, 80);
  text("Draw Lines: " + drawLines, 10, 100);
  text("Press d to toggle display", 10, 120);
  text("Press l to toggle draw lines", 10, 140);
  text("Press r to reproduce a random cell", 10, 160);
  text("Press p to print dna of a random cell", 10, 180);
  text("Press s to save a screenshot", 10, 200);
  text("Press u to print adam particle", 10, 220);



  //don't use if dead cells are converted to food
  if(frameCount % 5 == 0){  // add a food every 5 timesteps 
    food.add(new particle(new PVector(random(width), random(height)), 0));
  }
  //println(frameRate); // to see how changes effect efficiency
}

// for dead cells
void convertToFood(cell c){
  for(particle p: c.swarm){
    food.add(new particle(p.position, 0));
  }
}

void reproduce(){
  cell c;
  for(int i = swarm.size()-1; i>=0 ;i--){
    c = swarm.get(i);
    particle center = c.swarm.get(0); // center particle of cell
    if(c.energy > reproductionEnergy){ // if a cell has enough energy 
      cell temp = new cell(center.position.x, center.position.y);  // make a new cell at a random location
      temp.copyCell(c); // copy the parent cell's 'DNA'
      c.energy -= startingEnergy;  // parent cell loses energy (daughter cell recieves it) 
      temp.mutateCell(); // mutate the daughter cell
      swarm.add(temp);
      c.applyForce(new PVector(-1, 0)); // give the parent cell a push
      temp.applyForce(new PVector(0, -1)); // give the daughter cell a push
      println("reproduced");
    }
  }
}

// If population is below minPopulation add cells by copying and mutating
// randomly selected existing cells.
// Note: if the population all dies simultanious the program will crash - extinction!
void replace(){
  if(swarm.size() < minPopulation){  
    int parent = int(random(swarm.size()));
    cell temp = new cell(random(width), random(height));
    cell parentCell = swarm.get(parent);
    temp.copyCell(parentCell);
    temp.mutateCell();
    swarm.add(temp);
  }
}

void eat() {
  float dis;
  PVector vector = new PVector(0, 0);
  for (cell c : swarm) {  // for every cell
    for (particle p : c.swarm) {  // for every particle in every cell
      if (p.type == 1) { // 1 is the eating type of paricle
        for (int i = food.size()-1; i >= 0; i--) {  // for every food particle - yes this gets slow
          particle f = food.get(i);
          vector.mult(0);
          vector = f.position.copy();
          vector.sub(p.drawPos); 
          if (vector.x > width * 0.5) { vector.x -= width; }
          if (vector.x < width * -0.5) { vector.x += width; }
          if (vector.y > height * 0.5) { vector.y -= height; }
          if (vector.y < height * -0.5) { vector.y += height; }
          dis = vector.mag();
          if(dis < foodRange){
            c.energy += foodEnergy; // gain 100 energy for eating food 
            food.remove(i);
          }
        }
      }
    }
  }
}

void keyPressed(){
  if(key == 'd'){
    display = !display;
  }
    if(key == 'l'){
    drawLines = !drawLines;
  }

  //when r is pressed a random cell is selected and its reproduced
  if(key == 'r'){
  cell c;
  
    c = swarm.get((int) random(swarm.size()));
    particle center = c.swarm.get((int) random(c.swarm.size())); // center particle of cell
    if(c.energy > 0){ // if a cell has enough energy 
      cell temp = new cell(center.position.x, center.position.y);  // make a new cell at a random location
      temp.copyCell(c); // copy the parent cell's 'DNA'
      c.energy -= startingEnergy;  // parent cell loses energy (daughter cell recieves it) 
      temp.mutateCell(); // mutate the daughter cell
      swarm.add(temp);
      c.applyForce(new PVector(-0.1, 0)); // give the parent cell a push
      temp.applyForce(new PVector(0, -0.1)); // give the daughter cell a push
      println("reproduced");
    }
  
  }

  //print dna of a random cell
  if(key == 'p'){
    cell c;
    c = swarm.get(0);
    c.printDNA();
  }

  //save a screenshot
  if(key == 's'){
    saveFrame("screenshot.png");
  }

  //print particle stats
  if(key == 'u'){
    cell c;
    c = swarm.get(0);
    c.swarm.get(0).printStats();
  }


}
