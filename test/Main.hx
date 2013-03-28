import cmd.Cmd;
import cmd.MacroCmd;
class Main {
    static function main() {
        var c2 = new Cmd();
        c2.echo(['foo']).stdout(function(x) trace(x));
        //var g = new Cmd();
        //g.echo(["hi"]).stdout(function(x) trace(x));
    }
}



