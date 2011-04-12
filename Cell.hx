// map cell class

import Map;

class Cell
{
  public var map: Map;
  var ui: UI;
  var game: Game;

  public var x: Int;
  public var y: Int;
  public var type: String; // cell type (grass, water, etc)
  public var subtype: String; // cell subtype - for buildings
  public var building: Building; // which building this cell belongs to
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
//      if (isSelected)
//        paintSelected(screen);

      var xx = 5 + x * UI.cellSize;
      var yy = 7 + y * UI.cellSize;

      var skipBG = false;
      if (type == 'building' && (x != building.x || y != building.y))
        skipBG = true;

      var sym = 'tile_' + type;
      if (subtype != null) sym = 'tile_' + subtype;
      var w = UI.cellSize, h = UI.cellSize;

      // building images are larger than a cell
      if (type == 'building')
        {
          w = building.w * UI.cellSize;
          h = building.h * UI.cellSize;
          if (subtype != null)
            sym = 'building_' + subtype;
          else sym = 'building' + building.w + 'x' + building.h;
        }

      var img = ui.images.get(sym);
      if (img == null)
        {
          trace(sym);
          img = ui.images.get('undefined');
        }

      if (!skipBG)
        screen.drawImage(img, xx, yy, w, h);

      if (object != null) // paint object
        {
          sym = 'object_' + object.getImage();
          img = ui.images.get(sym);
          screen.drawImage(img, xx, yy, UI.cellSize, UI.cellSize);
        }

/*
      var xx = 5 + x * UI.cellSize;
      var yy = -1 + y * UI.cellSize;

      var str = type;
      var sym = '?';
      if (subtype != null) str = subtype;
      if (object != null) // object symbol
        {
          screen.fillStyle = object.getColor();
          sym = object.getSymbol();
        }
      else // terrain symbol
        {
          screen.fillStyle = Reflect.field(colors, str);
          sym = Reflect.field(symbols, str);
        }
      if (sym == "_") // hack - center "_"
        {
          xx += 4;
          yy -= 6;
        }

      // paint cell symbol
      if (isVisible)
        screen.fillText(sym, xx, yy);
*/
      paintMessage(screen, xx, yy); // paint message symbol
      if (map.hasMarker(x, y))
        paintMarker(screen, xx, yy); // paint marker symbol
    }


// paint marker symbol
  function paintMarker(screen: Dynamic, xx: Int, yy: Int)
    {
      // background
      var oldFont = screen.font;
      screen.fillStyle = "rgba(0, 0, 0, 0.7)";
      screen.font = Std.int(UI.cellSize / 1.5) + "px Verdana";
      var metrics = screen.measureText('!');
      screen.fillRect(xx + 6, yy + 6, metrics.width + 4, metrics.width * 2);

      var m = map.markers.first();
      screen.fillStyle = m.getColor();
      var sym = m.getSymbol();

      screen.fillStyle = '#ff0000';
      screen.fillText(sym, xx + 8, yy + 8);
      screen.font = oldFont;
    }



// paint message symbol
  function paintMessage(screen: Dynamic, xx: Int, yy: Int)
    {
      var msg = map.getMessage(x, y);
      if (msg == null)
        return;

      var oldFont = screen.font;
      screen.fillStyle = "rgba(0, 0, 0, 0.7)";
      screen.font = Std.int(UI.cellSize / 2) + "px Verdana";
      var metrics = screen.measureText('?');
      screen.fillRect(xx + 8, yy + 8, metrics.width + 4, metrics.width * 2);

      screen.fillStyle = (msg.isImportant ? '#ffff00' : '#aaaa00');
      var sym = (msg.isImportant ? '!' : '?');
      screen.fillText(sym, xx + 10, yy + 10);
      screen.font = oldFont;
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

//          game.checkFinish(); // check for finish
//          if (game.isFinished)
//            return;

          if (endTurn)
            game.endTurn();
          else game.map.paint();
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
      game.map.paint();//UI.getRect(x, y, 4));
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

