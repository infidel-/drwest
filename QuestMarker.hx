// quest marker object class

class QuestMarker extends CellObject
{
  public function new(g: Game, xv: Int, yv: Int, q: quests.Quest)
    {
      super(g, xv, yv);
      type = 'quest';
      subtype = 'quest';
      isQuest = true;
      quest = q;
    }


// on activation
  public override function activate(p: Player): Bool
    {
      quest.activate(this);
      return false;
    }


// object note
  public override function getNote(): String
    {
      return name;
    }
}
