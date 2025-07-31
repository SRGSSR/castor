//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Castor

import Foundation
import Testing

@Suite
struct URLTests {
    @Test
    func castableUrls() {
        #expect(URL(castableString: "http://www.ietf.org/rfc/rfc2396.txt") != nil)
        #expect(URL(castableString: "https://www.ietf.org/rfc/rfc2396.txt") != nil)
    }

    @Test
    func uncastableUrls() {
        #expect(URL(castableString: "ftp://ftp.is.co.za/rfc/rfc1808.txt") == nil)
        #expect(URL(castableString: "ldap://[2001:db8::7]/c=GB?objectClass?one") == nil)
        #expect(URL(castableString: "mailto:John.Doe@example.com") == nil)
        #expect(URL(castableString: "news:comp.infosystems.www.servers.unix") == nil)
        #expect(URL(castableString: "tel:+1-816-555-1212") == nil)
        #expect(URL(castableString: "telnet://192.0.2.16:80/") == nil)
        #expect(URL(castableString: "urn:oasis:names:specification:docbook:dtd:xml:4.1.2") == nil)
        #expect(URL(castableString: "uncastable string") == nil)
    }
}
