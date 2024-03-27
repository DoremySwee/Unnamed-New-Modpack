#reloadable
#priority 114514
#loader contenttweaker crafttweaker reloadable
import crafttweaker.data.IData;

static MACHINES_RAW as IData[] = [
    {
        "id":"color_engine_a",
        "unbreakable":true
    },
    {
        "id":"color_engine_b",
        "unbreakable":false
    }
] as IData[];

static MACHINES as IData = IData.createEmptyMutableDataMap();
var nid = 123;
for data in MACHINES_RAW{
    MACHINES = MACHINES + {data.id.asString():data+{"nid":nid}};
    nid+=1;
}
print("[info] Printing Modpack's Machines");
print(MACHINES);