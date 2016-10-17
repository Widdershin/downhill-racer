import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.utils.ByteArray;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.Memory;
import openfl.Assets;
import openfl.Vector;

class Main extends Sprite {
  var rectX : Int = 10;
  var bitmapData: BitmapData;
  var rect : Rectangle;
  var pixels : ByteArray;
  var stageWidth : Int;
  var laneMarkingOffsetY : Float = 0;
  var skyBlue : Int;
  var fov : Int = 40;
  var cameraDepth : Float;
  var cameraHeight : Int = -250;
  var segments = [];
  var centerX : Float;
  var road : Shape;
  var skaterX : Float = 1;
  var skaterZ : Float = 0;

  public function new() {
    super();

    var segmentLength = 100;

    for (n in 0...100) {
      segments.push({
        index: n,

        startZ: n * segmentLength,
        endZ: (n + 1) * segmentLength,
        projection: {
          start: {
            x: 0,
            y: 0,
            width: 0
          },
          end: {
            x: 0,
            y: 0,
            width: 0
          }
        }
      });
    }

    var stage = Lib.current.stage;
    stageWidth = stage.stageWidth;

    cameraDepth = 1 / Math.tan(fov / 2);
    centerX = stageWidth / 2;

    road = new Shape();
    addChild(road);

    Lib.current.addChild(new openfl.display.FPS());
    stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
    addEventListener(Event.ENTER_FRAME, render);
    skyBlue = rgbaToHex(0, 80, 255, 255);

    var skaterBitmap = Assets.getBitmapData('assets/skater.png');
    var skater = new Bitmap(skaterBitmap);
    addChild(skater);

    skater.scaleX = 4.0;
    skater.scaleY = 4.0;
    skater.x = stage.stageWidth / 2 - skaterBitmap.width * 2.05;
    skater.y = stage.stageHeight - 270;
  }

  private function render (event: Event) {
    // render the sky
    // for each segment
      // render the segment

    skaterZ += 20;

    graphics.clear();

    graphics.beginFill(0x5500FF);
    graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight / 2);

    graphics.beginFill(0x00AA00);
    graphics.drawRect(0, stage.stageHeight / 2, stage.stageWidth, stage.stageHeight);

    road.graphics.clear();

    for (segment in segments) {
      drawSegment(segment);
    }
  }

  private function drawSegment (segment) {
    var roadWidth = 500;

    segment.index;

    var color;

    switch (segment.index % 2 == 0) {
      case true: {
        color = 0x777777;
      }

      case false: {
        color = 0x555555;
      }
    }

    project(
      segment.projection.start,
      segment.startZ,
      -roadWidth / 2 * skaterX,
      cameraHeight,
      skaterZ,
      cameraDepth,
      stage.stageWidth,
      stage.stageHeight,
      roadWidth
    );

    project(
      segment.projection.end,
      segment.endZ,
      -roadWidth / 2 * skaterX,
      cameraHeight,
      skaterZ,
      cameraDepth,
      stage.stageWidth,
      stage.stageHeight,
      roadWidth
    );

    var startProjection = segment.projection.start;
    var endProjection = segment.projection.end;

    if (startProjection.x < 0 || startProjection.y < 0 || startProjection.width < 0) {
      return;
    }

    if (endProjection.x < 0 || endProjection.y < 0 || endProjection.width < 0) {
      return;
    }

    road.graphics.lineStyle();
    road.graphics.beginFill(color);
    road.graphics.moveTo(startProjection.x, startProjection.y);
    road.graphics.lineTo(endProjection.x, endProjection.y);
    road.graphics.lineTo(endProjection.x + endProjection.width, endProjection.y);
    road.graphics.lineTo(startProjection.x + startProjection.width, startProjection.y);
    road.graphics.lineTo(startProjection.x, startProjection.y);
    road.graphics.endFill();

    road.graphics.lineStyle(2, 0x00);
    road.graphics.moveTo(startProjection.x, startProjection.y);
    road.graphics.lineTo(endProjection.x, endProjection.y);

    road.graphics.moveTo(startProjection.x + startProjection.width, startProjection.y);
    road.graphics.lineTo(endProjection.x + endProjection.width, endProjection.y);
  }

  private function _update(event: Event) {
    var stage = Lib.current.stage;

    var centerX = stageWidth / 2;
    var roadWidth : Float = stageWidth;
    var laneMarkingWidth = 8;
    var laneMarkingHeight = 70;
    var yWorld = -10;

    laneMarkingOffsetY += 5;

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

        Memory.setI32(((stage.stageHeight - y) * stageWidth + x) * 4, rgbaToHex(r, g, b, 255));
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

  private function project (projection, z, cameraX : Float, cameraY, cameraZ : Float, cameraDepth : Float, width, height, roadWidth) {
    var scale = cameraDepth / (z - cameraZ);

    projection.x = Math.floor((width / 2) + (scale * cameraX * width / 2));
    projection.y = Math.floor((height / 2) - (scale * cameraY * height / 2));
    projection.width = Math.floor(scale * roadWidth * width / 2);
  }

  private function keyDown (event: KeyboardEvent) {
    switch (event.keyCode) {
      case (Keyboard.A): {
        skaterX -= 0.03;
      }

      case (Keyboard.D): {
        skaterX += 0.03;
      }
    };
  }

  private function rgbaToHex(R: Int, G: Int, B: Int, A: Int): Int {
    return (R & 0xFF) << 16 | (G & 0xFF) << 8 | (B & 0xFF);
  }
}
