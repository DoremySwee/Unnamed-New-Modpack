#reloadable
import scripts.libs.advanced.ParticleGenerator as FX;
import scripts.libs.basic.Vector3D as V;
import scripts.libs.advanced.Misc as M;
import mods.zenutils.NetworkHandler;
import crafttweaker.world.IBlockPos;
import crafttweaker.player.IPlayer;
import mods.zenutils.IByteBuf;
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
    //TODO: add tooltip
    apple.addTooltip();
//3. The flower
    //<cotSubTile:whispee>.onUpdate = function(tile, world, pos) {}
    var radius = 3;
    static posList as double[][] = []as double[][];
    for i in (-radius) to (radius+1){
        for j in (-radius) to (radius+1){
            for k in (-radius) to (radius+1){
                if(i*i+j*j+k*k<=radius*radius){
                    posList=posList+([i,j+1,k]as double[]);
                }
            }
        }
    }
    print(posList.length);
    function getFlowerPoses (player as IPlayer)as IBlockPos[]{
        var pp = V.getPos(player);
        var world = player.world;
        var flowerPosList as IBlockPos[] = [] as IBlockPos[];
        for dp in posList{
            var p = V.add(pp,dp);
            if(p[1]<0)continue;
            var blockPos as IBlockPos = V.asBlockPos(p);
            if(M.isFlower(world.getBlock(blockPos),"whispee"))flowerPosList=flowerPosList+blockPos;
        }
        return flowerPosList;
    }
    events.onClientChat(function(event as mods.eventtweaker.event.ClientChatEvent){
        if(event.getOriginalMessage()[0]=="/")return;
        if(getFlowerPoses(client.player).length<1)return;
        NetworkHandler.sendToServer("modpack_whispee_listen", function(buffer)as void{});
        event.cancel();
    });
    NetworkHandler.registerClient2ServerMessage("modpack_whispee_listen",
        function (server, byteBuf, player) as void{
            var world = player.world;
            var flowerPosList  = getFlowerPoses(player);
            if(flowerPosList.length<1)return;
            //var mana = 1+30/V.sqrt(1.0+flowerPosList.length);
            var mana = 30;
            for flowerPos in flowerPosList{
                world.getSubTileEntityInGame(flowerPos).addMana(mana);
                //FX
                var pp = V.add(V.add(V.getPos(player),[0,1.5,0]),V.scale(V.randomUnitVector(world),0.3));
                var fp = V.add(V.fromBlockPos(flowerPos),V.scale(V.randomUnitVector(world),0.3));
                var vpf = V.subtract(fp,pp);
                var color = M.fromDoubleRGB(V.randomUnitVector(world));
                var rdCoef = (3.0+world.random.nextDouble())/3.5;
                for i in 15 to 30{
                    var v = V.rot(V.scale(vpf,0.0005*i),V.randomUnitVector(world),3.0);
                    FX.LinearOrb.create(world,{
                        "color":color,
                        "size":0.1,
                        "colli":false,
                        "renderTime":1,
                        "renderInterval":10,
                        "lifeLimit":70
                    }+V.asData(pp)+V.asData(v,"v"));
                }
            }
        }
    );
//4. Mooshroom
    //TODO