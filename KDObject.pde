abstract class KDObject implements Comparable {
  public PVector position;
  public ArrayList<KDObject> neighbors;
  public float priority;

  public void findNeighbors(KDTree<? extends KDObject> kd, float range) {
    neighbors.clear();
    search(kd.root, 0, range); 
    neighbors.remove(this);
  }

  private void search(KDNode<? extends KDObject> root, int depth, float range) {
    float axis = 0;
    //Node in range? Add it.
    if(root == null)
      return; //<>// //<>//
    if (root.isLeaf && dist(root.data.position.x, root.data.position.y, position.x, position.y) < range && !root.data.equals(this)) {
      neighbors.add(root.data);
      return;
    }

    //Gets the axis that the KDNode was split on
    if (depth % 2 == 0) {
      axis = position.x;
    } else {
      axis = position.y;
    }

    //Search the side the target is on first. If range ring around target overlaps either
    //child node's territory, search that subtree. (I'm pretty sure this is just a fancy DFS
    //if we're looking for neighbors in a range.
    if (axis < root.value) {
      if (axis - range <= root.value) search(root.left, depth + 1, range);
      if (axis + range > root.value) search(root.right, depth + 1, range);
    } else {
      if (axis + range > root.value) search(root.right, depth + 1, range);
      if (axis - range <= root.value) search(root.left, depth + 1, range);
    }
  }

  @Override
    public boolean equals(Object other) {
    return ((KDObject)other).position.x == position.x && ((KDObject)other).position.y == position.y;
  }

  @Override
    public int compareTo(Object other) {
    return this.priority > ((KDObject)other).priority ? 1 : this.priority < ((KDObject)other).priority ? -1 : 0;
  }
}