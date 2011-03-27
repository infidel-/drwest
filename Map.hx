// map class

typedef Building =
{
  var x: Int;
  var y: Int;
  var w: Int;
  var h: Int;
  var t: String; // building type
};


class Map
{
  var ui: UI;
  var game: Game;

  var cells: Hash<Cell>;
  public var objects: List<CellObject>;
  public var markers: List<Marker>;
  var cemetery: Building;
  var police: Building;
  public var width: Int;
  public var height: Int;
  public var reanimated(getReanimated, null): Int;

  public function new(g: Game)
    {
      game = g;
      ui = game.ui;
      width = UI.mapWidth;
      height = UI.mapHeight;
    }


// generate map
  public function generate()
    {
      cells = new Hash<Cell>();
      objects = new List<CellObject>();
      markers = new List<Marker>();

      // clean field
      for (y in 0...height)
        for (x in 0...width)
          {
            var cell = new Cell(game);
            cell.x = x;
            cell.y = y;
            cell.type = "grass";
            cells.set(x + "," + y, cell);
          }

      // terrain generator
      for (y in 0...height)
        for (x in 0...width)
          {
            var cell = get(x,y);
            if (Math.random() < 0.05)
              cell.type = "tree";
            cell.isVisible = true;

            if (cell.x == 1 + Std.int(width / 3) && Math.random() < 0.3)
              cell.type = "grass";

            cells.set(x + "," + y, cell);
          }

      generateBuildings();
      generateCreatures();
    }


// generate buildings
  function generateBuildings()
    {
      // generate temporary building array
      var bldg = new Array<Building>();
      for (y in 0...height)
        for (x in 0...width)
          {
            var cell = get(x,y);
            if (Math.random() > 0.2)
              continue;

            // size
            var sx = 2 + Std.int(Math.random() * 3);
            var sy = 2 + Std.int(Math.random() * 3);

            // make building smaller to fit map
            if (x + sx > width)
              sx = width - x;
            if (y + sy > height)
              sy = height - y;

            if (x + sx > width || y + sy > height) // out of map
              continue;

            if (sx < 2 || sy < 2) // too small
              continue;

            // check for adjacent buildings
            var ok = true;
            for (dy in -1...sy + 2)
              for (dx in -1...sx + 2)
                {
                  for (b in bldg)
                    if (x + dx > b.x && x + dx < b.x + b.w &&
                        y + dy > b.y && y + dy < b.y + b.h)
                      {
                        ok = false;
                        break;
                      }

                  if (!ok)
                    break;
                }

            if (!ok)
              continue;
              
            var rect = { x: x, y: y, w: sx, h: sy, t: null };
            bldg.push(rect);
          }

      // 
      var types = [ 'lab', 'cemetery', 'police'];
      for (t in types)
        {
          var n = 0;
          var loop = 0;
          while (loop < 100)
            {
              n = Std.int(Math.random() * bldg.length);
              if (bldg[n].t == null)
                break;
            }
          var b = bldg[n];

          b.t = t;
          if (t == 'lab')
            {
              b.w = 2;
              b.h = 2;
            }
        }


      // put buildings on map
      var cnt = 0;
      for (b in bldg)
        {
          for (dy in 0...b.h)
            for (dx in 0...b.w)
              {
                var cell = get(b.x + dx, b.y + dy);
                if (cell == null)
                  continue;
                cell.type = "building";
                cell.subtype = b.t;
              }

          if (b.t == 'lab')
            game.player.lab = b;
          else if (b.t == 'cemetery')
            cemetery = b;
          else if (b.t == 'police')
            police = b;

          cnt++;
        }



/*    
      // buildings
      var cnt = 0;
      for (y in 0...height)
        for (x in 0...width)
          {
            var cell = get(x,y);
            if (Math.random() > 0.2)
              continue;

            // size
            var sx = 2 + Std.int(Math.random() * 3);
            var sy = 2 + Std.int(Math.random() * 3);

            if (cnt == 0) // lab
              {
                sx = 2;
                sy = 2;
              }
            else if (cnt == 1) // cemetery
              {
                sx = 4;
                sy = 4;
              }
            else if (cnt == 2) // police
              {
                sx = 3;
                sy = 3;
              }

            // make building smaller to fit map
            if (x + sx > width && cnt > 1)
              sx = width - x;
            if (y + sy > height && cnt > 1)
              sy = height - y;

            if (x + sx > width || y + sy > height) // out of map
              continue;

            // check for adjacent buildings
            var ok = true;
            for (dy in -1...sy + 2)
              for (dx in -1...sx + 2)
                {
                  if (dx == 0 && dy == 0)
                    continue;
                  var cell = get(x + dx, y + dy);
                  if (cell != null && cell.type == "building")
                    {
                      ok = false;
                      break;
                    }
                }

            if (!ok)
              continue;

            // put building on map
            for (dy in 0...sy)
              for (dx in 0...sx)
                {
                  var cell = get(x + dx, y + dy);
                  if (cell == null)
                    continue;
                  cell.type = "building";

                  if (cnt == 0) // make 1st building the lab
                    cell.subtype = 'lab';

                  else if (cnt == 1) // cemetery
                    cell.subtype = 'cemetery';

                  else if (cnt == 2) // police station
                    cell.subtype = 'police';
                }
//            cells.set(x + "," + y, cell);

            var rect = { x: x, y: y, w: sx, h: sy };

            if (cnt == 0) // lab
              game.player.lab = rect;
            else if (cnt == 1) // cemetery
              cemetery = rect;
            else if (cnt == 2) // police
              police = rect;

            cnt++;
          }
*/          
    }


// generate creatures
  function generateCreatures()
    {
      var cnt = Std.int(width * height / 17);
      for (i in 0...cnt)
        {
          // find empty spot
          var x = 0, y = 0;
          while (true)
            {
              x = Std.int(Math.random() * width);
              y = Std.int(Math.random() * height);

              var cell = get(x,y);
              if (cell.type == 'building' || cell.object != null)
                continue;

              if (x >= game.player.lab.x - 2 &&
                  x <= game.player.lab.x + game.player.lab.w + 2 &&
                  y >= game.player.lab.y - 2 &&
                  y <= game.player.lab.y + game.player.lab.h + 2)
                continue;
              
              break;
            }

          var c = new Human(game, x, y);
//          objects.add(c);
//          get(x,y).object = c;

          c.aiChangeRandomDirection(); // set movement direction
        }
    }


// spawn some patients
  public function spawnPatients()
    {
      var cnt = Std.int(width * height / 120);
      for (i in 0...cnt)
        {
          if (Math.random() < 0.8)
            continue;

          // find building spot
          var x = 0, y = 0;
          while (true)
            {
              x = Std.int(Math.random() * width);
              y = Std.int(Math.random() * height);

              var cell = get(x,y);
              if (cell.type != 'building' || cell.object != null ||
                  cell.subtype != null)
                continue;
              
              break;
            }

          var o = new Patient(game, x, y);
//          objects.add(o);
//          get(x,y).object = o;
        }
    }


// spawn cemetery
  public function spawnOnCemetery()
    {
      var cnt = 2;
      for (i in 0...cnt)
        {
          if (Math.random() > 0.2)
            continue;

          // find cemetery spot
          var x = cemetery.x + Std.int(Math.random() * cemetery.w);
          var y = cemetery.y + Std.int(Math.random() * cemetery.h);

          var o = new Body(game, x, y);
          o.quality = 1; // bodies on cemetary are rarely good
          o.freshness = 2;
          if (Math.random() < 0.2)
            o.quality++;
          if (Math.random() < 0.2)
            o.freshness++;

//          objects.add(o);
//          get(x,y).object = o;
        }
    }


// helper: find empty spot in rect
  public function findEmpty(x: Int, y: Int, w: Int, h: Int): Cell
    {
      var cell = null;
      var cnt = 0;
      while (true)
        {
          cnt++; // infinite loop
          if (cnt > 200)
            return null;

          var nx = x + Std.int(Math.random() * w);
          var ny = y + Std.int(Math.random() * h);
          
          if (nx >= width || ny >= height || nx < 0 || ny < 0)
            continue;

          cell = get(nx, ny);
          if (cell.object != null || !cell.isWalkable())
            continue;

          return cell;
        }

      return null;
    }


// helper: has marker on this spot?
  public function hasMarker(x: Int, y: Int): Bool
    {
      for (m in markers)
        if (m.x == x && m.y == y)
          return true;

      return false;
    }


// helper: get marker on this spot?
  public function getMarker(x: Int, y: Int): Marker
    {
      for (m in markers)
        if (m.x == x && m.y == y)
          return m;

      return null;
    }


// helper: are there alerted people on map?
  public function hasAlerted(): Bool
    {
      for (o in objects)
        if (o.type == 'human' && o.state == 'alerted')
          return true;

      return false;
    }


// helper: are there reanimated on map?
  public function hasReanimated(): Bool
    {
      for (o in objects)
        if (o.type == 'reanimated')
          return true;

      return false;
    }


// getter for reanimated
  function getReanimated():Int
    {
      var cnt = 0;
      for (o in objects)
        if (o.type == 'reanimated')
          cnt++;
      return cnt;
    }


// paint map
  public function paint(?rect: Dynamic)
    {
      var el = untyped UI.e("map");
      var map = el.getContext("2d");
      map.font = (UI.cellSize - 3) + "px Verdana";
      map.fillStyle = "black";
      map.textBaseline = "top";
      if (rect == null)
        rect = { x: 0, y: 0, w: 1000, h: 740};
      if (rect.x < 0)
        rect.x = 0;
      if (rect.y < 0)
        rect.y = 0;
      map.fillRect(rect.x, rect.y, rect.w, rect.h);
      if (cells == null) // hack: if called before initialization
        return;

      for (y in 0...height)
        for (x in 0...width)
          {
            var cell = get(x, y);
            cell.paint(map, false,
              //(ui.cursorX == x && ui.cursorY == y), 
              rect);
          }
    }


// get amount of objects of this type
  public function getObjectCount(type: String, ?subtype: String): Int
    {
      var cnt = 0;
      for (o in objects)
        if (o.type == type && (subtype == null || o.subtype == subtype))
          cnt++;
      return cnt;
    }


  public function get(x: Int, y: Int): Cell
    {
      return cells.get(x + "," + y);
    }


  public static var dirx = [ -1, -1, -1, 0, 0, 1, 1, 1 ];
  public static var diry = [ -1, 0, 1, -1, 1, -1, 0, 1 ];
}
