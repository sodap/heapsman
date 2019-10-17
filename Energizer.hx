
class Energizer extends Entity {
   
    var s2d : h2d.Scene;
    var bmp : h2d.Bitmap;
    public static var energizerWidth : Int = 8;
    public static var energizerHeight : Int = 8;
    public var collider : h2d.col.Bounds;
    public static var energizers = new Array<Energizer>();
    var spriteAtlas : h2d.Tile = hxd.Res.spriteAtlas.toTile();
    var elapsed : Int;

    override public function new(x,y,s2d) {
        super(s2d);
        elapsed = 0;
        energizers.push(this);
        // create the dot graphic tile
        var energizerTile : h2d.Tile = spriteAtlas.sub(5*16,8,energizerWidth,energizerHeight);
        
        // create a Bitmap object, which will display tile1
        // and will be added to our 2D scene (s2d)
        bmp = new h2d.Bitmap(energizerTile,this);
        
        // set position
        this.x = x;
        this.y = y - energizerHeight;
        
        cx = Std.int(x/8);
        cy = Std.int(y/8) - 1;

        //add to scene
        addChild(bmp);

    }

    // on each frame
    override public function update(dt: Float) {
        if (elapsed % 8 == 0)
        {
            visible = !visible;
        }
        elapsed ++;
        //
    }
    public function destroy(){
        
    }
}