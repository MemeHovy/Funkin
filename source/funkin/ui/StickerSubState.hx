package funkin.ui;

import flixel.FlxSprite;
import haxe.Json;
import lime.utils.Assets;
// import flxtyped group
import funkin.ui.story.StoryMenuState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.util.FlxSignal;
import flixel.addons.transition.FlxTransitionableState;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.display.Sprite;
import openfl.display.Bitmap;

class StickerSubState extends MusicBeatSubState
{
  public var grpStickers:FlxTypedGroup<StickerSprite>;

  // yes... a damn OpenFL sprite!!!
  public var dipshit:Sprite;

  var nextState:NEXTSTATE = FREEPLAY;

  public function new(?oldStickers:Array<StickerSprite>, ?nextState:NEXTSTATE = FREEPLAY):Void
  {
    super();

    this.nextState = nextState;

    grpStickers = new FlxTypedGroup<StickerSprite>();
    add(grpStickers);

    // makes the stickers on the most recent camera, which is more often than not... a UI camera!!
    // grpStickers.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    grpStickers.cameras = FlxG.cameras.list;

    if (oldStickers != null)
    {
      for (sticker in oldStickers)
      {
        grpStickers.add(sticker);
        trace(sticker);
      }

      degenStickers();
    }
    else
      regenStickers();
  }

  public function degenStickers():Void
  {
    grpStickers.cameras = FlxG.cameras.list;

    if (dipshit != null)
    {
      FlxG.removeChild(dipshit);
      dipshit = null;
    }

    for (ind => sticker in grpStickers.members)
    {
      new FlxTimer().start(sticker.timing, _ -> {
        sticker.visible = false;

        if (ind == grpStickers.members.length - 1)
        {
          switchingState = false;
          close();
        }
      });
    }
  }

  function regenStickers():Void
  {
    if (grpStickers.members.length > 0)
    {
      grpStickers.clear();
    }

    var stickerInfo:StickerInfo = new StickerInfo('stickers-set-1');
    var stickers:Map<String, Array<String>> = new Map<String, Array<String>>();
    for (stickerSets in stickerInfo.getPack("all"))
    {
      stickers.set(stickerSets, stickerInfo.getStickers(stickerSets));

      trace(stickers);

      // for (stickerShit in stickerInfo.getStickers(stickerSets))
      // {
      //   // for loop jus to repeat it easy easy easy
      //   for (i in 0...FlxG.random.int(1, 5))
      //   {
      //     var sticky:StickerSprite = new StickerSprite(0, 0, stickerInfo.name, stickerShit);
      //     sticky.x -= sticky.width / 2;
      //     sticky.y -= sticky.height * 0.9;

      //     // random location by default
      //     sticky.x += FlxG.random.float(0, FlxG.width);
      //     sticky.y += FlxG.random.float(0, FlxG.height);

      //     sticky.visible = false;
      //     sticky.scrollFactor.set();
      //     sticky.angle = FlxG.random.int(-60, 70);
      //     // sticky.flipX = FlxG.random.bool();
      //     grpStickers.add(sticky);

      //     sticky.timing = FlxG.random.float(0, 0.8);
      //   }
      // }
    }

    var xPos:Float = -100;
    var yPos:Float = -100;
    while (xPos <= FlxG.width)
    {
      var stickerSet:String = FlxG.random.getObject(stickers.keyValues());
      var sticker:String = FlxG.random.getObject(stickers.get(stickerSet));
      var sticky:StickerSprite = new StickerSprite(0, 0, stickerInfo.name, sticker);
      sticky.visible = false;

      sticky.x = xPos;
      sticky.y = yPos;
      xPos += sticky.frameWidth * 0.5;

      if (xPos >= FlxG.width)
      {
        if (yPos <= FlxG.height)
        {
          xPos = -100;
          yPos += FlxG.random.float(70, 120);
        }
      }

      sticky.angle = FlxG.random.int(-60, 70);
      grpStickers.add(sticky);
    }

    FlxG.random.shuffle(grpStickers.members);

    // var stickerCount:Int = 0;

    // for (w in 0...6)
    // {
    //   var xPos:Float = FlxG.width * (w / 6);
    //   for (h in 0...6)
    //   {
    //     var yPos:Float = FlxG.height * (h / 6);
    //     var sticker = grpStickers.members[stickerCount];
    //     xPos -= sticker.width / 2;
    //     yPos -= sticker.height * 0.9;
    //     sticker.x = xPos;
    //     sticker.y = yPos;

    //     stickerCount++;
    //   }
    // }

    // for (ind => sticker in grpStickers.members)
    // {
    //   sticker.x = (ind % 8) * sticker.width;
    //   var yShit:Int = Math.floor(ind / 8);
    //   sticker.y += yShit * sticker.height;
    //   // scales it juuuust a smidge
    //   sticker.y += 20 * yShit;
    // }

    // another damn for loop... apologies!!!
    for (ind => sticker in grpStickers.members)
    {
      sticker.timing = FlxMath.remapToRange(ind, 0, grpStickers.members.length, 0, 0.9);

      new FlxTimer().start(sticker.timing, _ -> {
        sticker.visible = true;

        var frameTimer:Int = FlxG.random.int(0, 2);

        // always make the last one POP
        if (ind == grpStickers.members.length - 1) frameTimer = 2;

        new FlxTimer().start((1 / 24) * frameTimer, _ -> {
          sticker.scale.x = sticker.scale.y = FlxG.random.float(0.97, 1.02);

          if (ind == grpStickers.members.length - 1)
          {
            switchingState = true;
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;

            dipshit = new Sprite();
            var scrn:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
            var mat:Matrix = new Matrix();
            scrn.draw(grpStickers.cameras[0].canvas, mat);

            var bitmap:Bitmap = new Bitmap(scrn);

            dipshit.addChild(bitmap);
            FlxG.addChildBelowMouse(dipshit);

            switch (nextState)
            {
              case FREEPLAY:
                FlxG.switchState(new FreeplayState(this));
              case STORY:
                FlxG.switchState(new StoryMenuState(this));
              case MAIN_MENU:
                FlxG.switchState(new MainMenuState());
              default:
                FlxG.switchState(new MainMenuState());
            }
          }

          // sticky.angle *= FlxG.random.float(0, 0.05);
        });
      });
    }

    grpStickers.sort((ord, a, b) -> {
      return FlxSort.byValues(ord, a.timing, b.timing);
    });

    // centers the very last sticker
    var lastOne:StickerSprite = grpStickers.members[grpStickers.members.length - 1];
    lastOne.updateHitbox();
    lastOne.angle = 0;
    lastOne.screenCenter();
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.ANY)
    {
      regenStickers();
    }
  }

  var switchingState:Bool = false;

  override public function close():Void
  {
    if (switchingState) return;
    super.close();
  }

  override public function destroy():Void
  {
    if (switchingState) return;
    super.destroy();
  }
}

class StickerSprite extends FlxSprite
{
  public var timing:Float = 0;

  public function new(x:Float, y:Float, stickerSet:String, stickerName:String):Void
  {
    super(x, y);
    loadGraphic(Paths.image('transitionSwag/' + stickerSet + '/' + stickerName));
    updateHitbox();
    scrollFactor.set();
  }
}

class StickerInfo
{
  public var name:String;
  public var artist:String;
  public var stickers:Map<String, Array<String>>;
  public var stickerPacks:Map<String, Array<String>>;

  public function new(stickerSet:String):Void
  {
    var path = Paths.file('images/transitionSwag/' + stickerSet + '/stickers.json');
    var json = Json.parse(Assets.getText(path));
    trace(json);

    // doin this dipshit nonsense cuz i dunno how to deal with casting a json object with
    // a dash in its name (sticker-packs)
    var jsonInfo:StickerShit = cast json;

    this.name = jsonInfo.name;
    this.artist = jsonInfo.artist;

    stickerPacks = new Map<String, Array<String>>();

    for (field in Reflect.fields(json.stickerPacks))
    {
      var stickerFunny = json.stickerPacks;
      var stickerStuff = Reflect.field(stickerFunny, field);

      stickerPacks.set(field, cast stickerStuff);

      trace(field);
      trace(Reflect.field(stickerFunny, field));
    }

    trace(stickerPacks);

    // creates a similar for loop as before but for the stickers
    stickers = new Map<String, Array<String>>();

    for (field in Reflect.fields(json.stickers))
    {
      var stickerFunny = json.stickers;
      var stickerStuff = Reflect.field(stickerFunny, field);

      stickers.set(field, cast stickerStuff);

      trace(field);
      trace(Reflect.field(stickerFunny, field));
    }

    trace(stickers);

    // this.stickerPacks = cast jsonInfo.stickerPacks;
    // this.stickers = cast jsonInfo.stickers;

    // trace(stickerPacks);
    // trace(stickers);

    // for (packs in stickers)
    // {
    //   // this.stickers.set(packs, Reflect.field(json, "sticker-packs"));
    //   trace(packs);
    // }
  }

  public function getStickers(stickerName:String):Array<String>
  {
    return this.stickers[stickerName];
  }

  public function getPack(packName:String):Array<String>
  {
    return this.stickerPacks[packName];
  }
}

// somethin damn cute just for the json to cast to!
typedef StickerShit =
{
  name:String,
  artist:String,
  stickers:Map<String, Array<String>>,
  stickerPacks:Map<String, Array<String>>
}

enum abstract NEXTSTATE(String)
{
  var MAIN_MENU = 'mainmenu';
  var FREEPLAY = 'freeplay';
  var STORY = 'story';
}
