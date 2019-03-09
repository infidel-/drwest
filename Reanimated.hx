// reanimated human class

class Reanimated extends Creature
{
  public var level: Int; // reanimated level

  public function new(g: Game, xv: Int, yv: Int)
    {
      super(g, xv, yv);
      type = 'reanimated';
      name = 'reanimated';
      level = 1;
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
      // aggression event - chance of attacking other reanimated
      var c = null;
      if (game.aggressionFlag)
        {
          c = aiFindAdjacentObject('reanimated', false);
          if (c != null && Std.random(100) > 50)
            c = null;
        }
      if (c == null)
        c = aiFindAdjacentObject('human', false);
      if (c != null)
        {
          map.addMessage(x, y, 'The reanimated attack' +
            (c.object.type != 'reanimated' ?
             's ' + c.object.name :
             ' each other') + '.');
          c.object.hit(this); // attack

          return;
        }

      // upgraded reanimated can devour bodies regaining life
      if (level > 1)
        {
          var c = aiFindAdjacentObject('body', true);
          if (c != null)
            {
              map.addMessage(x, y, 'The reanimated hungrily devours the body.');
              aiAlertAroundMe(); // alert people
              c.object.die();

              life = 2 + level;

              return;
            }
        }

      // aggression - can enter police station
      if (game.aggressionFlag)
        {
          // check if near station
          var b = game.map.police;
          var nearStation = false;
          for (i in 0...GameMap.dirx.length)
            {
              var cell = game.map.get(
                x + GameMap.dirx[i],
                y + GameMap.diry[i]);
              if (cell == null || cell.building != game.map.police)
                continue;

              nearStation = true;
              break;
            }

          // remove AI and add to station
          if (nearStation)
            {
              game.map.police.reanimated++;
              map.addMessage(x, y, 'The reanimated enters the police station.');

              die();
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
}
