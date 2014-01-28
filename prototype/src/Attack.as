package  
{
	import flash.globalization.LocaleID;
	import org.flixel.FlxBasic;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import utils.JSONLoader;
	/**
	 * ...
	 * @author fabio
	 */
	public class Attack extends FlxBasic
	{
		private var groundHitboxes : Vector.<Hitbox> = new Vector.<Hitbox> ();
		private var airHitboxes : Vector.<Hitbox> = new Vector.<Hitbox> ();
		private var hitboxes : Vector.<Hitbox> = new Vector.<Hitbox> ();
		
		//Timing properties
		private var timer : int;
		private var setup : int;
		private var stretch : int;
		private var accomodation : int;
		private var currentHitbox : int = -1;
		private var attacker : IOrigin;
		private var ended : Boolean = false;
		
		//Id and Combolink (id of the linkable move)
		private var _id : String;
		private var previous : String = null;
		
		private var direction : String;
		private var specialLevel : int;
		public static const NONE : String = "none";
		public static const SIDE : String = "side";
		public static const UP : String = "up";
		public static const DOWN : String = "down";
		
		public function Attack() 
		{
			active = false;
		}
		
		public static function loadAttack (attackData : Object, attacker : IOrigin) : Attack
		{
			var attack : Attack = new Attack;
			var groundHitboxes : Array = attackData.ground.hitboxes as Array;
			var airHitboxes : Array = attackData.air.hitboxes as Array;
			
			for (var i : int = 0; i < groundHitboxes.length; i++)
			{
				attack.groundHitboxes.push(Hitbox.loadHitbox(groundHitboxes[i], attacker));
			}
			
			for (i = 0; i < airHitboxes.length; i++)
			{
				attack.airHitboxes.push(Hitbox.loadHitbox(airHitboxes[i], attacker));
			}
			
			attack.setup = attackData.setup;
			attack.stretch = attackData.stretch;
			attack.accomodation = attackData.accomodation;
			attack._id = attackData.id;
			attack.previous = attackData.previous;
			attack.attacker = attacker;
			
			if (!attackData.direction) 
			{
				attack.direction = "none";
			}
			else
			{
				attack.direction = attackData.direction;
			}
			
			if (!attackData.specialLevel) 
			{
				attack.specialLevel = 0;
			}
			else
			{
				attack.specialLevel = attackData.specialLevel;
			}
			
			return attack;
		}
		
		override public function update():void 
		{
			timer += FlxG.elapsed * 1000;
			
			if (currentHitbox < 0)
			{
				if (timer >= setup)
				{
					currentHitbox = 0;
					timer = 0;
					FlxG.state.add (hitboxes[currentHitbox]);
					hitboxes[currentHitbox].update();
				}
			}
			
			else if (currentHitbox >= 0 && currentHitbox < hitboxes.length)
			{
				if (!(id == "heavy_attack_down" && attacker.onAir()))
				{
					if (hitboxes[currentHitbox].hasHitboxEnded(timer))
					{
						FlxG.state.remove (hitboxes[currentHitbox++]);
						if (currentHitbox < hitboxes.length)
						{
							FlxG.state.add (hitboxes[currentHitbox]);
							hitboxes[currentHitbox].update();
						}
						timer = 0;
					}
				}
			}
			
			else if (!ended)
			{
				if (timer >= stretch)
				{
					timer = 0;
					ended = true;
				}
			}
			
			else
			{
				if (timer >= accomodation)
				{
					interrupt();
				}
			}
			
			super.update();
		}
		
		public function activate () : void
		{
			if (attacker.onAir()) hitboxes = airHitboxes;
			else hitboxes = groundHitboxes;
			
			FlxG.state.add (this);
			active = true;
		}
		
		public function interrupt () : void
		{
			FlxG.state.remove(this);
			if (currentHitbox < hitboxes.length) FlxG.state.remove(hitboxes[currentHitbox]);
			timer = 0;
			currentHitbox = -1;
			active = false;
			ended = false;
		}
		
		public function hasPrevious () : Boolean
		{
			if (previous != null) return true;
			
			return false;
		}
		
		public function canLink (attack : Attack) : Boolean
		{
			if (attack.previous == id && isOnStretch()) return true;
			
			return false;
		}
		
		public function isDirection (direction : String) : Boolean
		{
			return (direction == this.direction);
		}
		
		public function specialLevelNeeded (specialLevel : int) : Boolean
		{
			return (specialLevel == this.specialLevel);
		}
		
		public function isOnSetup () : Boolean
		{
			return (timer < setup && currentHitbox < 0);
		}
		
		public function isOnStretch () : Boolean
		{
			return (currentHitbox >= hitboxes.length && timer < stretch && !ended);
		}
		
		public function isOnMeteorFall () : Boolean
		{
			return (id == "heavy_attack_down" && attacker.onAir());
		}
		
		public function isOnAccomodation () : Boolean
		{
			return (ended && timer < accomodation);
		}
		
		public function get id():String 
		{
			return _id;
		}
	}

}