// javascript ui class

import js.Browser;
import js.html.Image;
import js.html.KeyboardEvent;
import js.html.Element;
import js.html.CanvasElement;

class UI
{
  var game: Game;

  var alertWindow: Element; // alert window element
  var alertText: Element; // alert text element
  public var cursorX: Int; // cursor x,y in map coordinates
  public var cursorY: Int;
  public var prevX: Int; // previous mouse coordinates
  public var prevY: Int;
  public var images: Map<String, Image>; // images array

  public var justClicked: Bool; // hack: skip first mouse move after click
  public var msgLocked: Bool; // is msg panel locked until mouse click?

  public function new(g: Game)
    {
      game = g;
      Browser.document.onkeydown = onKey;

      e("version").innerHTML = Game.version;
      e("map").onclick = onMapClick;
      e("map").onmousemove = onMapMove;
      e("restart").onclick = onRestart;
      e('restart').onmouseenter = tooltip.bind('Restart');
      e('restart').onmouseleave = clearMessage;
      e("endTurn").onclick = onEndTurn;
      e('endTurn').onmouseenter = tooltip.bind('EndTurn');
      e('endTurn').onmouseleave = clearMessage;
      msgLocked = false;

      // check if canvas is available
      var map = e("map");
      if (!(untyped map).getContext)
        Browser.window.alert("No canvas available. Please use a canvas-compatible browser like Mozilla Firefox 3.5+ or Google Chrome.");

      // alert window
      alertWindow = Browser.document.createElement("alertWindow");
      alertWindow.style.visibility = 'hidden';
      alertWindow.style.position = 'absolute';
      alertWindow.style.zIndex = '20';
      alertWindow.style.width = '600px';
      alertWindow.style.height = '250px';
      alertWindow.style.left = '200px';
      alertWindow.style.top = '250px';
      alertWindow.style.background = '#222';
	  alertWindow.style.border = '4px double #ffffff';
      Browser.document.body.appendChild(alertWindow);

      // alert text
      alertText = Browser.document.createElement("alertText");
      alertText.style.overflow = 'auto';
      alertText.style.position = 'absolute';
      alertText.style.left = '10px';
      alertText.style.top = '10px';
      alertText.style.width = '580px';
      alertText.style.height = '200px';
      alertText.style.background = '#111';
	  alertText.style.border = '1px solid #777';
      alertWindow.appendChild(alertText);

      var status = e('status');
      status.innerHTML = "<table width=100%><tr>" +
        "<td halign=left id=statusTheory>" +
        "<td halign=left id=statusSuspicion>" +
        "<td halign=left id=statusMarkers>" +
        "<td halign=left id=statusChance>" +
        "<td halign=left><span id=statusPanic style='color:#ee1111'></span>" +
        "<td halign=left><span id=statusAggression style='color:#22eeee'></span>" +
        "<td halign=right><p id=statusTurns style='text-align:right; margin-right:5'>" +
        "</table>";
      for (el in [ 'Theory', 'Suspicion', 'Markers', 'Chance',
          'Panic', 'Aggression', 'Turns' ])
        {
          e('status' + el).onmouseenter = tooltip.bind(el);
          e('status' + el).onmouseleave = clearMessage;
        }

      // alert close button
      var alertClose = createCloseButton(alertWindow, 260, 215, 'alertClose');
	  alertClose.onclick = onAlertCloseClick;

      loadImages();
    }


// show tooltip for UI element
  function tooltip(el: String)
    {
      var s = null;
      if (el == 'Theory')
        s = 'Current theory progress. You win when it reaches 10.';
      else if (el == 'Suspicion')
        s = 'Current authorities suspicion. You lose when it reaches 3.';
      else if (el == 'Markers')
        s = 'Maximum amount of markers to control the reanimated with.';
      else if (el == 'Chance')
        s = 'Chance of theory progress on bodies with quality 1/2/3.';
      else if (el == 'Panic')
        s = 'The town is in panic! Police patrols near the station.';
      else if (el == 'Aggression')
        s = 'The reanimated are aggressive. Read more in hints.';
      else if (el == 'Turns')
        s = 'The amount of turns passed since game start.';
      else if (el == 'EndTurn')
        s = 'Press to end game turn.';
      else if (el == 'Restart')
        s = 'Press to restart the game.';
      msg(s);
    }


// clear message
  function clearMessage()
    {
      msg('');
    }


// load images
  function loadImages()
    {
      images = new Map();

      var imgnames = [ 'tile_building', 'tile_cemetery', 'tile_grass',
        'tile_lab', 'tile_police', 'tile_tree',
        'undefined', 'object_body1', 'object_body3', 'object_human1',
        'object_human3', 'object_human_alerted2', 'object_quest',
        'object_body2', 'object_cop', 'object_human2', 'object_human_alerted1',
        'object_human_alerted3', 'object_human_quest', 'object_reanimated',
        'building2x2', 'building2x3', 'building2x4', 'building3x2',
        'building3x3', 'building3x4', 'building4x2', 'building4x3',
        'building4x4', 'building_cemetery', 'building_lab', 'building_police'
        ];

      for (nm in imgnames)
        {
          var img = new Image();
          img.onload = onLoadImage;
          img.src = 'images/' + nm + '.png';

          images.set(nm, img);
        }
    }


  function onLoadImage()
    {
      game.map.paint();
    }


// keypress handling
  function onKey(ev: KeyboardEvent)
    {
      var key = ev.keyCode;

      // end turn
      if (ev.keyCode == 69 || ev.keyCode == 32) // E, Space
        onEndTurn(null);

      // dont propagate space button
      if (ev.keyCode == 32)
        {
          ev.stopPropagation();

          ev.cancelBubble = true;
          ev.preventDefault();
        }
    }


// create close button
  function createCloseButton(container: Element, x: Int, y: Int, name: String)
    {
      var b = Browser.document.createElement(name);
      b.innerHTML = '<b>Close</b>';
      b.style.fontSize = '20px';
      b.style.position = 'absolute';
      b.style.width = '80px';
      b.style.height = '25px';
      b.style.left = x + 'px';
      b.style.top = y + 'px';
      b.style.background = '#111';
	  b.style.border = '1px outset #777';
	  b.style.cursor = 'pointer';
      b.style.textAlign = 'center';
      container.appendChild(b);
      return b;
    }


// hide alert
  function onAlertCloseClick(event)
    {
      alertWindow.style.visibility = 'hidden';
    }


// on clicking restart button
  public function onRestart(event)
    {
      msgLocked = false;
      msg("", false);
      game.restart();
    }


// on clicking restart button
  public function onEndTurn(event)
    {
      if (alertWindow.style.visibility == 'visible')
        return;

      msgLocked = false;
      msg("", false);
      game.endTurn();
    }


// on map mouse click
  public function onMapClick(event)
    {
      if (game.isFinished)
        return;

      // clean msg lock
      if (msgLocked)
        {
          msgLocked = false;
          msg("", false);
        }

      var map = e("map");
      var x = event.clientX - map.offsetLeft - 14;
      var y = event.clientY - map.offsetTop - 14;
      var cellX = Std.int((x - 5) / cellSize);
      var cellY = Std.int((y - 7) / cellSize);
//      trace(x + "," + y + " -> " + cellX + "," + cellY);

      var cell = game.map.get(cellX, cellY);
      if (cell != null)// && cell.hasAdjacentWalkable())
        {
          cell.activate();
        }

      justClicked = true;
      paintStatus();
    }


// on map mouse move
  public function onMapMove(event)
    {
      if (justClicked)
        {
          justClicked = false;
          return;
        }
      if (game.isFinished)
        return;

      var map = e("map");
      var x = event.clientX - map.offsetLeft - 14;
      var y = event.clientY - map.offsetTop - 14;
//      trace(x + ' ' + y + ' : ' + map.offsetLeft + ',' + map.offsetTop);

      cursorX = Std.int((x - 5) / cellSize);
      cursorY = Std.int((y - 7) / cellSize);
/*
      // paint changed rectangle
      game.map.paint(getRect(cursorX, cursorY, repaintRadius));

      // check, if mouse moved more then the rect, repaint all
      var dx = prevX - x;
      var dy = prevY - y;
      if (dx * dx + dy * dy > 10000)
        game.map.paint();
*/
      var cell = game.map.get(cursorX, cursorY);
      if (cell != null && cell.isVisible)
        {
          tip(cell.getNote());

          // draw message
          var m = game.map.getMessage(cell.x, cell.y);
          if (m != null)
            msg(m.text);

          // draw object message
          else if (cell.object != null)
            msg(cell.object.getMessage());

          // draw marker help
          else if (game.map.hasMarker(cell.x, cell.y))
            msg('This marker will attract reanimated if they are close enough. ');

          // police building
          else if (cell.building == game.map.police)
            {
              var s = new StringBuf();
              s.add('There are ' +
                (game.map.copsTotal - game.stats.copsDead) +
                ' officers left');
              if (game.map.police.reanimated > 0)
                {
                  s.add('. ' + game.map.police.reanimated +
                    ' reanimated ');
                  if (game.map.police.reanimated == 1)
                    s.add('is');
                  else s.add('are');
                  s.add(' in the building.');
                }
              else s.add(' to protect the town.');
              msg(s.toString());
            }

          // cemetery
          else if (cell.building == game.map.cemetery)
            msg('The town cemetery is your main source of bodies.');

          // lab
          else if (cell.building == game.player.lab)
            msg('Macabre science is being done here!');

          else msg('');

        }
      else
        {
          tip('');
          msg('');
        }

      prevX = x;
      prevY = y;
    }


// get a rect around a cell
  public static function getRect(x: Int, y: Int, radius: Int)
    {
      var rect = {
        x: 3 + (x - radius) * cellSize,
        y: 2 + (y - radius) * cellSize,
        w: cellSize * radius * 2,
        h: cellSize * radius * 2 };
      if (radius == 0)
        {
          rect.w = cellSize;
          rect.h = cellSize;
        }
      return rect;
    }


// show a message
  public function msg(s: String, ?isLocked: Bool)
    {
      if (isLocked == null)
        isLocked = true;
//      trace(isLocked + " " + msgLocked);
      if (msgLocked && !isLocked)
        return;
      if (isLocked)
        msgLocked = true;
      e("msg").innerHTML = '<center>' + s + '</center>';
    }


// show a tip
  public function tip(s: String)
    {
      e("tip").innerHTML = s;
    }


// repaint status panel (fsta)
  public function paintStatus()
    {
      e('statusTheory').innerHTML = 'Theory: ' +
        game.player.theory;
      e('statusSuspicion').innerHTML = 'Suspicion: ' +
        game.player.suspicion;
      e('statusMarkers').innerHTML = 'Markers: ' +
        game.player.getMaxMarkers();
      e('statusChance').innerHTML = 'Chance: ' +
        game.player.getTheoryChance(1) + "% / " +
        game.player.getTheoryChance(2)+ "% / " +
        game.player.getTheoryChance(3)+ "%";
      e('statusPanic').innerHTML =
        (game.isPanic ? 'PANIC!' : '');
      e('statusAggression').innerHTML =
        (game.aggressionFlag ? 'AG' : '');
      e('statusTurns').innerHTML = 'Turns: ' + game.turns;
    }


// get element shortcut
  public static inline function e(s)
    {
	  return Browser.document.getElementById(s);
	}


// finish the game (ui)
  public function finish(isVictory: Bool, reason: String)
    {
      var el: CanvasElement = cast UI.e("map");
      var map = el.getContext2d();
      map.font = (UI.cellSize - 4) + "px Verdana";
      map.fillStyle = "rgba(0, 0, 0, 0.7)";
      map.fillRect(0, 0, el.width, el.height);

      map.fillStyle = "white";
      var text = "";
      if (isVictory)
        {
          var result = '';
          if (reason == 'police')
            result = 'removed the official obstacles';
          else if (reason == 'theory')
            result = 'proven your theory';
          text = "You have " + result + " in " + game.turns + " turns!";
        }
      else text = "You have been found out...";
      var metrics = map.measureText(text);
      var x = (el.width - metrics.width) / 2;
      var y = (el.height - cellSize) / 2;
      map.fillText(text, x, y);

      // game stats
      var font = Std.int(0.4 * UI.cellSize);
      map.font = font + "px Verdana";
      map.fillStyle = "yellow";
      var i = 0;
      map.fillText(game.stats.humansDead +
        " citizens died during the course of these horrible events.",
        10, y + 70);
      map.fillText(game.stats.copsDead +
        " police officers died fulfilling their duty.",
        10, y + 70 + (font + 10) * (++i));
      map.fillText(game.stats.bodiesTested +
        " different solutions were tested on the specimens.",
        10, y + 70 + (font + 10) * (++i));
      map.fillText(game.stats.bodiesReanimated +
        " specimens were successfully reanimated.",
        10, y + 70 + (font + 10) * (++i));
      map.fillText(game.stats.reanimatedDestroyed +
        " reanimated bodies were put down by the police.",
        10, y + 70 + (font + 10) * (++i));
      if (game.aggressionFlag)
        map.fillText("The reanimated were aggressive.",
          10, y + 70 + (font + 10) * (++i));
    }


// track stuff through google analytics
  public inline function track(action: String, ?label: String, ?value: Int)
    {
      action = "drwest "  + action + " " + Game.version;
      if (label == null)
        label = '';
      if (value == null)
        value = 0;
      untyped pageTracker._trackEvent('Dr West', action, label, value);
    }


// message with confirmation
  public function alert(s)
    {
      alertText.innerHTML = '<center>' + s + '</center>';
      alertWindow.style.visibility = 'visible';
    }


// get a stored variable (cookie)
  public inline function getVar(name: String)
    {
      return untyped getCookie(name);
    }


// get a stored variable (cookie)
  public inline function setVar(name: String, val: String)
    {
      return untyped setCookie(name, val,
        untyped __js__("new Date(2015, 0, 0, 0, 0, 0, 0)"));
    }


  public static var cellSize: Int = 40;
  public static var mapWidth: Int = 25;
  public static var mapHeight: Int = 16;
  public static var repaintRadius: Int = 3;
}
