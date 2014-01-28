package  
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import org.flixel.FlxBasic;
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author fabio
	 */
	public class GameState extends FlxState 
	{
		
		private var walls : FlxGroup = new FlxGroup ();
		private var projectiles : FlxGroup = new FlxGroup ();
		private var hitboxes : FlxGroup = new FlxGroup ();
		private var p1 : Character = new Character ();
		private var p2 : Character = new Character ();
		private var fullscreen : Boolean = true;
		
		public function GameState() 
		{
			
		}
		
		override public function add(Object:FlxBasic):FlxBasic 
		{
			if (Object is Projectile)
			{
				projectiles.add(Object);
			}
			
			if (Object is Hitbox)
			{
				hitboxes.add(Object);
				return Object;
			}
			
			return super.add(Object);
		}
		
		override public function remove(Object:FlxBasic, Splice:Boolean = false):FlxBasic 
		{
			if (Object is Projectile)
			{
				projectiles.remove(Object);
			}
			
			if (Object is Hitbox)
			{
				hitboxes.remove(Object);
			}
			
			return super.remove(Object, Splice);
		}
		
		override public function create():void 
		{
			FlxG.bgColor = FlxG.WHITE;
			FlxG.stage.addEventListener(Event.RESIZE, window_resized);
			add (hitboxes);
			add (p1);
			add (p1.emitter);
			//add (p2);
			
			var left : FlxSprite = new FlxSprite (0, 0);
			left.makeGraphic (50, FlxG.height, 0xff000000);
			add (left);
			left.immovable = true;
			
			var right : FlxSprite = new FlxSprite (FlxG.width - 50, 0);
			right.makeGraphic (50, FlxG.height, 0xff000000);
			add (right);
			right.immovable = true;
			
			var top : FlxSprite = new FlxSprite (50, 0);
			top.makeGraphic (FlxG.width - 100, 50, 0xff000000);
			add (top);
			top.immovable = true;
			
			var bottom : FlxSprite = new FlxSprite (50, FlxG.height - 50);
			bottom.makeGraphic (FlxG.width - 100, 50, 0xff000000);
			add (bottom);
			bottom.immovable = true;
			
			walls.add(left);
			walls.add(right);
			walls.add(top);
			walls.add(bottom);
			
			ControlConfig.loadData();
			super.create();
		}
		
		override public function update():void 
		{
			if (FlxG.keys.justReleased("ESCAPE"))
			{
				//toggle_fullscreen();
				FlxG.switchState(new GameState());
			}
			
			testPlayerControls (p1, 0);
			testPlayerControls (p2, 1);
			
			super.update();
			
			FlxG.collide (walls, p1); 
			FlxG.collide (walls, p2); 
			FlxG.collide (projectiles, walls, function (obj1: FlxObject, obj2 : FlxObject) : void
			{
				if (obj1 is Projectile)
				{
					obj1.destroy();
				}
				else if (obj2 is Projectile)
				{
					obj2.destroy();
				}
			}); 
			
			FlxG.overlap (p1, hitboxes, function (obj1 : FlxObject, obj2 : FlxObject) : void
			{
				if (obj1 is Hitbox)
					Character.hitboxCollision(obj2 as Character, obj1 as Hitbox);
				else
					Character.hitboxCollision(obj1 as Character, obj2 as Hitbox);
			});
			
			FlxG.overlap (p2, hitboxes, function (obj1 : FlxObject, obj2 : FlxObject) : void
			{
				if (obj1 is Hitbox)
					Character.hitboxCollision(obj2 as Character, obj1 as Hitbox);
				else
					Character.hitboxCollision(obj1 as Character, obj2 as Hitbox);
			});
		}
		
		private function testPlayerControls (player: Character, controlConfig : int) : void
		{
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_LIGHT))
			{
				player.light();
			}
			
			if (ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_BLOCK))
			{
				player.block();
				
				if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_EXPRESSION))
				{
					player.expression();
				}
			}
			else if (ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_BLOCK))
			{
				player.unblock();
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_DASH))
			{
				player.dash();
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_JUMP))
			{
				player.jump();
			}
			
			if (ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_JUMP))
			{
				player.shortHop();
			}
			
			if (ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_MOVE_LEFT))
			{
				player.walkLeft();
			}
			else if (ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_MOVE_RIGHT))
			{
				player.walkRight();
			}
			
			if (ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_MOVE_LEFT) || ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_MOVE_RIGHT))
			{
				player.stopWalking();
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_HEAVY))
			{
				if (ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_UP))
				{
					player.heavy(Attack.UP);
				}
				else if (ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_DOWN))
				{
					player.heavy(Attack.DOWN);
				}
				else
				{
					player.heavy(Attack.SIDE);
				}
			}
			
			if (ControlConfig.actionStarted(controlConfig, ControlConfig.ACTION_PROJECTILE))
			{
				player.projectile();
			}
			
			if (ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_TAUNT_1) && ControlConfig.actionActive(controlConfig, ControlConfig.ACTION_TAUNT_2))
			{
				player.taunt();
			}
			
			if (ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_TAUNT_1) || ControlConfig.actionReleased(controlConfig, ControlConfig.ACTION_TAUNT_2))
			{
				player.stopTaunt();
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
			FlxG.camera.scroll.x = -(FlxG.stage.stageWidth - 1366)/2;
			FlxG.camera.scroll.y = -(FlxG.stage.stageHeight - 768)/2;
			
		}

	}

}