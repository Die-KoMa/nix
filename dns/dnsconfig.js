"use strict";
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
var REG_NONE = NewRegistrar("none");
var REG_INWX = NewRegistrar("inwx");
var DNS_INWX = NewDnsProvider("inwx");
var DNS_HE = NewDnsProvider("he");
var DNS_DESEC = NewDnsProvider("desec");
function ACME(recordName, target, options) {
    if (options === void 0) { options = []; }
    var challengeRecordName = "_acme-challenge" + (recordName === "@" ? "" : "." + recordName);
    var normalizedTarget = target[target.length - 1] === "."
        ? target
        : target + ".desec.die-koma.org.";
    return [
        CNAME.apply(void 0, __spreadArray([challengeRecordName,
            "_acme-challenge." + normalizedTarget], options, false)),
    ];
}
function CNAME_HOST(recordName, target, options) {
    if (options === void 0) { options = []; }
    var targetCname = target[target.length - 1] === "."
        ? target
        : target + ".hosts.die-koma.org.";
    return CNAME.apply(void 0, __spreadArray([recordName, targetCname], options, false));
}
function CNAME_ACME(recordName, target, options) {
    if (options === void 0) { options = []; }
    return [
        CNAME_HOST(recordName, target, options),
        ACME(recordName, target, options),
    ];
}
function INWX_PARKING(recordName, options) {
    if (options === void 0) { options = []; }
    return A.apply(void 0, __spreadArray([recordName, "185.181.104.242"], options, false));
}
function HOST(recordName, host, options) {
    if (options === void 0) { options = []; }
    if (host === "brausefrosch") {
        return [
            A.apply(void 0, __spreadArray([recordName, "78.46.187.139"], options, false)),
            AAAA.apply(void 0, __spreadArray([recordName, "2a01:4f8:c012:de06::1"], options, false)),
        ];
    }
    PANIC("HOST with unknown hostname: " + host);
}
function CAA_LETSENCRYPT(recordName) {
    if (recordName === void 0) { recordName = "@"; }
    return CAA_BUILDER({
        label: recordName,
        issue: ["letsencrypt.org;validationmethods=dns-01"],
        issue_critical: true,
    });
}
DEFAULTS(NAMESERVER_TTL("1d"), DefaultTTL("1h"));
D("he.die-koma.org", REG_NONE, DnsProvider("he"), NAMESERVER_TTL("2d"), IGNORE("_acme-challenge.*", "TXT"));
D("desec.die-koma.org", REG_NONE, DnsProvider("desec"), NAMESERVER_TTL("1d"), IGNORE("_acme-challenge.*", "TXT"), 
// we need _some_ record here so that lego doesn't fail because it receives an NXDOMAIN
A("_acme-challenge.brausefrosch", "127.0.0.1"));
D("die-koma.org", REG_NONE, DnsProvider("inwx"), CAA_LETSENCRYPT(), NS("he", "ns1.he.net."), NS("he", "ns2.he.net."), NS("he", "ns3.he.net."), NS("he", "ns4.he.net."), NS("he", "ns5.he.net."), NS("desec", "ns1.desec.io."), NS("desec", "ns2.desec.org."), MX("@", 10, "brausefrosch.hosts.die-koma.org.", TTL(86400)), TXT("@", "v=spf1 mx ra=postmaster -all"), TXT("_dmarc", "v=DMARC1; p=reject; rua=mailto:postmaster@die-koma.org; ruf=mailto:postmaster@die-koma.org"), TXT("202503e._domainkey", "v=DKIM1; k=ed25519; h=sha256; p=Sn+LyM14oE9CkikTZuKldwT9Xo5aiwFbB+VIMfGZPjI="), TXT("202503r._domainkey", "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxMZ8aB44058PE1TVurqo7oKSxJTweFkJAwdYwsZpicD44jVJ9PK1MkDa3kYpl016Ykv0azDK+cH4DTvuwE7T0rw/qXJEAQpqsmkS6kGQWwnPDJDNJZisEG0PlMbk+HM+C301Pv+7St8alNfyIK0ckfuNyf03h4gnfv4UQCd5GLYNlIqZRbmvwSyGSwkeqPlXT6v3ohZQ3vL0o0I6s+ArCc379f1Mxv5NiwpYgTyHRab7RmRJeWAD2kafrjNhAWWAAcibsFxVE8ZtysbF2m2NRAcraYWPZBu9bXFajpbapzqrrH55aV0T8DFnf3yPkcmAgwpm6RjS5XvUHKfD58sUvQIDAQAB"), TXT("_smtp.tls", "v=TLSRPTv1; rua=mailto:postmaster@die-koma.org"), HOST("@", "brausefrosch"), ACME("@", "brausefrosch"), TXT("brausefrosch.hosts", "v=spf1 a ra=postmaster -all"), HOST("brausefrosch.hosts", "brausefrosch"), ACME("brausefrosch.hosts", "brausefrosch"), CNAME("anmeldung", "pretix.fachschaften.org."), CNAME_HOST("cloud", "brausefrosch"), CNAME_HOST("matrix", "brausefrosch"), CNAME_HOST("new", "brausefrosch"), CNAME_HOST("www", "brausefrosch"), CNAME_HOST("aks", "brausefrosch"));
D("komapedia.org", REG_NONE, DnsProvider("inwx"), CAA_LETSENCRYPT(), HOST("@", "brausefrosch"), ACME("@", "brausefrosch"), MX("@", 10, "brausefrosch.hosts.die-koma.org.", TTL(86400)), TXT("@", "v=spf1 mx ra=postmaster -all"), TXT("_dmarc", "v=DMARC1; p=reject; rua=mailto:postmaster@komapedia.org; ruf=mailto:postmaster@komapedia.org"), TXT("202411e._domainkey", "v=DKIM1; k=ed25519; h=sha256; p=kPe7mzLvckTRpvIKugKJbzpyiZm15ojeSCP0Ko/Oz0w="), TXT("202411r._domainkey", "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyCPH5+cAh6vzGuNeQDfZa/D296+edvyGeb/FGlyg1kJNuafVHEBy4d3Ecpf0nu+kspwdyTxk+hWRmqEV6tkvhtY3e2WryKvaY+0KMQaNZRvaAEF3fJ3sGNwCqFhi7hZe0/wglLKuEup1sWNGGEVH+W+z6zgVnNsxLfY/MoPdR91K7ZK6BFbxqVZbg81tNScOyQFzXrR9T6WVZDrJJw+qQRsqbJqK2TI6CLjzGHsnwAUcc3jZub0ZGPACM/alqlcKknW8UoDnKeVsoMGJJMqjStE9gqwfVXGfrW8EOtggA/0KfrPToKvUzOmLjiDeHUYz0ZEf1p14YCwcLf1yrgkXnQIDAQAB"), TXT("_smtp.tls", "v=TLSRPTv1; rua=mailto:postmaster@komapedia.org"), CNAME_HOST("de", "brausefrosch"), CNAME_HOST("file", "brausefrosch"), CNAME_HOST("www", "brausefrosch"));
