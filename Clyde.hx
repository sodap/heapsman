class Clyde extends Ghost {
    override function init(){
        name = "Clyde";
        //create walk right animation
        var frame1WR: h2d.Tile = entitiesAtlas.sub(0,16*7,16,16);
        var frame2WR : h2d.Tile = entitiesAtlas.sub(16,16*7,16,16);

        animWR = new h2d.Anim([frame1WR,frame2WR],this);
        animWR.loop = true;
        allAnims.push(animWR);

        //create walk right animation
        var frame1WL: h2d.Tile = entitiesAtlas.sub(32,16*7,16,16);
        var frame2WL : h2d.Tile = entitiesAtlas.sub(32+16,16*7,16,16);

        animWL = new h2d.Anim([frame1WL,frame2WL],this);
        animWL.loop = true;
        allAnims.push(animWL);

        //create walk up animation
        var frame1WU: h2d.Tile = entitiesAtlas.sub(64,16*7,16,16);
        var frame2WU : h2d.Tile = entitiesAtlas.sub(64+16,16*7,16,16);

        animWU = new h2d.Anim([frame1WU,frame2WU],this);
        animWU.loop = true;
        allAnims.push(animWU);

        //create walk down animation
        var frame1WD: h2d.Tile = entitiesAtlas.sub(96,16*7,16,16);
        var frame2WD : h2d.Tile = entitiesAtlas.sub(96+16,16*7,16,16);

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
        scatterY = 35;
        penX = 15;
        penY = 17;
        turn = tUP;
        startInPen(1);
        dotMax = 32;
        dotCountStart = 60;
        dotCount = dotCountStart;
    }
    override public function update(dt: Float) {
        

        super.update(dt);

        
        //if clyde is more 8 tiles far from pacman, move towards pacman
        var distToPacman = distSqr(cx,cy,Main.pacman.cx,Main.pacman.cy);
        if (distToPacman > 64) //distance is squared in this calculations, so we compare to 8*8
        {
            chaseX = Main.pacman.cx;
            chaseY = Main.pacman.cy;
        }
        else //if too close to pacman, move towards clyde's corner (bottom left)
        {
            chaseX = scatterX;
            chaseY = scatterY;
        }        
    }
}