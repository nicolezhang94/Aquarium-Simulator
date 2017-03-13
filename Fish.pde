class Fish extends KDObject {
  public FishType type;
  public Sex sex;
  public color colour;
  public boolean isDead;
  public PVector velocity;
  public PVector acceleration;
  public float lifespan;
  public boolean hungry;

  public Fish() {
    this.position = new PVector();
    this.velocity = new PVector();
    this.acceleration = new PVector();
    this.neighbors = new ArrayList<KDObject>();
    this.type = FishType.PREY;
    this.sex = random(1) < 0.5 ? Sex.MALE : Sex.FEMALE;
    if (this.sex == Sex.FEMALE && this.type == FishType.PREY) {
      this.colour = color(100, 144, 360, 360);
    } else if (this.sex == Sex.MALE && this.type == FishType.PREY) {
      this.colour = color(100, 288, 360, 360);
    } else if (this.type == FishType.EGG) {
      this.colour = color(60, 72, 360);
    } else {
      this.colour = color(20, 216, 360, 360);
    }
    this.isDead = false;
    this.hungry = false;
    this.lifespan = 15;
  }

  public Fish(PVector pos, FishType type) {
    this.position = pos;
    if (type != FishType.EGG) {
      this.velocity = new PVector(random(-60, 60), random(-60, 60), 0);
    } else {
      this.velocity = new PVector();
    }
    this.acceleration = new PVector();
    this.neighbors = new ArrayList<KDObject>();
    this.type = type;
    this.sex = random(1) < 0.5 ? Sex.MALE : Sex.FEMALE;
    if (this.sex == Sex.FEMALE && this.type == FishType.PREY) {
      this.colour = color(100, 144, 360, 360);
    } else if (this.sex == Sex.MALE && this.type == FishType.PREY) {
      this.colour = color(100, 288, 360, 360);
    } else if (this.type == FishType.EGG) {
      this.colour = color(60, 72, 360);
    } else {
      this.colour = color(20, 216, 360, 360);
    }
    this.isDead = false;
    this.hungry = false;
    this.lifespan = 15;
  }

  public Fish(PVector pos, FishType type, Sex sex) {
    this.position = pos;
    this.velocity = new PVector();
    this.acceleration = new PVector();
    this.neighbors = new ArrayList<KDObject>();
    this.type = type;
    this.sex = sex;
    if (this.sex == Sex.FEMALE && this.type == FishType.PREY) {
      this.colour = color(100, 144, 360, 360);
    } else if (this.sex == Sex.MALE && this.type == FishType.PREY) {
      this.colour = color(100, 288, 360, 360);
    } else if (this.type == FishType.EGG) {
      this.colour = color(60, 72, 360);
    } else {
      this.colour = color(20, 216, 360, 360);
    }
    this.isDead = false;
    this.lifespan = 15;
  }

  public void reproduce() {
    if (sex == Sex.FEMALE && type == FishType.PREY  && random(1) < 0.0001) {
      fishes.add(new Fish(position.copy(), FishType.EGG));
      birth.play();
      birth.rewind();
    }
  }

  public void getHungry() {
    if (type == FishType.PREY  && random(1) < 0.0005) {
      hungry = true;
    }
  }

  public void fixNeighbors() {
    ArrayList<KDObject> newNeighbors = new ArrayList<KDObject>();
    if (type == FishType.PREDATOR) {
      for (KDObject o : neighbors) {
        if (((Fish)o).type == FishType.PREY)
          newNeighbors.add(o);
      }
    } else if (type == FishType.PREY) {
      for (KDObject o : neighbors) {
        if (!(((Fish)o).hungry))
          newNeighbors.add(o);
      }
    }
    neighbors = newNeighbors;
  }

  public Fish nearestPrey() {
    float min = MAX_FLOAT;
    Fish closest = new Fish();
    for (KDObject f : neighbors) {
      if (dist(position.x, position.y, f.position.x, f.position.y) < min && ((Fish)f).type == FishType.PREY) {
        min = dist(position.x, position.y, f.position.x, f.position.y);
        closest = (Fish)f;
      }
    }
    return closest;
  }
}

public enum FishType {
  PREY(7), 
    PREDATOR(15), 
    EGG(2);

  private float size;

  private FishType(float s) {
    size = s;
  }

  public float getSize() {
    return size;
  }
}

//Possibly will make them lay eggs that will hatch
public enum Sex {
  MALE, FEMALE;
}