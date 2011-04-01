// game class


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
  public var map: Map;
  public var turns: Int;
  public var isFinished: Bool;
  public var player: Player;
  public var stats: GameStats;

  public var panic: Int; // town panic meter

  var tasks: List<Task>; // tasks queue

  public function new()
    {
      ui = new UI(this);
      map = new Map(this);
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

      turns++;
      map.paint();
      ui.paintStatus();
    }


// raise or lower panic meter
  function handlePanic()
    {
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
          if (t.type == 'spawn.cop' && map.getObjectCount('human', 'cop') < 10)
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
  public function finish(isVictory: Bool)
    {
      isFinished = true;
      ui.track((isVictory ? "winGame" : "loseGame"),
        "", turns);
      ui.finish(isVictory);
    }


// check for victory
  public function checkFinish()
    {
      // theory raised, win
      if (player.theory >= 10)
        {
          finish(true);
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
           
            if (player.suspicion >= 3)
              {
                ui.paintStatus();
                finish(false);
              }
            return;
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
      player = new Player(this);
      map.generate();
      map.paint();
      ui.paintStatus();
    }


  public static var version = "v2"; // game version
}


// task typedef

typedef Task =
{
  var type: String; // task type
  var params: Dynamic; // task params
  var turns: Int; // turns until activation
};
