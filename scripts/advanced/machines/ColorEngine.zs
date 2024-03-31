#reloadable
#priority 10000

import crafttweaker.data.IData;
import crafttweaker.block.IBlock;
import crafttweaker.world.IBlockPos;
import mods.modularmachinery.MMEvents;
import mods.modularmachinery.MachineTickEvent;
import mods.modularmachinery.MachineStructureFormedEvent;

import scripts.libs.basic.Vector3D as V;
import scripts.libs.advanced.Misc as M;
import scripts.libs.advanced.ParticleGenerator as FX;

import mods.modularmachinery.RecipePrimer;
import mods.modularmachinery.RecipeBuilder;
import mods.modularmachinery.IngredientArrayBuilder;

import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;

static soundA0 as string = "botania:divinationrod";
static soundA1 as string = "botania:manapoolcraft";//"botania:ding";
static soundA16 as string = "botania:terrasteelcraft";//"astralsorcery:attunement";
static DL as int = scripts.Config.DECORATION_LEVEL;

static EXAMPLE_MANABURST_DATA as IData = 
{
    //lensStack: {id: "botania:lens", Count: 1 as byte, tag: {}, Damage: 3 as short},
    //shake: 0 as byte, PortalCooldown: 0, FallDistance: 0.0 as float, inGround: 0 as byte, UpdateBlocked: 0 as byte, //ticksExisted: 550, UUIDMost: 5120235492213279619 as long, UUIDLeast: -8210393045666413237 as long, 
    ownerName: "", zTile: -1, yTile: -1, spreaderZ: 0, spreaderY: -1, spreaderX: 0, hasShooter: 0 as byte, xTile: -1, //Invulnerable: 0 as byte, Air: 300 as short, OnGround: 0 as byte, Dimension: 0, //inTile: "minecraft:air", 
    startingMana: 100, color: 16777215, manaLossTick: 4.0 as float, mana: 100, minManaLoss: 2147483647, 
        gravity: 0.0 as float, Fire: -1 as short
        //lastMotionZ: -2.4838395178704506E-5, lastMotionY: 1.3841746483211827E-4, lastMotionX: -0.005287180306594671, 
        //AABB: [-84.48982191986408, 74.0224058956854, 59.294428189767224, -84.48982191986408, 74.0224058956854, 59.294428189767224]
        //Motion: [-0.005287180306594671, 1.3841746483211827E-4, -2.4838395178704506E-5], 
        //Rotation: [-90.26912 as float, 1.4997045 as float], 
        //Pos: [-84.48982191986408, 74.0224058956854, 59.294428189767224],
} as IData;

MMEvents.onMachinePreTick("color_engine_a", function(event as MachineTickEvent) {
    var controller = event.controller;
    var world = controller.world;
    var pos = controller.pos;
    var pos2 = IBlockPos.create(pos.x,pos.y+2,pos.z);
    var glass = world.getBlock(pos2);
    if(glass.definition.id=="minecraft:glass")return;

    var color = glass.meta;
    var data = controller.customData;
    var originalColor = (data has "color") ? (data.color.asInt()) : (-1 as int) ;
    //Particles and sounds
        M.playSound(soundA1,pos,0.3);
        for i in 0 to 5*DL{
            var p0 = V.add(V.fromIBlockPos(pos2),V.scale(V.randomUnitVector(world),0.3));
            var v0 = [world.random.nextDouble(-0.015,0.015),world.random.nextDouble(-0.13,-0.07),world.random.nextDouble(-0.015,0.015)] as double[];
            M.createFX(V.asData(p0)+V.asData(v0,"v")+{
                "color":M.COLOR_RGB[color],
                "r":0.1,
                "a":10
            });
        }

    if(color == originalColor){
        var progress = data.progress.asInt()+1;
        if(progress>15){
            //Spawn special Mana Burst
            var v = V.scale(V.randomUnitVector(world),0.0001);
            var data = EXAMPLE_MANABURST_DATA + ({
                "startingMana":5, "mana":17, "color":M.COLOR_RGB[color],
                "manaLossTick":0.01 as float, "minManaLoss":300,
                "Pos":V.asDataList(V.add(V.fromIBlockPos(pos2),[0.0,1.51,0.0])), 
                "Motion":V.asDataList(v),
                "colorEngineData":color
            }as IData)+V.asData(v,"lastMotion",true);
            var entity = <entity:botania:mana_burst>.createEntity(world);
            entity.updateNBT(data);
            world.spawnEntity(entity);
            //Particles
            M.playSound(soundA16,pos,0.3);
            M.shout("Progress"~progress);
            for i in 0 to (20*DL){
                var p0 = V.add(V.fromIBlockPos(pos),V.scale(V.randomUnitVector(world),0.3));
                var v0 = [world.random.nextDouble(-0.015,0.015),world.random.nextDouble(0.12,0.17),world.random.nextDouble(-0.015,0.015)] as double[];
                FX.LinearOrb.create(world,V.asData(p0)+V.asData(v0,"v")+{
                    "color":M.COLOR_RGB[color],
                    "size":0.2,
                    "lifeLimit":40
                });
            }
            var n = 30*DL;
            var rotAxis = V.randomUnitVector(world);
            for j in 0 to (2+DL){
                for i in 0 to n{
                    var theta = 360.0/n*i;
                    var v1 = V.scale(V.disc(V.VX,V.VZ,theta),1.4);
                    var v2 = V.scale(V.disc(V.VX,V.VZ,theta+100),0.06);
                    var p = V.add(V.fromIBlockPos(pos),V.rot(v1,rotAxis,10));
                    var v = V.rot(v2,rotAxis,10);
                    FX.LinearOrb.create(world,V.asData(p)+V.asData(v,"v")+{
                        "color":M.COLOR_RGB[color],
                        "size":0.15,
                        "lifeLimit":50
                    });
                }
                }
        }
        data = data + {"progress":progress%16};
    }
    else{
        M.playSound(soundA0,pos,0.1);
        data = data + {"color":color,"progress":1};
    }

    controller.customData = data;
    val temp1 as IBlock = <minecraft:glass>as IBlock;
    val temp2 = temp1.definition.defaultState;
    world.setBlockState(temp2,pos2);
});


var controllerB = <modularmachinery:color_engine_b_controller>;
controllerB.addTooltip(game.localize("modpack.tooltip.color_engine_b_real"));
//TODO: Add JEI descriptions to two controllers

MMEvents.onStructureFormed("color_engine_b", function(event as MachineStructureFormedEvent) {
    var controller = event.controller;
    var world = controller.world;
    var pos = controller.pos;
    val xs as int[]= [2,2,2,2,2,-2,-2,-2,-2,-2,1,0,-1,1,0,-1] as int[];
    val zs as int[]= [2,1,0,-1,-2,2,1,0,-1,-2,2,2,2,-2,-2,-2] as int[];
    var t = 1;
    var counter = 0;
    for i in 0 to 16{
        var pos2 = IBlockPos.create(pos.x+xs[i], pos.y, pos.z+zs[i]);
        var flower = world.getBlock(pos2);
        if(isNull(flower.definition)){
            event.canceled=true;
            return;
        }
        if(flower.definition.id!=<botania:shinyflower>.definition.id){
            event.canceled=true;
            return;
        }
        counter = counter | t;
        t*=2;
    }
    event.canceled = (counter==65535);
});

static commandBlock as IItemStack = <minecraft:command_block>;
// In JEI Recipe, items before the command block are actual ingredients that need to be put onto the plate
// Wools after the command block represents required color rays.
static COLOR_ENGINE_RECIPE_COUNTER as int[] = [11] as int[];
static COLOR_ENGINE_RECIPES_INPUTS as IIngredient[][string] = {} as IIngredient[string];
static COLOR_ENGINE_RECIPES_COLORS as IItemStack[][string] = {} as IItemStack[string];
function addRecipe(output as IItemStack, inputs as IIngredient[], colors as IItemStack[])as void{
    //Use wools to represent color rays
    for wool in colors {
        if(!<minecraft:wool:*>.matches(wool)){
            print("[ERROR]: Color Engine (Type B), addRecipe found wrong arguments. The recipe is not added to the game.");
            print("[ERROR]: The second argument should be a set of wools, representing the color ray required.");
            return;
        }
    }
    var id = "color_engine_b_recipe_nid_" ~ COLOR_ENGINE_RECIPE_COUNTER[0];
    COLOR_ENGINE_RECIPE_COUNTER[0] = COLOR_ENGINE_RECIPE_COUNTER[0] + 1;

    var jeiInputs = [] as IIngredient[];
    for i in inputs {
        jeiInputs = jeiInputs + i;
    }
    jeiInputs = jeiInputs + (commandBlock as IIngredient);
    for i in colors {
        jeiInputs = jeiInputs + (i as IIngredient);
    }

    RecipeBuilder.newBuilder(id, "color_engine_b", 1)
        .addItemInputs(jeiInputs)
        .addItemOutput(output)
        .build();
    COLOR_ENGINE_RECIPES_INPUTS[id]=inputs;
    COLOR_ENGINE_RECIPES_COLORS[id]=colors;
}

MMEvents.onMachinePreTick("color_engine_b", function(event as MachineTickEvent) {
    //TODO
});
