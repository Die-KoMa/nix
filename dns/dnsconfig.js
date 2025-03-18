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

function CAA_LETSENCRYPT(record_name) {
  return CAA_BUILDER({
    label: record_name || "@",
    issue: ["letsencrypt.org;validationmethods=dns-01"],
    issue_critical: true,
  });
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

    CAA_LETSENCRYPT(),

    NS("he", "ns1.he.net."),
    NS("he", "ns2.he.net."),
    NS("he", "ns3.he.net."),
    NS("he", "ns4.he.net."),
    NS("he", "ns5.he.net."),

    NS("desec", "ns1.desec.io."),
    NS("desec", "ns2.desec.org."),

    MX("@", 10, "brausefrosch.hosts.die-koma.org.", TTL(86400)),
    TXT("@", "v=spf1 mx ra=postmaster -all"),
    TXT("_dmarc", "v=DMARC1; p=reject; rua=mailto:postmaster@die-koma.org; ruf=mailto:postmaster@die-koma.org"),
    TXT("202503e._domainkey", "v=DKIM1; k=ed25519; h=sha256; p=Sn+LyM14oE9CkikTZuKldwT9Xo5aiwFbB+VIMfGZPjI="),
    TXT("202503r._domainkey", "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxMZ8aB44058PE1TVurqo7oKSxJTweFkJAwdYwsZpicD44jVJ9PK1MkDa3kYpl016Ykv0azDK+cH4DTvuwE7T0rw/qXJEAQpqsmkS6kGQWwnPDJDNJZisEG0PlMbk+HM+C301Pv+7St8alNfyIK0ckfuNyf03h4gnfv4UQCd5GLYNlIqZRbmvwSyGSwkeqPlXT6v3ohZQ3vL0o0I6s+ArCc379f1Mxv5NiwpYgTyHRab7RmRJeWAD2kafrjNhAWWAAcibsFxVE8ZtysbF2m2NRAcraYWPZBu9bXFajpbapzqrrH55aV0T8DFnf3yPkcmAgwpm6RjS5XvUHKfD58sUvQIDAQAB"),
    TXT("_smtp.tls", "v=TLSRPTv1; rua=mailto:postmaster@die-koma.org"),

    HOST("@", "brausefrosch"),
    ACME("@", "brausefrosch"),
    TXT("brausefrosch.hosts", "v=spf1 a ra=postmaster -all"),

    HOST("brausefrosch.hosts", "brausefrosch"),
    ACME("brausefrosch.hosts", "brausefrosch"),

    CNAME_ACME("brausefrosch", "brausefrosch"),  // can be deleted soon

    CNAME("anmeldung", "pretix.fachschaften.org."),

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

    CAA_LETSENCRYPT(),

    HOST("@", "brausefrosch"),
    ACME("@", "brausefrosch"),

    MX("@", 10, "brausefrosch.hosts.die-koma.org.", TTL(86400)),
    TXT("@", "v=spf1 mx ra=postmaster -all"),
    TXT("_dmarc", "v=DMARC1; p=reject; rua=mailto:postmaster@komapedia.org; ruf=mailto:postmaster@komapedia.org"),
    TXT("202411e._domainkey", "v=DKIM1; k=ed25519; h=sha256; p=kPe7mzLvckTRpvIKugKJbzpyiZm15ojeSCP0Ko/Oz0w="),
    TXT("202411r._domainkey", "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyCPH5+cAh6vzGuNeQDfZa/D296+edvyGeb/FGlyg1kJNuafVHEBy4d3Ecpf0nu+kspwdyTxk+hWRmqEV6tkvhtY3e2WryKvaY+0KMQaNZRvaAEF3fJ3sGNwCqFhi7hZe0/wglLKuEup1sWNGGEVH+W+z6zgVnNsxLfY/MoPdR91K7ZK6BFbxqVZbg81tNScOyQFzXrR9T6WVZDrJJw+qQRsqbJqK2TI6CLjzGHsnwAUcc3jZub0ZGPACM/alqlcKknW8UoDnKeVsoMGJJMqjStE9gqwfVXGfrW8EOtggA/0KfrPToKvUzOmLjiDeHUYz0ZEf1p14YCwcLf1yrgkXnQIDAQAB"),
    TXT("_smtp.tls", "v=TLSRPTv1; rua=mailto:postmaster@komapedia.org"),

    CNAME_ACME("de", "brausefrosch"),
    CNAME_ACME("file", "brausefrosch"),
    CNAME_ACME("www", "brausefrosch"),
    []
);

// Local Variables:
// apheleia-mode: nil
// End:
