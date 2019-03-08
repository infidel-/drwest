// cell object class

class CellObject
{
  public var map: GameMap;
  var ui: UI;
  var game: Game;

  public var x: Int;
  public var y: Int;
  public var type: String; // object type (body, etc)
  public var subtype: String; // object subtype (cop, etc)
  public var name: String; // name in case of named object
  public var turns: Int; // how many turns this object lives
  public var life: Int; // object life (humans, etc)
  public var skip: Bool; // skip next ai() call
  public var state: String; // object state
  public var message: String; // object message (for message bar)

  // quest-related stuff
  public var isQuest: Bool; // is quest object? (changes behaviour)
  public var quest: quests.Quest; // related quest
  public var questTag: String; // quest tag in that quest

  public function new(g: Game, xv: Int, yv: Int, ?dontAdd: Bool)
    {
      game = g;
      x = xv;
      y = yv;
      map = game.map;
      ui = game.ui;
      turns = 0;
      skip = false;
      life = 1;
      state = 'idle';
      subtype = null;
      isQuest = false;
      message = '';

      if (dontAdd == null || dontAdd == false)
        {
          map.objects.add(this);
          map.get(x,y).object = this;
        }
    }


// object hit by another object
  public function hit(o: CellObject)
    {
    }


// object alerted by something at this location
  public function alert(ax: Int, ay: Int)
    {
    }


// object death - removed from list
  public function die()
    {
      map.objects.remove(this);
      map.get(x,y).object = null;
    }


// move object to another cell 
// -- no checking for another object there
  public function move(nx: Int, ny: Int)
    {
      map.get(x,y).object = null;
      x = nx;
      y = ny;
      map.get(x,y).object = this;
      onMove(); // on move finish callback
    }


// on move finish callback
  function onMove()
    {}


// object activation
// -- returns true if turn ended
  public dynamic function activate(p: Player): Bool
    {
      return false;
    }


// object note
  public function getNote(): String
    {
      var p1 = (subtype == null ? type : subtype);
      var p2 = (state != 'idle' ? ' (' + state + ')' : '');
      var p3 = '';
      for (i in 0...life)
        p3 += '*';
      return p1 + p2 + ' ' + p3;
    }


// object message
  public function getMessage(): String
    {
      return message;
    }


// object symbol
  public function getImage(): String
    {
      return type;
    }


// object ai
  public dynamic function ai()
    {}
}
