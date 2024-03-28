#reloadable
#norun
#priority 114514
#loader contenttweaker crafttweaker reloadable
import crafttweaker.data.IData;

static MACHINES_RAW as IData[] = [
    {
        "id":"color_engine_a"
    },
    {
        "id":"color_engine_b",
        "unbreakable":false
    }
] as IData[];

static DEFAULT_MACHINE_DATA as IData = {
    "unbreakable":true,
    "updateCheckRange":3
};

static MACHINES as IData = IData.createEmptyMutableDataMap();
var nid = 123;
for data in MACHINES_RAW{
    MACHINES = MACHINES + {data.id.asString():DEFAULT_MACHINE_DATA+data+{"nid":nid}};
    nid+=1;
}
print("[info] Printing Modpack's Machines");
print(MACHINES);