// reanimated human class

class Reanimated extends Creature
{
  public var level: Int; // reanimated level

  public function new(g: Game, xv: Int, yv: Int)
    {
      super(g, xv, yv);
      type = 'reanimated';
      life = 3;
    }


// object hit by cop
  public override function hit(who: CellObject)
    {
      life--;
      if (life > 0)
        return;

      die();
      game.stats.reanimatedDestroyed++;
      map.addMessage(x, y, 'Reanimated has been put down.');
    }


// object ai
  public override function ai()
    {
      // find close humans and attack
      var c = aiFindAdjacentObject('human');
      if (c != null)
        {
          map.addMessage(x, y, 'The reanimated attacks ' + c.object.subtype + '.');
          c.object.hit(this); // attack

          return;
        }

      // upgraded reanimated can devour bodies regaining life
      if (level > 1)
        {
          var c = aiFindAdjacentObject('body');
          if (c != null)
            {
              map.addMessage(x, y, 'The reanimated hungrily devours the body.');
              aiAlertAroundMe(); // alert people
              c.object.die();

              life = 2 + level;

              return;
            }
        }

      // find close markers
      var m = aiFindRandomMarker(2);
      if (m != null)
        {
          aiMoveTo(m.x, m.y);
          return;
        }

      // move around at random
      aiDefaultCreature();
    }


// on move finish
  override function onMove()
    {
      var m = map.getMarker(x,y);
      if (m != null)
        map.markers.remove(m);
    }


// object note
  public override function getNote(): String
    {
      var p1 = (subtype == null ? type : subtype);
      var p2 = (state != 'idle' ? ' (' + state + ')' : '');
      var p3 = '';
      for (i in 0...life)
        p3 += '*';
      return p1 + ' [' + level + ']' + p2 + ' ' + p3;
    }


// object color
  public override function getColor(): String
    {
      return "brown";
    }


// object symbol
  public override function getSymbol(): String
    {
      return 'z';
    }
}
