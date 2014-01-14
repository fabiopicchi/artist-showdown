package  
{
	import flash.globalization.LocaleID;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import utils.BitFlagControl;
	
	/**
	 * ...
	 * @author fabio
	 */
	public class Character extends FlxSprite 
	{
		private static const WIDTH : int = 50;
		private static const HEIGHT : int = 100;
		private static const SPEED : int = 500;
		
		private static const JUMP_HEIGHT : Number = 1.2 * HEIGHT;
		private static const JUMP_DURATION : Number = 0.5;
		private static const GRAVITY : Number = 2 * JUMP_HEIGHT / (JUMP_DURATION * JUMP_DURATION);
		private static const JUMP_SPEED : Number = - GRAVITY * JUMP_DURATION;
		
		private static const SHORT_HOP_HEIGHT : int = 0.5 * HEIGHT;
		private static const PLAYER_SPEED : int = 500;
		
		private static const DASH_LENGTH : Number = 4 * WIDTH;
		private static const DASH_DURATION : Number = 0.4;
		private static const DASH_ACCELERATION : Number = - 2 * DASH_LENGTH / (DASH_DURATION * DASH_DURATION);
		private static const DASH_SPEED : Number = - DASH_ACCELERATION * DASH_DURATION;
		
		private static const SHORT_HOP_THRESHOLD : int = 100;
		
		private var flagControl : BitFlagControl = new BitFlagControl ();
		private var shortHopTimer : int = 0;
		private var dashTimer : int = 0;
		private var jumpOrigin : int = 0;
		private var lightAttack1 : Attack;
		private var lightAttack2 : Attack;
		private var lightAttack3 : Attack;
		
		public function Character() 
		{
			super(50, 50);
			makeGraphic(50, 100, 0xffff0000);
					
			flagControl.addFlag("MOVE_LEFT");
			flagControl.addFlag("MOVE_RIGHT");
			flagControl.addFlag("JUMP");
			flagControl.addFlag("FALL");
			flagControl.addFlag("SHORT_HOP");
			flagControl.addFlag("DOUBLE_JUMP");
			flagControl.addFlag("DOUBLE_FALL");
			flagControl.addFlag("DASH");
			flagControl.addFlag("DASH_BLOCKED");
			flagControl.addFlag("DASH_COOLDOWN");
			flagControl.addFlag("BLOCK");
			flagControl.addFlag("LIGHT");
			
			width = WIDTH;
			height = HEIGHT;
			
			acceleration.y = GRAVITY;
		}
		
		override public function update():void 
		{
			flagControl.update();
			
			super.update();
			
			if (flagControl.flagSet("DASH_COOLDOWN"))
			{
				dashTimer += FlxG.elapsed * 1000;
				if (dashTimer >= 1.5 * (DASH_LENGTH / PLAYER_SPEED) * 1000)
				{
					flagControl.resetFlag("DASH_COOLDOWN");
					if (flagControl.flagSet("DASH"))
					{
						interruptDash();
					}
				}
				
				if (acceleration.x != 0)
				{
					if ((facing == FlxObject.LEFT && isTouching(FlxObject.LEFT)) ||
								(facing == FlxObject.RIGHT && isTouching(FlxObject.RIGHT)))
					{
						interruptDash();
					}
					else if (dashTimer >= DASH_DURATION * 1000)
					{
						if (!onAir())
						{
							endDash();
						}
						else
						{
							interruptDash();
						}
					}
				}
			}
			
			if (flagControl.flagSet("JUMP"))
			{
				this.shortHopTimer += FlxG.elapsed * 1000;
			}
			
			if (this.velocity.y > 0 && !(flagControl.flagSet("DOUBLE_FALL") || flagControl.flagSet("FALL")))
			{
				if (flagControl.flagSet("DOUBLE_JUMP"))
				{
					this.flagControl.setFlag ("DOUBLE_FALL");
					this.flagControl.resetFlag ("DOUBLE_JUMP");
				}
				else
				{
					this.flagControl.setFlag ("FALL");
					this.flagControl.resetFlag ("JUMP");
					this.flagControl.resetFlag ("SHORT_HOP");
				}
			}
			
			if (justTouched(FlxObject.FLOOR))
			{
				flagControl.resetFlag("FALL");
				flagControl.resetFlag("DOUBLE_FALL");
				flagControl.resetFlag("DASH_BLOCKED");
			}
		}
		
		public function onAir () : Boolean
		{
			return (flagControl.flagSet("SHORT_HOP") || flagControl.flagSet("JUMP") || flagControl.flagSet("DOUBLE_JUMP") || flagControl.flagSet("FALL") || flagControl.flagSet("DOUBLE_FALL"));
		}
		
		public function canMove () : Boolean
		{
			return !(flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK"));
		}
		
		public function onShortHopWindow () : Boolean
		{
			return (flagControl.flagSet("JUMP") && shortHopTimer < SHORT_HOP_THRESHOLD);
		}
		
		public function walkRight () : void
		{
			if (canMove())
			{
				this.velocity.x = PLAYER_SPEED;
			}
			facing = FlxObject.RIGHT;
			this.flagControl.forceSetFlag("MOVE_RIGHT");
			this.flagControl.forceResetFlag("MOVE_LEFT");
			
		}
		
		public function walkLeft () : void
		{
			if (canMove())
			{
				this.velocity.x = -PLAYER_SPEED;
			}
			facing = FlxObject.LEFT;
			this.flagControl.forceSetFlag("MOVE_LEFT");
			this.flagControl.forceResetFlag("MOVE_RIGHT");
		}
		
		public function stopWalking () : void
		{
			if (canMove())
			{
				this.velocity.x = 0;
			}
			this.flagControl.forceResetFlag("MOVE_RIGHT");
			this.flagControl.forceResetFlag("MOVE_LEFT");
		}
		
		public function jump () : void
		{
			if (flagControl.flagSet("DASH")) return;
			
			if (!onAir())
			{
				this.shortHopTimer = 0;
				this.jumpOrigin = this.y;
				this.velocity.y = JUMP_SPEED;
				this.flagControl.setFlag ("JUMP");
			}
			else if (!(this.flagControl.flagSet("DOUBLE_JUMP") || this.flagControl.flagSet("DOUBLE_FALL")))
			{
				this.velocity.y = JUMP_SPEED;
				flagControl.forceResetFlag ("FALL");
				flagControl.forceResetFlag ("JUMP");
				flagControl.forceResetFlag ("SHORT_HOP");
				this.flagControl.setFlag ("DOUBLE_JUMP");
			}
		}
		
		public function shortHop () : void
		{
			if (p1.onShortHopWindow() || flagControl.flagSet("DASH")) return;
			
			this.velocity.y = - Math.sqrt(2 * (SHORT_HOP_HEIGHT - (this.jumpOrigin - this.y)) * GRAVITY);
			flagControl.forceResetFlag ("JUMP");
			this.flagControl.setFlag ("SHORT_HOP");
		}
		
		public function block () : void
		{
			if (flagControl.flagSet("DASH")) return;
			
			flagControl.forceSetFlag("BLOCK");
			this.velocity.x = 0;
			this.velocity.y = 0;
			makeGraphic(50, 100, 0xff8822aa);
		}
		
		public function unblock () : void
		{
			if (flagControl.flagSet ("MOVE_LEFT"))
			{
				this.velocity.x = - PLAYER_SPEED;
			}
			else if (flagControl.flagSet ("MOVE_RIGHT"))
			{
				this.velocity.x = PLAYER_SPEED;
			}
			else
			{
				this.velocity.x = 0;
			}
			flagControl.forceResetFlag("BLOCK");
			makeGraphic(50, 100, 0xffff0000);
		}
		
		public function light () : void
		{
			
		}
		
		public function dash() : void
		{
			if (!(flagControl.flagSet("DASH_BLOCKED") || flagControl.flagSet("DASH_COOLDOWN") || flagControl.flagSet("BLOCK")))
			{
				var direction : int = 1;
				if (facing == FlxObject.LEFT)  direction = -1;
				
				this.velocity.x = direction * DASH_SPEED;
				this.acceleration.x = direction * DASH_ACCELERATION;
				
				this.velocity.y = 0;
				this.acceleration.y = 0;
				this.dashTimer = 0;
				
				if (onAir())
				{
					flagControl.setFlag("DASH_BLOCKED");
				}
				
				flagControl.setFlag("DASH");
				flagControl.forceSetFlag("DASH_COOLDOWN");
				makeGraphic(50, 100, 0xffffff00);
			}
		}
		
		private function interruptDash () : void
		{
			endDash();
			if (flagControl.flagSet ("MOVE_LEFT"))
			{
				this.velocity.x = - PLAYER_SPEED;
			}
			else if (flagControl.flagSet ("MOVE_RIGHT"))
			{
				this.velocity.x = PLAYER_SPEED;
			}
			else
			{
				this.velocity.x = 0;
			}
			flagControl.forceResetFlag("DASH");
		}
		
		private function endDash () : void
		{
			acceleration.y = GRAVITY;
			this.acceleration.x = 0;
			this.velocity.x = 0;
			makeGraphic(50, 100, 0xffff0000);
		}
	}
}