// game class

import quests.Quest;

typedef GameStats =
{
  var humansDead: Int;
  var copsDead: Int;
  var bodiesTested: Int;
  var bodiesReanimated: Int;
  var reanimatedDestroyed: Int;
}


class Game
{
  public var ui: UI;
  public var map: GameMap;
  public var turns: Int;
  public var isFinished: Bool;
  public var player: Player;
  public var stats: GameStats;
  public var quests: List<Quest>; // currently active quests
  public var questsCompleted: List<Dynamic>; // quests completed/failed
  public var questVariables: Map<String, Int>; // global quest variables storage

  public var panic: Int; // town panic meter
  public var isPanic: Bool; // is town in panic?

  var tasks: List<Task>; // tasks queue

  public function new()
    {
      ui = new UI(this);
      map = new GameMap(this);
      tasks = new List<Task>();
     
      var hasPlayed = ui.getVar('hasPlayed');
      if (hasPlayed == null)
        ui.alert("Welcome, Dr. West.<br><br>" +
          "If this is your first time playing, please take the time to read the " +
          "<a target=_blank href='http://code.google.com/p/drwest/wiki/Manual'>Manual</a> before playing.");
      ui.setVar('hasPlayed', '1');

      restart();
    } 


// queue a task into timer
  public function queue(type: String, params: Dynamic, turns: Int)
    {
      var t: Task = { type: type, params: params, turns: turns };
      tasks.add(t);
    }


// end turn
  public function endTurn()
    {
      if (isFinished)
        return;

      map.clearMessages(); // clear old messages
      taskHandler(); // handle queued tasks

      ui.tip('');
      for (q in quests) // quests tick
        {
          q.turnsPassed++;
          q.tick();
        }

      for (o in map.objects) // objects ai
        {
          o.turns++;
          if (!o.skip)
            o.ai();
          else o.skip = false;
        }

      map.paint();
      ui.paintStatus();
      checkFinish();
      if (isFinished)
        return;

      handlePanic(); // handle town panic meter

      // spawn objects
//      map.spawnPatients();
      map.spawnOnCemetery();
      spawnQuests();

      turns++;
      map.paint();
      ui.paintStatus();
    }


// spawn quests
  public function spawnQuests()
    {
      // check probability
      var prob = 0.05;
      if (quests.length > 0)
        prob = 0.025;
      var rnd = Math.random();
      if (rnd > prob)
        return;

      // spawn a quest
      for (cl in Game.possibleQuests)
        {
          // check if this quest is already active
          var ok = true;
          for (qqq in quests)
            if (Type.getClassName(Type.getClass(qqq)) == Type.getClassName(cl))
              {
                ok = false;
                break;
              }
          if (!ok)
            continue;

          // check if this quest is already done
          var ok = true;
          if (!cl.isRepeatable)
            {
              for (qqcl in questsCompleted)
                if (Type.getClassName(cl) == Type.getClassName(qqcl))
                  {
                    ok = false;
                    break;
                  }

              if (!ok)
                continue;
            }
    
          // check for quest start conditions
          var ok: Bool = Reflect.callMethod(cl, Reflect.field(cl, "check"), [ this ]);
          if (!ok)
            continue;

          var q = Type.createInstance(cl, [ this ]);
          quests.add(q);
          q.start();

          questsCompleted.add(cl);
          return; // one quest at a time
        }
    }


// raise or lower panic meter
  function handlePanic()
    {
      // town becomes panicked
      var cnt = map.getObjectCount('human', 'human');
      var max = Std.int(map.width * map.height / 18);
      if (cnt < max * 0.35)
        {
//          trace('panic ' + cnt + ' ' + (max * 0.3) + ' ' + isPanic);
          if (!isPanic)
            ui.alert("The town is in panic! The authorities order the police to be on constant patrol.");
          isPanic = true;
        }

      if (!isPanic)
        return;

      for (i in 0...4)
        {
          var c = map.findEmpty(map.police.x - 2, map.police.y - 2,
            map.police.w + 4, map.police.h + 4); 
          queue('spawn.cop', { x: c.x, y: c.y }, 1);
        }

/*
      // rot panic
      if (!map.hasReanimated() && panic > 0)
        {
          panic -= 5;
          if (panic < 0)
            panic = 0;
        }

      if (map.hasReanimated() && map.hasAlerted())
        {
          panic += map.reanimated;
        }
*/        
    }


// handle queued tasks
  function taskHandler()
    {
      for (t in tasks)
        {
          t.turns--;
          if (t.turns > 0)
            continue;

          // spawn a cop near x,y
          var copCount = map.getObjectCount('human', 'cop');
          if (t.type == 'spawn.cop' && copCount < 10 &&
              map.copsTotal - stats.copsDead - copCount > 0)
            {
              var cell = map.findEmpty(untyped t.params.x - 1,
                untyped t.params.y - 1, 2, 2);
              if (cell != null)
                {
                  var o = new Cop(this, cell.x, cell.y);
                  ui.msg('Authorities arrive on the scene.');
                }
            }

          tasks.remove(t);
        }
    }


// main function
  static var instance: Game;
  static function main()
    {
      instance = new Game();
    }


// finish the game
  public function finish(isVictory: Bool, reason: String)
    {
      isFinished = true;
      ui.track((isVictory ? "winGame" : "loseGame"),
        reason, turns);
      ui.finish(isVictory, reason);
    }


// check for victory
  public function checkFinish()
    {
      // all cops dead, win
      if (stats.copsDead >= map.copsTotal)
        {
          finish(true, 'police');
          return;
        }

      // theory raised, win
      else if (player.theory >= 10)
        {
          finish(true, 'theory');
          return;
        }

      // cops are around lab, lose
      for (y in player.lab.y - 1...player.lab.y + player.lab.h + 1)
        for (x in player.lab.x - 1...player.lab.x + player.lab.w + 1)
          {
            var c = map.get(x, y);
            if (c == null || c.object == null ||
                c.object.type != 'human' ||
                c.object.subtype != 'cop')
              continue;

            player.suspicion++;
          }

      if (player.suspicion >= 3)
        {
          player.suspicion = 3;
          ui.paintStatus();
          finish(false, 'suspicion');
        }
    }


// restart game
  public function restart()
    {
      ui.track("startGame");
      tasks.clear();
      stats = 
        {
          humansDead: 0,
          copsDead: 0,
          bodiesTested: 0,
          bodiesReanimated: 0,
          reanimatedDestroyed: 0
        };
      isFinished = false;
      turns = 0;
      panic = 0;
      isPanic = false;
      player = new Player(this);
      quests = new List<Quest>();
      questsCompleted = new List<Dynamic>();
      questVariables = new Map<String, Int>();
      map.generate();
      map.paint();
      ui.paintStatus();
    }


  public static var version = "v3"; // game version
  public static var possibleQuests: Array<Dynamic> =
    [ quests.AnxiousAssistant, quests.NosyReporter, quests.LabEventGeneric ];
}


// task typedef

typedef Task =
{
  var type: String; // task type
  var params: Dynamic; // task params
  var turns: Int; // turns until activation
};
