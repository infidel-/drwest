// creature class (humans, animals, reanimated, etc))

class Creature extends CellObject
{
  public var direction: Int; // direction of movement

  public function new(g: Game, xv: Int, yv: Int)
    {
      super(g, xv, yv);
      type = 'creature';
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
  public function aiFindAdjacentObject(t: String, isOutside: Bool): Cell
    {
      for (i in 0...Map.dirx.length)
        {
          var c = map.get(x + Map.dirx[i], y + Map.diry[i]);
          if (c == null || c.object == null || c.object.type != t ||
              (c.type == 'building' && isOutside))
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
  static var dirNumX = [ 0, -1, 0, 1, -1, 0, 1, -1, 0, 1 ];
  static var dirNumY = [ 0, 1, 1, 1, 0, 0, 0, -1, -1, -1 ];
  static var dirSecondary = [ [ 0, 0 ], [ 2, 4 ], [ 1, 3 ], [ 2, 6 ],
    [ 1, 7 ], [ 0, 0 ], [ 3, 9 ], [ 4, 8 ], [ 7, 9 ], [ 6, 8 ] ];
  public function aiMoveTo(xx: Int, yy: Int)
    {
      var dx = xx - x, dy = yy - y;
      if (dx < 0)
        dx = -1;
      else if (dx > 0)
        dx = 1;
      if (dy < 0)
        dy = -1;
      else if (dy > 0)
        dy = 1;

      // find dir number
      var dir = 0;
      for (i in 1...9)
        if (dx == dirNumX[i] && dy == dirNumY[i])
          {
            dir = i;
            break;
          }

      // check primary dir
      var c = map.get(x + dx, y + dy);
      if (c == null || !c.isWalkable() || c.object != null)
        {
          // secondary dir
          var dir2 = dirSecondary[dir][0];
          c = map.get(x + dirNumX[dir2], y + dirNumY[dir2]);
          if (c == null || !c.isWalkable() || c.object != null)
            {
              // tertiary dir
              var dir3 = dirSecondary[dir][1];
              c = map.get(x + dirNumX[dir3], y + dirNumY[dir3]);
              if (c == null || !c.isWalkable() || c.object != null)
                return;
              else dir = dir3;
            }
          else dir = dir2;
        }

      move(c.x, c.y);
    }


// alert people around this cell
  function aiAlertAroundMe()
    {
      // if someone was nearby, alert him and call the police
      for (yy in (y - 2)...(y + 2))
        for (xx in (x - 2)...(x + 2))
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
