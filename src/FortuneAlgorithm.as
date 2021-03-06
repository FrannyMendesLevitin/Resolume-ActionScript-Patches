/**
 * Copyright szisoq ( http://wonderfl.net/user/szisoq )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/574d
 */

// forked from h_sakurai's forked from: è??é?Ÿãƒœãƒ?ãƒŽã??å??ï??Fortune's algorithmï??
// forked from fumix's è??é?Ÿãƒœãƒ?ãƒŽã??å??ï??Fortune's algorithmï??
/**
 * è??é?Ÿãƒœãƒ?ãƒŽã??ã??ãƒ?ã??ãƒªã?ºãƒ?
 * å?ƒãƒ?ã??
 * Fortune's algorithm - Wikipedia, the free encyclopedia
 * http://en.wikipedia.org/wiki/Fortune's_algorithm
 * Controul > Speedy Voronoi diagrams in as3/flash
 * http://blog.controul.com/2009/05/speedy-voronoi-diagrams-in-as3flash/
 * ä?Šè??blogã??asã??ã??ã??ã??ã??ã??(Fortuneã??ãƒ?ã??)ã??
 * å??ç??ãƒ?ã??ãƒƒã??ã??ã??ã??ã?ªã??ã??ã??èª?ã??è??èª?ã??ã??ã??ã??ã??ã??ã??ã??
 *
 * æ??ç??ã??800ç??åº?ã??ã??ã??ã??ã??ã?Œã??ã??å??ã??å?šã??ã??ã??ã??ã??ã??ã??ã??
 * fullscreenã??ã??ã?Šæ??ã??ã??ã??ã?Ÿã??ã??ã??ã??ï??é??ã??ã??ã??ï??
 * 
 * æ??æœ?èªžã??è??æ??ï??PDFï??
 * http://atom.is.ocha.ac.jp/~kanenko/KOUGI/CompGeo/cpgeob.pdf
 * http://i-health.u-aizu.ac.jp/CompuGeo/2008/handouts/chapter4/Chapter4H.pdf
 */
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
//	import com.flashdynamix.utils.SWFProfiler;
	
	[SWF(backgroundColor="#000000", frameRate="30", width="465", height="465")]    
	
	public class FortuneAlgorithm extends Sprite {
		
		//ã??ãƒ?ãƒ?ãƒ?ã??
		private var _canvas : Sprite;
		//background
		private var _background:BitmapData;
		//voronoiæ??ç??æ??
		private const Q : uint = 800;
		//voronoiä?œå??ç??ã??ã??ãƒ?ã??
		private var fortune : Fortune;
		//voronoiæ??ç??(ãƒ?ãƒ?ãƒ?ã??ã??ãƒ?çš?ã?ª?)
		private var points : Vector.<Number2>;
		private var _first : Number2;
		
		private var stageWidth : int;
		private var stageHeight : int;
		
		public function FortuneAlgorithm() {
			addEventListener(Event.ADDED_TO_STAGE, _initialize);
		}
		
		/**
		 * å??æœŸåŒ?
		 */
		private function _initialize(event : Event) : void {
			var i : uint,old : Number2,point : Number2;
			removeEventListener(Event.ADDED_TO_STAGE, _initialize);
			//SWFProfiler.init(this);
			//ã??ãƒ?ãƒ?ã??è??å?š
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
			
			//èƒŒæ??ã??ãƒ?ãƒ?
			_background = new BitmapData(stageWidth , stageHeight, false, 0x0);
			addChild(new Bitmap(_background));
			
			//ã??ãƒ?ãƒ?ãƒ?ã??è??å?š
			_canvas = new Sprite();
			_canvas.x = 0;
			_canvas.y = 0;
			addChild(_canvas);
			
			//voronoiæ??ç??ç?Ÿæ??
			points = new Vector.<Number2>();
			for(i = 0;i < Q;i++) {
				point = new Number2();
				point.x = stageWidth * Math.random();
				point.y = stageHeight * Math.random();
				//å??æ??ç??ã??é?Ÿåº?
				point.vx = Math.random() * 0.4 - 0.2;
				point.vy = Math.random() * 0.4 - 0.2;
				points.push(point);
			}
			//voronoiæ??ç??ãƒªãƒ?ã??ãƒªã??ãƒ?ç?Ÿæ??
			for(i = 0;i < Q;i++) {
				point = points[i];
				if (_first == null) {
					old = _first = point;
				} else {
					old.next = point;
					old = point;
				}
			}
			
			//ãƒœãƒ?ãƒŽã??ä?œå??ç??ã??ãƒ?ã??
			fortune = new Fortune();
			
			addEventListener(Event.ENTER_FRAME, _updateHandler);
		}
		
		//ã??ãƒƒãƒ?ãƒ?ãƒ?ãƒ?
		private function _updateHandler(event : Event) : void {
			_interaction();
			_draw();
		}
		
		//ã??ãƒ?ã??ãƒ?ã??ã??ãƒ?ãƒ?
		private function _interaction() : void {
			var point : Number2 = _first;
			
			do {
				//æ??ç??ã??ä??ç??ã??æ??æ??
				point.x += point.vx;
				point.y += point.vy;
				point.y+=3;
				if(point.x > stageWidth) {
					point.x -= stageWidth;
				}else if(point.x < 0) {
					point.x += stageWidth;
				}
				if(point.y > stageHeight) {
					point.y -= stageHeight;
				}else if(point.y < 0) {
					point.y += stageHeight;
				}
			} while (point = point.next);
			
			//æ??æ??ã??ã?Ÿæ??ç??ã??voronoiä?œå??ç??ã??ãƒ?ã??ã??å??ã?Œã??
			fortune.points = points;
		}
		
		//æ??ç??
		private function _draw() : void {
			//ãƒœãƒ?ãƒŽã??é??ç??
			var segments : Vector.<Number2> = fortune.compute(),
				i : uint,start : Number2,end : Number2,
				point : Number2 = _first,
				g : Graphics = _canvas.graphics;
			
			//ãƒœãƒ?ãƒŽã??è?ºã??æ??ç??
			g.clear();
			g.lineStyle(1, 0xFFFFFF, 0.25);
			for(i = 0;i < segments.length;i += 2) {
				start = segments[i];
				end = segments[i + 1];
				if(start.y < -100 || end.y < -100) continue;
				if(start.y > 500 || end.y > 500) continue;
				
				g.moveTo(223+(start.x-223)*300/(500-start.y), 100+15000/(500-start.y));
				g.lineTo(223+(end.x-223)*300/(500-end.y), 100+15000/(500-end.y));
				
			}
			//ãƒœãƒ?ãƒŽã??æ??ç??ã??æ??ç??
			g.lineStyle(1, 0xFF0000, 0.5);
			do {
				//    g.drawCircle(point.x, point.y, 1);
			} while (point = point.next);
		}
	}
}

/*
* Fortune's algorithm
* http://blog.controul.com/2009/05/speedy-voronoi-diagrams-in-as3flash/
* ã?ªãƒªã??ãƒŠãƒ?ã??ä?Šè??blogã??ã??ãƒ?ã??ãƒ?ãƒ?ãƒ?ãƒ?ã??ã??è??ã??ã??ã??ã??ã??ï??
* ã??ã??ã??ã?Šã??ã??ã??å??ç??ã??ã??ã??ã?ªã??ã??ã??ã?ªã??ã??ã??ã??ã??ã??ã??ã??ã?ªã?Ÿã??è??èª?ã??ï??
*/

class Fortune {
	
	//    voronoiå??ã??æ??ç??ã??ã?ªã??ç??ç??
	public var points : Vector.<Number2>;
	
	//    Bounding box.
	private var x0 : Number;
	
	//    Root of the frontline and next arc to be removed.
	private var root : Arc;
	private var next : Arc;
	
	//    Reusable objects and pools.
	private var o : Number2 = new Number2;
	private static var arcPoolD : Arc;
	
	
	
	/**
	 * ä?Žã??ã??ã?Œã?Ÿæ??ç??ã??ã??voronoié??ç??ç??ã??è??ã??ã??ã??.
	 * @return A vector or vertices in pairs, describing segments ready for drawing.
	 */
	
	public function compute() : Vector.<Number2> {
		//    Clear the output.
		var out : Vector.<Number2> = new Vector.<Number2>,
			len : int = 0;
		
		//    Clear the state.
		root = null;
		next = null;
		
		//    Read the pools.
		var key : * ,
			arcPool : Arc = arcPoolD;
		
		//    Vars:
		var i : int,
		j : int,
		w : Number,
		x : Number,
		
		a : Arc,
		b : Arc,
		
		z : Number2,
		
		p : Number2 = points[ 0 ],
			points : Vector.<Number2> = points,
			n : int = points.length,
			
			//    Circle events check inlined.
			circle : Boolean,
			eventX : Number,
			
			c : Arc,
			d : Arc,
			
			aa : Number2,
			bb : Number2,
			cc : Number2,
			
			A : Number,
			B : Number,
			C : Number,
			D : Number,
			E : Number,
			F : Number,
			G : Number;
		
		
		//    ä?Žã??ã??ã?Œã?Ÿæ??ç??ã??xè??ã??ã??ãƒ?ãƒ?
		/////    Currently insertion sort. Quicksort?
		w = points[ 0 ].x;
		
		for ( i = 1;i < n;i++ ) {
			p = points[ i ];
			
			//    Insertion sort.
			x = p.x;
			if ( x < w ) {
				j = i;
				while ( ( j > 0 ) && ( points[ int(j - 1) ].x > x ) ) {
					points[ j ] = points[ int(j - 1) ];
					j--;
				}
				points[ j ] = p;
			}
			else
				w = x;
		}
		
		//    Get x bounds.
		x0 = points[ 0 ].x;
		
		//    Process.
		i = 0;
		p = points[ 0 ];
		x = p.x;
		
		//å¤šåˆ†æ¯ç‚¹ç¾¤ã§ãƒ«ãƒ¼ãƒ—
		for ( ;; ) {
			
			//    Check circle events. /////////////////////////
			if ( a ) {
				//    Check for arc a.
				circle = false;
				
				if ( a.prev && a.next ) {
					aa = a.prev.p,
						bb = a.p,
						cc = a.next.p;
					
					//    Algorithm from O'Rourke 2ed p. 189.
					A = bb.x - aa.x,
						B = bb.y - aa.y,
						C = cc.x - aa.x,
						D = cc.y - aa.y;
					
					//    Check that bc is a "right turn" from ab.
					if ( A * D - C * B <= 0 ) {
						E = A * ( aa.x + bb.x ) + B * ( aa.y + bb.y ),
							F = C * ( aa.x + cc.x ) + D * ( aa.y + cc.y ),
							G = 2 * ( A * ( cc.y - bb.y ) - B * ( cc.x - bb.x ) );
						
						//    Check for colinearity.
						//    if ( G > 0.000000001 || G < -0.000000001 )
						if ( G ) {
							//    Point o is the center of the circle.
							o.x = ( D * E - B * F ) / G;
							o.y = ( A * F - C * E ) / G;
							
							//    o.x plus radius equals max x coordinate.
							A = aa.x - o.x;
							B = aa.y - o.y;
							eventX = o.x + Math.sqrt(A * A + B * B);
							
							if ( eventX >= w ) circle = true;
						}
					}
				}
				
				//    Remove from queue.
				if ( a.right )
					a.right.left = a.left;
				if ( a.left )
					a.left.right = a.right;
				if ( a == next )
					next = a.right;
				
				//    Record event.
				if ( circle ) {
					a.endX = eventX;
					if ( a.endP ) {
						a.endP.x = o.x;
						a.endP.y = o.y;
					} else {
						a.endP = o;
						o = new Number2;
					}
					
					d = next;
					if ( !d ) {
						next = a;
					}
					else for ( ;; ) {
						if ( d.endX >= eventX ) {
							a.left = d.left;
							if ( d.left ) d.left.right = a;
							if ( next == d ) next = a;
							a.right = d;
							d.left = a;
							break;
						}
						if ( !d.right ) {
							d.right = a;
							a.left = d;
							a.right = null;
							break;
						}
						d = d.right;
					}
				} else {
					a.endX = NaN;
					a.endP = null;
					a.left = null;
					a.right = null;
				}
				
				//    Push next arc to check.
				if ( b ) {
					a = b;
					b = null;
					continue;
				}
				if ( c ) {
					a = c;
					c = null;
					continue;
				}
				a = null;
			}
			
			//////////////////////////////////////////////////
			//
			if ( next && next.endX <= x ) {
				//
				//    Handle next circle event.
				
				//    Get the next event from the queue. ///////////
				a = next;
				next = a.right;
				if ( next )
					next.left = null;
				a.right = null;
				
				//    Remove the associated arc from the front.
				if ( a.prev ) {
					a.prev.next = a.next;
					a.prev.v1 = a.endP;
				}
				if ( a.next ) {
					a.next.prev = a.prev;
					a.next.v0 = a.endP;
				}
				
				if ( a.v0 ) {
					out[ len++ ] = a.v0;
					a.v0 = null;
					out[ len++ ] = a.endP;
				}
				if ( a.v1 ) {
					out[ len++ ] = a.v1;
					a.v1 = null;
					out[ len++ ] = a.endP;
				}
				
				//    Keep a ref for collection.
				d = a;
				
				//    Recheck circle events on either side of p:
				w = a.endX;
				if ( a.prev ) {
					b = a.prev;
					a = a.next;
				} else {
					a = a.next;
					b = null;
				}
				c = null;
				
				//    Collect.
				d.v0 = null;
				d.v1 = null;
				d.p = null;
				d.prev = null;
				d.endX = NaN;
				d.endP = null;
				d.next = arcPool;
				arcPool = d;
				
				//////////////////////////////////////////////////
				//
			} else {
				if ( !p ) break;
				
				//
				//    Handle next site event. //////////////////////
				
				if ( !root ) {
					if ( arcPool ) {
						root = arcPool;
						arcPool = arcPool.next;
						root.next = null;
					}
					else
						root = new Arc;
					root.p = p;
				} else {
					
					z = new Number2;
					
					//    Find the first arc with a point below p,
					//    and start searching for the intersection around it.
					a = root.next;
					if ( a ) {
						while ( a.next ) {
							a = a.next;
							if ( a.p.y >= p.y ) break;
						}
						
						//    Find the intersecting curve.
						intersection(a.prev.p, a.p, p.x, z);
						if ( z.y <= p.y ) {
							
							//    Search for the intersection to the south of i.
							while ( a.next ) {
								a = a.next;
								intersection(a.prev.p, a.p, p.x, z);
								if ( z.y >= p.y ) {
									a = a.prev;
									break;
								}
							}
						} else {
							//    Search for the intersection above i.
							a = a.prev;
							while ( a.prev ) {
								a = a.prev;
								intersection(a.p, a.next.p, p.x, z);
								if ( z.y <= p.y ) {
									a = a.next;
									break;
								}
							}
						}
					}
					else
						a = root;
					
					//    New parabola will intersect arc a. Duplicate a.
					if ( a.next ) {
						if ( arcPool ) {
							b = arcPool;
							arcPool = arcPool.next;
							b.next = null;
						}
						else
							b = new Arc;
						b.p = a.p;
						b.prev = a;
						b.next = a.next;
						a.next.prev = b;
						a.next = b;
					} else {
						if ( arcPool ) {
							b = arcPool;
							arcPool = arcPool.next;
							b.next = null;
						}
						else
							b = new Arc;
						b.p = a.p;
						b.prev = a;
						a.next = b;
					}
					a.next.v1 = a.v1;
					
					//    Find the point of intersection.
					z.y = p.y;
					z.x = ( a.p.x * a.p.x + ( a.p.y - p.y ) * ( a.p.y - p.y ) - p.x * p.x ) / ( 2 * a.p.x - 2 * p.x );
					
					//    Add p between i and i->next.
					if ( arcPool ) {
						b = arcPool;
						arcPool = arcPool.next;
						b.next = null;
					}
					else
						b = new Arc;
					
					b.p = p;
					b.prev = a;
					b.next = a.next;
					
					a.next.prev = b;
					a.next = b;
					
					a = a.next;    //    Now a points to the new arc.
					
					a.prev.v1 = z;
					a.next.v0 = z;
					a.v0 = z;
					a.v1 = z;
					
					//    Check for new circle events around the new arc:
					b = a.next;
					a = a.prev;
					c = null;
					w = p.x;
				}
				
				//////////////////////////////////////////////////
				//
				
				i++;
				if ( i >= n ) {
					p = null;
					x = Number.MAX_VALUE;
				} else {
					p = points[ i ];
					x = p.x;
				}
			}
		}
		
		//    Store the pools.
		arcPoolD = arcPool;
		
		//
		//
		//    Return the result ready for drawing.
		return out;
	}
	
	
	
	/**
	 * Where do two parabolas intersect?
	 * @param    p0 A Number2 object describing the site for the first parabola.
	 * @param    p1 A Number2 object describing the site for the second parabola.
	 * @param    l The location of the sweep line.
	 * @param    res A Number2 object in which to store the intersection.
	 * @return The point of intersection.
	 */
	public function intersection( p0 : Number2, p1 : Number2, l : Number, res : Number2 ) : Number2 {
		var p : Number2 = p0,
			ll : Number = l * l;
		
		if ( p0.x == p1.x )
			res.y = ( p0.y + p1.y ) / 2;
		else if ( p1.x == l )
			res.y = p1.y;
		else if ( p0.x == l ) {
			res.y = p0.y;
			p = p1;
		} else {
			//    Use the quadratic formula.
			var z0 : Number = 0.5 / ( p0.x - l ); // 1 / ( 2*(p0.x - l) )
			var z1 : Number = 0.5 / ( p1.x - l ); // 1 / ( 2*(p1.x - l) )
			
			var a : Number = z0 - z1;
			var b : Number = -2 * ( p0.y * z0 - p1.y * z1 );
			var c : Number = ( p0.y * p0.y + p0.x * p0.x - ll ) * z0 - ( p1.y * p1.y + p1.x * p1.x - ll ) * z1;
			
			res.y = ( -b - Math.sqrt(b * b - 4 * a * c) ) / ( 2 * a );
		}
		
		//    Plug back into one of the parabola equations.
		res.x = ( p.x * p.x + ( p.y - res.y ) * ( p.y - res.y ) - ll ) / ( 2 * p.x - 2 * l );
		return res;
	}
}
class Arc {
	
	public var p : Number2;
	public var next : Arc;
	public var prev : Arc;
	public var v0 : Number2;
	public var v1 : Number2;
	
	//    Circle event data :
	public var left : Arc;
	public var right : Arc;
	public var endX : Number;
	public var endP : Number2;
}

class Number2 {
	public var x : Number;
	public var y : Number;
	//é€Ÿåº¦
	public var vx : Number;
	public var vy : Number;
	
	public var next : Number2;
}
