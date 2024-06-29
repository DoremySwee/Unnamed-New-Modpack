#reloadable
#priority 100000011

//imports
    import scripts.libs.basic.Vector3D as V;
    import scripts.libs.advanced.Misc as M;

    import crafttweaker.entity.IEntityDefinition;
    import crafttweaker.entity.IEntity;
    import crafttweaker.data.IData;

    import crafttweaker.event.PlayerBreakSpeedEvent;
    import crafttweaker.event.BlockBreakEvent;
    import crafttweaker.event.BlockHarvestDropsEvent;
    import crafttweaker.event.EntityJoinWorldEvent;

    import crafttweaker.block.IBlockState;
    import crafttweaker.block.IBlockStateMatcher;
    import crafttweaker.block.IBlock;

    import crafttweaker.item.WeightedItemStack;
    import crafttweaker.item.IItemDefinition;
    import crafttweaker.item.IIngredient;
    import crafttweaker.item.IItemStack;

    import crafttweaker.util.IRandom;
    import crafttweaker.world.IVector3d;

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
        Inputs += input;
        Outputs += outputs;
    }
    function addRecipe(outputs as WeightedItemStack[], input as IItemStack){
        Inputs += (input as IBlock).definition.getStateFromMeta(input.metadata);
        Outputs += outputs;
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
            if(isNull(tool))return;
            if (tool.definition.id.startsWith("exnihilocreatio:hammer")) {
                for i in PreciseResults{
                    var state = Inputs[i];
                    if (state.matches(event.blockState)) {
                        for o in Outputs[i] {
                            if(o.chance > world.random.nextFloat()) {
                                world.spawnEntity(o.stack.createEntityItem(world, event.x + 0.5f, event.y + 0.5f, event.z + 0.5f));
                            }
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
            if (!isNull(tool) && tool.definition.id.startsWith("exnihilocreatio:hammer")) {
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
    events.register(function(event as EntityJoinWorldEvent) {
        val entity = event.entity;
        if (entity.world.remote) return;
        val def = entity.definition;
        if (!isNull(def) && def.id == "minecraft:falling_block") {
            if ((["minecraft:anvil","enderio:block_dark_steel_anvil"] as string[]) has entity.nbt.Block.asString()) {
                M.shout("falling anvil");
                event.world.catenation()
                    .repeat(2147483647, function(builder) {
                        builder.run(function(world, ctx) {
                            val posVec = IVector3d.create(entity.x, entity.y, entity.z);
                            val motionVec = posVec.add(IVector3d.create(entity.motionX, entity.motionY, entity.motionZ));
                            val result = world.rayTraceBlocks(posVec, motionVec);
                            if (isNull(result) || !result.isBlock) {
                                return;
                            }
                            val pos = result.blockPos;
                            if (!world.isAirBlock(pos)) {
                                val state = world.getBlockState(pos);
                                for i, matcher in Inputs {
                                    if (matcher.matches(state)) {
                                        world.destroyBlock(pos, false);
                                        for output in Outputs[i] {
                                            if (output.chance > world.random.nextFloat()) {
                                                // TODO: remove mutable().copy() after crt update
                                                world.spawnEntity(output.stack.mutable().copy().createEntityItem(world, pos));
                                            }
                                        }
                                        // entity.motionY = min(0.3f, entity.motionY * 0.7 + 0.1);
                                    }
                                }
                            }
                        });
                    })
                    .stopWhen(function(world, ctx) {
                        return !entity.native.addedToWorld || !entity.alive || entity.y < 0;
                    })
                    .start();
            }
        }
    });
//////