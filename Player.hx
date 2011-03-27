// player class

import Map;

class Player
{
  var game: Game;

  public var money: Int; // player money
  public var theory: Int; // reanimation theory
  public var suspicion: Int; // authority suspicion

  public var lab: Building; // lab building rect

  public function new(g: Game)
    {
      game = g;
      money = 0;
      theory = 1;
      suspicion = 0;
    }

  public inline function getMaxMarkers(): Int
    {
      return 1 + Std.int(theory / 3);
    }
}
