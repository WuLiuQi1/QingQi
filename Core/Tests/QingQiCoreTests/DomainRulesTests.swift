import XCTest
@testable import QingQiCore

final class DomainRulesTests: XCTestCase {
    func testNormalizesCaseWhitespaceAndTrailingDot() throws {
        XCTAssertEqual(try DomainName("  ADS.Example.COM.\n").value, "ads.example.com")
    }

    func testRejectsNonASCII() {
        XCTAssertThrowsError(try DomainName("广告.example"))
    }

    func testAcceptsPunycodeASCIISyntax() throws {
        XCTAssertEqual(try DomainName("xn--fsqu00a.example").value, "xn--fsqu00a.example")
    }

    func testRejectsURLsAndWildcardSyntax() {
        for input in [
            "https://ads.example.com", "*.example.com", "||example.com^",
            "example.com/path", "example.com:443", "u@example.com",
            "example.com?q=1", "example.com#fragment"
        ] {
            XCTAssertThrowsError(try DomainName(input), input)
        }
    }

    func testRejectsMalformedNames() {
        for input in ["", "localhost", ".example.com", "a..example.com",
                      "example.com..", "-a.example", "a-.example", "a_b.example"] {
            XCTAssertThrowsError(try DomainName(input), input)
        }
    }

    func testRejectsIPAddresses() {
        XCTAssertThrowsError(try DomainName("127.0.0.1"))
        XCTAssertThrowsError(try DomainName("[::1]"))
    }

    func testRejectsLongLabels() {
        XCTAssertThrowsError(try DomainName(String(repeating: "a", count: 64) + ".example"))
    }

    func testRejectsLongDomains() {
        let long = Array(repeating: String(repeating: "a", count: 63), count: 4).joined(separator: ".")
        XCTAssertThrowsError(try DomainName(long))
    }

    func testDotBoundarySuffixMatching() throws {
        let parent = try DomainName("example.com")
        XCTAssertTrue(try DomainName("ads.example.com").isEqualToOrSubdomain(of: parent))
        XCTAssertTrue(try DomainName("example.com").isEqualToOrSubdomain(of: parent))
        XCTAssertFalse(try DomainName("notexample.com").isEqualToOrSubdomain(of: parent))
        XCTAssertFalse(try DomainName("example.com.evil.test").isEqualToOrSubdomain(of: parent))
    }

    func testDeduplicatesAndSorts() throws {
        let result = try DomainRuleCompiler.compile(
            blocked: ["b.example", "A.example", "a.example."], exclusions: []
        )
        XCTAssertEqual(result.blockedDomains, ["a.example", "b.example"])
    }

    func testSameDomainExceptionSuppressesBlock() throws {
        let result = try DomainRuleCompiler.compile(
            blocked: ["ads.example.com"], exclusions: ["ADS.example.com."]
        )
        XCTAssertTrue(result.blockedDomains.isEmpty)
        XCTAssertEqual(result.suppressed.count, 1)
    }

    func testChildExceptionSuppressesParentBlock() throws {
        let result = try DomainRuleCompiler.compile(
            blocked: ["example.com", "ads.other.example"], exclusions: ["pay.example.com"]
        )
        XCTAssertEqual(result.blockedDomains, ["ads.other.example"])
        XCTAssertEqual(result.suppressed.first?.blocked, "example.com")
    }

    func testParentExceptionSuppressesChildBlock() throws {
        let result = try DomainRuleCompiler.compile(
            blocked: ["ads.example.com"], exclusions: ["example.com"]
        )
        XCTAssertTrue(result.blockedDomains.isEmpty)
    }

    func testUnrelatedExceptionDoesNotSuppress() throws {
        let result = try DomainRuleCompiler.compile(
            blocked: ["ads.example.com"], exclusions: ["notexample.com"]
        )
        XCTAssertEqual(result.blockedDomains, ["ads.example.com"])
    }

    func testEmptyCompilation() throws {
        let result = try DomainRuleCompiler.compile(blocked: [], exclusions: [])
        XCTAssertTrue(result.blockedDomains.isEmpty)
        XCTAssertTrue(result.suppressed.isEmpty)
    }

    func testInvalidInputFailsInsteadOfSilentlyDropping() {
        XCTAssertThrowsError(
            try DomainRuleCompiler.compile(
                blocked: ["ads.example.com", "https://example.com"], exclusions: []
            )
        )
    }

    func testHelperMatchesEffectiveSetOnly() throws {
        let result = try DomainRuleCompiler.compile(
            blocked: ["ads.example.com"], exclusions: []
        )
        XCTAssertTrue(try result.matchesBlockedHost("cdn.ads.example.com"))
        XCTAssertFalse(try result.matchesBlockedHost("notads.example.com"))
    }
}

final class RulePipelineTests: XCTestCase {
    private let source = RuleSource(identifier: "internal-test", commit: "0123456789abcdef", license: "CC0-1.0", licenseVerified: true)

    func testCompilesAndAuditsOverlappingException() throws {
        let document = RuleDocument(datasetID: "dataset-1", source: source, blockedDomains: ["example.com"], exclusions: ["pay.example.com"])
        let snapshot = try RulePipeline.compile(document)
        XCTAssertTrue(snapshot.blockedDomains.isEmpty)
        XCTAssertEqual(snapshot.audit.first?.action, "suppressed-overlap")
    }

    func testRejectsUnverifiedLicenseAndUnsupportedSchema() {
        XCTAssertThrowsError(try RulePipeline.compile(RuleDocument(datasetID: "x", source: RuleSource(identifier: "x", commit: "c", license: "unknown", licenseVerified: false), blockedDomains: ["ads.example"])))
        XCTAssertThrowsError(try RulePipeline.compile(RuleDocument(schemaVersion: 2, datasetID: "x", source: source, blockedDomains: ["ads.example"])))
    }

    func testDeterministicEncoding() throws {
        let document = RuleDocument(datasetID: "dataset-1", source: source, blockedDomains: ["b.example", "a.example"])
        let snapshot = try RulePipeline.compile(document)
        XCTAssertEqual(try RulePipeline.deterministicData(snapshot), try RulePipeline.deterministicData(snapshot))
    }

    func testManifestValidation() throws {
        let manifest = RuleManifest(datasetID: "dataset-1", sequence: 1, artifacts: [RuleArtifact(name: "rules.json", byteCount: 4, sha256: String(repeating: "a", count: 64))], keyID: "test-key", signature: "test-signature")
        XCTAssertNoThrow(try manifest.validate())
    }
}
