// Nosy Reporter quest

package quests;

class NosyReporter extends Quest
{
  public static var isRepeatable = false;


  public function new(g: Game)
    {
      super(g);
      id = 'nosyReporter';
    }


// check if this quest can be spawned
  public static function check(game: Game): Bool
    {
      // player needs to have at least 1 reanimated
      if (game.map.reanimated == 0)
        return false;

      return true;
    }


// on quest start
  public override function start()
    {
      var c = game.map.findEmpty(game.player.lab.x - 3,
        game.player.lab.y - 3,
        game.player.lab.w + 6, game.player.lab.h + 6);
      spawnQuestMarker(c.x, c.y,
        'nosy reporter', '_markerStart',
        'A reporter is snooping around your laboratory...');
    }


// on quest marker activation
  public override function activate(o: QuestMarker)
    {
      if (o.questTag == '_markerStart')
        {
          message("A nosy reporter from out of town walks around the laboratory asking questions. You need to deal with this risk of exposure.");
          o.die();
    
          var c = game.map.findEmpty(game.player.lab.x - 3,
            game.player.lab.y - 3,
            game.player.lab.w + 6, game.player.lab.h + 6);
          var o = new Human(game, c.x, c.y);
          o.quality = 3;
          o.name = 'reporter';
          o.message = '"I need to find a scoop in this lousy town."';
          o.isQuest = true;
          o.quest = this;
          o.questTag = '_reporter';
        }
    }


// on each turn
  public override function tick()
    {
      // quest failed
      if (turnsPassed > 10)
        {
          message("The reporter has been able to dig up some revealing information about your research drawing unwanted attention. [Suspicion +1].");
          game.player.suspicion++;
          finish();
          return;
        }

      // check if quest marker is alive
      var o = map.getQuestObject(this, '_markerStart');
      if (o != null)
        return;

      // check if reporter is alive
      var o = map.getQuestObject(this, '_reporter');
      if (o != null)
        return;

      message("This reporter won't bother you again.");
      finish();
    }
}
