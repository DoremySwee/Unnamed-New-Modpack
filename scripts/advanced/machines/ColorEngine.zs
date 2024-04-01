#reloadable
#priority 10000

import crafttweaker.data.IData;
import crafttweaker.block.IBlock;
import crafttweaker.world.IBlockPos;
import crafttweaker.entity.IEntity;
import crafttweaker.entity.IEntityItem;
import crafttweaker.util.IAxisAlignedBB;

import mods.modularmachinery.MMEvents;
import mods.modularmachinery.MachineTickEvent;
import mods.modularmachinery.MachineStructureFormedEvent;

import scripts.libs.basic.Vector3D as V;
import scripts.libs.advanced.Misc as M;
import scripts.libs.advanced.Hungarian;
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
(controllerB as IBlock).definition.resistance = 13.0;
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
static COLOR_ENGINE_RECIPES_OUTPUTS as IItemStack[][string] = {} as IItemStack[string];
static COLOR_ENGINE_RECIPES_INPUTS as IIngredient[][string] = {} as IIngredient[string];
static COLOR_ENGINE_RECIPES_COLORS as IItemStack[][string] = {} as IItemStack[string];
static COLOR_ENGINE_RECIPES_TOLERANCE as double[string] = {} as double[string];
function addRecipe(outputs as IItemStack[], inputs as IIngredient[], colors as IItemStack[], tolerance as double = 0.3)as void{
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
        if(i.hasTransformations) print("[WARNING]: Color Engine Does not support OLD itemTransformers, which require a player parameter.");
    }
    jeiInputs = jeiInputs + (commandBlock as IIngredient);
    for i in colors {
        jeiInputs = jeiInputs + (i as IIngredient);
    }

    RecipeBuilder.newBuilder(id, "color_engine_b", 114)
        .addItemInputs(jeiInputs)
        .addItemOutputs(outputs)
        .addRecipeTooltip(game.localize("modpack.jei.mmce.color_engine_b.tolerance",""~((1.0+tolerance)*100)~"%"))
        .build();
    COLOR_ENGINE_RECIPES_INPUTS[id]=inputs;
    COLOR_ENGINE_RECIPES_OUTPUTS[id]=outputs;
    COLOR_ENGINE_RECIPES_COLORS[id]=colors;
    COLOR_ENGINE_RECIPES_TOLERANCE[id]=tolerance;
}

addRecipe([<minecraft:redstone>],[<botania:manaresource:23>],[<minecraft:wool:14>]);

static getWrongResult as function(int)IItemStack = function (color as int)as IItemStack{
    return <minecraft:dye>.definition.makeStack(color*10);
};

MMEvents.onMachinePreTick("color_engine_b", function(event as MachineTickEvent)as void{
    var controller = event.controller;
    var world = controller.world;
    var pos = controller.pos;
    var data = controller.customData;
    if(!(data has "recipe")){
        data = {
            "recipe":""
        } as IData;
    }

    var aabb = IAxisAlignedBB.create(
        0.0+pos.x, 0.125+pos.y, 0.0+pos.z,
        1.0+pos.x, 0.128+pos.y, 1.0+pos.z
    );
    var entities = world.getEntitiesWithinAABB(aabb) as IEntity[];

    var items = [] as [IItemStack];
    for e in entities{
        if(e instanceof IEntityItem){
            var i as IEntityItem = e;
            items += i.item;
        }
    }
    var recipeId = data.recipe.asString();
    if(COLOR_ENGINE_RECIPES_INPUTS has recipeId){
        var requirements = COLOR_ENGINE_RECIPES_INPUTS[recipeId];
        if(Hungarian.testShapeless(requirements,items)){
            var t as IData = data.progress;
            var progress = t.asIntArray();
            var requirementsW = COLOR_ENGINE_RECIPES_COLORS[recipeId];
            var colors = intArrayOf(16,0);
            var tolerance = 1.0 + COLOR_ENGINE_RECIPES_TOLERANCE[recipeId];
            var charge = 0;
            for w in requirementsW{
                colors[w.metadata] = w.amount;
            }
            for i in 0 to 16{
                charge += progress[i];
            }
            //1. Check if any of the color is over charged
            //2. Check if the recipe is completed
            var completed = true;
            for i in 0 to 16{
                if(progress[i]>tolerance*colors[i]){
                    var size0 = V.sqrt(1.3*charge);
                    var coef = 17.0;
                    var size1 = size0/coef;
                    var size2 = coef*(pow(2.71,size1)-pow(2.71,-size1))/(pow(2.71,size1)+pow(2.71,-size1));
                    controller.customData = {
                        "recipe":"",
                        "progress":intArrayOf(16,0) as IData
                    };
                    world.performExplosion(null, 0.5+pos.x, 0.3+pos.y, 0.5+pos.z, size2, true, true);
                    //TODO: explode with colored manabursts
                    return;
                }
                if(progress[i]<colors[i])completed=false;
            }
            if(completed){
                for e in entities{
                    if(e instanceof IEntityItem){
                        e.removeFromWorld();
                    }
                }
                var outputs = COLOR_ENGINE_RECIPES_OUTPUTS[recipeId] as IItemStack[];
                for o in outputs{
                    M.shout(o.commandString);
                    world.spawnEntity(o.createEntityItem(world, (0.5+pos.x)as float, (0.2+pos.y) as float, (0.5+pos.z)as float));
                }
                var matching = Hungarian.matchShapeless(requirements,items);
                for i in 0 to requirements.length{
                    var ing as IIngredient= requirements[i];
                    if(!ing.hasNewTransformers)continue;
                    var it as IItemStack= items[matching[i]];
                    var result = ing.applyNewTransform(it);
                    if(isNull(result))continue;
                    M.shout(result.commandString);
                    world.spawnEntity(result.createEntityItem(world, (0.5+pos.x)as float, (0.2+pos.y) as float, (0.5+pos.z)as float));
                }
                controller.customData = {
                    "recipe":"",
                    "progress":intArrayOf(16,0) as IData
                };
                //TODO: animation
                return;
            }
            //3. Absorb Mana Burst nearby

            //4. Animation
            return;
        }
    }
    for k,v in COLOR_ENGINE_RECIPES_INPUTS{
        if(Hungarian.testShapeless(v,items)){
            controller.customData = {
                "recipe":k,
                "progress":intArrayOf(16,0) as IData
            };
        }
    }
});

//M.shout(<botania:manaresource:23>.transformReplace(<minecraft:potato>).hasNewTransformers);
//M.shout(<botania:manaresource:23>.transformReplace(<minecraft:potato>).applyNewTransform(<botania:manaresource:23>).commandString);