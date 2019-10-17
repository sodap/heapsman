class Pinky extends Ghost {
    override function init(){
        
        //create walk right animation
        var frame1WR: h2d.Tile = entitiesAtlas.sub(0,16*5,16,16);
        var frame2WR : h2d.Tile = entitiesAtlas.sub(16,16*5,16,16);

        animWR = new h2d.Anim([frame1WR,frame2WR],this);
        animWR.loop = true;
        allAnims.push(animWR);

        //create walk right animation
        var frame1WL: h2d.Tile = entitiesAtlas.sub(32,16*5,16,16);
        var frame2WL : h2d.Tile = entitiesAtlas.sub(32+16,16*5,16,16);

        animWL = new h2d.Anim([frame1WL,frame2WL],this);
        animWL.loop = true;
        allAnims.push(animWL);

        //create walk up animation
        var frame1WU: h2d.Tile = entitiesAtlas.sub(64,16*5,16,16);
        var frame2WU : h2d.Tile = entitiesAtlas.sub(64+16,16*5,16,16);

        animWU = new h2d.Anim([frame1WU,frame2WU],this);
        animWU.loop = true;
        allAnims.push(animWU);

        //create walk down animation
        var frame1WD: h2d.Tile = entitiesAtlas.sub(96,16*5,16,16);
        var frame2WD : h2d.Tile = entitiesAtlas.sub(96+16,16*5,16,16);

        animWD = new h2d.Anim([frame1WD,frame2WD],this);
        animWD.loop = true;
        allAnims.push(animWD);

        for (animation in allAnims)
        {
            for (frame in animation.frames)
            {
                frame.dx = -4;
                frame.dy = -4;
            }
        }
        super.init();
        scatterX = 0;
        scatterY = 0;
        penX = 13;
        penY = 17;
        turn = tUP;
        startInPen(1);
        dotMax = 7;
        dotCountStart = 0;
        dotCount = dotCountStart;
        
    }
    override public function update(dt: Float) {
        name = "Pinky";

        super.update(dt);


        //where is pacman going        
        var adx : Int = 0;
        if (Main.pacman.dx != 0) adx = Std.int(Main.pacman.dx/Math.abs(Main.pacman.dx));
        var ady : Int = 0;
        if (Main.pacman.dy != 0) ady = Std.int(Main.pacman.dy/Math.abs(Main.pacman.dy));

        //chase pacman 4 tiles further from where it's right now in the direction it's moving
        chaseX = Main.pacman.cx + adx*4;
        chaseY = Main.pacman.cy + ady*4;
    }
}