package  
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author fabio
	 */
	public class GameState extends FlxState 
	{
		
		private var walls : FlxGroup = new FlxGroup ();
		private var p1 : Character = new Character ();
		private var fullscreen : Boolean = true;
		
		public function GameState() 
		{
			
		}
		
		override public function create():void 
		{
			FlxG.stage.addEventListener(Event.RESIZE, window_resized);
			add (p1);
			
			var left : FlxSprite = new FlxSprite (0, 0);
			left.makeGraphic (50, FlxG.height);
			add (left);
			left.immovable = true;
			
			var right : FlxSprite = new FlxSprite (FlxG.width - 50, 0);
			right.makeGraphic (50, FlxG.height);
			add (right);
			right.immovable = true;
			
			var top : FlxSprite = new FlxSprite (50, 0);
			top.makeGraphic (FlxG.width - 100, 50);
			add (top);
			top.immovable = true;
			
			var bottom : FlxSprite = new FlxSprite (50, FlxG.height - 50);
			bottom.makeGraphic (FlxG.width - 100, 50);
			add (bottom);
			bottom.immovable = true;
			
			walls.add(left);
			walls.add(right);
			walls.add(top);
			walls.add(bottom);
			
			ControlConfig.loadData();
			
			FlxG.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			super.create();
		}
		
		override public function update():void 
		{
			if (FlxG.keys.justReleased("ESCAPE"))
			{
				toggle_fullscreen();
			}
			
			testPlayerControls (p1, 0);
			
			super.update();
			
			FlxG.collide (walls, p1); 
		}
		
		private function testPlayerControls (player: Character, controlConfig : int) : void
		{
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_BLOCK))
			{
				p1.block();
			}
			else if (ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_BLOCK))
			{
				p1.unblock();
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_LIGHT))
			{
				p1.dash();
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_DASH))
			{
				p1.dash();
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_JUMP))
			{
				p1.jump();
			}
			
			if (ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_JUMP))
			{
				p1.shortHop();
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_MOVE_LEFT))
			{
				p1.walkLeft();
			}
			else if (ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_MOVE_LEFT) && !ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_MOVE_RIGHT))
			{
				p1.stopWalking();
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_MOVE_RIGHT))
			{
				p1.walkRight();
			}
			else if (ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_MOVE_RIGHT) && !ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_MOVE_LEFT))
			{
				p1.stopWalking();
			}
		}
		
		private function toggle_fullscreen():void {
			
			if (fullscreen) {
				fullscreen = false;
				FlxG.stage.displayState = StageDisplayState.NORMAL;
			} else {
				fullscreen = true;
				FlxG.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			window_resized();
		}
		
		private function window_resized(e:Event = null):void {
			
			FlxG.width = FlxG.stage.stageWidth / FlxCamera.defaultZoom;
			FlxG.height = FlxG.stage.stageHeight / FlxCamera.defaultZoom;

			FlxG.resetCameras(new FlxCamera(0, 0, FlxG.width, FlxG.height));
		}

	}

}