#reloadable
import mods.botaniatweaks.Agglomeration as Agg;
import scripts.libs.recipe.Transcript as T;
import scripts.libs.recipe.Mapping as Mp;
import scripts.libs.recipe.Misc as M;
import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemDefinition;

static DIFF as int = scripts.Config.DIFF;
static manaCoef as double = (3.0+DIFF)/5;

//Duplication
    static craftingDuplication as IItemStack[] = [
        <appliedenergistics2:nether_quartz_wrench>,
        <appliedenergistics2:creative_energy_cell>,
        <botania:terrasword>.withTag({Unbreakable: 1}),
        <minecraft:lever>,
        <minecraft:piston>,
        <appliedenergistics2:quartz_block>,
        <minecraft:sticky_piston>,
        <appliedenergistics2:quartz_slab>,
        <appliedenergistics2:quartz_vibrant_glass>,
        <botania:prism>
    ];
    for i in craftingDuplication{M.dup(i);}

//Bans
    recipes.remove(<minecraft:crafting_table>);
    recipes.remove(<botania:opencrate:1>);
    recipes.remove(<chisel:block_charcoal:*>);
    recipes.remove(<chisel:block_charcoal1:*>);
    recipes.remove(<chisel:block_charcoal2:*>);
    furnace.remove(<minecraft:iron_nugget>);
    recipes.remove(<betterbuilderswands:wandstone>);
    for fl in ["manastar","puredaisy","solegnolia","bellethorn","dreadthorn","hydroangeas","endoflame"]as string[]{
        mods.botania.Apothecary.removeRecipe(fl);
    }

//Pickaxe
    var quartz = <appliedenergistics2:quartz_block>;
    var gravel = <minecraft:gravel>;
    var sand = <minecraft:sand>;
    var sapling = <minecraft:sapling>;
    var deadBush = <minecraft:deadbush>;
    var bedRock = <minecraft:bedrock>;
    var stone = <minecraft:stone>;
    var cobbleStone = <minecraft:cobblestone>;
    var stone1 = DIFF<4?cobbleStone:stone;
    var centre1 = DIFF<3?quartz:stone1;
    var centre2 = DIFF<3?quartz:sand;
    Agg.addRecipe(deadBush,[sapling],200*manaCoef,0x404000, 0x008000,
        centre1,bedRock,stone1,centre1,bedRock,gravel);
    Agg.addRecipe(deadBush,[sapling],200*manaCoef,0x404000, 0x008000,
        quartz,bedRock,gravel,quartz,bedRock,sand);
    Agg.addRecipe(<minecraft:stone_pickaxe>,
        [sapling,<minecraft:flint>*3,<minecraft:stick>*2],
        1300*manaCoef,0x404000,0x80D080,
        centre2,bedRock,stone1,centre2,bedRock,sand);

//ManaPool
    var infDust = <enderio:item_material:20>;
    var powder = <minecraft:gunpowder>;
    var output1 = <botania:manaresource:23>; //powder;// Check if there is better output
    var pool1 = <botania:pool:2>;
    var pool2 = <botania:pool>;
    var quartzSlab = <appliedenergistics2:quartz_slab>;
    //furnace & glass
    if(DIFF<3) Agg.addRecipe(
        deadBush,[sapling],1500*manaCoef,0x202020,0x808080,
        sand,cobbleStone,cobbleStone,
        <minecraft:furnace>,<minecraft:glass>,<minecraft:glass>
    );
    else Agg.addRecipe(
        deadBush,[sapling],1500*manaCoef,0x202020,0x808080,
        sand,cobbleStone,cobbleStone,
        <minecraft:glass>,<minecraft:glass>,<minecraft:glass>
    );
    //pool1
    if(DIFF<1) Agg.addRecipe(output1,[infDust],600*manaCoef,0x202020,0xD0D0D0,
        quartzSlab,stone,quartz,pool1,cobbleStone,quartz);
    else if(DIFF<4) Agg.addRecipe(output1,[infDust],600*manaCoef,0x202020,0xD0D0D0,
        quartzSlab,stone,stone,pool1,cobbleStone,cobbleStone);
    else Agg.addRecipe(output1,[infDust*5],600*manaCoef,0x202020,0xD0D0D0,
        stone1,bedRock,stone,pool1,bedRock,cobbleStone);
    //pool2
    if(DIFF==0 || DIFF==4) Agg.addRecipe(output1,[infDust],2000*manaCoef,0x6060C0,0xD0D0F0,
        pool1,quartzSlab,pool1,pool2,quartzSlab,pool1);
    else if(DIFF==1) Agg.addRecipe(output1,[infDust],2000*manaCoef,0x6060C0,0xD0D0F0,
        pool1,quartzSlab,pool1,pool2,quartzSlab,quartzSlab);
    else Agg.addRecipe(output1,[infDust],2000*manaCoef,0x6060C0,0xD0D0F0,
        pool1,pool1,pool1,pool2,quartzSlab,pool1);

    //Usage
    T.bot.infusion(<minecraft:iron_pickaxe>,<minecraft:stone_pickaxe>,700*manaCoef);
    T.bot.infusion(<minecraft:dye:15>,sapling,100*manaCoef);

    //dup petal
    for i in 0 to 16{
        M.dupMana(<botania:petal>.definition.makeStack(i));
    }

//Tinker
    recipes.addShaped(<tconstruct:tooltables:3>,[[<tconstruct:pattern>],[<tconstruct:tooltables:2>]]);
    recipes.addShapeless(<tconstruct:rack:1>,[M.reuse(<tconstruct:pattern>.withTag({PartType: "tconstruct:tough_tool_rod"})),<minecraft:log>]);
    T.bot.infusion(<minecraft:hardened_clay>,<tconstruct:dried_clay>,1000);
    furnace.remove(<tconstruct:materials>);
    furnace.addRecipe(<tconstruct:materials>,<tconstruct:materials:2>);
//Crate
    var grass=<minecraft:tallgrass:1>;
    var water = <liquid:water>;
    Agg.addRecipe(deadBush,[sapling],1000*manaCoef,0x00FF00,0x0000FF,
        grass,grass,grass,water,deadBush,deadBush
    );
    if(DIFF<3) Agg.addRecipe(deadBush,[sapling],2000*manaCoef,0xAAAAAA,0xAAAAFF,
        <minecraft:stained_glass:11>,pool2,<minecraft:stained_hardened_clay:3>,
        <botania:opencrate:1>,pool1,<minecraft:clay>);
    else Agg.addRecipe(<minecraft:clay>,[<minecraft:stained_hardened_clay:3>],2000*manaCoef,0xAAAAAA,0xAAAAFF,
        water,pool2,<minecraft:stained_glass:11>,
        <botania:opencrate:1>,pool1,sand);
    
//Pure Daisy
    var daisy = <botania:specialflower>.withTag({type: "puredaisy"});
    var petalBlock = <botania:petalblock>;
    var flower1 =<botania:flower>;
    var flower2 = <botania:doubleflower1>;
    var manaGlass = <botania:managlass>;
    if(DIFF<2) Agg.addRecipe(daisy,[flower1],1000,0xAAAAFF,0xDDDDFF,
        water,manaGlass,flower2,
        manaGlass,<minecraft:glass>,flower1);
    else Agg.addRecipe(daisy,[sapling,flower1],1500,0xAAAAFF,0xDDDDFF,
        petalBlock,water,flower1,
        manaGlass,manaGlass,manaGlass);

//Coal, Redstone, Netherrock, Lava
    var charcoal = <minecraft:coal:1>;
    var coal = <minecraft:coal>;
    var coalOre = <minecraft:coal_ore>;
    var coalBlock = <minecraft:coal_block>;
    var ccB = <chisel:block_charcoal>;
    var edge1 = DIFF<3?<minecraft:log>:ccB;
    Agg.addRecipe(coal,[charcoal],700*manaCoef,0xAA9999,0xFFAAAA,
        stone,edge1,stone,coalOre,edge1,cobbleStone);
    var flower3 = DIFF<2?<botania:doubleflower2:6>:<botania:flower:14>;
    var redstoneOre = <minecraft:redstone_ore>;
    var redstone = <minecraft:redstone>;
    Agg.addRecipe(<botania:dye:15>,[<botania:dye:14>],1500*manaCoef,0x777777,0xFF8888,
        gravel,coalOre,flower3,sand,redstoneOre,flower1); //ToBalance: flower1 -> flower3
    