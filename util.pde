public enum ParticleType {
  FOOD,
  BUBBLE
}

class Particle{
 public PVector position;
 public PVector velocity;
 public PVector acceleration;
 public color colour;
 public float mass;
 public float lifespan;
 public float size;
 public float opacity;
 public ParticleType type;
 
 public Particle(){
  position = new PVector();
  velocity = new PVector();
  acceleration = new PVector();
  colour = color(0, 0, 0, 1);
  mass = 0;
  lifespan = -1;
 }
 
  public Particle(PVector pos, PVector vel, PVector accel, float life, float radius, ParticleType typeIn){
  position = pos;
  velocity = vel;
  acceleration = accel;
  colour = color(0, 0, 0, 1);
  mass = 0;
  lifespan = life;
  size = radius;
  opacity = 360;
  type = typeIn;
 }
 
 public Particle(PVector pos, PVector vel, PVector accel, color col){
  position = pos;
  velocity = vel;
  acceleration = accel;
  colour = col;
  mass = 0;
  lifespan = 0;
 }
}