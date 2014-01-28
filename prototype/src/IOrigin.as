package  
{
	/**
	 * ...
	 * @author fabio
	 */
	public interface IOrigin 
	{
		function getX () : Number;
		function getY () : Number;
		function facingLeft () : Boolean;
		function facingRight () : Boolean;
		function onAir () : Boolean;
	}
	
}