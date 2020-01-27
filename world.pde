/*
 * world.pde
 *
 * Handles all the level logic. Moving blocks down,
 * generating blocks maintaining the grid, etc...
 *
 * Created on: January 12, 2020
 *     Author: Sean LaPlante
 */
 

class World {
    /*
     * Generates the blocks and collectibles for a level
     */    
    
    private MainGame game;
    
    World(MainGame _game) {
        game = _game;
    }
    
    int getBlockValue() {
        /*
         * Get a random value for a block
         * based on the current level
         */
         float chance = random(100);
         if (chance < 33) {
             // 1/3rd chance of the block value being double the current level
             return game.hud.level * 2;
         }
         // otherwise the new blocks value is just the level
         return game.hud.level;
    }
   
    void generateBlocks() {
        /*
         * Generate blocks for the
         * current level
         */
        int num = int(random(1, BLOCK_COLUMNS)); 
        float x = 0;
        float y = game.screen.top;

        for (int i = 0; i < BLOCK_COLUMNS && num > 0; i++) {
            if (int(random(2)) == 0 && (BLOCK_COLUMNS - i) > num) {
                x += BLOCK_WIDTH;
            } else {
                int val = getBlockValue();
                Block block = new Block(new PVector(x, y), val);
                game.blocks.add(block);
                x += BLOCK_WIDTH;
                num--;
            }
        }
    }
}
