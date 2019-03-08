// map class

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

import quests.Quest;


// map building
typedef Building =
{
  var x: Int;
  var y: Int;
  var w: Int;
  var h: Int;
  var t: String; // building type
  var name: String;

  var reanimated: Int; // police only - reanimated in building
};


// map message
typedef Message =
{
  var x: Int;
  var y: Int;
  var text: String; // message text
  var isImportant: Bool; // is message important?
}


class GameMap
{
  var ui: UI;
  var game: Game;

  var cells: Map<String, Cell>;
  public var objects: List<CellObject>; // game objects
  public var markers: List<Marker>; // reanimated markers
  public var messages: Map<String,Message>; // game messages
  public var buildings: Array<Building>; // buildings list
  public var cemetery: Building;
  public var police: Building;
  public var copsTotal: Int; // total cops alive on that map
  public var width: Int;
  public var height: Int;
  public var reanimated(get_reanimated, null): Int;

  public function new(g: Game)
    {
      game = g;
      ui = game.ui;
      width = UI.mapWidth;
      height = UI.mapHeight;
    }


// add a message to map
  public function addMessage(x: Int, y: Int, text: String, ?params: { ?isImportant: Bool })
    {
      if (params == null)
        params = {};
      if (params.isImportant == null)
        params.isImportant = false;
      var m: Message =
        {
          x: x,
          y: y,
          text: text,
          isImportant: params.isImportant };
      messages.set("" + x + "," + y, m);
    }


// remove a message from map
  public function removeMessage(x: Int, y: Int)
    {
      messages.remove("" + x + "," + y);
    }


// get a message on this cell
  public function getMessage(x: Int, y: Int): Message
    {
      return messages.get("" + x + "," + y);
    }


// clear messages
  public function clearMessages()
    {
      for (m in messages.keys())
        messages.remove(m);
    }

// generate map
  public function generate()
    {
      cells = new Map();
      objects = new List<CellObject>();
      markers = new List<Marker>();
      messages = new Map();
      buildings = new Array<Building>();
      copsTotal = Std.int(width * height / 22 + Math.random() * 10);

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

/*
      // DEBUG
      var q = new quests.NosyReporter(game);
      game.quests.add(q);
      q.start();
*/      
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
              
            var b = {
              x: x,
              y: y,
              w: sx,
              h: sy,
              t: null,
              name: null,
              reanimated: 0,
            };
            bldg.push(b);
          }

      // find position for special buildings 
      var types = [ 'lab', 'cemetery', 'police'];
      for (t in types)
        {
          var n = 0;
          var loop = 0;
          while (loop < 100)
            {
              n = Std.int(Math.random() * bldg.length);

              // specials need to change building size
              if (bldg[n].w < 3 || bldg[n].h < 3)
                continue;
             
              // lab must be near the edge (for easier gameplay)
              if (t == 'lab' && bldg[n].x >= 2 && bldg[n].y >= 2 &&
                  bldg[n].x + bldg[n].w <= width - 2 &&
                  bldg[n].y + bldg[n].h <= height - 2)
                continue;

              if (bldg[n].t == null)
                break;
            }
          var b = bldg[n];

          b.t = t;
          if (t == 'lab')
            {
              b.w = 2;
              b.h = 2;
              b.name = 'laboratory';
            }
          else if (t == 'police')
            {
              b.w = 3;
              b.h = 3;
              b.name = 'police station';
            }
          else if (t == 'cemetery')
            {
              b.w = 3;
              b.h = 2;
              b.name = 'cemetery';
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
                cell.building = b;
              }

          if (b.t == 'lab')
            game.player.lab = b;
          else if (b.t == 'cemetery')
            cemetery = b;
          else if (b.t == 'police')
            police = b;

          cnt++;
        }

      buildings = bldg;
    }


// generate creatures
  function generateCreatures()
    {
      var cnt = Std.int(width * height / 18);
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
        }
    }


// spawn bodies on cemetery
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


// helper: get quest object
  public function getQuestObject(q: Quest, tag: String): CellObject
    {
      for (o in objects)
        if (o.quest == q && o.questTag == tag)
          return o;

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
  function get_reanimated():Int
    {
      var cnt = 0;
      for (o in objects)
        if (o.type == 'reanimated')
          cnt++;
      return cnt;
    }


// paint map
  public function paint(?rect = null)
    {
      var el: CanvasElement = cast UI.e("map");
      var map = el.getContext2d();
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

      paintPolice(map); // police stats
    }


// paint police stuff
  function paintPolice(map: CanvasRenderingContext2D)
    {
      // X/Y police officers text
      map.font = Std.int(UI.cellSize / 2) + "px Verdana";
      var text = (copsTotal - game.stats.copsDead) + " / " + copsTotal;
      var metrics = map.measureText(text);
      var xx = 
        UI.cellSize * police.x + (UI.cellSize * police.w - metrics.width) / 2;
      var yy = UI.cellSize * police.y + 50;

      // bg
      map.fillStyle = "rgba(0, 0, 0, 0.7)";
      var m2 = map.measureText('?');
      map.fillRect(xx - 4, yy - 8, metrics.width + 8, m2.width * 2 + 8);

      // text
      map.fillStyle = "white";
      map.fillText(text, xx, yy);

      // X reanimated text
      if (game.map.police.reanimated > 0)
        {
          map.fillStyle = '#ff3333';
          map.fillText('' + game.map.police.reanimated, xx, yy + 30);
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
