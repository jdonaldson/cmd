package sys;
import neko.FileSystem;
enum Platform { Windows; Linux; Mac; }
class System{
    static function platform():Platform{
        switch(Sys.systemName()){
            case "Windows": return Windows;
            case "Linux": return Linux;
            case "Mac": return Mac;
            default: {
                         throw "Unsupported platform: " + Sys.systemName();
                         return null;
                      }
        }
    }
    static function dir_separtor(){
        switch(platform()){
            case Windows: return "\\";
            case Linux, Mac: return ":";
        }
    }
    static function path_separator(){
        switch(platform()){
            case Windows: return ";";
            case Linux, Mac: return ":";
        }
    }
    public static function which(cmd:String){
        var path_ext = Sys.getEnv("PATHEXT");
        if (path_ext == null) path_ext = '';
        var exts = path_ext.split(";");

        var paths = Sys.getEnv("PATH");
        if (paths == null) paths  = '';

        for (path in paths.split(path_separator())){
            for (ext in exts){
                var exe = Std.format("${path}/${cmd}${ext}");
                if (FileSystem.exists(exe)) return exe;
            }

        }
        return null;
    }
}
