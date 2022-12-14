/// You do not need to change anything in this file, but you can
/// For example, if you want to add additional options controllable by keys
/// keyPressed would be the place for that.

ArrayList<PVector> waypoints = new ArrayList<PVector>();
int lastt;


Map map = new Map();

void setup() {
  size(800, 600);
  randomSeed(0);
  map.generate(-2);
}


void keyPressed()
{
    if (key == 'g')
    {
       map.generate(-2);
    }
    
    // Toggles whether you can see maze cells and its connections
    if (key == 'f')
    {
       if (DEBUG)
           DEBUG = false;
       else
           DEBUG = true;
    }
    
    // Use 'w' and 's' keys to change the GRID_SIZE; bounded 7-301
    if (key == 'w')
    {
       GRID_SIZE++;
       if (GRID_SIZE >= 301)
       {
           GRID_SIZE = 301;
           System.out.println("This maze is too large. Also too easy, don't you think?");
       }
       else
       {
           map.generate(-2);
           System.out.println("New grid size: " + GRID_SIZE);
       }
    }
    if (key == 's')
    {
       GRID_SIZE--;
       if (GRID_SIZE <= 7)
       {
           GRID_SIZE = 8;
           System.out.println("This maze is too small. Will encounter overflow error.");
       }
       else
       {
           map.generate(-2);
           System.out.println("New grid size: " + GRID_SIZE);
       }
    }
}


void draw() {
  background(0);

  float dt = (millis() - lastt)/1000.0;
  lastt = millis();
  
  map.update(dt);  
}
