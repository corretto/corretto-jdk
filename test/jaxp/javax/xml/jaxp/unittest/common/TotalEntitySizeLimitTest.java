/*
 * Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

/*
 * @test
 * @summary Verifies that jdk.xml.totalEntitySizeLimit is enforced individually for both DOM and SAX parsers.
 *          Uses two entities each under maxGeneralEntitySizeLimit but whose combined size exceeds totalEntitySizeLimit.
 *          Warning: this test was developed with a help of generative AI
 * @library /javax/xml/jaxp/unittest
 * @run main/othervm -Dtest.parser=dom -Dtest.expectedLimit=50000000 common.TotalEntitySizeLimitTest
 * @run main/othervm -Dtest.parser=sax -Dtest.expectedLimit=50000000 common.TotalEntitySizeLimitTest
 * @run main/othervm -Dtest.parser=dom -Dtest.expectedLimit=50000000 -Djdk.xml.totalEntitySizeLimit=50000000 common.TotalEntitySizeLimitTest
 * @run main/othervm -Dtest.parser=dom -Dtest.expectedLimit=50000000 -Djdk.xml.totalEntitySizeLimit=0 common.TotalEntitySizeLimitTest
 * @run main/othervm -Dtest.parser=sax -Dtest.expectedLimit=50000000 -Djdk.xml.totalEntitySizeLimit=50000000 common.TotalEntitySizeLimitTest
 * @run main/othervm -Dtest.parser=sax -Dtest.expectedLimit=50000000 -Djdk.xml.totalEntitySizeLimit=0 common.TotalEntitySizeLimitTest
 */
package common;

import common.util.LimitTestBase;
import org.xml.sax.SAXParseException;

public class TotalEntitySizeLimitTest {

    public static void main(String[] args) throws Exception {
        int expectedLimit = Integer.parseInt(System.getProperty("test.expectedLimit"));
        String prop = System.getProperty("jdk.xml.totalEntitySizeLimit");
        int limit = prop != null ? Integer.parseInt(prop) : expectedLimit;
        if (limit == 0) {
            LimitTestBase.parse(LimitTestBase.buildTwoEntityXml(expectedLimit / 2 + 1));
        } else {
            int eachSize = limit / 2 + 1;
            try {
                LimitTestBase.parse(LimitTestBase.buildTwoEntityXml(eachSize));
                throw new AssertionError("Expected SAXParseException");
            } catch (SAXParseException ex) {
                if (!ex.getMessage().contains("JAXP00010004")) {
                    throw new AssertionError(
                            "Expected JAXP00010004 in message: " + ex.getMessage());
                }
            }
            LimitTestBase.parse(LimitTestBase.buildTwoEntityXml(limit / 2));
        }
    }
}
