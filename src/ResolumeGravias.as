/**
 * Copyright wonderwhyer ( http://wonderfl.net/user/wonderwhyer )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/9Byvt
 */

package {
	import flash.accessibility.Accessibility;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import resolume.asset.BatchassImage;
	import resolume.core.*;
	import resolume.display.Surface;
	import resolume.display.SurfaceContext;
	import resolume.plugin.Patch;
	
	import resolumeCom.*;
	import resolumeCom.events.*;
	import resolumeCom.parameters.*;

	[SWF(width='640', height='480', frameRate='30', backgroundColor='0x333333')] 
	final public class ResolumeGravias extends Patch implements ISurfaceGenerator 
	{		
		public const mouseForce:Number = 20;
		public const oscillationDumper:Number = 0.05;
		public const minimalMovement   :Number = 0.001;
		
		public var sourceBMP:BitmapData;
		public var pictureX:Number;
		public var pictureY:Number;
		public var view:BitmapData;
		public var bmp:Bitmap;
		
		public var matrix:Array;
		public var blurFilter:BlurFilter = new BlurFilter(3,3,1);
		public var trans:ColorMatrixFilter = new ColorMatrixFilter(matrix);
		public var ct:ColorTransform = new ColorTransform(1,1,1,0.95,0,0,0,0);
		
		
		public var allPoints:Array = new Array();
		public var activePoints:Array = [];
		public var c:uint=0;
		public var point:Point = new Point(0,0);
		public var currentPixel:int=0;
		
		public var mouseDown:Boolean = false;
		private var mx:int = 0;
		private var my:int = 0;
		private var resolume:Resolume = new Resolume();
		private var xSlider:FloatParameter = resolume.addFloatParameter("x Bang", 0.5);
		private var ySlider:FloatParameter = resolume.addFloatParameter("y Bang", 0.5);
		private var paramExplode:EventParameter = resolume.addEventParameter("Explode!");
		private var context:SurfaceContext;
		
		public function ResolumeGravias() {
			
			init();
			
			addChild(bmp);
			resolume.addParameterListener(parameterChanged);
		}
		//this method will be called everytime you change a paramater in Resolume
		public function parameterChanged(event:ChangeEvent): void
		{
			if(event.object == this.paramExplode) 
			{
				if (mouseDown) mouseDown=false else mouseDown=true;
			}				
			else if(event.object == this.xSlider) 
			{
				mx = Math.round(this.xSlider.getValue() * 640);
			}
			else if(event.object == this.ySlider) 
			{
				my = Math.round(this.ySlider.getValue() * 480);
			}
		}		
		
		override public function initialize(layer:IDisplayLayer, context:SurfaceContext):int {
			
			
			return super.initialize(layer, context);
		}		
		private function init():void
		{
			sourceBMP = new BatchassImage();
			pictureX = (stage.stageWidth-sourceBMP.width)/2;
			pictureY = (stage.stageHeight-sourceBMP.height)/2;
			matrix = new Array();
			matrix = matrix.concat([1, 0, 0, 0, 0]);// red
			matrix = matrix.concat([0, 1, 0, 0, 0]);// green
			matrix = matrix.concat([0, 0, 1, 0, 0]);// blue
			matrix = matrix.concat([0, 0, 0, 1, -50]);// alpha
			
			view = new BitmapData(stage.stageWidth,stage.stageHeight,true,0);
			bmp = new Bitmap(view);
			
			createPoints();
			stage.addEventListener(Event.ENTER_FRAME,frame,false,0,true);
			
		}
		public function update(time:Number):void {}
		
		final public function getTotalTime():int {
			return 0;
		}
		private function frame(evt:Event):void {
			view.lock();
			
			//adding new 30 points to active points list
			var pointsCreated:int=0;
			while(pointsCreated<30 && currentPixel<allPoints.length){
				pointsCreated++;
				var pixel:dPixel = allPoints[currentPixel];
				pixel.x=pixel.cx+Math.random()*110-55;
				pixel.y=pixel.cy+Math.random()*110-55;
				pixel.dx=0;
				pixel.dy=0;
				pixel.h=1;
				activePoints.push(pixel);
				currentPixel++;
			}
			
			
			view.applyFilter(view,view.rect,point,blurFilter);
			view.colorTransform(view.rect,ct);
			
			
			for (var i:int=0; i<activePoints.length; i++) {
				
				pixel =dPixel(activePoints[int(i)]);
				
				//var pp:Point = new Point(pixel.x-bmp.mouseX,pixel.y-bmp.mouseY);//vector from mouse to this pixel
				var pp:Point = new Point(pixel.x-mx,pixel.y-my);//vector from mouse to this pixel
				
				var l:Number=1 / pp.length;
				
				//now normalized to length of 1
				pp.x*=l;
				pp.y*=l;
				
				l=20*l;
				
				//pushing pixel from mouse based on distance
				if(mouseDown){
					pixel.dx+=pp.x*l;
					pixel.dy+=pp.y*l;
				}
				
				//calculating how far pixel is from place where it should be, momentum of pixel is included, also acceleration of pixel towards its place
				var ddx:Number = (pixel.cx-pixel.x-pixel.dx)*0.05;
				var ddy:Number = (pixel.cy-pixel.y-pixel.dy)*0.05;
				
				var dd:Number = (Math.abs(ddx)+Math.abs(ddy))*0.03;
				
				//h is how "hot" pixel is, nasicly how far it is from place where it should be
				pixel.h+=dd;
				pixel.h*=0.98;
				pixel.h=Math.min(1,pixel.h);
				
				//moving pixel
				pixel.dx+=ddx;
				pixel.dy+=ddy;
				
				pixel.x+=pixel.dx;
				pixel.y+=pixel.dy;
				
				if(Math.abs(pixel.dx)<0.001)
					pixel.x = pixel.cx;
				if(Math.abs(pixel.dy)<0.001)
					pixel.y = pixel.cy;
				
				
				
				//drawing pixel interpolating color between what it should be and yellow
				view.setPixel32(pixel.x,pixel.y,InterpolateColor(pixel.color,0xFF352b5c,pixel.h));
			}
			
			view.unlock();
		}
		public function render(context:SurfaceContext, surface:Surface):void {
			surface.draw(view, null, null, null, null, true);			
		}        
		
		private function createPoints():void {
			for (var iy:int=0; iy<sourceBMP.height; iy++) {
				for (var ix:int=0; ix<sourceBMP.width; ix++) {
					var col:uint = sourceBMP.getPixel32(ix,iy);
					if ((col>>>24)>50) {
						allPoints.push(new dPixel(ix+pictureX,iy+pictureY,ix+pictureX,iy+pictureY,0,0,0,col));
					}
				}
			}
		}
		
		
		private function restart(evt:Event):void {
			activePoints.splice(0);
			currentPixel=0;
		}
		
	}
}
import flash.geom.ColorTransform;
class dPixel{
	public var x:Number;
	public var y:Number;
	public var cx:Number;
	public var cy:Number;
	public var dx:Number;
	public var dy:Number;
	public var h:Number;
	public var color:uint;
	public function dPixel(x:Number,y:Number,cx:Number,cy:Number,dx:Number,dy:Number,h:Number,color:uint){
		this.x=x;
		this.y=y;
		this.cx=cx;
		this.cy=cy;
		this.dx=dx;
		this.dy=dy;
		this.h=h;
		this.color=color;
	}
}
function InterpolateColor(StartColor:uint, EndColor:uint, TransitionPercent1:Number):uint
{
	var TransitionPercent2:Number = (1 - TransitionPercent1);
	
	//SC:StartColor EC:EndColor IC:InterpolateColor
	var SC1:uint = StartColor >> 24 & 0xFF;
	var SC2:uint = StartColor >> 16 & 0xFF;
	var SC3:uint = StartColor >> 8 & 0xFF;
	var SC4:uint = StartColor & 0xFF;
	
	var EC1:uint = EndColor >> 24 & 0xFF;
	var EC2:uint = EndColor >> 16 & 0xFF;
	var EC3:uint = EndColor >> 8 & 0xFF;
	var EC4:uint = EndColor & 0xFF;
	
	var IC1:uint = SC1 * TransitionPercent2 + EC1 * TransitionPercent1;
	var IC2:uint = SC2 * TransitionPercent2 + EC2 * TransitionPercent1;
	var IC3:uint = SC3 * TransitionPercent2 + EC3 * TransitionPercent1;
	var IC4:uint = SC4 * TransitionPercent2 + EC4 * TransitionPercent1;
	
	var IC:uint = IC1 << 24 | IC2 << 16 | IC3 << 8 | IC4;
	return IC;
}

