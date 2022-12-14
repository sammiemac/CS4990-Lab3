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
   ArrayList<Wall> connections;
   ArrayList<MazeCell> cells;
   
   Map()
   {
      walls = new ArrayList<Wall>();
      connections = new ArrayList<Wall>();
      cells = new ArrayList<MazeCell>();
   }
   
   void generate(int which)
   {
      walls.clear(); // resets map
      connections.clear(); // resets connections
      cells.clear(); // resets cells
      
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
      for (int i = GRID_SIZE; i <= width; i += GRID_SIZE)
      {
          for (int j = GRID_SIZE; j <= height; j += GRID_SIZE)
          {
              walls.add(new Wall(new PVector(i, j - GRID_SIZE), new PVector(i, j)));
          }
      }
      
      // Creating maze cells at the center of each grid box
      for (int i = GRID_SIZE/2; i <= height - GRID_SIZE/2; i += GRID_SIZE)
      {
          for (int j = GRID_SIZE/2; j <= width - GRID_SIZE/2; j += GRID_SIZE)
          {
              cells.add(new MazeCell(new PVector(j, i)));
          }
      }
      
      // Establishing neighbors between maze cells
      for (int i = 0; i < cells.size(); i++)
      {
          for (int j = 0; j < cells.size(); j++)
          {
               if (i == j)
                   continue;
               if (cells.get(i).point.x == cells.get(j).point.x)
               {
                   if (cells.get(i).point.y + GRID_SIZE == cells.get(j).point.y ||
                       cells.get(i).point.y - GRID_SIZE == cells.get(j).point.y)
                   {
                       cells.get(i).addNeighbor(cells.get(j));
                   }
               }
               if (cells.get(i).point.y == cells.get(j).point.y)
               {
                   if (cells.get(i).point.x + GRID_SIZE == cells.get(j).point.x ||
                       cells.get(i).point.x - GRID_SIZE == cells.get(j).point.x)
                   {
                       cells.get(i).addNeighbor(cells.get(j));
                   }
               }
          }
      }
      
      // Using Prim's algorithm to remove walls for maze
      int index = int(random(cells.size())); // choose a random starting cell
      generatePath(cells.get(index));
   }
   
   // Using Prim's algorithm
   void generatePath(MazeCell cell)
   {
       cell.visited = true; // marks a cell as visited
       int index = int(random(cell.neighbors.size())); // chooses a random neighbor to try and connect to
       
       for (int i = 0; i < cell.neighbors.size(); i++)
       {
           if (cell.neighbors.get(index).visited == false)
           {
               // Add a wall connection between the two neighbors
               connections.add(new Wall(cell.point, cell.neighbors.get(index).point));
               
               // Get the coordinates of the connection wall to remove the maze wall it is cutting through
               removeWall(cell.point, cell.neighbors.get(index).point);
               
               // Do the same procedure for the neighbor that was connected to
               generatePath(cell.neighbors.get(index));
           }
           // When all cells have been visited on a path, look for the next unvisited cell and start from there
           index = (index+1)%cell.neighbors.size();
       }
   }
   
   void removeWall(PVector from, PVector to)
   {
       for (int i = 0; i < walls.size(); i++)
       {
           if (walls.get(i).crosses(from, to))
           {
               walls.remove(i);
               break;
           }
       }
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
      if (DEBUG)
      {
        for (MazeCell w : cells)
        {
           w.draw();
        }
        for (Wall w : connections)
        {
            stroke(255, 0, 0);
            strokeWeight(0.75);
            line(w.start.x, w.start.y, w.end.x, w.end.y);
        }
      }
   }
}

// Added MazeCell class to keep track of when using Prim's algorithm
class MazeCell
{
    PVector point;
    ArrayList<MazeCell> neighbors;
    boolean visited;
    
    MazeCell(PVector point)
    {
        this.point = point;
        neighbors = new ArrayList<MazeCell>();
        visited = false;
    }
    
    void addNeighbor(MazeCell neighbor)
    {
        neighbors.add(neighbor);
    }
    
    void draw()
    {
        stroke(255, 0, 0);
        strokeWeight(3);
        fill(255, 0, 0);
        circle(point.x, point.y, GRID_SIZE/25);
    }
}
