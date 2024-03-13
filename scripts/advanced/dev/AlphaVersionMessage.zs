#reloadable
if(scripts.Config.ALPHA){
    events.onPlayerLoggedIn(function(event as crafttweaker.event.PlayerLoggedInEvent){
        event.player.sendRichTextStatusMessage(crafttweaker.text.ITextComponent.fromTranslation("modpack.chat.alphaversion"),false);
    });
}