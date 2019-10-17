enum GhostState{
    Chasing;
    Scattering;
    Fleeing;
    Dead;
    Returning;
    Exiting;
    Waiting;
}

class Ghost extends Entity {
    static var BASESPEED : Float = 0.12;
    static var FLEESPEED : Float = 0.075;
    static var RETURNSPEED : Float = 0.2;
    static var WAITSPEED : Float = 0.06;
    static var WRAPSPEED : Float = 0.065;
    var currentSpeed = BASESPEED;
    public var dotMax : Int = 0;
    public var dotCount : Int = 0;
    public var dotCountStart : Int = 0;
    var xr : Float;
    var yr : Float;

    var xx : Float;
    var yy : Float;

    var startX : Int;
    var startY : Int;

    var scatterX : Int = 0;
    var scatterY : Int = 0;
    static var penEntranceX : Int = 13;
    static var penEntranceY : Int = 14;
    static var penCenterX : Int = 13;
    static var penCenterY : Int = 17;
    var penX : Int = 13;
    var penY : Int = 17;

    var chaseX : Int = 0;
    var chaseY : Int = 0;



    var dx : Float;
    var dy : Float;

    public var freezeFrames : Float = 0;
    public var penTime : Float = 0;
    public var fleeTime : Float = 0;
    var penAllowed : Bool = false;

    public var unhide : Bool = false;


    public var currentState : GhostState = Chasing;

    var s2d : h2d.Scene;
    var bmp : h2d.Bitmap;
    var posBmp : h2d.Bitmap;
    
    var animWR : h2d.Anim;
    var animWL : h2d.Anim;
    var animWU : h2d.Anim;
    var animWD : h2d.Anim;
    var animDR : h2d.Anim;
    var animDL : h2d.Anim;
    var animDU : h2d.Anim;
    var animDD : h2d.Anim;
    var animFlee : h2d.Anim;
    var animFleeEnding : h2d.Anim;
    var animDie : h2d.Anim;
    var allAnims : Array<h2d.Anim> = [];
    var currentAnim : h2d.Anim;

    var tUP : Int = 0;
    var tDOWN : Int = 1;
    var tLEFT : Int = 2;
    var tRIGHT : Int = 3;
    var turn : Int = 0;

    var gx : Int;
    var gy : Int;

    public static var ghostWidth : Int = 16;
    public static var ghostHeight : Int = 16;
    public static var animSpeed : Float = 8;
    public static var previousAnimSpeed : Float = 0;
    var tileMap : Array<Int> = [];
    var navMap : Array<Int> = [];
    var currentTile : Int;
    public static var navNode : Int = 9;
    public static var restrictedNavNode : Int = 29;
    public static var wrapNavNode : Int = 39;

    public static var navPen : Int = 19;

    var spriteAtlas : h2d.Tile = hxd.Res.spriteAtlas.toTile();
    var entitiesAtlas : h2d.Tile = hxd.Res.entitiesAtlas.toTile();

    override public function new(x,y,tileMap:Array<Int>,navMap:Array<Int>,s2d) {
        gx = 0;
        gy = 0;
        super(s2d);
        name = "Ghost";
        //create walk right animation
        var frame1WR: h2d.Tile = entitiesAtlas.sub(0,16*4,ghostWidth,ghostHeight);
        var frame2WR : h2d.Tile = entitiesAtlas.sub(16,16*4,ghostWidth,ghostHeight);

        animWR = new h2d.Anim([frame1WR,frame2WR],this);
        animWR.loop = true;
        allAnims.push(animWR);

        //create walk right animation
        var frame1WL: h2d.Tile = entitiesAtlas.sub(32,16*4,ghostWidth,ghostHeight);
        var frame2WL : h2d.Tile = entitiesAtlas.sub(32+16,16*4,ghostWidth,ghostHeight);

        animWL = new h2d.Anim([frame1WL,frame2WL],this);
        animWL.loop = true;
        allAnims.push(animWL);

        //create walk up animation
        var frame1WU: h2d.Tile = entitiesAtlas.sub(64,16*4,ghostWidth,ghostHeight);
        var frame2WU : h2d.Tile = entitiesAtlas.sub(64+16,16*4,ghostWidth,ghostHeight);

        animWU = new h2d.Anim([frame1WU,frame2WU],this);
        animWU.loop = true;
        allAnims.push(animWU);

        //create walk down animation
        var frame1WD: h2d.Tile = entitiesAtlas.sub(96,16*4,ghostWidth,ghostHeight);
        var frame2WD : h2d.Tile = entitiesAtlas.sub(96+16,16*4,ghostWidth,ghostHeight);

        animWD = new h2d.Anim([frame1WD,frame2WD],this);
        animWD.loop = true;
        allAnims.push(animWD);

        //create dead right animation
        var frame1DR: h2d.Tile = entitiesAtlas.sub(8*16,16*5,ghostWidth,ghostHeight);

        animDR = new h2d.Anim([frame1DR],this);
        animDR.loop = false;
        allAnims.push(animDR);

        //create dead left animation
        var frame1DL: h2d.Tile = entitiesAtlas.sub(9*16,16*5,ghostWidth,ghostHeight);

        animDL = new h2d.Anim([frame1DL],this);
        animDL.loop = false;
        allAnims.push(animDL);
        
        //create dead up animation
        var frame1DU: h2d.Tile = entitiesAtlas.sub(10*16,16*5,ghostWidth,ghostHeight);

        animDU = new h2d.Anim([frame1DU],this);
        animDU.loop = false;
        allAnims.push(animDU);

        //create dead down animation
        var frame1DD: h2d.Tile = entitiesAtlas.sub(11*16,16*5,ghostWidth,ghostHeight);

        animDD = new h2d.Anim([frame1DD],this);
        animDD.loop = false;
        allAnims.push(animDD);

        //create flee animation
        var frame0Flee: h2d.Tile = entitiesAtlas.sub(8*16,16*4,ghostWidth,ghostHeight);
        var frame1Flee: h2d.Tile = entitiesAtlas.sub(9*16,16*4,ghostWidth,ghostHeight);

        animFlee = new h2d.Anim([frame0Flee,frame1Flee],this);
        animFlee.loop = true;
        allAnims.push(animFlee);

        //create flee ending animation
        var frame0FleeEnding: h2d.Tile = entitiesAtlas.sub(10*16,16*4,ghostWidth,ghostHeight);
        var frame1FleeEnding: h2d.Tile = entitiesAtlas.sub(11*16,16*4,ghostWidth,ghostHeight);

        animFleeEnding = new h2d.Anim([frame0Flee,frame1Flee,frame0FleeEnding,frame1FleeEnding],this);
        animFleeEnding.loop = true;
        allAnims.push(animFleeEnding);

        //create dieing animation
        var frame0Die : h2d.Tile = entitiesAtlas.sub(0,16*8,ghostWidth,ghostHeight);
        var frame1Die : h2d.Tile = entitiesAtlas.sub(16,16*8,ghostWidth,ghostHeight);
        var frame2Die : h2d.Tile = entitiesAtlas.sub(32,16*8,ghostWidth,ghostHeight);
        var frame3Die : h2d.Tile = entitiesAtlas.sub(48,16*8,ghostWidth,ghostHeight);

        animDie = new h2d.Anim([frame1Die,frame2Die,frame3Die],this);
        animDie.loop = false;
        allAnims.push(animDie);
        
        this.startX = x+4;
        this.startY = y-12;

        this.tileMap = tileMap.copy();
        this.navMap = navMap.copy();
        
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
        var positionTile : h2d.Tile = h2d.Tile.fromColor(0xffffff,8,8,0.5);
        posBmp = new h2d.Bitmap(positionTile,this);
        posBmp.visible = false;//true;
        init();

    }

    public function startInPen(dir : Int)
    {
        gx = penX;
        gy = penY;
        currentState = Waiting;
        dy = dir*currentSpeed;
        
        
        
        //-------------------------------------------//
        // /!\ for some reason this hack prevents 
        // ghosts spawning in pen from getting stuck
        //        DO NOT REMOVE THIS
            penTime = 4.81;
            //turn = tUP;
            currentState = Waiting;
        //-------------------------------------------//
    }

    public function init()
    {
        // set position
        setCoordinates(startX,startY);

        currentTile = Math.floor(x/8) + Math.floor(y/8) * 28;

        //set starting speed & animation;
        dx = -currentSpeed; //default to going left
        dy = 0; //default to not move vertically
        turn = -1;//tLEFT; //default to turning down
        currentAnim = null;
        currentAnim = setAnimation(animWL);
        visible = true;
        freezeFrames = 0;
    }

    public function setAnimation(animation : h2d.Anim) : h2d.Anim
    {
        if (this.currentAnim == animation) return animation;

        for (anim in allAnims)
        {
            anim.visible = false;
            anim.currentFrame = 0;
            anim.pause = true;
        }

        animation.visible = true;
        animation.speed = animSpeed;
        animation.play(animation.frames);
        previousAnimSpeed = animation.speed;
        return animation;
    }
    
    public function startFleeing(ft : Float){
        currentState = Fleeing;
        currentAnim = setAnimation(animFlee);
        fleeTime = ft;
    }

    public function startReturning(){
        currentState = Returning;
        if (turn == tUP) {
            currentAnim = setAnimation(animDU);
        }
        else if (turn == tDOWN){      
            currentAnim = setAnimation(animDD);
        }
        else if (turn == tLEFT) {
            currentAnim = setAnimation(animDL);
        }
        else if (turn == tRIGHT){
            currentAnim = setAnimation(animDR);
        }
    }


    public function setCoordinates(x:Int,y:Int){
        this.x = x;
        this.y = y;
        xx = x;
        yy = y;
        cx = Std.int(xx/8);
        cy = Std.int(yy/8);
        xr = (xx-cx*8)/8;
        yr = (yy-cy*8)/8;
    }

    public function hasCollision(cx:Int,cy:Int) : Bool
    {
        if (penAllowed)
        {
            return (tileMap[cx+cy*28] != 78 && cx <= 27 && cx >= 0 && tileMap[cx+cy*28] !=62);
        }
        else 
        {
            return (tileMap[cx+cy*28] != 78 && cx <= 27 && cx >= 0);
        }
    }

    public function distSqr(x1:Int,y1:Int,x2:Int,y2:Int) : Int
    {
        return (x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
    }

    public function isNode(cx:Int,cy:Int) : Bool
    {
        return(navMap[cx+cy*28] == navNode || navMap[cx+cy*28] == restrictedNavNode);
    }

    public function isRestrictedNode(cx:Int,cy:Int) : Bool
    {
        return(navMap[cx+cy*28] == restrictedNavNode);
    }

    public function isWrapNode(cx:Int,cy:Int) : Bool
    {
        return(navMap[cx+cy*28] == wrapNavNode);
    }

    public function isPen(cx:Int,cy:Int) : Bool
    {
        return(navMap[cx+cy*28] == navPen);
    }

    // on each frame
    public function freeze(t:Float){
        freezeFrames = t;
        currentAnim.speed = 0;
    }

    public function navigateTo(goalX : Int, goalY : Int) : Int
    {
        var nTurn = turn;
        var dist : Int = 999999999; //init distance to an impossibly long distance


        var adx : Int = 0;
        if (dx != 0) adx = Std.int(dx/Math.abs(dx));
        var ady : Int = 0;
        if (dy != 0) ady = Std.int(dy/Math.abs(dy));
        
        var nx : Int = cx + adx;
        var ny : Int = cy + ady;
        if(isNode(nx,ny))
        {
            // init distances to an impossibly long distance
            var dUP : Int = 999999; 
            var dDOWN : Int = 999999; 
            var dLEFT : Int = 999999;
            var dRIGHT : Int = 999999;
            var dDirections : Array<Int> = [];
            
            if (currentState == Fleeing){ //initialize distances to negative if ghost needs to get away from the goal
                dist = -1;
                dUP = -1;
                dDOWN = -1;
                dLEFT = -1;
                dRIGHT = -1;
            }

            // calculate distance from each direction to the goal          
            // only consider tiles without collisions and not requiring reversing directions
            if ( !hasCollision(nx,ny-1) && ady <= 0 && !isRestrictedNode(nx,ny) )
            {
                dUP = distSqr(nx,ny-1,goalX,goalY);
            }

            if ( !hasCollision(nx,ny+1) && ady >= 0 && !isRestrictedNode(nx,ny) ) 
            {
                dDOWN = distSqr(nx,ny+1,goalX,goalY);
            }
            
            if (!hasCollision(nx-1,ny) && adx <= 0)
            {
                dLEFT = distSqr(nx-1,ny,goalX,goalY);
            }

            if (!hasCollision(nx+1,ny) && adx >= 0)
            {
                dRIGHT = distSqr(nx+1,ny,goalX,goalY);
            }

            // compare distances and choose closest one (or furthest one if fleeing)
            dDirections = [dUP,dDOWN,dLEFT,dRIGHT];

            for (distance in dDirections)
            {
                if ( (distance >= 0 && (distance < dist)) || (distance >= 0 && (distance > dist) && currentState == Fleeing) )
                {
                    dist = distance;
                    nTurn = dDirections.indexOf(distance);
                }
            }

        }

        return nTurn;
    }

    public function moveAround() {
        //check inputs and update speed      
        if (turn == tLEFT && !hasCollision(cx-1,cy) && yr < 0.2){
            dx = -currentSpeed;
            dy = 0;
            yr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDL);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWL);
            }
        }
        if (turn == tRIGHT && !hasCollision(cx+1,cy) && yr < 0.2){
            dx = currentSpeed;
            dy = 0;
            yr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDR);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWR);
            }
        }
        if (turn == tDOWN && !hasCollision(cx,cy+1) && xr < 0.5){
            dy = currentSpeed;
            dx = 0;
            xr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDD);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWD);
            }
        }
        if (turn == tUP && !hasCollision(cx,cy-1) && xr < 0.5){
            dy = -currentSpeed;
            dx = 0;
            xr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDU);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWU);
            }
        }
    }

    public function exitPen() {
        gx = penCenterX;
        if (cx == gx)
        {
            xr = 0.5;
            gy = penEntranceY;
            penAllowed = true;
            dy = -BASESPEED;
            currentAnim = setAnimation(animWU);
            if(cy == gy)
            {
                yr = 0;
                currentState = Chasing;
                turn = tLEFT;
            }
        }
        else if (gx < cx)
        {
            gx = penEntranceX;
            dy = 0;
            yr = 0;
            dx = -BASESPEED;
            currentAnim = setAnimation(animWL);
        }
        else
        {
            gx = penEntranceX;
            dy = 0;
            yr = 0;
            dx = BASESPEED;
            currentAnim = setAnimation(animWR);
        }
    }

    public function waitInPen() {
        //check inputs and update speed      
        if (turn == tLEFT && !hasCollision(cx-1,cy) && yr < 0.2){
            dx = -currentSpeed;
            dy = 0;
            yr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDL);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWL);
            }
        }
        if (turn == tRIGHT && !hasCollision(cx+1,cy) && yr < 0.2){
            dx = currentSpeed;
            dy = 0;
            yr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDR);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWR);
            }
        }
        if (turn == tDOWN && !hasCollision(cx,cy+1) && xr < 0.5){
            dy = currentSpeed;
            dx = 0;
            xr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDD);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWD);
            }
        }
        if (turn == tUP && !hasCollision(cx,cy-1) && xr < 0.5){
            dy = -currentSpeed;
            dx = 0;
            xr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDU);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWU);
            }
        }
        gx = penX;
        if (cx == gx)
        {
            xr = 0.5;
            dx = 0;
        }
    }

    public function returnToPen() {
        gx = penEntranceX;
        gy = penEntranceY;
        //check inputs and update speed      
        if (turn == tLEFT && !hasCollision(cx-1,cy) && yr < 0.2){
            dx = -currentSpeed;
            dy = 0;
            yr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDL);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWL);
            }
        }
        if (turn == tRIGHT && !hasCollision(cx+1,cy) && yr < 0.2){
            dx = currentSpeed;
            dy = 0;
            yr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDR);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWR);
            }
        }
        if (turn == tDOWN && !hasCollision(cx,cy+1) && xr < 0.5){
            dy = currentSpeed;
            dx = 0;
            xr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDD);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWD);
            }
        }
        if (turn == tUP && !hasCollision(cx,cy-1) && xr < 0.5){
            dy = -currentSpeed;
            dx = 0;
            xr = 0;
            switch (currentState)
            {
                case Returning:
                    currentAnim = setAnimation(animDU);
                case Fleeing:
                    currentAnim = setAnimation(animFlee);
                default: 
                    currentAnim = setAnimation(animWU);
            }
        }
        if ( (cx == gx || cx == gx+1) && cy == gy)
        {
            if (cx == gx+1)
            {
                cx = gx;
            }
            xr = 0.5;
            dx = 0;
            dy = BASESPEED;
            gx = penX;
            gy = penY;
            penAllowed = true;
        }
    }

    override public function update(dt: Float) {
        
        //do not update if this is frozen
        freezeFrames -= dt;
        if (freezeFrames > 0) 
        {
            return;
        }
        if (unhide) 
        {
            visible = true;
            unhide = false;
        }
        //store current cell position
        var px : Int = Std.int(cx);
        var py : Int = Std.int(cy);  

        //reset anim speed if not frozen
        currentAnim.speed = previousAnimSpeed;

        switch (currentState)
        {
            case Returning:
                returnToPen();
            case Exiting:
                exitPen();
            case Waiting:
                waitInPen();
            default: 
                moveAround();
        }
        


        if(currentState == Waiting)//do this while waiting inside the pen
        {
            if (cx == gx)
            {
                if (hasCollision(cx,cy-1) && yr < 0.5){
                    dy = currentSpeed;
                    dx = 0;
                // turn = tDOWN;
                    currentAnim = setAnimation(animWD);
                }
                if (hasCollision(cx,cy+2) && yr > 0.5){
                    dy = -currentSpeed;
                    dx = 0;
                //  turn = tUP;
                    currentAnim = setAnimation(animWU);
                }
            }
            else 
            {
                cx = gx;
            }
        }

        if(currentState == Fleeing && isPen(cx,cy))
        {
            currentSpeed = WAITSPEED;
            if (hasCollision(cx,cy-1) && yr < 0.5){
                dy = currentSpeed;
                dx = 0;
               // turn = tDOWN;
               // currentAnim = setAnimation(animWD);
            }
            if (hasCollision(cx,cy+2) && yr > 0.5){
                dy = -currentSpeed;
                dx = 0;
              //  turn = tUP;
              //  currentAnim = setAnimation(animWU);
            }
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
            dx = currentSpeed;
            wrap = true;
        } 
        if (cx - 1 <= -1 && dx < 0 ) {
            cx += 27;
            dx = -currentSpeed;
            wrap = true;
        }
        
        if (!wrap) //only check for collisions & y movement when not wrapping around the lateral edges
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

        //update pixel position
        xx = Std.int( (cx+xr) * 8 );
        yy = Std.int( (cy+yr) * 8 );

        //when this has moved to a new cell
        if (px != cx || py != cy)
        {
            //decide next direction when finding a node
            turn = navigateTo(gx,gy);
        }


        //update ghost sprite position
        x = xx;
        y = yy;

        switch (currentState)
        {
            case Chasing:
                if (Main.scatterMode)
                {
                    currentState = Scattering;
                }
                gx = chaseX;
                gy = chaseY;
                penAllowed = isPen(cx,cy);
                currentSpeed = BASESPEED;
                if (isWrapNode(cx,cy)) currentSpeed = WRAPSPEED;
            case Fleeing:
                gx = Main.pacman.cx;
                gy = Main.pacman.cy;
                penAllowed = false;
                currentSpeed = FLEESPEED;
                if (fleeTime < 2 && animFleeEnding.pause)
                {
                    setAnimation(animFleeEnding);
                }
                if (fleeTime <= 0)
                {
                    currentState = Chasing;
                    if (isPen(cx,cy))
                    {
                        if (dy > 0) setAnimation(animWU);
                        else setAnimation(animWD);
                        currentState = Waiting;
                    }
                }
                fleeTime -= dt;
            case Waiting:
                
                //penTime -= dt;
                gx = penX;
                gy = penY;
                xr = 0.5;
                if (dy > 0 && hasCollision(cx,cy+1))
                {
                    dy = -WAITSPEED;
                }
                penAllowed = false;
                currentSpeed = WAITSPEED;
                if (dotCount <= 0) {
                    dotCount = dotMax;
                    turn = tDOWN;
                    currentState = Exiting;
                    penAllowed = false;
                }
            case Returning:
                penAllowed = true;
                currentSpeed = RETURNSPEED;
                if (isPen(cx,cy)) {
                    currentState = Waiting;
                    penAllowed = false;
                    penTime = 4; //must be >= 4 for some reason?? /!\
                }
            case Exiting:
                penAllowed = true;
                gx = penCenterX;
                if (!isPen(cx,cy)){
                    currentState = Chasing;
                    penAllowed = false;
                }
            case Scattering:
                gx = scatterX;
                gy = scatterY;
                if (!Main.scatterMode)
                {
                    currentState = Chasing;
                }
                penAllowed = isPen(cx,cy);
                currentSpeed = BASESPEED;
                if (isWrapNode(cx,cy)) currentSpeed = WRAPSPEED;
            default:
                //do nothing;
        }

      
    }
}