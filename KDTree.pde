class KDNode<T extends KDObject>{
  public T data;
  public float value;
  public KDNode left;
  public KDNode right;
  public boolean isLeaf;
  public float depth;

  public KDNode() {
    left = null;
    right = null;
  }

  public KDNode(T d, float dep) {
    data = d;
    isLeaf = true;
    left = null;
    right = null;
    depth = dep;
    value = -1;
  }

  public KDNode(float v, KDNode l, KDNode r, float d) {
    value = v;
    data = null;
    left = l;
    right = r;
    isLeaf = false;
    depth = d;
  }
}

class KDTree<T extends KDObject>{ //<>//
  public KDNode<? extends KDObject> root;

  public KDTree(List<T> objs) {
    root = makeKD(objs, 0);
  }

  private KDNode<T> makeKD(List<T> objs, int depth) {
    if (objs.size() == 1)
      return new KDNode<T>(objs.get(0),depth);

    if (depth % 2 == 0)
      Collections.sort(objs, new Comparator<T>() {
        @Override
          public int compare(T a, T b) {
          
          return new Float(a.position.x).compareTo(b.position.x);
        }
      }
    );
    else 
    Collections.sort(objs, new Comparator<T>() {
      @Override
        public int compare(T a, T b) {
        return new Float(a.position.y).compareTo(b.position.y);
      }
    }
    );

    int median = objs.size()/2;

    float medValue = depth % 2 == 0 ? 
      (objs.get(median).position.x + objs.get(median - 1).position.x)/2
      : (objs.get(median).position.y + objs.get(median - 1).position.y)/2; 

    List<T> l = new ArrayList<T>(objs.subList(0, median));
    List<T> r = new ArrayList<T>(objs.subList(median, objs.size()));

    return new KDNode<T>(medValue, l.size() > 0 ? makeKD(l, depth + 1) : null, r.size() > 0 ? makeKD(r, depth + 1) : null, depth + 1);
  }
}