
import hxd.Key;

class Pacman extends Entity {
   
    static var BASESPEED : Float = 0.15;
    var xr : Float;
    var yr : Float;

    var xx : Float;
    var yy : Float;

    var startX : Int;
    var startY : Int;

    public var dx : Float;
    public var dy : Float;

    public var freezeFrames : Float = 0;

    public var isDead = false;
    public var isDying = false;

    var s2d : h2d.Scene;
    var bmp : h2d.Bitmap;
    var posBmp : h2d.Bitmap;
    
    var animWR : h2d.Anim;
    var animWL : h2d.Anim;
    var animWU : h2d.Anim;
    var animWD : h2d.Anim;
    public var animDie : h2d.Anim;
    var allAnims : Array<h2d.Anim> = [];
    public var currentAnim : h2d.Anim;

    public var unhide : Bool = false;

    public static var pacmanWidth : Int = 16;
    public static var pacmanHeight : Int = 16;
    public static var animSpeed : Float = 15;
    public static var animSpeedDead : Float = 7;
    public static var previousAnimSpeed : Float = 0;
    public var fleeModeTimer : Float = -1;
    var tileMap : Array<Int> = [];
    public var repeatDeadSound : Bool = false;

    var spriteAtlas : h2d.Tile = hxd.Res.spriteAtlas.toTile();
    var entitiesAtlas : h2d.Tile = hxd.Res.entitiesAtlas.toTile();
    
    public var deathSound2 = null; 
    

    override public function new(x,y,tileMap:Array<Int>,s2d) {
        super(s2d);
        //create pacman base sprite
        var frame0 : h2d.Tile = entitiesAtlas.sub(32,0,pacmanWidth,pacmanHeight);
        
        //create walk right animation
        var frame1WR: h2d.Tile = entitiesAtlas.sub(0,0,pacmanWidth,pacmanHeight);
        var frame2WR : h2d.Tile = entitiesAtlas.sub(16,0,pacmanWidth,pacmanHeight);

        animWR = new h2d.Anim([frame0,frame1WR,frame2WR],this);
        animWR.loop = true;
        allAnims.push(animWR);

        //create walk right animation
        var frame1WL: h2d.Tile = entitiesAtlas.sub(0,16,pacmanWidth,pacmanHeight);
        var frame2WL : h2d.Tile = entitiesAtlas.sub(16,16,pacmanWidth,pacmanHeight);

        animWL = new h2d.Anim([frame0,frame1WL,frame2WL],this);
        animWL.loop = true;
        allAnims.push(animWL);

        //create walk up animation
        var frame1WU: h2d.Tile = entitiesAtlas.sub(0,32,pacmanWidth,pacmanHeight);
        var frame2WU : h2d.Tile = entitiesAtlas.sub(16,32,pacmanWidth,pacmanHeight);

        animWU = new h2d.Anim([frame0,frame1WU,frame2WU],this);
        animWU.loop = true;
        allAnims.push(animWU);

        //create walk down animation
        var frame1WD: h2d.Tile = entitiesAtlas.sub(0,48,pacmanWidth,pacmanHeight);
        var frame2WD : h2d.Tile = entitiesAtlas.sub(16,48,pacmanWidth,pacmanHeight);

        animWD = new h2d.Anim([frame0,frame1WD,frame2WD],this);
        animWD.loop = true;
        allAnims.push(animWD);

        //create dieing animation
        var frame1Die : h2d.Tile = entitiesAtlas.sub(16*3,0,pacmanWidth,pacmanHeight);
        var frame2Die : h2d.Tile = entitiesAtlas.sub(16*4,0,pacmanWidth,pacmanHeight);
        var frame3Die : h2d.Tile = entitiesAtlas.sub(16*5,0,pacmanWidth,pacmanHeight);
        var frame4Die : h2d.Tile = entitiesAtlas.sub(16*6,0,pacmanWidth,pacmanHeight);
        var frame5Die : h2d.Tile = entitiesAtlas.sub(16*7,0,pacmanWidth,pacmanHeight);
        var frame6Die : h2d.Tile = entitiesAtlas.sub(16*8,0,pacmanWidth,pacmanHeight);
        var frame7Die : h2d.Tile = entitiesAtlas.sub(16*9,0,pacmanWidth,pacmanHeight);
        var frame8Die : h2d.Tile = entitiesAtlas.sub(16*10,0,pacmanWidth,pacmanHeight);
        var frame9Die : h2d.Tile = entitiesAtlas.sub(16*11,0,pacmanWidth,pacmanHeight);
        var frame10Die : h2d.Tile = entitiesAtlas.sub(16*12,0,pacmanWidth,pacmanHeight);
        var frame11Die : h2d.Tile = entitiesAtlas.sub(16*13,0,pacmanWidth,pacmanHeight);

        animDie = new h2d.Anim([frame0,frame1Die,frame2Die,frame3Die,frame4Die,frame5Die,frame6Die,frame7Die,frame8Die,frame9Die,frame10Die,frame11Die],this);
        animDie.loop = false;
        animDie.onAnimEnd = function(){
            visible = false;
            #if hl
           // deathSound2.play(false);
            #end
            repeatDeadSound = true;
        }
        allAnims.push(animDie);
        
        this.startX = x+4;
        this.startY = y-12;
        this.tileMap = tileMap.copy();
        
        //set anchor point to middle, for all frames in all animations
        for (animation in allAnims)
        {
            for (frame in animation.frames)
            {
                frame.dx = -4;
                frame.dy = -4;
            }
        }
        
        //create debug bitmap
        var positionTile : h2d.Tile = h2d.Tile.fromColor(0xff0000,8,8,0.3);
        posBmp = new h2d.Bitmap(positionTile,this);
        posBmp.visible = false;
        init();

    }
    
    public function init()
    {
        // set position
        setCoordinates(startX,startY);

        //set starting speed & animation;
        dx = -BASESPEED;
        dy = 0;
        currentAnim = null;
        currentAnim = setAnimation(animWL);
        visible = true;
        isDead = false;
        isDying = false;
        freezeFrames = 0;
    }

    public function setAnimation(animation : h2d.Anim, ?aSpeed : Float = 15) : h2d.Anim
    {
        if (this.currentAnim == animation) return animation;

        for (anim in allAnims)
        {
            anim.visible = false;
            anim.currentFrame = 0;
            anim.pause = true;
        }

        animation.visible = true;
        animation.speed = aSpeed;
        animation.play(animation.frames);
        previousAnimSpeed = animation.speed;
        return animation;
    }

    public function setCoordinates(_x:Int,_y:Int){
        this.x = _x;
        this.y = _y;
        xx = _x;
        yy = _y;
        cx = Std.int(xx/8);
        cy = Std.int(yy/8);
        xr = (xx-cx*8)/8;
        yr = (yy-cy*8)/8;
    }

    public function hasCollision(cx:Int,cy:Int) : Bool
    {
        return (tileMap[cx+cy*28] != 78 && cx <= 27 && cx >= 0);
    }

    // on each frame
    public function freeze(t:Float){
        freezeFrames = Math.max(freezeFrames,t);
        currentAnim.speed = 0;
    }



    override public function update(dt: Float) {
        if (isDead)
        {
            
        }
        //do not update if this is frozen
        freezeFrames -= dt;
        if (freezeFrames > 0) 
        {
            return;
        }

        fleeModeTimer -= dt;


        if (unhide) 
        {
            visible = true;
            unhide = false;
        }
        currentAnim.speed = previousAnimSpeed;
         
        //check inputs and update speed 
        if (Key.isDown(Key.LEFT) && !hasCollision(cx-1,cy) && yr < 0.2){
            dx = -BASESPEED;
            dy = 0;
            yr = 0;
            currentAnim = setAnimation(animWL);
        }
        if (Key.isDown(Key.RIGHT) && !hasCollision(cx+1,cy) && yr < 0.2){
            dx = BASESPEED;
            dy = 0;
            yr = 0;
            currentAnim = setAnimation(animWR);
        }
        if (Key.isDown(Key.DOWN) && !hasCollision(cx,cy+1) && xr < 0.2){
            dy = BASESPEED;
            dx = 0;
            xr = 0;
            currentAnim = setAnimation(animWD);
        }
        if (Key.isDown(Key.UP) && !hasCollision(cx,cy-1) && xr < 0.2){
            dy = -BASESPEED;
            dx = 0;
            xr = 0;
            currentAnim = setAnimation(animWU);
        }
        
        if (dx == 0 && dy == 0 && currentAnim != animDie)
        {
            currentAnim.speed = 0;
            currentAnim.currentFrame = Math.max(currentAnim.currentFrame,1);
        }

        //x movement
        xr += dx;
        
        //wrap around
        var wrap : Bool = false;
        if (cx + 1 > 27 && dx > 0 ) {
            cx -= 28;
            xr = 0;
            dx = BASESPEED;
            wrap = true;
        } 
        if (cx - 1 <= -1 && dx < 0 ) {
            cx += 27;
            dx = -BASESPEED;
            wrap = true;
        }
        
        if (!wrap) //only check for collisions when not wrapping around the lateral edges
        {
            //check collisions
            if( hasCollision(cx+1,cy) && xr >= 0.1 ) {
                xr = 0;
                dx = 0;
            }
            if( hasCollision(cx-1,cy) && xr <= 0) {
                xr = 0;
                dx = 0;
            }

            while ( xr>1 ) { xr --; cx ++;}
            while ( xr<0 ) { xr ++; cx --;}

            //y movement
            yr += dy;

            if( hasCollision(cx,cy+1) && yr >= 0.1 ) {
                yr = 0;
                dy = 0;
            }
            if( hasCollision(cx,cy-1) && yr <= 0 ) {
                yr = 0;
                dy = 0;
            }

            while ( yr>1 ) { yr --; cy ++;}
            while ( yr<0 ) { yr ++; cy --;}
        }

        //update cell position
        xx = Std.int( (cx+xr) * 8 );
        yy = Std.int( (cy+yr) * 8 );

        //update pacman sprite position
        x = xx;
        y = yy;

      
    }
}