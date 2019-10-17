class Blinky extends Ghost {
    override public function init() {
        super.init();
        scatterX = 27;
        scatterY = 0;
        currentState = Chasing;
        name = "Blinky";
    }
    override public function update(dt: Float) {
        super.update(dt);

        //chase pacman directly
        chaseX = Main.pacman.cx;
        chaseY = Main.pacman.cy;
    }
}