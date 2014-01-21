package  
{
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import utils.JSONLoader;
	/**
	 * ...
	 * @author fabio
	 */
	public class Hitbox extends FlxSprite
	{
		private var _knockbackX : int;
		private var _knockbackY : int;
		private var _knockbackTime : int;
		private var id : String;
		private var _hitStun : int;
		private var duration : int;
		private var positionOffset : FlxPoint;
		private var _attacker : IOrigin;
		private var _type : int;
		
		private static var hitboxJSON : Array;
		
		public function Hitbox() 
		{
			
		}
		
		override public function update():void 
		{
			super.update();
			
			if (attacker.facingRight())
			{
				this.x = attacker.getX() + positionOffset.x - width / 2;
			}
			else
			{
				this.x = attacker.getX() - positionOffset.x - width / 2;
			}
			this.y = attacker.getY() + positionOffset.y - height / 2;
		}
		
		public static function loadHitbox (id : String, attacker : IOrigin) : Hitbox
		{
			if (!hitboxJSON)
			{
				hitboxJSON = JSONLoader.loadFile("hitboxes.json") as Array;
			}
			
			var hitboxData : Object;
			for (var i : int = 0; i < hitboxJSON.length; i++)
			{
				if ((hitboxData = hitboxJSON[i]).id == id) break;
			}
			
			var hitbox : Hitbox = new Hitbox;
			hitbox._knockbackX = hitboxData.knockbackX;
			hitbox._knockbackY = hitboxData.knockbackY;
			hitbox._knockbackTime = hitboxData.knockbackTime;
			hitbox._hitStun = hitboxData.hitStun;
			hitbox.positionOffset = new FlxPoint (hitboxData.xOffset, hitboxData.yOffset);
			hitbox._attacker = attacker;
			hitbox.width = hitboxData.width;
			hitbox.height = hitboxData.height;
			hitbox.duration = hitboxData.duration;
			hitbox.id = hitboxData.id;
			
			if (hitboxData.id == "projectile")
			{
				hitbox._type = HitboxType.PROJECTILE;
			}
			else
			{
				hitbox._type = HitboxType.MELEE;
			}
			
			if (id.indexOf("_weak") >= 0)
			{
				hitbox.makeGraphic(hitbox.width, hitbox.height, 0xffff00ff);
			}
			else
			{
				hitbox.makeGraphic(hitbox.width, hitbox.height, 0xffff0000);
			}
			
			return hitbox;
		}
		
		public function hasHitboxEnded (currentTime : int) : Boolean
		{
			return currentTime >= duration;
		}
		
		public function get hitStun():int 
		{
			return _hitStun;
		}
		
		public function get type():int 
		{
			return _type;
		}
		
		public function get knockbackX():int 
		{
			return _knockbackX;
		}
		
		public function get knockbackY():int 
		{
			return _knockbackY;
		}
		
		public function get knockbackTime():int 
		{
			return _knockbackTime;
		}
		
		public function get attacker():IOrigin 
		{
			return _attacker;
		}
	}

}