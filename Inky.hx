class Inky extends Ghost {
    override function init(){
        name = "Inky";
        //create walk right animation
        var frame1WR: h2d.Tile = entitiesAtlas.sub(0,16*6,16,16);
        var frame2WR : h2d.Tile = entitiesAtlas.sub(16,16*6,16,16);

        animWR = new h2d.Anim([frame1WR,frame2WR],this);
        animWR.loop = true;
        allAnims.push(animWR);

        //create walk right animation
        var frame1WL: h2d.Tile = entitiesAtlas.sub(32,16*6,16,16);
        var frame2WL : h2d.Tile = entitiesAtlas.sub(32+16,16*6,16,16);

        animWL = new h2d.Anim([frame1WL,frame2WL],this);
        animWL.loop = true;
        allAnims.push(animWL);

        //create walk up animation
        var frame1WU: h2d.Tile = entitiesAtlas.sub(64,16*6,16,16);
        var frame2WU : h2d.Tile = entitiesAtlas.sub(64+16,16*6,16,16);

        animWU = new h2d.Anim([frame1WU,frame2WU],this);
        animWU.loop = true;
        allAnims.push(animWU);

        //create walk down animation
        var frame1WD: h2d.Tile = entitiesAtlas.sub(96,16*6,16,16);
        var frame2WD : h2d.Tile = entitiesAtlas.sub(96+16,16*6,16,16);

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
        scatterX = 27;
        scatterY = 35;
        penX = 11;
        penY = 17;
        currentState = Waiting;
        dotMax = 17;
        dotCountStart = 30;
        dotCount = dotCountStart;
        //turn = tUP;
        startInPen(1);
    }
    override public function update(dt: Float) {
        

        super.update(dt);


        //where is Pacman going
        var adx : Int = 0;
        if (Main.pacman.dx != 0) adx = Std.int(Main.pacman.dx/Math.abs(Main.pacman.dx));
        var ady : Int = 0;
        if (Main.pacman.dy != 0) ady = Std.int(Main.pacman.dy/Math.abs(Main.pacman.dy));
        
        var pacX = Main.pacman.cx + adx*2;
        var pacY = Main.pacman.cy + ady*2;

        //where is Blinky in relation to pacman
        var bliX = Main.blinky.cx - pacX;
        var bliY = Main.blinky.cy - pacY;

        //go to the opposite cell of Blinky in relation to pacman
        chaseX = pacX + bliX;
        chaseY = pacY + bliY;
    }
}