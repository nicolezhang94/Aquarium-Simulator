import ddf.minim.*; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import java.util.Iterator;
import java.util.Vector;
import java.util.Comparator;
import java.util.Collections;
import java.util.List;

ArrayList<Particle> particles = new ArrayList<Particle>();
Vector<Fish> fishes = new Vector<Fish>();
KDTree fishKD;
int maxZ = 600;
PVector gravity = new PVector(0.0, 10.0, 0.0);
PVector bubbleGravity = new PVector(0.0, -10.0, 0.0);
PVector goal;
float elapsedTime;
float startTime;
float decayFactor = 0.75;
float radius = 4.0;
float dt = 0;
float speedFactor = 50;
float goalTimer = 0;

int maxFish = 200;

AudioPlayer bubble1;
AudioPlayer bubble2;
AudioPlayer bubble3;
AudioPlayer bubbles;
AudioPlayer tank;
AudioPlayer birth;
AudioPlayer pop;
Minim minim;

void animateScene() {
  elapsedTime = millis() - startTime;
  startTime = millis();
  dt = elapsedTime/1000;
  goalTimer += elapsedTime;

  if (goalTimer % 10000 <= 100) {
    goal = new PVector(random(60, width-60), random(140, height-60), 0);
  }

  Iterator<Particle> it = particles.iterator();

  while (it.hasNext()) {
    Particle p = it.next();

    moveParticle(p);
    if (p.lifespan <= 0) {
      it.remove();
    }
  }

  if (fishes.size() != 0) {
    fishKD = new KDTree(fishes);
  }

  for (int i = 0; i < fishes.size(); i++) {    
    Fish f = fishes.get(i);
    if (f.type == FishType.EGG && f.lifespan <= 0) {
      f.type = FishType.PREY;
      f.velocity.set(random(-50, 50), random(-50, 0), 0);
      if (f.sex == Sex.FEMALE) {
        f.colour = color(100, 144, 360, 360);
      } else {
        f.colour = color(100, 288, 360, 360);
      }
      pop.play();
      pop.rewind();
    }
    if (f.isDead) {    
      fishes.remove(f);    
      //The next fish will get skipped otherwise. We could fix this with a LinkedList maybe?
      i--;
    } else {
      if (fishes.size() < maxFish) {
        f.reproduce();
      }
      if (f.type == FishType.PREY) {
        f.fixNeighbors();
        if (f.hungry && particles.size() > 0) {
          PVector food = getFood(f);
          if (food != null) {
            f.velocity.set(food);
          } else {
            boids(f);
          }
        } else
          boids(f);
      } else if (f.type == FishType.PREDATOR) {
        f.findNeighbors(fishKD, 50);
        f.fixNeighbors();
        if (f.neighbors.size() != 0) {
          PVector prey = preyChase(f);
          prey.mult(15.0);
          f.acceleration.add(prey);
        }
        PVector w = wallForce(f);
        w.mult(2.0);
        f.acceleration.add(w);
        f.velocity.add(f.acceleration);
        f.velocity.limit(speedFactor);
        f.acceleration.mult(0);
      }
      moveFish(f);
    }
  }
}

void boids(Fish f) {
  f.findNeighbors(fishKD, 50);
  if (f.neighbors.size() != 0) {
    PVector s = separation(f);
    PVector a = alignment(f);
    PVector c = cohesion(f);
    PVector p = predAvoid(f);
    //        PVector g = goalMove(f);
    s.mult(3.0);
    a.mult(1.5);
    c.mult(0.8);
    p.mult(15.0);

    //        g.mult(2.0);
    f.acceleration.add(s);
    f.acceleration.add(a);
    f.acceleration.add(c);
    f.acceleration.add(p);

    //        f.acceleration.add(g);
    //f.velocity.add(separation(f).mult(1.5)).add(cohesion(f).mult(1.0)).add(alignment(f).mult(1.2)).limit(speedFactor);
  }
  PVector w = wallForce(f);
  w.mult(9.0);
  f.acceleration.add(w);

  f.velocity.add(f.acceleration);
  f.velocity.limit(speedFactor);
  f.acceleration.mult(0);
}

void keyPressed() {
  int currentFish = fishes.size();
  if (currentFish < maxFish) {
    if (key == '1') {
      PVector position = new PVector(random(80, width-80), random(155, height-80), 0);
      Fish f = new Fish(position, FishType.PREY);
      fishes.add(f);
    } else if (key == '2') {
      PVector position = new PVector(random(80, width-80), random(155, height-80), 0);
      Fish f = new Fish(position, FishType.PREDATOR);
      fishes.add(f);
    }
  }
  if (key == 'r') {
    fishes.clear();
  }
}

void collisionDetection(Fish fish) {
  for (KDObject o : fish.neighbors) {
    Fish f = (Fish)o;
    if (f.type == fish.type && dist(f.position.x, f.position.y, fish.position.x, fish.position.y) < 2 * fish.type.size -2) {
      PVector r = new PVector(f.position.x-fish.position.x, f.position.y - fish.position.y).normalize();
      PVector pos = PVector.sub(f.position, PVector.mult(r, f.type.size + fish.type.size));

      fish.position.x = pos.x;
      fish.position.y = pos.y;
    }
  }
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    if (mouseY < 75 && mouseX > 150 && mouseX < width-150) {
      for (int i = 0; i < 8; i++) {
        PVector position = new PVector(float(mouseX), float(mouseY), 0);
        PVector velocity = new PVector(random (-15, 15), random(40, 55), 0);
        Particle p = new Particle(position, velocity, gravity, 12.0, 3.5, ParticleType.FOOD);
        p.colour = color(45, 120, 280, 300);
        particles.add(p);
      }
    }
    if (mouseY > 150 && mouseY < height-75 && mouseX > 140 && mouseX < width-140) {
      for (int i = 0; i < 3; i++) {
        PVector position = new PVector(random(float(mouseX)-25, float(mouseX)+25), random(float(mouseY)-25, float(mouseY)+25), 0);
        PVector velocity = new PVector(random (-20, 20), random(-130, -90), 0);
        Particle p = new Particle(position, velocity, bubbleGravity, 15.0, random(4, 8), ParticleType.BUBBLE);
        p.colour = color(0, 0, 360, 80);
        particles.add(p);
        bubbles.play();
        bubbles.rewind();
      }
    }
  } else if (mouseButton == RIGHT) {
  }
}


void moveParticle(Particle p) {
  if (p.type == ParticleType.FOOD) {
    if (p.position.y < 133) {
      float noise = noise(p.position.x, p.position.y) - 0.5;
      p.position.x += noise;
      p.velocity.x += noise;
      p.position.add(PVector.mult(p.velocity, dt));
      p.velocity.add(PVector.mult(p.acceleration, dt));
    }
    p.lifespan -= dt;
    float opacity = p.opacity; 
    if (p.lifespan < 2.0) {
      opacity = p.opacity - 60;
      p.size = p.size - 0.025;
    }
    p.colour = color(hue(p.colour), saturation(p.colour), brightness(p.colour), opacity);
  } else if (p.type == ParticleType.BUBBLE) {
    if (p.position.y > 140) {
      p.position.add(PVector.mult(p.velocity, dt));
      p.velocity.add(PVector.mult(p.acceleration, dt));
    } else {
      p.lifespan = 0;
      int randomSound = (int)random(1, 3);
      if (randomSound == 1) {
        bubble1.play();
        bubble1.rewind();
      } else if (randomSound == 2) {
        bubble2.play();
        bubble2.rewind();
      } else if (randomSound == 3) {
        bubble3.play();
        bubble3.rewind();
      }
    }
  }
}

void moveFish(Fish f) {
  if (f.type == FishType.PREY) {
    if (f.hungry) {
      for (Particle p : particles) {
        if (dist(p.position.x, p.position.y, f.position.x, f.position.y) < 10) {
          p.lifespan = 0;
          f.hungry = false;
        }
      }
    } else
      f.getHungry();
  } else if (f.type == FishType.PREDATOR) {
    //if (f.neighbors.size() > 0) {*/   
    Fish nearestPrey = f.nearestPrey();
    if (dist(nearestPrey.position.x, nearestPrey.position.y, f.position.x, f.position.y) < 10) {
      nearestPrey.isDead = true;
    }/* else {
     PVector direction = PVector.sub(nearestPrey.position, f.position).normalize();
     f.velocity.set(PVector.mult(direction, f.velocity.mag()));
     }
     }*/
  } else if (f.type == FishType.EGG) {
    if (f.position.y < height - 71) {
      f.velocity.add(PVector.mult(gravity, dt));
    } else
      f.velocity.mult(0);
    f.lifespan -= dt;
  }
  checkWallCollision(f);
  f.position.add(PVector.mult(f.velocity, dt));
  //collisionDetection(f);
}

PVector wallForce(Fish f) {
  float dist = 60;
  float distScale = 8;
  PVector xNorm = new PVector(0, 0, 0), yNorm = new PVector(0, 0, 0);
  if (f.position.x < (70 + dist)) {
    xNorm.set(1, 0, 0).div(dist(f.position.x, f.position.y, 70, f.position.y) * distScale);
  } else if (f.position.x > width-(70 + dist)) {
    xNorm.set(-1, 0, 0).div(dist(f.position.x, f.position.y, width-70, f.position.y) * distScale);
  } else if (f.position.y < (160 + dist)) {
    yNorm.set(0, 1, 0).div(dist(f.position.x, f.position.y, f.position.x, 160) * distScale);
  } else if (f.position.y > height-(70 + dist)) {
    yNorm.set(0, -1, 0).div(dist(f.position.x, f.position.y, f.position.x, 70) * distScale);
  }

  return PVector.add(xNorm, yNorm).normalize();
}

void checkWallCollision(Fish f) {
  PVector wallNormal = null, i;
  i = PVector.mult(f.velocity, -1).normalize();
  if (f.position.x < 70) {
    wallNormal = new PVector(1, 0, 0).normalize();
    f.position.set(new PVector(71, f.position.y, f.position.z));
  } else if (f.position.x > width-70) {
    wallNormal = new PVector(-1, 0, 0).normalize();
    f.position.set(new PVector(width-71, f.position.y, f.position.z));
  } else if (f.position.y < 140) {
    wallNormal = new PVector(0, 1, 0).normalize();
    f.position.set(new PVector(f.position.x, 141, f.position.z));
  } else if (f.position.y > height-70) {
    wallNormal = new PVector(0, -1, 0).normalize();
    f.position.set(new PVector(f.position.x, height-71, f.position.z));
  }

  if (wallNormal != null) {
    f.velocity = PVector.mult(PVector.sub(PVector.mult(wallNormal, 2 * PVector.dot(wallNormal, i)), i), f.velocity.mag());
  }
}

PVector goalMove(Fish fish) {
  return PVector.sub(goal, fish.position).normalize();
}

PVector separation(Fish fish) {
  PVector total = new PVector();
  float minSep = 40, dist;
  for (KDObject o : fish.neighbors) {
    Fish f = (Fish)o;
    if (f.type == fish.type) {
      dist = dist(fish.position.x, fish.position.y, o.position.x, o.position.y);
      if (dist < minSep) {
        total.sub(PVector.div(PVector.sub(o.position, fish.position).normalize(), dist));
      }
    }
  }

  return total.mult(20);
}

PVector predAvoid(Fish fish) {
  PVector total = new PVector();
  float minSep = 60, dist;
  for (KDObject o : fish.neighbors) {
    Fish f = (Fish)o;
    if (f.type == FishType.PREDATOR) {
      dist = dist(fish.position.x, fish.position.y, o.position.x, o.position.y);
      if (dist < minSep) {
        total.sub(PVector.div(PVector.sub(o.position, fish.position).normalize(), dist));
      }
    }
  }

  return total.mult(40);
}

PVector alignment(Fish fish) {
  PVector total = new PVector();
  for (KDObject o : fish.neighbors) {
    Fish f = (Fish)o;
    if (f.type == fish.type)
      total.add(f.velocity);
  }
  if (fish.neighbors.size() > 0)
    total.div(fish.neighbors.size());

  return total.sub(fish.velocity).mult(0.5);
}

PVector cohesion(Fish fish) {
  PVector total = new PVector();
  for (KDObject o : fish.neighbors) {    
    Fish f = (Fish)o;
    if (f.type == fish.type)
      total.add(o.position);
  }

  if (fish.neighbors.size() > 0)
    total.div(fish.neighbors.size());

  return total.sub(fish.position).mult(0.2);
}

PVector preyChase(Fish fish) {
  PVector total = new PVector(0, 0, 0);
  for (KDObject o : fish.neighbors) {    
    Fish f = (Fish)o;
    if (f.type == FishType.PREY)
      total.sub(PVector.sub(fish.position, o.position).normalize());
  }

  if (fish.neighbors.size() > 0)
    total.div(fish.neighbors.size());

  return total;
}

PVector getFood(Fish fish) {
  Particle food = null;
  for (Particle p : particles) {
    if (p.type == ParticleType.FOOD) {
      food = p;
      break;
    }
  }

  if (food == null)
    return null;

  return PVector.sub(food.position, fish.position).normalize().mult(speedFactor);
}

void setup() {
  size(900, 600, P3D);
  surface.setTitle("Aquarium Simulator 2015");
  sphereDetail(2);
  goal = new PVector(random(60, width-60), random(140, height-60), 0);

  minim = new Minim(this);

  bubbles = minim.loadFile("bubbles.wav");
  bubble1 = minim.loadFile("bubble1.wav");
  bubble2 = minim.loadFile("bubble2.wav");
  bubble3 = minim.loadFile("bubble3.wav");
  tank = minim.loadFile("tank2.wav");
  birth = minim.loadFile("birth.wav");
  pop = minim.loadFile("pop.wav");

  bubble1.setGain(0.1);
  bubble2.setGain(0.1);
  bubble3.setGain(0.1);

  tank.play();
  tank.loop();
}

void draw() {
  Particle p;
  colorMode(HSB, 360);
  background(220, 180, 310);
  pointLight(0, 0, 0, width/2, height/2, -maxZ/2);
  ambientLight(0, 0, 360);

  animateScene();

  Iterator<Particle> it = particles.iterator();

  fill(220, 180, 250);
  beginShape();
  vertex(50, 75, -10);
  vertex(width-50, 75, -10);
  vertex(width-50, height-50, -10);
  vertex(50, height-50, -10);
  endShape();

  fill(220, 180, 270);
  beginShape();
  vertex(55, 130, -10);
  vertex(width-55, 130, -10);
  vertex(width-55, height-55, -10);
  vertex(55, height-55, -10);
  endShape();

  fill(0, 0, 0);
  beginShape();
  vertex(55, 75, 10);
  vertex(width-55, 75, 10);
  vertex(width-55, 100, 10);
  vertex(55, 100, 10);
  endShape();

  fill(120, 241, 216);
  beginShape();
  vertex(90, height-60, -5);
  vertex(110, height-60, -5);
  vertex(118, height-90, -5);
  vertex(104, height-120, -5);
  vertex(115, height-150, -5);
  vertex(106, height-170, -5);
  vertex(100, height-160, -5);
  vertex(105, height-140, -5);
  vertex(95, height-110, -5);
  vertex(100, height-80, -5);
  endShape();

  beginShape();
  vertex(90+80, height-60, -5);
  vertex(110+80, height-60, -5);
  vertex(118+80, height-120, -5);
  vertex(104+85, height-170, -5);
  vertex(115+80, height-210, -5);
  vertex(106+80, height-240, -5);
  vertex(100+80, height-200, -5);
  vertex(105+80, height-160, -5);
  vertex(95+80, height-110, -5);
  vertex(100+80, height-80, -5);
  endShape();

  fill(0, 0, 260);
  beginShape();
  vertex(width-110, height-65, -5);
  vertex(width-170, height-65, -5);
  vertex(width-190, height-95, -5);
  vertex(width-180, height-130, -5);
  vertex(width-140, height-110, -5);
  endShape();

  textSize(32);
  fill(0, 0, 360);
  //  text(frameRate, width - 100, 50);

  noStroke();

  sphereDetail(3);
  for (Fish f : fishes) {
    fill(f.colour);
    pushMatrix();
    translate(f.position.x, f.position.y, f.position.z);
    sphere(f.type.getSize());
    popMatrix();
  }

  while (it.hasNext()) {
    p = it.next();
    if (p.type == ParticleType.FOOD) {
      sphereDetail(2);
    } else if (p.type == ParticleType.BUBBLE) {
      sphereDetail(6);
    }
    fill(p.colour);
    pushMatrix();
    translate(p.position.x, p.position.y, p.position.z);
    sphere(p.size);
    popMatrix();
  }
}