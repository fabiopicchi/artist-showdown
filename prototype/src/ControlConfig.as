package  
{
	import org.flixel.FlxG;
	import utils.JSONLoader;
	/**
	 * ...
	 * @author fabio
	 */
	public class ControlConfig 
	{
		
		public static var ACTION_MOVE_LEFT : String = "ACTION_MOVE_LEFT";
		public static var ACTION_UP : String = "ACTION_UP";
		public static var ACTION_MOVE_RIGHT : String = "ACTION_MOVE_RIGHT";
		public static var ACTION_DOWN : String = "ACTION_DOWN";
		public static var ACTION_DASH : String = "ACTION_DASH";
		public static var ACTION_JUMP : String = "ACTION_JUMP";
		public static var ACTION_LIGHT : String = "ACTION_LIGHT";
		public static var ACTION_HEAVY : String = "ACTION_HEAVY";
		public static var ACTION_BLOCK : String = "ACTION_BLOCK";
		public static var ACTION_PROJECTILE : String = "ACTION_PROJECTILE";
		public static var ACTION_TAUNT_1 : String = "ACTION_TAUNT_1";
		public static var ACTION_TAUNT_2 : String = "ACTION_TAUNT_2";
		public static var ACTION_EXPRESSION : String = "ACTION_EXPRESSION";
		
		private static var controlData : Object;
		
		public static function loadData () : void
		{
			controlData = JSONLoader.loadFile("controlConfig.json");
		}
		
		public function ControlConfig() 
		{
			
		}
		
		public static function actionActive (id : int, code : String) : Boolean
		{
			for (var i : int = 0; i < controlData[id][code].length; i++)
			{
				if (!FlxG.keys[controlData[id][code][i]]) return false;
			}
			return true;
		}
		
		public static function actionStarted (id : int, code : String) : Boolean
		{
			for (var i : int = 0; i < controlData[id][code].length; i++)
			{
				if (!FlxG.keys.justPressed(controlData[id][code][i]))
				{
					return false;
				}
			}
			
			return true;
		}
		
		public static function actionReleased (id : int, code : String) : Boolean
		{
			for (var i : int = 0; i < controlData[id][code].length; i++)
			{
				if (!FlxG.keys.justReleased(controlData[id][code][i])) return false;
			}
			
			return true;
		}
		
	}

}