require "editheader";
require "variables";


deleteheader "from";
addheader "X-Original-From" "${envelope.from}";
addheader "From" "${envelope.to}";
redirect "homepage@die-koma.org";
