#loader contenttweaker
import scripts.libs.CotLib as CL;
//Broken Runes
    static runeNames as string[] = ["aer","aqua","ignis","terra"];
    for name in runeNames {CL.createItem("broken_"~name~"_rune");}
    CL.createBlock("ignis_living_rock",{"lightValue":4},CL.MISCTAB,<blockmaterial:rock>);
//Netherrack Heating
    for i in 1 to 5{
        var id = "heated_netherrack_"~i;
        CL.createBlock(id,{"lightValue":i/2},CL.MISCTAB,<blockmaterial:rock>);
    }
//Misc
    CL.createItem("afflatus_of_crafting");
    CL.createItem("complete_afflatus_of_crafting",{"glowing":true});
//Shards
    for t in ["aer","aqua","ordo","perditio","terra","ignis","balanced","nether","ender"] as string[]{
        CL.createItem("shard_"~t);
    }