import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.Lib;

class HelloWorld extends Sprite {
  var rectX : Int = 10;

  public function new() {
    super();
    Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
    addEventListener(Event.ENTER_FRAME, update);
  }

  private function update(event: Event) {
    graphics.clear();
    graphics.beginFill(0xff0000);
    graphics.drawRect(rectX, 10, 200, 200);
  }

  private function keyDown(event: KeyboardEvent) {
    trace(event.charCode);

    switch (event.charCode) {
      case 32: {
        rectX += 1;
      }
    }
  }
}
