// default quest class

package quests;


class Quest
{
  var game: Game;
  var map: Map;

  // quest parameters
  public var id: String; // all quests must have unique string ID

  public function new(g: Game)
    {
      game = g;
      map = game.map;
      id = '_dummy';
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


// ============== Overridable Interface Stuff ====================

// called on quest start
  public function start()
    {
    }


// called on quest marker activation
  public function activate(o: QuestMarker)
    {
    }
}
