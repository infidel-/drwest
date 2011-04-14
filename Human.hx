// common human class

class Human extends Creature
{
  public var quality: Int; // body quality
  public var isHit: Bool; // was hit by reanimated flag
  var timerAlerted: Int; // alerted timer

  public function new(g: Game, xv: Int, yv: Int)
    {
      super(g, xv, yv);
      type = 'human';
      name = 'human';
      subtype = 'human';
//      life = 3;
      quality = 1;
      if (Math.random() < 0.2)
        quality++;
      if (Math.random() < 0.1)
        quality++;
      timerAlerted = 0;
    }


// AI movement
  public override function ai()
    {
      if (state == 'alerted')
        timerAlerted--;

      // calm down
      if (state == 'alerted' && timerAlerted <= 0) //!map.hasReanimated())
        state = 'idle';

      aiDefaultCreature();
    }

/*
  public override function activate(p: Player): Bool
    {
      die();
      return false;
    }
*/

// object hit by reanimated
  public override function hit(who: CellObject)
    {
      if (who.type != 'reanimated')
        return;

      life--;
      isHit = true;
      if (life > 0) // alert self if still alive
        alert(who.x, who.y);

      aiAlertAroundMe(); // alert people around

      if (life > 0)
        return;

      die(); // die and spawn a body
      game.stats.humansDead++;
      game.panic += 10;
      var o = new Body(game, x, y);
      o.quality = quality;
      o.skip = true;
    }


// human alerted
  public override function alert(ax: Int, ay: Int)
    {
      timerAlerted = 5;
      if (state == 'alerted')
        return;

      // spawn 2 cops in 2 turns
      state = 'alerted';
      map.addMessage(x, y, 'Authorities have been notified!');
      aiCallForHelp(ax, ay);
      aiCallForHelp(ax, ay);
    }


// object message
  public override function getMessage(): String
    {
      if (isQuest)
        return message;
      else if (state == 'alerted')
        return "\"Good lord, I'm so scared!\"";
      else return "";
    }


// object image
  public override function getImage(): String
    {
      if (isQuest)
        return 'human_quest';

      if (state == 'alerted')
        return 'human_alerted' + quality;

      return 'human' + quality;
    }


// object note
  public override function getNote(): String
    {
      var p3 = '';
      for (i in 0...life)
        p3 += '*';
      return name + ' (BQ ' + quality + ') ' + p3;
//        + ' ' + timerAlerted;
    }
}
