<<<<<<< HEAD
#reoloadable
import crafttweaker.player.IPlayer;
//Apple
    var apple = <mysticalagriculture:inferium_apple>;
    apple.displayName="転生林檎";
    //Leaf drops
    events.onBlockHarvestDrops(function(event as crafttweaker.event.BlockHarvestDropsEvent){
        if(event.block.definition.id=="minecraft:leaves" && event.block.meta%4==0){
            event.drops += <minecraft:sapling>.weight(0.3);
            event.drops += apple.weight(0.005);
        }
    });
    //Haste
    events.onEntityLivingUseItemFinish(function(event as crafttweaker.event.EntityLivingUseItemEvent.Finish){
        if(event.isPlayer&&apple.matches(event.item)){
            event.player.addPotionEffect(<potion:minecraft:haste>.makePotionEffect(1800,2));
        }
    });
//A Bowl Of Water
    var emptyBowl = <minecraft:bowl>;
    var waterBowl = <botania:waterbowl>.withTag({Fluid: {FluidName: "water", Amount: 1000}});
    function bowlInteraction(player as IPlayer)as bool{
        var world = player.world;
        //Test if the player is clicking on a water source
        var reachDistance = player.getAttribute("generic.reachDistance").attributeValue;
        var traceResult = player.getRayTrace(reachDistance, 0, true, true);
        if(traceResult.isMiss || !traceResult.isBlock)return false;
        var pos = traceResult.blockPos;
        var block = world.getBlock(pos);
        var fluid = block.fluid;
        if(isNull(fluid))return false;
        print(fluid.name);
        print(block.meta);
        //TODO
        return true;
    }
    events.onPlayerInteract(function(event as crafttweaker.event.PlayerInteractEvent){
        print("A");
        var player = event.player;
        if(emptyBowl.matches(event.item)){
            if(!bowlInteraction(player))print("success!");
        }
    });/*
    events.onPlayerRightClickItem(function(event as crafttweaker.event.PlayerRightClickItemEvent){
        print("B");
        var player = event.player;
        //print(event.);
            if(emptyBowl.matches(event.item)){
                event.cancellationResult=bowlInteraction(player)?"success":"pass";
            }
    });*/
    //getRayTrace(double blockReachDistance, float partialTicks, true, true, @Optional(valueBoolean = true) boolean returnLastUncollidableBlock);
//TODOs:
    //3. The flower
    //4. Mooshroom