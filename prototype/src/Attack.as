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
		private var hitboxes : Vector.<Hitbox> = new Vector.<Hitbox> ();
		
		//Timing properties
		private var timer : int;
		private var setup : int;
		private var accomodation : int;
		private var currentHitbox : int = -1;
		
		//Id and Combolink (id of the linkable move)
		private var id : String;
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
			var arHitboxes : Array = attackData.hitboxes as Array;
			
			for (var i : int = 0; i < arHitboxes.length; i++)
			{
				attack.hitboxes.push(Hitbox.loadHitbox(arHitboxes[i], attacker));
			}
			
			attack.setup = attackData.setup;
			attack.accomodation = attackData.accomodation;
			attack.id = attackData.id;
			attack.previous = attackData.previous;
			
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
				}
			}
			
			else if (currentHitbox >= 0 && currentHitbox < hitboxes.length)
			{
				if (hitboxes[currentHitbox].hasHitboxEnded(timer))
				{
					FlxG.state.remove (hitboxes[currentHitbox++]);
					if (currentHitbox < hitboxes.length)
					{
						FlxG.state.add (hitboxes[currentHitbox]);
					}
					timer = 0;
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
		}
		
		public function hasPrevious () : Boolean
		{
			if (previous != null) return true;
			
			return false;
		}
		
		public function canLink (attack : Attack) : Boolean
		{
			if (attack.previous == id && isOnAccomodation()) return true;
			
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
		
		public function isOnAccomodation () : Boolean
		{
			return (currentHitbox >= hitboxes.length && timer < accomodation);
		}
	}

}