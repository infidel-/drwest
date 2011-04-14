// patient

class Patient extends CellObject
{
  var isSick: Bool; // is patient very sick? (will die if not treated)

  public function new(g: Game, xv: Int, yv: Int)
    {
      super(g, xv, yv);
      type = 'patient';
    }


// patient ai - die after some time
  public override function ai()
    {
      if (!isSick && turns >= 2) // normal patient
        {
          if (Math.random() < 0.7) // heals himself
            die();
          else // becomes very sick
            {
              isSick = true;
              turns = 0; // start over
            }
        }

      else if (isSick && turns >= 2) // sick patient
        {
          die();
          var o = new Body(game, x, y);
          o.skip = true;
        }
    }


// object activation
  public override function activate(player: Player): Bool
    {
      die();
      player.money++;
      ui.msg('Grateful patient gives you money for the treatment.');
      return true;
    }


// object note
  public override function getNote(): String
    {
      return (isSick ? 'sick patient' : type);
    }
}
