// map cell class

class Cell
{
  public var map: Map;
  var ui: UI;
  var game: Game;

  public var x: Int;
  public var y: Int;
  public var type: String; // cell type (grass, water, etc)
  public var subtype: String; // cell subtype - for buildings
  public var isVisible: Bool; // cell visible to player?
  public var object: CellObject; // cell object


  public function new(g: Game)
    {
      game = g;
      map = game.map;
      ui = game.ui;
    }


  public static var colors: Dynamic =
    {
      grass: "green",
      building: "gray",
      swamp: "#339999",
      water: "blue",
      tree: "darkgreen",
      lab: "cyan",
      cemetery: "#555500",
      police: "blue",
    };

  public static var symbols: Dynamic =
    {
      grass: ".",
      building: "#",
      swamp: ".",
      water: "~",
      tree: "*",
      lab: "#",
      cemetery: "#",
      police: "#",
    };

  static var walkable: Dynamic =
    {
      grass: true,
      building: false,
      swamp: true,
      water: false,
      tree: false,
    };


  static var dx: Array<Int> = [ 1, -1, 0, 0, 1, -1, 1, -1 ];
  static var dy: Array<Int> = [ 0, 0, 1, -1, 1, -1, -1, 1 ];


// paint cell
  public function paint(screen: Dynamic, isSelected: Bool, rect: Dynamic)
    {
      var x1 = 3 + x * UI.cellSize;
      var x2 = 3 + x * UI.cellSize + UI.cellSize;
      var y1 = 2 + y * UI.cellSize;
      var y2 = 2 + y * UI.cellSize + UI.cellSize;
      if (!(x1 >= rect.x && x1 < rect.x + rect.w &&
            y1 >= rect.y && y1 < rect.y + rect.h) &&
          !(x2 > rect.x && x2 <= rect.x + rect.w &&
            y2 > rect.y && y2 <= rect.y + rect.h))
        return;

      // paint selected
      if (isSelected)
        paintSelected(screen);

      var xx = 5 + x * UI.cellSize;
      var yy = -1 + y * UI.cellSize;

      var str = type;
      var sym = '?';
      if (subtype != null) str = subtype;
      if (object != null)
        {
          screen.fillStyle = object.getColor();
          sym = object.getSymbol();
        }
      else if (map.hasMarker(x, y))
        {
          var m = map.markers.first();
          screen.fillStyle = m.getColor();
          sym = m.getSymbol();
        }
      else
        {
          screen.fillStyle = Reflect.field(colors, str);
          sym = Reflect.field(symbols, str);
        }
      if (sym == "_") // hack - center "_"
        {
          xx += 4;
          yy -= 6;
        }
      if (isVisible)
        screen.fillText(sym, xx, yy);
    }


// helper, paint selected cell
  function paintSelected(screen)
    {
      if (game.isFinished)
        return;

      screen.fillStyle = "#333333";

      screen.fillRect(3 + x * UI.cellSize, 2 + y * UI.cellSize,
        UI.cellSize, UI.cellSize);
    }


// find distance from this cell to another
  public function distance(c: Cell): Int
    {
      var dx = x - c.x;
      var dy = y - c.y;
      return Std.int(Math.sqrt(dx * dx + dy * dy));
    }


// activate a cell
  public function activate()
    {
/*    
      // DEBUG
      if (object == null && type == 'grass')
        {
          var o = new Reanimated(game, x, y);
        }
*/
      // remove marker
      if (map.hasMarker(x,y))
        {
          var m = map.getMarker(x,y);
          map.markers.remove(m);
        }

      // activate object
      else if (object != null)
        {
          var endTurn = object.activate(game.player);

          game.checkFinish(); // check for finish
          if (game.isFinished)
            return;

          if (endTurn)
            game.endTurn();
        }

      // create marker
      else if (isWalkable() &&
               map.markers.length < game.player.getMaxMarkers() &&
          !map.hasMarker(x,y))
        {
          var o = new Marker(game, x, y);
          map.markers.add(o);
        }
      else return;

      // repaint map around
      game.map.paint(UI.getRect(x, y, 1));
    }


// has adjacent visible cells?
  public function hasAdjacentVisible()
    {
      for (i in 0...4)
        {
          var c = map.get(x + dx[i], y + dy[i]);
          if (c == null || !c.isVisible)
            continue;

          return true;
        }
      return false;
    }


// is cell walkable?
  public function isWalkable(): Bool
    {
      if (object != null)
        return false;
      return Reflect.field(walkable, type);
    }


// has adjacent walkable (and visible) cells?
  public function hasAdjacentWalkable()
    {
      for (i in 0...8)
        {
          var c = map.get(x + dx[i], y + dy[i]);
          if (c == null || !c.isWalkable() || !c.isVisible)
            continue;

          return true;
        }
      return false;
    }


// repaint only this cell
  public inline function repaint()
    {
      game.map.paint(UI.getRect(x, y, 0));
    }


// get cell description
  public function getNote(): String
    {
      var s = "";
      if (object != null)
        s = object.getNote();
      else if (subtype != null)
        s = subtype;
      else s = type;

      return s;
    }
}

