// cop class

class Cop extends Human
{
  public function new(g: Game, xv: Int, yv: Int)
    {
      super(g, xv, yv);
      subtype = 'cop';
      life = 2;
      skip = true;

      // cops spawn alerted
      state = 'alerted';
      timerAlerted = 3;
    }


// object ai
  public override function ai()
    {
      if (state == 'alerted')
        timerAlerted--;

      // calm down
      if (state == 'alerted' && timerAlerted <= 0) //!map.hasReanimated())
        state = 'idle';

      if (state == 'idle' && Math.random() < 0.7) // remove from map
        {
          die();
          return;
        }

      // if reanimated is close, attack it
      var c = aiFindAdjacentObject('reanimated');
      if (c != null)
        {
//          ui.msg
          map.addMessage(x, y, 'Cop attacks the reanimated.');
          c.object.hit(this); // attack

          return;
        }

      // if reanimated is near, move to it
      var c = aiFindRandomObject('reanimated', 5);
      if (c != null)
        {
          // move closer to this cell
          aiMoveTo(c.x, c.y);

          return;
        }

      // patrol at random
      aiDefaultCreature();
    }


// object hit by reanimated
  public override function hit(who: CellObject)
    {
      if (who.type != 'reanimated')
        return;

      if (Math.random() < 0.6) // 60% chance to hit
        life--;
      isHit = true;
//      if (life > 0) // alert self if still alive
//        alert();
      aiAlertAroundMe(); // alert people
      aiCallForHelp(x, y); // call for help

      if (life > 0)
        return;

      die(); // die and spawn a body
      game.stats.copsDead++;
      game.panic += 15; // dead cops bad for stability
      var o = new Body(game, x, y);
      o.skip = true;
    }


// cop alerted
  public override function alert(ax: Int, ay: Int)
    {
      timerAlerted = 3;
      if (state == 'alerted')
        return;

      state = 'alerted';
    }


// object color
  public override function getColor(): String
    {
      return "blue";
    }


// object symbol
  public override function getSymbol(): String
    {
      return 'p';
    }


// object note
  public override function getNote(): String
    {
      var p3 = '';
      for (i in 0...life)
        p3 += '*';
      return 'cop (BQ ' + quality + ') ' + p3;
//        + ' ' + timerAlerted;
    }
}
