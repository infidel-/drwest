// Anxious Assistant quest

package quests;

class AnxiousAssistant extends Quest
{
  public static var isRepeatable = false;


  public function new(g: Game)
    {
      super(g);
      id = 'anxiousAssistant';
    }


// check if this quest can be spawned
  public static function check(game: Game): Bool
    {
      // player needs to have at least 1 reanimated
      if (game.map.reanimated == 0 || game.player.theory < 5)
        return false;

      // check if first lab cell is occupied
      var c = game.map.get(game.player.lab.x, game.player.lab.y);
      if (c.object != null)
        return false;

      return true;
    }


// on quest start
  public override function start()
    {
      spawnQuestMarker(game.player.lab.x, game.player.lab.y,
        'anxious assistant', '_markerStart',
        'Your assistant is behaving weird lately...');
    }


// on quest marker activation
  public override function activate(o: QuestMarker)
    {
      if (o.questTag == '_markerStart')
        {
          message("Your assistant seems to have a problem with your research. It's time to dispose of him. Lead any reanimated close to him.");
          o.die();
    
          var o = new Human(game, game.player.lab.x, game.player.lab.y);
          o.quality = 3;
          o.name = 'assistant';
          o.message = 'He does not yet suspect what awaits him.';
          o.isQuest = true;
          o.quest = this;
          o.questTag = '_assistant';
          o.ai = function() {}; // will stay in one place
        }
    }


// on each turn
  public override function tick()
    {
      // quest failed
      if (turnsPassed > 5)
        {
          message("Your assistant has become mentally unstable and had to be sent to the appropriate institution. [Suspicion +1].");
          game.player.suspicion++;
          finish();
          return;
        }

      // check if quest marker is alive
      var o = map.getQuestObject(this, '_markerStart');
      if (o != null)
        return;

      // check if assistant is alive
      var o = map.getQuestObject(this, '_assistant');
      if (o != null)
        return;

      message("You have managed to obtain a very fresh specimen...");
      finish();
    }
}
