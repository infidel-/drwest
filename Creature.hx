// creature class (humans, animals, reanimated, etc))

class Creature extends CellObject
{
  public var direction: Int; // direction of movement

  public function new(g: Game, xv: Int, yv: Int)
    {
      super(g, xv, yv);
      type = 'creature';
    }


// object color
  public override function getColor(): String
    {
      return 'gray';
    }


// object symbol
  public override function getSymbol(): String
    {
      return '?';
    }


// AI movement
  public override function ai()
    {
      aiDefaultCreature();
    }


// default creature AI
  public function aiDefaultCreature()
    {
      if (Math.random() < 0.2)
        aiChangeRandomDirection();

      var c = map.get(x + Map.dirx[direction],
        y + Map.diry[direction]);
      if (c == null || !c.isWalkable())
        {
          aiChangeRandomDirection();
          return;
        }
      else move(x + Map.dirx[direction],
        y + Map.diry[direction]);
    }


// change direction at random to the empty space
  public function aiChangeRandomDirection()
    {
      var cnt = 0;
      while (true)
        {
          var dir = Std.int(Math.random() * Map.dirx.length);
          var c = map.get(x + Map.dirx[dir], y + Map.diry[dir]);

          cnt++; // break infinite loop
          if (cnt > 50)
            break;
          
          if (c == null || !c.isWalkable())
            continue;

          direction = dir;
          break;
        }
    }


// find random adjacent object of this type
  public function aiFindAdjacentObject(t: String): Cell
    {
      for (i in 0...Map.dirx.length)
        {
          var c = map.get(x + Map.dirx[i], y + Map.diry[i]);
          if (c == null || c.object == null || c.object.type != t ||
              c.type == 'building')
            continue;

          return c;
        }

      return null;
    }


// find random object of this type in this radius
  public function aiFindRandomObject(t: String, radius: Int): Cell
    {
      for (yy in -radius...radius)
        for (xx in -radius...radius)
          {
            var c = map.get(x + xx, y + yy);
            if (c == null || c.object == null || c.object.type != t)
              continue;

            return c;
          }
      return null;
    }


// find random marker in this radius
  public function aiFindRandomMarker(radius: Int): Marker
    {
      for (m in map.markers)
        if (m.x >= x - radius && m.x <= x + radius &&
            m.y >= y - radius && m.y <= y + radius)
          return m;
      return null;
    }


// try to move to this cell (possibly generating path in the future)
  public function aiMoveTo(xx: Int, yy: Int)
    {
      var dx = xx - x, dy = yy - y;
      if (dx < 0)
        dx = - 1;
      else if (dx > 0)
        dx = 1;
      if (dy < 0)
        dy = - 1;
      else if (dy > 0)
        dy = 1;

      var c = map.get(x + dx, y + dy);
      if (c == null || !c.isWalkable() || c.object != null)
        return;
//      trace(x + ',' + y + ' -> ' + c.x + ',' + c.y);

      move(x + dx, y + dy);
    }


// alert people around this cell
  function aiAlertAroundMe()
    {
      // if someone was nearby, alert him and call the police
      for (yy in (y - 3)...(y + 3))
        for (xx in (x - 3)...(x + 3))
          {
            var c = map.get(xx, yy);
            if (c == null || c.object == null ||
                c.object.type != 'human' || c.object == this)
              continue;

            var o: Human = untyped c.object;
            o.alert(x, y);
            game.panic++; // each alerted human raises panic
          }

    }


// call for backup/help
  function aiCallForHelp(ax: Int, ay: Int)
    {
      // max 10 cops on map
      if (map.getObjectCount('human', 'cop') >= 10)
        return;

      game.queue('spawn.cop', { x: ax, y: ay }, 2);
    }

}
