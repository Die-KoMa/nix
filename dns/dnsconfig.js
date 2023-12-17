var REG_NONE = NewRegistrar("none");
var REG_INWX = NewRegistrar("inwx");
var DNS_INWX = NewDnsProvider("inwx");
var DNS_HE = NewDnsProvider("he");


function ACME(record_name, target) {
  record_name = "_acme-challenge" + (record_name == "@" ? "" : "." + record_name);
  target = target[target.length-1] == "." ? target : target + ".he.die-koma.org.";
  return [ CNAME(record_name, "_acme-challenge."+target) ];
}

function CNAME_HOST(record_name, target) {
  target_cname = target[target.length-1] == "." ? target : target + ".hosts.die-koma.org.";
  return CNAME(record_name, target_cname);
}

function CNAME_ACME(record_name, target) {
  return [
    CNAME_HOST(record_name, target),
    ACME(record_name, target)
  ];
}

function INWX_PARKING(record_name) {
  return A(record_name, "185.181.104.242")
}

function HOST(record_name, host) {
  if(host == "brausefrosch") { return [
    A(record_name, "78.46.187.139"),
    AAAA(record_name, "2a01:4f8:c012:de06::1")
  ]; }
  if(host == "brausefroschlg") { return [
    A(record_name, "141.30.30.154"),
  ]; }
  if(host == "honigkuchenpferd") { return [
    A(record_name, "131.234.28.83"),
  ]; }
  PANIC("HOST with unknown hostname: "+ host);
}


DEFAULTS(
  NAMESERVER_TTL("1d"),
  DefaultTTL("1h"),
  []
)


D("he.die-koma.org", REG_NONE, DnsProvider("he"),
  NAMESERVER_TTL("2d"),
  IGNORE("_acme-challenge.*", "TXT"),
  []
)

D("die-koma.org", REG_NONE, DnsProvider("inwx"),
  NS("he", "ns1.he.net."),
  NS("he", "ns2.he.net."),
  NS("he", "ns3.he.net."),
  NS("he", "ns4.he.net."),
  NS("he", "ns5.he.net."),

  MX("@", 0, "mx0.stugen.de."),
  MX("@", 0, "mx1.stugen.de."),

  HOST("@", "brausefrosch"),
  ACME("@", "brausefrosch"),

  HOST("*", "honigkuchenpferd"),

  HOST("brausefrosch.hosts", "brausefrosch"),
  HOST("brausefroschlg.hosts", "brausefroschlg"),
  HOST("honigkuchenpferd.hosts", "honigkuchenpferd"),

  CNAME_HOST("51", "honigkuchenpferd"),
  CNAME_HOST("*.51", "honigkuchenpferd"),

  CNAME("anmeldung", "pretix.fachschaften.org."),

  CNAME_HOST("komapedia", "honigkuchenpferd"),
  CNAME_HOST("matrix.brausefrosch", "brausefroschlg"),
  CNAME_HOST("wiki", "honigkuchenpferd"),

  CNAME_ACME("brausefrosch", "brausefrosch"),
  CNAME_ACME("brausefroschlg", "brausefroschlg"),
  CNAME_ACME("cloud", "brausefrosch"),
  CNAME_ACME("matrix", "brausefroschlg"),
  CNAME_ACME("new", "brausefrosch"),
  CNAME_ACME("www", "brausefrosch"),

  []
);

D("komapedia.org", REG_NONE, DnsProvider("inwx"),
  HOST("@", "brausefrosch"),
  ACME("@", "brausefrosch"),

  HOST("*", "brausefrosch"),

  CNAME_ACME("42", "brausefrosch"),
  CNAME_ACME("de", "brausefrosch"),
  CNAME_ACME("file", "brausefrosch"),
  CNAME_ACME("www", "brausefrosch"),

  []
)
