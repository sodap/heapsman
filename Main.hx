import hxd.snd.OggData;
import Ghost.GhostState;
import hxsl.Cache;
import haxe.Json;
import haxe.Timer;
import h2d.Bitmap;
import h2d.TileGroup;
import hxd.res.TiledMap;
import h2d.Font.FontChar;
import hxd.Key;
#if !js
import hl.UI;
#end


typedef TileLayer = {
    var data : Array<Int>;
    var height : Int;
    var width : Int;
    var name : String;
    var objects : Array<TileObjectData>;
}
typedef TileData = {
    var height : Int;
    var width : Int;
    var layers : Array<TileLayer>;
}
typedef TileObjectData = {
    var template : String;
    var id : Int;
    var x : Int;
    var y : Int;
}

class Main extends hxd.App {

    var elapsed : Int = 0;
    var stageClear : Bool = false;
    var lostLife : Bool = false;
    var globalDots : Int = 0;
    public static var gameObjects : Array<Entity> = [];
    public static var dots : Array<Entity> = [];
    public static var removedDots : Array<Entity> = [];
    public static var pacman : Pacman;
    public static var ghosts : Array<Ghost> = [];
    public static var blinky : Ghost;
    public static var pinky : Ghost;
    public static var inky : Ghost;
    public static var clyde : Ghost;
    var chaseTime : Float = 20;
    var scatterTime : Float = 9;
    var modeTimer : Float = 7;
    public static var scatterMode : Bool = true;
    var countDots : Bool = false;
    var dotTic : Float = 1;
    var dotTimer : Float = 1;
    var currentScore : Int = 0;
    var extraLives : Int = 3;
    var levelBmp : h2d.Bitmap;
    var levelTileGroup : h2d.TileGroup;
    var tileset : h2d.Tile;
    var tilesetFlash : h2d.Tile;
    var tilesetNormal : h2d.Tile;
    var levelJson : String;
    var levelData:TileData;
    var tileMap:Array<Int>;
    var navMap:Array<Int> =[];
    var dieWaitTime:Float = 0.6;
    var dieTimer:Float = -1;
    var startTimer:Float = 2;
    var fullStartTimer:Float = 2.25;
    var currentTimer:Float = -1;
    var font : h2d.Font;
    var readyText : h2d.Text;
    var playerOneText : h2d.Text;
    var scoreText : h2d.Text;
    var hiscoreText : h2d.Text;
    var gameOverText : h2d.Text;
    var titleText : h2d.Text;
    var startText : h2d.Text;
    var creditsText : h2d.Text;
    var livesHUD : h2d.Graphics;
    var livesIcon : h2d.Tile;
    var titleBG : h2d.Graphics;

    var munchSound1 = null;
    var munchSound2 = null;
    var munchSound = null;
    var startSound = null;
    var deathSound1 = null;
    var deathSound2 = null;
    var eatGhostSound = null;
    var creditSound = null;
    var bonusSound = null;

    var readyTimer : Float = -1;
    var startGameTimer : Float = -1;
    var currentLevel : Int = 1;
    var eatPointsTimer : Float = -1;
    var gameStarted = false;
    
    var eatPoints : h2d.Anim;
    var eatenGhosts : Int = 0;

    static var bonusGoal : Int = 10000;
    var bonusLevel = 1;
    var lastBonus = 0;

    var hiScore : Int = 0;
    
    override function init() {
        #if !js
        hl.UI.closeConsole();
        engine.fullScreen = true;
        #end


        hxd.Res.initEmbed();
        
        #if js
            munchSound1 = hxd.Res.sounds.wav.pacmanMunch1;
            munchSound2 = hxd.Res.sounds.wav.pacmanMunch2;
            startSound = hxd.Res.sounds.wav.pacmanGameStart;
            deathSound1 = hxd.Res.sounds.wav.pacmanDeath1;
            eatGhostSound = hxd.Res.sounds.wav.pacmanMonsterEaten;
            creditSound = hxd.Res.sounds.wav.pacmanCredit;
            bonusSound = hxd.Res.sounds.wav.pacmanExtend;  
        #else
            if ( hxd.res.Sound.supportedFormat(OggVorbis) )
            {
                munchSound1 = hxd.Res.sounds.ogg.pacmanMunch1;
                munchSound2 = hxd.Res.sounds.ogg.pacmanMunch2;
                startSound = hxd.Res.sounds.ogg.pacmanGameStart;
                deathSound1 = hxd.Res.sounds.ogg.pacmanDeath1;
                eatGhostSound = hxd.Res.sounds.ogg.pacmanMonsterEaten;
                creditSound = hxd.Res.sounds.ogg.pacmanCredit;
                bonusSound = hxd.Res.sounds.ogg.pacmanExtend;  
            }
            else
            {
                munchSound1 = hxd.Res.sounds.wav.pacmanMunch1;
                munchSound2 = hxd.Res.sounds.wav.pacmanMunch2;
                startSound = hxd.Res.sounds.wav.pacmanGameStart;
                deathSound1 = hxd.Res.sounds.wav.pacmanDeath1;
                eatGhostSound = hxd.Res.sounds.wav.pacmanMonsterEaten;
                creditSound = hxd.Res.sounds.wav.pacmanCredit;
                bonusSound = hxd.Res.sounds.wav.pacmanExtend;    
            }
        #end
        hiScore = Std.parseInt(hxd.Save.load("0","hiscore",false));
        munchSound = munchSound1;

        font = hxd.Res.fonts.emulogic.toFont();
        readyText = new h2d.Text(font);
        readyText.text = "READY!";
        readyText.textAlign = Center;
        readyText.y = 19.8*8;
        readyText.x = 14*8;
        readyText.textColor = 0xFFFF00;
        readyText.letterSpacing = 0.25;
        
        playerOneText = new h2d.Text(font);
        playerOneText.text = 'LEVEL $currentLevel';
        playerOneText.textAlign = Center;
        playerOneText.y = 13.8*8;
        playerOneText.x = 14*8;
        playerOneText.textColor = 0x00FFFF;
        playerOneText.letterSpacing = 0.25;

        gameOverText = new h2d.Text(font);
        gameOverText.text = 'GAME OVER';
        gameOverText.textAlign = Center;
        gameOverText.y = 19.8*8;
        gameOverText.x = 14*8;
        gameOverText.textColor = 0xFF0000;
        gameOverText.letterSpacing = 0.25;
        gameOverText.visible = false;

        scoreText = new h2d.Text(font);
        scoreText.text = "SCORE\n0";
        scoreText.textAlign = Right;
        scoreText.y = 0;
        scoreText.x = 9*8;
        scoreText.textColor = 0xFFFFFF;
        scoreText.letterSpacing = 0.25;

        hiscoreText = new h2d.Text(font);
        hiscoreText.text = 'HI-SCORE\n$hiScore';
        hiscoreText.textAlign = Right;
        hiscoreText.y = 0;
        hiscoreText.x = 27*8;
        hiscoreText.textColor = 0xFFFFFF;
        hiscoreText.letterSpacing = 0.25;

        titleText = new h2d.Text(font);
        titleText.text = 'HEAPS-MAN (2019)\n\nA PAC-MAN CLONE\nBY EDU ALONSO\nUSING HEAPS.IO';
        titleText.lineSpacing = 1;
        titleText.textAlign = Center;
        titleText.y = 5*8;
        titleText.x = 14*8;
        titleText.textColor = 0xFFB8DE;
        titleText.letterSpacing = 0.25;


        startText = new h2d.Text(font);
        startText.text = 'PRESS ENTER\nTO START';
        startText.lineSpacing = 1;
        startText.textAlign = Center;
        startText.y = 30*8;
        startText.x = 14*8;
        startText.textColor = 0xFFFF00;
        startText.letterSpacing = 0.25;

        creditsText = new h2d.Text(font);
        creditsText.text = '2019';
        creditsText.lineSpacing = 1;
        creditsText.textAlign = Center;
        creditsText.y = 34*8;
        creditsText.x = 14*8;
        creditsText.textColor = 0x0000FF;
        creditsText.letterSpacing = 0.25;

        setScene2D(new h2d.Scene()); 
        s2d.scaleMode = Zoom(3);
        levelJson = hxd.Res.loader.load("map/pacmanLevel0.json").toText();
        levelData = Json.parse(levelJson);
        init_map(levelData);
        s2d.scaleMode = LetterBox(levelData.width*8,levelData.height*8);
        
        //add texts
        s2d.addChild(readyText);
        s2d.addChild(playerOneText);
        s2d.addChild(scoreText);
        s2d.addChild(hiscoreText);
        s2d.addChild(gameOverText);

        //add lives hud
        var entitiesAtlas : h2d.Tile = hxd.Res.entitiesAtlas.toTile();
        livesIcon = entitiesAtlas.sub(8*16,16,16,16);
        livesHUD = new h2d.Graphics(s2d);
        livesHUD.x = 0;
        livesHUD.y = 8*34;
        updateLivesHUD();

        //add titlescreen
        titleBG = new h2d.Graphics(s2d);
        titleBG.beginFill(0x000000);
        titleBG.drawRect(0,0,28*8,36*8);
        titleBG.endFill();

        s2d.addChild(titleText);
        //s2d.addChild(creditsText);
        s2d.addChild(startText);
        creditSound.play(false);

        var points0 : h2d.Tile = entitiesAtlas.sub(0,8*16,16,16);
        var points1 : h2d.Tile = entitiesAtlas.sub(1*16,8*16,16,16);
        var points2 : h2d.Tile = entitiesAtlas.sub(2*16,8*16,16,16);
        var points3 : h2d.Tile = entitiesAtlas.sub(3*16,8*16,16,16);

        points0.dx = -4;
        points0.dy = -4;
        points1.dx = -4;
        points1.dy = -4;
        points2.dx = -4;
        points2.dy = -4;
        points3.dx = -4;
        points3.dy = -4;

        eatPoints = new h2d.Anim([points0,points1,points2,points3],s2d);
        eatPoints.loop = false;
        eatPoints.visible = false;
        eatPoints.speed = 0;
        modeTimer = scatterTime + readyTimer;
        scatterMode = true;

    }

    function updateLivesHUD() {
        livesHUD.clear();
        for (lives in 0 ... extraLives)
        {
            livesHUD.beginTileFill(lives * 16,0,1,1,livesIcon);
            livesHUD.drawRect(lives* 16 ,0,16,16);
            livesHUD.endFill();
        }
    }

    function clean_map() {
        for (o in dots)
        {
            dots.remove(o);
        }
        dots = [];

        for (o in gameObjects)
        {
            o.remove();
            gameObjects.remove(o);
            o = null;
        }
        gameObjects = [];
        for (c in s2d)
        {
            s2d.removeChildren();
        }
    }

    function init_map(tileData : TileData) {
        tileset = hxd.Res.map.tileset.toTile();
        var tiles : Array<h2d.Tile> = [];
        var tileWidth = 8;
       
       

        //create tiles from tileset
        for (yy in 0 ... Math.round(tileset.height / tileWidth))
        {
            for (xx in 0 ... Math.round(tileset.width / tileWidth))
            {
                //cut the tile from the atlas
                var newTile = tileset.sub(xx*tileWidth,yy*tileWidth,tileWidth,tileWidth);
                tiles.push(newTile);
            }
        }
        

        tilesetNormal = hxd.Res.map.tileset2.toTile(); // h2d.Tile.fromColor(0xffffff,tileData.width*tileWidth,tileData.height*tileWidth,0);
        tilesetFlash = hxd.Res.map.tilesetFlash.toTile();
        levelTileGroup = new h2d.TileGroup(tilesetNormal,s2d);
        for (layer in tileData.layers)
        {          
            //add walls as found in the walls layer
            if (layer.name == "walls")
            {
                tileMap = layer.data.copy();
                for (yy in 0 ... tileData.height)
                {
                    for (xx in 0 ... tileData.width)
                    {
                        //add tiles to the level tilegroup
                        var newTile : h2d.Tile = tiles[layer.data[xx+yy*tileData.width]-1].clone();
                        levelTileGroup.add(xx*tileWidth,yy*tileWidth,newTile);
                    }
                }
            }
            //store nodes as found in the nodes layer
            if (layer.name == "nodes")
            {
                navMap = layer.data.copy();
            }
            if (layer.name == "objects")
            {
                for (i in layer.objects)
                {
                    var objectTemplate : String = hxd.Res.loader.load("map/" + i.template).toText();
                    var objectData : Xml = Xml.parse(objectTemplate);
                    var objectAccess = new haxe.xml.Access(objectData.firstElement());
                    var objectType : String = objectAccess.node.object.att.type;
                    var newObject : Entity;
                    switch objectType{
                        case "Dot": 
                            newObject = new Dot(i.x,i.y,s2d); 
                            gameObjects.push(newObject);
                            dots.push(newObject);
                        case "Energizer": 
                            newObject = new Energizer(i.x,i.y,s2d);
                            gameObjects.push(newObject);
                            dots.push(newObject);
                        case "Pacman": 
                            pacman = new Pacman(i.x,i.y,tileMap,s2d);
                            pacman.visible = false;
                            newObject = pacman;
                            gameObjects.push(newObject);
                        case "Blinky": 
                            blinky = new Blinky(i.x,i.y,tileMap,navMap,s2d);
                            blinky.visible = false;
                            newObject = blinky;
                            gameObjects.push(newObject);
                            ghosts.push(cast(newObject,Ghost));   
                        case "Pinky": 
                            pinky = new Pinky(i.x,i.y,tileMap,navMap,s2d);
                            pinky.visible = false;
                            newObject = pinky;
                            gameObjects.push(newObject);
                            ghosts.push(cast(newObject,Ghost));
                        case "Inky": 
                            inky = new Inky(i.x,i.y,tileMap,navMap,s2d);
                            inky.visible = false;
                            newObject = inky;
                            gameObjects.push(newObject);
                            ghosts.push(cast(newObject,Ghost));
                        case "Clyde": 
                            clyde = new Clyde(i.x,i.y,tileMap,navMap,s2d);
                            clyde.visible = false;
                            newObject = clyde;
                            gameObjects.push(newObject);
                            ghosts.push(cast(newObject,Ghost));
                    }
                }
            }
        }

        readyTimer = startTimer + fullStartTimer;
        startGameTimer = fullStartTimer;
        for (ghost in ghosts)
        {
            ghost.freeze(readyTimer);
        }
        pacman.freeze(readyTimer);
        
        
    }

    function showTitleScreen() {
        titleBG.visible = true;
        titleText.visible = true;
        //startText.visible = true;
        creditsText.visible = true;
        if (elapsed % 15 == 0)
        {
            startText.visible = true;
        }
        if (elapsed % 75 == 0)
        {
            startText.visible = false;
        }

        if (Key.isPressed(Key.ENTER))
        {
            elapsed = 0;
            gameStarted = true;
            titleText.visible = false;
            startText.visible = false;
            creditsText.visible = false;
            titleBG.visible = false;
            startSound.play(false);
            modeTimer = scatterTime + readyTimer;
            scatterMode = true;
        }

    }

    // on each frame
    override function update(dt: Float) {
        hiScore = Std.int(Math.max(hiScore,currentScore));
        hiscoreText.text = 'HI-SCORE\n$hiScore';
        modeTimer -= dt;
        if (modeTimer <= 0)
        {
            scatterMode = !scatterMode;
            if (scatterMode)
            {
                modeTimer = scatterTime;
            }
            else
            {
                modeTimer = chaseTime;
            }
        }
        var currentBonus = Std.int( currentScore / (bonusGoal*bonusLevel) );
        if (currentBonus > 0 && currentScore > lastBonus)
        {
            lastBonus = currentScore;
            extraLives++;
            bonusLevel ++;
            bonusSound.play(false);
            updateLivesHUD();
            
        }
        elapsed ++;
        eatPointsTimer -= dt;
        if (eatPointsTimer < 0) eatPoints.visible = false;
        if (!gameStarted)
        {
            showTitleScreen();
            return;
        }

        currentTimer -= dt;
        readyTimer -= dt;
        startGameTimer -= dt;
        if (startGameTimer < 0 && playerOneText.visible)
        {
            playerOneText.visible = false;
            pacman.visible = true;
            for (ghost in ghosts)
            {
                ghost.visible = true;
            }
        }
        if(readyTimer < 0 && readyText.visible)
        {
            readyText.visible = false;
        }
        for (gameObject in dots)
        {
            gameObject.update(dt);
            if (pacman.cx == gameObject.cx && pacman.cy == gameObject.cy)
            {
                //freeze pacman for a bit when eating dots and energizers
                var scoreValue : Int = 10;
                countDots = true;
                pacman.freeze(0.045);
                munchSound.play(false);
                if (munchSound == munchSound1) munchSound = munchSound2;
                else munchSound = munchSound1;
                if (Std.is(gameObject,Energizer))
                {
                    pacman.freeze(0.1);
                    pacman.fleeModeTimer = 5;
                    scoreValue = 50;
                    for (ghost in ghosts)
                    {
                        ghost.startFleeing(5);
                    }                   
                }
                currentScore += scoreValue;
                scoreText.text = 'SCORE\n$currentScore';
                gameObjects.remove(gameObject);
                dots.remove(gameObject);
                removedDots.push(gameObject);
                gameObject.visible = false;
                var dlength : Int = dots.length;
                if (dots.length <= 0 && !stageClear)
                {
                    elapsed = 0;
                    stageClear = true;
                    hxd.Save.save(Std.string(hiScore),'hiscore');
                    currentLevel ++;
                    for (ghost in ghosts){
                        ghost.freeze(50);
                    } 
                    pacman.freeze(50);
                }
            }
        }
        dotTimer -= dt;
        if (dotTimer <= 0)
        {
            countDots = true;
        }
        if (countDots)
        {
            if (lostLife){
                globalDots++;
                if(pinky.currentState == Waiting || pinky.currentState == Fleeing && pinky.isPen(pinky.cx,pinky.cy) )
                {
                    if (globalDots == 7)
                    {
                        pinky.dotCount = 0;
                    }
                }
                else if (inky.currentState == Waiting || inky.currentState == Fleeing && inky.isPen(inky.cx,inky.cy) )
                {
                    if (globalDots == 17)
                    {
                        inky.dotCount = 0;
                    }
                }
                else if (clyde.currentState == Waiting || clyde.currentState == Fleeing && clyde.isPen(clyde.cx,clyde.cy) )
                {
                    if (globalDots == 32)
                    {
                        clyde.dotCount = 0;
                        lostLife = false;
                    }
                }
            }
            else
            {
                if(pinky.currentState == Waiting || pinky.currentState == Fleeing && pinky.isPen(pinky.cx,pinky.cy) )
                {
                    pinky.dotCount--;
                }
                else if (inky.currentState == Waiting || inky.currentState == Fleeing && inky.isPen(inky.cx,inky.cy) )
                {
                    inky.dotCount--;
                }
                else if (clyde.currentState == Waiting || clyde.currentState == Fleeing && clyde.isPen(clyde.cx,clyde.cy) )
                {
                    clyde.dotCount--;
                }
            }
            countDots = false;
            dotTimer = dotTic;
        }

        if (stageClear && elapsed > 59)
        {
            if (blinky.visible)
            {
                for (ghost in ghosts){
                    ghost.visible = false;
                }
            }
            if (elapsed % 30 == 0 && elapsed < 211)
            {
            
                if (levelTileGroup.tile == tilesetNormal)
                {
                    levelTileGroup.tile = tilesetFlash;
                    
                }
                else
                {
                    levelTileGroup.tile = tilesetNormal;
                }
                
            }
            if (elapsed > 270)
            {
                levelTileGroup.tile = tilesetNormal;
                restartLevel(true);
            }
        }
        pacman.update(dt);
        if (pacman.fleeModeTimer <= 0) eatenGhosts = 0;
        for (ghost in ghosts)
        {
            ghost.update(dt);
            if (pacman.cx==ghost.cx && pacman.cy == ghost.cy )
            {
                if (ghost.currentState == GhostState.Fleeing)
                {
                    for(allghost in ghosts)
                    {
                        allghost.freeze(1);
                    }
                    pacman.freeze(1);
                    eatPoints.x = pacman.cx*8;
                    eatPoints.y = pacman.cy*8;
                    eatPoints.visible = true;
                    eatPoints.currentFrame = eatenGhosts;
                    eatPointsTimer = 1;
                    eatenGhosts = Std.int(Math.min(eatenGhosts,3));
                    currentScore += Std.int(Math.pow(2,1+eatenGhosts)*100);

                    eatenGhosts++;
                    scoreText.text = 'SCORE\n$currentScore';
                    pacman.unhide = true;
                    pacman.visible = false;
                    ghost.unhide = true;
                    ghost.visible = false;
                    ghost.startReturning();
                    eatGhostSound.play(false);
                }
                else if (ghost.currentState != GhostState.Returning)
                {
                    for(allghost in ghosts)
                    {
                        allghost.freeze(50);
                    }
                    if (!pacman.isDying)
                    {
                        hxd.Save.save(Std.string(hiScore),'hiscore');
                        pacman.isDying = true;
                        pacman.freeze(50);
                        dieTimer = 1;
                    }
                }
            }
        }

        if (pacman.isDying)
        {
            dieTimer -= dt;
            if (dieTimer <= 0)
            {
                for(allghost in ghosts)
                {
                    allghost.visible = false;
                }
                if (!pacman.isDead)
                {
                    deathSound1.play(false);
                    pacman.isDead = true;
                    pacman.setAnimation(pacman.animDie,Pacman.animSpeedDead);
                }
                else {

                }
                
            }
            if (!pacman.visible)
            {
                extraLives --;
                updateLivesHUD();
                if (extraLives < 0)
                {
                    for (dot in dots)
                    {
                        if (Std.is(dot,Energizer)) dot.visible = false;
                    }
                    game_over();
                }
                else
                {
                    restartLevel();
                }
                
            }
        }

        if (Key.isPressed(Key.SPACE))
        {
            restartGame(); //full restart
        }
        #if !js
        if (Key.isPressed(Key.F11) || (Key.isPressed(Key.ENTER) && Key.isDown(Key.LALT)) )
        {
            engine.fullScreen = !engine.fullScreen;
        }
        #end
    }

    function game_over() {
        if (!gameOverText.visible)
        {
            gameOverText.visible = true;
            elapsed = 0;
        }
        for (ghost in ghosts)
        {
            ghost.freeze(50);
        }
        pacman.freeze(50);
        if (elapsed > 120)
        {
            restartGame();
        }
    }

    function restartGame()
    {
        elapsed = 0;
        extraLives = 3;
        currentLevel = 1;
        currentScore = 0;
        creditSound.play(false);
        titleBG.visible = true;
        updateLivesHUD();
        restartLevel(true);
        gameStarted = false;


    }
    function restartLevel(?fullRestart:Bool = false) {
        gameOverText.visible = false;
        readyText.visible = true;
        readyTimer = startTimer;
        stageClear = false;
        playerOneText.text = 'LEVEL $currentLevel';
        lostLife = true;
        globalDots = 0;
        if (fullRestart)
        {
            modeTimer = scatterTime + readyTimer;
            scatterMode = true;
            lostLife = false;
            pacman.visible = false;
            for (ghost in ghosts)
            {
                ghost.visible = false;
            }
            playerOneText.visible = true;
            scoreText.text = 'SCORE\n$currentScore';
            readyTimer = startTimer + fullStartTimer;
            startGameTimer = fullStartTimer;
            for (dot in removedDots)
            {
                dots.push(dot);
                dot.visible = true;
            }
            removedDots = [];
        }
        pacman.init();
        pacman.freeze(readyTimer);
        for (ghost in ghosts)
        {
            ghost.init();
            ghost.freeze(readyTimer);
        }     
        if (fullRestart)
        {
            pacman.visible = false;
            for (ghost in ghosts)
            {
                ghost.visible = false;
            }
        }
    }


    static function main() {
        new Main();
    }
}