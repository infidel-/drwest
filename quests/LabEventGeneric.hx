// laboratory events packed into a quest

package quests;

class LabEventGeneric extends Quest
{
  public static var isRepeatable = true;


  public function new(g: Game)
    {
      super(g);
      id = 'labEvent';
    }


// check if this quest can be spawned
  public static function check(game: Game): Bool
    {
      // player needs to have at least 2 theory
      if (game.player.theory < 2)
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
        'laboratory event', '_markerStart',
        'There is something happening in the laboratory...');
    }


// on quest marker activation
  public override function activate(o: QuestMarker)
    {
      if (o.questTag != '_markerStart')
        return;

      var rnd = Std.random(100);
      var rnd2 = Std.random(100);
      var cnt = 7; // to split probability equally between different events
      var avg = 100.0 / cnt;
      var chance = 15;

      // faulty equipment
      if (rnd < avg)
        {
          message("It seems some of your equipment is faulty... " +
            (rnd2 < chance ?
              "and it's broken in the middle of an experiment delaying your research! [Theory -1]" :
              "but you manage to stop the experiment just in time."));
          if (rnd2 < chance)
            game.player.theory -= 1;
        }

      // new equipment received
      else if (rnd < avg * 2)
        {
          message("Equipment ordered earlier is finally delivered to your laboratory... " +
            (rnd2 < chance ?
              "and it gives a huge bonus to your research! [Theory +1]" :
              "but it falls short of your expectations."));
          if (rnd2 < chance)
            game.player.theory += 1;
        }

      // spilled chemicals
      else if (rnd < avg * 3)
        {
          message("Your assistant mixes up dangerously explosive chemicals used in research... " +
            (rnd2 < chance ?
              "and it produces a loud explosion alerting the neighbours! [Suspicion +1]" :
              "but fortunately nobody is around at this time."));
          if (rnd2 < chance)
            game.player.suspicion += 1;
        }

      // experimental chemicals received
      else if (rnd < avg * 4)
        {
          message("Experimental chemicals ordered by mail finally make it to your laboratory... " +
            (rnd2 < chance ?
              "and they give a huge bonus to your research! [Theory +1]" :
              "but they fall short of your expectations."));
          if (rnd2 < chance)
            game.player.theory += 1;
        }

      // explaining theory to the assistant
      else if (rnd < avg * 5)
        {
          message("Chatting with your assistant you find yourself in the mood for a lecture... " +
            (rnd2 < chance ?
              "and after an hour of discussing your theory you feel new ideas forming in your brain! [Theory +1]" :
              "but even after repeating yourself over and over he fails to grasp your theory."));
          if (rnd2 < chance)
            game.player.theory += 1;
        }

      // medicine journal
      else if (rnd < avg * 6)
        {
          message("Reading the fresh medicine journal... " +
            (rnd2 < chance ?
              "you feel new ideas forming in your brain! [Theory +1]" :
              "you find nothing of interest."));
          if (rnd2 < chance)
            game.player.theory += 1;
        }

      // strange letter
      else if (rnd < avg * 7)
        {
          message("Browsing through the mail... " +
            (rnd2 < chance ?
              "you find a strange letter from a person you don't know discussing your research with a high degree of knowledge." :
              "you find nothing of interest."));
          if (rnd2 < chance)
            game.questVariables.set('strangeLetterReceived', 1);
        }

      o.die();
      finish();
    }


// quest tick
  public override function tick()
    {
      if (turnsPassed > 1)
        finish();
    }
}
