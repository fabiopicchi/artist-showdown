package  
{
	import flash.globalization.LocaleID;
	import flash.utils.Dictionary;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxParticle;
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
		private static const PROJECTILE_THRESHOLD : int = 250;
		
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
		private var specialLevel : Number = 3;
		private var hurtboxType : int = HurtboxType.NORMAL;
		
		private var anims : Object = 
		{
			JUMP : [2, 3, true, 1],
			FALL : [4, 5, true, 1],
			DASH : [6, 7, true, 1],
			MOVING : [8, 19, true, 2],
			THROWING_PROJECTILE : [20, 23, true, 2],
			LIGHT : {
				light_attack_1 : [24, 27, false, 2],
				light_attack_1_accomodation : [78, 79, false, 1],
				light_attack_2 : [28, 31, false, 2],
				light_attack_2_accomodation : [78, 79, false, 1],
				light_attack_3 : [32, 37, false, 1],
				light_attack_3_accomodation : [78, 79, false, 1],
				light_attack_1_air : [80, 83, false, 2],
				light_attack_1_air_accomodation : [78, 79, false, 1],
				light_attack_2_air : [84, 87, false, 2],
				light_attack_2_air_accomodation : [78, 79, false, 1],
				light_attack_3_air : [88, 93, false, 1],
				light_attack_3_air_accomodation : [78, 79, false, 1]
			},
			HEAVY : {
				heavy_attack_side : [38, 49, false, 2],
				heavy_attack_side_accomodation : [50, 51, false, 1],
				heavy_attack_up : [52, 63, false, 2],
				heavy_attack_up_accomodation : [64, 65, false, 1],
				heavy_attack_down : [66, 77, false, 2],
				heavy_attack_down_accomodation : [78, 79, false, 1],
				heavy_attack_side_air : [94, 105, false, 2],
				heavy_attack_side_air_accomodation : [106, 107, false, 1],
				heavy_attack_up_air : [108, 119, false, 2],
				heavy_attack_up_air_accomodation : [120, 121, false, 1],
				heavy_attack_down_air_charge : [122, 125, false, 2],
				heavy_attack_down_air_fall : [126, 126, false, 2],
				heavy_attack_down_air_hit : [127, 133, false, 2],
				heavy_attack_down_air_accomodation : [134, 135, false, 1]
			},
			EXPRESSION : {
				expression_1 : [136, 161, false, 1],
				expression_2 : [162, 187, false, 1],
				expression_3 : [188, 214, false, 1]
			},
		TAUNT : [215, 226, true, 1],
			BLOCK : [230, 230, false, 1]
		};
		private var arFrames : Array = [];
		
		public var emitter:FlxEmitter;
		
		public function Character() 
		{
			for (var i : int = 1; i <= 230; i++)
			{
				arFrames.push(FlxG.addBitmap(Assets[getFramecode(i)], true, true));
			}
			
			
			emitter = new FlxEmitter(0, 0 + HEIGHT); //x and y of the emitter
			emitter.setYSpeed(-100, -150);
			emitter.setXSpeed( -150, 150);
			emitter.gravity = 120;
			
			for (i = 0; i < 40; i++)
			{
				var particle:FlxParticle = new FlxParticle ();
				particle.exists = false;
				particle.makeGraphic(7, 7, 0xff000000);
				emitter.add(particle);
			}
		
			
			super(50, 50);
			loadGraphic(Assets.F_0001, false, true);
			
			//makeGraphic(50, 100, 0xffff9900);
			offset.x = 51;
			offset.y = 123;
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
			
			for (i = 0; i < attacksJSON.length; i++)
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
				else if (this.projectileTimer >= PROJECTILE_THRESHOLD / 2 && !flagControl.flagSet("PROJECTILE_LOCK"))
				{					
					var proj : Projectile = new Projectile (facing, this);
					
					proj.x = x + width / 2 - proj.width / 2 + velocity.x * FlxG.elapsed;
					proj.y = y + height / 2 - proj.height / 2 - height / 6 + velocity.y * FlxG.elapsed;
					
					FlxG.state.add (proj);
					
					flagControl.forceSetFlag("PROJECTILE_LOCK");
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
			
			if (flagControl.flagSet("LIGHT"))
			{
				if (!currentAttack.active)
				{
					currentAttack = null;
					flagControl.forceResetFlag("LIGHT");
					maxVelocity.y = JUMP_SPEED;
					_codeSuffix = "";
				}
			}
			
			if (flagControl.flagSet("HEAVY"))
			{				
				if (onAir() && currentAttack.isDirection(Attack.DOWN))
				{
					if (currentAttack.isOnSetup())
					{
						velocity.y = 0;
					}
					else if (currentAttack.isOnMeteorFall())
					{
						velocity.y = maxVelocity.y = 2 * JUMP_SPEED;
					}
				}
				
				if (!currentAttack.active)
				{
					currentAttack = null;
					flagControl.forceResetFlag("HEAVY");
					maxVelocity.y = JUMP_SPEED;
					_codeSuffix = "";
				}
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
					if (currentAttack.isOnSetup())
					{
						//makeGraphic(WIDTH, HEIGHT, 0xff00ff00);
						if (hurtboxType != HurtboxType.MELEE_ONLY) hurtboxType = HurtboxType.MELEE_ONLY;
					}
					else if (currentAttack.isOnAccomodation())
					{
						//makeGraphic(WIDTH, HEIGHT, 0xffff9900);
						if (hurtboxType != HurtboxType.NORMAL) hurtboxType = HurtboxType.NORMAL;
					}
					else
					{
						//makeGraphic(WIDTH, HEIGHT, 0xff00ffff);
						if (hurtboxType != HurtboxType.IMUNE) hurtboxType = HurtboxType.IMUNE;
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
		
		private var _currentFrame : int = 1;
		private var _lastFrame : int = 0;
		private var _codeSuffix : String = "";
		private var _animationTimer : int = 0;
		private var FPS : int = 15;
		
		override public function draw():void 
		{
			if (_currentFrame != _lastFrame)
			{
				_pixels = arFrames[_currentFrame - 1];
				calcFrame();
				_lastFrame = _currentFrame;
			}
			width = WIDTH;
			height = HEIGHT;
			if (facing == FlxObject.LEFT)
			{
				offset.x = 152;
			}
			else if (facing == FlxObject.RIGHT)
			{
				offset.x = 51;
			}
			emitter.x = x + WIDTH / 2;
			emitter.y = y + HEIGHT - 15;
			offset.y = 123;
			
			super.draw();
			
			if (flagControl.flagSet("DASH"))
			{
				cycleAnimation("DASH");
			}
			
			else if (flagControl.flagSet("THROWING_PROJECTILE"))
			{
				cycleAnimation("THROWING_PROJECTILE");
			}
			
			else if (flagControl.flagSet("LIGHT") || flagControl.flagSet("HEAVY") || flagControl.flagSet("EXPRESSION"))
			{
				if (currentAttack.isOnAccomodation() && _codeSuffix.indexOf("_accomodation") < 0)
				{
					_codeSuffix += "_accomodation";
				}
				
				if (currentAttack.active)
				{
					if (flagControl.flagSet("LIGHT"))
						cycleAnimation("LIGHT", currentAttack.id + _codeSuffix);					
					
					if (flagControl.flagSet("HEAVY"))
					{
						if (currentAttack.isDirection(Attack.DOWN) && _codeSuffix.indexOf("_air") >= 0)
						{
							if (currentAttack.isOnSetup())
							{
								cycleAnimation("HEAVY", currentAttack.id + _codeSuffix + "_charge");
							}
							else if (currentAttack.isOnMeteorFall())
							{
								cycleAnimation("HEAVY", currentAttack.id + _codeSuffix + "_fall");
							}
							else if (!currentAttack.isOnAccomodation())
							{
								cycleAnimation("HEAVY", currentAttack.id + _codeSuffix + "_hit");
							}
							else
							{
								cycleAnimation("HEAVY", currentAttack.id + _codeSuffix);
							}
						}
						else
						{
							cycleAnimation("HEAVY", currentAttack.id + _codeSuffix);
						}
					}
					
					if (flagControl.flagSet("EXPRESSION"))
					{
						cycleAnimation("EXPRESSION", currentAttack.id);
					}
				}
			}
			
			else if (flagControl.flagSet("BLOCK"))
			{
				cycleAnimation("BLOCK");
			}
			
			else if (flagControl.flagSet("TAUNT"))
			{
				cycleAnimation("TAUNT");
			}
			
			else if (flagControl.flagSet("MOVING") && canMove() && !onAir())
			{
				cycleAnimation("MOVING");
			}
			
			else if (flagControl.flagSet("JUMP") || flagControl.flagSet("DOUBLE_JUMP") || flagControl.flagSet("SHORT_HOP"))
			{
				cycleAnimation("JUMP");
			}
			
			else if (flagControl.flagSet("FALL") || flagControl.flagSet("DOUBLE_FALL"))
			{
				cycleAnimation("FALL");
			}
			
			else
			{
				_currentFrame = 1;
			}
			
			flagControl.update();
		}
		
		private function cycleAnimation (code : String, subCode : String = "") : void
		{
			_animationTimer += FlxG.elapsed * 1000;
			
			if (anims[code] is Array)
			{
				if (_animationTimer >= Math.floor(1 / (FPS * anims[code][3]) * 1000))
				{
					_currentFrame++;
					_animationTimer = 0;
				}
				if (_currentFrame > anims[code][1])
				{
					if (anims[code][2])
						_currentFrame = anims[code][0];
					else
						_currentFrame = anims[code][1];
				}
				if (_currentFrame < anims[code][0])
				{
					_currentFrame = anims[code][0];
				}
			}
			else
			{
				if (_animationTimer >= Math.floor(1 / (FPS * anims[code][subCode][3]) * 1000))
				{
					_currentFrame++;
					_animationTimer = 0;
				}
				if (_currentFrame > anims[code][subCode][1])
				{
					if (anims[code][subCode][2])
						_currentFrame = anims[code][subCode][0];
					else
						_currentFrame = anims[code][subCode][1];
				}
				if (_currentFrame < anims[code][subCode][0])
				{
					_currentFrame = anims[code][subCode][0];
				}
			}
		}
		
		private function getFramecode (n : int) : String
		{
			return "F_0" + (n / 100 < 1 ? "0" : "") + (n / 10 < 1 ? "0" : "") + n.toString();
		}
		
		private function canMove(): Boolean 
		{
			return (!(flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("LIGHT") || flagControl.flagSet("HEAVY") || flagControl.flagSet("TAUNT")));
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
				emitter.start(true, 0.5, 0.1, 20);
			}
		}
		
		public function shortHop () : void
		{
			if (!onShortHopWindow()  || flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("LIGHT") || flagControl.flagSet("HEAVY") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			if ((SHORT_HOP_HEIGHT - (this.jumpOrigin - this.y)) >= 0)
			{
				this.velocity.y = - Math.sqrt(2 * (SHORT_HOP_HEIGHT - (this.jumpOrigin - this.y)) * GRAVITY);
				flagControl.forceResetFlag ("JUMP");
				this.flagControl.forceSetFlag ("SHORT_HOP");
			}
		}
		
		public function block () : void
		{
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("LIGHT") || flagControl.flagSet("BLOCK") || flagControl.flagSet("HEAVY") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			flagControl.forceSetFlag("BLOCK");
			this.velocity.x = 0;
			this.velocity.y = 0;
			//makeGraphic(50, 100, 0xff8822aa);
			hurtboxType = HurtboxType.BLOCK;
		}
		
		public function unblock () : void
		{
			flagControl.forceResetFlag("BLOCK");
			//makeGraphic(50, 100, 0xffff9900);
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
						_codeSuffix = "";
						if (onAir())
						{
							_codeSuffix = "_air";
						}
						_currentFrame = anims["LIGHT"][currentAttack.id + _codeSuffix][0];
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
						_codeSuffix = "";
						if (onAir())
						{
							_codeSuffix = "_air";
						}
						_currentFrame = anims["LIGHT"][currentAttack.id + _codeSuffix][0];
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
 					_codeSuffix = "";
					if (onAir())
					{
						_codeSuffix = "_air";
						if (currentAttack.isDirection(Attack.DOWN))
						{
							_currentFrame = anims["HEAVY"][currentAttack.id + _codeSuffix + "_charge"][0];
						}
					}
					else
					{
						_currentFrame = anims["HEAVY"][currentAttack.id + _codeSuffix][0];
					}
				}
			}
		}
		
		public function projectile () : void
		{
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("HEAVY") || flagControl.flagSet("LIGHT") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("PROJECTILE_LOCK") || flagControl.flagSet("TAUNT")) return;
			
			projectileTimer = 0;
			flagControl.forceSetFlag("THROWING_PROJECTILE");
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
				//makeGraphic(50, 100, 0xffffff00);
				hurtboxType = HurtboxType.PROJECTILE_ONLY;
			}
		}
		
		public function taunt () : void
		{
			if (flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("TAUNT") || flagControl.flagSet("DASH") || flagControl.flagSet("BLOCK") || flagControl.flagSet("HEAVY") || flagControl.flagSet("LIGHT") || flagControl.flagSet("THROWING_PROJECTILE")) return;
			
			flagControl.setFlag("TAUNT");
			//makeGraphic(50, 100, 0xff00ff00);
			hurtboxType = HurtboxType.MELEE_ONLY;
		}
		
		public function stopTaunt () : void
		{
			if (flagControl.flagSet("TAUNT"))
			{
				flagControl.forceResetFlag("TAUNT");
				//makeGraphic(50, 100, 0xffff9900);
				hurtboxType = HurtboxType.NORMAL;
			}
		}
		
		public function expression () : void
		{
			
			if (specialLevel < 1 || flagControl.flagSet("KNOCKBACK") || flagControl.flagSet("HIT_STUN") || flagControl.flagSet("EXPRESSION") || flagControl.flagSet("DASH") || flagControl.flagSet("HEAVY") || flagControl.flagSet("LIGHT") || flagControl.flagSet("THROWING_PROJECTILE") || flagControl.flagSet("TAUNT")) return;
			
			flagControl.forceResetFlag("BLOCK");
			facingHit = facing;
			_codeSuffix = "";
			
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
			_currentFrame = anims["EXPRESSION"][currentAttack.id + _codeSuffix][0];
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
			//makeGraphic(50, 100, 0xffff9900);
			hurtboxType = HurtboxType.NORMAL;
		}
		
		private function onShortHopWindow () : Boolean
		{
			return (flagControl.flagSet("JUMP") && shortHopTimer < SHORT_HOP_THRESHOLD);
		}
		
		public static function hitboxCollision (player : Character, hB : Hitbox) : void
		{
			if (player.flagControl.flagSet("HITSTUN") || player.flagControl.flagSet("KNOCKBACK")) return;
			
			if (hB.attacker == player || (hB.attacker is Projectile && (hB.attacker as Projectile).owner == player)) return;
			
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