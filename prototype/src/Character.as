package  
{
	import flash.globalization.LocaleID;
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	import utils.BitFlagControl;
	import utils.JSONLoader;
	
	/**
	 * ...
	 * @author fabio
	 */
	public class Character extends FlxSprite implements IOrigin, IThrower
	{
		private static const WIDTH : int = 50;
		private static const HEIGHT : int = 100;
		private static const SPEED : int = 500;
		
		private static const JUMP_HEIGHT : Number = 1.2 * HEIGHT;
		private static const JUMP_DURATION : Number = 0.5;
		private static const GRAVITY : Number = 2 * JUMP_HEIGHT / (JUMP_DURATION * JUMP_DURATION);
		private static const JUMP_SPEED : Number = GRAVITY * JUMP_DURATION;
		
		private static const SHORT_HOP_HEIGHT : int = 0.5 * HEIGHT;
		private static const PLAYER_SPEED : int = 500;
		
		private static const DASH_LENGTH : Number = 4 * WIDTH;
		private static const DASH_DURATION : Number = 0.4;
		private static const DASH_ACCELERATION : Number = - 2 * DASH_LENGTH / (DASH_DURATION * DASH_DURATION);
		private static const DASH_SPEED : Number = - DASH_ACCELERATION * DASH_DURATION;
		
		private static const SHORT_HOP_THRESHOLD : int = 100;
		private static const PROJECTILE_THRESHOLD : int = 500;
		
		private var flagControl : BitFlagControl = new BitFlagControl ();
		private var shortHopTimer : int = 0;
		private var dashTimer : int = 0;
		private var projectileTimer : int = 0;
		private var hitStunTimer : int = 0;
		private var knockbackTimer : int = 0;
		private var jumpOrigin : int = 0;
		private var attacks : Dictionary = new Dictionary ();
		private var currentAttack:Attack;
		private var facingHit:int;
		private var specialLevel : Number = 0;
		private var hurtboxType : int = HurtboxType.NORMAL;
		
		public function Character() 
		{
			super(50, 50);
			makeGraphic(50, 100, 0xffff9900);
			hurtboxType = HurtboxType.NORMAL;
					
			flagControl.addFlag("MOVING");
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
			flagControl.addFlag("HEAVY");
			flagControl.addFlag("THROWING_PROJECTILE");
			flagControl.addFlag("PROJECTILE_LOCK");
			flagControl.addFlag("TAUNT");
			flagControl.addFlag("EXPRESSION");
			flagControl.addFlag("HIT_STUN");
			flagControl.addFlag("KNOCKBACK");
			
			width = WIDTH;
			height = HEIGHT;
			
			acceleration.y = GRAVITY;
			
			var attacksJSON : Array = JSONLoader.loadFile("attacks.json") as Array;
			
			for (var i : int = 0; i < attacksJSON.length; i++)
			{
				var attack : Attack = Attack.loadAttack(attacksJSON[i], this);
				
				if (!attacks[attacksJSON[i].input])
				{
					attacks[attacksJSON[i].input] = new Vector.<Attack> ();
				}
				attacks[attacksJSON[i].input].push (attack);
			}
			
			maxVelocity.y = JUMP_SPEED;
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
			
			if (flagControl.flagSet("THROWING_PROJECTILE"))
			{
				this.projectileTimer += FlxG.elapsed * 1000;
				if (this.projectileTimer >= PROJECTILE_THRESHOLD)
				{
					flagControl.forceResetFlag("THROWING_PROJECTILE");
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
				maxVelocity.y = JUMP_SPEED;
			}
			
			if (flagControl.flagSet("LIGHT") && !currentAttack.active)
			{
				currentAttack = null;
				flagControl.forceResetFlag("LIGHT");
				maxVelocity.y = JUMP_SPEED;
			}
			
			if (flagControl.flagSet("HEAVY") && !currentAttack.active)
			{
				currentAttack = null;
				flagControl.forceResetFlag("HEAVY");
				maxVelocity.y = JUMP_SPEED;
			}
			
			if (flagControl.flagSet("EXPRESSION"))
			{
				if (!currentAttack.active)
				{
					currentAttack = null;
					flagControl.forceResetFlag("EXPRESSION");
					maxVelocity.y = JUMP_SPEED;
				}
				else
				{
					if (currentAttack.isOnSetup() && hurtboxType != HurtboxType.MELEE_ONLY)
					{
						makeGraphic(WIDTH, HEIGHT, 0xff00ff00);
						hurtboxType = HurtboxType.MELEE_ONLY;
					}
					else if (currentAttack.isOnAccomodation() && hurtboxType != HurtboxType.NORMAL)
					{
						makeGraphic(WIDTH, HEIGHT, 0xffff9900);
						hurtboxType = HurtboxType.NORMAL;
					}
					else if (hurtboxType != HurtboxType.IMUNE)
					{
						makeGraphic(WIDTH, HEIGHT, 0xff00ffff);
						hurtboxType = HurtboxType.IMUNE;
					}
				}
			}
			
			if (flagControl.flagSet("MOVING") && canMove())
			{
				if (facing == FlxObject.LEFT)
				{
					velocity.x = -PLAYER_SPEED;
				}
				else if (facing == FlxObject.RIGHT)
				{
					velocity.x = PLAYER_SPEED;
				}
			}
			else if (!(flagControl.flagSet("DASH_COOLDOWN") || flagControl.flagSet("KNOCKBACK")))
			{
				velocity.x = 0;
			}
			
			if (flagControl.flagSet("HIT_STUN"))
			{
				hitStunTimer -= FlxG.elapsed * 1000;
				if (hitStunTimer <= 0)
				{
					flagControl.forceResetFlag("HIT_STUN");
				}
			}
			
			if (flagControl.flagSet("KNOCKBACK"))
			{
				knockbackTimer -= FlxG.elapsed * 1000;
				
				if (knockbackTimer<= 0)
				{
					flagControl.forceResetFlag("KNOCKBACK");
					this.acceleration.y = GRAVITY;
					acceleration.x = 0;
					maxVelocity.y = JUMP_SPEED;
				}
			}
		}
		
		private function canMove(): Boolean 
		{
			return (!(flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("LIGHT") || flagControl.flagSet("HEAVY") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")));
		}
		
		public function onAir () : Boolean
		{
			return (flagControl.flagSet("SHORT_HOP") || flagControl.flagSet("JUMP") || flagControl.flagSet("DOUBLE_JUMP") || flagControl.flagSet("FALL") || flagControl.flagSet("DOUBLE_FALL"));
		}
		
		public function walkRight () : void
		{
			facing = FlxObject.RIGHT;
			this.flagControl.forceSetFlag("MOVING");
			
		}
		
		public function walkLeft () : void
		{
			facing = FlxObject.LEFT;
			this.flagControl.forceSetFlag("MOVING");
		}
		
		public function stopWalking () : void
		{
			this.flagControl.forceResetFlag("MOVING");
		}
		
		public function jump () : void
		{
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("LIGHT") || flagControl.flagSet("HEAVY") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			if (!onAir())
			{
				this.shortHopTimer = 0;
				this.jumpOrigin = this.y;
				this.velocity.y = - JUMP_SPEED;
				this.flagControl.setFlag ("JUMP");
			}
			else if (!(this.flagControl.flagSet("DOUBLE_JUMP") || this.flagControl.flagSet("DOUBLE_FALL")))
			{
				this.velocity.y = - JUMP_SPEED;
				flagControl.forceResetFlag ("FALL");
				flagControl.forceResetFlag ("JUMP");
				flagControl.forceResetFlag ("SHORT_HOP");
				this.flagControl.forceSetFlag ("DOUBLE_JUMP");
			}
		}
		
		public function shortHop () : void
		{
			if (!onShortHopWindow()  || flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("LIGHT") || flagControl.flagSet("HEAVY") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			this.velocity.y = - Math.sqrt(2 * (SHORT_HOP_HEIGHT - (this.jumpOrigin - this.y)) * GRAVITY);
			flagControl.forceResetFlag ("JUMP");
			this.flagControl.forceSetFlag ("SHORT_HOP");
		}
		
		public function block () : void
		{
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("LIGHT") || flagControl.flagSet("BLOCK") || flagControl.flagSet("HEAVY") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			flagControl.forceSetFlag("BLOCK");
			this.velocity.x = 0;
			this.velocity.y = 0;
			makeGraphic(50, 100, 0xff8822aa);
			hurtboxType = HurtboxType.BLOCK;
		}
		
		public function unblock () : void
		{
			flagControl.forceResetFlag("BLOCK");
			makeGraphic(50, 100, 0xffff9900);
			hurtboxType = HurtboxType.NORMAL;
		}
		
		public function light () : void
		{
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("HEAVY") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			var i : int;
			
			if (!flagControl.flagSet("LIGHT"))
			{
				
				for (i = 0; i < attacks[ControlConfig.ACTION_LIGHT].length; i++)
				{
					if (!attacks[ControlConfig.ACTION_LIGHT][i].hasPrevious())
					{
						facingHit = facing;
						currentAttack = attacks[ControlConfig.ACTION_LIGHT][i];
						currentAttack.activate();
						flagControl.forceSetFlag("LIGHT");
						this.velocity.x = 0;
						this.velocity.y = 0;
						maxVelocity.y = JUMP_SPEED / 10;
						break;
					}
				}				
			}
			else
			{
				for (i = 0; i < attacks[ControlConfig.ACTION_LIGHT].length; i++)
				{
					if (currentAttack.canLink(attacks[ControlConfig.ACTION_LIGHT][i]))
					{
						facingHit = facing;
						currentAttack.interrupt();
						currentAttack = attacks[ControlConfig.ACTION_LIGHT][i];
						currentAttack.activate();
						break;
					}
				}
				
			}
		}
		
		public function heavy (direction : String) : void
		{
			
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("HEAVY") || flagControl.flagSet("LIGHT") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			facingHit = facing;
			
			for (var i : int = 0; i < attacks[ControlConfig.ACTION_HEAVY].length; i++)
			{
				if (attacks[ControlConfig.ACTION_HEAVY][i].isDirection(direction))
				{
					currentAttack = attacks[ControlConfig.ACTION_HEAVY][i];
					currentAttack.activate();
					flagControl.forceSetFlag("HEAVY");
					this.velocity.x = 0;
					this.velocity.y = 0;
					maxVelocity.y = JUMP_SPEED / 10;
					
					if (onAir() && direction == Attack.DOWN)
					{
						velocity.y = maxVelocity.y = 2 * JUMP_SPEED;
					}
					
				}
			}
		}
		
		public function projectile () : void
		{
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("HEAVY") || flagControl.flagSet("LIGHT") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("PROJECTILE_LOCK") || flagControl.flagSet("TAUNT")) return;
			
			var proj : Projectile = new Projectile (facing, this);
			
			proj.x = x + width / 2 - proj.width / 2 + velocity.x * FlxG.elapsed;
			proj.y = y +height / 2 - proj.height / 2 - height / 6 + velocity.y * FlxG.elapsed;
			
			flagControl.forceSetFlag("PROJECTILE_LOCK");
			FlxG.state.add (proj);
		}
		
		public function dash () : void
		{
			if (!(flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH_BLOCKED") || flagControl.flagSet("DASH_COOLDOWN") || flagControl.flagSet("BLOCK") || flagControl.flagSet("LIGHT") || flagControl.flagSet("TAUNT")))
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
				hurtboxType = HurtboxType.PROJECTILE_ONLY;
			}
		}
		
		public function taunt () : void
		{
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("TAUNT") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("HEAVY") || flagControl.flagSet("LIGHT") || flagControl.flagSet("THROWING_PROJECTILE")) return;
			
			flagControl.setFlag("TAUNT");
			makeGraphic(50, 100, 0xff00ff00);
			hurtboxType = HurtboxType.MELEE_ONLY;
		}
		
		public function stopTaunt () : void
		{
			if (flagControl.flagSet("TAUNT"))
			{
				flagControl.forceResetFlag("TAUNT");
				makeGraphic(50, 100, 0xffff9900);
				hurtboxType = HurtboxType.NORMAL;
			}
		}
		
		public function expression () : void
		{
			
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("HEAVY") || flagControl.flagSet("LIGHT") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			flagControl.forceResetFlag("BLOCK");
			facingHit = facing;
			
			for (var i : int = 0; i < attacks[ControlConfig.ACTION_EXPRESSION].length; i++)
			{
				if (attacks[ControlConfig.ACTION_EXPRESSION][i].specialLevelNeeded(Math.floor(specialLevel)))
				{
					currentAttack = attacks[ControlConfig.ACTION_EXPRESSION][i];
					currentAttack.activate();
					flagControl.forceSetFlag("EXPRESSION");
					this.velocity.x = 0;
					this.velocity.y = 0;
					maxVelocity.y = JUMP_SPEED / 10;
				}
			}
		}
		
		/* INTERFACE IOrigin */
		
		public function getX():Number 
		{
			return x + width / 2;
		}
		
		public function getY():Number 
		{
			return y + height / 2;
		}
		
		public function facingLeft():Boolean
		{
			return facingHit == FlxObject.LEFT;
		}
		
		public function facingRight():Boolean
		{
			return facingHit == FlxObject.RIGHT;
		}
		
		/* INTERFACE IThrower */
		
		public function freeLock():void 
		{
			flagControl.forceResetFlag("PROJECTILE_LOCK");
		}
		
		private function interruptDash () : void
		{
			endDash();
			flagControl.forceResetFlag("DASH");
		}
		
		private function endDash () : void
		{
			acceleration.y = GRAVITY;
			this.acceleration.x = 0;
			this.velocity.x = 0;
			makeGraphic(50, 100, 0xffff9900);
			hurtboxType = HurtboxType.NORMAL;
		}
		
		private function onShortHopWindow () : Boolean
		{
			return (flagControl.flagSet("JUMP") && shortHopTimer < SHORT_HOP_THRESHOLD);
		}
		
		public static function hitboxCollision (player : Character, hB : Hitbox) : void
		{
			if (player.flagControl.flagSet("HITSTUN") || player.flagControl.flagSet("KNOCKBACK")) return;
			
			var directionX : int = (player.getX() - hB.attacker.getX()) / Math.abs(player.getX() - hB.attacker.getX());
			var directionY : int = hB.knockbackY / Math.abs(hB.knockbackY);
			
			switch (player.hurtboxType)
			{
				case HurtboxType.NORMAL:
					player.flagControl.forceSetFlag("HIT_STUN");
					player.flagControl.forceSetFlag("KNOCKBACK");
					player.hitStunTimer = hB.hitStun;
					player.velocity.x = directionX * hB.knockbackX;
					player.velocity.y = hB.knockbackY;
					player.maxVelocity.y = Math.abs(hB.knockbackY);
					player.acceleration.x = - directionX * hB.knockbackX / hB.knockbackTime * 1000;
					player.acceleration.y = directionY * hB.knockbackY / hB.knockbackTime * 1000;
					player.knockbackTimer = hB.knockbackTime;
					break;
				case HurtboxType.MELEE_ONLY:
					break;
				case HurtboxType.PROJECTILE_ONLY:
					break;
				case HurtboxType.BLOCK:
					break;
				case HurtboxType.IMUNE:
					break;
			}
		}
	}
}