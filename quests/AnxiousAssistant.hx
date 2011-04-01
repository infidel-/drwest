// Anxious Assistant quest

package quests;

class AnxiousAssistant extends Quest
{
  public function new(g: Game)
    {
      super(g);
      id = 'anxiousAssistant';
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
          o.name = 'assistant';
          o.message = 'He does not yet suspect what awaits him.';
          o.isQuest = true;
        }
    }
}
