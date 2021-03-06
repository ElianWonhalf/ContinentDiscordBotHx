package model.commandlist;

import Math;
import config.Config;
import StringTools;
import StringTools;
import utils.DiscordUtils;
import nodejs.http.HTTP.HTTPMethod;
import utils.Logger;
import haxe.Json;
import utils.HttpUtils;
import translations.LangCenter;

class UD implements ICommandDefinition {
    public var paramsUsage = '(word or expression) *(definition number)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.ud.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 0) {
            var definitionIndex: Int = 1;

            if (!Math.isNaN(cast args[args.length - 1])) {
                definitionIndex = cast args.pop();
            }

            if (definitionIndex > 0) {
                definitionIndex--;
            } else {
                definitionIndex = 0;
            }

            var search = StringTools.urlEncode(args.join(' '));

            HttpUtils.query(false, 'api.urbandictionary.com', '/v0/define?term=' + search, cast HTTPMethod.Get, function (data: String) {
                var response: Dynamic = null;

                try {
                    response = Json.parse(data);
                } catch (err: Dynamic) {
                    Logger.exception(err);
                }

                if (response != null && Reflect.hasField(response, 'list')) {
                    var list: Array<Dynamic> = cast response.list;

                    if (list.length > 0) {
                        if (definitionIndex > list.length - 1) {
                            definitionIndex = list.length - 1;
                        }

                        var definition: String = StringTools.trim(list[definitionIndex].definition);
                        var example: String = StringTools.trim(list[definitionIndex].example);
                        var link: String = StringTools.trim(list[definitionIndex].permalink);
                        var messageWithoutDefinition: String = author + ' => ...\n\n<' + link + '>';
                        var length: Int = Config.MESSAGE_MAX_LENGTH - messageWithoutDefinition.length;

                        _context.rawSendToChannel(author + ' => ' + definition.substr(0, length) + '...\n\n<' + link + '>');
                    } else {
                        _context.sendToChannel('model.commandlist.ud.process.404', cast [author]);
                    }
                } else {
                    _context.sendToChannel('model.commandlist.ud.process.fail', cast [author]);
                }
            });
        } else {
            _context.sendToChannel('model.commandlist.ud.process.syntax_error', cast [author]);
        }
    }
}
