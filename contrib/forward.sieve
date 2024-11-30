require "editheader";
require "variables";
require "envelope";

if envelope :matches "to" "*" { set "user_email" "${1}"; }
if envelope :matches "from" "*" { set "from_email" "${1}"; }

addheader "X-Original-From" "${from_email}";
deleteheader "from";
addheader "From" "${user_email}";
redirect "homepage@die-koma.org";
