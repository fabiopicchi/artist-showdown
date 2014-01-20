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
		private var knockback : int;
		private var id : String;
		private var hitStun : int;
		private var duration : int;
		private var positionOffset : FlxPoint;
		private var attacker : IOrigin;
		
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
			hitbox.knockback = hitboxData.knockback;
			hitbox.hitStun = hitboxData.hitStun;
			hitbox.positionOffset = new FlxPoint (hitboxData.xOffset, hitboxData.yOffset);
			hitbox.attacker = attacker;
			hitbox.width = hitboxData.width;
			hitbox.height = hitboxData.height;
			hitbox.duration = hitboxData.duration;
			hitbox.id = hitboxData.id;
			
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
	}

}