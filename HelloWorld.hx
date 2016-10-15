import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.utils.ByteArray;
import nme.geom.Rectangle;
import nme.Lib;
import nme.Memory;

class HelloWorld extends Sprite {
  var rectX : Int = 10;
  var bitmapData: BitmapData;
  var rect : Rectangle;
  var pixels : ByteArray;
  var stageWidth : Int;
  var laneMarkingOffsetY : Float = 0;
  var skyBlue : Int;

  public function new() {
    super();

    var stage = Lib.current.stage;
    stageWidth = stage.stageWidth;

    Lib.current.addChild(new nme.display.FPS());
    //stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
    addEventListener(Event.ENTER_FRAME, update);
    bitmapData = new BitmapData(stage.stageWidth, stage.stageHeight);
    addChild(new Bitmap(bitmapData));

    rect = bitmapData.rect;
    var size : Int = bitmapData.width * bitmapData.height * 4;

    skyBlue = rgbaToHex(80, 0, 255, 255);

    pixels = new ByteArray();

    pixels.setLength(size);
    Memory.select(pixels);
  }

  private function update(event: Event) {
    var stage = Lib.current.stage;

    var centerX = stageWidth / 2;
    var roadWidth : Float = stageWidth;
    var laneMarkingWidth = 8;
    var laneMarkingHeight = 70;

    laneMarkingOffsetY += 3;

    for (y in 0...Math.floor(stage.stageHeight / 2)) {
      roadWidth -= 2.5;

      for (x in 0...stage.stageWidth) {
        var r = 0;
        var g = 200;
        var b = 0;

        var pixelIsRoad = x > centerX - (roadWidth / 2) && x < centerX + (roadWidth / 2);

        var laneMarkingLeftBoundary = centerX - (laneMarkingWidth / 2 - y / 100);
        var laneMarkingRightBoundary = centerX + (laneMarkingWidth / 2 - y / 100);

        var isInLaneMarking = ((laneMarkingOffsetY + y) % laneMarkingHeight) < laneMarkingHeight / 2;

        var pixelIsLaneMarking = x > laneMarkingLeftBoundary && x < laneMarkingRightBoundary && isInLaneMarking;

        if (pixelIsRoad) {
          r = 80;
          g = 80;
          b = 80;
        }

        if (pixelIsLaneMarking) {
          r = 255;
          g = 255;
          b = 255;
        }

                                                        //G R L B
        Memory.setI32(((stage.stageHeight - y) * stageWidth + x) * 4, rgbaToHex(g, r, 255, b));
      }
    }

    for (y in Math.floor(stage.stageHeight / 2)...stage.stageHeight) {
      for (x in 0...stage.stageWidth) {
        Memory.setI32(((stage.stageHeight - y) * stageWidth + x) * 4, skyBlue);
      }
    }

    pixels.position = 0;
    bitmapData.setPixels(rect, pixels);
  }

  private function rgbaToHex(R: Int, G: Int, B: Int, A: Int): Int {
    return (A & 0xFF) << 24 | (R & 0xFF) << 16 | (G & 0xFF) << 8 | (B & 0xFF);
  }
}
