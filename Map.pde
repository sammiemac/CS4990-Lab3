class Wall
{
   PVector start;
   PVector end;
   PVector normal;
   PVector direction;
   float len;
   
   Wall(PVector start, PVector end)
   {
      this.start = start;
      this.end = end;
      direction = PVector.sub(this.end, this.start);
      len = direction.mag();
      direction.normalize();
      normal = new PVector(-direction.y, direction.x);
   }
   
   // Added crosses function from Lab 1
   boolean crosses(PVector from, PVector to)
   {
      // Vector pointing from `this.start` to `from`
      PVector d1 = PVector.sub(from, this.start);
      // Vector pointing from `this.start` to `to`
      PVector d2 = PVector.sub(to, this.start);
      // If both vectors are on the same side of the wall
      // their dot products with the normal will have the same sign
      // If they are both positive, or both negative, their product will
      // be positive.
      float dist1 = normal.dot(d1);
      float dist2 = normal.dot(d2);
      if (dist1 * dist2 > 0) return false;
      
      // if the start and end are on different sides, we need to determine 
      // how far the intersection point is along the wall
      // first we determine how far the projections of from and to are 
      // along the wall
      float ldist1 = direction.dot(d1);
      float ldist2 = direction.dot(d2);
      
      // the distance of the intersection point from the start
      // is proportional to the normal distance of `from` in 
      // along the total movement
      float t = dist1/(dist1 - dist2);

      // calculate the intersection as this proportion
      float intersection = ldist1 + t*(ldist2 - ldist1);
      if (intersection < 0 || intersection > len) return false;
      return true;      
   }
   
   // Return the mid-point of this wall
   PVector center()
   {
      return PVector.mult(PVector.add(start, end), 0.5);
   }
   
   void draw()
   {
       stroke(255);
       strokeWeight(3);
       line(start.x, start.y, end.x, end.y);
       if (SHOW_WALL_DIRECTION)
       {
          PVector marker = PVector.add(PVector.mult(start, 0.2), PVector.mult(end, 0.8));
          circle(marker.x, marker.y, 5);
       }
   }
}


class Map
{
   ArrayList<Wall> walls;
   ArrayList<MazeCell> cells;
   
   Map()
   {
      walls = new ArrayList<Wall>();
      cells = new ArrayList<MazeCell>();
   }
   
   void generate(int which)
   {
      walls.clear(); // resets map
      
      // TODO: implement algorithm to generate maze
      
      // Creating base grid
      // Creating horizontal cell walls
      for (int i = GRID_SIZE; i <= height; i += GRID_SIZE)
      {
          for (int j = GRID_SIZE; j <= width; j += GRID_SIZE)
          {
              walls.add(new Wall(new PVector(j - GRID_SIZE, i), new PVector(j, i)));
          }
      }
      
      // Creating vertical cell walls
      for (int i = 0; i <= width; i += GRID_SIZE)
      {
          for (int j = 0; j <= height; j += GRID_SIZE)
          {
              walls.add(new Wall(new PVector(i, j), new PVector(i, j + GRID_SIZE)));
          }
      }
      
      // Creating maze cells
      for (int i = GRID_SIZE/2; i <= height - GRID_SIZE/2; i += GRID_SIZE)
      {
          for (int j = GRID_SIZE/2; j <= width - GRID_SIZE/2; j += GRID_SIZE)
          {
              cells.add(new MazeCell(new PVector(j, i)));
          }
      }
      
      // Creating connections between maze cells **WIP**
   }
   
   void update(float dt)
   {
      draw();
   }
   
   void draw()
   {
      stroke(255);
      strokeWeight(3);
      for (Wall w : walls)
      {
         w.draw();
      }
      for (MazeCell w : cells)
      {
         w.draw();
      }
   }
}

// Added MazeCell class to keep track of when using Prim's algorithm
class MazeCell
{
    PVector point;
    ArrayList<PVector> neighbors;
    ArrayList<Wall> connections;
    boolean visited;
    
    MazeCell(PVector point)
    {
        this.point = point;
        neighbors = new ArrayList<PVector>();
        connections = new ArrayList<Wall>();
        visited = false;
    }
    
    void addNeighbor(PVector neighbor)
    {
        neighbors.add(neighbor);
        connections.add(new Wall(this.point, neighbor));
    }
    
    void draw()
    {
        stroke(255, 0, 0);
        strokeWeight(3);
        fill(255, 0, 0);
        circle(point.x, point.y, GRID_SIZE/25);
        for (Wall w : connections)
        {
           w.draw();
        }
    }
}
