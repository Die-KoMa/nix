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
    // we need _some_ record here so that lego doesn't fail because it receives an NXDOMAIN
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
    MX("brausefrosch.hosts", 10, "brausefrosch.hosts.die-koma.org."),
    TXT("brausefrosch.hosts", "v=spf1 a ra=postmaster -all"),
    TXT("brausefrosch.hosts", "v=spf1 mx ra=postmaster -all"),

    TXT("_dmarc.brausefrosch", "v=DMARC1; p=reject; rua=mailto:postmaster@brausefrosch.die-koma.org; ruf=mailto:postmaster@brausefrosch.die-koma.org"),
    TXT("202411e._domainkey.brausefrosch", "v=DKIM1; k=ed25519; h=sha256; p=52Ezg3f5qtQ4FsQ2WK2X/nPUZQSm0n2nby1VuxGq4Q0="),
    TXT("202411r._domainkey.brausefrosch", "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0kYMvpqBquVENKL39FEljeXVLNAFO4R3ydsyJwZP0rBIGqLegDSD9VBP24mJ6uZLT3g6GXbUkiUon09S2Ta6aPW9OXT8Cy2UJ4QlxaQoBA1w9uIX1PqxMEr4EmKJyfw2Xb1wQvIxO419YRo0evZNvmDSYLv8HLnVfBlVUJsuTMB9DnZ0ng8PSWVZ8UI/wq3VW+VnpwXsdJY4Pmw6iJ3RkNyKexbyISpDZwPjgUBQ+mvnJSG7ISYCNOEkT5auPb6uDSq7BT01eWy5WMA05sqTabPeccdENHq9n/Len2DgAA+7dSrLG2pSfwU9RaCWW4+aMy0W1E5uWwGIDnglikLXRwIDAQAB"),

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

    MX("@", 10, "brausefrosch.hosts.die-koma.org."),
    TXT("@", "v=spf1 mx ra=postmaster -all"),
    TXT("_dmarc", "v=DMARC1; p=reject; rua=mailto:postmaster@komapedia.org; ruf=mailto:postmaster@komapedia.org"),
    TXT("202411e._domainkey", "v=DKIM1; k=ed25519; h=sha256; p=kPe7mzLvckTRpvIKugKJbzpyiZm15ojeSCP0Ko/Oz0w="),
    TXT("202411r._domainkey", "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyCPH5+cAh6vzGuNeQDfZa/D296+edvyGeb/FGlyg1kJNuafVHEBy4d3Ecpf0nu+kspwdyTxk+hWRmqEV6tkvhtY3e2WryKvaY+0KMQaNZRvaAEF3fJ3sGNwCqFhi7hZe0/wglLKuEup1sWNGGEVH+W+z6zgVnNsxLfY/MoPdR91K7ZK6BFbxqVZbg81tNScOyQFzXrR9T6WVZDrJJw+qQRsqbJqK2TI6CLjzGHsnwAUcc3jZub0ZGPACM/alqlcKknW8UoDnKeVsoMGJJMqjStE9gqwfVXGfrW8EOtggA/0KfrPToKvUzOmLjiDeHUYz0ZEf1p14YCwcLf1yrgkXnQIDAQAB"),

    CNAME_ACME("de", "brausefrosch"),
    CNAME_ACME("file", "brausefrosch"),
    CNAME_ACME("www", "brausefrosch"),
    []
);
