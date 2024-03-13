#reloadable
#priority 1000000004
import mods.zenutils.command.ZenCommand;
import mods.zenutils.command.CommandUtils;
import mods.zenutils.command.IGetTabCompletion;
import mods.zenutils.StringList;
static boolTab as IGetTabCompletion = function(server, sender, pos) {
    return StringList.create(["true","false"]);
};