package  
{
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author fabio
	 */
	public class Projectile extends FlxSprite implements IOrigin
	{
		
		private var hitbox : Hitbox;
		private var direction : Hitbox;
		private var owner : IThrower;
		private static const PROJECTILE_SPEED : int = 1000;
		
		public function Projectile(direction : int, owner : IThrower) 
		{
			hitbox = Hitbox.loadHitbox("projectile", this);
			FlxG.state.add (hitbox);
			this.width = hitbox.width;
			this.height = hitbox.height;
			this.owner = owner;
			makeGraphic (width, height, 0x00000000); 
			hitbox.makeGraphic (width, height, 0xffea9999); 
			
			if (direction == FlxObject.LEFT)
			{
				velocity.x = -PROJECTILE_SPEED;
			}
			else
			{
				velocity.x = PROJECTILE_SPEED;
			}
		}
		
		override public function destroy():void 
		{
			super.destroy();
			FlxG.state.remove(this);
			FlxG.state.remove(hitbox);
			owner.freeLock();
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
			return false;
		}
		
		public function facingRight():Boolean 
		{
			return false;
		}
		
	}

}