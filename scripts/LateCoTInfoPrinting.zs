#loader contenttweaker
#priority -1919810
import scripts.libs.CotLib as CL;
print("This is a summary for ContentTweaker scripts, showing some useful information");
print("This is the numeral id - name map for ZU Tile Entity:");
var i = 124;
for name in CL.ZU_TILE_ENTITIES{
    print("nid:"~i~";    name:"~name);
    i+=1;
}