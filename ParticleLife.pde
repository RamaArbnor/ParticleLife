int numTypes = 6;  // 0 is food, plus 5 more, type 1 'eats' food the others just generate forces
int colorStep = 360/numTypes;
float friction = 0.2;
int minPopulation = 15;
int numFood = 200; // starting amount of food
int foodRange = 5; // distance to collect food
int foodEnergy = 100; // energy from food
int reproductionEnergy = 1000; 
int startingEnergy = 400;
float K = 0.2;
ArrayList<Cell> world;
ArrayList<Particle> food;
boolean display = true; // whether or not to display, d toggles, used to evolve faster
boolean drawLines = false; // whether or not to draw lines connecting a cell's particles, l to toggle



void setup() {
  size(1200,880);
  colorMode(HSB, 360, 100, 100);

  noStroke();
  frameRate(10);
  world = new ArrayList<Cell>();
  for (int i = 0; i < minPopulation; i++) {
    world.add(new Cell(random(width), random(height)));
  }
  food = new ArrayList<Particle>();
  for (int i = 0; i < numFood; i++) {
    food.add(new Particle(new PVector(random(width), random(height)), 0));
  }

}

void draw() {
  background(51);
  for (Cell c : world) { // update and display each cell
    c.update();

    c.draw();

  }

  for (int i = world.size()-1; i >= 0; i--) { // remove dead (energyless cells)
    Cell c = world.get(i);
    if (c.energy <= 0) {
      //convertToFood(c);
      world.remove(i);  // could convert to food instead
    }
  }

  eat(); // eat food


  for (Particle p : food) {
      p.draw();
  }
  

  //don't use if dead cells are converted to food
  if(frameCount % 5 == 0){  // add a food every 5 timesteps 
    food.add(new Particle(new PVector(random(width), random(height)), 0));
  }

}

// void replace(){
//   if(world.size() < minPopulation){  
//     int parent = int(random(world.size()));
//     Cell temp = new Cell(random(width), random(height));
//     Cell parentCell = world.get(parent);
//     temp.copyCell(parentCell);
//     temp.mutateCell();
//     world.add(temp);
//   }
// }

void eat() {
  float dis;
  PVector vector = new PVector(0, 0);
  for (Cell c : world) {  // for every cell
    for (Particle p : c.particles) {  // for every particle in every cell
      if (p.type == 1) { // 1 is the eating type of paricle
        for (int i = food.size()-1; i >= 0; i--) {  // for every food particle - yes this gets slow
          Particle f = food.get(i);
          vector.mult(0);
          vector = f.position.copy();
          vector.sub(p.position); 
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