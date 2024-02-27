var REG_NONE = NewRegistrar("none");
var REG_INWX = NewRegistrar("inwx");
var DNS_INWX = NewDnsProvider("inwx");
var DNS_HE = NewDnsProvider("he");
var DNS_DESEC = NewDnsProvider("desec");

function ACME(record_name, target, options) {
    record_name =
        "_acme-challenge" + (record_name == "@" ? "" : "." + record_name);
    target =
        target[target.length - 1] == "."
            ? target
            : target + ".desec.die-koma.org.";
    return [CNAME(record_name, "_acme-challenge." + target, options || [])];
}

function CNAME_HOST(record_name, target, options) {
    target_cname =
        target[target.length - 1] == "."
            ? target
            : target + ".hosts.die-koma.org.";
    return CNAME(record_name, target_cname, options || []);
}

function CNAME_ACME(record_name, target, options) {
    return [
        CNAME_HOST(record_name, target, options || []),
        ACME(record_name, target, options || []),
    ];
}

function INWX_PARKING(record_name, options) {
    return A(record_name, "185.181.104.242", options || []);
}

function HOST(record_name, host, options) {
    if (host == "brausefrosch") {
        return [
            A(record_name, "78.46.187.139", options || []),
            AAAA(record_name, "2a01:4f8:c012:de06::1", options || []),
        ];
    }
    PANIC("HOST with unknown hostname: " + host);
}

DEFAULTS(NAMESERVER_TTL("1d"), DefaultTTL("1h"), []);

D(
    "he.die-koma.org",
    REG_NONE,
    DnsProvider("he"),
    NAMESERVER_TTL("2d"),
    IGNORE("_acme-challenge.*", "TXT"),
    []
);

D(
    "desec.die-koma.org",
    REG_NONE,
    DnsProvider("desec"),
    NAMESERVER_TTL("1d"),
    IGNORE("_acme-challenge.*", "TXT"),
    A("_acme-challenge.brausefrosch", "127.0.0.1"),
    []
);

D(
    "die-koma.org",
    REG_NONE,
    DnsProvider("inwx"),

    NS("he", "ns1.he.net."),
    NS("he", "ns2.he.net."),
    NS("he", "ns3.he.net."),
    NS("he", "ns4.he.net."),
    NS("he", "ns5.he.net."),

    NS("desec", "ns1.desec.io."),
    NS("desec", "ns2.desec.org."),

    MX("@", 0, "mx0.stugen.de."),
    MX("@", 0, "mx1.stugen.de."),

    HOST("@", "brausefrosch"),
    ACME("@", "brausefrosch"),

    HOST("brausefrosch.hosts", "brausefrosch"),

    CNAME("anmeldung", "pretix.fachschaften.org."),

    CNAME_ACME("brausefrosch", "brausefrosch"),
    CNAME_ACME("cloud", "brausefrosch"),
    CNAME_ACME("matrix", "brausefrosch"),
    CNAME_ACME("new", "brausefrosch"),

    CNAME_ACME("www", "brausefrosch"),

    []
);

D(
    "komapedia.org",
    REG_NONE,
    DnsProvider("inwx"),
    HOST("@", "brausefrosch"),
    ACME("@", "brausefrosch"),

    CNAME_ACME("de", "brausefrosch"),
    CNAME_ACME("file", "brausefrosch"),
    CNAME_ACME("www", "brausefrosch"),
    []
);
