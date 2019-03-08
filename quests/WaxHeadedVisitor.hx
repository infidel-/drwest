// Wax-Headed Visitor quest

package quests;

class WaxHeadedVisitor extends Quest
{
  public static var isRepeatable = false;


  public function new(g: Game)
    {
      super(g);
      id = 'waxHeadedVisitor';
    }


// check if this quest can be spawned
  public static function check(game: Game): Bool
    {
      // player needs to have some knowlege
      if (game.player.theory < 2)
        return false;

      return true;
    }


// on quest start
  public override function start()
    {
      var c = game.map.findEmpty(game.player.lab.x - 1,
        game.player.lab.y - 1,
        game.player.lab.w + 2, game.player.lab.h + 2);
      if (c == null)
        return;

      spawnQuestMarker(c.x, c.y,
        'wax-headed visitor', '_markerStart',
        'There is a wax-headed visitor near the laboratory...');
    }


// on quest marker activation
  public override function activate(o: QuestMarker)
    {
      if (o.questTag == '_markerStart')
        {
          message("The wax-headed visitor praises your work, offers you a peculiar device describing it as a boon in your research and leaves.");
          o.die();
    
          spawnQuestMarker(o.x, o.y, 'whirring device', '_object',
            'A whirring cylindrical device.');
        }

      else if (o.questTag == '_object')
        {
          message("You bring the whirring device to your laboratory. It's time to get to work. [+ Aggression Effect]");
          game.aggressionFlag = true;
          o.die();
          finish();
        }
    }


// on each turn
  public override function tick()
    {
      // quest failed
      if (turnsPassed >= 3)
        {
          var o = map.getQuestObject(this, '_markerStart');
          if (o != null)
            message("You decide to ignore the visitor.");
          else
            {
              o = map.getQuestObject(this, '_object');
              if (o != null)
                message("You decide to ignore the visitor's gift.");
            }
          o.die();
          finish();
          return;
        }
    }
}
