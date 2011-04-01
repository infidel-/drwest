// default quest class

package quests;


class Quest
{
  var game: Game;
  var map: Map;

  // quest parameters
  public var id: String; // all quests must have unique string ID
  public var turnsPassed: Int; // turns passed from quest start (auto counter)
  public static var isRepeatable: Bool = false; // is this quest repeatable?

  public function new(g: Game)
    {
      game = g;
      map = game.map;
      id = '_dummy';
      turnsPassed = 0;
    }


// spawn quest marker
  inline function spawnQuestMarker(x: Int, y: Int, name: String, tag: String,
      message: String)
    {
      var o = new QuestMarker(game, game.player.lab.x, game.player.lab.y,
        this);
      o.name = name;
      o.message = message;
      o.questTag = tag;
    }


// show a dialog with message
  inline function message(str: String)
    {
      game.ui.alert(str);
    }


// finish this quest
  function finish()
    {
      // remove all quest objects for this quest
      for (o in map.objects)
        if (o.quest == this)
          o.die();

      // remove from active quests list
      game.quests.remove(this);
    }


// ============== Overridable Interface Stuff ====================


// !!! HAS TO BE OVERRIDDEN IN ALL QUESTS !!! - check if this quest can be spawned
// returns true on success
  public static function check(game: Game): Bool
    {
      return false;
    }


// called on quest start
  public function start()
    {
    }


// called on quest marker activation
  public function activate(o: QuestMarker)
    {
    }


// called each turn after quest start
  public function tick()
    {
    }
}
