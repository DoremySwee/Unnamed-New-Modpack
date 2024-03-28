#loader contenttweaker
#norun
import crafttweaker.data.IData;
import scripts.advanced.machines.Register;
import mods.contenttweaker.VanillaFactory;

for name, data in Register.MACHINES.asMap(){
    val te = VanillaFactory.createActualTileEntity(data.nid.asInt());
    val block = VanillaFactory.createExpandBlock(data.id.asString(), <blockmaterial:iron>);

    block.tileEntity = te;
    block.creativeTab = <creativetab:misc>;
    if(data.unbreakable.asBool()){
        block.blockResistance = 1919810.0;
        block.blockHardness=-1.0;
        block.witherProof=false;
    }
    block.register();
}