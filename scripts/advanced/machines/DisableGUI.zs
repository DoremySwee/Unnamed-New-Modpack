#reloadable
static IDLists as string[] = [
    "modularmachinery:color_engine_a_controller",
    "modularmachinery:color_engine_b_controller"
] as string[];
events.onPlayerInteractBlock(function(event as crafttweaker.event.PlayerInteractBlockEvent){
    var block = event.block;
    if(isNull(block) || isNull(block.definition))return;
    if(IDLists has block.definition.id)event.useBlock="DENY";
});