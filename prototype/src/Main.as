package 
{
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.ui.GameInput;
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxGame;
	
	/**
	 * ...
	 * @author fabio
	 */
	public class Main extends FlxGame 
	{
		
		public function Main():void 
		{
			super (1366, 768, GameState);
		}
	}
	
}