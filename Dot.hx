
class Dot extends Entity {
   
    var s2d : h2d.Scene;
    var bmp : h2d.Bitmap;
    public static var dotWidth : Int = 8;
    public static var dotHeight : Int = 8;
    public var collider : h2d.col.Bounds;
    public static var dots = new Array<Dot>();
    var spriteAtlas : h2d.Tile = hxd.Res.spriteAtlas.toTile();

    override public function new(x,y,s2d) {
        super(s2d);
        dots.push(this);

        // create the dot graphic tile
        var dotTile : h2d.Tile = spriteAtlas.sub(5*16,0,dotWidth,7);
        dotTile.dy = -8;
        // create a Bitmap object, which will display tile1
        // and will be added to our 2D scene (s2d)
        bmp = new h2d.Bitmap(dotTile,this);

        // set position
        this.x = x;
        this.y = y;

        cx = Std.int(this.x/8);
        cy = Std.int(this.y/8) - 1;
        
        //add to scene
        addChild(bmp);

    }

    // on each frame
    override public function update(dt: Float) {
        //
    }
}