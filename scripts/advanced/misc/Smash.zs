#reloadable
#priority 100000011

//imports
    import scripts.libs.advanced.UniversalTicker as UT;
    import scripts.libs.basic.Vector3D as V;
    import scripts.libs.advanced.Misc as M;

    import crafttweaker.entity.IEntityDefinition;
    import crafttweaker.entity.IEntity;
    import crafttweaker.data.IData;

    import crafttweaker.event.PlayerBreakSpeedEvent;
    import crafttweaker.event.BlockBreakEvent;
    import crafttweaker.event.BlockHarvestDropsEvent;

    import crafttweaker.block.IBlockState;
    import crafttweaker.block.IBlockStateMatcher;
    import crafttweaker.block.IBlock;

    import crafttweaker.item.WeightedItemStack;
    import crafttweaker.item.IItemDefinition;
    import crafttweaker.item.IIngredient;
    import crafttweaker.item.IItemStack;

//Speed
    static Hammers as int[IIngredient] = {
        <exnihilocreatio:hammer_wood:*>:    2.0f,
        <exnihilocreatio:hammer_stone:*>:   4.0f,
        <exnihilocreatio:hammer_iron:*>:    6.0f,
        <exnihilocreatio:hammer_diamond:*>: 8.0f,
        <exnihilocreatio:hammer_gold:*>:    12.0f
    } as int[IIngredient];
//////

//RecipeRegistry
    static Inputs as IBlockStateMatcher[] = [] as IBlockStateMatcher[];
    static Outputs as WeightedItemStack[][] = [] as WeightedItemStack[][];
    static PreciseResults as int[] = [] as int[];
    function addRecipePrecise(outputs as WeightedItemStack[], input as IBlockStateMatcher){
        PreciseResults = PreciseResults + (Inputs.length) as int;
        Inputs = Inputs + input;
        Outputs = Outputs + outputs;
    }
    function addRecipe(outputs as WeightedItemStack[], input as IItemStack){
        Inputs = Inputs + (input as IBlock).definition.defaultState;
        Outputs = Outputs + outputs;
    }
//////
//Events for Breaking Blocks
    events.register(function(event as PlayerBreakSpeedEvent) {
        var estate = event.blockState;
        var speedCoef = (estate.block.definition.getHarvestTool()=="")?1.0:3.0;
        for i in PreciseResults{
            var state = Inputs[i];
            if (state.matches(event.blockState)) {
                val tool = event.player.currentItem;
                for hammer, speed in Hammers{
                    if(hammer.matches(tool)) event.newSpeed = speed*speedCoef;
                }
            }
        }
    });
    events.register(function(event as BlockBreakEvent) {
        var estate = event.blockState;
        if (event.isPlayer) {
            val tool = event.player.currentItem;
            val world = event.world;
            if (tool.definition.id.startsWith("exnihilocreatio:hammer")) {
                for i in PreciseResults{
                    var state = Inputs[i];
                    if (state.matches(event.blockState)) {
                        for o in Outputs[i]{
                            if(world.random.nextFloat()<o.chance)
                                world.spawnEntity(o.stack.createEntityItem(world, event.x + 0.5f, event.y + 0.5f, event.z + 0.5f));
                            M.shout("AAAA");
                        }
                    }
                }
            }
        }
    });
    events.register(function(event as BlockHarvestDropsEvent){
        if (event.isPlayer) {
            val tool = event.player.currentItem;
            val world = event.world;
            if (tool.definition.id.startsWith("exnihilocreatio:hammer")) {
                for i in PreciseResults{
                    var state = Inputs[i];
                    if (state.matches(event.blockState)) {
                        event.drops = []; //Outputs[i];
                    }
                }
            }
        }
    });
//////
//Events for Anvils
    UT.register2(<entity:minecraft:falling_block>, function(entity as IEntity,event as crafttweaker.event.WorldTickEvent, data as IData)as void{
        if((["minecraft:anvil","enderio:block_dark_steel_anvil"] as string[]) has data.Block.asString()){
            var world = event.world;
            var res = world.rayTraceBlocks(
                crafttweaker.world.IVector3d.create(entity.x, entity.y, entity.z), 
                crafttweaker.world.IVector3d.create(entity.motionX, entity.motionY, entity.motionZ)
            );
            if(res.isBlock && res.sideHit == crafttweaker.world.IFacing.up()){
                var pos = res.blockPos;
                var state = world.getBlockState(pos);

                var p1 = V.getPos(entity);
                var p2 = V.add(V.fromBlockPos(pos),[0,0.5,0]);
                var d = V.subtract(p1,p2);
                var v = [entity.motionX, entity.motionY, entity.motionZ] as double[];
                if(V.dot(d,d)>V.dot(v,v)*1.7)return;
                
                for i in 0 to Inputs.length{
                    var matcher = Inputs[i];
                    if(matcher.matches(state)){
                        world.destroyBlock(pos,false);
                        for o in Outputs[i]{
                            if(world.random.nextFloat()<o.chance)
                                world.spawnEntity((o.stack).createEntityItem(world,pos));
                                M.shout(o.stack.amount);
                        }
                        entity.motionY = entity.motionY*0.7 + 0.1;
                    }
                }
            }
        }
    });
//////