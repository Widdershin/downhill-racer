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
  var cameraHeight : Int = -248;
  var segments = [];
  var centerX : Float;
  var road : Shape;
  var skaterX : Float = 1;
  var skaterZ : Float = 0;
  var segmentLength : Int = 100;

  public function new() {
    super();

    for (n in 1...200) {
      var curve;

      if (n < 50) {
        curve = 5;
      } else {
        curve = -5;
      };

      if (n > 100) {
        curve = 0;
      }

      segments.push({
        index: n,

        curve: curve,

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

    var x = 0;
    var dx = 0;

    var currentSegmentIndex = Math.floor(skaterZ / segmentLength);
    var currentSegment = segments[currentSegmentIndex];

    skaterX += currentSegment.curve / 1000;

    for (segmentIndex in (currentSegmentIndex...(segments.length - 1))) {
      var segment = segments[segmentIndex];

      drawSegment(segment, x, dx);

      x += dx;
      dx += segment.curve;
    }
  }

  private function drawSegment (segment, x, dx) {
    var roadWidth = 700;

    segment.curve;

    var color;

    switch (segment.index % 2 == 0) {
      case true: {
        color = 0x777777;
      }

      case false: {
        color = 0x666666;
      }
    }

    project(
      segment.projection.start,
      segment.startZ,
      -roadWidth / 2 * skaterX - x,
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
      -roadWidth / 2 * skaterX - x - dx,
      cameraHeight,
      skaterZ,
      cameraDepth,
      stage.stageWidth,
      stage.stageHeight,
      roadWidth
    );

    var startProjection = segment.projection.start;
    var endProjection = segment.projection.end;

    road.graphics.lineStyle();
    road.graphics.beginFill(color);
    road.graphics.moveTo(startProjection.x, startProjection.y);
    road.graphics.lineTo(endProjection.x, endProjection.y);
    road.graphics.lineTo(endProjection.x + endProjection.width, endProjection.y);
    road.graphics.lineTo(startProjection.x + startProjection.width, startProjection.y);
    road.graphics.lineTo(startProjection.x, startProjection.y);
    road.graphics.endFill();

    road.graphics.lineStyle();
    road.graphics.moveTo(startProjection.x, startProjection.y);
    road.graphics.lineTo(endProjection.x, endProjection.y);

    road.graphics.moveTo(startProjection.x + startProjection.width, startProjection.y);
    road.graphics.lineTo(endProjection.x + endProjection.width, endProjection.y);
  }

  private function project (projection, z, cameraX : Float, cameraY : Float, cameraZ : Float, cameraDepth : Float, width, height, roadWidth) {
    var scale = cameraDepth / (z - cameraZ);

    projection.x = Math.round((width / 2) + (scale * cameraX * width / 2));
    projection.y = Math.round((height / 2) - (scale * cameraY * height / 2));
    projection.width = Math.round(scale * roadWidth * width / 2);
  }

  private function keyDown (event: KeyboardEvent) {
    switch (event.keyCode) {
      case (Keyboard.A): {
        skaterX -= 0.05;
      }

      case (Keyboard.D): {
        skaterX += 0.05;
      }
    };
  }

  private function rgbaToHex(R: Int, G: Int, B: Int, A: Int): Int {
    return (R & 0xFF) << 16 | (G & 0xFF) << 8 | (B & 0xFF);
  }
}
